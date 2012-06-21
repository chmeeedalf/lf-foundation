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

#include <pthread.h>

#import <Foundation/NSLock.h>
#import <Foundation/NSDictionary.h>
#import "internal.h"

@implementation NSConditionLock
{
	NSString *name;
	pthread_mutex_t mutex;
	bool isLocked;
	volatile NSInteger currentCond;
}
@synthesize name;

// Initializing an NSConditionLock
-(id)initWithCondition:(NSInteger)condition
{
	pthread_mutex_init(&mutex, NULL);
	currentCond = condition;
	return self;
}

- (void)dealloc
{
	pthread_mutex_destroy(&mutex);
}


// Returning the condition
-(NSInteger)condition
{
	return currentCond;
}


// Acquiring and releasing a lock
-(void)lockWhenCondition:(NSInteger)condition
{
	do {
		[self lock];
		if (currentCond == condition)
			break;
		[self unlock];
	} while (1);
}

-(void)unlockWithCondition:(NSInteger)condition
{
	NSInteger oldCond = currentCond;
	currentCond = condition;
	if (pthread_mutex_unlock(&mutex) < 0)
	{
		NSDictionary *info;
		currentCond = oldCond;
		if ([self name] != nil)
			info = @{@"Name": [self name]};
		else
			info = nil;
		@throw [NSInvalidUseOfMethodException exceptionWithReason:
			@"attempt to unlock a lock not owned by the current thread"
			userInfo:info];
	}
	isLocked = false;
}


- (bool) lockBeforeDate:(NSDate *)lockDate
{
	struct timespec spec;
	NSTimeInterval ti = [lockDate timeIntervalSinceNow];
	spec.tv_sec = trunc(ti);
	spec.tv_nsec = trunc(fmod(ti, 1) * 1000000000);
	return (pthread_mutex_timedlock(&mutex, &spec) == 0);
}

- (bool) lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)lockDate
{
	do {
		[self lockBeforeDate:lockDate];
		if (currentCond == condition)
			return true;
		[self unlock];
	} while (1);
	return false;
}

-(bool)tryLock
{
	if (pthread_mutex_trylock(&mutex) == 0)
	{
		isLocked = true;
		return true;
	}
	return false;
}

-(bool)tryLockWhenCondition:(NSInteger)condition
{
	return [self lockWhenCondition:condition beforeDate:[NSDate date]];
}

- (void) lock
{
	pthread_mutex_lock(&mutex);
}

- (void) unlock
{
	pthread_mutex_unlock(&mutex);
}

@end
