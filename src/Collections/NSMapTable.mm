/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>

#import <Foundation/NSMapTable.h>
#import <Foundation/NSException.h>

#include <stddef.h>
#include <stdlib.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#if __GNUC_MINOR__ == 2
#import <tr1/unordered_map>
typedef std::tr1::unordered_map<const void *, void *, Gold::Hash, Gold::Equal> intern_map;
#else
#import <unordered_map>
typedef std::unordered_map<const void *, void *, Gold::Hash, Gold::Equal> intern_map;
#endif
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
	return [[[self alloc] initWithKeyOptions:keyOpts
		valueOptions:valOpts
		capacity:0]
		autorelease];
}

+ mapTableWithStrongToStrongObjects
{
	return [[[self alloc] initWithKeyOptions:NSStrongObjects
		valueOptions:NSStrongObjects capacity:0]
		autorelease];
}

+ mapTableWithWeakToStrongObjects
{
	return [[[self alloc] initWithKeyOptions:NSWeakObjects
		valueOptions:NSStrongObjects capacity:0]
		autorelease];
}

+ mapTableWithStrongToWeakObjects
{
	return [[[self alloc] initWithKeyOptions:NSStrongObjects
		valueOptions:NSWeakObjects capacity:0]
		autorelease];
}

+ mapTableWithWeakToWeakObjects
{
	return [[[self alloc] initWithKeyOptions:NSWeakObjects
		valueOptions:NSWeakObjects capacity:0]
		autorelease];
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
	return [self subclassResponsibility:_cmd];
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
	[objs release];
	[keys release];
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

- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackBuf count:(unsigned long)len
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
		const void *val = [self pointerForKey:key];
		[other setPointer:val forKey:key];
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
	intern_map::iterator iter = table.find(key);

	if (iter != table.end())
	{
		return reinterpret_cast<id>(iter->second);
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
	table[keyFuncs.acquireFunction(key, keyFuncs.sizeFunction, false)] =
		valFuncs.acquireFunction(obj, valFuncs.sizeFunction, false);
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
	intern_map::iterator iter = table.find(key);

	if (iter != table.end())
	{
		keyFuncs.relinquishFunction(iter->first, keyFuncs.sizeFunction);
		valFuncs.relinquishFunction(iter->second, valFuncs.sizeFunction);
		table.erase(iter);
	}
}

- (NSPointerFunctions *) keyPointerFunctions
{
	return [[keyFuncs copy] autorelease];
}

- (NSPointerFunctions *) valuePointerFunctions
{
	return [[valFuncs copy] autorelease];
}

- (NSEnumerator *) keyEnumerator
{
	return [[[_MapTableEnumerator alloc] initWithTable:self iterateValues:false] autorelease];
}

- (NSEnumerator *) objectEnumerator
{
	return [[[_MapTableEnumerator alloc] initWithTable:self iterateValues:true] autorelease];
}

- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackBuf count:(unsigned long)len
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
		i = table.find((id)state->extra[1]);
	}
	state->itemsPtr = stackBuf;
	for (; j < len && i != table.end(); j++, i++)
		state->itemsPtr[j] = (id)i->first;
	state->mutationsPtr = (unsigned long *)&table;
	/* LP model makes long and void* the same size, which makes this doable. */
	if (i != table.end())
		state->extra[1] = (unsigned long)(id)i->first;
	return j;
}

@end

@implementation _MapTableEnumerator

- initWithTable:(NSConcreteMapTable *)_table iterateValues:(bool)iterVals;
{
	table = [_table retain];
	iter = table->table.begin();
	second = iterVals;
	return self;
}

- (void) dealloc
{
	[table release];
	[super dealloc];
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
		obj = (id)iter->second;
	}
	else
	{
		obj = (id)iter->first;
	}

	iter++;
	return obj;
}
@end
