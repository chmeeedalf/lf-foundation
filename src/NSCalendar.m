/* $Gold$	*/
/*
 * All rights reserved.
 * Copyright (c) 2009-2012	Justin Hibbits
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

#import <Foundation/NSCalendar.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSString.h>
#import <Foundation/NSTimeZone.h>
#import "DateTime/NSConcreteDate.h"
#include <unicode/ucal.h>
#include <strings.h>
#include <stdlib.h>

@class NSDate, NSLocale, NSString, NSTimeZone;

@implementation NSDateComponents
@synthesize era;
@synthesize year;
@synthesize month;
@synthesize date;
@synthesize day;
@synthesize hour;
@synthesize minute;
@synthesize second;
@synthesize week;
@synthesize weekday;
@synthesize weekdayOrdinal;
@synthesize quarter;
@synthesize weekOfMonth;
@synthesize weekOfYear;
@synthesize yearForWeekOfYear;
@synthesize timeZone;
@synthesize calendar;

- (void) encodeWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		[coder encodeInteger:[self era] forKey:@"GD.DC.era"];
		[coder encodeInteger:[self year] forKey:@"GD.DC.year"];
		[coder encodeInteger:[self month] forKey:@"GD.DC.month"];
		[coder encodeInteger:[self day] forKey:@"GD.DC.day"];
		[coder encodeInteger:[self hour] forKey:@"GD.DC.hour"];
		[coder encodeInteger:[self minute] forKey:@"GD.DC.minute"];
		[coder encodeInteger:[self second] forKey:@"GD.DC.second"];
		[coder encodeInteger:[self week] forKey:@"GD.DC.week"];
		[coder encodeInteger:[self weekday] forKey:@"GD.DC.weekday"];
		[coder encodeInteger:[self weekdayOrdinal] forKey:@"GD.DC.weekdayOrdinal"];
		[coder encodeInteger:[self quarter] forKey:@"GD.DC.quarter"];
	}
	else
	{
		NSInteger dateComp;

		dateComp = [self era];
		[coder encodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		dateComp = [self year];
		[coder encodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		dateComp = [self month];
		[coder encodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		dateComp = [self day];
		[coder encodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		dateComp = [self hour];
		[coder encodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		dateComp = [self minute];
		[coder encodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		dateComp = [self second];
		[coder encodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		dateComp = [self week];
		[coder encodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		dateComp = [self weekday];
		[coder encodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		dateComp = [self weekdayOrdinal];
		[coder encodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		dateComp = [self quarter];
		[coder encodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
	}
}

- (id) initWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		[self setEra:[coder decodeIntegerForKey:@"GD.DC.era"]];
		[self setYear:[coder decodeIntegerForKey:@"GD.DC.year"]];
		[self setMonth:[coder decodeIntegerForKey:@"GD.DC.month"]];
		[self setDay:[coder decodeIntegerForKey:@"GD.DC.day"]];
		[self setHour:[coder decodeIntegerForKey:@"GD.DC.hour"]];
		[self setMinute:[coder decodeIntegerForKey:@"GD.DC.minute"]];
		[self setSecond:[coder decodeIntegerForKey:@"GD.DC.second"]];
		[self setWeek:[coder decodeIntegerForKey:@"GD.DC.week"]];
		[self setWeekday:[coder decodeIntegerForKey:@"GD.DC.weekday"]];
		[self setWeekdayOrdinal:[coder decodeIntegerForKey:@"GD.DC.weekdayOrdinal"]];
		[self setQuarter:[coder decodeIntegerForKey:@"GD.DC.quarter"]];
	}
	else
	{
		NSInteger dateComp;

		[coder decodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		[self setEra:dateComp];
		[coder decodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		[self setYear:dateComp];
		[coder decodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		[self setMonth:dateComp];
		[coder decodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		[self setDay:dateComp];
		[coder decodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		[self setHour:dateComp];
		[coder decodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		[self setMinute:dateComp];
		[coder decodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		[self setSecond:dateComp];
		[coder decodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		[self setWeek:dateComp];
		[coder decodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		[self setWeekday:dateComp];
		[coder decodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		[self setWeekdayOrdinal:dateComp];
		[coder decodeValueOfObjCType:@encode(NSInteger) at:&dateComp];
		[self setQuarter:dateComp];
	}
	return self;
}

- (id) copyWithZone:(NSZone *)zone
{
	NSDateComponents *other = [[NSDateComponents allocWithZone:zone] init];

	[other setEra:[self era]];
	[other setYear:[self year]];
	[other setMonth:[self month]];
	[other setDay:[self day]];
	[other setHour:[self hour]];
	[other setMinute:[self minute]];
	[other setSecond:[self second]];
	[other setWeek:[self week]];
	[other setWeekday:[self weekday]];
	[other setWeekdayOrdinal:[self weekdayOrdinal]];
	[other setQuarter:[self quarter]];

	return other;
}

@end

@implementation NSCalendar
{
	UCalendar	*cal;
	NSString	*calIdent;
	NSTimeZone	*tz;
	NSLocale	*locale;
}

static NSCalendar *autoCalendar;

- (id) copyWithZone:(NSZone *)zone
{
	NSCalendar *other = [[NSCalendar allocWithZone:zone] _initWithUCalendar:cal];
	
	if (other != nil)
	{
		other->calIdent = calIdent;
		other->tz = tz;
		other->locale = locale;
	}
	return other;
}

+ (id) currentCalendar
{
	return [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
}

/* TODO: Handle NSUserDefaults changing, to update the calendar. */
+ (id) autoupdatingCurrentCalendar
{
	if (autoCalendar == nil)
	{
		@synchronized(self)
		{
			if (autoCalendar == nil)
			{
				autoCalendar = [[NSCalendar currentCalendar] copy];
			}
		}
	}
	return autoCalendar;
}

