/*
 * Copyright (c) 2005,2011-2012	Justin Hibbits
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

#import <Foundation/NSDateFormatter.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDate.h>
#import "DateTime/NSConcreteDate.h"
#import <Foundation/NSLocale.h>
#import <Foundation/NSString.h>
#import <Foundation/NSTimeZone.h>
#import "internal.h"
#include <unicode/udat.h>
#include <unicode/udatpg.h>

#define BUFFER_SIZE 768

@implementation NSDateFormatter
{
	UDateFormat *_udf;
	UParseError _parseError;
	NSLocale *_locale;
	NSDateFormatterStyle _dateStyle;
	NSDateFormatterStyle _timeStyle;
	NSTimeZone *_timeZone;
	bool	_relative;
	NSDate	*defaultDate;
}

@synthesize defaultDate;

static void _InitPrivate(NSDateFormatter *self)
{
	UErrorCode ec = U_ZERO_ERROR;
	UChar *tzID;
	NSUInteger tzLen;
	if (self->_udf != NULL)
	{
		return;
	}

	tzLen = [[self->_timeZone name] length];
	tzID = malloc(tzLen * sizeof(*tzID));
	[[self->_timeZone name] getCharacters:tzID range:NSMakeRange(0, tzLen)];
	self->_udf = udat_open(self->_relative | self->_dateStyle, self->_relative | self->_timeStyle, [[self->_locale localeIdentifier] cStringUsingEncoding:NSUTF8StringEncoding], tzID, tzLen, NULL, 0, &ec);
	if (!U_SUCCESS(ec))
		NSLog(@"Warning: Unable to create ICU number formatter: %s", u_errorName(ec));
	return;
}

static NSString *_GetSymbolWithIndex(NSDateFormatter *self, UDateFormatSymbolType type, int32_t index)
{
	UErrorCode ec = U_ZERO_ERROR;
	UChar buffer[BUFFER_SIZE];
	int32_t strLen = udat_getSymbols(self->_udf, type, index, buffer, BUFFER_SIZE - 1, &ec);
	if (strLen > 0)
	{
		return [NSString stringWithCharacters:buffer length:strLen];
	}
	return nil;
}

static void _SetSymbolWithIndex(NSDateFormatter *self, UDateFormatSymbolType type, int32_t index, NSString *value)
{
	int32_t len = [value length];
	UChar icuBuffer[BUFFER_SIZE];
	UErrorCode ec = U_ZERO_ERROR;

	[value getCharacters:icuBuffer range:NSMakeRange(0, MIN(len, BUFFER_SIZE-1))];
	udat_setSymbols(self->_udf, type, index, icuBuffer, len, &ec);
}

static NSArray *_GetSymbolArray(NSDateFormatter *self, UDateFormatSymbolType type)
{
	_InitPrivate(self);

	int32_t count = udat_countSymbols(self->_udf, type);
	NSString *returns[count];

	for (int i = 0; i < count; i++)
	{
		UErrorCode ec = U_ZERO_ERROR;
		UChar buffer[BUFFER_SIZE];
		int32_t strLen = udat_getSymbols(self->_udf, type, i, buffer, BUFFER_SIZE - 1, &ec);
		if (strLen > 0)
		{
			returns[i] = [[NSString alloc] initWithCharacters:buffer length:strLen];
		}
	}
	NSArray *retval = [NSArray arrayWithObjects:returns count:count];

	return retval;
}

static void _SetSymbolArray(NSDateFormatter *self, UDateFormatSymbolType type, NSArray *values)
{
	UChar icuBuffer[BUFFER_SIZE];
	_InitPrivate(self);
	int32_t count = [values count];

	for (int i = 0; i < count; i++)
	{
		NSString *s = [values objectAtIndex:i];
		int32_t len = [s length];
		UErrorCode ec = U_ZERO_ERROR;

		[s getCharacters:icuBuffer range:NSMakeRange(0, len)];
		udat_setSymbols(self->_udf, type, i, icuBuffer, len, &ec);
	}
}

+ (NSString *)dateFormatFromTemplate:(NSString *)template options:(unsigned long)opts locale:(NSLocale *)locale
{
	const char *localeIdent = [[locale localeIdentifier] cStringUsingEncoding:NSUTF8StringEncoding];
	int32_t len = [template length];
	UChar pattern[len];
	UChar skel[len];
	UChar bpat[len];
	UErrorCode ec = U_ZERO_ERROR;
	[template getCharacters:pattern range:NSMakeRange(0, len)];
	UDateTimePatternGenerator *datpg = udatpg_open(localeIdent, &ec);
	int32_t skelLen = udatpg_getSkeleton(datpg, pattern, len, skel, sizeof(skel)/sizeof(UChar), &ec);
	if (U_FAILURE(ec))
	{
		udatpg_close(datpg);
		return nil;
	}
	int32_t patlen = udatpg_getBestPattern(datpg, skel, skelLen, bpat, sizeof(bpat)/sizeof(UChar), &ec);
	udatpg_close(datpg);

	if (U_FAILURE(ec))
		return nil;

	return [NSString stringWithCharacters:bpat length:patlen];
}

- (id) init
{
	return self;
}

- (NSString *)AMSymbol
{
	return _GetSymbolWithIndex(self, UDAT_AM_PMS, 0);
}

- (void) setAMSymbol:(NSString *)newAM
{
	_SetSymbolWithIndex(self, UDAT_AM_PMS, 0, newAM);
}

- (NSString *)PMSymbol
{
	return _GetSymbolWithIndex(self, UDAT_AM_PMS, 1);
}

- (void) setPMSymbol:(NSString *)newPM
{
	_SetSymbolWithIndex(self, UDAT_AM_PMS, 1, newPM);
}

- (NSArray *)eraSymbols
{
	return _GetSymbolArray(self, UDAT_ERAS);
}

- (void) setEraSymbols:(NSArray *)newEra
{
	_SetSymbolArray(self, UDAT_ERAS, newEra);
}

- (NSCalendar *)calendar
{
	_InitPrivate(self);
	return [NSCalendar _calendarWithUCalendar:__DECONST(UCalendar *, udat_getCalendar(_udf))];
}

- (void) setCalendar:(NSCalendar *)newCal
{
	_InitPrivate(self);
	udat_setCalendar(_udf, [newCal _ucalendar]);
}

- (NSString *) dateFormat
{
	NSInteger patlen;
	UErrorCode err;
	UChar *chars;
	
	patlen = udat_toPattern(_udf, true, NULL, 0, &err);

	chars = malloc(patlen * sizeof(*chars));
	patlen = udat_toPattern(_udf, true, chars, patlen, &err);

	return [[NSString alloc] initWithCharactersNoCopy:chars length:patlen freeWhenDone:true];
}

- (void) setDateFormat:(NSString *)dateFormat
{
	NSUInteger len = [dateFormat length];

	UChar chars[len];

	[dateFormat getCharacters:chars range:NSMakeRange(0,len)];

	_InitPrivate(self);
	udat_applyPattern(_udf, true, chars, len);
}

- (NSDateFormatterStyle)dateStyle
{
	return _dateStyle;
}

- (void) setTimeStyle:(NSDateFormatterStyle)style
{
	_timeStyle = style;
}

- (NSDateFormatterStyle)timeStyle
{
	return _timeStyle;
}

- (void) setDateStyle:(NSDateFormatterStyle)style
{
	_dateStyle = style;
}

- (NSTimeZone *)timeZone
{
	return _timeZone;
}

- (void) setTimeZone:(NSTimeZone *)tz
{
	_timeZone = tz;
}

- (NSDate *)twoDigitStartDate
{
	_InitPrivate(self);
	UErrorCode ec = U_ZERO_ERROR;
	UDate d = udat_get2DigitYearStart(_udf, &ec);
	if (U_FAILURE(ec))
		return nil;
	return [NSDate dateWithTimeIntervalSince1970:d];
}

- (void) setTwoDigitStartDate:(NSDate *)date
{
	_InitPrivate(self);
	UErrorCode ec = U_ZERO_ERROR;
	UDate d = [date timeIntervalSince1970];
	udat_set2DigitYearStart(_udf, d, &ec);
}


- (NSArray *)monthSymbols
{
	return _GetSymbolArray(self, UDAT_MONTHS);
}

- (void) setMonthSymbols:(NSArray *)monthSymbols
{
	_SetSymbolArray(self, UDAT_MONTHS, monthSymbols);
}

- (NSArray *)shortMonthSymbols
{
	return _GetSymbolArray(self, UDAT_SHORT_MONTHS);
}

- (void) setShortMonthSymbols:(NSArray *)shortSyms
{
	_SetSymbolArray(self, UDAT_SHORT_MONTHS, shortSyms);
}

- (NSArray *)shortStandaloneMonthSymbols
{
	return _GetSymbolArray(self, UDAT_STANDALONE_SHORT_MONTHS);
}

- (void) setShortStandaloneMonthSymbols:(NSArray *)shortSyms
{
	_SetSymbolArray(self, UDAT_STANDALONE_SHORT_MONTHS, shortSyms);
}

- (NSArray *)standaloneMonthSymbols
{
	return _GetSymbolArray(self, UDAT_STANDALONE_MONTHS);
}

- (void) setStandaloneMonthSymbols:(NSArray *)newSyms
{
	_SetSymbolArray(self, UDAT_STANDALONE_MONTHS, newSyms);
}

- (NSArray *)veryShortMonthSymbols
{
	return _GetSymbolArray(self, UDAT_NARROW_MONTHS);
}

- (void) setVeryShortMonthSymbols:(NSArray *)newSyms
{
	_SetSymbolArray(self, UDAT_NARROW_MONTHS, newSyms);
}

- (NSArray *)veryShortStandaloneMonthSymbols
{
	return _GetSymbolArray(self, UDAT_STANDALONE_NARROW_MONTHS);
}

- (void) setVeryShortStandaloneMonthSymbols:(NSArray *)newSyms
{
	_SetSymbolArray(self, UDAT_STANDALONE_NARROW_MONTHS, newSyms);
}


- (NSArray *)shortWeekdaySymbols
{
	return _GetSymbolArray(self, UDAT_SHORT_WEEKDAYS);
}

- (void) setShortWeekdaySymbols:(NSArray *)weekdays
{
	_SetSymbolArray(self, UDAT_SHORT_WEEKDAYS, weekdays);
}

- (NSArray *)shortStandaloneWeekdaySymbols
{
	return _GetSymbolArray(self, UDAT_STANDALONE_SHORT_WEEKDAYS);
}

- (void) setShortStandaloneWeekdaySymbols:(NSArray *)weekdays
{
	_SetSymbolArray(self, UDAT_STANDALONE_SHORT_WEEKDAYS, weekdays);
}

- (NSArray *)standaloneWeekdaySymbols
{
	return _GetSymbolArray(self, UDAT_STANDALONE_WEEKDAYS);
}

- (void) setStandaloneWeekdaySymbols:(NSArray *)weekdays
{
	_SetSymbolArray(self, UDAT_STANDALONE_WEEKDAYS, weekdays);
}

- (NSArray *) weekdaySymbols
{
	return _GetSymbolArray(self, UDAT_WEEKDAYS);
}

- (void)setWeekdaySymbols:(NSArray *)weekdays
{
	_SetSymbolArray(self, UDAT_WEEKDAYS, weekdays);
}

- (NSArray *)veryShortWeekdaySymbols
{
	return _GetSymbolArray(self, UDAT_NARROW_WEEKDAYS);
}

- (void) setVeryShortWeekdaySymbols:(NSArray *)newSyms
{
	_SetSymbolArray(self, UDAT_NARROW_WEEKDAYS, newSyms);
}

- (NSArray *)veryShortStandaloneWeekdaySymbols
{
	return _GetSymbolArray(self, UDAT_STANDALONE_NARROW_WEEKDAYS);
}

- (void) setVeryShortStandaloneWeekdaySymbols:(NSArray *)newSyms
{
	_SetSymbolArray(self, UDAT_STANDALONE_NARROW_WEEKDAYS, newSyms);
}


- (bool) isLenient
{
	_InitPrivate(self);
	return udat_isLenient(_udf);
}

- (void) setLenient:(bool)b
{
	_InitPrivate(self);
	udat_setLenient(_udf, b);
}

- (NSLocale *)locale
{
	return _locale;
}

- (void) setLocale:(NSLocale *)newLocale
{
	_locale = newLocale;
}


- (NSDate *)gregorianStartDate
{
	const UCalendar *cal = udat_getCalendar(_udf);
	UErrorCode ec = U_ZERO_ERROR;
	return [NSDate dateWithTimeIntervalSinceReferenceDate:UNIX_SEC(ucal_getGregorianChange(cal, &ec))];
}

- (void) setGregorianStartDate:(NSDate *)newDate
{
	UCalendar *cal = (UCalendar *)udat_getCalendar(_udf);
	UErrorCode ec = U_ZERO_ERROR;

	ucal_setGregorianChange(cal, ICU_MSEC([newDate timeIntervalSinceReferenceDate]), &ec);
}

- (NSArray *)longEraSymbols
{
	return _GetSymbolArray(self, UDAT_ERA_NAMES);
}

- (void) setLongEraSymbols:(NSArray *)newSyms
{
	_SetSymbolArray(self, UDAT_ERA_NAMES, newSyms);
}


- (NSArray *)quarterSymbols
{
	return _GetSymbolArray(self, UDAT_QUARTERS);
}

- (void) setQuarterSymbols:(NSArray *)newSyms
{
	_SetSymbolArray(self, UDAT_QUARTERS, newSyms);
}

- (NSArray *)shortQuarterSymbols
{
	return _GetSymbolArray(self, UDAT_SHORT_QUARTERS);
}

- (void) setShortQuarterSymbols:(NSArray *)newSyms
{
	_SetSymbolArray(self, UDAT_SHORT_QUARTERS, newSyms);
}

- (NSArray *)shortStandaloneQuarterSymbols
{
	return _GetSymbolArray(self, UDAT_STANDALONE_SHORT_QUARTERS);
}

- (void) setShortStandaloneQuarterSymbols:(NSArray *)newSyms
{
	_SetSymbolArray(self, UDAT_STANDALONE_SHORT_QUARTERS, newSyms);
}

- (NSArray *)standaloneQuarterSymbols
{
	return _GetSymbolArray(self, UDAT_STANDALONE_QUARTERS);
}

- (void) setStandaloneQuarterSymbols:(NSArray *)newSyms
{
	_SetSymbolArray(self, UDAT_STANDALONE_QUARTERS, newSyms);
}


- (bool) getObjectValue:(out id *)obj forString:(NSString *)str range:(inout NSRange *)rangep error:(out NSError **)err
{
	UErrorCode ec = U_ZERO_ERROR;
	_InitPrivate(self);
	UChar buffer[BUFFER_SIZE];
	int32_t len = [str length];
	int32_t parsePos = 0;
	[str getCharacters:buffer range:NSMakeRange(0, MIN(len, BUFFER_SIZE-1))];

	UDate d = udat_parse(_udf, buffer, MIN(len, BUFFER_SIZE-1), &parsePos, &ec);
	if (U_FAILURE(ec))
	{
		/* TODO: Real errors */
		return false;
	}

	if (rangep != NULL)
		*rangep = NSMakeRange(0, parsePos);
	*obj = [NSDate dateWithTimeIntervalSince1970:d];
	if (err)
		*err = nil;

	return true;
}


