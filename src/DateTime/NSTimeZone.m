/*
 * Copyright (c) 2006-2012	Gold Project
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
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR COEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSArray.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSResourceManager.h>
#import <Foundation/NSSettingsManager.h>
#import <Foundation/NSString.h>
#import <Foundation/NSTimeZone.h>
#import <Foundation/NSValue.h>
#include <stdlib.h>
#include <unicode/ucal.h>

#import "NSConcreteTimeZone.h"

NSTimeZone *DefaultTimeZone(void)
{
	return [NSTimeZone defaultTimeZone];
}

@implementation NSTimeZone

static NSTimeZone *defaultTimeZone = nil;
static NSTimeZone *systemTimeZone = nil;

// Creating and initializing an NSTimeZone
+(NSTimeZone *)defaultTimeZone
{
	@synchronized(self)
	{
		if (defaultTimeZone == nil)
		{
			defaultTimeZone = [self systemTimeZone];
		}
	}
	return defaultTimeZone;
}

+(NSTimeZone *)systemTimeZone
{
	@synchronized(self)
	{
		if (systemTimeZone == nil)
		{
			systemTimeZone = [NSConcreteTimeZone defaultTimeZone];
		}
	}
	return systemTimeZone;
}

+ (void) resetSystemTimeZone
{
	@synchronized(self)
	{
		systemTimeZone = nil;
	}
}

+(NSTimeZone *)timeZoneForSecondsFromGMT:(int)seconds
{
	/* Like GNUStep, disallow timezones larger than 18 hours from GMT */
	if ((abs(seconds) / 60) > 18)
		return nil;
	NSString *str = [[NSString alloc] initWithFormat:@"GMT%+.3d",(seconds/3600)];
	NSTimeZone *tz = [NSConcreteTimeZone timeZoneWithName:str];
	return tz;
}

+(NSTimeZone *)timeZoneWithAbbreviation:(NSString *)abbreviation
{
	return [[NSConcreteTimeZone alloc] initWithName:abbreviation];
}

+(NSTimeZone *)timeZoneWithName:(NSString *)aTimeZoneName
{
	return [[NSConcreteTimeZone alloc] initWithName:aTimeZoneName];
}

// Managing time zones
+(void)setDefaultTimeZone:(NSTimeZone *)aTimeZone
{
	NSString *tzName = [aTimeZone name];
	NSIndex len = [tzName length];
	NSUniChar ch[len + 1];
	UErrorCode ec = U_ZERO_ERROR;
	[tzName getCharacters:ch range:NSMakeRange(0, len)];
	ch[len] = 0;

	ucal_setDefaultTimeZone(ch, &ec);

	if (!U_SUCCESS(ec))
		return;
	@synchronized(self)
	{
		defaultTimeZone = aTimeZone;
	}
}

/* TODO: Think about the next two methods.  They're not required right now, so
 * they're ignored.
 */
+(NSDictionary *)abbreviationDictionary
{
	return nil;
}

+ (void) setAbbreviationDictionary:(NSDictionary *)newAbbrevs
{
}

// Getting time zone information
- (id) initWithName:(NSString *)name
{
	[self subclassResponsibility:_cmd];
	return nil;
}

-(NSString *)name
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (NSString *)localizedName:(NSTimeZoneNameStyle)style locale:(NSLocale *)locale
{
	UErrorCode ec = U_ZERO_ERROR;
	NSString *zoneName = [self name];
	size_t len = [zoneName length];
	NSString *localizedName = nil;
	UChar buf[len];
	[zoneName getCharacters:buf range:NSMakeRange(0, len)];
	UCalendar *cal = ucal_open(buf, len, [[locale localeIdentifier] cStringUsingEncoding:NSUTF8StringEncoding], UCAL_TRADITIONAL, &ec);

	size_t outLen = ucal_getTimeZoneDisplayName(cal, (UCalendarDisplayNameType)style, [[locale localeIdentifier] cStringUsingEncoding:NSUTF8StringEncoding], NULL, 0, &ec);
	if (U_SUCCESS(ec))
	{
		UChar buf[outLen + 1];
		ucal_getTimeZoneDisplayName(cal, (UCalendarDisplayNameType)style, [[locale localeIdentifier] cStringUsingEncoding:NSUTF8StringEncoding], buf, outLen, &ec);
		buf[outLen] = 0;
		localizedName = [NSString stringWithCharacters:buf length:outLen];
	}
	ucal_close(cal);
	return localizedName;
}