+ (NSCalendar *) _calendarWithUCalendar:(UCalendar *)ucal
{
	return [[self alloc] _initWithUCalendar:ucal];
}

- (id) _initWithUCalendar:(UCalendar *)ucal
{
	UErrorCode ec = U_ZERO_ERROR;
	cal = ucal_clone(ucal, &ec);
	return self;
}

- (id) initWithCalendarIdentifier:(NSString *)calIdentIn
{
	tz = [NSTimeZone defaultTimeZone];
	locale = [NSLocale currentLocale];
	self->calIdent = calIdentIn;
	return self;
}

static void zapCalendar(NSCalendar *self)
{
	if (self->cal != NULL)
	{
		ucal_close(self->cal);
		self->cal = NULL;
	}
}

- (void) setLocale:(NSLocale *)loc
{
	locale = loc;
	zapCalendar(self);
}

- (void) setTimeZone:(NSTimeZone *)newTz
{
	tz = newTz;
	zapCalendar(self);
}

- (NSString *)calendarIdentifier
{
	return calIdent;
}

#define BUFFER_SIZE 512
static bool configureCalendar(NSCalendar *self)
{
	if (self->cal != NULL)
		return true;
	char *localeID = NULL;
	int zoneID_len = 0;
	NSString *t = [[self timeZone] name];
	zoneID_len = [t length];
	UChar zoneID[zoneID_len + 1];
	zoneID[zoneID_len] = 0;
	[t getCharacters:zoneID range:NSMakeRange(0, zoneID_len)];

	localeID = malloc(BUFFER_SIZE);
	if (self->calIdent)
	{
		NSMutableDictionary *comps = [[NSLocale componentsFromLocaleIdentifier:[[self locale] localeIdentifier]] mutableCopy];
		[comps setObject:self->calIdent forKey:NSLocaleCalendarIdentifier];
		NSString *locID = [NSLocale localeIdentifierFromComponents:comps];
		[locID getCString:localeID maxLength:BUFFER_SIZE-1 encoding:NSASCIIStringEncoding];
	}
	else
	{
		[[[self locale] localeIdentifier] getCString:localeID maxLength:BUFFER_SIZE-1 encoding:NSASCIIStringEncoding];
	}
	UErrorCode ec = U_ZERO_ERROR;

	self->cal = ucal_open(zoneID, zoneID_len, localeID, UCAL_TRADITIONAL, &ec);
	free(localeID);
	return U_SUCCESS(ec);
}


- (NSInteger)firstWeekday
{
	if (configureCalendar(self))
		return ucal_getAttribute(cal, UCAL_FIRST_DAY_OF_WEEK);
	return -1;
}

- (NSLocale *)locale
{
	return locale ? locale : ([self setLocale:[NSLocale currentLocale]], locale);
}

