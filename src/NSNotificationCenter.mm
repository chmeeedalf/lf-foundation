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
 * 3. Neither the name of the author nor the names of its contributors
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

#import "internal.h"
#import <Foundation/NSException.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSOperation.h>
#import <Foundation/NSString.h>
#include <tuple>
#include <vector>


@interface _NSNotificationBlock : NSObject
{
	@public
		NSOperationQueue *queue;
		void (^block)(NSNotification *);
}
@end

@implementation _NSNotificationBlock
- (void) invokeWithNotification:(NSNotification *)note
{
	[queue addOperationWithBlock:^(){
		block(note);
	}];
}
@end

/*
 * NSNotificationCenter	
 */

static NSNotificationCenter *defaultCenter = nil;
class _NSNotificationDispatcher
{
	public:
		__weak id source;
		NSString *name;
		__weak id observer;
		SEL selector;
};

@implementation NSNotificationCenter 
{
	std::vector<_NSNotificationDispatcher> objects;
}

/* Class methods */

+ (void)initialize
{
	static bool initialized = false;

	if (!initialized)
	{
		initialized = true;
		defaultCenter = [[self alloc] init];
	}
}

+ (NSNotificationCenter*)defaultCenter
{
	return defaultCenter;
}

- (id)init
{
	return self;
}

/* Register && post notifications */

- (void)postNotification:(NSNotification *)notification
{
	id name;
	id object;

	name   = [notification name];
	object = [notification object];

	if (name == nil)
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"`nil' notification name in postNotification:" userInfo:nil];
	}

	for (auto &item: objects)
	{
		id obj = item.source;
		id noteName = item.name;
		
		if (obj != object && obj != nil)
			continue;
		if (noteName != name && noteName != nil)
			continue;

		[obj performSelector:item.selector withObject:notification];
	}
}

- (void)addObserver:(id)observer selector:(SEL)selector 
			   name:(NSString *)notificationName object:(id)object
{
	_NSNotificationDispatcher t{object, notificationName, observer, selector};
	objects.push_back(t);
}

- (id) addObserverForName:(NSString *)name object:(id)obj queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *))block
{
	auto observerObj = [_NSNotificationBlock new];

	observerObj->block = [block copy];
	observerObj->queue = queue;
	[self addObserver:observerObj selector:@selector(invokeWithNotification) name:name
		object:obj];
	return observerObj;
}

- (void)removeObserver:(id)observer 
				  name:(NSString*)notificationName object:(id)object
{
	objects.erase(std::remove_if(objects.begin(), objects.end(),
				[=](_NSNotificationDispatcher dispatch){
				return (observer == dispatch.observer && 
					((notificationName == dispatch.name || notificationName == nil) ||
					(object == dispatch.source || object == nil)));
				}), objects.end());
}

- (void)removeObserver:(id)observer
{
	objects.erase(std::remove_if(objects.begin(), objects.end(),
				[=](_NSNotificationDispatcher dispatch){
				return observer == dispatch.observer;
				}), objects.end());
}

- (void)postNotificationName:(NSString*)notificationName object:object
{
	id notification;

	notification = [[NSNotification alloc] initWithName:notificationName
											   object:object
											 userInfo:nil];
	[self postNotification:notification];
}

- (void)postNotificationName:(NSString*)notificationName object:object
					userInfo:(NSDictionary*)userInfo
{
	id notification;

	notification = [[NSNotification alloc] initWithName:notificationName
											   object:object
											 userInfo:userInfo];
	[self postNotification:notification];
}

@end /* NSNotificationCenter */

/*
   Local Variables:
	c-basic-offset: 4
		 tab-width: 8
			   End:
			   */
