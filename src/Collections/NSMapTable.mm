/*
 * Copyright (c) 2008-2012	Justin Hibbits
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

@interface _MapTableEnumerator	:	NSEnumerator
{
	NSMapTable *table;
	intern_map::const_iterator iter;
	bool second;
}
- (id) initWithTable:(NSMapTable *)table iterateValues:(bool)useValues;
@end

@implementation NSMapTable
{
	@package
	NSPointerFunctions *keyFuncs;
	NSPointerFunctions *valFuncs;
	Gold::Hash hasher;
	Gold::Equal equaler;
	intern_map table;
	NSUInteger keyOptions;
	NSUInteger valueOptions;
}

+ (id) mapTableWithKeyOptions:(NSPointerFunctionsOptions)keyOpts valueOptions:(NSPointerFunctionsOptions)valOpts
{
	return [[self alloc] initWithKeyOptions:keyOpts
		valueOptions:valOpts
		capacity:0];
}

+ (id) mapTableWithStrongToStrongObjects
{
	return [[self alloc] initWithKeyOptions:NSStrongObjects
		valueOptions:NSStrongObjects capacity:0];
}

+ (id) mapTableWithWeakToStrongObjects
{
	return [[self alloc] initWithKeyOptions:NSWeakObjects
		valueOptions:NSStrongObjects capacity:0];
}

+ (id) mapTableWithStrongToWeakObjects
{
	return [[self alloc] initWithKeyOptions:NSStrongObjects
		valueOptions:NSWeakObjects capacity:0];
}

+ (id) mapTableWithWeakToWeakObjects
{
	return [[self alloc] initWithKeyOptions:NSWeakObjects
		valueOptions:NSWeakObjects capacity:0];
}


- (id) initWithKeyOptions:(NSPointerFunctionsOptions)keyOpts valueOptions:(NSPointerFunctionsOptions)valOpts capacity:(size_t)cap
{
	NSPointerFunctions *keyFns = [NSPointerFunctions
		pointerFunctionsWithOptions:keyOpts];
	NSPointerFunctions *valFns = [NSPointerFunctions
		pointerFunctionsWithOptions:valOpts];
	keyOptions = keyOpts;
	valueOptions = valOpts;
	return [self initWithKeyPointerFunctions:keyFns
		valuePointerFunctions:valFns
		capacity:cap];
}

- (id) initWithKeyPointerFunctions:(NSPointerFunctions *)keyFuncts
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

- (NSEnumerator *) keyEnumerator
{
	return [[_MapTableEnumerator alloc] initWithTable:self iterateValues:false];
}

- (NSEnumerator *) objectEnumerator
{
	return [[_MapTableEnumerator alloc] initWithTable:self iterateValues:true];
}

- (size_t) count
{
	return table.size();
}


- (void) setObject:(id)obj forKey:(id)key
{
	table[keyFuncs.acquireFunction((__bridge void *)key, keyFuncs.sizeFunction, false)] =
		valFuncs.acquireFunction((__bridge void *)obj, valFuncs.sizeFunction, false);
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

- (void)removeAllObjects
{
	table.clear();
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


- (NSPointerFunctions *) keyPointerFunctions
{
	return [keyFuncs copy];
}

- (NSPointerFunctions *) valuePointerFunctions
{
	return [valFuncs copy];
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

- (id) copyWithZone:(NSZone *)zone
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

- (void) encodeWithCoder:(NSCoder *)coder
{
	NSAssert(keyOptions & NSPointerFunctionsObjectPersonality, @"NSMapTable encoding can only be used with object types");
	NSAssert(valueOptions & NSPointerFunctionsObjectPersonality, @"NSMapTable encoding can only be used with object types");
	if ([coder allowsKeyedCoding])
	{
		[coder encodeInteger:keyOptions forKey:@"NSMapTable.keyOpts"];
		[coder encodeInteger:valueOptions forKey:@"NSMapTable.valueOpts"];
		[coder encodeObject:[self dictionaryRepresentation]
			forKey:@"NSMapTable.Dictionary"];
	}
	else
	{
		[coder encodeValueOfObjCType:@encode(NSUInteger) at:&keyOptions];
		[coder encodeValueOfObjCType:@encode(NSUInteger) at:&valueOptions];
		[coder encodeObject:[self dictionaryRepresentation]];
	}
}

- (id) initWithCoder:(NSCoder *)coder
{
	NSDictionary *dictRep;
	NSUInteger keyOpts;
	NSUInteger valOpts;

	if ([coder allowsKeyedCoding])
	{
		keyOpts = [coder decodeIntegerForKey:@"NSMapTable.keyOpts"];
		valOpts = [coder decodeIntegerForKey:@"NSMapTable.valueOpts"];
		dictRep = [coder decodeObjectForKey:@"NSMapTable.Dictionary"];
	}
	else
	{
		[coder decodeValueOfObjCType:@encode(NSUInteger) at:&keyOpts];
		[coder decodeValueOfObjCType:@encode(NSUInteger) at:&valOpts];
		dictRep = [coder decodeObject];
	}
	self = [self initWithKeyOptions:keyOpts
		valueOptions:valOpts
		capacity:[dictRep count]];
	if (self == nil)
		return nil;

	[dictRep enumerateKeysAndObjectsUsingBlock:^(id key, id val, bool *stop){
		[self setObject:val forKey:key];
	}];
	return self;
}
@end

@implementation _MapTableEnumerator

- (id) initWithTable:(NSMapTable *)_table iterateValues:(bool)iterVals
{
	table = _table;
	iter = table->table.begin();
	second = iterVals;
	return self;
}

- (id) nextObject
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
