/*
 * Copyright (c) 2010-2012	Justin Hibbits
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

#include <algorithm>
#include <vector>

#import <Foundation/NSIndexPath.h>
#import <Foundation/NSByteOrder.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>

// TODO: Uniquify IndexPaths and cache them in a hash table.
@implementation NSIndexPath
{
	std::vector<NSUInteger> indexes;
}

+ (id) indexPathWithIndex:(NSUInteger)index
{
	return [[self alloc] initWithIndex:index];
}

+ (id) indexPathWithIndexes:(NSUInteger *)indexes length:(size_t)length
{
	return [[self alloc] initWithIndexes:indexes length:length];
}

- (id) initWithIndex:(NSUInteger)index
{
	return [self initWithIndexes:&index length:1];
}

- (id) initWithIndexes:(NSUInteger *)idxs length:(size_t)len
{
	std::copy(idxs, idxs + len, std::back_inserter(indexes));
	return self;
}

- (void) getIndexes:(NSUInteger *)idxOut
{
	std::copy(indexes.begin(), indexes.end(), idxOut);
}

- (NSUInteger) indexAtPosition:(NSUInteger)pos
{
	if (pos > indexes.size())
		return NSNotFound;
	return indexes[pos];
}

- (NSIndexPath *) indexPathByAddingIndex:(NSUInteger)idx
{
	std::vector<NSUInteger> newIndexes = indexes;
	newIndexes.push_back(idx);

	NSIndexPath *newPath = [NSIndexPath indexPathWithIndexes:&newIndexes[0]
		length:indexes.size()+1];

	return newPath;
}

- (NSIndexPath *) indexPathByRemovingLastIndex
{
	NSAssert(indexes.size() > 1, @"Cannot remove the only path index.");
	return [NSIndexPath indexPathWithIndexes:&indexes[0] length:indexes.size() - 1];
}

- (size_t) length
{
	return indexes.size();
}

- (NSComparisonResult) compare:(NSIndexPath *)other
{
	size_t end = (indexes.size() > other->indexes.size()) ? indexes.size() :
		other->indexes.size();
	for (size_t i = 0; i < end; i++)
	{
		if (i >= indexes.size())
			return NSOrderedAscending;
		if (i >= other->indexes.size())
			return NSOrderedDescending;
		if (indexes[i] != other->indexes[i])
		{
			return (indexes[i] > other->indexes[i]) ? NSOrderedDescending :
				NSOrderedAscending;
		}
	}
	return NSOrderedSame;
}

- (id) copyWithZone:(NSZone *)zone
{
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		[coder encodeInt64:indexes.size() forKey:@"IndexPathLength"];
		std::vector<NSUInteger> buf(indexes.size());

		for (size_t i = 0; i < indexes.size(); i++)
		{
			buf[i] = NSSwapHostLongLongToBig(indexes[i]);
		}
		NSData *d = [[NSData alloc] initWithBytes:&buf[0] length:buf.size() *
			sizeof(NSUInteger)];
		[coder encodeObject:d forKey:@"IndexPathData"];
	}
	else
	{
		size_t len = indexes.size();
		[coder encodeValueOfObjCType:@encode(size_t) at:&len];
		[coder encodeArrayOfObjCType:@encode(NSUInteger) count:indexes.size()
			at:&indexes[0]];
	}
}

- (id) initWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		NSUInteger len = [coder decodeInt64ForKey:@"IndexPathLength"];
		NSUInteger *src;
		NSData *d = [coder decodeObjectForKey:@"IndexPathData"];
		src = (NSUInteger *)[d bytes];
		for (size_t i = 0; i < len; i++)
		{
			indexes.push_back(NSSwapBigLongLongToHost(src[i]));
		}
	}
	else
	{
		NSUInteger len;
		[coder decodeValueOfObjCType:@encode(size_t) at:&len];
		indexes.reserve(len);
		[coder decodeArrayOfObjCType:@encode(NSUInteger) count:len
			at:&indexes[0]];
	}
	return self;
}

- (bool) isEqual:(id)other
{
	return ((self == other) || ([other isKindOfClass:[self class]] &&
				[self compare:other] == NSOrderedSame));
}
@end
