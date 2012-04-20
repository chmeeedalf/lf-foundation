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

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <types.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <Event.h>
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

extern void eventHandler (Event_t *_eventPage);

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

int64_t SystemTime(void)
{
	NSTimeInterval	theTime = UNIX_OFFSET;

	struct timeval tp;

	// XXX: Get this out of the way when we have LSD timekeeping
	gettimeofday(&tp, NULL);

	/* the constant of '10' is because we use 100ns counting, which is 1/10 us*/
	theTime += tp.tv_sec + tp.tv_usec / 1000000;

	return theTime;
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
/* TODO: Handle environment -- translate from CamelCase to
 * UPPERCASE_AND_UNDERSCORE, and back again in main()
 */
bool spawnProcessWithURL(NSURL *identifier, id args, NSDictionary *env, UUID *targetUUID)
{
	std::vector<std::string> argv;
	std::vector<std::string> environ;
	const char *progname;
	bool retval;
	pid_t	pid;

	/* Sanity checking */
	if (![identifier isKindOfClass:[NSURL class]])
		return false;

	/* A temporary pool to hold all the strings created */

	@autoreleasepool {
		progname = [[identifier path] UTF8String];
		if ([args isKindOfClass:[NSDictionary class]])
		{
			size_t length = [args count];
			length = 1;
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
		switch ((pid = vfork()))
		{
			case -1:
				NSLog(@"Can't fork!");
				retval = false;
				break;
			case 0:
				execve(progname, (char * const *)&argv[0],
						(char * const *)&environ[0]);
				_exit(errno);
				break;
			default:
				targetUUID->parts[3] = pid;
				retval = true;
				break;
		}

	}
	return retval;
}

static fd_set readers;
static fd_set writers;
static bool watching = false;
static NSInvocation *fd_invoke_write[FD_SETSIZE];
static NSInvocation *fd_invoke_read[FD_SETSIZE];
static NSArray *sigio_filters = nil;

static void handle_sigio(int sig)
{
	struct timeval tv = {0, 0};
	fd_set readers_copy;
	fd_set writers_copy;
	size_t i = [sigio_filters count];

	/* First run through the watched filters */
	for (; i > 0; i--)
	{
		[[sigio_filters objectAtIndex:(i-1)] invoke];
	}
	FD_COPY(&readers, &readers_copy);
	FD_COPY(&writers, &writers_copy);
	int count = select(FD_SETSIZE, &readers_copy, &writers_copy, NULL, &tv);
	if (count <= 0)
		return;

	for (i = 0; i < FD_SETSIZE; i++)
	{
		if (FD_ISSET(i, &readers_copy))
		{
			[fd_invoke_read[i] invoke];
		}
		if (FD_ISSET(i, &writers_copy))
		{
			[fd_invoke_write[i] invoke];
		}
	}
}

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
	__private extern Event_t eventPage[PAGE_SIZE/sizeof(Event_t)];
	uint32_t pid = getpid();
	struct sigaction sa;
	SEL msgSel = @selector(startProcess:);
	memset(&sa, 0, sizeof(sa));
	memset(eventPage, 0, sizeof(eventPage));
	((uint32_t*)eventPage[0].payload)[0] = pid;
	memset(&eventPage[0].senderID, 0, sizeof(eventPage[0].senderID));
	eventPage[0].message = (uint32_t)msgSel;

	sa.sa_handler = handle_sigio;
	sa.sa_flags = 0x48;
	sigaction(23, &sa, NULL);

	eventHandler(&eventPage[0]);
}
