/*
 * Copyright (c) 2008-2012	Justin Hibbits
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
#import <Foundation/NSURLConnection.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSHost.h>
#import <Foundation/NSOperation.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSURLRequest.h>
#import <Foundation/NSURLProtocol.h>
#import <Foundation/NSValue.h>
#import "internal.h"

@interface NSURLProtocol(private)
+(Class)_URLProtocolClassForRequest:(NSURLRequest *)request;
@end

@interface NSURLConnection(private) <NSURLProtocolClient>
@end

@implementation NSURLConnection
{
	NSURLRequest  *_request;
	NSURLProtocol *_protocol;
	id<NSURLConnectionDelegate>             _delegate;
	NSMutableArray *_modes;
	NSInputStream  *_inputStream;
	NSOutputStream *_outputStream;
}

+(bool)canHandleRequest:(NSURLRequest *)request
{
	return ([NSURLProtocol _URLProtocolClassForRequest:request] != nil)?true:false;
}

+(NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)responsep error:(NSError **)errorp
{
	TODO; // +[NSURLConnection sendSynchronousRequest:returningResponse:error:]
	return nil;
}

+(NSURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate
{
	return [[self alloc] initWithRequest:request delegate:delegate];
}

-(id)initWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate startImmediately:(bool)startLoading
{
	if ((self = [super init]) == nil)
	{
		return nil;
	}

	_request = [request copy];
	Class cls = [NSURLProtocol _URLProtocolClassForRequest:request];
	_protocol = [[cls alloc] initWithRequest:_request cachedResponse:nil client:self];
	_delegate = delegate;
	_modes = [[NSMutableArray alloc] initWithObjects:NSDefaultRunLoopMode,nil];
	if(startLoading)
		[self start];
	return self;
}

-(id)initWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate
{
	return [self initWithRequest:request delegate:delegate startImmediately:true];
}

-(void)start
{
	NSURL    *url = [_request URL];
	NSString *hostName = [url hostname];
	NSNumber *portNumber = [url port];
	NSInputStream *inStream;
	NSOutputStream *outStream;

	if(portNumber == nil)
		portNumber = @(80);

	NSHost *host = [NSHost hostWithName:hostName];

	[NSStream getStreamsToHost:host port:[portNumber intValue] inputStream:&inStream outputStream:&outStream];
	_inputStream = inStream;
	_outputStream = outStream;
	[_inputStream setDelegate:_protocol];
	[_outputStream setDelegate:_protocol];

	for(NSString *mode in _modes)
	{
		[_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
		[_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
	}

	[_inputStream open];
	[_outputStream open];
	//	Log(@"input stream %@",_inputStream);

	NSLog(@"start -> startLoading");
	[_protocol startLoading];
}

-(void)cancel
{
	[_protocol stopLoading];

	[_inputStream setDelegate:nil];
	[_outputStream setDelegate:nil];
	for (NSString *mode in _modes)
	{
		[_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
		[_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
	}
}

-(void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode
{
	[_inputStream scheduleInRunLoop:runLoop forMode:mode];
	[_outputStream scheduleInRunLoop:runLoop forMode:mode];
}

-(void)unscheduleFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode
{
	[_inputStream removeFromRunLoop:runLoop forMode:mode];
	[_outputStream removeFromRunLoop:runLoop forMode:mode];
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol wasRedirectedToRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirect
{
	[_delegate connection:self willSendRequest:request redirectResponse:redirect];
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	[_delegate connection:self didReceiveAuthenticationChallenge:challenge];
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	[_delegate connection:self didCancelAuthenticationChallenge:challenge];
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol didReceiveResponse:(NSURLResponse *)response cacheStoragePolicy:(NSURLCacheStoragePolicy)policy
{
	// [_delegate connection:self ];
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol cachedResponseIsValid:(NSCachedURLResponse *)response
{
	// [_delegate connection:self];
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol didLoadData:(NSData *)data
{
	NSLog(@"URLProtocol:didLoadData:");
	[_delegate connection:self didReceiveData:data];
}

-(void)URLProtocol:(NSURLProtocol *)urlProtocol didFailWithError:(NSError *)error
{
	[_delegate connection:self didFailWithError:error];
}

-(void)URLProtocolDidFinishLoading:(NSURLProtocol *)urlProtocol
{
	NSLog(@"URLProtocolDidFinishLoading:");
	if([_delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
		  [_delegate performSelector:@selector(connectionDidFinishLoading:) withObject:self];
}

-(void) setDelegateQueue:(NSOperationQueue *)queue
{
	TODO; // -[NSURLConnection setDelegateQueue:];
}

+ (void) sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler
{
	[queue addOperationWithBlock:^()
	{
		NSURLResponse *resp;
		NSError *err;
		NSData *d;

		d = [self sendSynchronousRequest:request returningResponse:&resp error:&err];
		handler(resp, d, err);
	}];
}
@end
