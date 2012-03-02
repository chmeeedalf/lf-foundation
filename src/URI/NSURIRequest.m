/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSURIRequest.h>
#import <Foundation/NSMutableURIRequest.h>
#import <Foundation/NSURI.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSData.h>
#import <Foundation/NSString.h>

@implementation NSURIRequest

-(id)initWithURIRequest:(NSURIRequest *)other
{
   _url = [[other NSURI] copy];
   _cachePolicy = [other cachePolicy];
   _timeoutInterval = [other timeoutInterval];
   
   NSData *data = [other HTTPBody];
   if(data != nil)
    _bodyDataOrStream = [data copy];
   else
    _bodyDataOrStream = [other HTTPBodyStream];
   
   _headerFields = [[other allHTTPHeaderFields] mutableCopy];
   _method = [other HTTPMethod];
   _handleCookies = [other HTTPShouldHandleCookies];
   return self;
}

-(id)initWithURI:(NSURI *)url
{
   return [self initWithURI:url cachePolicy:NSURIRequestUseProtocolCachePolicy timeoutInterval:60];
}

-(id)initWithURI:(NSURI *)url cachePolicy:(NSURIRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeout
{
   _url = [url copy];
   _cachePolicy = cachePolicy;
   _timeoutInterval = timeout;
   _bodyDataOrStream = nil;
   _headerFields = [NSMutableDictionary new];
   _method = @"GET";
   _handleCookies = true;
   return self;
}

+(id)requestWithURI:(NSURI *)url
{
   return [[self alloc] initWithURI:url];
}

+(id)requestWithURI:(NSURI *)url cachePolicy:(NSURIRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeout
{
   return [[self alloc] initWithURI:url cachePolicy:cachePolicy timeoutInterval:timeout];
}

-(id)copyWithZone:(NSZone *)zone
{
   return self;
}

-(id)mutableCopyWithZone:(NSZone *)zone
{
   return [[NSMutableURIRequest alloc] initWithURIRequest:self];
}

-(NSURI *)NSURI
{
   return _url;
}

-(NSURIRequestCachePolicy)cachePolicy
{
   return _cachePolicy;
}

-(NSTimeInterval)timeoutInterval
{
   return _timeoutInterval;
}

-(NSString *)HTTPMethod
{
   return _method;
}

-(NSData *)HTTPBody
{
   if([_bodyDataOrStream isKindOfClass:[NSData class]])
    return _bodyDataOrStream;
    
   return nil;
}

-(NSInputStream *)HTTPBodyStream
{
   if([_bodyDataOrStream isKindOfClass:[NSInputStream class]])
    return _bodyDataOrStream;
    
   return nil;
}

-(NSDictionary *)allHTTPHeaderFields
{
   return _headerFields;
}

-(NSString *)valueForHTTPHeaderField:(NSString *)field
{
   field = [field uppercaseString];
   
   return [_headerFields objectForKey:field];
}

-(NSURI *)mainDocumentURI
{
   return _mainDocumentURI;
}

-(bool)HTTPShouldHandleCookies
{
   return _handleCookies;
}

@end
