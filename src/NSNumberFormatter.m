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

#import <Foundation/NSNumberFormatter.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSString.h>
#import "internal.h"
#include <unicode/unum.h>

@interface _NumberFormatterPrivate	:	NSObject
{
@public
	UNumberFormat *_unf;
	UParseError _parseError;
}
@end
@implementation _NumberFormatterPrivate
@end

#define _private (*(_NumberFormatterPrivate **)&self->_private)

#define BUFFER_SIZE 768

@implementation NSNumberFormatter

static void _InitPrivate(NSNumberFormatter *self)
{
	UErrorCode ec = U_ZERO_ERROR;
	if (_private->_unf != NULL)
		return;
	_private->_unf = unum_open((UNumberFormatStyle)self->_style, NULL, 0, [[self->_locale localeIdentifier] cStringUsingEncoding:NSUTF8StringEncoding], &_private->_parseError, &ec);
	if (!U_SUCCESS(ec))
		NSLog(@"Warning: Unable to create ICU number formatter: %s", u_errorName(ec));
	return;
}

static inline NSString *_GetTextAttribute(NSNumberFormatter *self, UNumberFormatTextAttribute attr)
{
	UChar buff[BUFFER_SIZE];
	UErrorCode ec = U_ZERO_ERROR;
	int32_t len;
	_InitPrivate(self);

	len = unum_getTextAttribute(_private->_unf, attr, buff, sizeof(buff)/sizeof(UChar), &ec);
	return [NSString stringWithCharacters:buff length:len];
}

static inline void _SetTextAttribute(NSNumberFormatter *self, UNumberFormatTextAttribute attr, NSString *value)
{
	UChar buff[BUFFER_SIZE];
	UErrorCode ec = U_ZERO_ERROR;
	size_t len = [value length];
	_InitPrivate(self);

	[value getCharacters:buff range:NSMakeRange(0, MIN(len, BUFFER_SIZE))];

	unum_setTextAttribute(_private->_unf, attr, buff, sizeof(buff)/sizeof(UChar), &ec);
}

static inline NSString *_GetSymbol(NSNumberFormatter *self, UNumberFormatSymbol attr)
{
	UChar buff[BUFFER_SIZE];
	UErrorCode ec = U_ZERO_ERROR;
	int32_t len;
	_InitPrivate(self);

	len = unum_getSymbol(_private->_unf, attr, buff, sizeof(buff)/sizeof(UChar), &ec);
	return [NSString stringWithCharacters:buff length:len];
}

static inline void _SetSymbol(NSNumberFormatter *self, UNumberFormatSymbol attr, NSString *value)
{
	UChar buff[BUFFER_SIZE];
	UErrorCode ec = U_ZERO_ERROR;
	size_t len = [value length];
	_InitPrivate(self);

	[value getCharacters:buff range:NSMakeRange(0, MIN(len, BUFFER_SIZE))];

	unum_setSymbol(_private->_unf, attr, buff, sizeof(buff)/sizeof(UChar), &ec);
}

static inline unsigned long _GetIntAttribute(NSNumberFormatter *self, UNumberFormatAttribute attr)
{
	_InitPrivate(self);

	return unum_getAttribute(_private->_unf, attr);
}

static inline void _SetIntAttribute(NSNumberFormatter *self, UNumberFormatAttribute attr, unsigned long val)
{
	_InitPrivate(self);

	unum_setAttribute(_private->_unf, attr, (int32_t)val);
}

static inline double _GetDoubleAttribute(NSNumberFormatter *self, UNumberFormatAttribute attr)
{
	_InitPrivate(self);

	return unum_getDoubleAttribute(_private->_unf, attr);
}

static inline void _SetDoubleAttribute(NSNumberFormatter *self, UNumberFormatAttribute attr, double val)
{
	_InitPrivate(self);

	unum_setDoubleAttribute(_private->_unf, attr, val);
}

- init
{
	_private = [_NumberFormatterPrivate new];
	_locale = [NSLocale systemLocale];

	return self;
}

- (bool) alwaysShowsDecimalSeparator
{
	return _GetIntAttribute(self, UNUM_DECIMAL_ALWAYS_SHOWN);
}

