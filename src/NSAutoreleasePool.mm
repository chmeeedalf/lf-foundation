/*
 * Copyright (c) 2004	Gold Project
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

/*
   NSAutoreleasePool.m

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

   This file is part of libFoundation.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.
*/

#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#import "internal.h"
#include <stdlib.h>
#include <algorithm>
#include <deque>

@implementation NSAutoreleasePool

/*
 * Static variables
 */

// default pool (per thread)
static __thread NSAutoreleasePool* defaultPool = nil;

/*
 * Instance initialization
 */

- init
{
	parentPool = defaultPool;
	firstChunk = NULL;

	defaultPool = self;
	ownerThread = [NSThread currentThread];

	return self;
}

/*
 * Instance deallocation
 */

- (void)dealloc
{
	NSAssert(ownerThread == [NSThread currentThread],
			@"Must destroy the NSAutoreleasePool from the owning thread.");

	while (defaultPool != self)
	{
		[defaultPool release];
	}

	// All autoreleased objects created in dealloc methods go to the parent
	// pool.  They shouldn't be used, but might.  If this is the thread's
	// primary autorelease pool, memory will be leaked, but it can't be helped
	// without a lot of work.
	defaultPool = parentPool;

	[self drain];

	[super dealloc];
}

static void auto_release(id obj)
{
	[obj release:true];
}

- (void) drain
{
	NSAutoreleasePoolChunk *drainedChunk = firstChunk;

	if (firstChunk == NULL)
		return;

	firstChunk = NULL;
	
	std::for_each(drainedChunk->begin(), drainedChunk->end(), auto_release);
	delete drainedChunk;
}

/*
 * Notes that aObject should be released when the pool
 * at the current top of the stack is freed
 * This is called by NSObject -autorelease.
 */

+ (void)addObject:aObject
{
	if (defaultPool == nil)
		defaultPool = [NSAutoreleasePool new];

	[defaultPool addObject:aObject];
}

/*
 * Notes that aObject must be released when pool is freed
 */

- (void)addObject:aObject
{
	if (firstChunk == NULL)
	{
		firstChunk = new NSAutoreleasePoolChunk;
	}
	firstChunk->push_back(aObject);
}

/*
 * Default pool
 */

+ defaultPool
{
	return defaultPool;
}

#if 0
// For ARC compatibility.
- (void) _ARCCompatibleAutoreleasePool
{
}
#endif

@end /* NSAutoreleasePool */

/*
 * Class that handles C pointers release sending them Free()
 */

@implementation NSAutoreleasedPointer

+ (id)autoreleasePointer:(void*)address
{
	return AUTORELEASE([[self alloc] initWithPointerAddress:address]);
}

- initWithPointerAddress:(void*)address
{
	theAddress = address;
	return self;
}

- (void)dealloc
{
	free(theAddress);
	[super dealloc];
}

@end /* AutoreleasedPointer */
