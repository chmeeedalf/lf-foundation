/*
   ProcessInfo.m
 * All rights reserved.

   Copyright (C) 2005-2012 Gold project
   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Justin Hibbits <jrh29@po.cwru.edu>
   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

   This file is part of libFoundation.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.
 */

#include <sys/time.h>
#include <sys/timex.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/utsname.h>

#include <signal.h>
#include <string.h>
#include <unistd.h>

#include <atomic>
#include <string>
#include <memory>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSException.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import "internal.h"

/*
 * Static global vars
 */

// The shared ProcessInfo instance
static NSProcessInfo *processInfo = nil;

// Current process name
static NSString *processName = nil;

// NSArray of Strings (argv[0] .. argv[argc-1])
static NSArray *arguments = nil;

// NSDictionary of environment vars and their values
static NSMutableDictionary *environment = nil;

unsigned int numThreads __private = 0;

/*
 * ProcessInfo implementation
 */

@implementation NSProcessInfo

static std::atomic<NSInteger> suddenTermCount{1};

static void sigtermHandler(int sig __unused)
{
	if (suddenTermCount > 0)
	{
		return;
	}
	else
	{
		exit(0);
	}
}

+ (void) load
{
	struct sigaction sa{};

	memset(&sa, 0, sizeof(sa));

	sa.sa_handler = sigtermHandler;

	sigaction(SIGTERM, &sa, NULL);
}

+ (void) initialize
{
	if (self != [NSProcessInfo class])
		return;
	size_t count = 0;
	size_t s = sizeof(count);

	sysctlbyname("kern.argmax", &count, &s, NULL, 0);

	char *args = new char[count];
	int argmib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_ARGS, getpid() };
	processInfo = [NSAllocateObject([NSProcessInfo class], 0, NULL) init];
	if (sysctl(argmib, 4, args, &count, NULL, 0) == 0 && *args != 0)
	{
		size_t i = 0;
		size_t argc = 0;
		for (; i < count; i++)
		{
			if (args[i] == '\0')
				argc++;
		}

		NSMutableArray *tmpArgs;

		tmpArgs = [[NSMutableArray alloc] initWithCapacity:argc];
		for (i = 0; i < count;)
		{
			[tmpArgs addObject:@(&args[i])];
			i += strlen(&args[i]) + 1;
		}
	}
	else
	{
		arguments = [[NSArray alloc] initWithObjects:@"unknown",nil];
	}

	delete[] args;
}

+ (id) allocWithZone:(NSZone *)_zone
{
	return processInfo;
}

- (NSUInteger) operatingSystem
{
	return NSBSDOperatingSystem;
}

- (NSString*)operatingSystemName
{
	return @"NSBSDOperatingSystem";
}

- (NSString *) operatingSystemVersionString
{
	static NSString *versionString;

	if (versionString == nil)
	{
		@synchronized([NSProcessInfo class])
		{
			if (versionString == nil)
			{
				struct utsname uts;
				
				if (uname(&uts) != 0)
				{
					return nil;
				}
				versionString = [NSString stringWithCString:uts.release
					encoding:[NSString defaultCStringEncoding]];
			}
		}
	}
	return versionString;
}

+ (NSProcessInfo*)processInfo
{
	return processInfo;
}

- (id)init
{
	return self;
}

- (NSArray*)arguments
{
	return arguments;
}

- (NSDictionary*)environment
{
	return environment;
}

- (void)addEnvironmentVariable:(NSString *)var withValue:(NSString *)val
{
	[environment setObject:[val copy] forKey:var];
}

- (void)setEnvironment:(NSDictionary *)newEnv
{
	[environment setDictionary:newEnv];
}

- (NSString*)processName
{
	if (processName == nil)
	{
		@synchronized(self)
		{
			if (processName == nil)
			{
				processName = [arguments objectAtIndex:0];
			}
		}
	}
	return processName;
}

- (NSString*)globallyUniqueString
{
	static unsigned int counter = 0;
	unsigned int count;
	NSObject *o = [NSObject new];
	NSString *s;

	count = __sync_fetch_and_add(&counter, 1);

	s = [NSString stringWithFormat:@"%d:%p:%g:%p:%d",
		   //[Host currentHost],
		   [self processIdentifier],
		   [NSThread currentThread],
		   [[NSDate date] timeIntervalSince1970],
		   o,
		   count];
	return s;
}

- (void)setProcessName:(NSString*)aName
{
	if (aName != nil && [aName length] > 0)
	{
		processName = aName;
	}
}

- (NSUInteger) threadCount
{
	return numThreads;
}

/*
 * internal class that cannot be deleted
 */

- (pid_t) processIdentifier
{
	return getpid();
}

- (NSString *) hostName
{
	size_t len = sysconf(_SC_HOST_NAME_MAX);
	std::unique_ptr<char[]> hostname(new char[len]);
	if (gethostname(&hostname[0], len) < 0)
		return nil;
	return [NSString stringWithCString:&hostname[0] encoding:NSASCIIStringEncoding];
}

- (NSTimeInterval) systemUptime
{
	struct timespec ts;
	clock_gettime(CLOCK_UPTIME_FAST, &ts);
	return (NSTimeInterval)ts.tv_sec + (NSTimeInterval)ts.tv_nsec / NANOSECOND;
}

- (NSUInteger) processorCount
{
	/* A constant value, once initialized. */
	static unsigned long processors;

	if (processors == 0)
	{
		size_t s = sizeof(processors);

		sysctlbyname("kern.smp.cpus", &processors, &s, NULL, 0);
	}
	return processors;
}

- (NSUInteger) activeProcessorCount
{
	unsigned long activeCount = 0;
	size_t s = sizeof(activeCount);

	sysctlbyname("kern.smp.active", &activeCount, &s, NULL, 0);
	return activeCount;
}

- (unsigned long long) physicalMemory
{
	unsigned long physmem = 0;
	size_t s = sizeof(physmem);

	sysctlbyname("hw.physmem", &physmem, &s, NULL, 0);
	return physmem;
}

- (void) enableSuddenTermination
{
	NSInteger count = --suddenTermCount;

	if (count < 0)
	{
		@throw [NSInternalInconsistencyException
			exceptionWithReason:@"Unbalanced sudden termination control"
			userInfo:nil];
	}
}

- (void) disableSuddenTermination
{
	suddenTermCount++;
}
@end
