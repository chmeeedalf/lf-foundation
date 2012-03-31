/*
 * Copyright (c) 2005	Justin Hibbits
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

#import "internal.h"
#import <Event.h>
#import <Foundation/NSApplication.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSThread.h>
#include <string.h>

NSApplication *App = nil;

@interface NSApplication(LSDExtensions)
- (void) startThread:(NSThread *)threadID :(void *[1])data;
- (void) startProcess:(void *[1])data;
- (void) startClone:(void *[1])data;
@end

@implementation NSApplication

+ (NSApplication *)currentApplication
{
	return App;
}

- (id) init
{
	threadList = [NSMutableArray new];
	return self;
}

- (id) run
{
	id thr = [threadList objectAtIndex:0];
	runThread((__bridge void *)thr);
	return nil;
}

- (void)dealloc
{
	[self cleanup];
}

- (void) removeThread:(NSThread *)thr
{
	[threadList removeObject:thr];
	if ([threadList count] == 0)
		[self cleanup];
}

- (void) cleanup
{
}

- (void) addThread:(NSThread *)thr
{
	// Do we already have this thread?
	@synchronized(threadList)
	{
		if ([threadList containsObject:thr])
			return;
		[threadList addObject:thr];
	}
}

- (NSArray *) threadList
{
	return [threadList copy];
}

- (void) exit
{
	[threadList makeObjectsPerformSelector:@selector(exit)];

	terminate();
}

- (void) startThread:(NSThread *)threadID :(void *[])data
{
}

/* The array size of 1 is a "hack" just so the decoder wouldn't try to decode
 * the data, and would instead treat it as the pointer to just the block of
 * memory in the event.
 */
- (void) startProcess:(void *[1])data
{
	id thread = nil;

#if 0
	UUID senderTest = {{0}};
	UUID *procData = (UUID *)data;
	register Event_t *rawEvent __asm__("%r6");
	Event_t *realEvent = rawEvent;
	/* Security check -- only the kernel should send a startProcess: message */
	if (memcmp(realEvent->senderID, &senderTest, sizeof(UUID)) != 0)
		return;

	memcpy(&processID, procData[0], sizeof(processID));
	memset(realEvent, 0, sizeof(*realEvent));
#endif

	size_t count = 0;
	Class *threads = class_copySubclassList([NSThread class], &count);

	for (; count; count--)
	{
		if ([threads[count-1] conformsToProtocol:@protocol(NSLaunchableThread)])
		{
			if (thread)
				[[thread new] start];
			thread = threads[count-1];
		}
	}
	runThread((__bridge void *)[thread new]);
	for (NSThread *t in threadList)
		pthread_join([t _pthreadId], NULL);
	[self exit];
}

@end
