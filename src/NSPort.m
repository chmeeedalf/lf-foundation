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

#import <Foundation/NSPort.h>
#import <Foundation/NSException.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSPortCoder.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSString.h>

@class NSArray, NSPortMessage, NSString, NSConnection, NSDate, NSRunLoop;

NSMakeSymbol(NSPortDidBecomeInvalidNotification);

@implementation NSPort
{
	bool				_isValid;
	id<NSPortDelegate>	delegate;
}

+ (id) allocWithZone:(NSZone *)zone
{
	return [super allocWithZone:zone];
}

+ (id) port
{
	return [[self alloc] init];
}

+ (Class) portCoderClass
{
	return [self subclassResponsibility:_cmd];
}

- (void) invalidate
{
	_isValid = false;
	[[NSNotificationCenter defaultCenter] postNotificationName:NSPortDidBecomeInvalidNotification object:self];
}

- (bool) isValid
{
	return _isValid;
}


- (void) setDelegate:(id<NSPortDelegate>)newDel
{
	delegate = newDel;
}

- (id<NSPortDelegate>) delegate
{
	return delegate;
}

- (bool) sendBeforeDate:(NSDate *)date components:(NSArray *)comp from:(NSPort *)from reserved:(size_t)reserved
{
	return [self sendBeforeDate:date
						  msgid:0
					 components:comp
						   from:from
					   reserved:reserved];
}

- (bool) sendBeforeDate:(NSDate *)date msgid:(uint32_t)msgid components:(NSArray *)comp from:(NSPort *)from reserved:(size_t)reserved
{
	[self subclassResponsibility:_cmd];
	return false;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	NSParameterAssert([coder isKindOfClass:[NSPortCoder class]]);
	[(NSPortCoder *)coder encodePortObject:self];
}

- (id) initWithCoder:(NSCoder *)coder
{
	NSParameterAssert([coder isKindOfClass:[NSPortCoder class]]);
	return [(NSPortCoder *)coder decodePortObject];
}

- (void) removeFromRunLoop:(NSRunLoop *)loop forMode:(NSString *)mode
{
	[loop removeInputSource:self forMode:mode];
}

- (void) scheduleInRunLoop:(NSRunLoop *)loop forMode:(NSString *)mode
{
	[loop addInputSource:self forMode:mode];
}

- (void) removeConnection:(NSConnection *)conn fromRunLoop:(NSRunLoop *)loop forMode:(NSString *)mode
{
	[self removeFromRunLoop:loop forMode:mode];
}

- (void) addConnection:(NSConnection *)conn toRunLoop:(NSRunLoop *)loop forMode:(NSString *)mode
{
	[self scheduleInRunLoop:loop forMode:mode];
}

- (size_t) reservedSpaceLength
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (id) copyWithZone:(NSZone *)zone
{
	return self;
}

- (uint32_t) newConversation
{
	[self subclassResponsibility:_cmd];
	return 0;
}

@end
