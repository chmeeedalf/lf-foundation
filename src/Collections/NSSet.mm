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
   NSSet.m

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

#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSException.h>
#import <Foundation/NSCoder.h>

#import "NSCoreSet.h"

/*
 * NSSet
 */

@interface NSSet(extensions)

- (id)initWithObject:(id)firstObject arglist:(va_list)argList;

@end

static Class SetClass;
static Class MutableSetClass;
static Class CoreSetClass;

@implementation NSSet

+ (void) initialize
{
	SetClass = [NSSet class];
	MutableSetClass = [NSMutableSet class];
	CoreSetClass = [NSCoreSet class];
}

/* Allocating and Initializing a NSSet */

+ (id)allocWithZone:(NSZone*)zone
{
	return NSAllocateObject( (self == SetClass) ?  CoreSetClass : (Class)self, 0, zone);
}

+ (id)set
{
	return [[self alloc] init];
}

+ (id)setWithArray:(NSArray*)array
{
	return [[self alloc] initWithArray:array];
}

+ (id)setWithObject:(id)anObject
{
	return [[self alloc] initWithObjects:anObject, nil];
}

+ (id)setWithObjects:(id)firstObj,...
{
	id set;
	va_list va;

	va_start(va, firstObj);
	set = [[self alloc] initWithObject:firstObj arglist:va];
	va_end(va);
	return set;
}

+ (id)setWithObjects:(const id[])objects count:(unsigned int)count
{
	return [[self alloc] initWithObjects:objects count:count];
}

+ (id)setWithSet:(NSSet*)aSet
{
	return [[self alloc] initWithSet:aSet];
}

- (id)init
{
	return self;
}

- (id)initWithArray:(NSArray*)array
{
	std::vector<id> objects;

	for (id obj in array)
	{
		objects.push_back(obj);
	}

	self = [self initWithObjects:&objects[0] count:objects.size()];

	return self;
}

- (id)initWithObjects:(id)firstObj,...
{
	va_list va;
	va_start(va, firstObj);
	self = [self initWithObject:firstObj arglist:va];
	va_end(va);
	return self;
}

- (id)initWithObject:(id)firstObject arglist:(va_list)argList
{
	id object;
	std::vector<id> objs;

	for (object = firstObject; object; object = va_arg(argList,id))
	{
		objs.push_back(object);
	}

	self = [self initWithObjects:&objs[0] count:objs.size()];

	return self;
}

- (id)initWithObjects:(const id[])objects count:(unsigned int)count
{
	return self;
}

- (id)initWithSet:(NSSet*)set copyItems:(bool)flag
{
	std::vector<id> objs;

	for (id key in set)
	{
		objs.push_back(flag ? [key copyWithZone:NULL] : key);
	}

	self = [self initWithObjects:&objs[0] count:objs.size()];

	return self;
}

- (id)initWithSet:(NSSet*)aSet
{
	return [self initWithSet:aSet copyItems:false];
}

- (NSSet *) setByAddingObject:(id)anObject
{
	NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[self allObjects]];
	[arr addObject:anObject];
	NSSet *newSet = [NSSet setWithArray:arr];
	return newSet;
}

- (NSSet *) setByAddingObjectsFromArray:(NSArray *)other
{
	NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[self allObjects]];
	[arr addObjectsFromArray:other];
	NSSet *newSet = [NSSet setWithArray:arr];
	return newSet;
}

- (NSSet *) setByAddingObjectsFromSet:(NSSet *)other
{
	return [self setByAddingObjectsFromArray:[other allObjects]];
}

/* Querying the NSSet */

- (NSArray*)allObjects
{
	std::vector<id> objs;

	for (id key in self)
	{
		objs.push_back(key);
	}
	return [NSArray arrayWithObjects:&objs[0] count:objs.size()];
}

- (id)anyObject
{
	return [[self objectEnumerator] nextObject];
}

- (bool)containsObject:(id)anObject
{
	return [self member:anObject] ? true : false;
}

- (NSIndex)count
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (id)member:(id)anObject
{
	return [self subclassResponsibility:_cmd];
}

- (NSEnumerator*)objectEnumerator
{
	return [self subclassResponsibility:_cmd];
}

/* Sending Messages to Elements of the NSSet */

- (void)makeObjectsPerformSelector:(SEL)aSelector
{
	for (id key in self)
	{
		[key performSelector:aSelector];
	}
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)anObject
{
	for (id key in self)
	{
		[key performSelector:aSelector withObject:anObject];
	}
}

/* Comparing Sets */

- (bool)intersectsSet:(NSSet*)otherSet
{
	for (id key in self)
	{
		if ([otherSet containsObject:key])
		{
			return true;
		}
	}
	return false;
}

- (bool)isEqualToSet:(NSSet*)otherSet
{
	if ([self count] != [otherSet count])
	{
		return false;
	}

	for (id key in self)
	{
		if (![otherSet containsObject:key])
		{
			return false;
		}
	}

	return true;
}

- (bool)isSubsetOfSet:(NSSet*)otherSet
{
	for (id key in self)
	{
		if (![otherSet containsObject:key])
		{
			return false;
		}
	}
	return true;
}

/* Creating a NSString Description of the NSSet */

