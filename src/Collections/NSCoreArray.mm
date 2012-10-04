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

#include <stddef.h>
#include <stdlib.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSValue.h>

#import "NSCoreArray.h"

/*
 * NSCoreArray class
 */

@implementation NSCoreArray

- (id)init
{
	return self;
}

- (id)initWithCapacity:(NSUInteger)aNumItems
{
	items.reserve(aNumItems);
	return self;
}

- (id)initWithObjects:(id *)objects count:(NSUInteger)count
{
	NSUInteger i;

	items.assign(objects, objects + count);
	for (i = 0; i < count; i++)
	{
		if (objects[i] == nil)
		{
			@throw([NSInvalidArgumentException
					exceptionWithReason: @"Nil object to be added in array"
					userInfo:nil]);
		}
	}
	return self;
}

- (id)initWithArray:(NSArray *)anotherArray
{
	NSUInteger i, count = [anotherArray count];

	items.reserve(count);
	for (i = 0; i < count; i++)
	{
		items.push_back([anotherArray objectAtIndex:i]);
	}
	return self;
}

- (NSUInteger)count
{
	return items.size();
}

- (id) objectAtIndex:(NSUInteger)index
{
	if (index >= items.size())
		@throw([NSRangeException exceptionWithReason:@"Index out of bounds in -[NSCoreArray objectAtIndex:]" userInfo:nil]);
	return items[index];
}

/* Altering the NSArray */

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
	if (!anObject)
	{
		@throw([NSInvalidArgumentException
				exceptionWithReason:@"Nil object to be added in array" userInfo:nil]);
	}
	if (index > items.size())
	{
		@throw([NSRangeException
				exceptionWithReason:@"-[NSCoreArray insertObject:atIndex:]"
				userInfo:nil]);
	}
	items.insert(items.begin() + index, anObject);
}

- (void) addObject:(id)object
{
	items.push_back(object);
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
	if (!anObject)
	{
		@throw([NSInvalidArgumentException
				exceptionWithReason:@"Nil object to be added in array" userInfo:nil]);
	}
	if (index >= items.size())
	{
		@throw([NSRangeException
				exceptionWithReason:@"-[NSCoreArray replaceObjectAtIndex:withObject:]"
				userInfo:nil]);
	}
	items[index] = anObject;
}

- (void)removeObjectsFrom:(NSUInteger)index
	count:(NSUInteger)count
{
	items.erase(items.begin() + index, items.begin() + index + count);
}

- (void)removeObjectsInRange:(NSRange)aRange
{
	[self removeObjectsFrom:aRange.location count:aRange.length];
}

- (void)removeAllObjects
{
	[self removeObjectsFrom:0 count:items.size()];
}

- (void)removeLastObject
{
	if (items.size() > 0)
	{
		items.pop_back();
	}
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
	items.erase(items.begin() + index);
}

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state
	objects:(__unsafe_unretained id [])stackBuf count:(NSUInteger)len
{
	NSUInteger idx = 0;

	if (state->state == 0)
	{
		state->state = 1;
	}
	else
	{
		idx = state->extra[1];
	}
	if (items.size() > 0)
		state->mutationsPtr = &state->extra[0];
	else
		state->mutationsPtr = 0;
	len = std::min(len, (NSUInteger)items.size());
	std::copy(&items[idx], &items[idx + len], stackBuf);
	state->extra[1] += len;
	return len;
}

@end
