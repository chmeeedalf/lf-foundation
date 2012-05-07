/* Copyright (c) 2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSIndexSet.h>
#import <limits.h>
#include <stdlib.h>

// FIX: assert range values on init/insert/remove

@implementation NSMutableIndexSet

-initWithIndexSet:(NSIndexSet *)other
{
   [super initWithIndexSet:other];
   _capacity=(_length==0)?1:_length;
   return self;
}

-initWithIndexesInRange:(NSRange)range
{
	[super initWithIndexesInRange:range];
	_capacity=(_length==0)?1:_length;
	return self;
}

-copyWithZone:(NSZone *)zone
{
	return [[NSIndexSet allocWithZone:zone] initWithIndexSet:self];
}

static unsigned positionOfRangeLessThanOrEqualToLocation(NSRange *ranges,unsigned length,unsigned location)
{
	int i=length;

	while(--i>=0)
		if(ranges[i].location<=location)
			return i;

	return NSNotFound;
}

static void removeRangeAtPosition(NSRange *ranges,unsigned length,unsigned position)
{
	unsigned i;

	for(i=position;i+1<length;i++)
		ranges[i]=ranges[i+1];
}

-(void)_insertRange:(NSRange)range position:(unsigned)position
{
	int i;

	_length++;
	if(_capacity<_length){
		_capacity*=2;
		_ranges=realloc(_ranges,sizeof(NSRange)*_capacity);
	}
	for(i=_length;--i>=position+1;)
		_ranges[i]=_ranges[i-1];

	_ranges[position]=range;
}

-(void)addIndexesInRange:(NSRange)range
{
	unsigned pos=positionOfRangeLessThanOrEqualToLocation(_ranges,_length,range.location);
	bool     insert=false;

	if(pos==NSNotFound){
		pos=0;
		insert=true;
	}
	else
	{
		if(NSMaxRange(range)<=NSMaxRange(_ranges[pos]))
			return; // present

		if(range.location<=NSMaxRange(_ranges[pos])) // intersects or adjacent
			_ranges[pos].length=NSMaxRange(range)-_ranges[pos].location;
		else
		{
			pos++;
			insert=true;
		}
	}

	if(insert)
		[self _insertRange:range position:pos];

	while(pos+1<_length){
		unsigned max=NSMaxRange(_ranges[pos]);
		unsigned nextMax;

		if(max<_ranges[pos+1].location)
			break;

		nextMax=NSMaxRange(_ranges[pos+1]);
		if(nextMax>max)
			_ranges[pos].length=nextMax-_ranges[pos].location;

		removeRangeAtPosition(_ranges,_length,pos+1);
		_length--;
	}
}

-(void)addIndexes:(NSIndexSet *)other
{
	int i;

	for(i=0;i<((NSMutableIndexSet *)other)->_length;i++)
		[self addIndexesInRange:((NSMutableIndexSet *)other)->_ranges[i]];
}

-(void)addIndex:(unsigned)index
{
	[self addIndexesInRange:NSMakeRange(index,1)];
}

-(void)removeAllIndexes
{
	_length=0;
}

-(void)removeIndexesInRange:(NSRange)range
{
	unsigned pos=positionOfRangeLessThanOrEqualToLocation(_ranges,_length,range.location);

	if(pos==NSNotFound)
		pos=0;

	while(range.length>0 && pos<_length){
		if(_ranges[pos].location>=NSMaxRange(range))
			break;

		if(NSMaxRange(_ranges[pos])==NSMaxRange(range)){

			if(_ranges[pos].location==range.location){
				removeRangeAtPosition(_ranges,_length,pos);
				_length--;
			}
			else
				_ranges[pos].length=range.location-_ranges[pos].location;

			break;
		}

		if(NSMaxRange(_ranges[pos])>NSMaxRange(range)){

			if(_ranges[pos].location==range.location){
				unsigned max=NSMaxRange(_ranges[pos]);

				_ranges[pos].location=NSMaxRange(range);
				_ranges[pos].length=max-_ranges[pos].location;
			}
			else
			{
				NSRange iceberg;

				iceberg.location=NSMaxRange(range);
				iceberg.length=NSMaxRange(_ranges[pos])-iceberg.location;

				_ranges[pos].length=range.location-_ranges[pos].location;

				[self _insertRange:iceberg position:pos+1];
			}
			break;
		}

		if(range.location>=NSMaxRange(_ranges[pos]))
			pos++;
		else
		{
			unsigned max=NSMaxRange(range);
			NSRange  temp=_ranges[pos];

			if(_ranges[pos].location>=range.location){
				removeRangeAtPosition(_ranges,_length,pos);
				_length--;
			}
			else
			{
				_ranges[pos].length=range.location-_ranges[pos].location;
				pos++;
			}    
			range.location=NSMaxRange(temp);
			range.length=max-range.location;
		}
	}
}

-(void)removeIndexes:(NSIndexSet *)other
{
	int i;

	for(i=0;i<((NSMutableIndexSet *)other)->_length;i++)
		[self removeIndexesInRange:((NSMutableIndexSet *)other)->_ranges[i]];
}

-(void)removeIndex:(unsigned)index
{
	[self removeIndexesInRange:NSMakeRange(index,1)];
}

-(void)shiftIndexesStartingAtIndex:(unsigned)index by:(int)delta
{
	[self notImplemented:_cmd];
}

@end
