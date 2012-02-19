/*
 * Copyright (c) 2005-2012	Gold Project
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

#import <Foundation/NSResourceManager.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>

@implementation NSResourceManager

static NSResourceManager *sharedResourceManager = nil;
static NSMutableDictionary *resources;

+ (void) initialize
{
	sharedResourceManager = (id)NSAllocateObject(self, 0, NSDefaultAllocZone());
	resources = [NSMutableDictionary new];
}

+ (id) allocWithZone:(NSZone *)zone
{
	return sharedResourceManager;
}

- (id) init
{
	return sharedResourceManager;
}

+ (NSResourceManager *)sharedManager
{
	return sharedResourceManager;
}

- (id) resourceWithName:(NSString *)name
{
	return [self resourceWithName:name inDomain:NSInnermostResourceDomain];
}

- (id) resourceWithName:(NSString *)name inDomain:(NSResourceDomain)domain
{
	id obj = resources;
	NSArray *nameArray = [name componentsSeparatedByString:@"/"];

	if (name == nil)
		return nil;

	for (id x in nameArray)
	{
		@try
		{
			obj = [obj objectForKey:x];
		}
		@catch (NSException *any)
		{
			return nil;
		}
	}
	return obj;
}

- (void) addResourceDictionary:(NSDictionary *)dict
{
	for (id key in dict)
	{
		if ([resources objectForKey:key] == nil)
		{
			[resources setObject:[dict objectForKey:key] forKey:key];
		}
	}
}

// Must be a directory/dictionary path, not a single object
- (void) loadResourcesWithURI:(NSURI *)path
{
	bool isDir = false;
	if (![[NSFileManager defaultManager] fileExistsAtURI:path isDirectory:&isDir] || !isDir)
	{
		@throw [NSRuntimeException
			exceptionWithReason:
				[NSString stringWithFormat:@"NSObject with path '%@' not a"
				@" NSDictionary-like object.",path]
			userInfo:nil];
	}
}

- (void) dealloc
{
	@throw [NSRuntimeException
		exceptionWithReason: @"Attempting to dealloc shared resources"
		userInfo:nil];
}

@end
