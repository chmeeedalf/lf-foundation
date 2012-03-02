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

#import "NSObject.h"
#import "NSGeometry.h"
#import "NSDate.h"

@class NSArray;
@class NSDate;
@class NSDictionary;
@class NSOrthography;
@class NSRegularExpression;
@class NSString;
@class NSTimeZone;
@class NSURI;

typedef uint64_t NSTextCheckingType;
enum {
	NSTextCheckingTypeOrthography	= 1ULL << 0,
	NSTextCheckingTypeSpelling		= 1ULL << 1,
	NSTextCheckingTypeGrammar		= 1ULL << 2,
	NSTextCheckingTypeDate			= 1ULL << 3,
	NSTextCheckingTypeAddress		= 1ULL << 4,
	NSTextCheckingTypeLink			= 1ULL << 5,
	NSTextCheckingTypeQuote			= 1ULL << 6,
	NSTextCheckingTypeDash			= 1ULL << 7,
	NSTextCheckingTypeReplacement	= 1ULL << 8,
	NSTextCheckingTypeCorrection	= 1ULL << 9,
	NSTextCheckingTypeRegularExpression	= 1ULL << 10,
	NSTextCheckingTypePhoneNumber	= 1ULL << 11,
	NSTextCheckingTypeTransitInformation	= 1ULL << 12,
};

enum : uint64_t {
	NSTextCheckingAllSystemTypes = 0xffffffffULL,
	NSTextCheckingAllCustomTypes = 0xffffffffULL << 32,
	NSTextCheckingAllTypes = (NSTextCheckingAllSystemTypes|NSTextCheckingAllCustomTypes)
};
typedef uint64_t NSTextCheckingTypes;

/**
 * NSTextCheckingResult is an abstract class encapsulating the result of some
 * operation that checks 
 */
@interface NSTextCheckingResult : NSObject
@property(readonly) NSDictionary *addressComponents;
@property(readonly) NSDictionary *components;
@property(readonly) NSDate *date;
@property(readonly) NSTimeInterval duration;
@property(readonly) NSArray *grammarDetails;
@property(readonly) NSUInteger numberOfRanges;
@property(readonly) NSOrthography *orthography;
@property(readonly) NSString *phoneNumber;
@property(readonly) NSRange range;
@property(readonly) NSRegularExpression *regularExpression;
@property(readonly) NSString *replacementString;
@property(readonly) NSTextCheckingType resultType;
@property(readonly) NSTimeZone *timeZone;
@property(readonly) NSURI *URI;
+ (NSTextCheckingResult *) replacementCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacement;
+ (NSTextCheckingResult *) regularExpressionCheckingResultWithRanges: (NSRangePointer)ranges
                                                             count: (NSUInteger)count
                                                 regularExpression: (NSRegularExpression*)regularExpression;
+ (NSTextCheckingResult *) linkCheckingResultWithRange:(NSRange)range URI:(NSURI *)uri;
+ (NSTextCheckingResult *) addressCheckingResultWithRange:(NSRange)range components:(NSDictionary *)components;
+ (NSTextCheckingResult *) correctionCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacement;
+ (NSTextCheckingResult *) dashCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacement;
+ (NSTextCheckingResult *) dateCheckingResultWithRange:(NSRange)range date:(NSDate *)date;
+ (NSTextCheckingResult *) dateCheckingResultWithRange:(NSRange)range date:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration;
+ (NSTextCheckingResult *) grammarCheckingResultWithRange:(NSRange)range details:(NSArray *)details;
+ (NSTextCheckingResult *) orthographyCheckingResultWithRange:(NSRange)range orthography:(NSOrthography *)orth;
+ (NSTextCheckingResult *) phoneNumberCheckingResultWithRange:(NSRange)range phoneNumber:(NSString *)number;
+ (NSTextCheckingResult *) quoteCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacement;
+ (NSTextCheckingResult *) spellCheckingResultWithRange:(NSRange)range;
+ (NSTextCheckingResult *) transitInformationCheckingResultWithRange:(NSRange)range components:(NSDictionary *)components;


- (NSRange) rangeAtIndex:(NSUInteger)idx;
- (NSTextCheckingResult *) resultByAdjustingRangesWithOffset:(NSInteger)offset;

@end

extern NSString * const NSTextCheckingAirlineKey;
extern NSString * const NSTextCheckingFlightKey;

extern NSString * const NSTextCheckingNameKey;
extern NSString * const NSTextCheckingJobTitleKey;
extern NSString * const NSTextCheckingOrganizationKey;
extern NSString * const NSTextCheckingStreetKey;
extern NSString * const NSTextCheckingCityKey;
extern NSString * const NSTextCheckingStateKey;
extern NSString * const NSTextCheckingZIPKey;
extern NSString * const NSTextCheckingCountryKey;
extern NSString * const NSTextCheckingPhoneKey;
