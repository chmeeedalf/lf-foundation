/*
 * Copyright (c) 2004-2012	Gold Project
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
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR COEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSDate.h>

@class NSInvocation, NSDate, NSRunLoop, NSThread;

/*!
 * \brief NSTimer object.
 */
@interface NSTimer	: NSObject
{
	/* @{ Shouldn't be needed.*/
	NSDate *fireDate;
	NSInvocation *invocation;
	NSThread *ownerThread;
	id userInfo;
	NSTimeInterval timeInterval;
	bool repeats;
	bool isValid;
	bool running;
	bool isExpired;
	NSRunLoop *runLoop;
	/*! @} */
}
@property bool isExpired;
@property(readonly) NSTimeInterval timeInterval;

// Creating a timer object
/*!
 * \brief Returns a new NSTimer object and registers it with the current RunLoop in the default mode.
 * \param seconds Timeout for timer.
 * \param anInvocation Invocation message to send when fired.
 * \param repeats If true, the timer will repeatedly reschedule itself.
 */
+(NSTimer *)scheduledTimerWithNSTimeInterval:(NSTimeInterval)seconds
	invocation:(NSInvocation *)anInvocation repeats:(bool)repeats;

/*!
 * \brief Returns a new NSTimer object and registers it with the current RunLoop in the default mode.
 * \param seconds Timeout for timer.
 * \param anObject Target object.
 * \param aSelector Selector message to send when fired.
 * \param anArgument Extra data to provide the target object on request.
 * \param repeats If true, the timer will repeatedly reschedule itself.
 */
+(NSTimer *)scheduledTimerWithNSTimeInterval:(NSTimeInterval)seconds
	target:(id)anObject selector:(SEL)aSelector
	userInfo:(id) anArgument repeats:(bool)repeats;

/*!
 * \brief Returns a new NSTimer object.
 * \param seconds Timeout for timer.
 * \param anInvocation Invocation message to send when fired.
 * \param repeats If true, the timer will repeatedly reschedule itself.
 */
+(NSTimer *)timerWithNSTimeInterval:(NSTimeInterval)seconds
	invocation:(NSInvocation *)anInvocation repeats:(bool)repeats;

/*!
 * \brief Returns a new NSTimer object.
 * \param seconds Timeout for timer.
 * \param anObject Target object.
 * \param aSelector Selector message to send when fired.
 * \param anArgument Extra data to provide the target object on request.
 * \param repeats If true, the timer will repeatedly reschedule itself.
 */
+(NSTimer *)timerWithNSTimeInterval:(NSTimeInterval)seconds
	target:(id)anObject selector:(SEL)aSelector
	userInfo:(id) anArgument repeats:(bool)repeats;

/*!
 * \brief TODO
 */
- (id) initWithFireDate:(NSDate *)date interval:(NSTimeInterval)seconds target:(id)target selector:(SEL)aSelector userInfo:(id)arg repeats:(bool)repeats;

// Firing the timer
/*!
 * \brief Causes the NSTimer's message to be dispatched to its target.
 */
-(void)fire;

// Stopping the timer
/*!
 * \brief Stops the NSTimer from ever firing again.
 */
-(void)invalidate;

// Getting information about the NSTimer
/*!
 * \brief Returns the date that the NSTimer will next fire.
 */
-(NSDate *)fireDate;

/*!
 * \brief Returns \c true if the receiver is currently valid, \c false otherwise.
 */
-(bool)isValid;

/*!
 * \brief Returns true if this timer repeats, false otherwise.
 */
-(bool)repeats;

/*!
 * \brief Returns \c true if this timer is currently running, \c false otherwise.
 */
-(bool)running;

/*!
 * \brief Returns the addictional data that the object receiving the timer's message can use.
 */
-(id)userInfo;

/*!
  \brief Starts the timer.
  Registers and starts the timer.
 */
-(void)start;
@end

/*
   vim:syntax=objc:
 */