- (NSString *) currencyCode
{
	return _GetTextAttribute(self, UNUM_CURRENCY_CODE);
}

- (NSString *) currencyDecimalSeparator
{
	return _GetSymbol(self, UNUM_MONETARY_SEPARATOR_SYMBOL);
}

- (NSString *) currencyGroupingSeparator
{
	return _GetSymbol(self, UNUM_MONETARY_GROUPING_SEPARATOR_SYMBOL);
}

- (NSString *) currencySymbol
{
	return _GetSymbol(self, UNUM_CURRENCY_SYMBOL);
}

- (NSString *) decimalSeparator
{
	return _GetSymbol(self, UNUM_DECIMAL_SEPARATOR_SYMBOL);
}

- (NSString *) exponentSymbol
{
	return _GetSymbol(self, UNUM_EXPONENTIAL_SYMBOL);
}

- (unsigned long) formatWidth
{
	return _GetIntAttribute(self, UNUM_FORMAT_WIDTH);
}

- (NSString *) groupingSeparator
{
	return _GetSymbol(self, UNUM_GROUPING_SEPARATOR_SYMBOL);
}

- (unsigned long) groupingSize
{
	return _GetIntAttribute(self, UNUM_GROUPING_SIZE);
}

- (bool) isLenient
{
	return _GetIntAttribute(self, UNUM_LENIENT_PARSE);
}

- (bool) isPartialStringValidationEnabled
{
	return _partialValidate;
}

- (NSString *) internationalCurrencySymbol
{
	return _GetSymbol(self, UNUM_INTL_CURRENCY_SYMBOL);
}

- (NSLocale *) locale
{
	return _locale;
}

- (NSNumber *) maximum
{
	return _maximum;
}

- (unsigned long) maximumFractionDigits
{
	return _GetIntAttribute(self, UNUM_MAX_FRACTION_DIGITS);
}

- (unsigned long) maximumIntegerDigits
{
	return _GetIntAttribute(self, UNUM_MAX_INTEGER_DIGITS);
}

- (unsigned long) maximumSignificantDigits
{
	return _GetIntAttribute(self, UNUM_MAX_SIGNIFICANT_DIGITS);
}

- (NSNumber *) minimum
{
	return _minimum;
}

- (unsigned long) minimumFractionDigits
{
	return _GetIntAttribute(self, UNUM_MIN_FRACTION_DIGITS);
}

- (unsigned long) minimumIntegerDigits
{
	return _GetIntAttribute(self, UNUM_MIN_INTEGER_DIGITS);
}

- (unsigned long) minimumSignificantDigits
{
	return _GetIntAttribute(self, UNUM_MIN_SIGNIFICANT_DIGITS);
}

- (NSString *) minusSign
{
	return _GetSymbol(self, UNUM_MINUS_SIGN_SYMBOL);
}

- (NSNumber *) multiplier
{
	return [NSNumber numberWithDouble:_GetDoubleAttribute(self, UNUM_MULTIPLIER)];
}

- (NSString *) negativeFormat
{
	TODO;	// negativeFormat
	return nil;
}

- (NSString *) negativePrefix
{
	return _GetTextAttribute(self, UNUM_NEGATIVE_PREFIX);
}

- (NSString *) negativeSuffix
{
	return _GetTextAttribute(self, UNUM_NEGATIVE_SUFFIX);
}

- (NSString *) nilSymbol
{
	return _nilSym;
}

- (NSString *) notANumberSymbol
{
	return _GetSymbol(self, UNUM_NAN_SYMBOL);
}

- (NSNumberFormatterStyle) numberStyle
{
	return _style;
}

- (NSString *) paddingCharacter
{
	return _GetTextAttribute(self, UNUM_PADDING_CHARACTER);
}

- (NSNumberFormatterPadPosition) paddingPosition
{
	return _GetIntAttribute(self, UNUM_PADDING_POSITION);
}

- (NSString *) percentSymbol
{
	return _GetSymbol(self, UNUM_PERCENT_SYMBOL);
}

- (NSString *) perMillSymbol
{
	return _GetSymbol(self, UNUM_PERMILL_SYMBOL);
}

