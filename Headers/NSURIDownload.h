/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSObject.h>
#import <Foundation/NSURIConnection.h>

@class NSURI,NSURIRequest,NSURIResponse,NSURIAuthenticationChallenge,NSData,NSError,NSURIConnection,NSOutputStream;
@protocol NSURIDownloadDelegate;

@interface NSURIDownload : NSObject<NSURIConnectionDelegate>
{
	NSURIRequest *_request;
	id<NSURIDownloadDelegate>   _delegate;
	bool _deletesOnFailure;
	NSURI	 *_path;
	bool      _allowOverwrite;
	NSURIConnection *_connection;
	NSOutputStream        *_fileStream;
}

+(bool)canResumeDownloadDecodedWithEncodingMIMEType:(NSString *)mimeType;

-initWithRequest:(NSURIRequest *)requst delegate:(id<NSURIDownloadDelegate>)delegate;
-initWithResumeData:(NSData *)data delegate:(id<NSURIDownloadDelegate>)delegate path:(NSString *)path;

-(NSURIRequest *)request;
-(NSData *)resumeData;

-(bool)deletesFileUponFailure;

-(void)setDeletesFileUponFailure:(bool)flag;
-(void)setDestination:(NSString *)path allowOverwrite:(bool)allowOverwrite;

-(void)cancel;

@end

@protocol NSURIDownloadDelegate<NSObject>
-(void)downloadDidBegin:(NSURIDownload *)download;
-(NSURIRequest *)download:(NSURIDownload *)download willSendRequest:(NSURIRequest *)request redirectResponse:(NSURIResponse *)redirect;
-(void)download:(NSURIDownload *)download didReceiveAuthenticationChallenge:(NSURIAuthenticationChallenge *)authChallenge;
-(void)download:(NSURIDownload *)download didCancelAuthenticationChallenge:(NSURIAuthenticationChallenge *)authChallenge;
-(void)download:(NSURIDownload *)download didReceiveResponse:(NSURIResponse *)response;
-(void)download:(NSURIDownload *)download didReceiveDataOfLength:(unsigned long)length;

-(void)download:(NSURIDownload *)download didFailWithError:(NSError *)error;
-(void)downloadDidFinish:(NSURIDownload *)download;

-(void)download:(NSURIDownload *)download decideDestinationWithSuggestedFilename:(NSString *)suggested;
-(void)download:(NSURIDownload *)download didCreateDestination:(NSURI *)destPath;
-(bool)download:(NSURIDownload *)download shouldDecodeSourceDataOfMIMEType:(NSString *)mimeType;

-(void)download:(NSURIDownload *)download willResumeWithResponse:(NSURIResponse *)response fromByte:(long long)position;

-(void)download:(NSURIDownload *)download didReceiveDataOfLength:(unsigned long)length;

@end
