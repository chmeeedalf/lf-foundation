/*
 * Copyright (c) 2008-2012	Gold Project
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
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR COEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#include <stddef.h>
#include <stdlib.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSIndexSet.h>
#import <Foundation/NSString.h>
#include <vector>

@implementation NSIndexSet
{
	@protected
		std::vector<NSRange> indexes;
}

+ (id) indexSetWithIndexesInRange:(NSRange)range
{
	return [[self allocWithZone:NULL] initWithIndexesInRange:range];
}

+ (id) indexSetWithIndex:(unsigned)index
{
	return [[self allocWithZone:NULL] initWithIndex:index];
}

+ (id) indexSet
{
	return [[self allocWithZone:NULL] init];
}

- (id) initWithIndexSet:(NSIndexSet *)other
{
	[other enumerateRangesUsingBlock:^(NSRange range, bool *stop){
		self->indexes.push_back(range);
	}];
	return self;
}

- (id) initWithIndexesInRange:(NSRange)range
{
	indexes.push_back(range);
	return self;
}

- (id) initWithIndex:(unsigned)index
{
	return [self initWithIndexesInRange:NSMakeRange(index,1)];
}

- (id) init
{
	return [self initWithIndexesInRange:NSMakeRange(0,0)];
}

- (id) copyWithZone:(NSZone *)zone
{
	return self;
}

- (id) mutableCopyWithZone:(NSZone *)zone
{
	return [[NSMutableIndexSet allocWithZone:zone] initWithIndexSet:self];
}

- (NSUInteger)countOfIndexesInRange:(NSRange)range
{
	__block NSUInteger count;
	[self enumerateRangesInRange:range options:0 usingBlock:^(NSRange range,
			bool *stop){
		count += range.length;
	}];
	return count;
}

- (bool)isEqualToIndexSet:(NSIndexSet *)other
{
	return [self containsIndexes:other] && [other containsIndexes:self];
}

- (unsigned)count
{
	NSUInteger count = 0;

	for (NSRange &r: indexes)
	{
		count += r.length;
	}
	return count;
}

- (NSUInteger)firstIndex
{
	if (indexes.empty())
		return NSNotFound;
	return indexes.front().location;
}

- (NSUInteger)lastIndex
{
	if (indexes.empty())
		return NSNotFound;
	return NSMaxRange(indexes.back()) - 1;
}

- (NSUInteger)getIndexes:(NSUInteger *)buffer maxCount:(NSUInteger)capacity inIndexRange:(NSRange *)rangePtr
{
	__block NSRange range;
	__block NSUInteger cap = 0;

	if (rangePtr == NULL)
		range = NSMakeRange([self firstIndex], [self lastIndex] - [self firstIndex] + 1);
	else
		range = *rangePtr;
	[self enumerateRangesInRange:range options:0 usingBlock:^(NSRange inRange,
			bool *stop){
		cap--;
		NSUInteger i = inRange.location;
		for (; i < NSMaxRange(inRange); i++)
		{
			buffer[cap++] = i;

			if (cap == capacity)
			{
				*stop = true;
				break;
			}
		}
	}];

	range.location += cap;
	range.length -= cap;

	if (rangePtr != NULL)
		*rangePtr = range;

	return cap;
}

- (bool)containsIndexesInRange:(NSRange)range
{
	if ([self firstIndex] == NSNotFound)
		return false;

	if (NSMaxRange(range) > [self lastIndex] ||
			NSMaxRange(range) < [self firstIndex])
	{
		return false;
	}

	for (NSRange &r: indexes)
	{
		if (NSEqualRanges(r, range))
			return true;
	}

	return false;
}

- (bool)containsIndexes:(NSIndexSet *)other
{
	__block bool found = true;
	[other enumerateRangesUsingBlock:^(NSRange range, bool *stop){
		if (![self containsIndexesInRange:range])
		{
			found = false;
			*stop = true;
		}
	}];

	return found;
}

- (bool)containsIndex:(unsigned)index
{
	return [self containsIndexesInRange:NSMakeRange(index,1)];
}

- (NSUInteger)indexGreaterThanIndex:(NSUInteger)index
{
	++index;

	for (NSRange &r: indexes)
	{
		if (NSMaxRange(r) > index)
		{
			return std::max(r.location, index);
		}
	}
	return NSNotFound;
}

- (NSUInteger)indexGreaterThanOrEqualToIndex:(NSUInteger)index
{
	for (NSRange &r: indexes)
	{
		if (NSMaxRange(r) > index)
		{
			return std::max(r.location, index);
		}
	}
	return NSNotFound;
}

- (NSUInteger)indexLessThanIndex:(NSUInteger)index
{
	--index;

	auto i = std::find_if(indexes.rbegin(), indexes.rend(), [=](NSRange &r){
		return (r.location <= index);
	});

	if (i == indexes.rend())
		return NSNotFound;

	return std::min(index, NSMaxRange(*i) - 1);
}

- (NSUInteger)indexLessThanOrEqualToIndex:(NSUInteger)index
{
	auto i = std::find_if(indexes.rbegin(), indexes.rend(), [=](NSRange &r){
		return (r.location <= index);
	});

	if (i == indexes.rend())
		return NSNotFound;

	return std::min(index, NSMaxRange(*i) - 1);
}

- (bool)intersectsIndexesInRange:(NSRange)range
{
	for (NSRange &r: indexes)
	{
		if (NSIntersectionRange(r, range).length > 0)
			return true;
	}
	return false;
}

- (NSString *)description
{
	NSMutableString *m;
	if (indexes.empty())
	{
		return [NSString stringWithFormat:@"%@(no indexes)",
			   [super description]];
	}

	m = [NSMutableString stringWithFormat:@"%@[number of indexes: %u: ",
	  [super description],indexes.size()];

	for (NSRange &r: indexes)
	{
		if (r.length > 1)
			[m appendFormat:@"(%u-%u)",r.location, NSMaxRange(r) - 1];
		else
			[m appendFormat:@"(%u)",r.location];
	}
	[m appendString:@"]"];

	return m;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		NSUInteger i = 0;
		[coder encodeInteger:indexes.size() forKey:@"NSRangeCount"];
		for (NSRange &r: indexes)
		{
			[coder encodeInteger:r.location forKey:[NSString
				stringWithFormat:@"NSRangeLocation.%d",i]];
			[coder encodeInteger:r.location forKey:[NSString
				stringWithFormat:@"NSRangeLength.%d",i]];
			i++;
		}
	}
	else
	{
		NSUInteger size = indexes.size();
		[coder encodeValueOfObjCType:@encode(NSUInteger) at:&size];
		if (size > 0)
			[coder encodeArrayOfObjCType:@encode(NSRange) count:size at:&indexes[0]];
	}
}

- (id) initWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		NSUInteger i;
		NSUInteger count;
		count = [coder decodeIntegerForKey:@"NSRangeCount"];
		for (i = 0; i < count; i++)
		{
			NSRange r;
			r.location = [coder decodeIntegerForKey:
				[NSString stringWithFormat:@"NSRangeLocation.%d",i]];
			r.length = [coder decodeIntegerForKey:
				[NSString stringWithFormat:@"NSRangeLength.%d",i]];
			indexes.push_back(r);
		}
	}
	else
	{
		NSUInteger size = indexes.size();
		[coder encodeValueOfObjCType:@encode(NSUInteger) at:&size];
		if (size > 0)
		{
			indexes.reserve(size);
			[coder decodeArrayOfObjCType:@encode(NSRange) count:size at:&indexes[0]];
		}
	}
	return self;
}

- (NSUInteger) indexPassingTest:(bool (^)(NSUInteger, bool *))predicate
{
	__block NSUInteger retval = NSNotFound;

	[self enumerateIndexesUsingBlock:^(NSUInteger i, bool *stop){
		if (predicate(i, stop))
		{
			retval = i;
			*stop = true;
		}
	}];

	return retval;
}

- (NSUInteger) indexWithOptions:(NSEnumerationOptions)opts passingTest:(bool (^)(NSUInteger, bool *))predicate
{
	__block NSUInteger retval = NSNotFound;

	[self enumerateIndexesWithOptions:opts usingBlock:^(NSUInteger i, bool *stop){
		if (predicate(i, stop))
		{
			retval = i;
			*stop = true;
		}
	}];

	return retval;
}

- (NSUInteger) indexInRange:(NSRange)range options:(NSEnumerationOptions)opts passingTest:(bool (^)(NSUInteger, bool *))predicate
{
	__block NSUInteger retval = NSNotFound;

	[self enumerateIndexesInRange:range options:opts usingBlock:^(NSUInteger i, bool *stop){
		if (predicate(i, stop))
		{
			retval = i;
			*stop = true;
		}
	}];

	return retval;
}

- (NSIndexSet *) indexesPassingTest:(bool (^)(NSUInteger, bool *))predicate
{
	__block NSMutableIndexSet *other = [NSMutableIndexSet new];

	[self enumerateIndexesUsingBlock:^(NSUInteger i, bool *stop){
		if (predicate(i, stop))
		{
			[other addIndex:i];
		}
	}];

	return other;
}

- (NSIndexSet *) indexesWithOptions:(NSEnumerationOptions)opts passingTest:(bool (^)(NSUInteger, bool *))predicate
{
	__block NSMutableIndexSet *other = [NSMutableIndexSet new];

	[self enumerateIndexesWithOptions:opts usingBlock:^(NSUInteger i, bool *stop){
		if (predicate(i, stop))
		{
			[other addIndex:i];
			*stop = true;
		}
	}];

	return other;
}

- (NSIndexSet *) indexesInRange:(NSRange)range options:(NSEnumerationOptions)opts passingTest:(bool (^)(NSUInteger, bool *))predicate
{
	__block NSMutableIndexSet *other = [NSMutableIndexSet new];

	[self enumerateIndexesInRange:range options:opts usingBlock:^(NSUInteger i, bool *stop){
		if (predicate(i, stop))
		{
			[other addIndex:i];
			*stop = true;
		}
	}];

	return other;
}


- (void) enumerateIndexesUsingBlock:(void (^)(NSUInteger, bool *))predicate
{
	for (const NSRange &r: indexes)
	{
		bool stop = false;
		NSUInteger i = r.location;
		
		for (; i < NSMaxRange(r) && !stop; i++)
		{
			predicate(i, &stop);
		}
		if (stop)
			break;
	}
}

- (void) enumerateIndexesWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(NSUInteger, bool *))predicate
{
	// Range limit is (NSNotFound - 1), so there's at most NSNotFound indexes
	[self enumerateIndexesInRange:NSMakeRange(0, NSNotFound) options:opts
		usingBlock:predicate];
}

- (void) enumerateIndexesInRange:(NSRange)range options:(NSEnumerationOptions)opts usingBlock:(void (^)(NSUInteger, bool *))predicate
{
	NSInteger delta;
	NSInteger offset;
	
	if (opts & NSEnumerationReverse)
	{
		delta = -1;
		offset = 1;
	}
	else
	{
		delta = 1;
		offset = 0;
	}

	[self enumerateRangesInRange:range options:opts usingBlock:^(NSRange r, bool *stop){
		NSUInteger begin;
		NSUInteger end;
		if (opts & NSEnumerationReverse)
		{
			begin = NSMaxRange(r);
			end = r.location;
		}
		else
		{
			begin = r.location;
			end = NSMaxRange(r);
		}

		for (; begin - offset != end; begin += delta)
		{
			predicate(begin - offset, stop);
			if (*stop)
				break;
		}
	}];
}

- (void) enumerateRangesUsingBlock:(void (^)(NSRange, bool *))block
{
	for (NSRange &r: indexes)
	{
		bool stop = false;

		block(r, &stop);
		if (stop)
			break;
	}
}

- (void) enumerateRangesWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(NSRange, bool *))block
{
	[self enumerateRangesInRange:NSMakeRange(0, NSNotFound) options:opts
		usingBlock:block];
}

- (void) enumerateRangesInRange:(NSRange)range options:(NSEnumerationOptions)opts usingBlock:(void (^)(NSRange, bool *))block
{
	auto pred = [&](const NSRange r)->bool {
		bool stop = false;;
		block(r, &stop);
		return stop;
	};

	if (opts & NSEnumerationReverse)
	{
		std::find_if(indexes.rbegin(), indexes.rend(), pred);
	}
	else
	{
		std::find_if(indexes.begin(), indexes.end(), pred);
	}
}

@end

@implementation NSMutableIndexSet

-(void)addIndexesInRange:(NSRange)range
{
	NSUInteger i = 0;
	// TODO: Finish

	for (NSRange &r: indexes)
	{
		if (NSUnionRange(range, r).length <= range.length+r.length)
		{
			r = NSUnionRange(range, r);
			range = r;
		}
		else if (NSMaxRange(range) < r.location)
		{
			break;
		}
		i++;
	}
	indexes.insert(indexes.begin() + i, range);
	indexes.erase(std::remove_if(indexes.begin(), indexes.end(),
				[=](NSRange &r){ return r.location == range.location; }));
}

-(void)addIndexes:(NSIndexSet *)other
{
	for (const NSRange &r: other->indexes)
	{
		[self addIndexesInRange:r];
	}
}

-(void)addIndex:(NSUInteger)index
{
	[self addIndexesInRange:NSMakeRange(index, 1)];
}

-(void)removeAllIndexes
{
	indexes.clear();
}

-(void)removeIndexesInRange:(NSRange)range
{
	NSRange newRange = NSMakeRange(0, 0);

	for (NSRange &r: indexes)
	{
		NSRange irange = NSIntersectionRange(r, range);

		if (irange.length == 0)
			continue;

		/* There are only a small number of outcomes from this intersection:
		   - The intersection spans the length of the range in the vector.
		   - The intersection is the length of the range to remove
		     - In this instance, split the range in two parts, write the first half
		     back, and save the second half to add after traversing.
		   - The intersection lands at the end of the range
		   - The intersection lands at the beginning of the range
		 */
		if (irange.length == r.length)
			r.length = 0;
		if (irange.length == range.length)
		{
			newRange.location = NSMaxRange(irange);
			newRange.length = NSMaxRange(r) - NSMaxRange(irange);
			r.length = irange.location - r.location;
			break;
		}
		else if (irange.location > r.location)
		{
			r.length = irange.location - r.location;
		}
		else if (irange.location < r.location)
		{
			r.length = NSMaxRange(r) - NSMaxRange(irange);
			r.location = NSMaxRange(irange);
		}
	}
	indexes.erase(std::remove_if(indexes.begin(), indexes.end(), [](NSRange r){
				return r.length == 0; }), indexes.end());
	if (newRange.length != 0)
	{
		[self addIndexesInRange:newRange];
	}
}

