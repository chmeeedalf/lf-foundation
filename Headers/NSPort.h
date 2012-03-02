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
#import <Foundation/NSCoder.h>
#import <Foundation/NSRunLoop.h>

__BEGIN_DECLS

@class NSArray, PortMessage, NSString, NSConnection, NSDate, NSRunLoop;
@protocol NSEventSource;

SYSTEM_EXPORT NSString * const NSPortDidBecomeInvalidNotification;

@protocol NSPortDelegate<NSObject>
- (void) handlePortMessage:(PortMessage *)message;
@end

@interface NSPort	:	NSObject<NSCoding,NSCopying,NSEventSource>
{
	bool				_isValid;
	id<NSPortDelegate>	_delegate;
}

+ (id) port;
+ (Class) portCoderClass;

- (void) invalidate;
- (bool) isValid;

- (void) setDelegate:(id<NSPortDelegate>) delegate;
- (id<NSPortDelegate>) delegate;

- (void) addConnection:(NSConnection *)conn toRunLoop:(NSRunLoop *)loop forMode:(NSString *)mode;
- (void) removeConnection:(NSConnection *)conn fromRunLoop:(NSRunLoop *)loop forMode:(NSString *)mode;

- (uint32_t) newConversation;
- (bool) sendBeforeDate:(NSDate *)date components:(NSArray *)comp from:(NSPort *)from reserved:(size_t)reserved;
- (bool) sendBeforeDate:(NSDate *)date msgid:(uint32_t)msgid components:(NSArray *)comp from:(NSPort *)from reserved:(size_t)reserved;
- (size_t)reservedSpaceLength;

- (void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
- (void)removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
@end

__END_DECLS
