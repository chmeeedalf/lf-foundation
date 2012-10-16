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
#include <sys/timex.h>	// for NANOSECOND

#include <math.h>
#include <unistd.h>

#include <algorithm>
#include <map>
#include <unordered_map>
#include <unordered_set>

#import <Foundation/NSArray.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSInvocation.h>
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

typedef std::multimap<NSUInteger,NSInvocation *> performMap;

struct _NSRunLoopMode {
	NSMutableArray *timers;
	performMap performers;
	int queue = kqueue();
};

@implementation NSRunLoop
{
	dispatch_queue_t                    loopQueue;
	dispatch_semaphore_t                loopSem;
	dispatch_source_t                   currentDispatchObj;
	id                                  currentMode;
	std::unordered_map<NSString *, _NSRunLoopMode> modes;
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
		close(i.second.queue);
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
	/* Don't add an invalidated timer */
	if (![timer isValid])
		return;

	if (modes[mode].timers == nil)
		modes[mode].timers = [NSMutableArray array];
	[modes[mode].timers addObject:timer];
}

- (void) addEventSource:(struct kevent *)source
	target:(id<_NSRunLoopEventSource>)target
	modes:(NSArray *)runModes
{
	struct timespec timeout{0, 0};

	// The target is weakly held
	source->udata = (__bridge void *)target;

	for (NSString *mode in runModes)
	{
		struct kevent s = *source;
		s.flags |= EV_ADD;
		kevent(modes[mode].queue, &s, 1, NULL, 0, &timeout);
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
			kevent(i->second.queue, &s, 1, NULL, 0, &timeout);
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
	order:(NSUInteger)order modes:(NSArray *)perfModes
{
	for (NSString *perfMode in perfModes)
	{
		NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[target
			methodSignatureForSelector:sel]];
		[inv setTarget:target];
		[inv setSelector:sel];
		[inv setArgument:&arg atIndex:2];
		modes[perfMode].performers.insert(std::make_pair(order, inv));
	}
}

- (void) cancelPerformSelector:(SEL)sel target:(id)target argument:(id)arg
{
	for (auto mode : modes)
	{
		auto &m = mode.second.performers;
		for (auto i = m.begin(); i != m.end();)
		{
			id invarg;
			if (([i->second target] == target) &&
					([i->second selector] == sel) &&
					(([i->second getArgument:&invarg atIndex:2],invarg) == arg)
			   )
				m.erase(i++);
			else
				i++;
		}
	}
}

- (void) cancelPerformSelectorsWithTarget:(id)target
{
	for (auto mode : modes)
	{
		auto &m = mode.second.performers;
		for (auto i = m.begin(); i != m.end();)
		{
			if ([i->second target] == target)
				m.erase(i++);
			else
				i++;
		}
	}
}

- (void) acceptInputForMode:(NSString *)mode beforeDate:(NSDate *)limit
{
	auto i = modes.find(mode);
	if (i == modes.end())
		return;

	struct kevent events[MAX_EVENTS];
	currentMode = mode;

	while ([limit earlierDate:[NSDate date]] != limit)
	{
		NSDate *d = [limit earlierDate:[self limitDateForMode:mode]];
		NSTimeInterval ti = [d timeIntervalSinceNow];
		struct timespec ts{(time_t)ti,
			static_cast<long>((ti - (long)ti) * NANOSECOND)};
		int count = kevent(i->second.queue, NULL, 0, events, MAX_EVENTS, &ts);

		if (count > 0)
		{
			for (; count > 0; --count)
			{
				struct kevent *ev = &events[count];
				[(__bridge id<_NSRunLoopEventSource>)ev handleEvent:ev];
			}
			break;
		}
		__block NSMutableArray *a = nil;
		[i->second.timers enumerateObjectsUsingBlock:
			^(id obj, NSUInteger idx, bool *stop){
				if (![obj isValid])
				{
					if (a == nil)
						a = [NSMutableArray array];
					[a addObject:obj];
				}
				if ([[NSDate date] compare:[obj fireDate]] != NSOrderedAscending)
				{
					[obj fire];
				}
			}];
		[i->second.timers removeObjectsInArray:a];
	}
	performMap map = i->second.performers;
	i->second.performers.clear();

	for (auto j : map)
	{
		[j.second invoke];
	}
}

- (NSDate *) limitDateForMode:(NSString *)mode
{
	__block NSDate *limitDate = [NSDate date];

	[modes[mode].timers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,
			bool *stop){
		NSDate *itsLimit = [obj fireDate];
		if ([limitDate compare:itsLimit] == NSOrderedDescending)
			limitDate = itsLimit;
	}];
	return limitDate;
}

- (NSString *) currentMode
{
	return currentMode;
}
@end

@interface _NSObjectRunLoopLink : NSObject
{
	@package
	NSTimer *timer;
	NSInvocation *inv;
}
@end
@implementation _NSObjectRunLoopLink
-(void) dealloc
{
	[timer invalidate];
}
@end

@implementation NSObject(RunLoopAdditions)
static char runLoopRequestKey = 'R';

+ (void) cancelPreviousPerformRequestsWithTarget:(id)target
{
	objc_setAssociatedObject(target, &runLoopRequestKey, nil,
			OBJC_ASSOCIATION_RETAIN);
}

+ (void) cancelPreviousPerformRequestsWithTarget:(id)target selector:(SEL)sel object:(id)arg
{
	NSMutableArray *links = objc_getAssociatedObject(target, &runLoopRequestKey);
	NSMutableArray *toDestroy = [NSMutableArray array];
	for (_NSObjectRunLoopLink *link in links)
	{
		if ([link->inv selector] == sel)
		{
			id obj;
			[link->inv getArgument:&obj atIndex:2];
			if (obj == arg)
			{
				[toDestroy addObject:link];
			}
		}
	}
	[links removeObjectsInArray:toDestroy];
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
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self
		methodSignatureForSelector:sel]];

	[inv setSelector:sel];
	[inv setTarget:self];
	[inv setArgument:&obj atIndex:2];

	t = [NSTimer timerWithTimeInterval:delay invocation:inv repeats:false];
	for (id mode in modes)
	{
		[loop addTimer:t forMode:mode];
	}
	_NSObjectRunLoopLink *link = [_NSObjectRunLoopLink new];
	link->inv = inv;
	link->timer = t;

	NSMutableArray *links = objc_getAssociatedObject(self, &runLoopRequestKey);
	if (links == nil)
	{
		links = [NSMutableArray array];
		objc_setAssociatedObject(self, &runLoopRequestKey, links,
				OBJC_ASSOCIATION_RETAIN);
	}
	[links addObject:link];
}

@end
