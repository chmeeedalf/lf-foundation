/*
 * Copyright (c) 2010	Gold Project
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

#import <Foundation/NSIndexPath.h>
#import <Foundation/NSByteOrder.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#include <algorithm>

// TODO: Uniquify IndexPaths and cache them in a hash table.
@implementation NSIndexPath

+ (id) indexPathWithIndex:(NSUInteger)index
{
	return [[[self alloc] initWithIndex:index] autorelease];
}

+ (id) indexPathWithIndexes:(NSUInteger *)indexes length:(size_t)length
{
	return [[[self alloc] initWithIndexes:indexes length:length] autorelease];
}

- (id) initWithIndex:(NSUInteger)index
{
	return [self initWithIndexes:&index length:1];
}

- (id) initWithIndexes:(NSUInteger *)indexes length:(size_t)len
{
	_indexes = new NSUInteger[len];
	_length = len;
	
	std::copy(indexes, indexes + len, _indexes);
	return self;
}

- (void) dealloc
{
	delete[] _indexes;
	[super dealloc];
}

- (void) getIndexes:(NSUInteger *)indexes
{
	std::copy(_indexes, _indexes + _length, indexes);
}

- (NSUInteger) indexAtPosition:(NSUInteger)pos
{
	if (pos > _length)
		return NSNotFound;
	return _indexes[pos];
}

- (NSIndexPath *) indexPathByAddingIndex:(NSUInteger)idx
{
	NSUInteger *newIndexes = new NSUInteger[_length + 1];
	std::copy(_indexes, _indexes + _length, newIndexes);
	newIndexes[_length] = idx;

	NSIndexPath *newPath = [NSIndexPath indexPathWithIndexes:newIndexes
		length:_length+1];
	delete[] newIndexes;

	return newPath;
}

- (NSIndexPath *) indexPathByRemovingLastIndex
{
	NSAssert(_length > 1, @"Cannot remove the only path index.");
	return [NSIndexPath indexPathWithIndexes:_indexes length:_length - 1];
}

- (size_t) length
{
	return _length;
}

- (NSComparisonResult) compare:(NSIndexPath *)other
{
	size_t end = (_length > other->_length) ? _length : other->_length;
	for (size_t i = 0; i < end; i++)
	{
		if (i >= _length)
			return NSOrderedAscending;
		if (i >= other->_length)
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
	return [self retain];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		[coder encodeInt64:_length forKey:@"IndexPathLength"];
		NSUInteger *buf = new NSUInteger[_length];
		for (size_t i = 0; i < _length; i++)
		{
			buf[i] = NSSwapHostLongLongToBig(_indexes[i]);
		}
		NSData *d = [[NSData alloc] initWithBytes:buf length:_length *
			sizeof(NSUInteger)];
		[coder encodeObject:d forKey:@"IndexPathData"];
		[d release];
		delete[] buf;
	}
	else
	{
		[coder encodeValueOfObjCType:@encode(size_t) at:&_length];
		[coder encodeArrayOfObjCType:@encode(NSUInteger) count:_length
			at:_indexes];
	}
}

- (id) initWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		_length = [coder decodeInt64ForKey:@"IndexPathLength"];
		NSUInteger *buf = new NSUInteger[_length];
		NSUInteger *src;
		NSData *d = [coder decodeObjectForKey:@"IndexPathData"];
		src = (NSUInteger *)[d bytes];
		for (size_t i = 0; i < _length; i++)
		{
			buf[i] = NSSwapBigLongLongToHost(src[i]);
		}
		_indexes = buf;
	}
	else
	{
		[coder decodeValueOfObjCType:@encode(size_t) at:&_length];
		[coder decodeArrayOfObjCType:@encode(NSUInteger) count:_length
			at:_indexes];
	}
	return self;
}

- (bool) isEqual:(id)other
{
	return ((self == other) || ([other isKindOfClass:[self class]] &&
				[self compare:other] == NSOrderedSame));
}
@end
