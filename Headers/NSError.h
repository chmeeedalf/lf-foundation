/* $Gold$	*/
/*
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

#import <Foundation/NSObject.h>

@class NSArray;
@class NSDictionary;
@class NSString;

@interface NSError	:	NSObject
{
	int			_code;
	NSDictionary	*_userInfo;
	NSString		*_domain;
}

@property(readonly,retain) NSString *domain;
@property(readonly,retain) NSDictionary *userInfo;
@property(readonly) int code;

+ (NSError *)errorWithDomain:(NSString *)dom code:(int)code userInfo:(NSDictionary *)userInfo;
- (id)initWithDomain:(NSString *)dom code:(int)code userInfo:(NSDictionary *)userInfo;

- (NSString *)localizedDescription;
- (NSArray *)localizedRecoveryOptions;
- (NSString *)localizedRecoverySuggestion;
- (NSString *)localizedFailureReason;

- (id) recoveryAttempter;
- (NSString *)helpAnchor;
@end

@protocol NSErrorRecoveryAttempting<NSObject>
@optional
- (bool)attemptRecoveryFromError:(NSError *)error optionIndex:(uint32_t)recoveryOptionIndex;
- (void)attemptRecoveryFromError:(NSError *)error optionIndex:(uint32_t)recoveryOptionIndex delegate:(id)delegate didRecoverSelector:(SEL)didRecoverSelector contextInfo:(void *)contextInfo;
@end

SYSTEM_EXPORT NSString * const NSLocalizedDescriptionKey;
SYSTEM_EXPORT NSString * const NSLocalizedFailureReasonErrorKey;
SYSTEM_EXPORT NSString * const NSLocalizedRecoverySuggestionErrorKey;
SYSTEM_EXPORT NSString * const NSLocalizedRecoveryOptionsErrorKey;
SYSTEM_EXPORT NSString * const NSRecoveryAttempterErrorKey;
SYSTEM_EXPORT NSString * const NSHelpAnchorErrorKey;
SYSTEM_EXPORT NSString * const NSFileURLErrorKey;
SYSTEM_EXPORT NSString * const NSStringEncodingErrorKey;
SYSTEM_EXPORT NSString * const NSUnderlyingErrorKey;
SYSTEM_EXPORT NSString * const NSURLErrorKey;

SYSTEM_EXPORT NSString * const NSPOSIXErrorDomain;
SYSTEM_EXPORT NSString * const NSSystemErrorDomain;
SYSTEM_EXPORT NSString * const NSUserErrorDomain;
SYSTEM_EXPORT NSString * const NSCocoaErrorDomain;