- (NSString *) plusSign
{
	return _GetSymbol(self, UNUM_PLUS_SIGN_SYMBOL);
}

- (NSString *) positiveFormat
{
	TODO;	// positiveFormat
	return nil;
}

- (NSString *) positivePrefix
{
	return _GetTextAttribute(self, UNUM_POSITIVE_PREFIX);
}

- (NSString *) positiveSuffix
{
	return _GetTextAttribute(self, UNUM_POSITIVE_SUFFIX);
}

- (NSNumber *) roundingIncrememt
{
	return [NSNumber numberWithDouble:_GetDoubleAttribute(self, UNUM_ROUNDING_INCREMENT)];
}

- (NSNumberFormatterRoundingMode) roundingMode
{
	return _GetIntAttribute(self, UNUM_ROUNDING_MODE);
}

- (unsigned long) secondaryGroupingSize
{
	return _GetIntAttribute(self, UNUM_SECONDARY_GROUPING_SIZE);
}

- (void) setAlwaysShowsDecimalSeparator:(bool)alwaysShow
{
	_SetIntAttribute(self, UNUM_DECIMAL_ALWAYS_SHOWN, alwaysShow);
}

- (void) setCurrencyCode:(NSString *)newCode
{
	_SetTextAttribute(self, UNUM_CURRENCY_CODE, newCode);
}

- (void) setCurrencyDecimalSeparator:(NSString *)newSep
{
	_SetSymbol(self, UNUM_MONETARY_SEPARATOR_SYMBOL, newSep);
}

- (void) setCurrencyGroupingSeparator:(NSString *)newSep
{
	_SetSymbol(self, UNUM_MONETARY_GROUPING_SEPARATOR_SYMBOL, newSep);
}

- (void) setCurrencySymbol:(NSString *)newSym
{
	_SetSymbol(self, UNUM_CURRENCY_SYMBOL, newSym);
}

- (void) setDecimalSeparator:(NSString *)newSep
{
	_SetSymbol(self, UNUM_DECIMAL_SEPARATOR_SYMBOL, newSep);
}

- (void) setExponentSymbol:(NSString *)newSym
{
	_SetSymbol(self, UNUM_EXPONENTIAL_SYMBOL, newSym);
}

- (void) setFormatWidth:(unsigned long)newWidth
{
	_SetIntAttribute(self, UNUM_FORMAT_WIDTH, newWidth);
}

- (void) setGroupingSeparator:(NSString *)newSep
{
	_SetSymbol(self, UNUM_GROUPING_SEPARATOR_SYMBOL, newSep);
}

- (void) setGroupingSize:(unsigned long)newSize
{
	_SetIntAttribute(self, UNUM_GROUPING_SIZE, newSize);
}

- (void) setInternationalCurrencySymbol:(NSString *)newSym
{
	_SetSymbol(self, UNUM_INTL_CURRENCY_SYMBOL, newSym);
}

- (void) setLenient:(bool)lenient
{
	_SetIntAttribute(self, UNUM_LENIENT_PARSE, lenient);
}

/* TODO: Make this recreate the unum object */
- (void) setLocale:(NSLocale *)locale
{
	[locale retain];
	[_locale release];
	_locale = locale;
}

- (void) setMaximum:(NSNumber *)newMax
{
	[newMax retain];
	[_maximum release];
	_maximum = newMax;
}

- (void) setMaximumFractionDigits:(unsigned long)newMaxFrac
{
	_SetIntAttribute(self, UNUM_MAX_FRACTION_DIGITS, newMaxFrac);
}

- (void) setMaximumIntegerDigits:(unsigned long)newMaxInt
{
	_SetIntAttribute(self, UNUM_MAX_INTEGER_DIGITS, newMaxInt);
}

- (void) setMaximumSignificantDigits:(unsigned long)maxSigFig
{
	_SetIntAttribute(self, UNUM_MAX_SIGNIFICANT_DIGITS, maxSigFig);
}

- (void) setMinimum:(NSNumber *)newMin
{
	[newMin retain];
	[_minimum release];
	_minimum = newMin;
}

- (void) setMinimumFractionDigits:(unsigned long)newMinFrac
{
	_SetIntAttribute(self, UNUM_MIN_FRACTION_DIGITS, newMinFrac);
}

