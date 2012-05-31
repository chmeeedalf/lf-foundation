/*
 * Copyright (c) 2012	Justin Hibbits
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the Project nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSKeyValueObserving.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSString.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#include <cstring>
#include <cstdio>
#include <cstdlib>
#include <ctype.h>
#include <string>
#include <algorithm>
#include <vector>
#include <objc/encoding.h>
#import "internal.h"

#import "NSKVCMutableArray.h"
#import "NSString+KVCAdditions.h"

@implementation NSKeyValueCodingException
@end

@implementation NSUndefinedKeyException
@end

NSMakeSymbol(NSTargetObjectUserInfoKey);
NSMakeSymbol(NSUnknownUserInfoKey);

NSString * const NSAverageKeyValueOperator = @"avg";
NSString * const NSCountKeyValueOperator = @"count";
NSString * const NSDistinctUnionOfArraysKeyValueOperator = @"distinctUnionOfArrays";
NSString * const NSDistinctUnionOfObjectsKeyValueOperator =
@"distinceUnionOfObjects";
NSString * const NSDistinctUnionOfSetsKeyValueOperator = @"distinctUnionOfSets";
NSString * const NSMaximumKeyValueOperator = @"max";
NSString * const NSMinimumKeyValueOperator = @"min";
NSString * const NSSumKeyValueOperator = @"sum";
NSString * const NSUnionOfArraysKeyValueOperator = @"unionOfArrays";
NSString * const NSUnionOfObjectsKeyValueOperator = @"unionOfObjects";
NSString * const NSUnionOfSetsKeyValueOperator = @"unionOfSets";

@implementation NSObject (KeyValueCoding)

+ (bool) accessInstanceVariablesDirectly
{
	return true;
}

- (id) valueForUndefinedKey:(NSString *)key
{
	@throw [NSUndefinedKeyException exceptionWithReason:@"Undefined key"
		userInfo:[NSDictionary dictionaryWithObjectsAndKeys:key,NSUnknownUserInfoKey,self,NSTargetObjectUserInfoKey,nil]];
	return nil;
}

- (void) setNilValueForKey:(NSString *)key
{
	@throw [NSInvalidArgumentException exceptionWithReason:@"Nil value for key"
		userInfo:[NSDictionary dictionaryWithObjectsAndKeys:key,NSUnknownUserInfoKey,self,NSTargetObjectUserInfoKey,nil]];
}

- (void) setValue:(id)val forUndefinedKey:(NSString *)key
{
	@throw [NSUndefinedKeyException exceptionWithReason:@"Undefined key to set"
		userInfo:[NSDictionary dictionaryWithObjectsAndKeys:key,NSUnknownUserInfoKey,self,NSTargetObjectUserInfoKey,nil]];
}

- (NSDictionary *) dictionaryWithValuesForKeys:(NSArray *)keys
{
	NSMutableDictionary *ret = [NSMutableDictionary new];

	for (NSString *k in keys)
	{
		id val = [self valueForKey:k];

		if (val == nil)
		{
			val = [NSNull null];
		}
		[ret setObject:val forKey:k];
	}

	return [ret copy];
}

- (void) setValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
	[keyedValues enumerateKeysAndObjectsUsingBlock:
		^(id key, id val, bool *stop){
			if ([val isEqual:[NSNull null]])
				val = nil;
			[self setValue:val forKey:key];
	}];
}

- (id) valueForKeyPath:(NSString *)path
{
	NSRange r = [path rangeOfString:@"."];

	if (r.length == 0)
	{
		return [self valueForKey:path];
	}

	return [[self valueForKey:[path substringToIndex:r.location]]
		valueForKeyPath:[path substringFromIndex:NSMaxRange(r)]];
}

- (void) setValue:(id)val forKeyPath:(NSString *)path
{
	NSRange r = [path rangeOfString:@"."];

	if (r.length == 0)
	{
		[self setValue:val forKey:path];
		return;
	}

	[[self valueForKey:[path substringToIndex:r.location]]
		setValue:val forKeyPath:[path substringFromIndex:NSMaxRange(r)]];
}

- (bool) validateValue:(id *)ioVal forKeyPath:(NSString *)path error:(out NSError **)errp
{
	NSUInteger i = [path indexOfString:@"."];

	if (i == NSNotFound)
	{
		return [self validateValue:ioVal forKey:path error:errp];
	}

	return [[self valueForKey:[path substringToIndex:i]]
		validateValue:ioVal forKeyPath:[path substringFromIndex:i+1]
		error:errp];
}

- (NSMutableArray *) mutableArrayValueForKeyPath:(NSString *)path
{
	NSUInteger i = [path indexOfString:@"."];

	if (i == NSNotFound)
	{
		return [self mutableArrayValueForKey:path];
	}

	return [[self valueForKey:[path substringToIndex:i]]
		mutableArrayValueForKeyPath:[path substringFromIndex:i+1]];
}

- (NSMutableSet *) mutableSetValueForKeyPath:(NSString *)path
{
	NSUInteger i = [path indexOfString:@"."];

	if (i == NSNotFound)
	{
		return [self mutableSetValueForKey:path];
	}

	return [[self valueForKey:[path substringToIndex:i]]
		mutableSetValueForKeyPath:[path substringFromIndex:i+1]];
}

- (NSMutableOrderedSet *) mutableOrderedSetValueForKeyPath:(NSString *)path
{
	NSUInteger i = [path indexOfString:@"."];

	if (i == NSNotFound)
	{
		return [self mutableOrderedSetValueForKey:path];
	}

	return [[self valueForKey:[path substringToIndex:i]]
		mutableOrderedSetValueForKeyPath:[path substringFromIndex:i+1]];
}

/*
   Search order for instance variable keys:
   - _<key>
   - _is<Key>
   - <key>
   - is<Key>
 */
