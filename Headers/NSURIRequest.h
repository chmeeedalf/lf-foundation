/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>

@class NSURI,NSInputStream,NSMutableDictionary,NSDictionary;

typedef enum
{
	NSURIRequestUseProtocolCachePolicy,
	NSURIRequestReloadIgnoringCacheData,
	NSURIRequestReturnCacheDataElseLoad,
	NSURIRequestReturnCacheDataDontLoad
} NSURIRequestCachePolicy;

@interface NSURIRequest : NSObject <NSCopying,NSMutableCopying>
{
	NSURI                  *_url;
	NSURIRequestCachePolicy _cachePolicy;
	NSTimeInterval          _timeoutInterval;
	NSString               *_method;
	id                      _bodyDataOrStream;
	NSMutableDictionary    *_headerFields;
	NSURI                  *_mainDocumentURI;
	bool                    _handleCookies;
}

-initWithURI:(NSURI *)url;
-initWithURI:(NSURI *)url cachePolicy:(NSURIRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeout;

+requestWithURI:(NSURI *)url;
+requestWithURI:(NSURI *)url cachePolicy:(NSURIRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeout;

-(NSURI *)NSURI;
-(NSURIRequestCachePolicy)cachePolicy;
-(NSTimeInterval)timeoutInterval;

-(NSString *)HTTPMethod;
-(NSData *)HTTPBody;
-(NSInputStream *)HTTPBodyStream;

-(NSDictionary *)allHTTPHeaderFields;
-(NSString *)valueForHTTPHeaderField:(NSString *)field;

-(NSURI *)mainDocumentURI;

-(bool)HTTPShouldHandleCookies;

@end
