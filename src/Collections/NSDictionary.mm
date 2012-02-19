/*
 * Copyright (c) 2004-2012	Gold Project
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
 * THIS SOFTWARE IS PROVIDED BY THE PROJECT ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */

/*
   NSDictionary.m

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

   This file is part of libFoundation.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.
*/

#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <vector>

#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSPropertyListSerialization.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSString.h>

#import "NSCoreDictionary.h"

@interface _DictionaryObjectEnumerator	:	NSEnumerator
{
	NSEnumerator *keys;
	NSDictionary *dict;
}
- (id) initWithKeyEnumerator:(NSEnumerator *)keyEnum dictionary:(NSDictionary *)dict;

@end


@interface NSDictionary(DictionaryExtensions)
- (id)initWithObjectsAndKeys:(id)firstObject arguments:(va_list)argList;
@end
/*
 * NSDictionary class
 */

static Class DictionaryClass;
static Class MutableDictionaryClass;
static Class CoreDictionaryClass;

@implementation NSDictionary

+ (void) initialize
{
	DictionaryClass = [NSDictionary class];
	MutableDictionaryClass = [NSMutableDictionary class];
	CoreDictionaryClass = [NSCoreDictionary class];
}

/* Creating and Initializing an NSDictionary */

+ (id)allocWithZone:(NSZone *)zone
{
	id s = NSAllocateObject((self == DictionaryClass) ? CoreDictionaryClass : (Class)self, 0, zone);

	return s;
}

+ (id)dictionary
{
	return [self new];
}

+ (id)dictionaryWithObjects:(NSArray*)objects forKeys:(NSArray*)keys
{
	return [[self allocWithZone:NULL] initWithObjects:objects forKeys:keys];
}

+ (id)dictionaryWithObjects:(const id [])objects forKeys:(const id [])keys
	count:(unsigned int)count
{
	return [[self allocWithZone:NULL]
		initWithObjects:objects forKeys:keys count:count];
}

+ (id)dictionaryWithObjectsAndKeys:(id)firstObject, ...
{
	id dict = [self alloc];
	va_list va;

	va_start(va, firstObject);
	dict = [dict initWithObjectsAndKeys:firstObject arguments:va];
	va_end(va);
	return dict;
}

+ (id)dictionaryWithDictionary:(NSDictionary*)aDict
{
	return [[self allocWithZone:NULL]
		initWithDictionary:aDict];
}

+ (id)dictionaryWithObject:object forKey:key
{
	return [[self allocWithZone:NULL]
			initWithObjects:&object forKeys:&key count:1];
}

+ (id) dictionaryWithContentsOfURI:(NSURI *)uri
{
	return [[self alloc] initWithContentsOfURI:uri];
}

- (id) initWithContentsOfURI:(NSURI *)uri
{
	self = nil;

	NSData *d = [[NSData alloc] initWithContentsOfURI:uri];

	if (d == nil)
	{
		return nil;
	}
	@try
	{
		self = [NSPropertyListSerialization propertyListWithData:d options:NSPropertyListImmutable
			format:NULL error:NULL];
		if (![self isKindOfClass:[NSDictionary class]])
		{
			return nil;
		}
	}
	@catch (...)
	{
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary copyItems:(bool)flag
{
	unsigned count = [dictionary count];
	std::vector<id> keys(count);
	std::vector<id> values(count);

	count = 0;
	for (id key in dictionary)
	{
		keys[count] = key;
		if (flag)
		{
			values[count] = [[dictionary objectForKey:key] copy];
		}
		else
		{
			values[count] = [dictionary objectForKey:key];
		}
		count++;
	}

	self = [self initWithObjects:&values[0] forKeys:&keys[0] count:count];
	return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
	return [self initWithDictionary:dictionary copyItems:false];
}

- (id)initWithObjectsAndKeys:(id)firstObject,...
{
	va_list va;
	va_start(va, firstObject);
	self = [self initWithObjectsAndKeys:firstObject arguments:va];
	va_end(va);
	return self;
}

- (id)initWithObjects:(NSArray*)objects forKeys:(NSArray*)keysArray
{
	unsigned int i = 0;
	unsigned int count = [objects count];
	std::vector<id> keys;
	std::vector<id> values;

	if (count != [keysArray count])
	{
		@throw([NSInvalidArgumentException exceptionWithReason:
			@"NSDictionary initWithObjects:forKeys must \
			have both arguments of the same size" userInfo:nil]);
	}

	for (i = 0; i < count; i++)
	{
		keys.push_back([keysArray objectAtIndex:i]);
		values.push_back([objects objectAtIndex:i]);
	}
	self = [self initWithObjects:&values[0] forKeys:&keys[0] count:count];

	return self;
}

- (id)initWithObjects:(const id [])objects forKeys:(const id [])keys
count:(unsigned int)count
{
	[self subclassResponsibility:_cmd];
	return self;
}

/* Accessing Keys and Values */

- (NSArray*)allKeys
{
	id array;
	std::vector<id> objs;

	for (id key in self)
	{
		objs.push_back(key);
	}
	array = [[NSArray alloc] initWithObjects:&objs[0] count:objs.size()];

	return array;
}

- (NSArray *) allKeysForObject:(id)obj
{
	__block NSMutableArray *ret = [NSMutableArray array];

	[self enumerateKeysAndObjectsUsingBlock:^(id key, id object, bool *stop){
		if ([object isEqual:obj])
			[ret addObject:key];
	}];
	return ret;
}

- (NSArray*)allValues
{
	id array;
	std::vector<id> objs;

	for (id key in self)
	{
		objs.push_back([self objectForKey:key]);
	}
	array = [[NSArray alloc] initWithObjects:&objs[0] count:objs.size()];

	return array;
}

- (void) getObjects:(id[])objects andKeys:(id[])keys
{
	__block NSUInteger idx = 0;

	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, bool *stop){
		objects[idx] = obj;
		keys[idx] = key;
		idx++;
	}];
}