Ivar findIvar(NSObject *self, NSString *key)
{
	Class cls = [self class];
	Ivar retval;

	if (key == nil || self == nil)
		return NULL;

	char keyBuf[[key length] + 4];

	[key getCString:(keyBuf + 3) maxLength:sizeof(keyBuf) - 3
		encoding:NSASCIIStringEncoding];

	keyBuf[2] = '_';

	if ((retval = class_getInstanceVariable(cls, &keyBuf[2])) != NULL)
	{
		return retval;
	}

	keyBuf[0] = '_';
	keyBuf[1] = 'i';
	keyBuf[2] = 's';

	char oldkbuf = keyBuf[3];
	keyBuf[3] = std::toupper(keyBuf[3]);

	if ((retval = class_getInstanceVariable(cls, keyBuf)) != NULL)
	{
		return retval;
	}

	keyBuf[3] = oldkbuf;
	if ((retval = class_getInstanceVariable(cls, &keyBuf[3])) != NULL)
	{
		return retval;
	}

	keyBuf[3] = std::toupper(keyBuf[3]);

	return class_getInstanceVariable(cls, &keyBuf[1]);
}

- (id) valueForKey:(NSString *)key
{
	SEL getSel;
	IMP imp;
	Ivar ivar;
	void *varAddr;
	const char *type;
	NSMethodSignature *sig;

	getSel = NSSelectorFromString([NSString
			stringWithFormat:@"get%@:",[key capitalizedString]]);
	sig = [self methodSignatureForSelector:getSel];
	imp = [self methodForSelector:getSel];

	if (sig != nil)
	{
		if ([sig numberOfArguments] != 2)
		{
			@throw [NSInvalidArgumentException
				exceptionWithReason:@"Key-value getter has wrong number of arguments"
				userInfo:nil];
		}
		type = [sig methodReturnType];
	}
	else
	{
		if (![[self class] accessInstanceVariablesDirectly])
		{
			return [self valueForUndefinedKey:key];
		}
		
		ivar = findIvar(self, key);
		if (ivar == NULL)
		{
			return [self valueForUndefinedKey:key];
		}

		varAddr = (char *)(__bridge void *)self + ivar_getOffset(ivar);
	}

	switch (*type)
	{
#define GET_VALUE(code, type, sel)\
		case code:\
			do { type v; \
				if (imp != NULL) \
				{ v = ((type (*)(id, SEL))imp)(self, getSel); } \
				else { v = *(type *)varAddr; } \
				break; \
				return [NSNumber sel:v]; \
			} while (0)
		GET_VALUE(_C_BOOL, bool, numberWithBool);
		GET_VALUE(_C_CHR, char, numberWithChar);
		GET_VALUE(_C_DBL, double, numberWithDouble);
		GET_VALUE(_C_FLT, float, numberWithFloat);
		GET_VALUE(_C_INT, int, numberWithInt);
		GET_VALUE(_C_LNG, long, numberWithLong);
		GET_VALUE(_C_LNG_LNG, long long, numberWithLongLong);
		GET_VALUE(_C_SHT, short, numberWithShort);
		GET_VALUE(_C_UCHR, unsigned char, numberWithUnsignedChar);
		GET_VALUE(_C_UINT, unsigned int, numberWithUnsignedInt);
		GET_VALUE(_C_ULNG, unsigned long, numberWithUnsignedLong);
		GET_VALUE(_C_ULNG_LNG, unsigned long long, numberWithUnsignedLongLong);
		GET_VALUE(_C_USHT, unsigned short, numberWithUnsignedShort);
		case _C_ID:
		case _C_CLASS:
			if (imp != NULL)
			{
				return ((id (*)(id, SEL))imp)(self, getSel);
			}
			else
			{
				return object_getIvar(self, ivar);
			}
		case _C_STRUCT_B:
#define GET_VALUE_STRUCT(t, sel)\
		if (strcmp(type, @encode(t)) == 0)\
			do { t v; \
				if (imp != NULL) \
				{ v = ((t (*)(id, SEL))imp)(self, getSel); } \
				else { v = *(t *)varAddr; } \
				break;\
				return [NSValue sel:v]; \
			} while (0)
			GET_VALUE_STRUCT(NSPoint, valueWithPoint);
			GET_VALUE_STRUCT(NSRange, valueWithRange);
			GET_VALUE_STRUCT(NSRect, valueWithRect);
			GET_VALUE_STRUCT(NSSize, valueWithSize);
			if (imp != NULL)
			{
				NSUInteger size;
				NSInvocation *inv = [NSInvocation
					invocationWithMethodSignature:sig];

				NSGetSizeAndAlignment(type, &size, NULL);

				[inv setTarget:self];
				[inv setSelector:getSel];
				[inv invoke];

				char bytes[size];
				[inv getReturnValue:bytes];
				return [NSValue valueWithBytes:bytes objCType:type];
			}
			else
			{
				return [NSValue valueWithBytes:varAddr
					objCType:ivar_getTypeEncoding(ivar)];
			}

#undef GET_VALUE_STRUCT
#undef GET_VALUE
		default:
			{
				return [self valueForUndefinedKey:key];
			}
	}
}

