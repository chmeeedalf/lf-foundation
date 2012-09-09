/*
 * Copyright (c) 2010-2012	Justin Hibbits
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

#import <Foundation/NSData.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSString.h>
#import <Alepha/RunLoop.h>
#import "NSConcreteStream.h"
#import "internal.h"

@class RunLoop, NSError;

NSMakeSymbol(NSStreamSocketSecurityLevelKey);
NSMakeSymbol(NSStreamSOCKSProxyConfigurationKey);
NSMakeSymbol(NSStreamDataWrittenToMemmoryStreamKey);
NSMakeSymbol(NSStreamFileCurrentOffsetKey);
NSMakeSymbol(NSStreamNetworkServiceTypeKey);

NSMakeSymbol(NSStreamSocketSSLErrorDomain);
NSMakeSymbol(NSStreamSOCKSErrorDomain);

NSMakeSymbol(NSStreamSocketSecurityLevelNone);
NSMakeSymbol(NSStreamSocketSecurityLevelSSLv2);
NSMakeSymbol(NSStreamSocketSecurityLevelSSLv3);
NSMakeSymbol(NSStreamSocketSecurityLevelTLSv1);
NSMakeSymbol(NSStreamSocketSecurityLevelNegotiatedSSL);

NSMakeSymbol(NSStreamSOCKSProxyHostKey);
NSMakeSymbol(NSStreamSOCKSProxyPortKey);
NSMakeSymbol(NSStreamSOCKSProxyVersionKey);
NSMakeSymbol(NSStreamSOCKSProxyUserKey);
NSMakeSymbol(NSStreamSOCKSProxyPasswordKey);
NSMakeSymbol(NSStreamSOCKSProxyVersion4);
NSMakeSymbol(NSStreamSOCKSProxyVersion5);

NSMakeSymbol(NSStreamNetworkServiceTypeVoIP);
NSMakeSymbol(NSStreamNetworkServiceTypeVideo);
NSMakeSymbol(NSStreamNetworkServiceTypeBackground);
NSMakeSymbol(NSStreamNetworkServiceTypeVoice);

@implementation NSStream
+ (void)getStreamsToHost:(NSHost *)host port:(NSInteger)port inputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream
{
	TODO; // +[NSStream getStreamsToHost:port:inputStream:outputStream:]
	return;
}

- (id) propertyForKey:(NSString *)key
{
	return [self subclassResponsibility:_cmd];
}

- (oneway void) setProperty:(id)prop forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (id<NSStreamDelegate>)delegate
{
	return self;
}

- (oneway void) setDelegate:(id<NSStreamDelegate>)delegate
{
	[self subclassResponsibility:_cmd];
}


- (void) open
{
	[self subclassResponsibility:_cmd];
}

- (void) close
{
	[self subclassResponsibility:_cmd];
}


- (void) scheduleInRunLoop:(RunLoop *)loop
{
	[self subclassResponsibility:_cmd];
}

- (void) removeFromRunLoop:(RunLoop *)loop
{
	[self subclassResponsibility:_cmd];
}


- (NSError *) streamError
{
	return [self subclassResponsibility:_cmd];
}

- (NSStreamStatus) streamStatus
{
	[self subclassResponsibility:_cmd];
	return NSStreamStatusError;
}

- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)event
{
	// Empty.  Here to conform to protocol.
}

- (void) scheduleInRunLoop:(NSRunLoop *)loop forMode:(NSString *)mode
{
	[self subclassResponsibility:_cmd];
}

- (void) removeFromRunLoop:(NSRunLoop *)loop forMode:(NSString *)mode
{
	[self subclassResponsibility:_cmd];
}

@end

@implementation NSInputStream
+ (id) inputStreamWithData:(NSData *)d
{
	return [[self alloc] initWithData:d];
}

+ (id) inputStreamWithURL:(NSURL *)uri
{
	return [[self alloc] initWithURL:uri];
}


- (id) initWithData:(NSData *)d
{
	return [[NSInputStream_data alloc] initWithData:d];
}

- (id) initWithURL:(NSURL *)uri
{
	[self notImplemented:_cmd];
	return nil;
}


- (NSInteger) read:(uint8_t *)buf maxLength:(NSUInteger)max
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (bool) getBuffer:(uint8_t **)buf length:(NSUInteger *)len
{
	[self subclassResponsibility:_cmd];
	return false;
}

- (bool) hasBytesAvailable
{
	[self subclassResponsibility:_cmd];
	return false;
}

@end

@implementation NSOutputStream

+ (id) outputStreamToMemory
{
	return [[self alloc] initToMemory];
}

+ (id) outputStreamToBuffer:(uint8_t *)buf capacity:(NSUInteger)cap
{
	return [[self alloc] initToBuffer:buf capacity:cap];
}

+ (id) outputStreamWithURL:(NSURL *)uri append:(bool)append
{
	return [[self alloc] initWithURL:uri append:append];
}


- (id) initToMemory
{
	return [[NSOutputStream_memory alloc] initToMemory];
}

- (id) initToBuffer:(uint8_t *)buf capacity:(NSUInteger)cap
{
	return [[NSOutputStream_buffer alloc] initToBuffer:buf capacity:cap];
}

- (id) initWithURL:(NSURL *)uri append:(bool)append
{
	[self notImplemented:_cmd];
	return nil;
}


- (NSInteger) write:(const uint8_t *)buf maxLength:(NSUInteger)max
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (bool) hasSpaceAvailable
{
	[self subclassResponsibility:_cmd];
	return false;
}

@end
