/* $Gold$	*/
/*
 * All rights reserved.
 * Copyright (c) 2009-2012	Justin Hibbits
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
#include <sys/event.h>
#include <sys/time.h>

#include <math.h>
#include <unistd.h>

#include <unordered_map>
#include <unordered_set>

#import <Foundation/NSArray.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSMapTable.h>
#import <Foundation/NSPort.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSTimer.h>
#include "internal.h"

#define MAX_EVENTS 100

static NSString *NSRunLoopKey = @"NSRunLoopKey";

NSMakeSymbol(NSDefaultRunLoopMode);
NSMakeSymbol(NSRunLoopCommonModes);

@implementation NSRunLoop
{
	dispatch_queue_t                    loopQueue;
	dispatch_semaphore_t                loopSem;
	dispatch_source_t                   currentDispatchObj;
	id                                  currentMode;
	std::unordered_map<NSString *, int> modes;
}

+ (id) currentRunLoop
{
	NSRunLoop *loop = [[[NSThread currentThread] threadDictionary]
		objectForKey:NSRunLoopKey];

	if (loop == nil)
	{
		loop = [NSRunLoop new];
		[[[NSThread currentThread] threadDictionary] setObject:loop
			forKey:NSRunLoopKey];

		// The loop will persist until removed from the dictionary, which won't
		// happen until the thread exits
	}

	return loop;
}

+ (NSRunLoop *) mainRunLoop
{
	return [[[NSThread mainThread] threadDictionary] objectForKey:NSRunLoopKey];
}

- (id) init
{
	return self;
}

- (void) dealloc
{
	for (auto i: modes)
	{
		close(i.second);
	}
}

- (void) addPort:(NSPort *)port forMode:(NSString *)mode
{
	[port scheduleInRunLoop:self forMode:mode];
}

- (void) removePort:(NSPort *)port forMode:(NSString *)mode
{
	[port removeFromRunLoop:self forMode:mode];
}

/*
   Design of timers in NSRunLoop:
 */
- (void) addTimer:(NSTimer *)timer forMode:(NSString *)mode
{
	TODO; // -[NSRunLoop addTimer:forMode:]
}

- (void) addEventSource:(struct kevent *)source target:(id)target
	selector:(SEL)sel modes:(NSArray *)runModes
{
	struct timespec timeout{0, 0};

	for (NSString *mode in runModes)
	{
		if (modes.find(mode) == modes.end())
		{
			modes[mode] = kqueue();
		}
		struct kevent s = *source;
		s.flags |= EV_ADD;
		kevent(modes[mode], &s, 1, NULL, 0, &timeout);
	}
}

- (void) removeEventSource:(struct kevent *)source fromModes:(NSArray *)rlModes
{
	struct timespec timeout{0, 0};

	for (id mode in rlModes)
	{
		auto i = modes.find(mode);
		if (i != modes.end())
		{
			struct kevent s = *source;
			s.flags |= EV_DELETE;
			kevent(i->second, &s, 1, NULL, 0, &timeout);
		}
	}
}

- (void) run
{
	[self runUntilDate:[NSDate distantFuture]];
}

- (void) runUntilDate:(NSDate *)date
{
	if (date == nil)
		date = [NSDate distantFuture];
	while ([self runMode:NSDefaultRunLoopMode beforeDate:date])
		;
}

- (bool) runMode:(NSString *)str beforeDate:(NSDate *)date
{
	auto i = modes.find(str);

	if (i == modes.end())
		return false;
	if ([[NSDate date] earlierDate:date] == date)
		return false;
	[self acceptInputForMode:str beforeDate:date];
	return true;
}

- (void) performSelector:(SEL)sel target:(id)target argument:(id)arg
	order:(NSUInteger)order modes:(NSArray *)modes
{
	TODO; // -[NSRunLoop performSelector:target:argument:order:modes:]
}

- (void) cancelPerformSelector:(SEL)sel target:(id)target argument:(id)arg
{
	TODO; // -[NSRunLoop cancelPerformSelector:target:argument:]
}

- (void) cancelPerformSelectorsWithTarget:(id)target
{
	TODO; // -[NSRunLoop cancelPerformSelectorsWithTarget:]
}

- (void) acceptInputForMode:(NSString *)mode beforeDate:(NSDate *)limit
{
	NSTimeInterval ti = [limit timeIntervalSinceNow];
	struct timespec ts{(time_t)ti,
		static_cast<long>((ti - (long)ti) * 100000000000ULL)};
	// First suspend the currently running mode, then resume the new one.  This
	// way if inputs are in both modes, they will stick around.
	auto i = modes.find(mode);
	struct kevent events[MAX_EVENTS];
	if (i == modes.end())
		return;

	currentMode = mode;
	int count = kevent(i->second, NULL, 0, events, MAX_EVENTS, &ts);

	for (; count > 0; --count)
	{
	}
}

- (NSDate *) limitDateForMode:(NSString *)mode
{
	TODO; // limitDateForMode:
	return [NSDate distantFuture];
}

- (NSString *) currentMode
{
	return currentMode;
}
@end

@implementation NSObject(RunLoopAdditions)
+ (void) cancelPreviousPerformRequestsWithTarget:(id)target
{
	TODO; // -[NSObject(RunLoopAdditions) cancelPreviousPerformRequestsWithTarget:]
}

+ (void) cancelPreviousPerformRequestsWithTarget:(id)target selector:(SEL)sel object:(id)arg
{
	TODO; // -[NSObject(RunLoopAdditions) cancelPreviousPerformRequestsWithTarget:selector:object:]
}

- (void) performSelector:(SEL)sel withObject:(id)obj afterDelay:(NSTimeInterval)delay
{
	[self performSelector:sel withObject:obj afterDelay:delay
		inModes:@[NSDefaultRunLoopMode]];
}

- (void) performSelector:(SEL)sel withObject:(id)obj afterDelay:(NSTimeInterval)delay inModes:(NSArray *)modes
{
	NSTimer *t;
	NSRunLoop *loop = [NSRunLoop currentRunLoop];

	t = [NSTimer timerWithTimeInterval:delay target:self 
		selector:sel userInfo:obj repeats:false];
	for (id mode in modes)
	{
		[loop addTimer:t forMode:mode];
	}
}

@end
