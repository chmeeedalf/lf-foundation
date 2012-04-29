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

#include <errno.h>
#include <fcntl.h>

#import <Foundation/NSDistributedLock.h>

#import <Foundation/NSDate.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSValue.h>

@class NSDate;
@class NSString;

@implementation NSDistributedLock
{
	NSString *lockPath;
	NSDate   *lockDate;
}

+ (id) lockWithPath:(NSString *)path
{
	return [[self alloc] initWithPath:path];
}

- (id) initWithPath:(NSString *)path
{
	lockPath = [path copy];

	return self;
}

- (bool) tryLock
{
	int fd = open([lockPath fileSystemRepresentation], O_WRONLY | O_CREAT | O_EXCL, 0644);

	if (fd < 0)
	{
		if (errno == EEXIST)
			return false;
		else
		{
			@throw [NSStandardException exceptionWithReason:@"File system error creating lock."
												  userInfo:@{ @"NSFileSystemError" : @(errno) }];
		}
	}
	lockDate = [self lockDate];
	return true;
}

- (void) breakLock
{
	if ([[NSFileManager defaultManager]
			attributesOfItemAtURL:[NSURL fileURLWithPath:lockPath]
							error:NULL] == nil)
		return;

	if (![[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:lockPath] error:NULL])
		@throw [NSStandardException exceptionWithReason:@"Filesystem error while unlocking distributed lock" userInfo:nil];
}

- (void) unlock
{
	NSDate *lDate = [self lockDate];

	if (lDate == nil)
		@throw [NSStandardException exceptionWithReason:@"Lock not locked" userInfo:nil];
	if (![lockDate isEqual:[self lockDate]])
	{
		@throw [NSStandardException exceptionWithReason:@"Lock already broken and re-used" userInfo:nil];
	}
	if (![[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:lockPath] error:NULL])
		@throw [NSStandardException exceptionWithReason:@"Filesystem error while unlocking distributed lock" userInfo:nil];
}

- (NSDate *) lockDate
{
	NSDictionary *attribs = [[NSFileManager defaultManager]
		attributesOfItemAtURL:[NSURL fileURLWithPath:lockPath] error:NULL];
	
	return [attribs fileCreationDate];
}

@end
