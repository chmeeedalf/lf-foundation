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

#include <stdarg.h>
#include <stdlib.h>

#include <dispatch/dispatch.h>

#include <numeric>
#include <vector>

#import "internal.h"

#import <Foundation/NSOrderedSet.h>

#import <Foundation/NSCoder.h>
#import <Foundation/NSIndexSet.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSException.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>

@class NSArray, NSEnumerator, NSIndexSet, NSString, NSLocale, NSSet;

@interface _NSOrderedSetArrayFacade	:	NSArray
- (id) initWithOrderedSet:(NSOrderedSet *)set;
@end

@interface _NSOrderedSetSetFacade	:	NSSet
- (id) initWithOrderedSet:(NSOrderedSet *)set;
@end

@implementation NSOrderedSet

+ (id) orderedSet
{
	return [self new];
}

+ (id) orderedSetWithArray:(NSArray *)array
{
	return [[self alloc] initWithArray:array];
}

+ (id) orderedSetWithArray:(NSArray *)array range:(NSRange)range copyItems:(bool)copy
{
	return [[self alloc] initWithArray:array range:range copyItems:copy];
}

+ (id) orderedSetWithObject:(id)obj
{
	return [[self alloc] initWithObject:obj];
}

+ (id) orderedSetWithObjects:(id)obj,...
{
	std::vector<id> objects;
	va_list args;
	id o;

	objects.push_back(obj);
	va_start(args, obj);

	for (o = va_arg(args, __unsafe_unretained id); o != nil;)
	{
		objects.push_back(o);
	}

	return [[self alloc] initWithObjects:&objects[0] count:objects.size()];
}

+ (id) orderedSetWithObjects:(const id[])objs count:(NSUInteger)count
{
	return [[self alloc] initWithObjects:objs count:count];
}

+ (id) orderedSetWithOrderedSet:(NSOrderedSet *)set
{
	return [[self alloc] initWithOrderedSet:set];
}

+ (id) orderedSetWithOrderedSet:(NSOrderedSet *)set range:(NSRange)range copyItems:(bool)copy
{
	return [[self alloc] initWithOrderedSet:set range:range copyItems:copy];
}

+ (id) orderedSetWithSet:(NSSet *)set
{
	return [[self alloc] initWithSet:set];
}

+ (id) orderedSetWithSet:(NSSet *)set copyItems:(bool)copy
{
	return [[self alloc] initWithSet:set copyItems:copy];
}

- (id) initWithArray:(NSArray *)array
{
	return [self initWithArray:array range:NSMakeRange(0, [array count])
		copyItems:false];
}

- (id) initWithArray:(NSArray *)array copyItems:(bool)copy
{
	return [self initWithArray:array range:NSMakeRange(0, [array count])
		copyItems:false];
}

- (id) initWithArray:(NSArray *)array range:(NSRange)range copyItems:(bool)copy
{
	NSParameterAssert(NSMaxRange(range) <= [array count]);

	__block std::vector<id> objects;

	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger index, bool *stop){
		if (copy)
			obj = [obj copy];
		objects.push_back(obj);
	}];
	return [self initWithObjects:&objects[0] count:objects.size()];
}

- (id) initWithObject:(id)obj
{
	return [self initWithObjects:&obj count:1];
}

- (id) initWithObjects:(id)obj,...
{
	std::vector<id> objects;
	va_list args;
	id o;

	objects.push_back(obj);
	va_start(args, obj);

	for (o = va_arg(args, __unsafe_unretained id); o != nil;)
	{
		objects.push_back(o);
	}

	return [self initWithObjects:&objects[0] count:objects.size()];
}

- (id) initWithObjects:(const id[])objs count:(NSUInteger)count
{
	return [self subclassResponsibility:_cmd];
}

- (id) initWithOrderedSet:(NSOrderedSet *)set
{
	return [self initWithOrderedSet:set copyItems:false];
}

- (id) initWithOrderedSet:(NSOrderedSet *)set copyItems:(bool)copy
{
	return [self initWithOrderedSet:set range:NSMakeRange(0, [set count]) copyItems:copy];
}

