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
@property(nonatomic,strong) NSDate *defaultDate;
@property(nonatomic,copy) NSString *AMSymbol;
@property(nonatomic,copy) NSString *PMSymbol;
@property(nonatomic,copy) NSArray *eraSymbols;
@property(nonatomic,copy) NSArray *longEraSymbols;
@property(nonatomic,copy) NSArray *monthSymbols;
@property(nonatomic,copy) NSArray *shortMonthSymbols;
@property(nonatomic,copy) NSArray *standaloneMonthSymbols;
@property(nonatomic,copy) NSArray *shortStandaloneMonthSymbols;
@property(nonatomic,copy) NSArray *veryShortStandaloneMonthSymbols;
@property(nonatomic,copy) NSArray *shortWeekdaySymbols;
@property(nonatomic,copy) NSArray *standaloneWeekdaySymbols;
@property(nonatomic,copy) NSArray *shortStandaloneWeekdaySymbols;
@property(nonatomic,copy) NSArray *weekdaySymbols;
@property(nonatomic,copy) NSArray *veryShortWeekdaySymbols;
@property(nonatomic,copy) NSArray *veryShortStandaloneWeekdaySymbols;
@property(nonatomic,copy) NSArray *quarterSymbols;
@property(nonatomic,copy) NSArray *shortQuarterSymbols;
@property(nonatomic,copy) NSArray *shortStandaloneQuarterSymbols;
@property(nonatomic,copy) NSArray *standaloneQuarterSymbols;
@property(nonatomic,copy) NSCalendar *calendar;
@property(nonatomic,strong) NSTimeZone *timeZone;
@property(nonatomic,strong) NSDate *twoDigitStartDate;
@property NSDateFormatterStyle dateStyle;
@property NSDateFormatterStyle timeStyle;
@property(setter=setLenient:) bool isLenient;
@property(nonatomic,strong) NSLocale *locale;
@property(nonatomic,strong) NSDate *gregorianStartDate;
@property bool doesRelativeFormatting;

+ (NSString *)dateFormatFromTemplate:(NSString *)dfTemplate options:(unsigned long)opts locale:(NSLocale *)locale;
- (id) init;

- (void) setDateFormat:(NSString *)dateFormat;

- (bool) getObjectValue:(out id *)obj forString:(NSString *)str range:(inout NSRange *)rangep error:(out NSError **)err;

- (NSDate *)dateFromString:(NSString *)str;
- (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)localizedStringFromDate:(NSDate *)date dateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
@end
