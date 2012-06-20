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
#import "internal.h"

NSString * const NSHTTPCookieManagerCookiesChangedNotification = @"NSHTTPCookieManagerCookiesChangedNotification";
NSString * const NSHTTPCookieManagerAcceptPolicyChangedNotification = @"NSHTTPCookieManagerAcceptPolicyChangedNotification";

@implementation NSHTTPCookieStorage
+ (id) sharedHTTPCookieStorage
{
	TODO;	// +[NSHTTPCookieStorage sharedHTTPCookieStorage]
	return nil;
}


- (NSHTTPCookieAcceptPolicy) cookieAcceptPolicy
{
	TODO;	// -[NSHTTPCookieStorage cookieAcceptPolicy]
	return NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain;
}

- (void) setCookieAcceptPolicy:(NSHTTPCookieAcceptPolicy)policy
{
	TODO;	// -[NSHTTPCookieStorage setCookieAcceptPolicy:]
}


- (void) deleteCookie:(NSHTTPCookie *)cookie
{
	TODO;	// -[NSHTTPCookieStorage deleteCookie:]
}

- (void) setCookie:(NSHTTPCookie *)cookie
{
	TODO;	// -[NSHTTPCookieStorage setCookie:]
}

- (void) setCookies:(NSArray *)cookies forURL:(NSURL *)url mainDocumentURL:(NSURL *)mainDocURL
{
	TODO;	// -[NSHTTPCookieStorage setCookies:forURL:mainDocumentURL:]
}


- (NSArray *) cookies
{
	TODO;	// -[NSHTTPCookieStorage cookies]
	return nil;
}

- (NSArray *) cookiesForURL:(NSURL *)url
{
	TODO;	// -[NSHTTPCookieStorage cookiesForURL:]
	return nil;
}

- (NSArray *) sortedCookiesUsingDescriptors:(NSArray *)sortDescs
{
	TODO;	// -[NSHTTPCookieStorage sortedCookiesUsingDescriptors:]
	return nil;
}

@end
