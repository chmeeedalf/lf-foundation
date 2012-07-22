/*
 * Copyright (c) 2012	Justin Hibbits
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

#import <Foundation/NSURLCache.h>
#import "internal.h"

static NSURLCache *sharedCache;

@implementation NSURLCache
{
	NSUInteger memoryCapacity;
	NSUInteger diskCapacity;
}

+(NSURLCache *)sharedURLCache
{
	NSURLCache *cache = sharedCache;
	if (cache == nil)
	{
		@synchronized(self)
		{
			cache = sharedCache;
			if (cache == nil)
			{
				NSURL *sharedURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomains:NSUserDomainMask appropriateForURL:nil create:true error:nil];
				NSString sharedPath = [[sharedURL absolutePath] stringByAppendingPathComponent:[NSProcessInfo processName]];
				sharedCache = [[self alloc] initWithMemoryCapacity:(4 * 1024 * 1024)
													  diskCapacity:(20 * 1024 * 1024)
														  diskPath:sharedPath];
				cache = sharedCache;
			}
		}
	}
	return cache;
}

+(void)setSharedURLCache:(NSURLCache *)cache
{
	@synchronized(self)
	{
		sharedCache = cache;
	}
}

-(id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)diskPath
{
	TODO; // -[NSURLCache initWithMemoryCapacity:diskCapacity:diskPath:]
	[self notImplemented:_cmd];
	return nil;
}

-(NSUInteger)memoryCapacity
{
	TODO; // -[NSURLCache memoryCapacity]
	return memoryCapacity;
}

-(NSUInteger)diskCapacity
{
	TODO; // -[NSURLCache diskCapacity]
	return diskCapacity;
}

-(NSUInteger)currentDiskUsage
{
	TODO; // -[NSURLCache currentDiskUsage]
	[self notImplemented:_cmd];
	return 0;
}

-(NSUInteger)currentMemoryUsage
{
	TODO; // -[NSURLCache currentMemoryUsage]
	[self notImplemented:_cmd];
	return 0;
}

-(NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
	TODO; // -[NSURLCache cachedResponseForRequest:]
	[self notImplemented:_cmd];
	return nil;
}

-(void)setMemoryCapacity:(NSUInteger)memoryCapacity
{
	TODO; // -[NSURLCache setMemoryCapacity:]
	[self notImplemented:_cmd];
}

-(void)setDiskCapacity:(NSUInteger)diskCapacity
{
	TODO; // -[NSURLCache setDiskCapacity:]
	[self notImplemented:_cmd];
}

-(void)storeCachedResponse:(NSCachedURLResponse *)response forRequest:(NSURLRequest *)request
{
	TODO; // -[NSURLCache storeCachedResponse:forRequest:]
	[self notImplemented:_cmd];
}

-(void)removeAllCachedResponses
{
	TODO; // -[NSURLCache removeAllCachedResponses]
	[self notImplemented:_cmd];
}

-(void)removeCachedResponseForRequest:(NSURLRequest *)request
{
	TODO; // -[NSURLCache removeCachedResponseForRequest:]
	[self notImplemented:_cmd];
}

@end