struct kvsCtx
{
	NSDictionary *d;
	SEL comparator;
};

static NSComparisonResult compareVals(id key1, id key2, void *ctx)
{
	struct kvsCtx *context = (struct kvsCtx *)ctx;

	id val1;
	id val2;

	val1 = [context->d objectForKey:key1];
	val2 = [context->d objectForKey:key2];

	return (NSComparisonResult)(intptr_t)[val1 performSelector:context->comparator withObject:val2];
}

- (NSArray *) keysSortedByValueUsingSelector:(SEL)comp
{
	struct kvsCtx context = {self, comp};

	return [[self allKeys] sortedArrayUsingFunction:compareVals context:&context];
}

- (NSArray *) keysSortedByValueUsingComparator:(NSComparator)cmp
{
	return [self keysSortedByValueWithOptions:0 usingComparator:cmp];
}

- (NSArray *) keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmp
{
	return [[self allKeys] sortedArrayUsingComparator:cmp];
}

- (NSSet *) keysOfEntriesPassingTest:(bool (^)(id key, id obj, bool *stop))predicate
{
	return [self keysOfEntriesWithOptions:0 passingTest:predicate];
}

- (NSSet *) keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(bool (^)(id key, id obj, bool *stop))predicate
{
	__block NSMutableSet *outset = [NSMutableSet new];

	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, bool *stop){
		if (predicate(key, obj, stop))
		{
			[outset addObject:obj];
		}
	}];
	return outset;
}

- (NSEnumerator*)keyEnumerator
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (NSEnumerator *)objectEnumerator
{
	return [[_DictionaryObjectEnumerator alloc]
		initWithKeyEnumerator:[self keyEnumerator]
		dictionary:self];
}

- (void) enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, bool *stop))block
{
	[self enumerateKeysAndObjectsWithOptions:0 usingBlock:block];
}

- (void) enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, bool *stop))block
{
	bool stop = false;

	for (id key in self)
	{
		block(key, [self objectForKey:key], &stop);
		if (stop)
		{
			break;
		}
	}
}

- (id)objectForKey:(id)aKey
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (NSArray*)objectsForKeys:(NSArray*)keys notFoundMarker:notFoundObj
{
	id tmp;
	std::vector<id> objs;
	id ret;

	for (id key in keys)
	{
		tmp = [self objectForKey:key];
		if (tmp == nil)
			tmp = notFoundObj;
		objs.push_back(tmp);
	}

	ret = [NSArray arrayWithObjects:&objs[0] count:objs.size()];

	return ret;
}

/* Counting Entries */

- (NSUInteger)count
{
	[self subclassResponsibility:_cmd];
	return 0;
}

/*
 * Comparing Dictionaries
 */

