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

#import <Foundation/NSFormatter.h>

typedef enum
{
	NSNumberFormatterNoStyle = 0,
	NSNumberFormatterDecimalStyle = 1,
	NSNumberFormatterCurrencyStyle,
	NSNumberFormatterPercentStyle,
	NSNumberFormatterScientificStyle,
	NSNumberFormatterSpellOutStyle,
} NSNumberFormatterStyle;

typedef enum
{
	NSNumberFormatterPadBeforePrefix,
	NSNumberFormatterPadAfterPrefix,
	NSNumberFormatterPadBeforeSuffix,
	NSNumberFormatterPadAfterSuffix,
} NSNumberFormatterPadPosition;

typedef enum
{
	NSNumberFormatterRoundCeiling,
	NSNumberFormatterRoundFloor,
	NSNumberFormatterRoundDown,
	NSNumberFormatterRoundUp,
	NSNumberFormatterRoundHalfEven,
	NSNumberFormatterRoundHalfDown,
	NSNumberFormatterRoundingHalfUp
} NSNumberFormatterRoundingMode;

@class NSString, NSLocale, NSNumber;

@interface NSNumberFormatter	:	NSFormatter
/* These are not properties in Cocoa, but are here, because they're ancillary */
@property (strong,nonatomic) NSDictionary *textAttributesForZero;
@property (strong,nonatomic) NSDictionary *textAttributesForNegativeInfinity;
@property (strong,nonatomic) NSDictionary *textAttributesForPositiveInfinity;
@property (strong,nonatomic) NSDictionary *textAttributesForNegativeValues;
@property (strong,nonatomic) NSDictionary *textAttributesForPositiveValues;
@property (strong,nonatomic) NSDictionary *textAttributesForNil;
@property (strong,nonatomic) NSDictionary *textAttributesForNotANumber;
/* Unused for now. */
@property bool generatesDecimalNumbers;

- (void) setNumberStyle:(NSNumberFormatterStyle)newStyle;
- (NSNumberFormatterStyle) numberStyle;

- (bool) getObjectValue:(out id *)obj forString:(NSString *)str range:(inout NSRange *)rangep error:(out NSError **)err;
+ (NSString *) localizedStringFromNumber:(NSNumber *)num numberStyle:(NSNumberFormatterStyle)numberStyle;
- (NSNumber *) numberFromString:(NSString *)str;
- (NSString *) stringFromNumber:(NSNumber *)number;

@property NSLocale *locale;
@property NSNumber *roundingIncrement;
@property NSNumberFormatterRoundingMode roundingMode;

@property NSUInteger formatWidth;
@property (copy) NSString *negativeFormat;
@property (copy) NSString *positiveFormat;
@property NSNumber *multiplier;

@property NSString *percentSymbol;
@property NSString *perMillSymbol;
@property NSString *minusSign;
@property NSString *plusSign;
@property NSString *exponentSymbol;
@property NSString *zeroSymbol;
@property NSString *nilSymbol;
@property NSString *notANumberSymbol;
@property NSString *negativeInfinitySymbol;
@property NSString *positiveInfinitySymbol;

@property NSString *currencySymbol;
@property NSString *currencyCode;
@property NSString *internationalCurrencySymbol;
@property NSString *currencyGroupingSeparator;

@property NSString *positivePrefix;
@property NSString *positiveSuffix;
@property NSString *negativePrefix;
@property NSString *negativeSuffix;

@property NSString *groupingSeparator;
@property bool usesGroupingSeparator;
@property NSString *decimalSeparator;
@property bool alwaysShowsDecimalSeparator;
@property NSString *currencyDecimalSeparator;
@property NSUInteger groupingSize;
@property NSUInteger secondaryGroupingSize;

@property NSString *paddingCharacter;
@property NSNumberFormatterPadPosition paddingPosition;

@property bool allowsFloats;
@property NSNumber *minimum;
@property NSNumber *maximum;
@property NSUInteger minimumIntegerDigits;
@property NSUInteger maximumIntegerDigits;
@property NSUInteger minimumFractionDigits;
@property NSUInteger maximumFractionDigits;
@property NSUInteger minimumSignificantDigits;
@property NSUInteger maximumSignificantDigits;

@property bool usesSignificantDigits;

@property (setter=setLenient:) bool isLenient;

@property (setter=setPartialStringValidationEnabled:) bool isPartialStringValidationEnabled;

@end
