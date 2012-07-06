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

#import <Foundation/NSObject.h>

@class NSArray;
@class NSDate;
@class NSDictionary;
@class NSString;
@class NSURL;

@interface NSHTTPCookie	:	NSObject
+ (NSArray *) cookiesWithResponseHeaderFields:(NSDictionary *)fields forURL:(NSURL *)url;
+ (id) cookieWithProperties:(NSDictionary *)properties;
- (id) initWithProperties:(NSDictionary *)properties;

+ (NSDictionary *) requestHeaderFieldsWithCookies:(NSArray *)cookies;

- (NSString *) comment;
- (NSURL *) commentURL;
- (NSString *) domain;
- (NSDate *) expiresDate;
- (bool) isHTTPOnly;
- (bool) isSecure;
- (bool) isSessionOnly;
- (NSString *) name;
- (NSString *) path;
- (NSArray *) portList;
- (NSDictionary *) properties;
- (NSString *) value;
- (NSUInteger) version;
@end

extern NSString * const NSHTTPCookieComment;
extern NSString * const NSHTTPCookieCommentURL;
extern NSString * const NSHTTPCookieDomain;
extern NSString * const NSHTTPCookieExpiresDate;
extern NSString * const NSHTTPCookieIsHTTPOnly;
extern NSString * const NSHTTPCookieIsSecure;
extern NSString * const NSHTTPCookieIsSessionOnly;
extern NSString * const NSHTTPCookieName;
extern NSString * const NSHTTPCookiePath;
extern NSString * const NSHTTPCookiePortList;
extern NSString * const NSHTTPCookieProperties;
extern NSString * const NSHTTPCookieValue;
extern NSString * const NSHTTPCookieVersion;
