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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#import <Foundation/NSFileHandle.h>

#import <Foundation/NSData.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSString.h>

@class NSArray;
@class NSData;
@class NSError;
@class NSString;
@class NSURL;

extern NSString * const NSFileHandleConnectionAcceptedNotification;
extern NSString * const NSFileHandleDataAvailableNotification;
extern NSString * const NSFileHandleReadCompletionNotification;
extern NSString * const NSFileHandleReadToEndOfFileCompletionNotification;

extern NSString * const NSFileHandleNotificationFileHandleItem;
extern NSString * const NSFileHandleNotificationDataItem;

@implementation NSFileHandleOperationException
@end

@implementation NSFileHandle
{
	int fd;
	bool closeOnDealloc;
}

@synthesize readabilityHandler;
@synthesize writeabilityHandler;

+ (id) fileHandleForReadingFromURL:(NSURL *)url error:(NSError **)errp
{
	return [[NSFileManager defaultManager] fileHandleForReadingAtURL:url error:errp];
}

+ (id) fileHandleForWritingToURL:(NSURL *)url error:(NSError **)errp
{
	return [[NSFileManager defaultManager] fileHandleForWritingAtURL:url error:errp];
}

+ (id) fileHandleForUpdatingURL:(NSURL *)url error:(NSError **)errp
{
	return [[NSFileManager defaultManager] fileHandleForUpdatingAtURL:url error:errp];
}


+ (id) fileHandleWithStandardError
{
	static NSFileHandle *stderrHandle;

	if (stderrHandle == nil)
	{
		@synchronized(self)
		{
			if (stderrHandle == nil)
			{
				stderrHandle = [[NSFileHandle alloc] initWithFileDescriptor:STDERR_FILENO];
			}
		}
	}
	return stderrHandle;
}

+ (id) fileHandleWithStandardInput
{
	static NSFileHandle *stdinHandle;

	if (stdinHandle == nil)
	{
		@synchronized(self)
		{
			if (stdinHandle == nil)
			{
				stdinHandle = [[NSFileHandle alloc] initWithFileDescriptor:STDIN_FILENO];
			}
		}
	}
	return stdinHandle;
}

+ (id) fileHandleWithStandardOutput
{
	static NSFileHandle *stdoutHandle;

	if (stdoutHandle == nil)
	{
		@synchronized(self)
		{
			if (stdoutHandle == nil)
			{
				stdoutHandle = [[NSFileHandle alloc] initWithFileDescriptor:STDOUT_FILENO];
			}
		}
	}
	return stdoutHandle;
}

+ (id) fileHandleWithNullDevice
{
	static NSFileHandle *nullHandle;

	if (nullHandle == nil)
	{
		@synchronized(self)
		{
			if (nullHandle == nil)
			{
				int nullfd = open("/dev/null", O_RDWR);
				
				if (nullfd >= 0)
					nullHandle = [[NSFileHandle alloc] initWithFileDescriptor:nullfd];
			}
		}
	}
	return nullHandle;
}


- (id) initWithFileDescriptor:(int)desc
{
	return [self initWithFileDescriptor:desc closeOnDealloc:false];
}

- (id) initWithFileDescriptor:(int)desc closeOnDealloc:(bool)doClose
{
	closeOnDealloc = doClose;
	fd = desc;

	return self;
}

- (void) dealloc
{
	if (closeOnDealloc)
		close(fd);
}

- (int) fileDescriptor
{
	return fd;
}


- (NSData *) availableData
{
	TODO; // -[NSFileHandle availableData]
	return [self readDataToEndOfFile];
}

- (NSData *) readDataToEndOfFile
{
	NSMutableData *outData = [NSMutableData new];
	NSData *inData;

	do
	{
		inData = [self readDataOfLength:BUFSIZ];
	} while ([inData length] > 0);

	return outData;
}

- (NSData *) readDataOfLength:(NSUInteger)length
{
	NSMutableData *d = [NSMutableData new];
	char *buf = malloc(BUFSIZ);

	do
	{
		NSUInteger rlen = BUFSIZ;
		ssize_t rd;

		if (length < BUFSIZ)
		{
			rlen = length;
		}
		rd = read(fd, buf, rlen);
		if (rd < 0)
		{
			char buf[NL_TEXTMAX];
			strerror_r(errno, buf, sizeof(buf));

			@throw [NSFileHandleOperationException exceptionWithReason:@(buf) userInfo:nil];
		}
		[d appendBytes:buf length:rd];
		length -= rd;
		if (rd == 0)
		{
			break;
		}
	} while (length > 0);

	return d;
}


