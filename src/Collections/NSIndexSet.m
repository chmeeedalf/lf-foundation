/* Copyright (c) 2007 Christopher J. W. Lloyd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#include <stddef.h>
#include <stdlib.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSIndexSet.h>
#import <Foundation/NSString.h>

@implementation NSIndexSet

+ indexSetWithIndexesInRange:(NSRange)range
{
	return [[[self allocWithZone:NULL] initWithIndexesInRange:range] autorelease];
}

+ indexSetWithIndex:(unsigned)index
{
	return [[[self allocWithZone:NULL] initWithIndex:index] autorelease];
}

+indexSet
{
	return [[[self allocWithZone:NULL] init] autorelease];
}

- initWithIndexSet:(NSIndexSet *)other
{
	int i;

	_length = other->_length;
	_ranges = malloc(sizeof(NSRange) * ((_length == 0) ? 1 : _length));
	for(i = 0; i < _length; i++)
	{
		_ranges[i] = other->_ranges[i];
	}

	return self;
}

- initWithIndexesInRange:(NSRange)range
{
	_length = (range.length == 0) ? 0 : 1;
	_ranges = malloc(sizeof(NSRange));
	_ranges[0] = range;
	return self;
}

- initWithIndex:(unsigned)index
{
	return [self initWithIndexesInRange:NSMakeRange(index,1)];
}

- init
{
	return [self initWithIndexesInRange:NSMakeRange(0,0)];
}

- (void)dealloc
{
	free(_ranges);
	[super dealloc];
}

- copyWithZone:(NSZone *)zone
{
	return [self retain];
}

- mutableCopyWithZone:(NSZone *)zone
{
	return [[NSIndexSet allocWithZone:zone] initWithIndexSet:self];
}

- (unsigned long)countOfIndexesInRange:(NSRange)range
{
	unsigned long count = 0;

	for (unsigned long i = 0; i < _length; i++)
	{
		count += NSIntersectionRange(range, _ranges[i]).length;
	}
	return count;
}

- (bool)isEqualToIndexSet:(NSIndexSet *)other
{
	int i;

	if(_length != other->_length)
	{
		return false;
	}

	for(i = 0; i < _length; i++)
	{
		if(!NSEqualRanges(_ranges[i],other->_ranges[i]))
		{
			return false;
		}
	}

	return true;
}

- (unsigned)count
{
	unsigned result = 0;
	int i;

	for(i = 0; i < _length; i++)
	{
		result += _ranges[i].length;
	}

	return result;
}

- (unsigned)firstIndex
{
	if(_length > 0)
	{
		return _ranges[0].location;
	}

	return NSNotFound;
}

- (unsigned)lastIndex
{
	if(_length > 0)
	{
		return NSMaxRange(_ranges[_length - 1]) - 1;
	}

	return NSNotFound;
}

// these two functions are the lynchpin of performance, should be improved for large sets
static unsigned positionOfRangeGreaterThanOrEqualToLocation(NSRange *ranges,unsigned length,unsigned location)
{
	unsigned i;

	for(i = 0; i < length; i++)
	{
		if(location < NSMaxRange(ranges[i]))
		{
			return i;
		}
	}

	return NSNotFound;
}

static unsigned positionOfRangeLessThanOrEqualToLocation(NSRange *ranges,unsigned length,unsigned location)
{
	int i = length;

	while(--i >= 0)
	{
		if(ranges[i].location <= location)
		{
			return i;
		}
	}

	return NSNotFound;
}

- (NSUInteger)getIndexes:(NSUInteger *)buffer maxCount:(NSUInteger)capacity inIndexRange:(NSRange *)rangePtr
{
	NSRange range;
	unsigned first;
	unsigned result = 0;
	unsigned location = 0;

	if(rangePtr != NULL)
	{
		range = *rangePtr;
	}
	else
	{
		range.location = _ranges[0].location;
		range.length = NSMaxRange(_ranges[_length - 1]) - range.location;
	}

	first = positionOfRangeGreaterThanOrEqualToLocation(_ranges,_length,range.location);

	for(; first < _length && result < capacity; first++)
	{
		unsigned max = NSMaxRange(_ranges[first]);

		for(location = _ranges[first].location; location < max && result < capacity; location++)
		{
			buffer[result++] = location;
		}
	}

	if(rangePtr != NULL)
	{
		unsigned max = NSMaxRange(*rangePtr);

		rangePtr->location = location;
		rangePtr->length = max - rangePtr->location;
	}

	return result;
}

- (bool)containsIndexesInRange:(NSRange)range
{
	int first = positionOfRangeLessThanOrEqualToLocation(_ranges,_length,range.location);

	if(first == NSNotFound)
	{
		return false;
	}

	for(; first < _length && _ranges[first].location < NSMaxRange(range); first++)
	{
		if(NSMaxRange(range) <= NSMaxRange(_ranges[first]))
		{
			return true;
		}
	}

	return false;
}

- (bool)containsIndexes:(NSIndexSet *)other
{
	int i;

	for(i = 0; i < other->_length; i++)
	{
		if(![self containsIndexesInRange:other->_ranges[i]])
		{
			return false;
		}
	}

	return true;
}

- (bool)containsIndex:(unsigned)index
{
	return [self containsIndexesInRange:NSMakeRange(index,1)];
}

- (unsigned)indexGreaterThanIndex:(unsigned)index
{
	unsigned first = positionOfRangeGreaterThanOrEqualToLocation(_ranges,_length,index);

	if(first == NSNotFound)
	{
		return NSNotFound;
	}

	if(index < _ranges[first].location)
	{
		return _ranges[first].location;
	}

	if(index + 1 < NSMaxRange(_ranges[first]))
	{
		return index + 1;
	}

	first++;
	if(first < _length)
	{
		return _ranges[first].location;
	}

	return NSNotFound;
}

- (unsigned)indexGreaterThanOrEqualToIndex:(unsigned)index
{
	unsigned first = positionOfRangeGreaterThanOrEqualToLocation(_ranges,_length,index);

	if(first == NSNotFound)
	{
		return NSNotFound;
	}

	if(index < _ranges[first].location)
	{
		return _ranges[first].location;
	}

	if(index < NSMaxRange(_ranges[first]))
	{
		return index;
	}

	first++;
	if(first < _length)
	{
		return _ranges[first].location;
	}

	return NSNotFound;
}

- (unsigned)indexLessThanIndex:(unsigned)index
{
	int first = positionOfRangeLessThanOrEqualToLocation(_ranges,_length,index);

	if(index == 0)
	{
		return NSNotFound;
	}

	if(first == NSNotFound)
	{
		return NSNotFound;
	}

	if(NSLocationInRange(index - 1,_ranges[first]))
	{
		return index - 1;
	}

	if(index == _ranges[first].location)
	{
		first--;
	}

	if(first >= 0)
	{
		return NSMaxRange(_ranges[first]) - 1;
	}

	return NSNotFound;
}

- (unsigned)indexLessThanOrEqualToIndex:(unsigned)index
{
	int first = positionOfRangeLessThanOrEqualToLocation(_ranges,_length,index);

	if(first == NSNotFound)
	{
		return NSNotFound;
	}

	if(NSLocationInRange(index,_ranges[first]))
	{
		return index;
	}

	return NSMaxRange(_ranges[first]) - 1;
}

- (bool)intersectsIndexesInRange:(NSRange)range
{
	unsigned first = positionOfRangeGreaterThanOrEqualToLocation(_ranges,_length,range.location);

	if(first == NSNotFound)
	{
		return false;
	}

	return (_ranges[first].location < NSMaxRange(range)) ? true : false;
}

- (NSString *)description
{
	NSMutableString *result = [NSMutableString stringWithCapacity:0];
	int i;

	[result appendString:[super description]];
	[result appendString:[NSString stringWithFormat:@"[number of indexes: %d (in %d ranges), indexes: (",[self count],_length]];
	for(i = 0; i < _length; i++)
	{
		[result appendString:[NSString stringWithFormat:@"%d-%d%@",_ranges[i].location,NSMaxRange(_ranges[i]) - 1,(i + 1 < _length) ? @" ":@""]];
	}
	[result appendString:@")]"];
	return result;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	[coder encodeValueOfObjCType:@encode(unsigned) at:&_length];
	[coder encodeArrayOfObjCType:@encode(NSRange) count:_length at:_ranges];
}

- (id) initWithCoder:(NSCoder *)coder
{
	[coder decodeValueOfObjCType:@encode(unsigned) at:&_length];
	_ranges = malloc(_length * sizeof(NSRange));
	[coder decodeArrayOfObjCType:@encode(NSRange) count:_length at:_ranges];

	return self;
}
@end