- (void) setValue:(id)value forKey:(NSString *)key
{
	SEL setSel = NSSelectorFromString([NSString
			stringWithFormat:@"set%@:",[key capitalizedString]]);
	IMP imp;
	Ivar ivar;
	void *varAddr;
	const char *type;
	NSMethodSignature *sig;

	if (value == nil || value == [NSNull null])
	{
		[self setNilValueForKey:key];
	}
	sig = [self methodSignatureForSelector:setSel];
	imp = [self methodForSelector:setSel];

	if (sig != nil)
	{
		if ([sig numberOfArguments] != 3)
		{
			@throw [NSInvalidArgumentException
				exceptionWithReason:@"Key-value setter has wrong number of arguments"
				userInfo:nil];
		}
		type = [sig getArgumentTypeAtIndex:2];
	}
	else
	{
		if (![[self class] accessInstanceVariablesDirectly])
		{
			[self setValue:value forUndefinedKey:key];
			return;
		}
		
		ivar = findIvar(self, key);
		if (ivar == NULL)
		{
			[self setValue:value forUndefinedKey:key];
		}

		varAddr = (char *)(__bridge void *)self + ivar_getOffset(ivar);
	}

	switch (*type)
	{
#define SET_VALUE(code, type, sel)\
		case code:\
			do { type v = [value sel]; \
				if (imp != NULL) \
				{ ((void (*)(id, SEL, type))imp)(self, setSel, v); } \
				else { *(type *)varAddr = v; } \
				break; \
			} while (0)
		SET_VALUE(_C_BOOL, bool, boolValue);
		SET_VALUE(_C_CHR, char, charValue);
		SET_VALUE(_C_DBL, double, doubleValue);
		SET_VALUE(_C_FLT, float, floatValue);
		SET_VALUE(_C_INT, int, intValue);
		SET_VALUE(_C_LNG, long, longValue);
		SET_VALUE(_C_LNG_LNG, long long, longLongValue);
		SET_VALUE(_C_SHT, short, shortValue);
		SET_VALUE(_C_UCHR, unsigned char, unsignedCharValue);
		SET_VALUE(_C_UINT, unsigned int, unsignedIntValue);
		SET_VALUE(_C_ULNG, unsigned long, unsignedLongValue);
		SET_VALUE(_C_ULNG_LNG, unsigned long long, unsignedLongLongValue);
		SET_VALUE(_C_USHT, unsigned short, unsignedShortValue);
		case _C_ID:
		case _C_CLASS:
			if (imp != NULL)
			{
				((void (*)(id, SEL, id))imp)(self, setSel, value);
			}
			else
			{
				object_setIvar(self, ivar, value);
			}
		case _C_STRUCT_B:
#define SET_VALUE_STRUCT(t, sel)\
		if (strcmp(type, @encode(t)) == 0)\
			do { t v = [value sel]; \
				if (imp != NULL) \
				{ ((void (*)(id, SEL, t))imp)(self, setSel, v); } \
				else { *(t *)varAddr = v; } \
				break;\
			} while (0)
			SET_VALUE_STRUCT(NSPoint, pointValue);
			SET_VALUE_STRUCT(NSRange, rangeValue);
			SET_VALUE_STRUCT(NSRect, rectValue);
			SET_VALUE_STRUCT(NSSize, sizeValue);
			if (imp != NULL)
			{
				NSUInteger byteSize;

				NSGetSizeAndAlignment(type, &byteSize, NULL);
				char bytes[byteSize];

				[value getValue:bytes];
				imp(self, setSel, bytes);
			}
			else
			{
				[value getValue:varAddr];
			}

#undef SET_VALUE_STRUCT
#undef SET_VALUE
		default:
			{
				[self setValue:value forUndefinedKey:key];
			}
	}
}

- (bool) validateValue:(id *)ioValue forKey:(NSString *)key error:(out NSError **)outError
{
	SEL validateSel = NSSelectorFromString([NSString
			stringWithFormat:@"validate%@:error:",[key capitalizedString]]);

	if ([self respondsToSelector:validateSel])
	{
		IMP imp = [self methodForSelector:validateSel];

		return ((bool(*)(id,SEL,id*,id*))imp)(self, validateSel, ioValue, outError);
	}
	return true;
}

- (NSMutableArray *) mutableArrayValueForKey:(NSString *)key
{
	TODO; // -[NSObject(NSKeyValueCoding) mutableArrayValueForKey:]
	return nil;
}

- (NSMutableSet *) mutableSetValueForKey:(NSString *)key
{
	TODO; // -[NSObject(NSKeyValueCoding) mutableSetValueForKey:]
	return nil;
}

- (NSMutableOrderedSet *) mutableOrderedSetValueForKey:(NSString *)key
{
	TODO; // -[NSObject(NSKeyValueCoding) mutableOrderedSetValueForKey:]
	return nil;
}

@end
