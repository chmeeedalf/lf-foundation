/*
 * Copyright (c) 2008-2012	Gold Project
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

#import <Foundation/NSMapTable.h>
#import <Foundation/NSException.h>

#include <stddef.h>
#include <stdlib.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <unordered_map>
typedef std::unordered_map<const void *, void *, Gold::Hash, Gold::Equal> intern_map;
#import "internal.h"

#define NSStrongObjects \
(NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPointerPersonality)

#define NSWeakObjects \
(NSPointerFunctionsZeroingWeakMemory|NSPointerFunctionsObjectPointerPersonality)

@interface NSConcreteMapTable	:	NSMapTable
{
	@package
	NSPointerFunctions *keyFuncs;
	NSPointerFunctions *valFuncs;
	Gold::Hash hasher;
	Gold::Equal equaler;
	intern_map table;
}
@end

@interface _MapTableEnumerator	:	NSEnumerator
{
	NSConcreteMapTable *table;
	intern_map::const_iterator iter;
	bool second;
}
- initWithTable:(NSConcreteMapTable *)table iterateValues:(bool)useValues;
@end

@implementation NSMapTable

+ allocWithZone:(NSZone *)zone
{
	if (self == [NSMapTable class])
		return NSAllocateObject([NSConcreteMapTable class], 0, zone);
	else
		return [super allocWithZone:zone];
}

+ mapTableWithKeyOptions:(NSPointerFunctionsOptions)keyOpts valueOptions:(NSPointerFunctionsOptions)valOpts
{
	return [[self alloc] initWithKeyOptions:keyOpts
		valueOptions:valOpts
		capacity:0];
}

+ mapTableWithStrongToStrongObjects
{
	return [[self alloc] initWithKeyOptions:NSStrongObjects
		valueOptions:NSStrongObjects capacity:0];
}

+ mapTableWithWeakToStrongObjects
{
	return [[self alloc] initWithKeyOptions:NSWeakObjects
		valueOptions:NSStrongObjects capacity:0];
}

+ mapTableWithStrongToWeakObjects
{
	return [[self alloc] initWithKeyOptions:NSStrongObjects
		valueOptions:NSWeakObjects capacity:0];
}

+ mapTableWithWeakToWeakObjects
{
	return [[self alloc] initWithKeyOptions:NSWeakObjects
		valueOptions:NSWeakObjects capacity:0];
}


- initWithKeyOptions:(NSPointerFunctionsOptions)keyOpts valueOptions:(NSPointerFunctionsOptions)valOpts capacity:(size_t)cap
{
	NSPointerFunctions *keyFuncs = [NSPointerFunctions
		pointerFunctionsWithOptions:keyOpts];
	NSPointerFunctions *valFuncs = [NSPointerFunctions
		pointerFunctionsWithOptions:valOpts];
	return [self initWithKeyPointerFunctions:keyFuncs
		valuePointerFunctions:valFuncs
		capacity:cap];
}

- initWithKeyPointerFunctions:(NSPointerFunctions *)keyFuncts valuePointerFunctions:(NSPointerFunctions *)valFuncts capacity:(size_t)cap
{
	// Nothing to do here, move along.
	return self;
}


- (id)objectForKey:(id)key
{
	return [self subclassResponsibility:_cmd];
}

- (const void *)pointerForKey:(const void *)key
{
	[self subclassResponsibility:_cmd];
	return NULL;
}

- (NSEnumerator *)keyEnumerator
{
	return [self subclassResponsibility:_cmd];
}

- (NSEnumerator *)objectEnumerator
{
	return [self subclassResponsibility:_cmd];
}

- (size_t)count
{
	[self subclassResponsibility:_cmd];
	return 0;
}


- (void)setObject:(id)obj forKey:(id)key
{
	[self subclassResponsibility:_cmd];
}

- (void) setPointer:(const void *)ptr forKey:(const void *)key
{
	[self subclassResponsibility:_cmd];
}

- (void)removeObjectForKey:(id)key
{
	[self subclassResponsibility:_cmd];
}

- (void)removeAllObjects
{
}

- (NSDictionary *)dictionaryRepresentation
{
	if ([self count] == 0)
		return [NSDictionary dictionary];

	NSEnumerator *keyEnum = [self keyEnumerator];
	NSEnumerator *valEnum = [self objectEnumerator];
	NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:[self count]];
	NSMutableArray *objs = [[NSMutableArray alloc] initWithCapacity:[self count]];
	NSDictionary *dictRep;

	for (id key in keyEnum)
	{
		[keys addObject:key];
	}
	for (id obj in valEnum)
	{
		[objs addObject:obj];
	}

	dictRep = [NSDictionary dictionaryWithObjects:objs forKeys:keys];
	return dictRep;
}


- (NSPointerFunctions *)keyPointerFunctions
{
	return [self subclassResponsibility:_cmd];
}

- (NSPointerFunctions *)valuePointerFunctions
{
	return [self subclassResponsibility:_cmd];
}

- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *)state
	objects:(__unsafe_unretained id *)stackBuf count:(unsigned long)len
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- copyWithZone:(NSZone *)zone
{
	NSMapTable *other = [[NSMapTable allocWithZone:zone]
		initWithKeyPointerFunctions:[self keyPointerFunctions]
		valuePointerFunctions:[self valuePointerFunctions]
		capacity:[self count]];

	for (id key in self)
	{
		const void *val = [self pointerForKey:(__bridge const void *)key];
		[other setPointer:val forKey:(__bridge void *)key];
	}

	return other;
}

@end

@implementation NSConcreteMapTable
- initWithKeyPointerFunctions:(NSPointerFunctions *)keyFuncts
valuePointerFunctions:(NSPointerFunctions *)valFuncts capacity:(size_t)cap
{
	keyFuncs = [keyFuncts copy];
	valFuncs = [valFuncts copy];
	
	[keyFuncs _fixupEmptyFunctions];
	[valFuncs _fixupEmptyFunctions];
	hasher = Gold::Hash(keyFuncs);
	equaler = Gold::Equal(keyFuncs);
	table = intern_map(10, hasher, equaler);

	return self;
}

- (id) objectForKey:(id)key
{
	intern_map::iterator iter = table.find((__bridge const void *)key);

	if (iter != table.end())
	{
		return (__bridge id)(iter->second);
	}
	return nil;
}

- (const void *) pointerForKey:(const void *)key
{
	intern_map::iterator iter = table.find(key);

	if (iter != table.end())
	{
		return iter->second;
	}
	return NULL;
}

- (void) setObject:(id)obj forKey:(id)key
{
	table[keyFuncs.acquireFunction((__bridge void *)key, keyFuncs.sizeFunction, false)] =
		valFuncs.acquireFunction((__bridge void *)obj, valFuncs.sizeFunction, false);
}

- (size_t) count
{
	return table.size();
}

- (void) setPointer:(const void *)ptr forKey:(const void *)key
{
	table[keyFuncs.acquireFunction(key, keyFuncs.sizeFunction, false)] =
		valFuncs.acquireFunction(ptr, valFuncs.sizeFunction, false);
}

- (void) removeObjectForKey:(id)key
{
	intern_map::iterator iter = table.find((__bridge const void *)key);

	if (iter != table.end())
	{
		keyFuncs.relinquishFunction(iter->first, keyFuncs.sizeFunction);
		valFuncs.relinquishFunction(iter->second, valFuncs.sizeFunction);
		table.erase(iter);
	}
}

- (NSPointerFunctions *) keyPointerFunctions
{
	return [keyFuncs copy];
}

- (NSPointerFunctions *) valuePointerFunctions
{
	return [valFuncs copy];
}

- (NSEnumerator *) keyEnumerator
{
	return [[_MapTableEnumerator alloc] initWithTable:self iterateValues:false];
}

- (NSEnumerator *) objectEnumerator
{
	return [[_MapTableEnumerator alloc] initWithTable:self iterateValues:true];
}

- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *)state
	objects:(__unsafe_unretained id [])stackBuf count:(unsigned long)len
{
	intern_map::const_iterator i;
	unsigned long j = 0;
	if (state->state == 0)
	{
		state->state = 1;
		i = table.begin();
	}
	else
	{
		i = table.find((const void *)state->extra[1]);
	}
	state->itemsPtr = stackBuf;
	for (; j < len && i != table.end(); j++, i++)
		state->itemsPtr[j] = (__bridge id)i->first;
	state->mutationsPtr = (unsigned long *)&table;
	/* LP model makes long and void* the same size, which makes this doable. */
	if (i != table.end())
		state->extra[1] = (unsigned long)(const void *)i->first;
	return j;
}

@end

@implementation _MapTableEnumerator

- initWithTable:(NSConcreteMapTable *)_table iterateValues:(bool)iterVals;
{
	table = _table;
	iter = table->table.begin();
	second = iterVals;
	return self;
}

- nextObject
{
	id obj;
	
	if (iter == table->table.end())
	{
		return nil;
	}

	if (second)
	{
		obj = (__bridge id)iter->second;
	}
	else
	{
		obj = (__bridge id)iter->first;
	}

	iter++;
	return obj;
}
@end
