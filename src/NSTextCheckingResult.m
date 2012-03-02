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

#import <Foundation/NSDictionary.h>
#import <Foundation/NSRegularExpression.h>
#import <Foundation/NSString.h>
#import <Foundation/NSTextCheckingResult.h>
#import <Foundation/NSURI.h>
#include <stdlib.h>
#include <string.h>

/**
 * Private class encapsulating a regular expression match.
 */
@interface GSRegularExpressionCheckingResult : NSTextCheckingResult
{
	// TODO: This could be made more efficient by adding a variant that only
	// contained a single range.
	@public
		/** The number of ranges matched */
		NSUInteger rangeCount;
		/** The array of ranges. */
		NSRange *ranges;
		/** The regular expression object that generated this match. */
		NSRegularExpression *regularExpression;
}
@end

/* Since most results use a single range, make a common base class for them. */
@interface NSBasicRangeCheckingResult : NSTextCheckingResult
{
	@public
		NSRange range;
}
@end

@interface NSReplacementCheckingResult : NSBasicRangeCheckingResult
{
	@public
		NSString *replacement;
}
@end

@interface NSLinkCheckingResult : NSBasicRangeCheckingResult
{
	@public
		NSURI *uri;
}
@end

@interface NSAddressCheckingResult : NSBasicRangeCheckingResult
{
	@public
		NSDictionary *components;
}
@end

@interface NSComponentCheckingResult : NSBasicRangeCheckingResult
{
	@public
		NSDictionary *components;
}
@end

@interface NSDateCheckingResult : NSBasicRangeCheckingResult
{
	@public
		NSDate *date;
		NSTimeZone *timeZone;
		NSTimeInterval duration;
}
@end

@interface NSGrammarCheckingResult : NSBasicRangeCheckingResult
{
	@public
		NSArray *details;
}
@end

@interface NSOrthographyCheckingResult : NSBasicRangeCheckingResult
{
	@public
		NSOrthography *orthography;
}
@end

@interface NSPhoneNumberCheckingResult : NSBasicRangeCheckingResult
{
	@public
		NSString *phoneNumber;
}
@end

@implementation NSTextCheckingResult
{
	@package
	NSTextCheckingType resultType;
}

+ (NSTextCheckingResult*)regularExpressionCheckingResultWithRanges: (NSRangePointer)ranges
                                                             count: (NSUInteger)count
                                                 regularExpression: (NSRegularExpression*)regularExpression
{
	GSRegularExpressionCheckingResult *result = [GSRegularExpressionCheckingResult new];
	result->rangeCount = count;
	result->ranges = calloc(sizeof(NSRange), count);
	memcpy(result->ranges, ranges, (sizeof(NSRange) * count));
	result->regularExpression = regularExpression;
	return result;
}

+ (NSTextCheckingResult *) replacementCheckingResultWithRange:(NSRange)range
											replacementString:(NSString *)replacement
{
	NSReplacementCheckingResult *result = [NSReplacementCheckingResult new];
	result->range = range;
	result->replacement = [replacement copy];

	return result;
}

+ (NSTextCheckingResult *) linkCheckingResultWithRange:(NSRange)range URI:(NSURI *)uri
{
	NSLinkCheckingResult *result = [NSLinkCheckingResult new];
	result->range = range;
	result->uri = [uri copy];

	return result;
}

+ (NSTextCheckingResult *) addressCheckingResultWithRange:(NSRange)range
											   components:(NSDictionary *)components
{
	NSAddressCheckingResult *result = [NSAddressCheckingResult new];
	result->range = range;
	result->components = [components copy];

	return result;
}

+ (NSTextCheckingResult *) correctionCheckingResultWithRange:(NSRange)range
										   replacementString:(NSString *)replacement
{
	NSReplacementCheckingResult *result = [NSReplacementCheckingResult new];
	result->resultType = NSTextCheckingTypeCorrection;
	result->range = range;
	result->replacement = [replacement copy];

	return result;
}

+ (NSTextCheckingResult *) dashCheckingResultWithRange:(NSRange)range
									 replacementString:(NSString *)replacement
{
	NSReplacementCheckingResult *result = [NSReplacementCheckingResult new];
	result->resultType = NSTextCheckingTypeDash;
	result->range = range;
	result->replacement = [replacement copy];

	return result;
}

