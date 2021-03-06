/*
 * Copyright (c) 2004-2012	Justin Hibbits
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
   NSException.m

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Ovidiu Predescu <ovidiu@bx.logicnet.ro>

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

#import <Foundation/NSException.h>

#include <execinfo.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSValue.h>
#import "internal.h"

@class NSLocale;
@implementation NSException
{
	NSMutableArray *callStackSymbols;
}
@synthesize name;
@synthesize reason;
@synthesize userInfo;

+ (NSException*)exceptionWithName:(NSString*)_name
reason:(NSString*)_reason
userInfo:(NSDictionary*)_userInfo
{
	return [[self alloc] initWithName:_name reason:_reason userInfo:_userInfo];
}

- (id)initWithName:(NSString*)_name
reason:(NSString*)_reason
userInfo:(NSDictionary*)_userInfo
{
	NSInteger retaddr;
	NSArray *callstack;
	NSUInteger i = 0;

	self.name = _name;
	self.reason = _reason;
	self.userInfo = _userInfo;

	retaddr = (uintptr_t)__builtin_return_address(0);
	callstack = [NSThread callStackReturnAddresses];

	for (NSNumber *addr in callstack)
	{
		if ([addr integerValue] == retaddr)
		{
			break;
		}
		i++;
	}
	if (i < [callstack count])
	{
		returnAddresses = [callstack subarrayWithRange:NSMakeRange(i, [callstack count] - i)];
	}
	return self;
}

- (void)dealloc
{
}

- (NSString*)descriptionWithLocale:(NSLocale*)locale
{
	return [NSString stringWithFormat: @"(NSException name:%@ class:%@ reason:%@ info:%@)"
		locale:locale,
		[self name],
		NSStringFromClass([self class]),
		reason ? reason : @"<nil>",
		userInfo ? [userInfo description] : @"<nil>"];
}

- (NSString*)description
{
	return [self descriptionWithLocale:nil];
}

-(id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (NSString*)errorString
{
	return [NSString stringWithFormat:@"exceptionName %@\nReason: %@\n",
		[self name],
			([self reason] ? [self reason] : @"none")];
}

- (NSArray *)callStackReturnAddresses
{
	return returnAddresses;
}

- (NSArray *)callStackSymbols
{
	if (callStackSymbols != nil)
		return callStackSymbols;

	NSUInteger count = [returnAddresses count];
	callStackSymbols = [NSMutableArray new];
	NSUInteger *addrs = malloc([returnAddresses count] * sizeof(void *));
	for (NSUInteger i = count; i > 0; --i)
	{
		addrs[i - 1] = [[returnAddresses objectAtIndex:i-1] unsignedIntegerValue];
	}
	char **syms = backtrace_symbols((void **)addrs, count);
	for (NSUInteger i = 0; i < count; i++)
	{
		[callStackSymbols addObject:@(syms[i])];
	}
	free(syms);
	free(addrs);
	return callStackSymbols;
}

@end /* NSException (Extensions) */

@implementation NSStandardException : NSException
+(id)exceptionWithReason:(NSString *)_reason userInfo:(NSDictionary *)_info
{
	return [super exceptionWithName:NSStringFromClass(self)
		reason:_reason
		userInfo:_info];
}

@end

@implementation NSRuntimeException : NSStandardException
@end

@implementation NSInternalInconsistencyException : NSRuntimeException
@end

@implementation NSInvalidUseOfMethodException : NSRuntimeException
@end

@implementation NSInvalidArgumentException : NSRuntimeException
@end

@implementation NSMemoryException : NSStandardException
@end

@implementation NSRangeException : NSStandardException
@end

/*
 * Assertions.
 */

@implementation NSAssertionHandler

static id currentHandler = nil;

+ (void)initialize
{
	static bool initialized = false;

	if(!initialized)
	{
		initialized = true;
		currentHandler = [[self alloc] init];
	}
}

+ (NSAssertionHandler*)currentHandler
{
	return currentHandler;
}

- (void)handleFailureInFunction:(NSString*)functionName
	file:(NSString*)fileName
	lineNumber:(int)line
	description:(NSString*)format,...
{
	va_list ap;

	va_start(ap, format);
	NSLog(@"Assertion failed in file %@, line %d, function %@:",
			fileName, line, functionName);
	NSLogv(format, ap);
	va_end(ap);
	@throw([NSInternalInconsistencyException
			exceptionWithReason:[[NSString alloc] initWithFormat:format arguments:ap]
			userInfo:nil]);
}

- (void)handleFailureInMethod:(SEL)selector
	object:(id)object
	file:(NSString*)fileName
	lineNumber:(int)line
	description:(NSString*)format,...
{
	va_list ap;

	va_start(ap, format);
	NSLog(@"Assertion failed in file %@, line %d, method %@:",
			fileName, line, NSStringFromSelector(selector));
	NSLogv(format, ap);
	va_end(ap);
	@throw([NSInternalInconsistencyException
			exceptionWithReason:[[NSString alloc] initWithFormat:format arguments:ap]
					   userInfo:@{@"Object": object}]);
}

- (void)handleFailureInMethod:(SEL)selector
	object:(id)object
	exception:(Class)exceptCls
	userInfo:(NSDictionary *)uinfo
	file:(NSString*)fileName
	lineNumber:(int)line
	description:(NSString*)format,...
{
	va_list ap;

	va_start(ap, format);
	NSLog(@"Assertion failed in file %@, line %d, method %@:",
			fileName, line, NSStringFromSelector(selector));
	NSLogv(format, ap);
	va_end(ap);
	@throw([exceptCls
			exceptionWithReason:[[NSString alloc] initWithFormat:format arguments:ap]
				userInfo:uinfo]);
}

@end /* AssertionHandler */