- (id) initWithOrderedSet:(NSOrderedSet *)set range:(NSRange)range copyItems:(bool)copy
{
	return [self initWithArray:[set array] range:range copyItems:copy];
}

- (id) initWithSet:(NSSet *)set
{
	return [self initWithSet:set copyItems:false];
}

- (id) initWithSet:(NSSet *)set copyItems:(bool)copy
{
	return [self initWithArray:[set allObjects] copyItems:copy];
}

- (NSUInteger) count
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (bool) containsObject:(id)obj
{
	return ([self indexOfObject:obj] != NSNotFound);
}

- (void) enumerateObjectsAtIndexes:(NSIndexSet *)indexes
	options:(NSEnumerationOptions)opts
	usingBlock:(void (^)(id, NSUInteger, bool *))block
{
	[indexes enumerateIndexesWithOptions:opts
		usingBlock:^(NSUInteger idx, bool *stop){
			block([self objectAtIndex:idx], idx, stop);
		}];
}

- (void) enumerateObjectsUsingBlock:(void (^)(id, NSUInteger, bool *))block
{
	[self enumerateObjectsWithOptions:0 usingBlock:block];
}

- (void) enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id, NSUInteger, bool *))block
{
	dispatch_queue_t queue;

	if (opts & NSEnumerationConcurrent)
	{
		queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	}
	else
	{
		queue = dispatch_queue_create(NULL, NULL);
	}
	NSUInteger count = [self count];
	for (NSUInteger i = 0; i < count; i++)
	{
		__block bool stop = false;
		dispatch_async(queue, ^{
				if (stop)
					return;
				block([self objectAtIndex:i], i, &stop);});
		if (stop)
		{
			break;
		}
	}
	if (!(opts & NSEnumerationConcurrent))
	{
		dispatch_release(queue);
	}
}

- (id) firstObject
{
	return [self objectAtIndex:0];
}

- (id) lastObject
{
	return [self objectAtIndex:[self count] - 1];
}

- (id) objectAtIndex:(NSUInteger)index
{
	return [self subclassResponsibility:_cmd];
}

- (id) objectAtIndexedSubscript:(NSUInteger)index
{
	return [self objectAtIndex:index];
}

- (NSArray *) objectsAtIndexes:(NSIndexSet *)indexes
{
	NSMutableArray *objects = [NSMutableArray new];
	[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, bool *stop){
		[objects addObject:[self objectAtIndex:idx]];
	}];

	return objects;
}

- (NSUInteger) indexOfObject:(id)obj
{
	[self subclassResponsibility:_cmd];
	return NSNotFound;
}

- (NSUInteger) indexOfObject:(id)obj inSortedRange:(NSRange)range options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp
{
	if (NSMaxRange(range) >= [self count])
	{
		@throw [NSRangeException
			exceptionWithReason:@"Range out of bounds for ordered set."
			userInfo:nil];
	}
	if (obj == nil)
	{
		@throw [NSInvalidArgumentException
			exceptionWithReason:@"Nil object in search." userInfo:nil];
	}
	if (cmp == NULL)
	{
		@throw [NSInvalidArgumentException
			exceptionWithReason:@"Null comparator in search." userInfo:nil];
	}

	NSUInteger foundIndex = NSNotFound;

	// A binary search -- modify the input range as we go.
	/*
	   Keep searching after found if NSBinarySearchingFirstEqual or
	   NSBinarySearchingLastEqual are specified.

	   If NSBinarySearchingInsertionIndex is specified, returns the range's
	   location if not found, since that's the last index that's greater than
	   the object, or it's equal to NSMaxRange() of the input range, if all are
	   less than the input object.
	 */
	for (;;)
	{
		NSUInteger index = range.location + (range.length / 2);
		NSComparisonResult result = cmp([self objectAtIndex:index], obj);
		if (result == NSOrderedSame)
		{
			foundIndex = index;
			if (opts & NSBinarySearchingFirstEqual)
			{
				result = NSOrderedAscending;
			}
			else if (opts & NSBinarySearchingLastEqual)
			{
				result = NSOrderedDescending;
			}
			else
				break;
		}
		if (result == NSOrderedAscending)
		{
			range.location = index;
			range.length /= 2;
		}
		else if (result == NSOrderedDescending)
		{
			range.length /= 2;
		}
		if (range.length == 0)
			break;
	}
	if (foundIndex == NSNotFound && (opts & NSBinarySearchingInsertionIndex))
		foundIndex = range.location;

	return foundIndex;
}

