/* Copyright (c) 2008 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import "NSURIConnectionState.h"
#import <Foundation/NSURIConnection.h>
#import <Foundation/NSURIAuthenticationChallenge.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSError.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSData.h>
#import <Foundation/NSString.h>

@implementation NSURIConnectionState

-init
{
	_isRunning=true;
	_response=nil;
	_error=nil;
	_data=[[NSMutableData alloc] init];
	return self;
}

-(void)dealloc
{
	[_response release];
	[_error release];
	[_data release];
	[super dealloc];
}

-(bool)isRunning
{
	return _isRunning;
}

-(void)receiveAllDataInMode:(NSString *)mode
{
	while (  [self isRunning] )
	{
		[[NSRunLoop currentRunLoop] runMode:mode beforeDate:[NSDate distantFuture]];
		//		Log(@"loop did run");
	}
	NSLog(@"done %d",_isRunning);

}

-(NSURIResponse *)response
{
	return _response;
}

-(NSError *)error
{
	return _error;
}

-(NSMutableData *)data
{
	return _data;
}

-(void)connection:(NSURIConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"connection didFailWithError: %@",error);
	_isRunning=false;
	_error=[error retain];
}

-(void)connection:(NSURIConnection *)connection didReceiveAuthenticationChallenge:(NSURIAuthenticationChallenge *)challenge
{
}

-(void)connection:(NSURIConnection *)connection didCancelAuthenticationChallenge:(NSURIAuthenticationChallenge *)challenge
{
}

-(void)connection:(NSURIConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"connection didReceiveData: %d",[data length]);
	[_data appendData:data];
}

-(void)connection:(NSURIConnection *)connection didReceiveResponse:(NSURIResponse *)response
{
	NSLog(@"connection didReceiveResponse: %@",response);
}

-(NSCachedURIResponse *)connection:(NSURIConnection *)connection willCacheResponse:(NSCachedURIResponse *)response
{
	return response;
}

-(NSURIRequest *)connection:(NSURIConnection *)connection willSendRequest:(NSURIRequest *)request redirectResponse:(NSURIResponse *)response
{
	return request;
}

- (void)connectionDidFinishLoading:(NSURIConnection *)connection
{
	NSLog(@"connection connectionDidFinishLoading");

	_isRunning=false;
}

@end
