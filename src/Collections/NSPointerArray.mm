/* $Gold$	*/
/*
 * Copyright (c) 2009-2012	Gold Project
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

#import <Foundation/NSArray.h>
#import <Foundation/NSPointerArray.h>
#include <vector>
#include <algorithm>

@interface NSConcretePointerArray	:	NSPointerArray
{
	NSPointerFunctions *functions;
	std::vector<void *> array;
}
@end

@implementation NSPointerArray
+ allocWithZone:(NSZone *)zone
{
	if ([self class] == [NSPointerArray class])
		return NSAllocateObject([NSConcretePointerArray class], 0, zone);
	return [super alloc];
}

+ pointerArrayWithOptions:(NSPointerFunctionsOptions)options
{
	return [[self alloc] initWithOptions:options];
}

+ pointerArrayWithPointerFunctions:(NSPointerFunctions *)functions
{
	return [[self alloc] initWithPointerFunctions:functions];
}

+ pointerArrayWithStrongObjects
{
	return [[self alloc] initWithOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality)];
}

+ pointerArrayWithWeakObjects
{
	return [[self alloc] initWithOptions:(NSPointerFunctionsZeroingWeakMemory |
			NSPointerFunctionsObjectPersonality)];
}

- initWithOptions:(NSPointerFunctionsOptions)options
{
	NSPointerFunctions *functions = [[NSPointerFunctions alloc] initWithOptions:options];

	self = [self initWithPointerFunctions:functions];
	return self;
}

- initWithPointerFunctions:(NSPointerFunctions *)functions
{
	return self;
}

- (size_t) count
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (void) setCount:(size_t)count
{
	[self subclassResponsibility:_cmd];
}

- (NSArray *) allObjects
{
	size_t s = [self count];
	size_t i = 0;
	std::vector<id> buf;

	buf.reserve(s);

	for (; i < s; i++)
	{
		id x = (__bridge id)[self pointerAtIndex:i];
		if (x != nil)
			buf[i] = x;
	}
	
	NSArray *a = [NSArray arrayWithObjects:&buf[0] count:i];
	return a;
}

- (void *)pointerAtIndex:(size_t)index
{
	[self subclassResponsibility:_cmd];
	return NULL;
}

- (void) addPointer:(void *)ptr
{
	[self insertPointer:ptr atIndex:[self count]];
}

- (void) removePointerAtIndex:(size_t)index
{
	[self subclassResponsibility:_cmd];
}

- (void) insertPointer:(void *)pointer atIndex:(size_t)index
{
	[self subclassResponsibility:_cmd];
}

- (void) replacePointerAtIndex:(size_t)index withPointer:(void *)pointer
{
	[self subclassResponsibility:_cmd];
}

- (void) compact
{
	[self subclassResponsibility:_cmd];
}

- (NSPointerFunctions *)pointerFunctions
{
	return [self subclassResponsibility:_cmd];
}

@end

@implementation NSConcretePointerArray

- initWithPointerFunctions:(NSPointerFunctions *)funcs
{
	functions = [funcs copy];
	return self;
}

- (size_t) count
{
	return array.size();
}

- (void) setCount:(size_t)count
{
	if (count > array.size())
	{
		size_t i = array.size();
		array.resize(count);
		for (; i < count; i++)
			array[i] = NULL;
	}
	else
	{
		std::vector<void *>::iterator i = array.begin() + count;
		for (; i < array.end(); i++)
		{
			if (functions.relinquishFunction != NULL)
				functions.relinquishFunction(*i, functions.sizeFunction);
		}
		array.resize(count);
	}
}

- (void *)pointerAtIndex:(size_t)index
{
	return array[index];
}

- (NSPointerFunctions *)pointerFunctions
{
	return [functions copy];
}

- (void) removePointerAtIndex:(size_t)index
{
	void *pointer = array[index];
	array.erase(array.begin() + index);
	if (functions.relinquishFunction != NULL)
		functions.relinquishFunction(pointer, functions.sizeFunction);
}

- (void) insertPointer:(void *)pointer atIndex:(size_t)index
{
	if (functions.acquireFunction != NULL)
		pointer = functions.acquireFunction(pointer, functions.sizeFunction,
				true);
	array.insert(array.begin() + index, pointer);
}

- (void) replacePointerAtIndex:(size_t)index withPointer:(void *)pointer
{
	void *old = array[index];
	array[index] = pointer;
	if (functions.relinquishFunction != NULL)
		functions.relinquishFunction(old, functions.sizeFunction);
}

- (void) compact
{
	array.erase(std::remove(array.begin(), array.end(), (void *)0),
			array.end());
}

- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *)state
	objects:(__unsafe_unretained id [])stackBuf count:(unsigned long)len
{
	unsigned long idx = 0;

	if (state->state == 0)
	{
		state->state = 1;
	}
	else
	{
		idx = state->extra[1];
	}
	if (array.size() > 0)
		state->mutationsPtr = &state->extra[0];
	else
		state->mutationsPtr = 0;
	len = std::min(len, (unsigned long)array.size());
	state->extra[1] += len;
	for (unsigned long i = 0; i < len; ++i)
		stackBuf[len] = (__bridge id)array[len + idx];
	return len;
}
@end
