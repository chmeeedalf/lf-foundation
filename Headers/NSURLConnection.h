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

#import <Foundation/NSObject.h>

@class NSInputStream,NSOutputStream;
@class NSRunLoop;
@class NSURLRequest,NSURLResponse,NSCachedURLResponse,NSURLProtocol;
@class NSURLAuthenticationChallenge, NSURLProtectionSpace;
@class NSOperationQueue;
@class NSData;
@class NSError;
@class NSMutableArray;
@protocol NSURLConnectionDelegate;

@interface NSURLConnection : NSObject
{
	NSURLRequest  *_request;
	NSURLProtocol *_protocol;
	id<NSURLConnectionDelegate>             _delegate;
	NSMutableArray *_modes;
	NSInputStream  *_inputStream;
	NSOutputStream *_outputStream;
}

+(bool)canHandleRequest:(NSURLRequest *)request;

+(NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;

+(NSURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate;
-(id)initWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate;
-(id)initWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate startImmediately:(bool)startLoading;

+ (void) sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler;
-(void)start;

-(void)cancel;

-(void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
-(void) setDelegateQueue:(NSOperationQueue *)queue;
-(void)unscheduleFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;

@end

@protocol NSURLConnectionDelegate<NSObject>
@optional
-(void) connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
-(bool) connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)space;
-(void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
-(bool)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (NSURLRequest *) connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
@end
