/*
 * Copyright (c) 2010-2012	Gold Project
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

#import <Foundation/NSObject.h>

typedef enum
{
	NSStreamStatusNotOpen,
	NSStreamStatusOpening,
	NSStreamStatusOpen,
	NSStreamStatusReading,
	NSStreamStatusWriting,
	NSStreamStatusAtEnd,
	NSStreamStatusClosed,
	NSStreamStatusError,
} NSStreamStatus;

typedef enum
{
	NSStreamEventNone = 0,
	NSStreamEventOpenCompleted = 1,
	NSStreamEventHasBytesAvailable = 1 << 1,
	NSStreamEventHasSpaceAvailable = 1 << 2,
	NSStreamEventErrorOccurred = 1 << 3,
	NSStreamEventEndEncountered = 1 << 4,
} NSStreamEvent;

@class NSStream, NSRunLoop, NSError, NSData, NSURL, NSHost;
@class NSInputStream, NSOutputStream;

@protocol NSStreamDelegate<NSObject>
- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)event;
@end

@protocol NSInputStream
- (size_t) read:(uint8_t *)buf maxLength:(size_t)max;
- (bool) getBuffer:(uint8_t **)buf length:(size_t *)len;
- (bool) hasBytesAvailable;
@end

@protocol NSOutputStream
- (size_t) write:(const uint8_t *)buf maxLength:(size_t)max;
- (bool) hasSpaceAvailable;
@end

@interface NSStream	:	NSObject<NSStreamDelegate>
{
}
+ (void)getStreamsToHost:(NSHost *)host port:(NSInteger)port inputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream;

/* Methods to override. */
- (id) propertyForKey:(NSString *)key;
- (oneway void) setProperty:(id)prop forKey:(NSString *)key;
- (id<NSStreamDelegate>) delegate;
- (oneway void) setDelegate:(id<NSStreamDelegate>)delegate;

- (void) open;
- (void) close;

- (void) scheduleInRunLoop:(NSRunLoop *)loop forMode:(NSString *)mode;
- (void) removeFromRunLoop:(NSRunLoop *)loop forMode:(NSString *)mode;

- (NSError *) streamError;
- (NSStreamStatus) streamStatus;
@end

@interface NSInputStream	:	NSStream<NSInputStream>
{
}
+ (id) inputStreamWithData:(NSData *)d;
+ (id) inputStreamWithURL:(NSURL *)uri;

- (id) initWithData:(NSData *)d;
- (id) initWithURL:(NSURL *)uri;

- (size_t) read:(uint8_t *)buf maxLength:(size_t)max;
- (bool) getBuffer:(uint8_t **)buf length:(size_t *)len;
- (bool) hasBytesAvailable;
@end

@interface NSOutputStream	:	NSStream<NSOutputStream>
{
}

+ (id) outputStreamToMemory;
+ (id) outputStreamToBuffer:(uint8_t *)buf capacity:(size_t)cap;
+ (id) outputStreamWithURL:(NSURL *)uri append:(bool)append;

- (id) initToMemory;
- (id) initToBuffer:(uint8_t *)buf capacity:(size_t)cap;
- (id) initWithURL:(NSURL *)uri append:(bool)append;

- (size_t) write:(const uint8_t *)buf maxLength:(size_t)max;
- (bool) hasSpaceAvailable;
@end

extern NSString * const NSStreamSocketSecurityLevelKey;
extern NSString * const NSStreamSOCKSProxyConfigurationKey;
extern NSString * const NSStreamDataWrittenToMemmoryStreamKey;
extern NSString * const NSStreamFileCurrentOffsetKey;
extern NSString * const NSStreamNetworkServiceTypeKey;

extern NSString * const NSStreamSocketSSLErrorDomain;
extern NSString * const NSStreamSOCKSErrorDomain;

extern NSString * const NSStreamSocketSecurityLevelNone;
extern NSString * const NSStreamSocketSecurityLevelSSLv2;
extern NSString * const NSStreamSocketSecurityLevelSSLv3;
extern NSString * const NSStreamSocketSecurityLevelTLSv1;
extern NSString * const NSStreamSocketSecurityLevelNegotiatedSSL;

extern NSString * const NSStreamSOCKSProxyHostKey;
extern NSString * const NSStreamSOCKSProxyPortKey;
extern NSString * const NSStreamSOCKSProxyVersionKey;
extern NSString * const NSStreamSOCKSProxyUserKey;
extern NSString * const NSStreamSOCKSProxyPasswordKey;
extern NSString * const NSStreamSOCKSProxyVersion4;
extern NSString * const NSStreamSOCKSProxyVersion5;

extern NSString * const NSStreamNetworkServiceTypeVoIP;
extern NSString * const NSStreamNetworkServiceTypeVideo;
extern NSString * const NSStreamNetworkServiceTypeBackground;
extern NSString * const NSStreamNetworkServiceTypeVoice;
