/* Copyright (c) 2006-2007 Johannes Fortmann
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOTT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSKeyValueObserving.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSString.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#import "NSKVCMutableArray.h"
#import "NSString+KVCAdditions.h"

@implementation NSKeyValueCodingException
@end

@implementation NSUndefinedKeyException
@end

@implementation NSObject (KeyValueCoding)
- (void)_demangleTypeEncoding:(const char *)type to:(char *)cleanType
{
	while(*type)
	{
		if(*type == '"')
		{
			type++;
			while(*type && *type != '"')
			{
				type++;
			}
			type++;
		}
		if (*type == '+')
		{
			type++;
		}
		while(isdigit(*type))
		{
			type++;
		}
		*cleanType = *type;
		if (*type != 0)
		{
			type++, cleanType++, *cleanType = 0;
		}
	}
}

- (id)_wrapValue:(void *)value ofType:(const char *)type
{
	char*cleanType = alloca(strlen(type) + 1);

	// strip offsets & quotes from type
	[self _demangleTypeEncoding:type to:cleanType];

	if(type[0] != '@')
	{
		return [NSValue valueWithBytes:value objCType:cleanType];
	}
	return value;
}

- (bool)_setValue:(id)value toBuffer:(void *)buffer ofType:(const char *)type
{
	char*cleanType = alloca(strlen(type) + 1);

	[self _demangleTypeEncoding:type to:cleanType];

	if(cleanType[0] != '@')
	{
		if(strcmp([value objCType], cleanType) && strlen(cleanType) > 1)
		{
			NSLog(@"trying to set value of type %s for type %s", cleanType, [value objCType]);
			return false;
		}
		[value getValue:buffer];
	}
	else
	{
		*(id *)buffer = value;
	}
	return true;
}

- (id)_wrapReturnValueForSelector:(SEL)sel
{
	id sig = [self methodSignatureForSelector:sel];
	const char*type = [sig methodReturnType];

	if(strcmp(type, "@"))
	{
		id inv = [NSInvocation invocationWithMethodSignature:sig];
		[inv setSelector:sel];
		[inv setTarget:self];
		[inv invoke];

		int returnLength = [sig methodReturnLength];
		void *returnValue = alloca(returnLength);
		[inv getReturnValue:returnValue];

		return [self _wrapValue:returnValue ofType:type];
	}
	return [self performSelector:sel];
}

- (void)_setValue:(id)value withSelector:(SEL)sel fromKey:(id)key
{
	id sig = [self methodSignatureForSelector:sel];
	const char*type = [sig getArgumentTypeAtIndex:2];

	if(type[0] != '@')
	{
		if(!value)
		{
			// value is nil and accessor doesn't take object type
			return [self setNilValueForKey:key];
		}
		size_t size;
		NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
		[inv setSelector:sel];
		[inv setTarget:self];

		size = objc_sizeof_type(type);
		void *buffer = alloca(size);
		[self _setValue:value toBuffer:buffer ofType:type];

		[inv setArgument:buffer atIndex:2];

		[inv invoke];
		return;
	}
	[self performSelector:sel withObject:value];
}

- (id)valueForKey:(NSString *)key
{
	if(!key)
	{
		return [self valueForUndefinedKey:nil];
	}
	SEL sel = NSSelectorFromString(key);

	if([self respondsToSelector:sel])
	{
		return [self _wrapReturnValueForSelector:sel];
	}
	else
	{
		int len = [key maximumLengthOfBytesUsingEncoding:NSASCIIStringEncoding];
		char *keyname = alloca(len + 1);
		[key getCString:keyname maxLength:len encoding:NSASCIIStringEncoding];
		char *selname = alloca(strlen(keyname) + 5);

#define TRY_PREFIX( prefix ) \
	strcpy(selname, prefix); \
	strcat(selname, keyname); \
	sel = sel_getUid(selname); \
	if([self respondsToSelector:sel]) \
	{ \
		return [self _wrapReturnValueForSelector:sel]; \
	}
		keyname[0] = toupper(keyname[0]);
		TRY_PREFIX("is");
#undef TRY_PREFIX
	}

	if([object_getClass(self) accessInstanceVariablesDirectly])
	{
		const char *k = [key UTF8String];
		char *ktest;

		asprintf(&ktest, "_%s", k);
		Ivar ivar = class_getInstanceVariable(object_getClass(self), ktest);
		free(ktest);
		if(!ivar)
		{
			ivar = class_getInstanceVariable(object_getClass(self), k);
		}
		if(ivar)
		{
			return [self _wrapValue:(void *)self + ivar_getOffset(ivar) ofType:ivar_getTypeEncoding(ivar)];
		}

	}

	return [self valueForUndefinedKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	NSString *ukey = [key capitalizedString];
	const char *cukey = [key UTF8String];
	SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@:", ukey]);

	if([self respondsToSelector:sel])
	{
		return [self _setValue:value withSelector:sel fromKey:key];
	}

	if([object_getClass(self) accessInstanceVariablesDirectly])
	{
		char *keyVarStr;

		asprintf(&keyVarStr, "_%s", [key UTF8String]);

		Ivar ivar = class_getInstanceVariable(object_getClass(self), keyVarStr);
		free(keyVarStr);
		if(!ivar)
		{
			asprintf(&keyVarStr, "_is%s", cukey);
			ivar = class_getInstanceVariable(object_getClass(self), keyVarStr);
			free(keyVarStr);
		}
		if(!ivar)
		{
			ivar = class_getInstanceVariable(object_getClass(self), [key UTF8String]);
			free(keyVarStr);
		}
		if(!ivar)
		{
			asprintf(&keyVarStr, "is%s", cukey);
			ivar = class_getInstanceVariable(object_getClass(self), cukey);
			free(keyVarStr);
		}

		if(ivar)
		{
			bool shouldNotify = [object_getClass(self) automaticallyNotifiesObserversForKey:key];
			if(shouldNotify)
			{
				[self willChangeValueForKey:key];
			}
			// if value is nil and ivar is not an object type
			if(!value && ivar_getTypeEncoding(ivar)[0] != '@')
			{
				return [self setNilValueForKey:key];
			}

			[self _setValue:value toBuffer:(char *)self + ivar_getOffset(ivar) ofType:ivar_getTypeEncoding(ivar)];
			if(shouldNotify)
			{
				[self didChangeValueForKey:key];
			}
			return;
		}
	}

	[self setValue:value forUndefinedKey:key];
}

- (bool)validateValue:(id *)ioValue forKey:(NSString *)key error:(NSError * *)outError
{
	SEL sel = NSSelectorFromString([NSString stringWithFormat:@"validate%@:error:", [key capitalizedString]]);

	if([self respondsToSelector:sel])
	{
		return false; // objc_msgSend(self, sel, ioValue, outError);
	}
	return true;
}

+ (bool)accessInstanceVariablesDirectly
{
	return true;
}

- (id)valueForUndefinedKey:(NSString *)key
{
	@throw([NSUndefinedKeyException exceptionWithReason:[NSString stringWithFormat:@"%@: trying to get undefined key %@", [self className], key] userInfo:nil]);
	return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	@throw([NSUndefinedKeyException exceptionWithReason:[NSString stringWithFormat:@"%@: trying to set undefined key %@", [self className], key] userInfo:nil]);
}

- (void)setNilValueForKey:(id)key
{
	@throw([NSInvalidArgumentException exceptionWithReason:[NSString stringWithFormat:@"%@: trying to set nil value for key %@", [self className], key] userInfo:nil]);
}

- (id)valueForKeyPath:(NSString *)keyPath
{
	NSString *firstPart, *rest;

	[keyPath _KVC_partBeforeDot:&firstPart afterDot:&rest];
	if(rest)
	{
		return [[self valueForKey:firstPart] valueForKeyPath:rest];
	}
	else
	{
		return [self valueForKey:firstPart];
	}
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
	NSString *firstPart, *rest;

	[keyPath _KVC_partBeforeDot:&firstPart afterDot:&rest];

	if(rest)
	{
		[[self valueForKey:firstPart] setValue:value forKeyPath:rest];
	}
	else
	{
		[self setValue:value forKey:firstPart];
	}
}

- (bool)validateValue:(id *)ioValue forKeyPath:(NSString *)keyPath error:(NSError * *)outError
{
	id array = [[[keyPath componentsSeparatedByString:@"."] mutableCopy] autorelease];
	id lastPathComponent = [array lastObject];

	[array removeObject:lastPathComponent];
	id pathComponent;
	id ret = self;
	for (pathComponent in array)
	{
		ret = [ret valueForKey:pathComponent];
		if (ret == nil)
		{
			break;
		}
	}
	return [self validateValue:ioValue forKey:lastPathComponent error:outError];
}

- (NSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys
{
	id ret = [NSDictionary dictionary];
	id key;

	for (key in keys)
	{
		id value = [self valueForKey:key];
		[ret setObject:value ? value:(id)[NSNull null] forKey:key];
	}
	return ret;
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
	NSString *key;
	NSNull *null = [NSNull null];

	for (key in keyedValues)
	{
		id value = [keyedValues objectForKey:key];
		[self setValue:value == null ? nil:value forKey:key];
	}
}

- (id)mutableArrayValueForKey:(id)key
{
	return [[[NSKVCMutableArray alloc] initWithKey:key forProxyObject:self] autorelease];
}

- (id)mutableArrayValueForKeyPath:(id)keyPath
{
	NSString *firstPart, *rest;

	[keyPath _KVC_partBeforeDot:&firstPart afterDot:&rest];
	if(rest)
	{
		return [[self valueForKeyPath:firstPart] valueForKeyPath:rest];
	}
	else
	{
		return [[[NSKVCMutableArray alloc] initWithKey:firstPart forProxyObject:self] autorelease];
	}
}

- (id) initWithDictionary:(NSDictionary *)dict
{
	[self setValuesForKeysWithDictionary:dict];
	return self;
}
@end
