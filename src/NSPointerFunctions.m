/* $Gold$	*/
/*
 * All rights reserved.
 * Copyright (c) 2009	Justin Hibbits
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
#import <Foundation/NSPointerFunctions.h>
#import <Foundation/NSString.h>
#include <stdlib.h>
#include <string.h>

static size_t objectSize(const void *obj)
{
	return class_getInstanceSize(object_getClass((__bridge id)obj));
}

static void *objectAcquire(const void *item, NSSizeFunction sizeFunc, bool shouldCopy)
{
	if (shouldCopy)
		return (__bridge void *)[(__bridge id)item copy];
	else
		return (__bridge_retained void *)(__bridge id)item;
}

static void objectRelinquish(const void *obj, NSSizeFunction sizeFunc)
{
	id relObj = (__bridge_transfer id)obj;
	(void)relObj;
}

static void *mallocAcquire(const void *item, NSSizeFunction sizeFunc, bool shouldCopy)
{
	size_t s = sizeFunc(item);
	if (shouldCopy)
	{
		void *outItem = malloc(s);
		return memcpy(outItem, item, sizeFunc(item));
	}
	else
		return (void *)item;
}

static void mallocRelinquish(const void *obj, NSSizeFunction sizeFunc)
{
	free((void *)obj);
}

static void *nullAcquire(const void *item, NSSizeFunction sizeFunc, bool shouldCopy)
{
	return (void *)item;
}

static void nullRelinquish(const void *obj, NSSizeFunction sizeFunc)
{
}

static NSString *objectDescription(const void *item)
{
	return [(__bridge id)item description];
}

static NSString *pointerDescription(const void *item)
{
	return [NSString stringWithFormat:@"%p",item];
}

static NSString *cstringDescription(const void *str)
{
	return [NSString stringWithFormat:@"%s",str];
}

static NSString *integerDescription(const void *item)
{
	return [NSString stringWithFormat:@"%ld",(long)(intptr_t)item];
}

static NSHashCode objectHash(const void *item, NSSizeFunction sizeFunc)
{
	return [(__bridge id)item hash];
}

static NSHashCode pointerHash(const void *item, NSSizeFunction sizeFunc)
{
	return (NSHashCode)(uintptr_t)item >> 2;
}

static NSHashCode integerHash(const void *item, NSSizeFunction sizeFunc)
{
	return (intptr_t)item;
}

static NSHashCode memoryHash(const void *item, NSSizeFunction sizeFunc)
{
	return hashjb(item, strlen(item));
}

static NSHashCode cstringHash(const void *item, NSSizeFunction sizeFunc)
{
	return hashjb(item, sizeFunc(item));
}

static bool objectIsEqual(const void *obj1, const void *obj2, NSSizeFunction sizeFunc)
{
	return [(__bridge id)obj1 isEqual:(__bridge id)obj2];
}

static bool directIsEqual(const void *obj1, const void *obj2, NSSizeFunction sizeFunc)
{
	return obj1 == obj2;
}

static bool cstringIsEqual(const void *obj1, const void *obj2, NSSizeFunction sizeFunc)
{
	return strcmp(obj1, obj2);
}

static bool memoryIsEqual(const void *obj1, const void *obj2, NSSizeFunction sizeFunc)
{
	size_t s1 = sizeFunc(obj1);
	size_t s2 = sizeFunc(obj2);
	return (s1 == s2) && (memcmp(obj1, obj2, sizeFunc(obj1)) == 0);
}

@implementation NSPointerFunctions	:	NSObject
@synthesize acquireFunction;
@synthesize descriptionFunction;
@synthesize hashFunction;
@synthesize isEqualFunction;
@synthesize relinquishFunction;
@synthesize sizeFunction;
@synthesize usesStrongWriteBarrier;
@synthesize usesWeakReadAndWriteBarriers;

+ (id) pointerFunctionsWithOptions:(NSPointerFunctionsOptions)options
{
	return [[self alloc] initWithOptions:options];
}

- (id) initWithOptions:(NSPointerFunctionsOptions)options
{
	NSPointerFunctionsOptions memOpts = (options & 0xff);
	NSPointerFunctionsOptions persOpts = (options & 0xff00);
	switch (memOpts)
	{
		case NSPointerFunctionsStrongMemory:
			if (persOpts == NSPointerFunctionsObjectPersonality || persOpts == NSPointerFunctionsObjectPointerPersonality)
			{
				self.acquireFunction = objectAcquire;
				self.relinquishFunction = objectRelinquish;
			}
			self.usesStrongWriteBarrier = true;
			break;
		case NSPointerFunctionsOpaqueMemory:
			self.acquireFunction = nullAcquire;
			self.relinquishFunction = nullRelinquish;
			break;
		case NSPointerFunctionsMallocMemory:
			self.acquireFunction = mallocAcquire;
			self.relinquishFunction = mallocRelinquish;
			break;
		case NSPointerFunctionsZeroingWeakMemory:
			self.usesWeakReadAndWriteBarriers = true;
			self.acquireFunction = nullAcquire;
			self.relinquishFunction = nullRelinquish;
			break;
	}
	switch (persOpts)
	{
		case NSPointerFunctionsObjectPersonality:
			self.descriptionFunction = objectDescription;
			self.hashFunction = objectHash;
			self.isEqualFunction = objectIsEqual;
			self.sizeFunction = objectSize;
			break;
		case NSPointerFunctionsObjectPointerPersonality:
			self.descriptionFunction = objectDescription;
			self.hashFunction = pointerHash;
			self.isEqualFunction = directIsEqual;
			break;
		case NSPointerFunctionsOpaquePersonality:
			self.descriptionFunction = pointerDescription;
			self.hashFunction = pointerHash;
			self.isEqualFunction = directIsEqual;
			break;
		case NSPointerFunctionsCStringPersonality:
			self.descriptionFunction = cstringDescription;
			self.hashFunction = cstringHash;
			self.isEqualFunction = cstringIsEqual;
			break;
		case NSPointerFunctionsStructPersonality:
			self.descriptionFunction = pointerDescription;
			self.hashFunction = memoryHash;
			self.isEqualFunction = memoryIsEqual;
			break;
		case NSPointerFunctionsIntegerPersonality:
			self.descriptionFunction = integerDescription;
			self.hashFunction = integerHash;
			self.isEqualFunction = directIsEqual;
			break;
	}

	return self;
}

- (void) _fixupEmptyFunctions
{
	if (self.descriptionFunction == NULL)
		self.descriptionFunction = pointerDescription;
	if (self.hashFunction == NULL)
		self.hashFunction = integerHash;
	if (self.isEqualFunction == NULL)
		self.isEqualFunction = directIsEqual;
	if (self.acquireFunction == NULL)
		self.acquireFunction = nullAcquire;
	if (self.relinquishFunction == NULL)
		self.relinquishFunction = nullRelinquish;
}

- (id) copyWithZone:(NSZone *)z
{
	NSPointerFunctions *other = [[NSPointerFunctions allocWithZone:z] init];
	other.descriptionFunction = self.descriptionFunction;
	other.hashFunction = self.hashFunction;
	other.isEqualFunction = self.isEqualFunction;
	other.acquireFunction = self.acquireFunction;
	other.relinquishFunction = self.relinquishFunction;

	return other;
}
@end
