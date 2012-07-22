/*
 * Copyright (c) 2011-2012	Justin Hibbits
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

#import <Foundation/NSDelegate.h>
#import <Foundation/NSURLDownload.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSURLRequest.h>
#import <Foundation/NSURLConnection.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSData.h>
#import "internal.h"

@implementation NSURLDownload
{
	NSURLRequest    *request;
	id               delegate;
	bool             deletesOnFailure;
	NSURL	        *path;
	bool             allowOverwrite;
	NSData          *resumeData;
	NSURLConnection *connection;
	NSOutputStream  *fileStream;
}


+(bool)canResumeDownloadDecodedWithEncodingMIMEType:(NSString *)mimeType
{
	TODO; // +[NSURLDownload canResumeDownloadDecodedWithEncodingMIMEType:]
	return false;
}

-(id)initWithRequest:(NSURLRequest *)req delegate:(id<NSURLDownloadDelegate>)del
{
	request = [req copy];
	delegate = del;
	return self;
}

-(id)initWithResumeData:(NSData *)data delegate:(id<NSURLDownloadDelegate>)delegate path:(NSString *)path
{
	TODO;	// -[NSURLDownload initWithResumeData:delegate:path:]
	return self;
}

-(NSURLRequest *)request
{
	return request;
}

-(NSData *)resumeData
{
	TODO; // -[NSURLDownload resumeData]
	return nil;
}

-(bool)deletesFileUponFailure
{
	return deletesOnFailure;
}

-(void)setDeletesFileUponFailure:(bool)flag
{
	deletesOnFailure = flag;
}

-(void)setDestination:(NSString *)dst allowOverwrite:(bool)flag
{
	if (path == nil)
	{
		path = [NSURL fileURLWithPath:dst];
		allowOverwrite = flag;
	}
}

-(void)cancel
{
	TODO; // -[NSURLDownload cancel]
}

@end
