/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSURIDownload.h>
#import <Foundation/NSURI.h>
#import <Foundation/NSURIRequest.h>
#import <Foundation/NSURIConnection.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSPathUtilities.h>
//#import <Foundation/NSOutputStream.h>
#import <Foundation/NSData.h>

@implementation NSURIDownload

+(bool)canResumeDownloadDecodedWithEncodingMIMEType:(NSString *)mimeType
{
	return true;
}

-initWithRequest:(NSURIRequest *)request delegate:(id<NSURIDownloadDelegate>)delegate
{
	_request=[request copy];
	_delegate=delegate;
	_connection=[[NSURIConnection alloc] initWithRequest:_request delegate:self startImmediately:true];
	return self;
}

-initWithResumeData:(NSData *)data delegate:(id<NSURIDownloadDelegate>)delegate path:(NSString *)path
{
	[self notImplemented:_cmd];
	return false;
}

-(NSURIRequest *)request
{
	return _request;
}

-(NSData *)resumeData
{
	[self notImplemented:_cmd];
	return false;
}

-(bool)deletesFileUponFailure
{
	return _deletesOnFailure;
}

-(void)setDeletesFileUponFailure:(bool)flag
{
	_deletesOnFailure=flag;
}

-(void)setDestination:(NSString *)path allowOverwrite:(bool)allowOverwrite
{
	_path=[NSURI fileURIWithPath:path];
	_allowOverwrite=allowOverwrite;
}

-(void)cancel
{
	[_connection cancel];
}

-(void)connection:(NSURIConnection *)connection didFailWithError:(NSError *)error
{
	if([_delegate respondsToSelector:@selector(download:didFailWithError:)])
				 [_delegate download:self didFailWithError:error];
}

-(void)connection:(NSURIConnection *)connection didReceiveAuthenticationChallenge:(NSURIAuthenticationChallenge *)challenge
{
	if([_delegate respondsToSelector:@selector(download:didReceiveAuthenticationChallenge:)])
				 [_delegate download:self didReceiveAuthenticationChallenge:challenge];
}

-(void)connection:(NSURIConnection *)connection didCancelAuthenticationChallenge:(NSURIAuthenticationChallenge *)challenge
{
	if([_delegate respondsToSelector:@selector(download:didCancelAuthenticationChallenge:)])
				 [_delegate download:self didCancelAuthenticationChallenge:challenge];
}

-(void)_createFileStreamIfNeeded
{
	if(_fileStream!=nil)
		return;

	NSURI *check=_path;

	if(!_allowOverwrite)
	{
		if([[NSFileManager defaultManager] fileExistsAtURI:check])
		{
			NSURI *tryThis;
			long i;

			for(i=0;;i++)
			{
				tryThis=[check URIByDeletingPathExtension];
				NSString *tryPath = [check lastPathComponent];
				tryThis = [tryThis URIByDeletingLastPathComponent];
				tryThis=[tryThis URIByAppendingPathComponent:[tryPath stringByAppendingFormat:@"-%d",i]];
				tryThis=[tryThis URIByAppendingPathExtension:[check pathExtension]];

				if(![[NSFileManager defaultManager] fileExistsAtURI:tryThis])
				{
					check=tryThis;
					break;
				}
			}
		}
	}

	_fileStream=[[NSOutputStream alloc] initWithURI:check append:false];

	if([_delegate respondsToSelector:@selector(download:didCreateDestination:)])
				 [_delegate download:self didCreateDestination:check];
}

-(void)connection:(NSURIConnection *)connection didReceiveData:(NSData *)data
{
	[self _createFileStreamIfNeeded];
	[_fileStream write:[data bytes] maxLength:[data length]];

	if([_delegate respondsToSelector:@selector(download:didReceiveDataOfLength:)])
				 [_delegate download:self didReceiveDataOfLength:[data length]];
}

-(void)connection:(NSURIConnection *)connection didReceiveResponse:(NSURIResponse *)response
{
	if([_delegate respondsToSelector:@selector(download:didReceiveResponse:)])
				 [_delegate download:self didReceiveResponse:response];
}

-(NSCachedURIResponse *)connection:(NSURIConnection *)connection willCacheResponse:(NSCachedURIResponse *)response
{
	return nil;
}

-(NSURIRequest *)connection:(NSURIConnection *)connection willSendRequest:(NSURIRequest *)request redirectResponse:(NSURIResponse *)response
{
	if([_delegate respondsToSelector:@selector(download:willSendRequest:redirectResponse:)])
		  return [_delegate download:self willSendRequest:request redirectResponse:response];

	return request;
}

-(void)connectionDidFinishLoading:(NSURIConnection *)connection
{
	if([_delegate respondsToSelector:@selector(downloadDidFinish:)])
		[_delegate downloadDidFinish:self];
}


@end
