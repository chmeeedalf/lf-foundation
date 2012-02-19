/*
   ProcessInfo.m

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

#include <unistd.h>
#include <sys/timex.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <string.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#include <Alepha/System/SysCtl.h>
#include <string>

/*
 * Static global vars
 */

static NSString *operatingSystem = @"Gold version " @VERSION;

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

+ (void) initialize
{
	if (self != [NSProcessInfo class])
		return;
	size_t count = (long)Alepha::System::SysCtl("kern.argmax");
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

		NSString *argptrs[argc];
		size_t j = 0;
		for (i = 0,j=0; i < count;j++)
		{
			argptrs[j] = [NSString stringWithUTF8String:&args[i]];
			i += strlen(&args[i]) + 1;
		}
		arguments = [[NSArray alloc] initWithObjects:argptrs count:argc];
	}
	else
	{
		arguments = [[NSArray alloc] initWithObjects:@"unknown",nil];
	}

	delete[] args;
}

+ allocWithZone:(NSZone *)_zone
{
	return processInfo;
}

+ (NSString*)operatingSystem
{
	return operatingSystem;
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
	if (aName && [aName length])
	{
		processName = aName;
	}
}

- (unsigned int) threadCount
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
	char hostname[sysconf(_SC_HOST_NAME_MAX)];
	if (gethostname(hostname, sizeof(hostname)) < 0)
		return nil;
	return [NSString stringWithCString:hostname encoding:NSASCIIStringEncoding];
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
		processors = Alepha::System::SysCtl("kern.smp.cpus");
	}
	return processors;
}

- (unsigned long long) physicalMemory
{
	return (unsigned long)Alepha::System::SysCtl("hw.physmem");
}

- (void) enableSuddenTermination
{
	TODO;
}

- (void) disableSuddenTermination
{
	TODO;
}
@end
