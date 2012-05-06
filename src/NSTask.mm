/*
 * Copyright (c) 2008-2012	Justin Hibbits
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

#include <sys/types.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <sys/resource.h>

#include <dispatch/dispatch.h>

#import "internal.h"
#import <debug.h>
#import <Foundation/NSTask.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileHandle.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSString.h>

#include <unordered_map>
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
{
	id			taskURL;	/*!< \brief The identifier for the task object. */
	id			args;	/*!< \brief Argument(s) to pass to the new task. */
	NSDictionary	*taskEnv;	/*!< \brief Environment in which to execute. */
	NSString    *newDir;
	int			result; 		/*!< \brief Result of execution (exit code).  Only valid once the process has terminated. */
	NSTaskTerminationReason         terminateReason;
	bool		isRunning;		/*!< Whether or not the task is running. */
	id			stdIn;
	id			stdOut;
	id			stdErr;
	pid_t		processID;	/*!< Process ID of the new task. */
	dispatch_source_t taskDispatch;
}

@synthesize terminationHandler;

+ (id) spawnedTaskWithURL:(NSURL *)target object:(id)arg
		 environment:(NSDictionary *)env
{
	NSTask *t = [[self alloc] initWithURL:target object:arg environment:env];
	[t launch];
	return t;
}

+ (id) launchedTaskWithLaunchURL:(NSURL *)url arguments:(NSArray *)args
{
	return [[self alloc] initWithURL:url object:args environment:nil];
}

- (id) init
{
	return self;
}

- (id) initWithURL:(NSURL *)target object:(id)obj environment:(NSDictionary *)env
{
	taskURL = target;
	args = [obj copy];
	taskEnv = [env copy];
	return self;
}

- (void) launch
{
	if (isRunning)
	{
		NSLog(@"Process '%@' is already running.", taskURL);
		return;
	}

	if (spawnProcessWithURL(taskURL, args, taskEnv, &processID))
	{
		isRunning = true;
		taskDispatch = dispatch_source_create(DISPATCH_SOURCE_TYPE_PROC,
				processID, DISPATCH_PROC_EXIT, dispatch_get_main_queue());
		dispatch_source_set_event_handler(taskDispatch, ^{
				int status;
				waitpid(processID, &status, WNOHANG);
				[self _handleTaskExitWithErrorCode:WEXITSTATUS(status)
				normalExit:WIFEXITED(status)];
				});
	}
}

- (void) setCurrentDirectory:(NSString *)newPath
{
	if ([self isRunning])
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"Task already running" userInfo:nil];
	}
	newDir = newPath;
}

- (void) setStandardError:(id)newStderr
{
	if ([self isRunning])
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"Task already running" userInfo:nil];
	}
	if (![newStderr isKindOfClass:[NSFileHandle class]] && ![newStderr isKindOfClass:[NSPipe class]])
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"Invalid object type being set as stderr" userInfo:nil];
	}
	stdErr = newStderr;
}

- (void) setStandardInput:(id)newStdin
{
	if ([self isRunning])
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"Task already running" userInfo:nil];
	}
	if (![newStdin isKindOfClass:[NSFileHandle class]] && ![newStdin isKindOfClass:[NSPipe class]])
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"Invalid object type being set as stdin" userInfo:nil];
	}
	stdIn = newStdin;
}

- (void) setStandardOutput:(id)newStdout
{
	if ([self isRunning])
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"Task already running" userInfo:nil];
	}
	if (![newStdout isKindOfClass:[NSFileHandle class]] && ![newStdout isKindOfClass:[NSPipe class]])
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"Invalid object type being set as stdout" userInfo:nil];
	}
	stdOut = newStdout;
}

- (void) setArguments:(NSArray *)newArgs
{
	args = [newArgs copy];
}

- (void) setEnvironment:(NSDictionary *)newEnv
{
	taskEnv = [newEnv copy];
}

- (void) setLaunchURL:(NSURL *)newURL
{
	taskURL = newURL;
}

- (void) _sendSignal:(int)sig
{
	NSAssert(isRunning, @"Not running");
	if (!isRunning)
		return;

	kill(processID, sig);
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
	args = obj;
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

- (int) processIdentifier
{
	return processID;
}

/* Internal method, called when a task exits, by the NSApplication class (forward) */
- (void) _handleTaskExitWithErrorCode:(int)err normalExit:(bool)normalExit
{
	isRunning = false;
	result = err;
	terminateReason = (normalExit ? NSTaskTerminationReasonExit : NSTaskTerminationReasonUncaughtSignal);
	[[NSNotificationCenter defaultCenter] postNotificationName:NSTaskDidExitNotification object:self];
	if (self.terminationHandler != NULL)
		self.terminationHandler(self);
}

@end
