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

#include <sys/stat.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <array>

#include <dispatch/dispatch.h>

#import <Foundation/NSFileHandle.h>

#import <Foundation/NSData.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

@class NSArray;
@class NSData;
@class NSError;
@class NSString;
@class NSURL;

NSString * const NSFileHandleConnectionAcceptedNotification = @"NSFileHandleConnectionAcceptedNotification";
NSString * const NSFileHandleDataAvailableNotification = @"NSFileHandleDataAvailableNotification";
NSString * const NSFileHandleReadCompletionNotification = @"NSFileHandleReadCompletionNotification";
NSString * const NSFileHandleReadToEndOfFileCompletionNotification = @"NSFileHandleReadToEndOfFileCompletionNotification";

NSString * const NSFileHandleNotificationFileHandleItem = @"NSFileHandleNotificationFileHandleItem";
NSString * const NSFileHandleNotificationDataItem = @"NSFileHandleNotificationDataItem";

@implementation NSFileHandleOperationException
@end

@interface NSFileHandle()
- (void) setNonBlock:(bool)noblock;
@end

@implementation NSFileHandle
{
	int fd;

	dispatch_source_t readSource;
	dispatch_source_t writeSource;
	dispatch_queue_t dispatchQueue;
	void (^readabilityHandler)(NSFileHandle *);
	void (^writeabilityHandler)(NSFileHandle *);

	bool closeOnDealloc;
	bool isNonBlocked;
	bool isRegularFile;
}

@synthesize readabilityHandler;
@synthesize writeabilityHandler;

- (void) setReadabilityHandler:(void (^)(NSFileHandle *))handler
{
	if (handler == NULL)
	{
		dispatch_source_cancel(readSource);
	}
	else
	{
		if (readSource == 0)
		{
			readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0,
					dispatchQueue);
		}
		else
		{
			dispatch_suspend(readSource);
		}
		dispatch_source_set_event_handler(readSource, ^{
				readabilityHandler(self);
				});
		dispatch_resume(readSource);
	}
}

- (void) setWriteabilityHandler:(void (^)(NSFileHandle *))handler
{
	if (handler == NULL)
	{
		dispatch_source_cancel(writeSource);
	}
	else
	{
		if (writeSource == 0)
		{
			writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0,
					dispatchQueue);
		}
		else
		{
			dispatch_suspend(writeSource);
		}
		dispatch_source_set_event_handler(writeSource, ^{
				writeabilityHandler(self);
				});
		dispatch_resume(writeSource);
	}
}

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
	struct stat sb;
	closeOnDealloc = doClose;
	fd = desc;

	if (fstat(desc, &sb) < 0)
		return nil;

	if (S_ISREG(sb.st_mode))
	{
		isRegularFile = true;
	}
	else
	{
		isRegularFile = false;
	}
	dispatchQueue = dispatch_queue_create(NULL, NULL);
	return self;
}

- (void) dealloc
{
	dispatch_source_cancel(readSource);
	dispatch_source_cancel(writeSource);
	dispatch_release(readSource);
	dispatch_release(writeSource);
	dispatch_release(dispatchQueue);
	if (closeOnDealloc)
		close(fd);
}

- (int) fileDescriptor
{
	return fd;
}


