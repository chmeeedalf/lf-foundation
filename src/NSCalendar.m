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

- initWithCoder:(NSCoder *)coder
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

- copyWithZone:(NSZone *)zone
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

@interface AutoCalendar		:	NSCalendar
{
	NSCalendar *cal;
	NSTimeZone *changedTZ;
	NSLocale *changedLocale;
	unsigned long changedWeekday;
	unsigned long changedMinimumDays;
}
@end

#ifndef _ICUCAL_DEF
@interface ConcreteICUCalendar	:	NSCalendar
{
	UCalendar *cal;
	NSString *calIdent;
	NSTimeZone *tz;
	NSLocale *locale;
}

- _initWithUCalendar:(UCalendar *)cal;
@end
#define _ICUUCAL_DEF
#endif

@implementation NSCalendar

static Class CalendarClass;
static Class ConcreteICUCalendarClass;

+ (void) initialize
{
	CalendarClass = [NSCalendar class];
	ConcreteICUCalendarClass = [ConcreteICUCalendar class];
}

+ currentCalendar
{
	return [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
}

+ autoupdatingCurrentCalendar
{
	return [[[AutoCalendar alloc] init] autorelease];
}

+ (NSCalendar *) _calendarWithUCalendar:(UCalendar *)ucal
{
	return [[[ConcreteICUCalendar alloc] _initWithUCalendar:ucal] autorelease];
}

+ allocWithZone:(NSZone *)zone
{
	if (self == CalendarClass)
		return NSAllocateObject(ConcreteICUCalendarClass, 0, zone);
	return [super allocWithZone:zone];
}

- initWithCalendarIdentifier:(NSString *)calIdent
{
	[self subclassResponsibility:_cmd];
	[self release];
	return nil;
}

- (void) setLocale:(NSLocale *)loc
{
	[self subclassResponsibility:_cmd];
}

- (void) setTimeZone:(NSTimeZone *)newTz
{
	[self subclassResponsibility:_cmd];
}


- (NSString *)calendarIdentifier
{
	return [self subclassResponsibility:_cmd];
}

- (int)firstWeekday
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (NSLocale *)locale
{
	return [self subclassResponsibility:_cmd];
}

- (NSRange)maximumRangeOfUnit:(NSCalendarUnit)calUnit
{
	[self subclassResponsibility:_cmd];
	return NSMakeRange(0, 0);
}

- (int)minimumDaysInFirstWeek
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (NSRange)minimumRangeOfUnit:(NSCalendarUnit)calUnit
{
	[self subclassResponsibility:_cmd];
	return NSMakeRange(0, 0);
}

- (unsigned long)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
{
	[self subclassResponsibility:_cmd];
	return NSMakeRange(0, 0);
}

- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller startDate:(NSDate *)start interval:(NSTimeInterval)interval forDate:(NSDate *)date
{
	[self subclassResponsibility:_cmd];
	return NSMakeRange(0, 0);
}

- (NSTimeZone *)timeZone
{
	return [self subclassResponsibility:_cmd];
}


- (NSDateComponents *)components:(unsigned long)unitFlags fromDate:(NSDate *)date
{
	return [self subclassResponsibility:_cmd];
}

- (NSDateComponents *)components:(unsigned long)unitFlags fromDate:(NSDate *)date toDate:(NSDate *)toDate options:(unsigned long)opts
{
	return [self subclassResponsibility:_cmd];
}

- (NSDate *)dateByAddingComponents:(NSDateComponents *)components toDate:(NSDate *)startDate options:(unsigned long)opts
{
	return [self subclassResponsibility:_cmd];
}

- (NSDate *)dateFromComponents:(NSDateComponents *)components
{
	return [self subclassResponsibility:_cmd];
}

- (void) setFirstWeekday:(unsigned long)weekday
{
	[self subclassResponsibility:_cmd];
}

- (void) setMinimumDaysInFirstWeek:(unsigned long)min
{
	[self subclassResponsibility:_cmd];
}

@end

@implementation ConcreteICUCalendar

#define BUFFER_SIZE 512
static bool configureCalendar(ConcreteICUCalendar *self)
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
		[comps release];
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

static void zapCalendar(ConcreteICUCalendar *self)
{
	if (self->cal != NULL)
	{
		ucal_close(self->cal);
		self->cal = NULL;
	}
}

- _initWithUCalendar:(UCalendar *)ucal
{
	UErrorCode ec = U_ZERO_ERROR;
	cal = ucal_clone(ucal, &ec);
	return self;
}

- initWithCalendarIdentifier:(NSString *)calIdentIn
{
	tz = [[NSTimeZone defaultTimeZone] retain];
	locale = [[NSLocale currentLocale] retain];
	self->calIdent = [calIdentIn retain];
	return self;
}

- (void) setLocale:(NSLocale *)loc
{
	[loc retain];
	[locale release];
	locale = loc;
	zapCalendar(self);
}

- (void) setTimeZone:(NSTimeZone *)newTz
{
	[newTz retain];
	[tz release];
	tz = newTz;
	zapCalendar(self);
}


- (NSString *)calendarIdentifier
{
	return calIdent;
}

- (int)firstWeekday
{
	if (configureCalendar(self))
		return ucal_getAttribute(cal, UCAL_FIRST_DAY_OF_WEEK);
	return -1;
}

- (NSLocale *)locale
{
	return locale ?: ([self setLocale:[NSLocale currentLocale]], locale);
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

- (int)minimumDaysInFirstWeek
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

- (unsigned long)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
{
	[self subclassResponsibility:_cmd];
	return NSMakeRange(0, 0);
}

- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller startDate:(NSDate *)start interval:(NSTimeInterval)interval forDate:(NSDate *)date
{
	[self subclassResponsibility:_cmd];
	return NSMakeRange(0, 0);
}

- (NSTimeZone *)timeZone
{
	return tz ?: ([self setTimeZone:[NSTimeZone defaultTimeZone]], tz);
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

	return [components autorelease];
}

- (NSDateComponents *)components:(unsigned long)unitFlags fromDate:(NSDate *)date toDate:(NSDate *)toDate options:(unsigned long)opts
{
	NSTimeInterval t = [toDate timeIntervalSinceReferenceDate] - [date timeIntervalSinceReferenceDate];
	NSDate *d = [[NSDate alloc] initWithTimeIntervalSince1970:t];

	NSDateComponents *dc = [self components:unitFlags fromDate:d];
	[d release];
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

@end

@implementation AutoCalendar
void updateCalendar(AutoCalendar *self)
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	if ([[cal calendarIdentifier] isEqual:[self->cal calendarIdentifier]])
	{
		[self->cal release];
	}
	self->cal = [cal retain];
	if (self->changedTZ != nil)
		[cal setTimeZone:self->changedTZ];
	if (self->changedLocale != nil)
		[cal setLocale:self->changedLocale];
	if (self->changedWeekday != 0)
		[cal setFirstWeekday:self->changedWeekday];
	if (self->changedMinimumDays)
		[cal setMinimumDaysInFirstWeek:self->changedMinimumDays];
}

- initWithCalendarIdentifier:(NSString *)calIdent
{
	[self notImplemented:_cmd];
	return nil;
}

- init
{
	/* All real initialization happens when we actually do something. */
	return self;
}

- (void) setLocale:(NSLocale *)loc
{
	[loc retain];
	[changedLocale release];
	changedLocale = loc;
}

- (void) setTimeZone:(NSTimeZone *)newTz
{
	[newTz retain];
	[changedTZ release];
	changedTZ = newTz;
}

- (void) setFirstWeekday:(unsigned long)weekday
{
	changedWeekday = weekday;
}

- (void) setMinimumDaysInFirstWeek:(unsigned long)min
{
	changedMinimumDays = min;
}

- (NSString *)calendarIdentifier
{
	updateCalendar(self);
	return [cal calendarIdentifier];
}

- (int)firstWeekday
{
	if (changedWeekday)
		return changedWeekday;
	updateCalendar(self);
	return [cal firstWeekday];
}

- (NSLocale *)locale
{
	if (changedLocale)
		return changedLocale;
	updateCalendar(self);
	return [cal locale];
}

- (NSRange)maximumRangeOfUnit:(NSCalendarUnit)calUnit
{
	updateCalendar(self);
	return [cal maximumRangeOfUnit:calUnit];
}

- (int)minimumDaysInFirstWeek
{
	if (changedMinimumDays)
		return changedMinimumDays;
	updateCalendar(self);
	return [cal minimumDaysInFirstWeek];
}

- (NSRange)minimumRangeOfUnit:(NSCalendarUnit)calUnit
{
	updateCalendar(self);
	return [cal minimumRangeOfUnit:calUnit];
}

- (unsigned long)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
{
	updateCalendar(self);
	return [cal ordinalityOfUnit:smaller inUnit:larger forDate:date];
}

- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
{
	updateCalendar(self);
	return [cal rangeOfUnit:smaller inUnit:larger forDate:date];
}

- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller startDate:(NSDate *)start interval:(NSTimeInterval)interval forDate:(NSDate *)date
{
	updateCalendar(self);
	return [cal rangeOfUnit:smaller startDate:start interval:interval forDate:date];
}

- (NSTimeZone *)timeZone
{
	updateCalendar(self);
	return [cal timeZone];
}


- (NSDateComponents *)components:(unsigned long)unitFlags fromDate:(NSDate *)date
{
	updateCalendar(self);
	return [cal components:unitFlags fromDate:date];
}

- (NSDateComponents *)components:(unsigned long)unitFlags fromDate:(NSDate *)date toDate:(NSDate *)toDate options:(unsigned long)opts
{
	updateCalendar(self);
	return [cal components:unitFlags fromDate:date toDate:toDate options:opts];
}

- (NSDate *)dateByAddingComponents:(NSDateComponents *)components toDate:(NSDate *)startDate options:(unsigned long)opts
{
	updateCalendar(self);
	return [cal dateByAddingComponents:components toDate:startDate options:opts];
}

- (NSDate *)dateFromComponents:(NSDateComponents *)components
{
	updateCalendar(self);
	return [cal dateFromComponents:components];
}

@end