- (NSUInteger) indexOfObjectAtIndexes:(NSIndexSet *)indexes options:(NSEnumerationOptions)opts passingTest:(bool (^)(id, NSUInteger, bool *))predicate
{
	__block NSUInteger outIndex = NSNotFound;
	[indexes enumerateIndexesWithOptions:opts
		usingBlock:^(NSUInteger index, bool *stop){
			if (predicate([self objectAtIndex:index], index, stop))
			{
				outIndex = index;
				*stop = true;
			}
		}];
	return outIndex;
}

- (NSUInteger) indexOfObjectPassingTest:(bool (^)(id, NSUInteger, bool *))predicate
{
	return [self indexOfObjectWithOptions:0 passingTest:predicate];
}

- (NSUInteger) indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(bool (^)(id, NSUInteger, bool *))predicate
{
	__block NSUInteger outIndex = NSNotFound;
	[self enumerateObjectsWithOptions:opts
		usingBlock:^(id obj, NSUInteger index, bool *stop){
			if (predicate(obj, index, stop))
			{
				outIndex = index;
				*stop = true;
			}
		}];

	return outIndex;
}

- (NSIndexSet *) indexesOfObjectsAtIndexes:(NSIndexSet *)indexes options:(NSEnumerationOptions)opts passingTest:(bool (^)(id, NSUInteger, bool *))predicate
{
	__block NSMutableIndexSet *outIndexes = [NSMutableIndexSet new];

	[self enumerateObjectsAtIndexes:indexes options:opts
		usingBlock:^(id obj, NSUInteger index, bool *stop) {
			if (predicate(obj, index, stop))
				[outIndexes addIndex:index];
		}];

	return outIndexes;
}

- (NSIndexSet *) indexesOfObjectsPassingTest:(bool (^)(id, NSUInteger, bool *))predicate
{
	__block NSMutableIndexSet *outIndexes = [NSMutableIndexSet new];

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger index, bool *stop) {
			if (predicate(obj, index, stop))
				[outIndexes addIndex:index];
		}];

	return outIndexes;
}

- (NSIndexSet *) indexesOfObjectsWithOptions:(NSBinarySearchingOptions)opts passingTest:(bool (^)(id, NSUInteger, bool *))predicate
{
	__block NSMutableIndexSet *outIndexes = [NSMutableIndexSet new];

	[self enumerateObjectsWithOptions:opts
		usingBlock:^(id obj, NSUInteger index, bool *stop) {
			if (predicate(obj, index, stop))
				[outIndexes addIndex:index];
		}];

	return outIndexes;
}

- (NSEnumerator *) objectEnumerator
{
	__block NSUInteger idx = 0;
	NSUInteger count = [self count];

	return [[NSBlockEnumerator alloc] initWithBlock:^{
		if (idx == count)
			return nil;
		return [self objectAtIndex:idx++];
	}];
}

- (NSEnumerator *) reverseObjectEnumerator
{
	__block NSUInteger idx = [self count];

	return [[NSBlockEnumerator alloc] initWithBlock:^{
		if (idx == 0)
			return nil;
		return [self objectAtIndex:--idx];
	}];
}

- (NSOrderedSet *) reversedOrderedSet
{
	std::vector<id> objects;

	for (id obj in [self reverseObjectEnumerator])
	{
		objects.push_back(obj);
	}
	return [[NSOrderedSet alloc] initWithObjects:&objects[0] count:objects.size()];
}

- (void) getObjects:(id __unsafe_unretained [])objs range:(NSRange)range
{
	NSParameterAssert(NSMaxRange(range) <= [self count]);

	for (NSUInteger i = range.location; i < NSMaxRange(range); ++i)
	{
		objs[i - range.location] = [self objectAtIndex:i];
	}
}