- (NSData *) availableData
{
	if (isRegularFile)
	{
		return [self readDataToEndOfFile];
	}
	else
	{
		char buf[BUFSIZ];
		ssize_t read_count;

		[self setNonBlock:true];
		read_count = read(fd, buf, sizeof(buf));
		if (read_count <= 0)
		{
			[self setNonBlock:false];
			read_count = read(fd, buf, 1);
			if (read_count <= 0)
			{
				char buf[NL_TEXTMAX];
				strerror_r(errno, buf, sizeof(buf));

				@throw [NSFileHandleOperationException
					exceptionWithReason:@"Unable to read from descriptor."
					userInfo:@{
						@"NSFileHandleError" : @(buf)}];
			}
			else
			{
				[self setNonBlock:true];
				read_count = read(fd, &buf[1], sizeof(buf) - 1);
				read_count++;
			}
		}
		return [NSData dataWithBytes:buf length:read_count];
	}
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

- (void) setNonBlock:(bool)noblock
{
	if (noblock != isNonBlocked)
	{
		fcntl(fd, F_SETFL, noblock ? O_NONBLOCK : 0);
		isNonBlocked = noblock;
	}
}

- (NSData *) readDataOfLength:(NSUInteger)length
{
	NSMutableData *d = [NSMutableData new];
	std::array<char, BUFSIZ> buf;

	[self setNonBlock:false];
	do
	{
		NSUInteger rlen = BUFSIZ;
		ssize_t rd;

		if (length < BUFSIZ)
		{
			rlen = length;
		}
		rd = read(fd, &buf[0], rlen);
		if (rd < 0)
		{
			char buf[NL_TEXTMAX];
			strerror_r(errno, buf, sizeof(buf));

			@throw [NSFileHandleOperationException exceptionWithReason:@(buf) userInfo:nil];
		}
		[d appendBytes:&buf[0] length:rd];
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

- (void) _acceptConnection
{
	int acceptedFd = accept(fd, NULL, NULL);
	id outHandle = nil;

	if (acceptedFd >= 0)
	{
		outHandle = [[[self class] alloc] initWithFileDescriptor:acceptedFd];
	}
	[[NSNotificationCenter defaultCenter]
		postNotificationName:NSFileHandleConnectionAcceptedNotification
		object:self
		userInfo:@{
			NSFileHandleNotificationFileHandleItem : outHandle ?: self,
			@"NSFileHandleError" : @(errno)}];
}

- (void) _readDataBackground
{
	NSData *data;
	char buf[BUFSIZ];

	[self setNonBlock:true];
	ssize_t read_data = read(fd, buf, BUFSIZ);
	data = [NSData dataWithBytes:buf length:read_data];
	[[NSNotificationCenter defaultCenter]
		postNotificationName:NSFileHandleReadCompletionNotification
		object:self
		userInfo:@{
			NSFileHandleNotificationDataItem : data,
			@"NSFileHandleError" : @(errno)}];
}

- (void) _readDataToEndBackground
{
	static char key = 'f';
	NSMutableData *data;
	char buf[BUFSIZ];
	int err;

	ssize_t read_data = read(fd, buf, BUFSIZ);
	err = errno;
	data = objc_getAssociatedObject(self, &key);

	if (data == nil)
	{
		data = [NSMutableData new];
		objc_setAssociatedObject(self, &key, data,
				OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	if (read_data > 0)
	{
		[data appendBytes:buf length:read_data];
		return;
	}

	[[NSNotificationCenter defaultCenter]
		postNotificationName:NSFileHandleReadCompletionNotification
		object:self
		userInfo:@{
NSFileHandleNotificationDataItem : data,
								 @"NSFileHandleError" : @(err)}];
}

- (void) _dataAvailableBackground
{
	[[NSNotificationCenter defaultCenter]
		postNotificationName:NSFileHandleDataAvailableNotification
		object:self];
}

- (void) _addRunLoopSourceEventHandlerForModes:(NSArray *)modes selector:(SEL)selector
{
	if (modes != nil)
	{
		for (id mode in modes)
		{
			[[NSRunLoop currentRunLoop]
				addRunLoopSource:(new Alepha::RunLoop::File(fd))
				target:self
				selector:@selector(acceptConnection) mode:mode];
		}
	}
	else
	{
		[[NSRunLoop currentRunLoop]
			addRunLoopSource:(new Alepha::RunLoop::File(fd))
			target:self
			selector:@selector(acceptConnection) mode:NSDefaultRunLoopMode];
	}
}

- (void) acceptConnectionInBackgroundAndNotify
{
	[self acceptConnectionInBackgroundAndNotifyForModes:nil];
}

- (void) acceptConnectionInBackgroundAndNotifyForModes:(NSArray *)modes
{
	[self _addRunLoopSourceEventHandlerForModes:modes
		selector:@selector(_acceptConnection)];
}

- (void) readInBackgroundAndNotify
{
	[self readInBackgroundAndNotifyForModes:nil];
}

- (void) readInBackgroundAndNotifyForModes:(NSArray *)modes
{
	[self _addRunLoopSourceEventHandlerForModes:modes
		selector:@selector(_readDataBackground)];
}

- (void) readToEndOfFileInBackgroundAndNotify
{
	[self readToEndOfFileInBackgroundAndNotifyForModes:nil];
}

- (void) readToEndOfFileInBackgroundAndNotifyForModes:(NSArray *)modes
{
	[self setNonBlock:false];
	[self _addRunLoopSourceEventHandlerForModes:modes
		selector:@selector(_readDataBackground)];
}

- (void) waitForDataInBackgroundAndNotify
{
	[self waitForDataInBackgroundAndNotifyForModes:nil];
}

- (void) waitForDataInBackgroundAndNotifyForModes:(NSArray *)modes
{
	[self _addRunLoopSourceEventHandlerForModes:modes
		selector:@selector(_dataAvailableBackground)];
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
				reason = @"File descriptor is not a regular file";
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
				reason = @"File descriptor is not a regular file";
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
				reason = @"File descriptor is not a regular file";
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
				reason = @"File descriptor is not a regular file";
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
