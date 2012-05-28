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
	std::vector<NSUInteger> _indexes;
	NSHashCode _hash;
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

- (id) initWithIndexes:(NSUInteger *)indexes length:(size_t)len
{
	std::copy(indexes, indexes + len, std::back_inserter(_indexes));
	return self;
}

- (void) getIndexes:(NSUInteger *)indexes
{
	std::copy(_indexes.begin(), _indexes.end(), indexes);
}

- (NSUInteger) indexAtPosition:(NSUInteger)pos
{
	if (pos > _indexes.size())
		return NSNotFound;
	return _indexes[pos];
}

- (NSIndexPath *) indexPathByAddingIndex:(NSUInteger)idx
{
	std::vector<NSUInteger> newIndexes = _indexes;
	newIndexes.push_back(idx);

	NSIndexPath *newPath = [NSIndexPath indexPathWithIndexes:&newIndexes[0]
		length:_indexes.size()+1];

	return newPath;
}

- (NSIndexPath *) indexPathByRemovingLastIndex
{
	NSAssert(_indexes.size() > 1, @"Cannot remove the only path index.");
	return [NSIndexPath indexPathWithIndexes:&_indexes[0] length:_indexes.size() - 1];
}

- (size_t) length
{
	return _indexes.size();
}

- (NSComparisonResult) compare:(NSIndexPath *)other
{
	size_t end = (_indexes.size() > other->_indexes.size()) ? _indexes.size() :
		other->_indexes.size();
	for (size_t i = 0; i < end; i++)
	{
		if (i >= _indexes.size())
			return NSOrderedAscending;
		if (i >= other->_indexes.size())
			return NSOrderedDescending;
		if (_indexes[i] != other->_indexes[i])
		{
			return (_indexes[i] > other->_indexes[i]) ? NSOrderedDescending :
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
		[coder encodeInt64:_indexes.size() forKey:@"IndexPathLength"];
		std::vector<NSUInteger> buf(_indexes.size());

		for (size_t i = 0; i < _indexes.size(); i++)
		{
			buf[i] = NSSwapHostLongLongToBig(_indexes[i]);
		}
		NSData *d = [[NSData alloc] initWithBytes:&buf[0] length:buf.size() *
			sizeof(NSUInteger)];
		[coder encodeObject:d forKey:@"IndexPathData"];
	}
	else
	{
		size_t len = _indexes.size();
		[coder encodeValueOfObjCType:@encode(size_t) at:&len];
		[coder encodeArrayOfObjCType:@encode(NSUInteger) count:_indexes.size()
			at:&_indexes[0]];
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
			_indexes.push_back(NSSwapBigLongLongToHost(src[i]));
		}
	}
	else
	{
		NSUInteger len;
		[coder decodeValueOfObjCType:@encode(size_t) at:&len];
		_indexes.reserve(len);
		[coder decodeArrayOfObjCType:@encode(NSUInteger) count:len
			at:&_indexes[0]];
	}
	return self;
}

- (bool) isEqual:(id)other
{
	return ((self == other) || ([other isKindOfClass:[self class]] &&
				[self compare:other] == NSOrderedSame));
}
@end
