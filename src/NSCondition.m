/*
 * Copyright (c) 2009	Gold Project
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

#include <math.h>
#include <pthread.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSObject.h>

@implementation NSCondition
@synthesize name;

- (id) init
{
	pthread_cond_init(&condition, NULL);
	pthread_mutex_init(&mutex, NULL);
	return self;
}

- (void) dealloc
{
	self.name = nil;
	pthread_cond_destroy(&condition);
	pthread_mutex_destroy(&mutex);
	[super dealloc];
}

- (void) wait
{
	pthread_cond_wait(&condition, &mutex);
}

- (bool) waitUntilDate:(NSDate *)date
{
	struct timespec spec;
	TimeInterval ti = [date timeIntervalSinceNow];
	spec.tv_sec = trunc(ti);
	spec.tv_nsec = trunc(fmod(ti, 1) * 1000000000);
	return (pthread_cond_timedwait(&condition, &mutex, &spec) == 0);
}

- (void) signal
{
	pthread_cond_signal(&condition);
}
- (void) broadcast
{
	pthread_cond_broadcast(&condition);
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

/*
   vim:syntax=objc:
 */
