/*
 * Copyright (c) 2012	Justin Hibbits
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

#import <Foundation/NSHTTPCookieStorage.h>

#import <Foundation/NSPredicate.h>
#import <Foundation/NSValue.h>

#import "NSSqlite.h"
#import "internal.h"

NSString * const NSHTTPCookieManagerCookiesChangedNotification = @"NSHTTPCookieManagerCookiesChangedNotification";
NSString * const NSHTTPCookieManagerAcceptPolicyChangedNotification = @"NSHTTPCookieManagerAcceptPolicyChangedNotification";
static NSString * const _NSGlobalHTTPCookieStorage = @"org.Gold.HTTPCookieStorage";

static NSHTTPCookieStorage *sharedStorage;

@implementation NSHTTPCookieStorage
{
	NSSqliteDatabase *storage;
	NSSqliteArray *policyArray;
	NSSqliteArray *storedCookies;
}

+ (void) initialize
{
	static bool initialized = false;

	if (initialized)
		return;
	sharedStorage = [[self alloc] init];
	initialized = true;
}

+ (id) sharedHTTPCookieStorage
{
	return sharedStorage;
}

- (id) init
{
	if (sharedStorage != nil)
		return sharedStorage;

	if ((self = [super init]) == nil)
		return nil;

	policyArray = [NSSqliteArray arrayWithTableName:@"storagePolicy" database:storage];
	[self setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain];
	return self;
}


- (NSHTTPCookieAcceptPolicy) cookieAcceptPolicy
{
	return [policyArray[0][@"policy"] integerValue];
}

- (void) setCookieAcceptPolicy:(NSHTTPCookieAcceptPolicy)newPol
{
	policyArray[0][@"storagePolicy"] = @(newPol);
}


- (void) deleteCookie:(NSHTTPCookie *)cookie
{
	[storedCookies removeObject:cookie];
}

- (void) setCookie:(NSHTTPCookie *)cookie
{
	TODO;	// -[NSHTTPCookieStorage setCookie:]
}

- (void) setCookies:(NSArray *)cookies forURL:(NSURL *)url mainDocumentURL:(NSURL *)mainDocURL
{
	if ([cookies count] == 0 || [self cookieAcceptPolicy] == NSHTTPCookieAcceptPolicyNever)
	{
		return;
	}

	if ([self cookieAcceptPolicy] == NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain &&
			![[url hostname] hasSuffix:[mainDocURL hostname]])
	{
		return;
	}

	for (id cookie in cookies)
	{
		[self setCookie:cookie];
	}
}


- (NSArray *) cookies
{
	return storedCookies;
}

- (NSArray *) cookiesForURL:(NSURL *)url
{
	return [storedCookies filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"URL BEGINSWITH \"%@\"",url]];
}

- (NSArray *) sortedCookiesUsingDescriptors:(NSArray *)sortDescs
{
	return [[self cookies] sortedArrayUsingDescriptors:sortDescs];
}

@end
