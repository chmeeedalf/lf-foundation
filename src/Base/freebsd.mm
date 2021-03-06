/*
 * Copyright (c) 2005-2012	Justin Hibbits
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

/*
   This is the kernel-specific portion of the System framework, for FreeBSD.
 */

#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <spawn.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <string>
#include <vector>

#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSApplication.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSString.h>
#import <Foundation/NSTask.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSURL.h>
#import "DateTime/NSConcreteDate.h"	/* for UNIX_OFFSET */
#import "internal.h"

/* Emulation of the Gold APIs */

void terminate()
{
	if (numThreads > 0)
		pthread_exit(NULL);
	exit(0);
}

void hold(void)
{
	sigset_t mask;
	sigemptyset(&mask);
	sigsuspend(&mask);
}

void yield(void)
{
	sched_yield();
}

/*
 * args can be any object, with some considerations:
 *
 * If it's an array, all objects will be entered into the task's argv[] as-is
 * (using descriptions).
 * If it's a dictionary then the following rules apply:
 * Keys that are strings of length n, n > 1 become prefixed with '--', iff the
 * value is not Null.  If value is '', just '--<key>' is used, else
 * '--<key>=<value>' is used.
 * Keys of length 1 become prefixed '-', if value is Null.
 * Keys with value of Null are conveyed as-is.
 */
bool spawnProcessWithURL(NSURL *identifier, id args, NSDictionary *env, pid_t *targetID)
{
	std::vector<const char *> argv;
	std::vector<const char *> environ;
	const char *progname;
	pid_t	pid;

	/* Sanity checking */
	if (![identifier isKindOfClass:[NSURL class]])
		return false;

	/* A temporary pool to hold all the strings created */

	@autoreleasepool {
		progname = [[identifier path] UTF8String];
		if ([args isKindOfClass:[NSDictionary class]])
		{
			for (id key in args)
			{
				if ([args objectForKey:key] == [NSNull null])
					argv.push_back([[key description] UTF8String]);
				else
				{
					id obj = [args objectForKey:key];
					NSString *desc = [obj description];
					NSString *keyDesc = [key description];
					if ([keyDesc length] == 1)
						argv.push_back([[NSString stringWithFormat:@"-%@%@", keyDesc, desc] UTF8String]);
					else if ([desc length] == 0)
						argv.push_back([[NSString stringWithFormat:@"--%@",keyDesc] UTF8String]);
					else
						argv.push_back([[NSString stringWithFormat:@"--%@=%@", keyDesc, desc] UTF8String]);
				}
				argv.push_back(NULL);
			}
		}
		else if ([args respondsToSelector:@selector(objectEnumerator)])
		{
			for (id item in args)
			{
				argv.push_back([[item description] UTF8String]);
			}
			argv.push_back(NULL);
		}
		else
		{
			if (args != nil)
				argv.push_back([[args description] UTF8String]);
		}
		argv.push_back(progname);

		if (env == nil)
		{
			env = [[NSProcessInfo processInfo] environment];
		}

		for (NSString *key in env)
		{
			environ.push_back([[NSString stringWithFormat:@"%@=%@",key,[env objectForKey:key]] UTF8String]);
		}

		if (posix_spawn(&pid, argv[0], NULL, NULL, 
					(char **)&argv[0], (char **)&environ[0]) < 0)
		{
			return false;
		}
		*targetID = pid;
		return true;
	}
}

static fd_set readers;
static fd_set writers;
static bool watching = false;
static NSInvocation *fd_invoke_write[FD_SETSIZE];
static NSInvocation *fd_invoke_read[FD_SETSIZE];

void _AsyncWatchDescriptor(int fd, id obj, SEL sel, bool writing)
{
	NSInvocation *inv;
	if (!watching)
	{
		watching = true;
		FD_ZERO(&readers);
		FD_ZERO(&writers);
	}
	if ((size_t)fd > FD_SETSIZE)
		@throw [NSInternalInconsistencyException exceptionWithReason:@"File descriptor for async too big" userInfo:nil];

	inv = [[NSInvocation alloc] initWithMethodSignature:[obj methodSignatureForSelector:sel]];
	[inv setSelector:sel];
	[inv setTarget:obj];
	if (writing)
	{
		fd_invoke_write[fd] = inv;
		FD_SET(fd, &writers);
	}
	else
	{
		fd_invoke_read[fd] = inv;
		FD_SET(fd, &readers);
	}
	fcntl(fd, F_SETOWN, getpid());
	fcntl(fd, F_SETFL, O_ASYNC | O_NONBLOCK);
}

void _AsyncUnwatchDescriptor(int fd, bool writing)
{
	FD_CLR(fd, &readers);
	if (writing)
	{
		fd_invoke_write[fd] = nil;
	}
	else
	{
		fd_invoke_read[fd] = nil;
	}
}

// FreeBSD entry point
// we just take all 3 arguments
int main(int argc, const char **argv, const char **environ)
{
	[[NSApplication new] startProcess:NULL];
}
