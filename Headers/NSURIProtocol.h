/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSObject.h>
#import <Foundation/NSCachedURIResponse.h>

@class NSURIProtocol,NSURIRequest,NSURIResponse,NSURIAuthenticationChallenge,NSCachedURIResponse,NSData,NSError,NSMutableURIRequest;

@protocol NSURIProtocolClient
-(void)URIProtocol:(NSURIProtocol *)urlProtocol wasRedirectedToRequest:(NSURIRequest *)request redirectResponse:(NSURIResponse *)redirect;
-(void)URIProtocol:(NSURIProtocol *)urlProtocol didReceiveAuthenticationChallenge:(NSURIAuthenticationChallenge *)challenge;
-(void)URIProtocol:(NSURIProtocol *)urlProtocol didCancelAuthenticationChallenge:(NSURIAuthenticationChallenge *)challenge;
-(void)URIProtocol:(NSURIProtocol *)urlProtocol didReceiveResponse:(NSURIResponse *)response cacheStoragePolicy:(NSURICacheStoragePolicy)policy;
-(void)URIProtocol:(NSURIProtocol *)urlProtocol cachedResponseIsValid:(NSCachedURIResponse *)response;
-(void)URIProtocol:(NSURIProtocol *)urlProtocol didLoadData:(NSData *)data;
-(void)URIProtocol:(NSURIProtocol *)urlProtocol didFailWithError:(NSError *)error;
-(void)URIProtocolDidFinishLoading:(NSURIProtocol *)urlProtocol;
@end

@interface NSURIProtocol : NSObject
{
	NSURIRequest            *_request;
	NSCachedURIResponse     *_response;
	id <NSURIProtocolClient> _client;
}

+(bool)registerClass:(Class)cls;
+(void)unregisterClass:(Class)cls;

+propertyForKey:(NSString *)key inRequest:(NSURIRequest *)request;
+(void)removePropertyForKey:(NSString *)key inRequest:(NSMutableURIRequest *)request;
+(void)setProperty:value forKey:(NSString *)key inRequest:(NSMutableURIRequest *)request;

+(bool)canInitWithRequest:(NSURIRequest *)request;
+(NSURIRequest *)canonicalRequestForRequest:(NSURIRequest *)request;
+(bool)requestIsCacheEquivalent:(NSURIRequest *)request toRequest:(NSURIRequest *)other;

-initWithRequest:(NSURIRequest *)request cachedResponse:(NSCachedURIResponse *)response client:(id <NSURIProtocolClient>)client;

-(NSURIRequest *)request;
-(NSCachedURIResponse *)cachedResponse;
-(id <NSURIProtocolClient>)client;

-(void)startLoading;
-(void)stopLoading;

@end
