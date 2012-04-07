/*
 * Copyright (c) 2004	Justin Hibbits
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

#import <Foundation/NSDate.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSTimeZone.h>
#import <Foundation/NSThread.h>

#include <string.h>
#include <unistd.h>

const char *_NSPrintForDebugger(id obj);

/*
 * Log a Message
 */

void NSLog(NSString *format, ...)
{
	va_list ap;

	va_start(ap, format);
	NSLogv(format, ap);
	va_end(ap);
}

void NSLogv(NSString *format, va_list args)
{
	NSString* message = [[NSString alloc] initWithFormat:format arguments:args];
	NSDate* date = [NSDate new];
	NSString* header;
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	const char *f;

	/* We use en_US_POSIX so that it uses a consistant POSIX print */
	header = [[NSString alloc] initWithFormat:@"%@ %@(%@) [%d]: %@"
		locale:locale,
		[date descriptionWithCalendarFormat:@"MMM dd kk:mm:ss" timeZone:[NSTimeZone defaultTimeZone] locale:locale],
		[[NSProcessInfo processInfo] processName], 
		[[NSThread currentThread] name],
		getpid(),
		message];

	f = [header UTF8String];

	NSLogRaw(f);
}

void NSLogRaw(const char *message)
{
	write(2, message, strlen(message));
	if (message[strlen(message) - 1] != '\n')
		write(2, "\n", 1);
}

/* XXX: For the next 2 functions, we should cache the strings, rather than
 * making new ones every time.
 */
NSString *NSStringFromSelector(SEL aSelector)
{
	const char *c = sel_getName(aSelector);
	if (c == NULL)
	{
		return nil;
	}

	return [[NSString alloc] initWithBytesNoCopy:c length:strlen(c) 
		encoding:NSASCIIStringEncoding freeWhenDone:false];
}

NSString *NSStringFromClass(Class aClass)
{
	const char *name;
	if (aClass == NULL)
	{
		return nil;
	}
	name = class_getName(aClass);

	return [[NSString alloc] initWithBytesNoCopy:name length:strlen(name)
		encoding:NSASCIIStringEncoding freeWhenDone:false];
}

Class NSClassFromString(NSString *aString)
{
	return aString ? objc_lookUpClass([aString UTF8String]) : Nil;
}

SEL NSSelectorFromString(NSString *aSelectorName)
{
	return aSelectorName ? sel_getUid([aSelectorName UTF8String]) : NULL;
}

const char *_NSPrintForDebugger(id obj)
{
	return [[obj description] cStringUsingEncoding:NSASCIIStringEncoding];
}