- (void) setMinimumIntegerDigits:(unsigned long)newMinInt
{
	_SetIntAttribute(self, UNUM_MIN_INTEGER_DIGITS, newMinInt);
}

- (void) setMinimumSignificantDigits:(unsigned long)minSigFig
{
	_SetIntAttribute(self, UNUM_MIN_SIGNIFICANT_DIGITS, minSigFig);
}

- (void) setMinusSign:(NSString *)newMinus
{
	_SetSymbol(self, UNUM_MINUS_SIGN_SYMBOL, newMinus);
}

- (void) setMultiplier:(NSNumber *)newMult
{
	_SetDoubleAttribute(self, UNUM_MULTIPLIER, [newMult doubleValue]);
}

- (void) setNegativeFormat:(NSString *)negForm
{
}

- (void) setNegativeInfinitySymbol:(NSString *)newNeg
{
}

- (void) setNegativePrefix:(NSString *)newNegPref
{
	_SetTextAttribute(self, UNUM_NEGATIVE_PREFIX, newNegPref);
}

- (void) setNegativeSuffix:(NSString *)newNegSuff
{
	_SetTextAttribute(self, UNUM_NEGATIVE_SUFFIX, newNegSuff);
}

- (void) setNilSymbol:(NSString *)newNil
{
	[newNil retain];
	[_nilSym release];
	_nilSym = newNil;
}

- (void) setNotANumberSymbol:(NSString *)newSym
{
}

- (void) setNumberStyle:(NSNumberFormatterStyle)newStyle
{
	_style = newStyle;
}

- (void) setPaddingCharacter:(NSString *)newPad
{
	return _SetTextAttribute(self, UNUM_PADDING_CHARACTER, newPad);
}

- (void) setPaddingPosition:(NSNumberFormatterPadPosition)newPos
{
	return _SetIntAttribute(self, UNUM_PADDING_POSITION, newPos);
}

- (void) setPartialStringValidationEnabled:(bool)enabled
{
	_partialValidate = enabled;
}

- (void) setPercentSymbol:(NSString *)newPercent
{
	_SetSymbol(self, UNUM_PERCENT_SYMBOL, newPercent);
}

- (void) setPerMillSymbol:(NSString *)newPerMill
{
	_SetSymbol(self, UNUM_PERMILL_SYMBOL, newPerMill);
}

- (void) setPlusSign:(NSString *)newPlus
{
	_SetSymbol(self, UNUM_PLUS_SIGN_SYMBOL, newPlus);
}

- (void) setPositiveFormat:(NSString *)posForm
{
}

- (void) setPositiveInfinitySymbol:(NSString *)newPos
{
}

- (void) setPositivePrefix:(NSString *)newPosPref
{
	_SetTextAttribute(self, UNUM_POSITIVE_PREFIX, newPosPref);
}

- (void) setPositiveSuffix:(NSString *)newPosSuff
{
	_SetTextAttribute(self, UNUM_POSITIVE_SUFFIX, newPosSuff);
}

- (void) setRoundingIncrement:(NSNumber *)newRound
{
	_SetDoubleAttribute(self, UNUM_ROUNDING_INCREMENT, [newRound doubleValue]);
}

- (void) setRoundingMode:(NSNumberFormatterRoundingMode)mode
{
	return _SetIntAttribute(self, UNUM_ROUNDING_MODE, mode);
}

- (void) setSecondaryGroupingSize:(unsigned long) newGroup
{
	return _SetIntAttribute(self, UNUM_SECONDARY_GROUPING_SIZE, newGroup);
}

#if 0
- (void) setTextAttributesForNegativeInfinity:(NSDictionary *)newAttribs
{
}

- (void) setTextAttributesForNegativeValues:(NSDictionary *)newAttribs
{
}

- (void) setTextAttributesForNil:(NSDictionary *)newAttribs
{
}

- (void) setTextAttributesForNotANumber:(NSDictionary *)newAttribs
{
}

- (void) setTextAttributesForPositiveInfinity:(NSDictionary *)newAttribs
{
}

