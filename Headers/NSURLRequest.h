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
#import <Foundation/NSDate.h>

@class NSURL,NSInputStream,NSMutableDictionary,NSDictionary;

typedef enum
{
	NSURLRequestUseProtocolCachePolicy = 0,
	NSURLRequestReloadIgnoringLocalCacheData = 1,
	NSURLRequestReloadIgnoringLocalAndRemoteCacheData = 4,
	NSURLRequestReloadIgnoringCacheData = NSURLRequestReloadIgnoringLocalCacheData,
	NSURLRequestReturnCacheDataElseLoad = 2,
	NSURLRequestReturnCacheDataDontLoad = 3,
	NSURLRequestReloadRevalidatingCacheData = 5
} NSURLRequestCachePolicy;

typedef enum
{
	NSURLNetworkServiceTypeDefault = 0,
	NSURLNetworkServiceTypeVoIP = 1,
	NSURLNetworkServiceTypeVideo = 2,
	NSURLNetworkServiceTypeBackground = 3,
	NSURLNetworkServiceTypeVoice = 4
} NSURLRequestNetworkServiceType;

@interface NSURLRequest : NSObject <NSCopying,NSMutableCopying>
{
	NSURL                  *_url;
	NSURLRequestCachePolicy _cachePolicy;
	NSTimeInterval          _timeoutInterval;
	NSString               *_method;
	id                      _bodyDataOrStream;
	NSMutableDictionary    *_headerFields;
	NSURL                  *_mainDocumentURL;
	bool                    _handleCookies;
}

+(id)requestWithURL:(NSURL *)url;
-(id)initWithURL:(NSURL *)url;

+(id)requestWithURL:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeout;
-(id)initWithURL:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeout;


-(NSURLRequestCachePolicy)cachePolicy;
-(bool) HTTPShouldUsePipelining;
-(NSURL *)mainDocumentURL;
-(NSTimeInterval)timeoutInterval;
-(NSURLRequestNetworkServiceType) networkServiceType;
-(NSURL *)URL;

-(NSDictionary *)allHTTPHeaderFields;
-(NSData *)HTTPBody;
-(NSInputStream *)HTTPBodyStream;
-(NSString *)HTTPMethod;
-(bool)HTTPShouldHandleCookies;
-(NSString *)valueForHTTPHeaderField:(NSString *)field;

@end

@interface NSMutableURLRequest : NSURLRequest

-(void)setCachePolicy:(NSURLRequestCachePolicy)value;
-(void)setURL:(NSURL *)value;
-(void)setTimeoutInterval:(NSTimeInterval)value;
-(void)setMainDocumentURL:(NSURL *)value;

-(void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
-(void)setAllHTTPHeaderFields:(NSDictionary *)allValues;
-(void)setHTTPBody:(NSData *)value;
-(void)setHTTPBodyStream:(NSInputStream *)value;
-(void)setHTTPMethod:(NSString *)value;
-(void)setHTTPShouldHandleCookies:(bool)value;
-(void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

@end
