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

#import <Foundation/NSURLResponse.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSString.h>
#import "internal.h"

@implementation NSURLResponse

-(id)initWithURL:(NSURL *)url MIMEType:(NSString *)mimeType expectedContentLength:(long)expectedLength textEncodingName:(NSString *)encoding
{
	_url=url;
	_mimeType = mimeType;
	_expectedContentLength = expectedLength;
	_encoding = encoding;
	return self;
}

-(id)copyWithZone:(NSZone *)zone
{
	return self;
}

-(id)initWithCoder:(NSCoder *)coder
{
	[self notImplemented:_cmd];
	return nil;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
	[self notImplemented:_cmd];
}

-(NSURL *)URL
{
	return _url;
}

-(NSString *)MIMEType
{
	return _mimeType;
}

-(long long)expectedContentLength
{
	return _expectedContentLength;
}

-(NSString *)textEncodingName
{
	return _encoding;
}

// Subclasses should implement this to provide their own suggested filename,
// falling back to this one if that fails.
-(NSString *)suggestedFilename
{
	// TODO: Add extension information based on MIME type.  Probably belongs in
	// HTTPURLResponse
	NSString *name = [_url lastPathComponent];
	if (name == nil)
	{
		name = [_url hostname];
		if (name == nil)
			name = @"unknown";
	}
	return name;
}

@end