// New methods from MacOSX, which are deemed useful
-(NSString *)abbreviation
{
	NSDate *d = [NSDate new];
	NSString *abbrev = [self abbreviationForDate:d];
	return abbrev;
}

-(NSString*)abbreviationForDate:(NSDate *)_date
{
	[self subclassResponsibility:_cmd];
	return nil;
}

-(bool)isDaylightSavingTime
{
	NSDate *d = [NSDate new];
	bool isDST = [self isDaylightSavingTimeForDate:d];
	return isDST;
}

-(bool)isDaylightSavingTimeForDate:(NSDate *)aDate
{
	[self subclassResponsibility:_cmd];
	return false;
}

-(int)secondsFromGMT
{
	NSDate *d = [NSDate new];
	int s = [self secondsFromGMTForDate:d];
	return s;
}

-(int)secondsFromGMTForDate:(NSDate *)_date
{
	[self subclassResponsibility:_cmd];
	return 0;
}

-(NSDate *)nextDaylightSavingTimeTransition
{
	NSDate *d = [NSDate new];
	NSDate *nextDST = [self nextDaylightSavingTimeTransitionAfterDate:d];
	return nextDST;
}

-(NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate
{
	return [self subclassResponsibility:_cmd];
}

/* This is read-only so it doesn't matter what zone we're in. */
- copyWithZone:(NSZone *)zone
{
	return self;
}

- (NSTimeInterval)daylightSavingTimeOffset
{
	NSDate *d = [NSDate new];
	NSTimeInterval s = [self daylightSavingTimeOffsetForDate:d];
	return s;
}

- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)date
{
	return 0;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<NSTimeZone %p>{ name = %@, abbreviation = %@, offset = %g, DST = %s",self, [self name], [self abbreviation], [self secondsFromGMT], ([self isDaylightSavingTime]?"true":"false")];
}

- (bool) isEqualToTimeZone:(NSTimeZone *)other
{
	/* Short circuit the other checks. */
	if (self == other)
		return true;

	if (![[self name] isEqualToString:[other name]])
		return false;
	if ([self secondsFromGMT] != [other secondsFromGMT])
		return false;

	/* If both have the same name and same offset, assume they're the same. */
	return true;
}

+ (NSString *)timeZoneDataVersion
{
	static NSString *tzDataVer = nil;
	UErrorCode ec = U_ZERO_ERROR;
	const char *tzVer;

	if (tzDataVer != nil)
		return tzDataVer;
	@synchronized(self)
	{
		if (tzDataVer != nil)
			return tzDataVer;
		tzVer = ucal_getTZDataVersion(&ec);
		if (!U_SUCCESS(ec))
			return nil;

		tzDataVer = [[NSString alloc] initWithCString:tzVer encoding:NSASCIIStringEncoding];
	}
	return tzDataVer;
}

+ (NSArray *)knownTimeZoneNames
{
	UErrorCode ec = U_ZERO_ERROR;
	static NSArray *zones = nil;

	if (zones != nil)
		return zones;

	@synchronized(self)
	{
		if (zones != nil)
			return zones;
		UEnumeration *zoneEnum = ucal_openTimeZones(&ec);
		NSMutableArray *a = [NSMutableArray new];
		for (const char *name = uenum_next(zoneEnum, NULL, &ec); name != NULL; name = uenum_next(zoneEnum, NULL, &ec))
		{
			[a addObject:[NSString stringWithCString:name encoding:NSASCIIStringEncoding]];
		}
		zones = [[NSArray alloc] initWithArray:a];
	}
	return zones;
}
@end
