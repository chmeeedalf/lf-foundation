/* $Gold$	*/
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

#include <limits.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>

@class NSDate, NSLocale, NSString, NSTimeZone;

enum {
	NSUndefinedDateComponent = LONG_MAX,
};

typedef enum {
	NSEraCalendarUnit = 1 << 1,
	NSYearCalendarUnit = 1 << 2,
	NSMonthCalendarUnit = 1 << 3,
	NSDayCalendarUnit = 1 << 4,
	NSHourCalendarUnit = 1 << 5,
	NSMinuteCalendarUnit = 1 << 6,
	NSSecondCalendarUnit = 1 << 7,
	NSWeekCalendarUnit = 1 << 8,
	NSWeekdayCalendarUnit = 1 << 9,
	NSWeekdayOrdinalCalendarUnit = 1 << 10,
	NSWeekOfMonthCalendarUnit = 1 << 11,
	NSWeekOfYearhCalendarUnit = 1 << 12,
	NSYearForWeekOfYearCalendarUnit = 1 << 13,
} NSCalendarUnit;

@interface NSDateComponents	:	NSObject<NSCoding,NSCopying>
{
	NSInteger era;
	NSInteger year;
	NSInteger month;
	NSDate *date;
	NSInteger day;
	NSInteger hour;
	NSInteger minute;
	NSInteger second;
	NSInteger week;
	NSInteger weekday;
	NSInteger weekdayOrdinal;
	NSInteger quarter;
	NSInteger weekOfMonth;
	NSInteger weekOfYear;
	NSInteger yearForWeekOfYear;
}
@property NSInteger era;
@property NSInteger year;
@property NSInteger month;
@property(retain,nonatomic) NSDate *date;
@property NSInteger day;
@property NSInteger hour;
@property NSInteger minute;
@property NSInteger second;
@property NSInteger week;
@property NSInteger weekday;
@property NSInteger weekdayOrdinal;
@property NSInteger quarter;
@property NSInteger weekOfMonth;
@property NSInteger weekOfYear;
@property NSInteger yearForWeekOfYear;
@end

@interface NSCalendar	:	NSObject<NSCoding,NSCopying>
{
}
+ currentCalendar;
+ autoupdatingCurrentCalendar;

- initWithCalendarIdentifier:(NSString *)calIdent;
- (void) setLocale:(NSLocale *)loc;
- (void) setTimeZone:(NSTimeZone *)newTz;
- (void) setFirstWeekday:(unsigned long)weekday;
- (void) setMinimumDaysInFirstWeek:(unsigned long)min;

- (NSString *)calendarIdentifier;
- (int)firstWeekday;
- (NSLocale *)locale;
- (NSRange)maximumRangeOfUnit:(NSCalendarUnit)calUnit;
- (int)minimumDaysInFirstWeek;
- (NSRange)minimumRangeOfUnit:(NSCalendarUnit)calUnit;
- (unsigned long)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date;
- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date;
- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller startDate:(NSDate *)start interval:(NSTimeInterval)interval forDate:(NSDate *)date;
- (NSTimeZone *)timeZone;

- (NSDateComponents *)components:(unsigned long)unitFlags fromDate:(NSDate *)date;
- (NSDateComponents *)components:(unsigned long)unitFlags fromDate:(NSDate *)date toDate:(NSDate *)toDate options:(unsigned long)opts;
- (NSDate *)dateByAddingComponents:(NSDateComponents *)components toDate:(NSDate *)startDate options:(unsigned long)opts;
- (NSDate *)dateFromComponents:(NSDateComponents *)components;

@end