- (bool) isEqualToOrderedSet:(NSOrderedSet *)other
{
	__block bool equal = true;

	if ([other count] != [self count])
		return false;

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, bool *stop){
		if (![obj isEqual:[other objectAtIndex:idx]])
		{
			equal = false;
			*stop = true;
		}
	}];

	return equal;
}

- (bool) intersectsOrderedSet:(NSOrderedSet *)other
{
	__block bool intersects = false;

	if ([other count] != [self count])
		return false;

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, bool *stop){
		if ([other containsObject:obj])
		{
			intersects = true;
			*stop = true;
		}
	}];

	return intersects;
}

- (bool) intersectsSet:(NSSet *)other
{
	__block bool intersects = false;

	if ([other count] != [self count])
		return false;

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, bool *stop){
		if ([other containsObject:obj])
		{
			intersects = true;
			*stop = true;
		}
	}];

	return intersects;
}

- (bool) isSubsetOfOrderedSet:(NSOrderedSet *)other
{
	__block bool subset = true;

	if ([other count] != [self count])
		return false;

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, bool *stop){
		if (![other containsObject:obj])
		{
			subset = false;
			*stop = true;
		}
	}];

	return subset;
}

- (bool) isSubsetOfSet:(NSSet *)set
{
	__block bool subset = true;

	if ([set count] != [self count])
		return false;

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, bool *stop){
		if (![set containsObject:obj])
		{
			subset = false;
			*stop = true;
		}
	}];

	return subset;
}


- (NSArray *) sortedArrayUsingComparator:(NSComparator)cmp
{
	return [self sortedArrayWithOptions:0 usingComparator:cmp];
}

- (NSArray *) sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmp
{
	return [[self array] sortedArrayWithOptions:opts usingComparator:cmp];
}


- (NSString *) description
{
	return [self descriptionWithLocale:nil indent:0];
}

- (NSString *) descriptionWithLocale:(NSLocale *)locale
{
	return [self descriptionWithLocale:nil indent:0];
}

- (NSString *) descriptionWithLocale:(NSLocale *)locale indent:(NSUInteger)indent
{
	NSUInteger indent1 = indent + 4;
	NSString* indentation = [NSString stringWithFormat:
		[NSString stringWithFormat:@"%%%dc", indent1], ' '];
	NSUInteger count = [self count];

	if(count)
	{
		id stringRepresentation;
		NSMutableString* description = [NSMutableString stringWithString:@"(\n"];
		NSMutableArray *descrArray = [NSArray array];

		for (id object in self)
		{
			if ([object respondsToSelector:
					@selector(descriptionWithLocale:indent:)])
			{
				stringRepresentation = [object descriptionWithLocale:locale
					indent:indent1];
			}
			else if ([object
					respondsToSelector:@selector(descriptionWithLocale:)])
			{
				stringRepresentation = [object descriptionWithLocale:locale];
			}
			else
			{
				stringRepresentation = [object description];
			}
			[descrArray addObject:[indentation stringByAppendingString:stringRepresentation]];
		}
		[description appendString:[descrArray componentsJoinedByString:@",\n"]];
		[description appendString:@"\n"];
		if (indent)
			[description appendString:[NSString stringWithFormat:[NSString stringWithFormat:@"%%%dc",indent],' ']];
		[description appendString:@")"];
		return description;
	}
	return [indentation stringByAppendingString:@"()"];
}


- (NSArray *) array
{
	return [[_NSOrderedSetArrayFacade alloc] initWithOrderedSet:self];
}

- (NSSet *) set
{
	return [[_NSOrderedSetSetFacade alloc] initWithOrderedSet:self];
}

// Adopted protocols
// NSCoding
- (id)initWithCoder:(NSCoder *)coder
{
	NSArray *arrayRep = [coder decodeObject];

	return [self initWithArray:arrayRep];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self array]];
}

// NSCopying
-(id)copyWithZone:(NSZone *)zone
{
	return [[NSOrderedSet alloc] initWithOrderedSet:self];
}

// NSMutableCopying
-(id)mutableCopyWithZone:(NSZone *)zone
{
	return [[NSMutableOrderedSet alloc] initWithOrderedSet:self];
}

