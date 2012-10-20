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

/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Foundation/NSURLRequest.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSData.h>
#import <Foundation/NSString.h>
#import "internal.h"

@implementation NSURLRequest
{
	@protected
	NSURL                  *url;
	NSURLRequestCachePolicy cachePolicy;
	NSTimeInterval          timeoutInterval;
	NSString               *method;
	NSData                 *bodyData;
	NSInputStream          *bodyStream;
	NSMutableDictionary    *headerFields;
	NSURL                  *mainDocumentURL;
	NSURLRequestNetworkServiceType netServiceType;
	bool                    usePipeline;
	bool                    handleCookies;
}

-(id)initWithURLRequest:(NSURLRequest *)other
{
	url = [[other URL] copy];
	cachePolicy = [other cachePolicy];
	timeoutInterval = [other timeoutInterval];

	bodyData = [other HTTPBody];
	bodyStream = [other HTTPBodyStream];

	headerFields = [[other allHTTPHeaderFields] mutableCopy];
	method = [other HTTPMethod];
	handleCookies = [other HTTPShouldHandleCookies];
	return self;
}

-(id)initWithURL:(NSURL *)newURL
{
   return [self initWithURL:newURL cachePolicy:NSURLRequestUseProtocolCachePolicy
   			timeoutInterval:60];
}

-(id)initWithURL:(NSURL *)newURL
	 cachePolicy:(NSURLRequestCachePolicy)cp
 timeoutInterval:(NSTimeInterval)timeout
{
   url = [newURL copy];
   cachePolicy = cp;
   timeoutInterval = timeout;
   headerFields = [NSMutableDictionary new];
   method = @"GET";
   handleCookies = true;
   return self;
}

+(id)requestWithURL:(NSURL *)url
{
   return [[self alloc] initWithURL:url];
}

+(id)requestWithURL:(NSURL *)url
		cachePolicy:(NSURLRequestCachePolicy)cachePolicy
	timeoutInterval:(NSTimeInterval)timeout
{
   return [[self alloc] initWithURL:url cachePolicy:cachePolicy timeoutInterval:timeout];
}

-(id)copyWithZone:(NSZone *)zone
{
   return self;
}

-(id)mutableCopyWithZone:(NSZone *)zone
{
   return [[NSMutableURLRequest alloc] initWithURLRequest:self];
}

-(NSURL *)URL
{
   return url;
}

-(NSURLRequestCachePolicy)cachePolicy
{
   return cachePolicy;
}

-(NSTimeInterval)timeoutInterval
{
   return timeoutInterval;
}

-(NSString *)HTTPMethod
{
   return method;
}

-(NSData *)HTTPBody
{
	return bodyData;
}

-(NSInputStream *)HTTPBodyStream
{
	return bodyStream;
}

-(NSDictionary *)allHTTPHeaderFields
{
	return headerFields;
}

-(NSString *)valueForHTTPHeaderField:(NSString *)field
{
	field = [field uppercaseString];

	return [headerFields objectForKey:field];
}

-(NSURL *)mainDocumentURL
{
	return mainDocumentURL;
}

-(bool)HTTPShouldHandleCookies
{
	return handleCookies;
}

-(bool) HTTPShouldUsePipelining
{
	return usePipeline;
}

-(NSURLRequestNetworkServiceType) networkServiceType
{
	return netServiceType;
}
@end

@implementation NSMutableURLRequest

-(id)copyWithZone:(NSZone *)zone
{
	return [[NSURLRequest alloc] initWithURLRequest:self];
}

-(void)setURL:(NSURL *)value
{
	value = [value copy];
	url = value;
}

-(void)setCachePolicy:(NSURLRequestCachePolicy)value
{
	cachePolicy = value;
}

-(void)setTimeoutInterval:(NSTimeInterval)value
{
	timeoutInterval = value;
}

-(void)setHTTPMethod:(NSString *)value
{
	value = [value copy];
	method = value;
}

-(void)setHTTPBody:(NSData *)value
{
	bodyData = [value copy];
	bodyStream = nil;
}

-(void)setHTTPBodyStream:(NSInputStream *)value
{
	bodyStream = value;
	bodyData = nil;
}

-(void)setAllHTTPHeaderFields:(NSDictionary *)allValues
{
	NSString     *key;

	[headerFields removeAllObjects];
	for (key in allValues)
	{
		NSString *value = [allValues objectForKey:key];

		if([key isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]])
		{
			[headerFields setObject:value forKey:[key uppercaseString]];
		}
	}
}

-(void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
	field = [field uppercaseString];

	[headerFields setObject:value forKey:field];
}

-(void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
	NSString *existing;

	field = [field uppercaseString];
	existing = [headerFields objectForKey:field];
	if(existing != nil)
		value = [[existing stringByAppendingString:@","] stringByAppendingString:value];

	[headerFields setObject:value forKey:field];
}

-(void)setHTTPShouldHandleCookies:(bool)value
{
	handleCookies = value;
}

-(void)setMainDocumentURL:(NSURL *)value
{
	mainDocumentURL = [value copy];
}

-(void)setHTTPShouldUsePipelining:(bool)use
{
	usePipeline = use;
}

- (void) setNetworkServiceType:(NSURLRequestNetworkServiceType)type
{
	netServiceType = type;
}

@end
