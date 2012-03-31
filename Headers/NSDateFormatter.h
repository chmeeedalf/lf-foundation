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

@class NSArray, NSCalendar, NSDate, NSString, NSLocale, NSTimeZone;

typedef enum
{
	NSDateFormatterFullStyle,
	NSDateFormatterLongStyle,
	NSDateFormatterMediumStyle,
	NSDateFormatterShortStyle,
	NSDateFormatterNoStyle = -1,
} NSDateFormatterStyle;

@interface NSDateFormatter	:	NSFormatter
@property(nonatomic,copy) NSDate *defaultDate;

+ (NSString *)dateFormatFromTemplate:(NSString *)dfTemplate options:(unsigned long)opts locale:(NSLocale *)locale;
- (id) init;

- (NSString *)AMSymbol;
- (void) setAMSymbol:(NSString *)newAM;
- (NSString *)PMSymbol;
- (void) setPMSymbol:(NSString *)newPM;
- (NSArray *)eraSymbols;
- (void) setEraSymbols:(NSArray *)newEra;
- (NSCalendar *)calendar;
- (void) setCalendar:(NSCalendar *)newCal;
- (void) setDateFormat:(NSString *)dateFormat;
- (NSDateFormatterStyle)dateStyle;
- (void) setTimeStyle:(NSDateFormatterStyle)style;
- (NSDateFormatterStyle)timeStyle;
- (void) setDateStyle:(NSDateFormatterStyle)style;
- (NSTimeZone *)timeZone;
- (void) setTimeZone:(NSTimeZone *)tz;
- (NSDate *)twoDigitStartDate;
- (void) setTwoDigitStartDate:(NSDate *)date;

- (NSArray *)monthSymbols;
- (void) setMonthSymbols:(NSArray *)monthSymbols;
- (NSArray *)shortMonthSymbols;
- (void) setShortMonthSymbols:(NSArray *)shortSyms;
- (NSArray *)shortStandaloneMonthSymbols;
- (void) setShortStandaloneMonthSymbols:(NSArray *)shortSyms;
- (NSArray *)shortStandaloneMonthSymbols;
- (void) setShortStandaloneMonthSymbols:(NSArray *)newSyms;
- (NSArray *)standaloneMonthSymbols;
- (void) setStandaloneMonthSymbols:(NSArray *)newSyms;
- (NSArray *)veryShortMonthSymbols;
- (void) setVeryShortMonthSymbols:(NSArray *)newSyms;
- (NSArray *)veryShortStandaloneMonthSymbols;
- (void) setVeryShortStandaloneMonthSymbols:(NSArray *)newSyms;

- (NSArray *)shortWeekdaySymbols;
- (void) setShortWeekdaySymbols:(NSArray *)weekdays;
- (NSArray *)shortStandaloneWeekdaySymbols;
- (void) setShortStandaloneWeekdaySymbols:(NSArray *)weekdays;
- (NSArray *)standaloneWeekdaySymbols;
- (void) standaloneWeekdaySymbols:(NSArray *)weekdays;
- (NSArray *) weekdaySymbols;
- (void)setWeekdaySymbols:(NSArray *)weekdays;
- (NSArray *)veryShortWeekdaySymbols;
- (void) setVeryShortWeekdaySymbols:(NSArray *)newSyms;
- (NSArray *)veryShortStandaloneWeekdaySymbols;
- (void) setVeryShortStandaloneWeekdaySymbols:(NSArray *)newSyms;

- (bool) isLenient;
- (void) setLenient:(bool)b;
- (NSLocale *)locale;
- (void) setLocale:(NSLocale *)newLocale;

- (NSDate *)gregorianStartdate;
- (void) setGregorianStartDate:(NSDate *)newDate;
- (NSArray *)longEraSymbols;
- (void) setLongEraSymbols:(NSArray *)newSyms;

- (NSArray *)quarterSymbols;
- (void) setQuarterSymbols:(NSArray *)newSyms;
- (NSArray *)shortQuarterSymbols;
- (void) setShortQuarterSymbols:(NSArray *)newSyms;
- (NSArray *)shortStandaloneQuarterSymbols;
- (void) setShortStandaloneQuarterSymbols:(NSArray *)newSyms;
- (NSArray *)standaloneQuarterSymbols;
- (void) setStandaloneQuarterSymbols:(NSArray *)newSyms;

- (bool) getObjectValue:(out id *)obj forString:(NSString *)str range:(inout NSRange *)rangep error:(out NSError **)err;

- (NSDate *)dateFromString:(NSString *)str;
- (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)localizedStringFromDate:(NSDate *)date dateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
- (bool) doesRelativeFormatting;
- (void) setDoesRelativeFormatting:(bool)doRel;
@end
