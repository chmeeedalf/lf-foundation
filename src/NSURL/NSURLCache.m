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

#import <Foundation/NSFileManager.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSValue.h>

#import "NSSqlite.h"
#import "internal.h"

/*
 * Design of NSURLCache:
 *
 * LRU-based cache.  Least recently used are pushed out to disk when reaching
 * memory capacity.  Once on-disk it still maintains temporal data for eviction
 * purposes.
 *
 * Both in-memory and on-disk use sqlite databases.  This ensures a consistent
 * access to each store.  Columns for the tables are:
 *
 * Request -- blob
 * Response -- blob
 * Timestamp -- datetime
 *
 * When the memory cache fills up, it flushes some to the disk cache.  When it
 * retrieves an entry from the disk cache, it's copied into the memory cache,
 * but not removed from the disk cache until normal LRU purging.
 */
static NSURLCache *sharedCache;

@implementation NSURLCache
{
	NSSqliteDatabase *diskCache;
	NSSqliteDatabase *memCache;
	NSUInteger sqlitePagesize;
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
				NSURL *sharedURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:true error:NULL];
				NSString *sharedPath = [[sharedURL path] stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
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

-(id)initWithMemoryCapacity:(NSUInteger)memCap diskCapacity:(NSUInteger)diskCap diskPath:(NSString *)diskPath
{
	diskCache = [NSSqliteDatabase databaseWithURL:[NSURL fileURLWithPath:diskPath]];
	memCache = [NSSqliteDatabase temporaryDatabase];
	[diskCache setValue:@(diskCap) forPragma:@"max_page_count"];
	[memCache setValue:@(memCap) forPragma:@"max_page_count"];

	return self;
}

-(NSUInteger)memoryCapacity
{
	return [[diskCache valueForPragma:@"max_page_count"] unsignedIntegerValue];
}

-(NSUInteger)diskCapacity
{
	return [[diskCache valueForPragma:@"max_page_count"] unsignedIntegerValue];
}

-(NSUInteger)currentDiskUsage
{
	return [[diskCache valueForPragma:@"page_count"] unsignedIntegerValue];
}

-(NSUInteger)currentMemoryUsage
{
	return [[memCache valueForPragma:@"page_count"] unsignedIntegerValue];
}

-(NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
	TODO; // -[NSURLCache cachedResponseForRequest:]
	[self notImplemented:_cmd];
	return nil;
}

-(void)setMemoryCapacity:(NSUInteger)newCap
{
	[memCache setValue:@(newCap) forPragma:@"max_page_count"];
}

-(void)setDiskCapacity:(NSUInteger)newCap
{
	[diskCache setValue:@(newCap) forPragma:@"max_page_count"];
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
