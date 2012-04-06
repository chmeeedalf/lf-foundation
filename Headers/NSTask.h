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

#include <types.h>
#import <Foundation/NSObject.h>

@class NSArray, NSDictionary, NSURL;

typedef enum
{
	NSTaskTerminationReasonExit,
	NSTaskTerminationReasonUncaughtSignal
} NSTaskTerminationReason;

/*!
 * \class NSTask
 * \brief Manages spawning tasks, and interfacing with other processes.
 */
@interface NSTask : NSObject 
#if __has_feature(blocks)
@property(copy) void (^terminationHandler)(NSTask *);
#endif

/*!
 * \brief Create a new task that executes with a given environment, and an
 * argument.
 * \param target Target identifier for the task (filename for POSIX).
 * \param obj NSObject to pass as an argument/argument list to the target.
 * \param env Environment in which to execute -- environment variables,
 * settings.
 * \sa [NSTask initWithIdentifier:object:environment:]
 */
+ (id)spawnedTaskWithURL:(NSURL *)target object:(id)obj environment:(NSDictionary *)env;
+ (id)launchedTaskWithLaunchURL:(NSURL *)target arguments:(NSArray *)args;

- (id)init;
/*!
 * \brief Initialize a task object that executes with a given environment, and a
 * collection of arguments.
 * \param target Target identifier for the task (filename for POSIX).
 * \param obj NSObject collection to pass to the target at startup.
 * \param env Environment in which to execute -- environment variables,
 * settings.
 *
 * \details On FreeBSD, the argument list gets converted into string arguments.
 * If \e obj is an NSArray object, the arguments are just stringified.  If \e obj is a
 * NSDictionary object, the following rules are applied:
 *	- If a given key has an associated value of Null class, it is stringified
 * 		verbatim.
 * 	- If a key is a single character, it's prepended with '-' with the value
 * 	appended as part of the string.
 *	- If a key is multiple characters, it's prepended with '--'.
 * 		- If the associated value is the empty string, nothing else is done.
 * 		- If the associated value is not empty, it is appended with an '=' to
 * 		the key's string.
 */
- (id)initWithURL:(NSURL *)target object:(id)obj environment:(NSDictionary *)env;

/*!
 * \brief Force the task to stop.
 *
 * \details Equivalent to SIGKILL in UNIX terminology.  This is trapped by the
 * kernel to forcibly terminate the task.  The task cannot clean up its
 * environment before exiting, so objects may be left in an invalid state when
 * this is called.
 */
- (void) kill;

- (void) interrupt;

/*!
 * \brief Spawn the process.
 *
 * \details The task must not be running.
 */
- (void) launch;

- (void) resume;
- (void) suspend;

/*!
 * \brief Stop the task.
 *
 * \details Equivalent to SIGTERM in UNIX signal terminology.
 */
- (void) terminate;

- (void) waitUntilExit;

/*!
 * \brief Set the task object to run.
 * \param obj New target object to start as the task.
 *
 * \details The task must not be running.
 */
- (void) setObject:(id)obj;

/*!
 * \brief Check if the task is running.
 */
- (bool) isRunning;
- (int) terminationStatus;
- (NSTaskTerminationReason) terminationReason;

- (int) processIdentifier;
- (void) setArguments:(NSArray *)newArgs;
- (void) setCurrentDirectory:(NSString *)curDir;
- (void) setEnvironment:(NSDictionary *)newEnv;
- (void) setLaunchURL:(NSURL *)url;
- (void) setStandardError:(id)newStderr;
- (void) setStandardInput:(id)newStdin;
- (void) setStandardOutput:(id)newStdout;
@end

/*
   vim:syntax=objc:
 */
