/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSObject.h>

@class NSError,NSURIResponse,NSURIProtectionSpace,NSURICredential;

@protocol NSURIAuthenticationChallengeSender <NSObject>
@end

@interface NSURIAuthenticationChallenge : NSObject
{
	NSURIProtectionSpace *_protectionSpace;
	NSURICredential      *_proposedCredential;
	int                   _failureCount;
	NSURIResponse        *_failureResponse;
	NSError              *_error;
	id                    _sender;
}

-initWithProtectionSpace:(NSURIProtectionSpace *)space proposedCredential:(NSURICredential *)credential previousFailureCount:(int)failureCount failureResponse:(NSURIResponse *)failureResponse error:(NSError *)error sender:(id <NSURIAuthenticationChallengeSender>)sender;

-initWithAuthenticationChallenge:(NSURIAuthenticationChallenge *)challenge sender:(id <NSURIAuthenticationChallengeSender>)sender;

-(NSURIProtectionSpace *)protectionSpace;
-(NSURICredential *)proposedCredential;
-(unsigned long)previousFailureCount;
-(NSURIResponse *)failureResponse;
-(NSError *)error;
-(id<NSURIAuthenticationChallengeSender>)sender;

@end