- (NSDate *)dateFromString:(NSString *)str
{
	NSDate *d;

	if (![self getObjectValue:&d forString:str range:NULL error:NULL])
		return nil;
	return d;
}

- (NSString *)stringFromDate:(NSDate *)date
{
	_InitPrivate(self);

	UDate d = ICU_MSEC([date timeIntervalSinceReferenceDate]);
	UChar buffer[BUFFER_SIZE];
	UErrorCode ec = U_ZERO_ERROR;

	int32_t len = udat_format(_udf, d, buffer, BUFFER_SIZE-1, NULL, &ec);

	if (U_FAILURE(ec))
		return nil;
	return [NSString stringWithCharacters:buffer length:MIN(BUFFER_SIZE-1, len)];
}

+ (NSString *)localizedStringFromDate:(NSDate *)date dateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
	UChar buffer[BUFFER_SIZE];
	UErrorCode ec = U_ZERO_ERROR;

	UDateFormat ufmt = udat_open((UDateFormatStyle)dateStyle, (UDateFormatStyle)timeStyle, NULL, NULL, 0, NULL, 0, &ec);
	int32_t len = udat_format(ufmt, ICU_MSEC([date timeIntervalSinceReferenceDate]), buffer, BUFFER_SIZE - 1, NULL, &ec);
	NSString *ret = [NSString stringWithCharacters:buffer length:MIN(BUFFER_SIZE-1, len)];
	udat_close(ufmt);
	return ret;
}

- (bool) doesRelativeFormatting
{
	return _relative;
}

- (void) setDoesRelativeFormatting:(bool)doRel
{
	_relative = doRel;
}

-(void) dealloc
{
	udat_close(self->_udf);
}
@end
