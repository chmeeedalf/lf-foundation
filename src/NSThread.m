/*
 * Copyright (c) 2005-2012	Justin Hibbits
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

#include <dlfcn.h>
#include <execinfo.h>
#import "internal.h"
#import <Foundation/NSApplication.h>
#import <Foundation/NSArray.h>
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

	Need to check ARC ownership on this.  Ownership should transfer at thread spawn.
	The NSThread class currently is not implemented properly and should be
	rewritten.  All member data should be created at instantiation time, rather
	than launch time, to ease the ownership rights confusion.
 */

#define NANOSECONDS	1000000000UL

/* NSThread notifications */
NSString* NSThreadWillExitNotification = @"NSThreadWillExitNotification";

/* Global thread variables */
static pthread_key_t curThreadKey;

static NSThread *mainThread;

@interface NSApplication (private)
- (void) removeThread:(NSThread *)thrID;
@end

@interface NSThread(private)
- (void) __startThread;
@end

@interface _NSTargetedThread	:	NSThread
{
	SEL selector;
	id target;
}
@end

@implementation NSThread

@synthesize name;

void *runThread(void *thread)
{
	NSThread *thr = (__bridge NSThread *)thread;

	[thr __startThread];
	return (__bridge void *)thr;
}

static void cleanupThread(void *thrId)
{
	NSThread *thr = (__bridge NSThread *)thrId;

	[thr exit];
}

+ (void) initialize
{
	static bool initialized = false;

	if (!initialized)
	{
		pthread_key_create(&curThreadKey, cleanupThread);
		initialized = true;
	}
}

- (void) __startThread
{
	__sync_fetch_and_add(&numThreads, 1);
	if (base == NULL)
		base = pthread_self();
	pthread_setspecific(curThreadKey, (__bridge void *)self);
	if (pthread_main_np() == 1)
		mainThread = self;
	isRunning = true;
	@autoreleasepool {
		[App addThread:self];
		[self main];
	}
}

+ (void) detachNewThreadSelector:(SEL)aSel toTarget:(id)target withObject:(id)arg
{
	NSThread *thread = [[NSThread alloc] initWithTarget:target selector:aSel object:arg];
	[thread start];
	[thread detach];
}

/*
 * Instance Methods
 */

- (id) init
{
	// Not yet running
	isRunning = false;

	privateThreadData = [NSMutableDictionary new];
	self.name = NSStringFromClass([self class]);
	return self;
}

- (id) initWithTarget:(id)target selector:(SEL)sel object:(id)argument
{
	return [[_NSTargetedThread alloc] initWithTarget:target selector:sel object:argument];
}

- (id) initWithObject:(id)anArgument
{
	self = [self init];

	// Set running parameters
	arg = anArgument;
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

+ (bool) isMainThread
{
	return (pthread_main_np() == 1);
}

- (bool) isMainThread
{
	return (self == mainThread);
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
	pthread_create(&self->base, NULL, runThread, (__bridge void *)self);
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

	if (self != [NSThread currentThread])
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

- (NSMutableDictionary *) threadDictionary
{
	return privateThreadData;
}

- (void)dealloc
{
	if (isRunning)
	{
		@throw [NSInvalidUseOfMethodException
			exceptionWithReason:@"cannot deallocate NSThread object for a running thread"
			userInfo:nil];
	}
}

/*
 * Class Methods
 */

+ (NSThread*)currentThread
{
	return (__bridge NSThread *)pthread_getspecific(curThreadKey);
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

- (void) setName:(NSString *)newName
{
	pthread_set_name_np(base, [newName UTF8String]);
	name = newName;
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

@implementation _NSTargetedThread
- (id) initWithTarget:(id)targ selector:(SEL)sel object:(id)argument
{
	if ((self = [super init]) != NULL)
	{
		target = targ;
		selector = sel;
		arg = argument;
	}
	return self;
}

- (void) main
{
	[target performSelector:selector withObject:arg];
}

@end