- (NSRange)maximumRangeOfUnit:(NSCalendarUnit)calUnit
{
	NSRange r = NSMakeRange(0, 0);
	/* Converting from NSCalendarUnit to UCalendarDateFields is as simple as
	 * getting the first bit set.  This is by design, to simplify the
	 * conversion.
	 */
	int unit = ffs(calUnit) - 1;
	UErrorCode ec = U_ZERO_ERROR;
	if (configureCalendar(self))
	{
		r.location = ucal_getLimit(cal, unit, UCAL_MINIMUM, &ec);
		r.length = ucal_getLimit(cal, unit, UCAL_MAXIMUM, &ec) - r.location + 1;
		if (unit == UCAL_MONTH)
			r.location++;
	}

	return r;
}

- (NSInteger)minimumDaysInFirstWeek
{
	if (configureCalendar(self))
		return ucal_getAttribute(cal, UCAL_MINIMAL_DAYS_IN_FIRST_WEEK);
	return -1;
}

- (NSRange)minimumRangeOfUnit:(NSCalendarUnit)calUnit
{
	NSRange r = NSMakeRange(0, 0);
	/* Converting from NSCalendarUnit to UCalendarDateFields is as simple as
	 * getting the first bit set.  This is by design, to simplify the
	 * conversion.
	 */
	int unit = ffs(calUnit) - 1;
	UErrorCode ec = U_ZERO_ERROR;
	if (configureCalendar(self))
	{
		r.location = ucal_getLimit(cal, unit, UCAL_GREATEST_MINIMUM, &ec);
		r.length = ucal_getLimit(cal, unit, UCAL_LEAST_MAXIMUM, &ec) - r.location + 1;
		if (unit == UCAL_MONTH)
			r.location++;
	}

	return r;
}

- (NSTimeZone *)timeZone
{
	return tz ? tz : ([self setTimeZone:[NSTimeZone defaultTimeZone]], tz);
}

- (NSDateComponents *)components:(unsigned long)unitFlags fromDate:(NSDate *)date
{
	NSDateComponents *components = [NSDateComponents new];
	UErrorCode ec = U_ZERO_ERROR;

	configureCalendar(self);
	ucal_clear(cal);
	ucal_setMillis(cal, ICU_MSEC([date timeIntervalSinceReferenceDate]), &ec);

	if (unitFlags & NSEraCalendarUnit)
		components.era = ucal_get(cal, UCAL_ERA, &ec);
	if (unitFlags & NSYearCalendarUnit)
		components.year = ucal_get(cal, UCAL_YEAR, &ec);
	if (unitFlags & NSMonthCalendarUnit)
		components.month = ucal_get(cal, UCAL_MONTH, &ec);
	if (unitFlags & NSDayCalendarUnit)
		components.day = ucal_get(cal, UCAL_DAY_OF_MONTH, &ec);
	if (unitFlags & NSHourCalendarUnit)
		components.hour = ucal_get(cal, UCAL_HOUR_OF_DAY, &ec);
	if (unitFlags & NSMinuteCalendarUnit)
		components.minute = ucal_get(cal, UCAL_MINUTE, &ec);
	if (unitFlags & NSSecondCalendarUnit)
		components.second = ucal_get(cal, UCAL_SECOND, &ec);
	if (unitFlags & NSWeekCalendarUnit)
		components.week = ucal_get(cal, UCAL_WEEK_OF_MONTH, &ec);
	if (unitFlags & NSWeekdayCalendarUnit)
		components.weekday = ucal_get(cal, UCAL_DAY_OF_WEEK, &ec);

	return components;
}

- (NSDateComponents *)components:(unsigned long)unitFlags fromDate:(NSDate *)date toDate:(NSDate *)toDate options:(unsigned long)opts
{
	NSTimeInterval t = [toDate timeIntervalSinceReferenceDate] - [date timeIntervalSinceReferenceDate];
	NSDate *d = [[NSDate alloc] initWithTimeIntervalSince1970:t];

	NSDateComponents *dc = [self components:unitFlags fromDate:d];
	return dc;
}

