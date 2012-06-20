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

#import <Foundation/NSHTTPCookie.h>
#import "internal.h"

@implementation NSHTTPCookie
+ (NSArray *) cookiesWithResponseHeaderFields:(NSDictionary *)fields forURL:(NSURL *)url
{
	TODO;	// -[NSHTTPCookie cookiesWithResponseHeaderFields:forURL:]
	return nil;
}

+ (id) cookieWithProperties:(NSDictionary *)properties
{
	TODO;	// -[NSHTTPCookie cookieWithProperties:]
	return nil;
}

- (id) initWithProperties:(NSDictionary *)properties
{
	TODO;	// -[NSHTTPCookie initWithProperties:]
	return nil;
}


+ (NSDictionary *) requestHeaderFieldsWithCookies:(NSArray *)cookies
{
	TODO;	// -[NSHTTPCookie requestHeaderFieldsWithCookies:]
	return nil;
}


- (NSString *) comment
{
	TODO;	// -[NSHTTPCookie comment]
	return nil;
}

- (NSURL *) commentURL
{
	TODO;	// -[NSHTTPCookie commentURL]
	return nil;
}

- (NSString *) domain
{
	TODO;	// -[NSHTTPCookie domain]
	return nil;
}

- (NSDate *) expiresDate
{
	TODO;	// -[NSHTTPCookie expiresDate]
	return nil;
}

- (bool) isHTTPOnly
{
	TODO;	// -[NSHTTPCookie isHTTPOnly]
	return false;
}

- (bool) isSecure
{
	TODO;	// -[NSHTTPCookie isSecure]
	return false;
}

- (bool) isSessionOnly
{
	TODO;	// -[NSHTTPCookie isSessionOnly]
	return false;
}

- (NSString *) name
{
	TODO;	// -[NSHTTPCookie name]
	return nil;
}

- (NSString *) path
{
	TODO;	// -[NSHTTPCookie path]
	return nil;
}

- (NSArray *) portList
{
	TODO;	// -[NSHTTPCookie portList]
	return nil;
}

- (NSDictionary *) properties
{
	TODO;	// -[NSHTTPCookie properties]
	return nil;
}

- (NSString *) value
{
	TODO;	// -[NSHTTPCookie value]
	return nil;
}

- (NSUInteger) version
{
	TODO;	// -[NSHTTPCookie version]
	return 0;
}

- (id) copyWithZone:(NSZone *)zone
{
	TODO;	// -[NSHTTPCookie<NSCopying> copyWithZone:]
	return nil;
}
@end

NSString * const NSHTTPCookieComment = @"NSHTTPCookieComment";
NSString * const NSHTTPCookieCommentURL = @"NSHTTPCookieCommentURL";
NSString * const NSHTTPCookieDomain = @"NSHTTPCookieDomain";
NSString * const NSHTTPCookieExpiresDate = @"NSHTTPCookieExpiresDate";
NSString * const NSHTTPCookieIsHTTPOnly = @"NSHTTPCookieIsHTTPOnly";
NSString * const NSHTTPCookieIsSecure = @"NSHTTPCookieIsSecure";
NSString * const NSHTTPCookieIsSessionOnly = @"NSHTTPCookieIsSessionOnly";
NSString * const NSHTTPCookieName = @"NSHTTPCookieName";
NSString * const NSHTTPCookiePath = @"NSHTTPCookiePath";
NSString * const NSHTTPCookiePortList = @"NSHTTPCookiePortList";
NSString * const NSHTTPCookieProperties = @"NSHTTPCookieProperties";
NSString * const NSHTTPCookieValue = @"NSHTTPCookieValue";
NSString * const NSHTTPCookieVersion = @"NSHTTPCookieVersion";
