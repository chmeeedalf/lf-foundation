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

#import <Alepha/Objective/Object.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSMapTable.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSTimer.h>
#include <Alepha/Atomic/primitive.h>
#include <unordered_map>
#include "internal.h"
#include <atomic>

static NSString *NSRunLoopKey = @"NSRunLoopKey";

namespace {
typedef Singleton<std::unordered_map<id,NSUInteger>> modes;
template<> modes::type modes::value = modes::type();
}

static std::atomic<NSUInteger> max_mode(0);
//static Alepha::Atomic::atomic<NSUInteger> max_mode(0);

NSMakeSymbol(NSDefaultRunLoopMode);
NSMakeSymbol(NSRunLoopCommonModes);

extern "C" id objc_msgSend(id,SEL,...);

namespace 
{
	namespace ObjC_RunLoop
	{
		class Delegate	:	public Alepha::RunLoop::Delegate
		{
			private:
				Alepha::Objective::Object<id> target;
				SEL sel;
				Alepha::RunLoop::Source *source;
			public:
				Delegate() {}
				Delegate(id t, SEL s, Alepha::RunLoop::Source *src) :
					target(t), sel(s), source(src)
				{
					source->setDelegate(this);
				}
				~Delegate()
				{
					delete source;
				}
				void perform(Alepha::RunLoop::Source *s, uint32_t flags, intptr_t data)
				{
//					objc_msgSend(target, sel, flags, data);
				}
				Alepha::RunLoop::Source *getSource(void) const
				{
					return source;
				}
		};
	}
}

/* We use associated objects, a'la OS X 10.6, to remove sources when the
 * delegate is destroyed.
 */
@interface _RunLoopSource : NSObject
{
	@public
		ObjC_RunLoop::Delegate d;
}
@end

@implementation _RunLoopSource
- (id) initWithTarget:(id)t selector:(SEL)selector
	source:(Alepha::RunLoop::Source *)source
{
	new (&d) ObjC_RunLoop::Delegate(t, selector, source);
	return self;
}

@end

@implementation NSRunLoop
{
	@private
		ARunLoop *rl;
		volatile bool	isCanceled;
		volatile bool	isTerminated;
		int		kernelQueue;	/* kqueue ID. */
		id		currentMode;
}

/* Since this is thread-local, making it unsafe-unretained is safe. */
static __unsafe_unretained __thread NSRunLoop *threadRunLoop = nil;

static uint32_t ModeIndexFromString(NSString *mode)
{
	modes m;
	if (m->find(mode) == m->end())
	{
		(*m)[mode] = ++max_mode;
	}
	return (*m)[mode];
}

+ (void) initialize
{
	static bool initialized = false;

	if (!initialized)
	{
		ModeIndexFromString(NSDefaultRunLoopMode);
	}
}

+ (id) currentRunLoop
{
	NSRunLoop *loop = threadRunLoop;

	if (threadRunLoop == nil)
	{
		loop = [NSRunLoop new];
		[[NSThread currentThread] setPrivateThreadData:threadRunLoop
			forKey:NSRunLoopKey];

		// The loop will persist until removed from the dictionary, which won't
		// happen until the thread exits
		threadRunLoop = loop;
	}

	return threadRunLoop;
}

+ (NSRunLoop *) mainRunLoop
{
	return [[NSThread mainThread] privateThreadDataForKey:NSRunLoopKey];
}

- (id) init
{
	rl = new ARunLoop;
	return self;
}

- (void) dealloc
{
	delete rl;
}

- (void) addInputSource:(NSObject<NSEventSource> *)obj forMode:(NSString *)mode
{
	uintptr_t desc = [obj descriptor];
	switch ([obj sourceType])
	{
		case NSDescriptorEventSource:
			[self addRunLoopSource:(new Alepha::RunLoop::File(desc)) target:obj
				selector:@selector(handleEvent:data:) mode:mode];
			break;
		case NSProcessEventSource:
			[self addRunLoopSource:(new Alepha::RunLoop::Process(desc)) target:obj
				selector:@selector(handleEvent:data:) mode:mode];
			break;
		case NSSignalEventSource:
			[self addRunLoopSource:(new Alepha::RunLoop::Signal(desc)) target:obj
				selector:@selector(handleEvent:data:) mode:mode];
			break;
		case NSUserEventSource:
			[self addRunLoopSource:(new Alepha::RunLoop::File(desc)) target:obj
				selector:@selector(handleEvent:data:) mode:mode];
			break;
		default:
			break;
	}
}

- (void) removeInputSource:(NSObject<NSEventSource> *)obj forMode:(NSString *)mode
{
	[self removeRunLoopTarget:obj mode:mode];
}

- (void) addTimer:(NSTimer *)timer forMode:(NSString *)mode
{
	Alepha::RunLoop::Timer *t = new Alepha::RunLoop::Timer([timer
			timeInterval]);
	[self addRunLoopSource:t target:timer selector:@selector(fire) mode:mode];
}

- (void) removeTimer:(NSTimer *)timer forMode:(NSString *)mode
{
	[self removeRunLoopTarget:timer mode:mode];
}

- (void) run
{
	[self runUntilDate:[NSDate distantFuture]];
}

- (void) runUntilDate:(NSDate *)date
{
	if (date == nil)
		date = [NSDate distantFuture];
	while (!isCanceled)
	{
		[self runMode:NSDefaultRunLoopMode beforeDate:date];
		if ([date timeIntervalSinceNow] <= 0)
			break;
		if (isTerminated)
			break;
	}
}

- (void) runMode:(NSString *)str beforeDate:(NSDate *)date
{
	NSTimeInterval ti;
	@autoreleasepool {
		ti = [date timeIntervalSinceNow];

		currentMode = str;
		rl->run_once(ti, ModeIndexFromString(str));
	}
}

/* End the loop at the end of event processing. */
- (void) exit
{
	rl->cancel();
	isCanceled = true;
}

- (bool) isCanceled
{
	return isCanceled;
}

/* End the loop as soon as possible, generally when this event handler exits. */
- (void) terminate
{
	rl->exit();
	isTerminated = true;
}

- (bool) isTerminated
{
	return isTerminated;
}

- (void) performSelector:(SEL)sel target:(id)target argument:(id)arg
	order:(unsigned long)order modes:(NSArray *)modes
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

static char rl_key;

- (void) addRunLoopSource:(Alepha::RunLoop::Source *)s target:(id)tgt
	selector:(SEL)sel mode:(NSString *)mode
{
	_RunLoopSource *d;
	
	d = objc_getAssociatedObject(tgt, &rl_key);

	if (d == nil)
	{
		d = [[_RunLoopSource alloc] initWithTarget:tgt
			selector:sel source:s];
		objc_setAssociatedObject(tgt, &rl_key, d, OBJC_ASSOCIATION_RETAIN);
	}
	rl->add(d->d.getSource(), ModeIndexFromString(mode));
}

- (void) removeRunLoopTarget:(id)tgt mode:(NSString *)mode
{
	_RunLoopSource *d;
	
	d = objc_getAssociatedObject(tgt, &rl_key);

	if (d != nil)
	{
		rl->remove(d->d.getSource(), ModeIndexFromString(mode));
	}
}

- (Alepha::RunLoop *)coreRunLoop
{
	return rl;
}

- (void) acceptInputForMode:(NSString *)mode beforeDate:(NSDate *)limit
{
	TODO; // acceptInputForMode:beforeDate:
}

- (NSDate *) limitDateForMode:(NSString *)mode
{
	TODO; // limitDateForMode:
	return nil;
}

- (NSString *) currentMode
{
	return currentMode;
}
@end
