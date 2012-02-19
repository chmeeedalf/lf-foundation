/*
 * Copyright (c) 2011-2012	Gold Project
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
/* Copyright (c) 2011 David Chisnall */

#import <Foundation/NSTextCheckingResult.h>
#import <Foundation/NSObject.h>
@class NSTextCheckingResult;
@class NSError;
@class NSString, NSMutableString;
@class NSURI;

typedef NSUInteger NSRegularExpressionOptions;
enum {
	NSRegularExpressionUseUnixLineSeparators       = 1<<0,
	NSRegularExpressionCaseInsensitive             = 1<<1,
	NSRegularExpressionAllowCommentsAndWhitespace  = 1<<2,
	NSRegularExpressionAnchorsMatchLines           = 1<<3,
	NSRegularExpressionIgnoreMetacharacters        = 1<<4,
	NSRegularExpressionDotMatchesLineSeparators    = 1<<5,
	NSRegularExpressionUseUnicodeWordBoundaries    = 1<<7,
};

typedef NSUInteger NSMatchingFlags;
enum {
	NSMatchingProgress      = 1<<0,
	NSMatchingCompleted     = 1<<1,
	NSMatchingHitEnd        = 1<<2,
	NSMatchingRequiredEnd   = 1<<3,
	NSMatchingInternalError = 1<<4,
};

typedef NSUInteger NSMatchingOptions;
enum {
	NSMatchingReportProgress         = 1<<0,
	NSMatchingReportCompletion       = 1<<1,
	NSMatchingAnchored               = 1<<2,
	NSMatchingWithTransparentBounds  = 1<<3,
	NSMatchingWithoutAnchoringBounds = 1<<4,
};

typedef void (^NSRegexBlock)(NSTextCheckingResult *, NSMatchingFlags, bool *);


@interface NSRegularExpression : NSObject <NSCoding, NSCopying>
{
	@private
	void *regex;
	NSRegularExpressionOptions options;
}
+ (NSRegularExpression*)regularExpressionWithPattern: (NSString*)aPattern
                                             options: (NSRegularExpressionOptions)opts
                                               error: (NSError**)e;
- (id) initWithPattern: (NSString*)aPattern
          options: (NSRegularExpressionOptions)opts
            error: (NSError**)e;
+ (NSRegularExpression*)regularExpressionWithPattern: (NSString*)aPattern
                                             options: (NSRegularExpressionOptions)opts
                                               error: (NSError**)e;
- (id) initWithPattern: (NSString*)aPattern
          options: (NSRegularExpressionOptions)opts
            error: (NSError**)e;
- (NSString*)pattern;

- (void)enumerateMatchesInString: (NSString*)string
                         options: (NSMatchingOptions)options
                           range: (NSRange)range
                      usingBlock: (NSRegexBlock)block;
- (NSUInteger)numberOfMatchesInString: (NSString*)string
                              options: (NSMatchingOptions)options
                                range: (NSRange)range;

- (NSTextCheckingResult*)firstMatchInString: (NSString*)string
                                    options: (NSMatchingOptions)options
                                      range: (NSRange)range;
- (NSArray*)matchesInString: (NSString*)string
                    options:(NSMatchingOptions)options
                      range:(NSRange)range;
- (NSRange)rangeOfFirstMatchInString: (NSString*)string
                             options: (NSMatchingOptions)options
                               range: (NSRange)range;
- (NSUInteger)replaceMatchesInString: (NSMutableString*)string
                             options: (NSMatchingOptions)options
                               range: (NSRange)range
                        withTemplate: (NSString*)templat;
- (NSString*)stringByReplacingMatchesInString: (NSString*)string
                                      options: (NSMatchingOptions)options
                                        range: (NSRange)range
                                 withTemplate: (NSString*)templat;
- (NSString*)replacementStringForResult: (NSTextCheckingResult*)result
                               inString: (NSString*)string
                                 offset: (NSInteger)offset
                               template: (NSString*)templat;
#if GS_HAS_DECLARED_PROPERTIES
@property (readonly) NSRegularExpressionOptions options;
@property (readonly) NSUInteger numberOfCaptureGroups;
#else
- (NSRegularExpressionOptions)options;
- (NSUInteger)numberOfCaptureGroups;
#endif
@end

@interface NSDataDetector	:	NSRegularExpression
{
}
@property(readonly) NSTextCheckingTypes checkingTypes;
+ (id) dataDetectorWithTypes:(NSTextCheckingTypes)types error:(NSError **)errorp;
- (id) initWithTypes:(NSTextCheckingTypes)types error:(NSError **)errorp;
@end
