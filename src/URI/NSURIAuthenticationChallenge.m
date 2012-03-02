/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSURIAuthenticationChallenge.h>
#import <Foundation/NSURIProtectionSpace.h>
#import <Foundation/NSURICredential.h>
#import <Foundation/NSURIResponse.h>
#import <Foundation/NSError.h>

@implementation NSURIAuthenticationChallenge

-(id)initWithProtectionSpace:(NSURIProtectionSpace *)space proposedCredential:(NSURICredential *)credential previousFailureCount:(int)failureCount failureResponse:(NSURIResponse *)failureResponse error:(NSError *)error sender:(id <NSURIAuthenticationChallengeSender>)sender
{
	_protectionSpace = [space copy];
	_proposedCredential = [credential copy];
	_failureCount = failureCount;
	_failureResponse = [failureResponse copy];
	_sender = sender;
	return self;
}

-(id)initWithAuthenticationChallenge:(NSURIAuthenticationChallenge *)challenge sender:(id <NSURIAuthenticationChallengeSender>)sender
{
	return [self initWithProtectionSpace:[challenge protectionSpace] proposedCredential:[challenge proposedCredential] previousFailureCount:[challenge previousFailureCount] failureResponse:[challenge failureResponse] error:[challenge error] sender:sender];
	return self;
}

-(NSURIProtectionSpace *)protectionSpace
{
	return _protectionSpace;
}

-(NSURICredential *)proposedCredential
{
	return _proposedCredential;
}

-(unsigned long)previousFailureCount
{
	return _failureCount;
}

-(NSURIResponse *)failureResponse
{
	return _failureResponse;
}

-(NSError *)error
{
	return _error;
}

-(id<NSURIAuthenticationChallengeSender>)sender
{
	return _sender;
}

@end