+ (NSTextCheckingResult *) dateCheckingResultWithRange:(NSRange)range date:(NSDate *)date
{
	NSDateCheckingResult *result = [NSDateCheckingResult new];
	result->resultType = NSTextCheckingTypeDate;
	result->date = date;

	return result;
}

+ (NSTextCheckingResult *) dateCheckingResultWithRange:(NSRange)range
												  date:(NSDate *)date
											  timeZone:(NSTimeZone *)timeZone
											  duration:(NSTimeInterval)duration
{
	NSDateCheckingResult *result = [NSDateCheckingResult new];
	result->resultType = NSTextCheckingTypeDate;
	result->date = date;
	result->timeZone = timeZone;
	result->duration = duration;

	return result;
}

+ (NSTextCheckingResult *) grammarCheckingResultWithRange:(NSRange)range
												  details:(NSArray *)details
{
	NSGrammarCheckingResult *result = [NSGrammarCheckingResult new];
	result->resultType = NSTextCheckingTypeGrammar;
	result->details = details;

	return result;
}

+ (NSTextCheckingResult *) orthographyCheckingResultWithRange:(NSRange)range
												  orthography:(NSOrthography *)orth
{
	NSOrthographyCheckingResult *result = [NSOrthographyCheckingResult new];
	result->resultType = NSTextCheckingTypeOrthography;
	result->orthography = orth;

	return result;
}

+ (NSTextCheckingResult *) phoneNumberCheckingResultWithRange:(NSRange)range
												  phoneNumber:(NSString *)number
{
	NSPhoneNumberCheckingResult *result = [NSPhoneNumberCheckingResult new];
	result->resultType = NSTextCheckingTypePhoneNumber;
	result->phoneNumber = number;

	return result;
}

+ (NSTextCheckingResult *) quoteCheckingResultWithRange:(NSRange)range
									  replacementString:(NSString *)replacement
{
	NSReplacementCheckingResult *result = [NSReplacementCheckingResult new];
	result->resultType = NSTextCheckingTypeQuote;
	result->range = range;
	result->replacement = [replacement copy];

	return result;
}

+ (NSTextCheckingResult *) spellCheckingResultWithRange:(NSRange)range
{
	NSBasicRangeCheckingResult *result = [NSBasicRangeCheckingResult new];
	result->resultType = NSTextCheckingTypeSpelling;
	result->range = range;

	return result;
}

+ (NSTextCheckingResult *) transitInformationCheckingResultWithRange:(NSRange)range
														  components:(NSDictionary *)components
{
	NSComponentCheckingResult *result = [NSComponentCheckingResult new];
	result->resultType = NSTextCheckingTypeTransitInformation;
	result->range = range;
	result->components = [components copy];

	return result;
}

- (NSRange) rangeAtIndex:(NSUInteger)idx
{
	if (idx == 0)
	{
		return [self range];
	}
	return NSMakeRange(0, NSNotFound);
}

- (NSTextCheckingResult *) resultByAdjustingRangesWithOffset:(NSInteger)offset
{
	return self;
}

- (NSDictionary*)addressComponents
{
	return nil;
}

- (NSDictionary*)components
{
	return nil;
}

- (NSDate*)date
{
	return nil;
}

- (NSTimeInterval) duration
{
	return 0;
}

- (NSArray*)grammarDetails
{
	return nil;
}

- (NSUInteger) numberOfRanges
{
	return nil;
}

- (NSOrthography*)orthography
{
	return nil;
}

- (NSString*)phoneNumber
{
	return nil;
}

- (NSRange) range
{
	return NSMakeRange(NSNotFound, 0);
}

- (NSRegularExpression*)regularExpression
{
	return nil;
}

- (NSString*)replacementString
{
	return nil;
}

- (NSTextCheckingType)resultType
{
	return resultType;
}

- (NSTimeZone*)timeZone
{
	return nil;
}

- (NSURI*)URI
{
	return nil;
}

@end



@implementation GSRegularExpressionCheckingResult
- (NSUInteger)numberOfRanges
{
	return rangeCount;
}
- (NSRange)range
{
	return ranges[0];
}
- (NSRange)rangeAtIndex: (NSUInteger)idx
{
	if (idx >= rangeCount)
	{
		return NSMakeRange(0, NSNotFound);
	}
	return ranges[idx];
}
- (NSTextCheckingType)resultType
{
	return NSTextCheckingTypeRegularExpression;
}
- (void)dealloc
{
	free(ranges);
}
@end

@implementation NSBasicRangeCheckingResult
- (NSRange) range
{
	return range;
}
@end
