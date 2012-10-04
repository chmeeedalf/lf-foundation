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

#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

#import "internal.h"
#import "NSCoreDictionary.h"

/*
 * NSCoreDictionary class
 */

@implementation NSCoreDictionary

/* Allocating and Initializing */

- (id)init
{
	return [self initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)cap
{
	table = _map_table(cap);
	return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
	self = [self initWithCapacity:[dictionary count]];
	for (id key in dictionary)
	{
		[self setObject:[dictionary objectForKey:key] forKey:key];
	}
	return self;
}

/* Accessing keys and values */

- (NSEnumerator *)keyEnumerator
{
	return [[_CoreDictionaryEnumerator alloc] initWithDictionary:self];
}

- (id)objectForKey:(id)aKey
{
	_map_table::iterator i = table.find(aKey);
	if (i != table.end())
		return i->second;
	return nil;
}

- (NSUInteger)count
{
	return table.size();
}

/* Private */

- (_map_table *)__dictObject
{
	return &table;
}

/* Allocating and Initializing */

- (id)initWithObjects:(id*)objects
	forKeys:(id*)keys
	count:(NSUInteger)count
{
	self = [self initWithCapacity:count];

	if (count == 0)
	{
		return self;
	}

	while(count--)
	{
		id key;
		if (!keys[count] || !objects[count])
		{
			@throw([NSInvalidArgumentException
					exceptionWithReason:@"Nil object to be added in dictionary"
					userInfo:nil]);
		}
		key = [keys[count] copy];
		table[key] = objects[count];
	}
	return self;
}

/* Modifying dictionary */

- (void)setObject:(id)anObject forKey:(id)aKey
{
	if (!anObject || !aKey)
	{
		@throw([NSInvalidArgumentException
				exceptionWithReason:@"Nil object to be added in dictionary"
				userInfo:nil]);
	}
	
	_map_table::iterator i = table.find(aKey);
	if (i == table.end())
	{
		aKey = [aKey copy];
	}
	table[aKey] = anObject;
}

- (void)removeObjectForKey:(id)aKey
{
	table.erase(aKey);
}

- (void)removeAllObjects
{
	table.clear();
}

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state
	objects:(__unsafe_unretained id [])stackBuf count:(NSUInteger)len
{
	_map_table::const_iterator i = table.cbegin();
	NSUInteger j = 0;
	if (state->state == 0)
	{
		state->state = 1;
	}
	else
	{
		advance(i, state->extra[1]);
	}
	state->itemsPtr = stackBuf;
	for (; j < len && i != table.end(); j++, i++)
		state->itemsPtr[j] = i->first;
	state->mutationsPtr = (unsigned long *)&table;
	/* LP model makes long and void* the same size, which makes this doable. */
	if (i != table.end())
		state->extra[1] = std::distance(table.cbegin(), i);
	return j;
}

@end /* ConcreteMutableDictionary */

/*
 * NSCoreDictionary NSEnumerator classes
 */

@implementation _CoreDictionaryEnumerator

- (id) initWithDictionary:(NSCoreDictionary*)_dict
{
	d = _dict;
	table = [d __dictObject];
	i = table->begin();
	return self;
}

- (id) nextObject
{
	id obj;

	if (i == table->end())
		return nil;

	obj = i->first;
	i++;

	return obj;
}

@end
