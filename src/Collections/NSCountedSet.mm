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

#import <Foundation/NSArray.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSEnumerator.h>
#import "internal.h"
#include <unordered_set>
typedef std::unordered_multiset<id> _map_table;

@interface _CountedSetEnumerator :	NSEnumerator
{
	_map_table::iterator i;
	_map_table *t;
}
- (id) initWithTable:(_map_table *)t;
@end

@implementation NSCountedSet
{
	_map_table table;
}

-(id)initWithCapacity:(unsigned int)numItems
{
	if ((self = [super initWithCapacity:numItems]) == nil)
		return nil;

	return self;
}

-(id)initWithObjects:(const id[])objects count:(unsigned int)count
{
	if ((self = [self initWithCapacity:count]) == nil)
		return nil;

	for (unsigned int i = 0; i < count; i++)
		table.insert(objects[i]);

	return self;
}

- (id) initWithArray:(NSArray *)array
{
	for (id item in array)
	{
		[self addObject:item];
	}
	return self;
}

- (id) initWithSet:(NSSet *)set
{
	bool countedSet = [set isKindOfClass:[self class]];
	void (*adder)(id, SEL, id) = (void (*)(id, SEL, id))[self methodForSelector:@selector(addObject:)];
	for (id item in set)
	{
		adder(self, @selector(addObject:), item);
		[self addObject:item];
		if (countedSet)
		{
			for (int i = [(NSCountedSet *)set countForObject:item] - 1; i > 0; i--)
			{
				adder(self, @selector(addObject:), item);
			}
		}
	}
	return self;
}

-(NSUInteger)count
{
	return table.size();
}

-(id)member:(id)anObject
{
	_map_table::iterator i = table.find(anObject);
	if (i != table.end())
		return *i;
	return nil;
}

-(NSEnumerator *)objectEnumerator
{
	return [[_CountedSetEnumerator alloc] initWithTable:&table];
}

-(bool)isEqualToSet:(NSSet *)otherSet
{
	if (otherSet == self)
		return true;

	if ([otherSet count] != [self count])
		return false;

	if ([otherSet isKindOfClass:[NSCountedSet class]])
	{
		_map_table::iterator i = table.begin();
		for (; i != table.end(); i++)
		{
			if ([(NSCountedSet *)otherSet countForObject:*i] != table.count(*i))
				return false;
		}
		return true;
	}
	return false;
}

-(void)addObject:(id)object
{
	table.insert(object);
}

-(void)removeObject:(id)object
{
	_map_table::iterator i = table.find(object);
	if (i != table.end())
		table.erase(i);
}

- (size_t) countForObject:(id)object
{
	return table.count(object);
}

@end

@implementation _CountedSetEnumerator
- (id) initWithTable:(_map_table *)table
{
	t = table;
	i = t->begin();
	return self;
}

- (id) nextObject
{
	if (i == t->end())
		return nil;
	return *(i++);
}
@end
