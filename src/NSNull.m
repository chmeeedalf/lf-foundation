/*
 * Copyright (c) 2005	Gold Project
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
#include <stddef.h>

#import <Foundation/NSNull.h>
#import <Foundation/NSString.h>

@implementation NSNull

static NSNull *sharedNull = nil;

+ (void) initialize
{
	if (sharedNull == nil)
		sharedNull = (NSNull *)NSAllocateObject([NSNull class], 0, NULL);
}

+ null
{
	return sharedNull;
}

+ allocWithZone:(NSZone *)zone
{
	return sharedNull;
}

- description
{
	return @"<null>";
}

- (id) autorelease
{
	// Don't add this to an autorelease pool, it's not necessary.
	return self;
}

- (id) retain
{
	return self;
}

- (oneway void) release
{
	// NOTHING
}

- (void) dealloc
{
	// Appease gcc 4.x, which wants [super dealloc] for all subclasses
	if (0)
		[super dealloc];
}

- (id) copyWithZone:(NSZone *)zone
{
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	// NOTHING
}

- (id) initWithCoder:(NSCoder *)coder
{
	return self;
}
@end
