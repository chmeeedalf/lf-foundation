/*
 * Copyright (c) 2004,2005	Justin Hibbits
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

#include <sys/types.h>
#include <pthread.h>

#import <Foundation/NSDate.h>
#import <Foundation/NSObject.h>

@class NSDate;
@class NSString;
@class NotificationCenter;
@class NSMutableDictionary;

/*!
 * \file NSThread.h
 */

/*!
 \enum ThreadPriority
 \brief NSThread priorities.
 */
typedef enum {
	NSInteractiveThreadPriority,
	NSBackgroundThreadPriority,
	NSLowThreadPriority
} NSThreadPriority;

/*!
 * \brief Notification posted to the NotificationCenter when the thread is
 * exiting.
 */
SYSTEM_EXPORT NSString *NSThreadWillExitNotification;

/* This exists mostly to be a class property. */
@protocol NSLaunchableThread
@end

/*!
 \class NSThread
 \brief Execution thread.
 */
@interface NSThread	: NSObject
{
	/* @{ */
	bool			 isRunning;	/*!< \brief Whether or not the thread is running. */
	bool			 isFinished;	/*!< \brief Whether or not the thread completed. */
	bool			 canceled;	/*!< \brief Whether or not the thread has been canceled. */
	void			*reserved;	/* Scratch space for thread data */
	pthread_t		 base;		/*!< \brief The thread backend. */
	pthread_attr_t	 attrs;
	id				 arg;		/*!< \brief NSThread specific argument. */
	NSMutableDictionary		*privateThreadData;	/*!< \brief Private thread data that can't be managed simply with the TLS block. */
	NSString			*name;
	/* @} */
}
@property(nonatomic,copy) NSString *name;
@property double threadPriority;
@property size_t stackSize;

/*!
 * \brief Initialize the thread data.  This is the designated initializer.
 * Every subclass must call this if it implements an init method.
 */
- (id) init;

/*!
 * \brief Initialize the thread with a target object.
 * \param obj "Argument" object to pass to the thread.
 */
- (id) initWithObject:(id)obj;
- (id) initWithTarget:(id)target selector:(SEL)selector object:(id)argument;

+ (void) detachNewThreadSelector:(SEL)aSel toTarget:(id)target withObject:(id)arg;

/*!
 * \brief Main thread routine.
 *
 * \details Subclasses should implement this method in order for it to do any
 * real work.
 */
- (void) main;

/*!
 * \brief Spawn and run this thread.
 */
- (void) start;

/*!
 * \brief Returns an indicator of whether the receiver is currently executing.
 */
- (bool) isExecuting;

- (bool) isFinished;

- (bool) isCancelled;

/*!
 * \brief Detach the receiving thread.  When terminated it will clean up its
 * resources automatically.
 */
- (void) detach;

/*!
 \brief Has the receiver sleep until the specified time.
 \param date NSDate to wakeup.
 No input or timers will be processed in this interval.
 */
+ (void) sleepUntilDate:(NSDate *)date;

/*!
 * \brief Sleep for the specified time interval.
 */
+ (void) sleepForTimeInterval:(NSTimeInterval)ti;

/*!
 \brief Terminates the receiving thread.
 Before exiting the thread, this method posts the
 ThreadExitingNotification with the thread being exited to the default
 notification center.
 */
- (void) exit;

- (void) cancel;

/*!
 \brief Returns an object representing the current thread.
 */
+ (NSThread *) currentThread;
+ (NSArray *) callStackReturnAddresses;
+ (NSArray *) callStackSymbols;

+ (void) setThreadPriority:(double)newPrio;
+ (double) threadPriority;

+ (NSThread *) mainThread;
+ (bool) isMainThread;
- (bool) isMainThread;

/* \functiongroup Getting thread data */

- (NSMutableDictionary *)threadDictionary;

@end

@interface NSObject (Threading)
- (void)performSelectorInBackground:(SEL)aSelector withObject:(id)arg;
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(bool)wait;
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(bool)wait modes:(NSArray *)array;
- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(bool)wait;
- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(bool)wait modes:(NSArray *)array;
@end

/*
   vim:syntax=objc:
 */
