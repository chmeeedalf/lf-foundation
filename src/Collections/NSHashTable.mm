/*
 * Copyright (c) 2009	Gold Project
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

#import <Foundation/NSHashTable.h>

#include <stddef.h>
#include <stdlib.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#if __GNUC_MINOR__ == 2
#include <tr1/unordered_set>
typedef std::tr1::unordered_set<void *,Gold::Hash,Gold::Equal> intern_set;
#else
#include <unordered_set>
typedef std::unordered_set<void *,Gold::Hash,Gold::Equal> intern_set;
#endif
#include <algorithm>
#import "internal.h"

@interface NSConcreteHashTable	:	NSHashTable
{
@public
	NSPointerFunctions *callbacks;
	Gold::Hash hasher;
	Gold::Equal equaler;
	intern_set table;
}
@end

@interface _ConcreteHashEnumerator	:	NSEnumerator
{
	intern_set *table;
	intern_set::iterator i;
}

- initWithHashTable:(NSConcreteHashTable *)tbl;
@end

@implementation NSHashTable
static Class HashTableClass;
static Class ConcreteHashTableClass;

+ (void) initialize
{
	HashTableClass = [NSHashTable class];
	ConcreteHashTableClass = [NSConcreteHashTable class];
}

+ allocWithZone:(NSZone *)zone
{
	if (self == HashTableClass)
		return NSAllocateObject(ConcreteHashTableClass, 0, zone);
	return [super allocWithZone:zone];
}

+ hashTableWithOptions:(NSPointerFunctionsOptions)options
{
	return [[[self alloc] initWithOptions:options capacity:0] autorelease];
}

+ hashTableWithWeakObjects
{
	return [[[self alloc] initWithOptions:(NSPointerFunctionsObjectPersonality |
			NSPointerFunctionsZeroingWeakMemory) capacity:0] autorelease];
}

- initWithOptions:(NSPointerFunctionsOptions)options capacity:(size_t)cap
{
	NSPointerFunctions *pf = [[NSPointerFunctions alloc] initWithOptions:options];
	self = [self initWithPointerFunctions:pf capacity:cap];
	[pf release];
	return self;
}

- initWithPointerFunctions:(NSPointerFunctions *)pfuncts capacity:(size_t)cap
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (NSArray *)allObjects
{
	size_t s = [self count];
	NSArray *a;
	id *objs = new id[s];
	size_t i = 0;

	for (id obj in self)
	{
		objs[i++] = obj;
	}
	a = [NSArray arrayWithObjects:objs count:i];
	return a;
}

- (id)anyObject
{
	return [[self objectEnumerator] nextObject];
}

- (bool)containsObject:(id)obj
{
	return ([self member:obj] != NULL);
}

- (size_t)count
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (id)member:(id)obj
{
	return [self subclassResponsibility:_cmd];
}

- (NSEnumerator *)objectEnumerator
{
	return [self subclassResponsibility:_cmd];
}

- (NSSet *)setRepresentation
{
	return [NSSet setWithArray:[self allObjects]];
}


- (void)addObject:(id)obj
{
	[self subclassResponsibility:_cmd];
}

- (void)removeAllObjects
{
}

- (void)removeObject:(id)obj
{
	[self subclassResponsibility:_cmd];
}


- (bool)intersectsHashTable:(NSHashTable *)other
{
	for (id obj in self)
	{
		if ([other containsObject:obj])
			return true;
	}
	return false;
}

- (bool)isEqualToHashTable:(NSHashTable *)other
{
	if ([other count] != [self count])
		return false;

	for (id obj in self)
	{
		if (![other containsObject:obj])
			return false;
	}
	return true;
}

- (bool)isSubsetOfHashTable:(NSHashTable *)other
{
	if ([self count] > [other count])
		return false;

	for (id obj in self)
	{
		if (![other containsObject:obj])
			return false;
	}
	return true;
}

- (void)intersetHashTable:(NSHashTable *)other
{
	NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:[self count]];
	for (id obj in self)
	{
		if (![other containsObject:obj])
		{
			[arr addObject:obj];
		}
	}
	for (id obj in arr)
	{
		[self removeObject:obj];
	}
	[arr release];
}

- (void)minusHashTable:(NSHashTable *)other
{
	for (id obj in other)
	{
		[self removeObject:obj];
	}
}

- (void)unionHashTable:(NSHashTable *)other
{
	for (id obj in other)
	{
		[self addObject:obj];
	}
}

- (NSPointerFunctions *)pointerFunctions
{
	return [self subclassResponsibility:_cmd];
}

- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackBuf count:(unsigned long)len
{
	[self subclassResponsibility:_cmd];
	return 0;
}

@end

@implementation NSConcreteHashTable

- initWithPointerFunctions:(NSPointerFunctions *)pfuncts capacity:(size_t)cap
{
	callbacks=[pfuncts copy];
	[callbacks _fixupEmptyFunctions];
	hasher = Gold::Hash(callbacks);
	equaler = Gold::Equal(callbacks);
	table = intern_set(10, hasher, equaler);

	return self;
}

- (void) dealloc
{
	std::for_each(table.begin(), table.end(),
			std::bind2nd(std::ptr_fun(callbacks.relinquishFunction),callbacks.sizeFunction));
	[super dealloc];
}

- (void) addObject:(id)obj
{
	callbacks.acquireFunction(obj, callbacks.sizeFunction, false);
	table.insert(reinterpret_cast<void *>(obj));
}

- (void) removeAllObjects
{
	std::for_each(table.begin(), table.end(),
			std::bind2nd(std::ptr_fun(callbacks.relinquishFunction),callbacks.sizeFunction));
	table.clear();
}

- (size_t) count
{
	return table.size();
}

- (id) member:(id)obj
{
	intern_set::iterator i = table.find(reinterpret_cast<void *>(obj));
	if (i != table.end())
		return reinterpret_cast<id>(*i);
	return NULL;
}

- (void) removeObject:(id)obj
{
	intern_set::iterator i = table.find(reinterpret_cast<void *>(obj));
	if (i != table.end())
	{
		callbacks.relinquishFunction(*i, callbacks.sizeFunction);
		table.erase(i);
	}
}

- (NSString *) description
{
	NSMutableString *string=[NSMutableString new];
	NSString *fmt=@"%p";

	for (intern_set::iterator i = table.begin(); i != table.end();
			i++)
	{
		NSString *desc;
		if((desc=callbacks.descriptionFunction(*i))!=nil)
			[string appendString:desc];
		else
			[string appendString:[NSString stringWithFormat:fmt,*i]];
	}

	return [string autorelease];
}

- objectEnumerator
{
	return [[[_ConcreteHashEnumerator alloc] initWithHashTable:self]
		autorelease];
}

- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackBuf count:(unsigned long)len
{
	intern_set::const_iterator i;
	unsigned long j = 0;
	if (state->state == 0)
	{
		state->state = 1;
		i = table.begin();
	}
	else
	{
		i = table.find((id)state->extra[1]);
	}
	state->itemsPtr = stackBuf;
	for (; j < len && i != table.end(); j++, i++)
	{
		state->itemsPtr[j] = (id)*i;
	}
	state->mutationsPtr = (unsigned long *)&table;
	/* LP model makes long and void* the same size, which makes this doable. */
	if (i != table.end())
		state->extra[1] = (unsigned long)(id)*i;
	return j;
}

@end

@implementation _ConcreteHashEnumerator

- initWithHashTable:(NSConcreteHashTable *)tbl
{
	table = &tbl->table;
	i = table->begin();
	return self;
}

- nextObject
{
	if (i == table->end())
		return nil;
	return reinterpret_cast<id>(*(i++));
}

@end