-(void)removeIndexes:(NSIndexSet *)other
{
	for (const NSRange &r: other->indexes)
	{
		[self removeIndexesInRange:r];
	}
}

-(void)removeIndex:(NSUInteger)index
{
	[self removeIndexesInRange:NSMakeRange(index, 1)];
}

-(void)shiftIndexesStartingAtIndex:(NSUInteger)index by:(NSInteger)delta
{
	if (delta == 0)
		return;

	index = [self indexGreaterThanOrEqualToIndex:index];
	const auto i = std::find_if(indexes.begin(), indexes.end(), [=](NSRange &r){
			return NSLocationInRange(index, r);});

	if (i == indexes.end())
		return;

	NSRange tmp = NSMakeRange(index, NSMaxRange(*i) - index);
	i->length = index - i->location;
	if (delta > 0)
	{
		indexes.insert(i+1, tmp);

		const auto after = i + 2;
		std::for_each(after, indexes.end(), [=](NSRange &r){ r.location += delta; });
	}
	else
	{
		std::vector<NSRange> newranges(i+1, indexes.end());

		newranges[0] = tmp;

		indexes.erase(i + 1, indexes.end());
		std::for_each(newranges.begin(), newranges.end(),
				[&](NSRange &r){
					r.location += delta;
					[self addIndexesInRange:r];
				});
	}
}

@end
