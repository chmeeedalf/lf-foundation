/*
 * Copyright (c) 2005-2006	Gold Project
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

#include <dlfcn.h>
#include <execinfo.h>
#import "internal.h"
#import <Foundation/NSApplication.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSValue.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <pthread.h>
#include <pthread_np.h>
#include <objc/objc-arc.h>

/*
	XXX: REWRITE This.

	The NSThread class currently is not implemented properly and should be
	rewritten.  All member data should be created at instantiation time, rather
	than launch time, to ease the ownership rights confusion.  NSAutoreleasePool
	should probably also be fixed to support creating for another thread.
 */

#define NANOSECONDS	1000000000UL

/* NSThread notifications */
NSString* NSThreadWillExitNotification = @"NSThreadWillExitNotification";

/* Global thread variables */
__thread id currentThread __private = nil;
static NSThread *mainThread;

@interface NSApplication (private)
- (void) removeThread:(NSThread *)thrID;
@end

@interface NSThread(private)
- (void) __startThread;
@end

@implementation NSThread

@synthesize name;

void *runThread(void *thread)
{
	NSThread *thr = thread;

	[thr __startThread];
	return thr;
}

static void cleanupThread(void *thrId)
{
	NSThread *thr = thrId;

	[thr exit];
}

- (void) __startThread
{
	__sync_fetch_and_add(&numThreads, 1);
	pthread_cleanup_push(cleanupThread, self);
	if (base == NULL)
		base = pthread_self();
	currentThread = self;
	if (pthread_main_np() == 1)
		mainThread = self;
	isRunning = true;
	objc_autoreleasePoolPush();
	[App addThread:self];
	[self main];
	pthread_cleanup_pop(1);
}

/*
 * Instance Methods
 */

- init
{
	// Not yet running
	isRunning = false;

	privateThreadData = [NSMutableDictionary new];
	self.name = NSStringFromClass([self class]);
	return self;
}

- initWithObject:(id)anArgument
{
	self = [self init];

	// NSSet running parameters
	arg = RETAIN(anArgument);
	return self;
}

+ (NSArray *)callStackReturnAddresses
{
	NSMutableArray *addrs = [NSMutableArray array];
	void *btrace[100];

	int count = backtrace(btrace, sizeof(btrace)/sizeof(btrace[0]));
	for (int i = 0; i < count; i++)
	{
		[addrs addObject:[NSNumber numberWithUnsignedInteger:(NSUInteger)(uintptr_t)btrace[i]]];
	}
	return addrs;
}

+ (NSArray *)callStackSymbols
{
	void *btrace[100];
	NSMutableArray *symbols = [NSMutableArray array];

	int count = backtrace(btrace, sizeof(btrace)/sizeof(btrace[0]));
	char **traces = backtrace_symbols(btrace, count);

	for (int i = 0; i < count; i++)
	{
		[symbols addObject:[NSString stringWithUTF8String:traces[i]]];
	}

	return symbols;
}

// Do nothing
- (void) main
{
	[self subclassResponsibility:_cmd];
}

- (void) start
{
	NSAssert(!isRunning, @"NSThread is already running");
	NSAssert(!isFinished, @"Attempted to start a finished thread.");
	NSAssert(!canceled, @"Attempted to start a cancelled thread.");
	//spawn(self);
	pthread_create(&self->base, NULL, runThread, self);
}

- (void)exit
{
	// If we're already not running, don't do anything
	// This also prevents double-exit, such as when a user calls [thr exit],
	// since it's called upon pthread termination as well.
	if (!isRunning)
		return;

	isRunning = false;
	isFinished = true;

	if (self != currentThread)
	{
		NSLog(@"Sending exit message to another thread.");
		return;
	}

	[[NSNotificationCenter defaultCenter]
		postNotificationName:NSThreadWillExitNotification
		object:self];

	[App removeThread:self];
	__sync_fetch_and_add(&numThreads, -1);
	terminate();
}

- (void) setPrivateThreadData:(id)data forKey:(id)key
{
	if (data == nil)
	{
		[privateThreadData removeObjectForKey:key];
	}
	else
	{
		[privateThreadData setObject:data forKey:key];
	}
}

- (id) privateThreadDataForKey:(id)key
{
	return [privateThreadData objectForKey:key];
}

- (void)dealloc
{
	if (isRunning)
	{
		@throw [NSInvalidUseOfMethodException
			exceptionWithReason:@"cannot deallocate NSThread object for a running thread"
			userInfo:nil];
	}

	[privateThreadData release];
	RELEASE(arg);
	[super dealloc];
}

/*
 * Class Methods
 */

+ (NSThread*)currentThread
{
	return currentThread;
}

+ (NSThread *)mainThread
{
	return mainThread;
}

+ (void)sleepUntilDate:(NSDate*)aDate
{
	[self sleepForTimeInterval:[aDate timeIntervalSinceNow]];
}

+ (void) sleepForTimeInterval:(NSTimeInterval)interval
{
	struct timespec spec;
	double fspec;

	spec.tv_nsec = (modf(interval, &fspec) * NANOSECONDS);
	spec.tv_sec = (time_t)fspec;
	while (nanosleep(&spec, &spec) < 0)
		;	/* Empty */
}

- (pthread_t) _pthreadId
{
	return base;
}

- (bool)isExecuting
{
	return isRunning;
}

- (void) setStackSize:(size_t)size
{
	NSAssert(!isRunning, @"Cannot set the stack size while running.");

	pthread_attr_setstacksize(&attrs, size);
}

- (size_t) stackSize
{
	size_t ret;

	pthread_attr_getstacksize(&attrs, &ret);
	return ret;
}

- (void) setThreadPriority:(double)prio
{
	int prio_min = sched_get_priority_min(SCHED_OTHER);
	int prio_max = sched_get_priority_max(SCHED_OTHER);
	int real_prio = (prio_max - prio_min) * prio;
	struct sched_param params = { .sched_priority = real_prio };

	pthread_attr_setschedparam(&attrs, &params);
}

- (double) threadPriority
{
	int prio_min = sched_get_priority_min(SCHED_OTHER);
	int prio_max = sched_get_priority_max(SCHED_OTHER);
	struct sched_param params;

	pthread_attr_getschedparam(&attrs, &params);

	return (double)params.sched_priority / (prio_max - prio_min);
}

+ (double) threadPriority
{
	return [[NSThread currentThread] threadPriority];
}

+ (void) setThreadPriority:(double)prio
{
	[[NSThread currentThread] setThreadPriority:prio];
}

- (void) cancel
{
	canceled = true;
}

- (bool) isCancelled
{
	return canceled;
}

- (bool) isFinished
{
	return isFinished;
}

- (void) detach
{
	pthread_detach(base);
}

@end /* NSThread */
