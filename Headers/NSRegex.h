/*
 * Copyright (c) 2009-2012	Justin Hibbits
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

#import <Foundation/NSString.h>
#import <Foundation/NSScanner.h>

enum {
	NSRegularExpressionUseUnixLineSeparators = 1,
	NSRegularExpressionCaseInsensitive = 2,
	NSRegularExpressionAllowCommentsAndWhitespace = 4,
	NSRegexFlagMultiline = 8,
	NSRegularExpressionIgnoreMetacharacters = 16,
	NSRegularExpressionDotMatchesLineSeparators = 32,
	NSRegexFlagNormalize = 128,
	NSRegularExpressionUseUnicodeWordBoundaries = 256,
	NSRegexFlagErrorOnUnknownEscapes = 512,
};
typedef NSUInteger NSRegexFlags;

@interface NSRegexPattern	: NSObject
{
@private
	id _private;
	NSString *patternString;
}
+ (id) compiledPatternWithString:(NSString *)str;
+ (id) compiledPatternWithString:(NSString *)str flags:(NSRegexFlags)flags;

- (id) initWithStringPattern:(NSString *)str flags:(NSRegexFlags)flags;
- (NSString *) pattern;
- (bool) isEqualToPattern:(NSRegexPattern *)other;
@end

@interface NSRegexMatcher	: NSObject
{
@private
	id							_private;
@protected
	NSRegexPattern				*sourcePattern;
	NSString						*input;
}

@end

@interface NSString(RegularExpressions)
- (bool) matchesRegularExpression:(NSRegexPattern *)pattern;
- (NSArray *) componentsSeparatedByPattern:(NSRegexPattern *)pattern;
- (NSArray *) componentsMatchingPattern:(NSRegexPattern *)pattern;
@end

@interface NSScanner(RegularExpressions)
- (bool) scanUpToPattern:(NSRegexPattern *)pattern intoString:(NSString **)str;
- (bool) scanPattern:(NSRegexPattern *)pattern intoString:(NSString **)str;
@end
