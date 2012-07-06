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

#import <Foundation/NSDictionary.h>
#import <Foundation/NSValue.h>
#import "internal.h"

@implementation NSHTTPCookie
+ (NSArray *) cookiesWithResponseHeaderFields:(NSDictionary *)fields forURL:(NSURL *)url
{
	TODO;	// -[NSHTTPCookie cookiesWithResponseHeaderFields:forURL:]
	return nil;
}

+ (id) cookieWithProperties:(NSDictionary *)properties
{
	return [[self alloc] initWithProperties:properties];
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
	return [[self properties] objectForKey:NSHTTPCookieComment];
}

- (NSURL *) commentURL
{
	return [[self properties] objectForKey:NSHTTPCookieCommentURL];
}

- (NSString *) domain
{
	return [[self properties] objectForKey:NSHTTPCookieDomain];
}

- (NSDate *) expiresDate
{
	return [[self properties] objectForKey:NSHTTPCookieExpiresDate];
}

- (bool) isHTTPOnly
{
	return [[[self properties] objectForKey:NSHTTPCookieIsHTTPOnly] boolValue];
}

- (bool) isSecure
{
	return [[[self properties] objectForKey:NSHTTPCookieIsSecure] boolValue];
}

- (bool) isSessionOnly
{
	return [[[self properties] objectForKey:NSHTTPCookieIsSessionOnly] boolValue];
}

- (NSString *) name
{
	return [[self properties] objectForKey:NSHTTPCookieName];
}

- (NSString *) path
{
	return [[self properties] objectForKey:NSHTTPCookiePath];
}

- (NSArray *) portList
{
	return [[self properties] objectForKey:NSHTTPCookiePortList];
}

- (NSDictionary *) properties
{
	TODO;	// -[NSHTTPCookie properties]
	return nil;
}

- (NSString *) value
{
	return [[self properties] objectForKey:NSHTTPCookieValue];
}

- (NSUInteger) version
{
	return [[[self properties] objectForKey:NSHTTPCookieVersion] unsignedIntegerValue];
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