- (NSDate *)dateByAddingComponents:(NSDateComponents *)components toDate:(NSDate *)startDate options:(unsigned long)opts
{
	configureCalendar(self);
	ucal_clear(cal);
	UErrorCode ec = U_ZERO_ERROR;
	long era = components.era;
	long year = components.year;
	long month = components.month;
	long week = components.week;
	long day = components.day;
	long weekday = components.weekday;
	long hour = components.hour;
	long minute = components.minute;
	long second = components.second;

	if (era != NSUndefinedDateComponent)
		ucal_add(cal, UCAL_ERA, era, &ec);
	if (year != NSUndefinedDateComponent)
		ucal_add(cal, UCAL_YEAR, year, &ec);
	if (month != NSUndefinedDateComponent)
		ucal_add(cal, UCAL_MONTH, month, &ec);
	if (week != NSUndefinedDateComponent)
		ucal_add(cal, UCAL_WEEK_OF_MONTH, week, &ec);
	if (day != NSUndefinedDateComponent)
		ucal_add(cal, UCAL_DAY_OF_MONTH, day, &ec);
	if (weekday != NSUndefinedDateComponent)
		ucal_add(cal, UCAL_DAY_OF_WEEK, weekday, &ec);
	if (hour != NSUndefinedDateComponent)
		ucal_add(cal, UCAL_HOUR_OF_DAY, hour, &ec);
	if (minute != NSUndefinedDateComponent)
		ucal_add(cal, UCAL_MINUTE, minute, &ec);
	if (second != NSUndefinedDateComponent)
		ucal_add(cal, UCAL_SECOND, second, &ec);

	UDate d = ucal_getMillis(cal, &ec);
	if (U_SUCCESS(ec))
		return [NSDate dateWithTimeIntervalSinceReferenceDate:UNIX_SEC(d)];
	return nil;
}

- (NSDate *)dateFromComponents:(NSDateComponents *)components
{
	configureCalendar(self);
	ucal_clear(cal);

	long era = components.era;
	long year = components.year;
	long month = components.month;
	long week = components.week;
	long day = components.day;
	long weekday = components.weekday;
	long hour = components.hour;
	long minute = components.minute;
	long second = components.second;

	if (era != NSUndefinedDateComponent)
		ucal_set(cal, UCAL_ERA, era);
	if (year != NSUndefinedDateComponent)
		ucal_set(cal, UCAL_YEAR, year);
	if (month != NSUndefinedDateComponent)
		ucal_set(cal, UCAL_MONTH, month);
	if (week != NSUndefinedDateComponent)
		ucal_set(cal, UCAL_WEEK_OF_MONTH, week);
	if (day != NSUndefinedDateComponent)
		ucal_set(cal, UCAL_DAY_OF_MONTH, day);
	if (weekday != NSUndefinedDateComponent)
		ucal_set(cal, UCAL_DAY_OF_WEEK, weekday);
	if (hour != NSUndefinedDateComponent)
		ucal_set(cal, UCAL_HOUR_OF_DAY, hour);
	if (minute != NSUndefinedDateComponent)
		ucal_set(cal, UCAL_MINUTE, minute);
	if (second != NSUndefinedDateComponent)
		ucal_set(cal, UCAL_SECOND, second);

	UErrorCode ec = U_ZERO_ERROR;
	UDate d = ucal_getMillis(cal, &ec);
	if (U_SUCCESS(ec))
		return [NSDate dateWithTimeIntervalSinceReferenceDate:UNIX_SEC(d)];
	return nil;
}

- (void) setFirstWeekday:(unsigned long)weekday
{
	if (configureCalendar(self))
		ucal_setAttribute(cal, UCAL_FIRST_DAY_OF_WEEK, weekday);
}

- (void) setMinimumDaysInFirstWeek:(unsigned long)min
{
	if (configureCalendar(self))
		ucal_setAttribute(cal, UCAL_MINIMAL_DAYS_IN_FIRST_WEEK, min);
}

- (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
{
	TODO; // -[NSCalendar ordinalityOfUnit:inUnit:forDate:]
	return 0;
}

- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
{
	TODO; // -[NSCalendar rangeOfUnit:inUnit:forDate:]
	return NSMakeRange(NSNotFound,0);
}

- (bool)rangeOfUnit:(NSCalendarUnit)smaller startDate:(NSDate **)start interval:(NSTimeInterval *)interval forDate:(NSDate *)date
{
	TODO; // -[NSCalendar rangeOfUnit:startDate:interval:forDate:]
	return false;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	TODO; // -[NSCalendar initWithCoder:]
}

- (id) initWithCoder:(NSCoder *)coder
{
	TODO; // -[NSCalendar initWithCoder:]
	return nil;
}
@end