// NSFastEnumeration
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state
	objects:(__unsafe_unretained id [])stackBuf count:(NSUInteger)len
{
	if (state->state == 0)
	{
		state->state = 1;
		state->extra[0] = 0;
		state->mutationsPtr = &state->extra[1];
	}
	state->extra[1] = [self count];
	NSUInteger i = 0;

	for (; i < state->extra[1] && i < len; i++)
	{
		stackBuf[i] = [self objectAtIndex:i + state->extra[0]];
		state->extra[0]++;
	}

	return i;
}

@end

@implementation NSMutableOrderedSet
+ (id) orderedSetWithCapacity:(NSUInteger)cap
{
	return [[self alloc] initWithCapacity:cap];
}

- (id) initWithCapacity:(NSUInteger)cap
{
	return self;
}


- (void) addObject:(id)obj
{
	[self insertObject:obj atIndex:[self count]];
}

- (void) addObjects:(const id[])objs count:(NSUInteger)count
{
	NSUInteger myCount = [self count];

	for (NSUInteger i = 0; i < count; i++)
	{
		[self insertObject:objs[i] atIndex:myCount + i];
	}
}

- (void) addObjectsFromArray:(NSArray *)array
{
	NSUInteger myCount = [self count];

	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, bool *stop){
		[self insertObject:obj atIndex:myCount + idx];
	}];
}

- (void) insertObject:(id)obj atIndex:(NSUInteger)idx
{
	[self subclassResponsibility:_cmd];
}

- (void) insertObjects:(NSArray *)objs atIndexes:(NSIndexSet *)idxs
{
	NSParameterAssert([objs count] == [idxs count]);
	__block NSUInteger idx = [idxs firstIndex];

	[objs enumerateObjectsUsingBlock:^(id obj, NSUInteger unused, bool *stop){
		[self insertObject:obj atIndex:idx];
		idx = [idxs indexGreaterThanIndex:idx];
	}];
}

- (void) removeObject:(id)obj
{
	[self removeObjectAtIndex:[self indexOfObject:obj]];
}

- (void) removeObjectAtIndex:(NSUInteger)idx
{
	[self subclassResponsibility:_cmd];
}

- (void) removeObjectsAtIndexes:(NSIndexSet *)idxs
{
	[idxs enumerateIndexesWithOptions:NSEnumerationReverse
		usingBlock:^(NSUInteger idx, bool *stop){
			[self removeObjectAtIndex:idx];
		}];
}

- (void) removeObjectsInArray:(NSArray *)array
{
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, bool *stop){
		[self removeObjectAtIndex:[self indexOfObject:obj]];
	}];
}

- (void) removeObjectsInRange:(NSRange)range
{
	NSParameterAssert(NSMaxRange(range) <= [self count]);

	for (; range.length > 0; --range.length)
	{
		[self removeObjectAtIndex:NSMaxRange(range)];
	}
}

- (void) removeAllObjects
{
	[self removeObjectsInRange:NSMakeRange(0, [self count])];
}

- (void) replaceObjectAtIndex:(NSUInteger)idx withObject:(id)obj
{
	[self subclassResponsibility:_cmd];
}

- (void) replaceObjectsAtIndexes:(NSIndexSet *)idxs withObjects:(NSArray *)objs
{
	NSParameterAssert([objs count] == [idxs count]);
	__block NSUInteger idx = [idxs firstIndex];

	[objs enumerateObjectsUsingBlock:^(id obj, NSUInteger unused, bool *stop){
		[self replaceObjectAtIndex:idx withObject:obj];
		idx = [idxs indexGreaterThanIndex:idx];
	}];
}

- (void) replaceObjectsInRange:(NSRange)range withObjects:(const id[])objs count:(NSUInteger)count
{
	NSParameterAssert(NSMaxRange(range) <= [self count]);

	if (count > range.length)
	{
		for (NSUInteger i = 0; i < (count - range.length); ++i)
		{
			[self insertObject:objs[i] atIndex:NSMaxRange(range) + i];
		}
	}
	else if (count < range.length)
	{
		[self removeObjectsInRange:NSMakeRange(range.location + count,
				NSMaxRange(range))];
	}
	for (NSUInteger i = 0; i < count; i++)
	{
		[self replaceObjectAtIndex:(i + range.location) withObject:objs[i]];
	}
}

