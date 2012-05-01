/*
 * Copyright (c) 2004-2012	Justin Hibbits
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

#import "internal.h"
#import "NSCoreSet.h"
#import <Foundation/NSArray.h>
#include <unordered_set>
typedef std::unordered_set<id> intern_set;

/*
 * NSCoreSet
 */

@interface NSCoreSet ()
- (intern_set *)__setObject;
@end

@implementation NSCoreSet
{
	intern_set set;
}

- (id)init
{
	return [self initWithCapacity:0];
}

- (id)initWithCapacity:(unsigned)_capacity
{
	set = intern_set(_capacity);
	return self;
}

- (id)initWithObjects:(const id[])objects count:(unsigned int)count
{
	unsigned i;

	self = [self initWithCapacity:count];
	for (i = 0; i < count; i++)
	{
		[self addObject:objects[i]];
	}
	return self;
}

/* Copying */

- (id)copyWithZone:(NSZone*)_zone
{
	return [[NSCoreSet allocWithZone:_zone]
			initWithSet:self copyItems:true];
}

/* Accessing keys and values */

- (NSUInteger)count
{
	return set.size();
}

- (id)member:(id)anObject
{
	intern_set::iterator i = set.find(anObject);
	if (i != set.end())
		return *i;
	return nil;
}

/* Entries */

- (NSEnumerator *)objectEnumerator
{
	return [[_ConcreteSetEnumerator alloc] initWithSet:self];
}

/* Add and remove entries */

- (void)addObject:(id)object
{
	set.insert(object);
}

- (void)removeObject:(id)object
{
	set.erase(object);
}

- (void)removeAllObjects
{
	set.clear();
}

- (intern_set *)__setObject
{
	return &set;
}

- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *)state
	objects:(__unsafe_unretained id [])stackBuf count:(unsigned long)len
{
	intern_set::const_iterator i;
	unsigned long j = 0;
	i = set.cbegin();
	if (state->state == 0)
	{
		state->state = 1;
	}
	else
	{
		advance(i, state->extra[1]);
	}
	state->itemsPtr = stackBuf;
	for (; j < len && i != set.end(); j++, i++)
		state->itemsPtr[j] = *i;
	state->mutationsPtr = (unsigned long *)&set;
	/* LP model makes long and void* the same size, which makes this doable. */
	if (i != set.end())
		state->extra[1] = std::distance(set.cbegin(), i);
	return j;
}
@end /* NSCoreSet */

/*
 * _ConcreteSetEnumerator
 */

@implementation _ConcreteSetEnumerator
{
	NSCoreSet *set;
	intern_set *table;
	intern_set::iterator i;
}

- (id) initWithSet:(NSCoreSet*)_set
{
	set = _set;
	table = [_set __setObject];
	i = table->begin();

	return self;
}

- (id) nextObject
{
	id obj;
	if (i == table->end())
		return nil;

	obj = *i;

	i++;
	return obj;
}

@end /* _ConcreteSetEnumerator */
