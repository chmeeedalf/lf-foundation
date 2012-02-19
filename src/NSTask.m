/*
 * Copyright (c) 2008	Gold Project
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

#import "internal.h"
#import <debug.h>
#import <Foundation/NSTask.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSString.h>
#include <sys/types.h>
#include <signal.h>
#include <string.h>

NSString *NSTaskDidExitNotification = @"NSTaskDidExitNotification";

/*
	A NSTask refers to either a running task or a spawned task.  It is used as the
	primary form of communication between processes.  An identifier refers to
	either a disk file format, or a MIME type of 'application/x-running-process'.
	A MIME of 'application/x-running-process' is any object that could be
	proxied to as a running process.  It could even be on another machine, as
	long as there is a local object to refer to it.
 */
@implementation NSTask

static NSMutableArray *runningTasks;

+ (void) initialize
{
	runningTasks = [NSMutableArray new];
}

+ spawnedTaskWithURI:(NSURI *)target object:(id)arg
		 environment:(NSDictionary *)env
{
	NSTask *t = [[self alloc] initWithURI:target object:arg environment:env];
	[t launch];
	return t;
}

- init
{
	return self;
}

- initWithURI:(NSURI *)target object:(id)obj environment:(NSDictionary *)env
{
	_taskObject = target;
	_taskArguments = [obj copy];
	_environment = [env copy];
	return self;
}

- (void) launch
{
	if (isRunning)
	{
		NSLog(@"Process '%@' is already running.", _taskObject);
		return;
	}

	if (spawnProcessWithURI(_taskObject, _taskArguments, _environment, &processUUID))
	{
		isRunning = true;
		[runningTasks addObject:self];
	}
}

- (void) _sendSignal:(int)sig
{
	NSAssert(isRunning, @"Not running");
	if (!isRunning)
		return;

	kill(processUUID.parts[3], sig);
}

- (void) resume
{
	[self _sendSignal:SIGCONT];
}

- (void) suspend
{
	[self _sendSignal:SIGSTOP];
}

- (void) terminate
{
	[self _sendSignal:SIGTERM];
}

- (void) kill
{
	[self _sendSignal:SIGKILL];
}

- (void) interrupt
{
	[self _sendSignal:SIGINT];
}

- (void) waitUntilExit
{
	while ([self isRunning])
		hold();
}

- (void) setObject:(id)obj
{
	_taskArguments = obj;
}

- (bool) isRunning
{
	return isRunning;
}

- (int) result
{
	NSAssert(![self isRunning], @"NSTask is still running");
	return result;
}

- (int) terminationStatus
{
	NSAssert(![self isRunning], @"NSTask is still running");
	return result;
}

- (NSTaskTerminationReason) terminationReason
{
	NSAssert(![self isRunning], @"NSTask is still running");
	return terminateReason;
}

- (void) getProcessIdentifier:(UUID *)uuid
{
	memcpy(uuid, &processUUID, sizeof(*uuid));
}

/* Internal method, called when a task exits, by the NSApplication class (forward) */
- (void) _handleTaskExitWithErrorCode:(int)err normalExit:(bool)normalExit
{
	isRunning = false;
	result = err;
	terminateReason = (normalExit ? NSTaskTerminationReasonExit : NSTaskTerminationReasonUncaughtSignal);
	[[NSNotificationCenter defaultCenter] postNotificationName:NSTaskDidExitNotification object:self];
}

+ (void) _dispatchExitToPid:(UUID)pid status:(int)status exitedNormally:(bool)normalExit
{
	UUID taskID;
	for (id task in runningTasks)
	{
		[task getProcessIdentifier:&taskID];
		if (memcmp(&taskID, &pid, sizeof(pid)) == 0)
		{
			[runningTasks removeObject:task];
			[task _handleTaskExitWithErrorCode:status normalExit:normalExit];
			break;
		}
	}
}

@end

/*
   vim:syntax=objc:
 */
