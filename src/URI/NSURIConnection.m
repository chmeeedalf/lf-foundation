/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import "internal.h"
#import <Foundation/NSURIConnection.h>
#import <Foundation/NSURIRequest.h>
#import <Foundation/NSURIProtocol.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSHost.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURI.h>
#import "NSURIConnectionState.h"

@interface NSURIProtocol(private)
+(Class)_URIProtocolClassForRequest:(NSURIRequest *)request;
@end;

@interface NSURIConnection(private) <NSURIProtocolClient>
@end

@implementation NSURIConnection

+(bool)canHandleRequest:(NSURIRequest *)request
{
	return ([NSURIProtocol _URIProtocolClassForRequest:request]!=nil)?true:false;
}

+(NSData *)sendSynchronousRequest:(NSURIRequest *)request returningResponse:(NSURIResponse **)responsep error:(NSError **)errorp
{
	NSURIConnectionState *state=[[NSURIConnectionState alloc] init];
	NSURIConnection      *connection=[[self alloc] initWithRequest:request delegate:state];
	NSString *mode=@"NSURIConnectionRequestMode";

	[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];

	[state receiveAllDataInMode:mode];
	[connection unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:mode];


	[connection cancel];
	[connection release];

	if(errorp!=NULL)
		*errorp=[state error];
	if(responsep!=NULL)
		*responsep=[state response];

	NSData *d = [state data];
	[state release];
	return d;
}

+(NSURIConnection *)connectionWithRequest:(NSURIRequest *)request delegate:(id<NSURIConnectionDelegate>)delegate
{
	return [[[self alloc] initWithRequest:request delegate:delegate] autorelease];
}

-initWithRequest:(NSURIRequest *)request delegate:(id<NSURIConnectionDelegate>)delegate startImmediately:(bool)startLoading
{
	_request=[request copy];
	Class cls=[NSURIProtocol _URIProtocolClassForRequest:request];
	_protocol=[[cls alloc] initWithRequest:_request cachedResponse:nil client:self];
	_delegate=delegate;
	_modes=[[NSMutableArray alloc] initWithObjects:NSDefaultRunLoopMode,nil];
	if(startLoading)
		[self start];
	return self;
}

-initWithRequest:(NSURIRequest *)request delegate:(id<NSURIConnectionDelegate>)delegate
{
	return [self initWithRequest:request delegate:delegate startImmediately:true];
}

-(void)dealloc
{
	[_request release];
	[_protocol release];
	_delegate=nil;
	[_modes release];
	[_inputStream release];
	[_outputStream release];
	[super dealloc];
}

-(void)start
{
	NSURI    *url=[_request NSURI];
	NSString *hostName=[url hostname];
	NSNumber *portNumber=[url port];

	if(portNumber==nil)
		portNumber=[NSNumber numberWithInt:80];

	NSHost *host=[NSHost hostWithName:hostName];

	[NSStream getStreamsToHost:host port:[portNumber intValue] inputStream:&_inputStream outputStream:&_outputStream];
	[_inputStream setDelegate:_protocol];
	[_outputStream setDelegate:_protocol];

	for(NSString *mode in _modes)
	{
		[_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
		[_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
	}

	[_inputStream retain];
	[_outputStream retain];
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
	for(NSString *mode in _modes)
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

-(void)URIProtocol:(NSURIProtocol *)urlProtocol wasRedirectedToRequest:(NSURIRequest *)request redirectResponse:(NSURIResponse *)redirect
{
	[_delegate connection:self willSendRequest:request redirectResponse:redirect];
}

-(void)URIProtocol:(NSURIProtocol *)urlProtocol didReceiveAuthenticationChallenge:(NSURIAuthenticationChallenge *)challenge
{
	// [_delegate connection:self didReceiveAuthenticationChallenge];
}

-(void)URIProtocol:(NSURIProtocol *)urlProtocol didCancelAuthenticationChallenge:(NSURIAuthenticationChallenge *)challenge
{
	// [_delegate connection:self didCancelAuthenticationChallenge];
}

-(void)URIProtocol:(NSURIProtocol *)urlProtocol didReceiveResponse:(NSURIResponse *)response cacheStoragePolicy:(NSURICacheStoragePolicy)policy
{
	// [_delegate connection:self ];
}

-(void)URIProtocol:(NSURIProtocol *)urlProtocol cachedResponseIsValid:(NSCachedURIResponse *)response
{
	// [_delegate connection:self];
}

-(void)URIProtocol:(NSURIProtocol *)urlProtocol didLoadData:(NSData *)data
{
	NSLog(@"NSURIProtocol:didLoadData:");
	[_delegate connection:self didReceiveData:data];
}

-(void)URIProtocol:(NSURIProtocol *)urlProtocol didFailWithError:(NSError *)error
{
	[_delegate connection:self didFailWithError:error];
}

-(void)URIProtocolDidFinishLoading:(NSURIProtocol *)urlProtocol
{
	NSLog(@"NSURIProtocolDidFinishLoading:");
	if([_delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
		  [_delegate performSelector:@selector(connectionDidFinishLoading:) withObject:self];
}


@end
