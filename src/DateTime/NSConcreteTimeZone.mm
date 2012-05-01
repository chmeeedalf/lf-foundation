/*
 * Copyright (c) 2006-2012	Justin Hibbits
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

#import <Foundation/NSDate.h>
#import <Foundation/NSString.h>
#import "String/NSCoreString.h"
#import "NSConcreteDate.h"
#import "NSConcreteTimeZone.h"
#include <stdlib.h>
#include <unicode/tztrans.h>
#include <unicode/simpletz.h>
#include <unicode/ucal.h>
#include <unicode/udat.h>
#include <cstdio>

@implementation NSConcreteTimeZone

- (id) initWithName:(NSString *)name
{
	NSUInteger tzLen = [name length];
	NSUniChar ch[tzLen];
	
	if (name == nil)
	{
		return (id)[NSTimeZone defaultTimeZone];
	}

	[name getCharacters:ch range:NSMakeRange(0, tzLen)];

	tz = icu::TimeZone::createTimeZone(ch);
	timeZoneName = name;

	return self;
}

- (NSString *)name
{
	return timeZoneName;
}

-(bool)isDaylightSavingTimeForDate:(NSDate *)aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceReferenceDate];
	UErrorCode ec = U_ZERO_ERROR;
	UDate d = ICU_MSEC(ti);
	return tz->inDaylightTime(d, ec);
}

-(int)secondsSinceGMTForDate:(NSDate *)aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceReferenceDate];
	UErrorCode ec = U_ZERO_ERROR;
	UDate d = ICU_MSEC(ti);
	int32_t offset;
	int32_t dstOffset;
	tz->getOffset(d, true, offset, dstOffset, ec);
	return dstOffset + offset;
}

- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceReferenceDate];
	UErrorCode ec = U_ZERO_ERROR;
	UDate d = ICU_MSEC(ti);
	int32_t offset;
	int32_t dstOffset;
	tz->getOffset(d, true, offset, dstOffset, ec);
	return dstOffset;
}

- (NSDate *)nextDaylightSavingTransitionAfterDate:(NSDate *)aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceReferenceDate];
	UDate d = ICU_MSEC(ti);
	icu::TimeZoneTransition transition;

	((icu::SimpleTimeZone *)tz)->getNextTransition(d, true, transition);
	return [NSDate
		dateWithTimeIntervalSinceReferenceDate:UNIX_SEC(transition.getTime())];
}

-(NSString*)abbreviationForDate:(NSDate *)_date
{
	NSUInteger tzLen = [timeZoneName length];
	NSUniChar ch[tzLen];
	UDateFormat *dat;
	UErrorCode ec = U_ZERO_ERROR;
	NSUniChar pattern[] = {'V'};
	NSUniChar *output;
	NSUInteger len;
	NSString *ret = nil;

	[timeZoneName getCharacters:ch range:NSMakeRange(0, tzLen)];
	dat = udat_open(UDAT_IGNORE, UDAT_IGNORE, NULL, ch, tzLen,
			pattern, 1, &ec);

	len = udat_format(dat, ICU_MSEC([_date timeIntervalSinceReferenceDate]),
			NULL, 0, NULL, &ec);

	output = new NSUniChar[len];
	ec = U_ZERO_ERROR;
	udat_format(dat, ICU_MSEC([_date timeIntervalSinceReferenceDate]),
			output, len, NULL, &ec);
	udat_close(dat);

	if (!U_FAILURE(ec))
		ret = [NSString stringWithCharacters:output length:len];
	delete[] output;
	return ret;
}

+ (NSTimeZone *) defaultTimeZone
{
	NSConcreteTimeZone *tz;

	tz = [NSConcreteTimeZone new];
	icu::TimeZone *tzInt = icu::TimeZone::createDefault();
	icu::UnicodeString utzn;
	tz->tz = tzInt;
	tz->tz->getID(utzn);
	tz->timeZoneName = [[NSCoreString alloc] initWithUnicodeString:&utzn];

	return tz;
}
@end