- (void) setObject:(id)obj atIndex:(NSUInteger)idx
{
	if (idx == [self count])
	{
		[self addObject:obj];
	}
	else
	{
		[self replaceObjectAtIndex:idx withObject:obj];
	}
}

- (void) moveObjectsAtIndexes:(NSIndexSet *)idxs toIndex:(NSUInteger)newIdx
{
	NSArray *objects = [self objectsAtIndexes:idxs];

	[self removeObjectsAtIndexes:idxs];
	newIdx -= [idxs countOfIndexesInRange:NSMakeRange(0,newIdx)];
	[self insertObjects:objects
		atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(newIdx, 0)]];
}

- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
	NSParameterAssert(idx1 < [self count] && idx2 < [self count]);

	id tmp = [self objectAtIndex:idx1];
	id tmp2 = [self objectAtIndex:idx2];

	// Exists just to empty out one index
	id noObj = [NSObject new];
	
	/* Need to do the three-step monty because replaceObjectAtIndex:withObject:
	 * does nothing if the replacing object already exists (which it would, if
	 * we didn't first erase one of the objects.
	 */
	[self replaceObjectAtIndex:idx1 withObject:noObj];
	[self replaceObjectAtIndex:idx2 withObject:tmp];
	[self replaceObjectAtIndex:idx1 withObject:tmp2];
}


- (void) sortUsingComparator:(NSComparator)cmp
{
	[self sortWithOptions:0 usingComparator:cmp];
}

- (void) sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmp
{
	[self sortRange:NSMakeRange(0,[self count])
		options:opts
		usingComparator:cmp];
}

- (void) sortRange:(NSRange)range options:(NSSortOptions)opts usingComparator:(NSComparator)cmp
{
	NSSortRangeUsingOptionsAndComparator(self, range, opts, cmp);
}


- (void) intersectOrderedSet:(NSOrderedSet *)other
{
	NSMutableIndexSet *delSet = [NSMutableIndexSet new];
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, bool *stop){
		if (![other containsObject:obj])
			[delSet addIndex:idx];
	}];
	[self removeObjectsAtIndexes:delSet];
}

- (void) intersectSet:(NSSet *)other
{
	NSMutableIndexSet *delSet = [NSMutableIndexSet new];
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, bool *stop){
		if (![other containsObject:obj])
			[delSet addIndex:idx];
	}];
	[self removeObjectsAtIndexes:delSet];
}

- (void) minusOrderedSet:(NSOrderedSet *)other
{
	[other enumerateObjectsUsingBlock:^(id obj, NSUInteger unused, bool *stop){
		[self removeObject:obj];
	}];
}

- (void) minusSet:(NSSet *)other
{
	[other enumerateObjectsUsingBlock:^(id obj, bool *stop){
		[self removeObject:obj];
	}];
}

- (void) unionOrderedSet:(NSOrderedSet *)other
{
	[other enumerateObjectsUsingBlock:^(id obj, NSUInteger unused, bool *stop){
		[self addObject:obj];
	}];
}

- (void) unionSet:(NSSet *)other
{
	[other enumerateObjectsUsingBlock:^(id obj, bool *stop){
		[self addObject:obj];
	}];
}


@end

@implementation _NSOrderedSetArrayFacade
{
	NSOrderedSet *realSet;
}

- (id) initWithOrderedSet:(NSOrderedSet *)set
{
	realSet = set;
	return self;
}

- (NSUInteger) count
{
	return [realSet count];
}

- (id) objectAtIndex:(NSUInteger)index
{
	return [realSet objectAtIndex:index];
}
@end

@implementation _NSOrderedSetSetFacade
{
	NSOrderedSet *realSet;
}

- (id) initWithOrderedSet:(NSOrderedSet *)set
{
	realSet = set;
	return self;
}

- (NSUInteger) count
{
	return [realSet count];
}

- (id) member:(id)obj
{
	NSUInteger idx = [realSet indexOfObject:obj];

	if (idx != NSNotFound)
	{
		return [realSet objectAtIndex:idx];
	}

	return nil;
}

- (id) objectEnumerator
{
	return [realSet objectEnumerator];
}

@end