- (bool)isEqualToDictionary:(NSDictionary*)other
{
	if( other == self )
	{
		return true;
	}
	if ([self count] != [other count] || other == nil)
	{
		return false;
	}
	for (id key in self)
	{
		if (![[self objectForKey:key] isEqual:[other objectForKey:key]])
		{
			return false;
		}
	}
	return true;
}

/* Storing Dictionaries */

- (NSString*)descriptionWithLocale:(NSLocale*)locale
	indent:(unsigned int)indent
{
	id value;
	unsigned indent1 = indent + 4;
	NSMutableArray* keyDescriptions;
	NSString *keyDesc, *valDesc;
	NSString *description, *indentation, *indent0;

	if(![self count])
	{
		return @"{}";
	}

	indentation = [NSString stringWithFormat:
		[NSString stringWithFormat:@"%%%dc", indent1], ' '];
	if (indent != 0)
	{
		indent0 = [NSString stringWithFormat:
			[NSString stringWithFormat:@"%%%dc", indent], ' '];
	} else {
		indent0 = @"";
	}

	@autoreleasepool {
		keyDescriptions = [NSMutableArray arrayWithCapacity:[self count]];

		for (id key in self)
		{
			value = [self objectForKey:key];

			if ([key respondsToSelector:@selector(descriptionWithLocale:indent:)])
			{
				keyDesc = [key descriptionWithLocale:locale indent:indent1];
			}
			else if ([key respondsToSelector:@selector(descriptionWithLocale:)])
			{
				keyDesc = [key descriptionWithLocale:locale];
			}
			else
			{
				keyDesc = [key description];
			}

			if ([value respondsToSelector:@selector(descriptionWithLocale:indent:)])
			{
				valDesc = [value descriptionWithLocale:locale indent:indent1];
			}
			else if ([value respondsToSelector:@selector(descriptionWithLocale:)])
			{
				valDesc = [value descriptionWithLocale:locale];
			}
			else
			{
				valDesc = [value description];
			}

			keyDesc = [NSString stringWithFormat:@"%@%@ = %@;\n",
					indentation,keyDesc,valDesc];
			[keyDescriptions addObject:keyDesc];
		}

		description = [[NSString alloc] initWithFormat:@"{\n%@%@}",
					[keyDescriptions componentsJoinedByString:@""],
					indent0
						];
	}

	return description;
}

- (NSString*)descriptionWithLocale:(NSLocale*)locale
{
	return [self descriptionWithLocale:locale indent:0];
}

- (NSString*)description
{
	return [self descriptionWithLocale:nil indent:0];
}

- (NSString *) descriptionInStringsFileFormat
{
	NSMutableString *desc = [NSMutableString new];
	[desc appendString:@"{\n"];
	for (id k in [self allKeys])
	{
		[desc appendFormat:@"\"%@\" = \"%@\";\n",k,[self objectForKey:k]];
	}
	[desc appendString:@"}"];
	return desc;
}

/* From adopted/inherited protocols */

- (NSHashCode)hash
{
	return [self count];
}

- (bool)isEqual:(id)anObject
{
	if (![anObject isKindOfClass:[NSDictionary class]])
	{
		return false;
	}
	return [self isEqualToDictionary:anObject];
}

- (id)copyWithZone:(NSZone*)zone
{
	if (NSShouldRetainWithZone(self, zone))
	{
		return self;
	}
	else
	{
		return [[[self class] allocWithZone:zone]
			initWithDictionary:self copyItems:false];
	}
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
	return [[NSMutableDictionary allocWithZone:zone] initWithDictionary:self];
}

/*
   Identical to -objectForKey:
 */
- (id):(id)key
{
	return [self objectForKey:key];
}

- (id)valueForKey:(id)key
{
	if ([key isKindOfClass:[NSString class]] && [key hasPrefix:@"@"])
	{
		key = [key substringWithRange:NSRange(1, [key length] - 1)];
		return [super valueForKey:key];
	}
	else
		return [self objectForKey:key];
}

/* Ugh, this algorithm is O(n^2), better hope this is only run once. A better
 * implementation is in NSCoreDictionary.mm.
 */
- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *)state
	objects:(__unsafe_unretained id [])stackBuf count:(unsigned long)len
{
	unsigned long i = 0;
	NSEnumerator *en = [self keyEnumerator];

	if (state->state == 0)
	{
		state->state = 1;
		state->extra[0] = 0;
	}
	state->itemsPtr = stackBuf;

	for (; i < state->extra[0]; i++)
	{
		[en nextObject];
	}

	for (i = 0; i < len; i++)
	{
		id obj = [en nextObject];
		if (obj == nil)
			break;
		stackBuf[i] = obj;
	}
	state->extra[0] = i;

	return i;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		NSArray *keys = [self allKeys];
		NSMutableArray *vals = [NSMutableArray new];
		for (id key in keys)
		{
			[vals addObject:[self objectForKey:key]];
		}
		[coder encodeObject:keys forKey:@"GD.Dict.keys"];
		[coder encodeObject:vals forKey:@"GD.Dict.vals"];
	}
	else
	{
		size_t count = [self count];
		[coder encodeValueOfObjCType:@encode(size_t) at:&count];

		for (id key in self)
		{
			[coder encodeObject:key];
			[coder encodeObject:[self objectForKey:key]];
		}
	}
}

- (id) initWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		NSArray *keys = [coder decodeObjectForKey:@"GD.Dict.keys"];
		NSArray *vals = [coder decodeObjectForKey:@"GD.Dict.vals"];
		self = [self initWithObjects:vals forKeys:keys];
	}
	else
	{
		size_t count;
		[coder decodeValueOfObjCType:@encode(size_t) at:&count];

		if (count > 0)
		{
			std::vector<id> keys(count);
			std::vector<id> values(count);

			for (size_t i = 0; i < count; i++)
			{
				keys.push_back([coder decodeObject]);
				values.push_back([coder decodeObject]);
			}
			self = [self initWithObjects:&values[0] forKeys:&keys[0] count:count];
		}
		else
		{
			self = [self init];
		}
	}
	return self;
}

@end

@implementation NSMutableDictionary

+ (id)allocWithZone:(NSZone *)zone
{
	id s = NSAllocateObject((self == MutableDictionaryClass) ?  CoreDictionaryClass : (Class)self, 0, zone);

	return s;
}

+ (id)dictionaryWithCapacity:(unsigned int)aNumItems
{
	return [[self alloc] initWithCapacity:aNumItems];
}

- (id)initWithCapacity:(unsigned int)aNumItems
{
	[self subclassResponsibility:_cmd];
	return self;
}

/* Adding and Removing Entries */

- (void)addEntriesFromDictionary:(NSDictionary*)otherDictionary
{
	for (id key in otherDictionary)
	{
		[self setObject:[otherDictionary objectForKey:key] forKey:key];
	}
}

- (void)removeAllObjects
{
	for (id key in [self allKeys])
	{
		[self removeObjectForKey:key];
	}
}

- (void)removeObjectForKey:(id)theKey
{
	[self subclassResponsibility:_cmd];
}

- (void)removeObjectsForKeys:(NSArray*)keyArray
{
	for (id key in keyArray)
	{
		[self removeObjectForKey:key];
	}
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
	[self subclassResponsibility:_cmd];
}

- (void)setValue:(id)anObject forKey:(id)key
{
	if (anObject == nil)
	{
		[self removeObjectForKey:key];
	} else {
		[self setObject:anObject forKey:key];
	}
}

- (void)setDictionary:(NSDictionary*)otherDictionary
{
	[self removeAllObjects];
	[self addEntriesFromDictionary:otherDictionary];
}

@end

/*
 * Extensions to NSDictionary
 */

@implementation NSDictionary(DictionaryExtensions)

- (id)initWithObjectsAndKeys:(id)firstObject arguments:(va_list)argList
{
	id object;
	std::vector<id> keys;
	std::vector<id> values;

	for (object = firstObject; object != nil; object = va_arg(argList,id))
	{
		values.push_back(object);
		keys.push_back(va_arg(argList, id));
		if (*keys.rbegin() == nil)
		{
			@throw([NSInvalidArgumentException
					exceptionWithReason: @"Nil key to be added in dictionary"
					userInfo:nil]);
		}
	}

	if (values.size() == 0)
	{
		Class cls = [self class];
		return [cls new];
	}

	self = [self initWithObjects:&values[0] forKeys:&keys[0] count:values.size()];

	return self;
}

@end;

@implementation _DictionaryObjectEnumerator

- (id) initWithKeyEnumerator:(NSEnumerator *)keyEnum dictionary:(NSDictionary *)d
{
	dict = d;
	keys = keyEnum;
	return self;
}

- (id) nextObject
{
	id obj = [keys nextObject];
	
	if (obj != nil)
	{
		return [dict objectForKey:obj];
	}
	return nil;
}

@end
