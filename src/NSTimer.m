/*
 * Copyright (c) 2004-2012	Justin Hibbits
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
/*
   NSTimer.m

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Ovidiu Predescu <ovidiu@bx.logicnet.ro>

   This file is part of libFoundation.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.
 */

/* Design of timers:

   First we need to decide on something:  Are timers handled by each individual
   app (doubt it), the kernel (preferred), or a daemon (second choice)?

   The reason for not wanting each app to do it is pretty obvious: we would need
   a runloop or a dedicated thread to handle it.  By putting it into the kernel,
   it fits with the event mechanism, and a daemon would be similar to the kernel
   in that aspect.

   Rest of the design assumes an external maintainer:

   Scheduling a timer sends a message to the timer subsystem.
   At fire time, the process is sent the appropriate message to launch the
   timer.
   Descheduling/invalidating the timer sends a message to the timer subsystem.

   On LSD, there will be one timer per thread, accessed through a system call.
   On FreeBSD, this is not possible, so a trick is used whereby whichever thread
   responds to the SIGALARM will determine which thread has the timer, and
   thr_kill() the appropriate thread.

   Timers register with the thread's timer manager when they start, and
   deregister when stopped.
   
TODO:
	Flesh out timer details.
	- How many can we have?
	- How do we register?
	- Are they per-thread, or per-process?
	- Setting callbacks (event details)
 */

#import "internal.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSTimer.h>

@interface NSTimer(TimerImplementation)
- (id) initWith:(NSTimeInterval)seconds invocation:(NSInvocation*)anInvocation
    userInfo:(id)anObject repeat:(bool)_repeats;
@end

@implementation NSTimer
@synthesize isExpired;

+ (NSTimer*)scheduledTimerWithNSTimeInterval:(NSTimeInterval)seconds
    invocation:(NSInvocation*)anInvocation
    repeats:(bool)_repeats
{
	id timer = [self timerWithNSTimeInterval:seconds
		invocation:anInvocation
		repeats:_repeats];
	[timer start];
	return timer;
}

+ (NSTimer*)scheduledTimerWithNSTimeInterval:(NSTimeInterval)seconds
    target:(id)anObject
    selector:(SEL)aSelector
    userInfo:(id)anArgument
    repeats:(bool)_repeats
{
	id timer = [self timerWithNSTimeInterval:seconds
		target:anObject
		selector:aSelector
		userInfo:anArgument
		repeats:_repeats];
	[timer start];
	return timer;
}

+ (NSTimer*)timerWithNSTimeInterval:(NSTimeInterval)seconds
    invocation:(NSInvocation*)anInvocation
    repeats:(bool)_repeats
{
	id timer = [[self alloc]
			initWith:seconds invocation:anInvocation
			userInfo:nil repeat:_repeats];
	return timer;
}

+ (NSTimer*)timerWithNSTimeInterval:(NSTimeInterval)seconds
    target:(id)anObject
    selector:(SEL)aSelector
    userInfo:(id)anArgument
    repeats:(bool)_repeats
{
	return [[self alloc] initWithFireDate:nil interval:seconds target:anObject selector:aSelector userInfo:anArgument repeats:_repeats];
}

- (id) initWithFireDate:(NSDate *)date interval:(NSTimeInterval)seconds target:(id)target selector:(SEL)aSelector userInfo:(id)arg repeats:(bool)repeat
{
	id anInvocation;
	
	if (target == nil)
		anInvocation = nil;
	else
	{
		anInvocation = [[NSInvocation alloc] initWithMethodSignature:[target methodSignatureForSelector:aSelector]];
		[anInvocation setTarget:target];
		[anInvocation setSelector:aSelector];
		[anInvocation setArgument:&self atIndex:2];
	}
	self = [self initWith:seconds invocation:anInvocation userInfo:arg repeat:repeat];
	
	fireDate = date;
	return self;
}

- (void)dealloc
{
	[self invalidate];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<%@ %p fireDate: %@ selector: %@ repeats: %s isValid: %s>",
			[self className],
			self,
			fireDate,
			NSStringFromSelector([invocation selector]),
			repeats ? "true" : "false",
			isValid ? "true" : "false"];
}

- (void)fire
{
	if(isValid)
	{
		[invocation invoke];
		if(!repeats)
		{
			[self invalidate];
		}
	}
	fireDate = nil;
}

- (NSDate*)fireDate
{
	return fireDate;
}

- (NSTimeInterval) timeInterval
{
	return timeInterval;
}

- (void)invalidate
{
	if (isValid)
	{
		isValid = false;
		[[NSRunLoop currentRunLoop] removeTimer:self forMode:NSDefaultRunLoopMode];
		running = false;
	}
}

- (void)start
{
	[[NSRunLoop currentRunLoop] addTimer:self forMode:NSDefaultRunLoopMode];
}

- (id) userInfo		{ return userInfo; }
- (bool)isValid		{ return isValid; }
- (bool)repeats		{ return repeats; }
- (bool)running	{ return running; }

- (void)setRunning:(bool)run
{
	running = run;
	if (!running)
	{
		fireDate = nil;
	}
	else if (fireDate == nil)
	{
		fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:timeInterval];
	}
}

@end

/*
 * NSTimer implementation messages
 */

@implementation NSTimer(TimerImplementation)
- (id) initWith:(NSTimeInterval)seconds invocation:(NSInvocation*)anInvocation
    userInfo:(id)anObject repeat:(bool)_repeats
{
	timeInterval = seconds;
	invocation = anInvocation;
	userInfo = anObject;
	repeats = _repeats;
	isValid = true;
	running = false;
	ownerThread = [NSThread currentThread];
	return self;
}

- (NSThread *)ownerThread
{
	return ownerThread;
}

@end

/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
 */
