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
#import <Foundation/NSURLConnection.h>

@class NSURL,NSURLRequest,NSURLResponse,NSURLAuthenticationChallenge,NSData,NSError,NSURLConnection,NSOutputStream;
@protocol NSURLDownloadDelegate;

@interface NSURLDownload : NSObject<NSURLConnectionDelegate>
{
	NSURLRequest *_request;
	id<NSURLDownloadDelegate>   _delegate;
	bool _deletesOnFailure;
	NSURL	 *_path;
	bool      _allowOverwrite;
	NSURLConnection *_connection;
	NSOutputStream        *_fileStream;
}

-(id)initWithRequest:(NSURLRequest *)requst delegate:(id<NSURLDownloadDelegate>)delegate;

+(bool)canResumeDownloadDecodedWithEncodingMIMEType:(NSString *)mimeType;
-(id)initWithResumeData:(NSData *)data delegate:(id<NSURLDownloadDelegate>)delegate path:(NSString *)path;
-(NSData *)resumeData;
-(void)setDeletesFileUponFailure:(bool)flag;
-(bool)deletesFileUponFailure;

-(void)cancel;

-(NSURLRequest *)request;

-(void)setDestination:(NSString *)path allowOverwrite:(bool)allowOverwrite;

@end

@protocol NSURLDownloadDelegate<NSObject>
-(void)downloadDidBegin:(NSURLDownload *)download;
-(NSURLRequest *)download:(NSURLDownload *)download willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirect;
-(void)download:(NSURLDownload *)download didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)authChallenge;
-(void)download:(NSURLDownload *)download didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)authChallenge;
-(void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response;
-(void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned long)length;

-(void)download:(NSURLDownload *)download didFailWithError:(NSError *)error;
-(void)downloadDidFinish:(NSURLDownload *)download;

-(void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)suggested;
-(void)download:(NSURLDownload *)download didCreateDestination:(NSURL *)destPath;
-(bool)download:(NSURLDownload *)download shouldDecodeSourceDataOfMIMEType:(NSString *)mimeType;

-(void)download:(NSURLDownload *)download willResumeWithResponse:(NSURLResponse *)response fromByte:(long long)position;

-(void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned long)length;

@end