- (void) writeData:(NSData *)data
{
	if (write(fd, [data bytes], [data length]) < 0)
	{
		char buf[NL_TEXTMAX];
		strerror_r(errno, buf, sizeof(buf));

		@throw [NSFileHandleOperationException exceptionWithReason:@(buf) userInfo:nil];
	}
}


- (void) acceptConnectionInBackgroundAndNotify
{
	TODO; // -[NSFileHandle acceptConnectionInBackgroundAndNotify]
}

- (void) acceptConnectionInBackgroundAndNotifyForModes:(NSArray *)modes
{
	TODO; // -[NSFileHandle acceptConnectionInBackgroundAndNotifyForModes:]
}

- (void) readInBackgroundAndNotify
{
	TODO; // -[NSFileHandle readInBackgroundAndNotify]
}

- (void) readInBackgroundAndNotifyForModes:(NSArray *)modes
{
	TODO; // -[NSFileHandle readInBackgroundAndNotifyForModes:]
}

- (void) readToEndOfFileInBackgroundAndNotify
{
	TODO; // -[NSFileHandle readToEndOfFileInBackgroundAndNotify]
}

- (void) readToEndOfFileInBackgroundAndNotifyForModes:(NSArray *)modes
{
	TODO; // -[NSFileHandle readToEndOfFileInBackgroundAndNotifyForModes:]
}

- (void) waitForDataInBackgroundAndNotify
{
	TODO; // -[NSFileHandle waitForDataInBackgroundAndNotify]
}

- (void) waitForDataInBackgroundAndNotifyForModes:(NSArray *)modes
{
	TODO; // -[NSFileHandle waitForDataInBackgroundAndNotifyForModes:]
}


- (off_t) offsetInFile
{
	off_t offset;
	offset = lseek(fd, 0, SEEK_CUR);

	if (offset < 0)
	{
		NSString *reason;

		switch (errno)
		{
			case ESPIPE:
				reason = @"File descriptor is a pipe or socket";
				break;
			case EBADF:
				reason = @"File descriptor is closed";
				break;
			default:
				reason = @"Invalid file descriptor";
				break;
		}
		@throw [NSFileHandleOperationException exceptionWithReason:reason userInfo:nil];
	}
	return offset;
}

- (void) seekToEndOfFile
{
	if (lseek(fd, 0, SEEK_END) < 0)
	{
		NSString *reason;

		switch (errno)
		{
			case ESPIPE:
				reason = @"File descriptor is a pipe or socket";
				break;
			case EBADF:
				reason = @"File descriptor is closed";
				break;
			default:
				reason = @"Invalid file descriptor";
				break;
		}
		@throw [NSFileHandleOperationException exceptionWithReason:reason userInfo:nil];
	}
}

- (void) seekToFileOffset:(off_t)offset
{
	if (lseek(fd, offset, SEEK_SET) < 0)
	{
		NSString *reason;

		switch (errno)
		{
			case ESPIPE:
				reason = @"File descriptor is a pipe or socket";
				break;
			case EBADF:
				reason = @"File descriptor is closed";
				break;
			default:
				reason = @"Invalid file descriptor or seek offset";
				break;
		}
		@throw [NSFileHandleOperationException exceptionWithReason:reason userInfo:nil];
	}
}


- (void) closeFile
{
	close(fd);
}

- (void) synchronizeFile
{
	fsync(fd);
}

- (void) truncateFileAtOffset:(off_t)offset
{
	if (ftruncate(fd, offset) < 0)
	{
		NSString *reason;

		switch (errno)
		{
			case ESPIPE:
				reason = @"File descriptor is a pipe or socket";
				break;
			case EBADF:
				reason = @"File descriptor is closed";
				break;
			default:
				reason = @"Invalid file descriptor";
				break;
		}
		@throw [NSFileHandleOperationException exceptionWithReason:reason userInfo:nil];
	}
}

@end

@implementation NSPipe
{
	NSFileHandle *readHandle;
	NSFileHandle *writeHandle;
}

- (id) init
{
	int fds[2];

	if (pipe(fds) < 0)
	{
		return nil;
	}
	readHandle = [[NSFileHandle alloc] initWithFileDescriptor:fds[0] closeOnDealloc:true];
	writeHandle = [[NSFileHandle alloc] initWithFileDescriptor:fds[1] closeOnDealloc:true];
	return self;
}

+ (id) pipe
{
	return [[self alloc] init];
}

- (NSFileHandle *) fileHandleForReading
{
	return readHandle;
}

- (NSFileHandle *) fileHandleForWriting
{
	return writeHandle;
}
@end

/*
  vim:syntax=objc:
 */