- (NSString*)descriptionWithLocale:(NSLocale*)locale
{
	return [self descriptionWithLocale:locale indent:0];
}

- (NSString*)description
{
	return [self descriptionWithLocale:nil indent:0];
}

- (NSString*)descriptionWithLocale:(NSLocale*)locale
   indent:(unsigned int)indent
{
	return [[self allObjects] descriptionWithLocale:locale indent:indent];
}

/* From adopted/inherited protocols */

- (NSHashCode)hash
{
	return [self count];
}

- (bool)isEqual:(id)anObject
{
	if (![anObject isKindOfClass:object_getClass(self)])
	{
		return false;
	}
	return [self isEqualToSet:anObject];
}

- (id)copyWithZone:(NSZone*)zone
{
	return [[NSSet allocWithZone:zone] initWithSet:self copyItems:false];
}

- (id)mutableCopyWithZone:(NSZone*)zone
{
	return [[NSMutableSet allocWithZone:zone] initWithSet:self copyItems:false];
}

- (void) setValue:(id)val forKey:(NSString *)key
{
	for (id obj in self)
	{
		[obj setValue:val forKey:key];
	}
}

- (id) valueForKey:(NSString *)key
{
	NSMutableSet *s = [NSMutableSet new];

	for (id obj in self)
	{
		id val = [obj valueForKey:key];
		if (val != nil)
			[s addObject:val];
	}
	return s;
}

/* Ugh, this algorithm is O(n^2), better hope this is only run once. A better
 * implementation is in NSCoreSet.mm.
 */
- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *)state
	objects:(__unsafe_unretained id [])stackBuf count:(unsigned long)len
{
	unsigned long i = 0;
	NSEnumerator *en = [self objectEnumerator];

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

- (void) enumerateObjectsUsingBlock:(void (^)(id obj, bool *stop))block
{
	for (id obj in self)
	{
		bool stop = false;
		block(obj, &stop);
		if (stop)
		{
			break;
		}
	}
}

- (void) enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, bool *stop))block
{
}

- (NSSet *) objectsPassingTest:(bool (^)(id obj, bool *stop))predicate
{
	__block NSMutableSet *newSet = [NSMutableSet new];

	[self enumerateObjectsUsingBlock:^(id obj, bool *stop){
		if (predicate(obj, stop))
		{
			[newSet addObject:obj];
		}
	}];
	return newSet;
}

- (NSSet *) objectsWithOptions:(NSEnumerationOptions)opts passingTest:(bool (^)(id obj, bool *stop))predicate
{
	__block NSMutableSet *newSet = [NSMutableSet new];

	[self enumerateObjectsWithOptions:opts usingBlock:^(id obj, bool *stop){
		if (predicate(obj, stop))
		{
			[newSet addObject:obj];
		}
	}];
	return newSet;
}

- (NSArray *) sortedArrayUsingDescriptors:(NSArray *)descriptors
{
	return [[self allObjects] sortedArrayUsingDescriptors:descriptors];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		[coder encodeObject:[self allObjects] forKey:@"GD.S.objs"];
	}
	else
	{
		size_t count = [self count];
		[coder encodeValueOfObjCType:@encode(size_t) at:&count];

		for (id obj in self)
		{
			[coder encodeObject:obj];
		}
	}
}

- (id) initWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		return [self initWithArray:[coder decodeObjectForKey:@"GD.S.objs"]];
	}
	else
	{
		size_t count;
		std::vector<id> objs;

		[coder decodeValueOfObjCType:@encode(size_t) at:&count];

		if (count == 0)
		{
			return [self init];
		}
		objs.reserve(count);
		for (size_t i = 0; i < count; i++)
		{
			objs.push_back([coder decodeObject]);
		}
		self = [self initWithObjects:&objs[0] count:count];
	}
	return self;
}

@end

@implementation NSMutableSet

+ (id)allocWithZone:(NSZone*)zone
{
	return NSAllocateObject( (self == MutableSetClass) ?  CoreSetClass : (Class)self, 0, zone);
}

+ (id)setWithCapacity:(unsigned)numItems
{
	return [[self alloc] initWithCapacity:numItems];
}

- (id)initWithCapacity:(unsigned)numItems
{
	return self;
}

- (id)init
{
	return [self initWithCapacity:0];
}

- (void)addObject:(id)object
{
	[self subclassResponsibility:_cmd];
}

- (void)addObjectsFromArray:(NSArray*)array
{
	for (id obj in array)
	{
		[self addObject:obj];
	}
}

- (void)unionSet:(NSSet*)other
{
	for (id key in other)
		[self addObject:key];
}

- (void)setSet:(NSSet*)other
{
	[self removeAllObjects];
	[self unionSet:other];
}

/* Removing Objects */

- (void)intersectSet:(NSSet*)other
{
	NSArray *objs = [self allObjects];
	for (id key in objs)
	{
		if (![other containsObject:key])
		{
			[self removeObject:key];
		}
	}
}

- (void)minusSet:(NSSet*)other
{
	for (id key in other)
	{
		[self removeObject:key];
	}
}

- (void)removeAllObjects
{
	NSArray *objs = [self allObjects];
	for (id key in objs)
	{
		[self removeObject:key];
	}
}

- (void)removeObject:(id)object
{
	[self subclassResponsibility:_cmd];
}

@end /* NSSet */