- (void) setTextAttributesForPositiveValues:(NSDictionary *)newAttribs
{
}

- (void) setTextAttributesForZero:(NSDictionary *)newAttribs
{
}
#endif

- (void) setUsesGroupingSeparator:(bool)useGroup
{
	return _SetIntAttribute(self, UNUM_GROUPING_USED, useGroup);
}

- (void) setUsesSignificantDigits:(bool)useSigFigs
{
	return _SetIntAttribute(self, UNUM_SIGNIFICANT_DIGITS_USED, useSigFigs);
}

- (void) setZeroSymbol:(NSString *)newZero
{
	return _SetSymbol(self, UNUM_ZERO_DIGIT_SYMBOL, newZero);
}

#if 0
- (NSDictionary *) textAttributesForNegativeInfinity
{
}

- (NSDictionary *) textAttributesForNegativeValues
{
}

- (NSDictionary *) textAttributesForNil
{
}

- (NSDictionary *) textAttributesForNotANumber
{
}

- (NSDictionary *) textAttributesForPositiveInfinity
{
}

- (NSDictionary *) textAttributesForPositiveValues
{
}

- (NSDictionary *) textAttributesForZero
{
}
#endif

- (bool) usesGroupingSeparator
{
	return _GetIntAttribute(self, UNUM_GROUPING_USED);
}

- (bool) usesSignificantDigits
{
	return _GetIntAttribute(self, UNUM_SIGNIFICANT_DIGITS_USED);
}

- (NSString *) zeroSymbol
{
	return _GetSymbol(self, UNUM_ZERO_DIGIT_SYMBOL);
}

- (bool) getObjectValue:(out id *)obj forString:(NSString *)str range:(inout NSRange *)rangep error:(out NSError **)err
{
	UChar buffer[BUFFER_SIZE];
	UErrorCode ec = U_ZERO_ERROR;
	int strLength = [str length];
	int32_t parsePos = 0;
	_InitPrivate(self);
	[str getCharacters:buffer range:NSMakeRange(0, MIN(BUFFER_SIZE, strLength))];
	if ([self allowsFloats])
	{
		double d = unum_parseDouble(_private->_unf, buffer, BUFFER_SIZE-1, &parsePos, &ec);
		if (U_SUCCESS(ec))
			*obj = [NSNumber numberWithDouble:d];
	}
	else
	{
		int64_t i64 = unum_parseInt64(_private->_unf, buffer, BUFFER_SIZE-1, &parsePos, &ec);
		if (U_SUCCESS(ec))
			*obj = [NSNumber numberWithLongLong:i64];
	}
	if (U_FAILURE(ec))
	{
		return false;
	}
	if (err)
		*err = nil;
	return true;
}

+ (NSString *) localizedStringFromNumber:(NSNumber *)num numberStyle:(NSNumberFormatterStyle)numberStyle
{
	NSNumberFormatter *fmtr = [NSNumberFormatter new];
	[fmtr setNumberStyle:numberStyle];
	
	NSString *s = [fmtr stringFromNumber:num];
	[fmtr release];
	return s;
}

- (NSNumber *) numberFromString:(NSString *)str
{
	NSNumber *n = nil;
	if (![self getObjectValue:&n forString:str range:NULL error:NULL])
		return nil;

	return n;
}

- (NSString *) stringFromNumber:(NSNumber *)number
{
	UChar buffer[BUFFER_SIZE];
	UErrorCode ec = U_ZERO_ERROR;
	int len;
	_InitPrivate(self);
	if ([self allowsFloats])
	{
		len = unum_formatDouble(_private->_unf, [number doubleValue], buffer, BUFFER_SIZE-1, NULL, &ec);
	}
	else
	{
		len = unum_formatInt64(_private->_unf, [number longLongValue], buffer, BUFFER_SIZE-1, NULL, &ec);
	}
	return [NSString stringWithCharacters:buffer length:len];
}

- (bool) allowsFloats
{
	return !_GetIntAttribute(self, UNUM_PARSE_INT_ONLY);
}

- (void) setAllowsFloats:(bool)allowFloats
{
	_SetIntAttribute(self, UNUM_PARSE_INT_ONLY, !allowFloats);
}


@end
