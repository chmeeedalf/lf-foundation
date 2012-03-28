/*-
 * Copyright (c) 2009-2012	Gold Project
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
 * THIS SOFTWARE IS PROVIDED BY THE PROJECT ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSError.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>

NSString * const NSLocalizedDescriptionKey = @"NSLocalizedDescriptionKey";
NSString * const NSLocalizedFailureReasonErrorKey = @"NSLocalizedFailureReasonErrorKey";
NSString * const NSLocalizedRecoverySuggestionErrorKey = @"NSLocalizedRecoverySuggestionErrorKey";
NSString * const NSLocalizedRecoveryOptionsErrorKey = @"NSLocalizedRecoveryOptionsErrorKey";
NSString * const NSRecoveryAttempterErrorKey = @"NSRecoveryAttempterErrorKey";
NSString * const NSHelpAnchorErrorKey = @"NSHelpAnchorErrorKey";
NSString * const NSFileURLErrorKey = @"NSFileURLErrorKey";
NSString * const NSStringEncodingErrorKey = @"NSStringEncodingErrorKey";
NSString * const NSUnderlyingErrorKey = @"NSUnderlyingErrorKey";
NSString * const NSURLErrorKey = @"NSURLErrorKey";

NSString * const NSPOSIXErrorDomain = @"NSPOSIXErrorDomain";
NSString * const NSCocoaErrorDomain = @"NSCocoaErrorDomain";
NSString * const NSSystemErrorDomain = @"NSSystemErrorDomain";
NSString * const NSUserErrorDomain = @"NSUserErrorDomain";

@implementation NSError

@synthesize domain = _domain;
@synthesize userInfo = _userInfo;
@synthesize code = _code;

+ (id) errorWithDomain:(NSString *)dom code:(int)code userInfo:(NSDictionary *)userInfo
{
	return [[self alloc] initWithDomain:dom code:code userInfo:userInfo];
}

- (id) initWithDomain:(NSString *)dom code:(int)code userInfo:(NSDictionary *)userInfo
{
	_domain = dom;
	_code = code;
	_userInfo = userInfo;
	return self;
}

- (NSString *)localizedDescription
{
	return [_userInfo objectForKey:NSLocalizedDescriptionKey];
}

- (NSArray *)localizedRecoveryOptions
{
	return [_userInfo objectForKey:NSLocalizedRecoveryOptionsErrorKey];
}

- (NSString *)localizedRecoverySuggestion
{
	return [_userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey];
}

- (NSString *)localizedFailureReason
{
	return [_userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
}

- (id) recoveryAttempter
{
	return [_userInfo objectForKey:NSHelpAnchorErrorKey];
}

- (NSString *)helpAnchor
{
	return [_userInfo objectForKey:NSRecoveryAttempterErrorKey];
}
@end
