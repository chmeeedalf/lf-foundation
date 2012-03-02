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
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */

#include <math.h>
#import <Foundation/NSLock.h>

#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>

/*
   NSLock - lock of unlimited (MAX_INT) depth

   In Gold all locks are recursive.
 */

/* Brain dump:
 *
 * There can be a type of locking mechanism called a 'queued lock'.  This allows
 * a thread to be reentrant for signals (interrupted), while allowing
 * pseudo-recursive locking semantics.  If a thread takes a lock, and is
 * interrupted by a signal (expired timer, etc), the interrupt can be queued to
 * execute when the critical section is released if the interrupt attempts to
 * take the lock.  This should prevent deadlock occurrances, and using an
 * alternate stack should allow us to keep multiple yields in-flight if needed.
 */

@implementation NSLock

@synthesize name;

- (id) init
{
	pthread_mutexattr_t attr;
	pthread_mutexattr_init(&attr);
	pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
	pthread_mutex_init(&mutex, &attr);
	return self;
}

- (void)dealloc
{
	pthread_mutex_destroy(&mutex);
}

- (void)lock
{
	if (pthread_mutex_lock(&mutex) < 0)
	{
		NSDictionary *info;
		if ([self name] != nil)
			info = [NSDictionary dictionaryWithObjectsAndKeys:[self name],@"Name",nil];
		else
			info = nil;
		@throw [NSInvalidUseOfMethodException
			exceptionWithReason: @"attempt to lock an invalid lock" userInfo:info];
	}
	isLocked = true;
}

- (bool)tryLock
{
	if (pthread_mutex_trylock(&mutex) == 0)
	{
		isLocked = true;
		return true;
	}
	return false;
}

- (bool)lockBeforeDate:(NSDate *)limit
{
	struct timespec spec;
	NSTimeInterval ti = [limit timeIntervalSinceNow];
	spec.tv_sec = trunc(ti);
	spec.tv_nsec = trunc(fmod(ti, 1) * 1000000000);
	return (pthread_mutex_timedlock(&mutex, &spec) == 0);
}

- (void)unlock
{
	if (pthread_mutex_unlock(&mutex) < 0)
	{
		NSDictionary *info;
		if ([self name] != nil)
			info = [NSDictionary dictionaryWithObjectsAndKeys:[self name],@"Name",nil];
		else
			info = nil;
		@throw [NSInvalidUseOfMethodException exceptionWithReason:
			@"attempt to unlock a lock not owned by the current thread"
			userInfo:info];
	}
	isLocked = false;
}

- (bool) isLocked
{
	return isLocked;
}

@end /* NSLock:NSObject */
