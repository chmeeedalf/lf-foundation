/*
 * Copyright (c) 2009	Gold Project
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
{
@private
	id _private;
@protected
	NSString *_multiplier;
	NSString *_format;
	NSString *_zeroSym;
	NSString *_nilSym;
	NSString *_negFormat;
	NSString *_posFormat;
	NSLocale *_locale;
	NSNumberFormatterStyle _style;
	NSNumberFormatterRoundingMode _round;
	NSNumberFormatterPadPosition _pad;
	NSNumber *_maximum;
	NSNumber *_minimum;
	bool _userMultiplier;
	bool _partialValidate;
}

- (void) setNumberStyle:(NSNumberFormatterStyle)newStyle;
- (NSNumberFormatterStyle) numberStyle;
- (void) setGeneratesDecimalNumbers:(bool)flag;
- (bool) generatesDecimalNumbers;

- (bool) getObjectValue:(out id *)obj forString:(NSString *)str range:(inout NSRange *)rangep error:(out NSError **)err;
+ (NSString *) localizedStringFromNumber:(NSNumber *)num numberStyle:(NSNumberFormatterStyle)numberStyle;
- (NSNumber *) numberFromString:(NSString *)str;
- (NSString *) stringFromNumber:(NSNumber *)number;

- (void) setLocale:(NSLocale *)locale;
- (NSLocale *) locale;

- (void) setRoundingIncrement:(NSNumber *)newRound;
- (NSNumber *) roundingIncrememt;
- (void) setRoundingMode:(NSNumberFormatterRoundingMode)mode;
- (NSNumberFormatterRoundingMode) roundingMode;

- (void) setFormatWidth:(unsigned long)newWidth;
- (unsigned long) formatWidth;
- (void) setNegativeFormat:(NSString *)negForm;
- (NSString *) negativeFormat;
- (void) setPositiveFormat:(NSString *)posForm;
- (NSString *) positiveFormat;
- (void) setMultiplier:(NSNumber *)newMult;
- (NSNumber *) multiplier;

- (void) setPercentSymbol:(NSString *)newPercent;
- (NSString *) percentSymbol;
- (void) setPerMillSymbol:(NSString *)newPerMill;
- (NSString *) perMillSymbol;
- (void) setMinusSign:(NSString *)newMinus;
- (NSString *) minusSign;
- (void) setPlusSign:(NSString *)newPlus;
- (NSString *) plusSign;
- (void) setExponentSymbol:(NSString *)newSym;
- (NSString *) exponentSymbol;
- (void) setZeroSymbol:(NSString *)newZero;
- (NSString *) zeroSymbol;
- (void) setNilSymbol:(NSString *)newNil;
- (NSString *) nilSymbol;
- (void) setNotANumberSymbol:(NSString *)newSym;
- (NSString *) notANumberSymbol;
- (void) setNegativeInfinitySymbol:(NSString *)newNeg;
- (NSString *) negativeInfinitySymbol;
- (void) setPositiveInfinitySymbol:(NSString *)newPos;
- (NSString *) positiveInfinitySymbol;

- (void) setCurrencySymbol:(NSString *)newSym;
- (NSString *) currencySymbol;
- (void) setCurrencyCode:(NSString *)newCode;
- (NSString *) currencyCode;
- (void) setInternationalCurrencySymbol:(NSString *)newSym;
- (NSString *) internationalCurrencySymbol;
- (void) setCurrencyGroupingSeparator:(NSString *)newSep;
- (NSString *) currencyGroupingSeparator;

- (void) setPositivePrefix:(NSString *)newPosPref;
- (NSString *) positivePrefix;
- (void) setPositiveSuffix:(NSString *)newPosSuff;
- (NSString *) positiveSuffix;
- (void) setNegativePrefix:(NSString *)newNegPref;
- (NSString *) negativePrefix;
- (void) setNegativeSuffix:(NSString *)newNegSuff;
- (NSString *) negativeSuffix;

- (void) setTextAttributesForNegativeValues:(NSDictionary *)newAttribs;
- (NSDictionary *) textAttributesForNegativeValues;
- (void) setTextAttributesForPositiveValues:(NSDictionary *)newAttribs;
- (NSDictionary *) textAttributesForPositiveValues;
- (void) setAttributedStringForZero:(NSAttributedString *)newAttrStr;
- (NSAttributedString *) attributedStringForZero;
- (void) setTextAttributesForZero:(NSDictionary *)newAttribs;
- (NSDictionary *) textAttributesForZero;
- (void) setAttributedStringForNil:(NSAttributedString *)newAttrStr;
- (NSAttributedString *) attributedStringForNil;
- (void) setTextAttributesForNil:(NSDictionary *)newAttribs;
- (NSDictionary *) textAttributesForNil;
- (void) setAttributedStringForNotANumber:(NSAttributedString *)newAttrStr;
- (NSAttributedString *) attributedStringForNotANumber;
- (void) setTextAttributesForNotANumber:(NSDictionary *)newAttribs;
- (NSDictionary *) textAttributesForNotANumber;
- (void) setTextAttributesForPositiveInfinity:(NSDictionary *)newAttribs;
- (NSDictionary *) textAttributesForPositiveInfinity;
- (void) setTextAttributesForNegativeInfinity:(NSDictionary *)newAttribs;
- (NSDictionary *) textAttributesForNegativeInfinity;

- (void) setGroupingSeparator:(NSString *)newSep;
- (NSString *) groupingSeparator;
- (void) setUsesGroupingSeparator:(bool)useGroup;
- (bool) usesGroupingSeparator;
- (void) setThousandSeparator:(NSString *)newSep;
- (NSString *) thousandSeparator;
- (void) setHasThousandSeparators:(bool)useGroup;
- (bool) hasThousandSeparators;
- (void) setDecimalSeparator:(NSString *)newSep;
- (NSString *) decimalSeparator;
- (void) setAlwaysShowsDecimalSeparator:(bool)alwaysShow;
- (bool) alwaysShowsDecimalSeparator;
- (void) setCurrencyDecimalSeparator:(NSString *)newSep;
- (NSString *) currencyDecimalSeparator;
- (void) setGroupingSize:(unsigned long)newSize;
- (unsigned long) groupingSize;
- (void) setSecondaryGroupingSize:(unsigned long) newGroup;
- (unsigned long) secondaryGroupingSize;

- (void) setPaddingCharacter:(NSString *)newPad;
- (NSString *) paddingCharacter;
- (void) setPaddingPosition:(NSNumberFormatterPadPosition)newPos;
- (NSNumberFormatterPadPosition) paddingPosition;

- (void) setAllowsFloats:(bool)allowFloats;
- (bool) allowsFloats;
- (void) setMinimum:(NSNumber *)newMin;
- (NSNumber *) minimum;
- (void) setMaximum:(NSNumber *)newMax;
- (NSNumber *) maximum;
- (void) setMinimumIntegerDigits:(unsigned long)newMinInt;
- (unsigned long) minimumIntegerDigits;
- (void) setMinimumFractionDigits:(unsigned long)newMinFrac;
- (unsigned long) minimumFractionDigits;
- (void) setMaximumIntegerDigits:(unsigned long)newMaxInt;
- (unsigned long) maximumIntegerDigits;
- (void) setMaximumFractionDigits:(unsigned long)newMaxFrac;
- (unsigned long) maximumFractionDigits;

- (void) setUsesSignificantDigits:(bool)useSigFigs;
- (bool) usesSignificantDigits;
- (void) setMinimumSignificantDigits:(unsigned long)minSigFig;
- (unsigned long) minimumSignificantDigits;
- (void) setMaximumSignificantDigits:(unsigned long)maxSigFig;
- (unsigned long) maximumSignificantDigits;

- (void) setLenient:(bool)lenient;
- (bool) isLenient;

- (void) setPartialStringValidationEnabled:(bool)enabled;
- (bool) isPartialStringValidationEnabled;

@end
