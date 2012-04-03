/*
 * Copyright (c) 2004-2012	Justin Hibbits
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

/*
   NSDate.m

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

   This file is part of libFoundation.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.
 */

#include <SysCall.h>
#include <stdlib.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSException.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSString.h>
#import <Foundation/NSTimeZone.h>

#import "NSConcreteDate.h"
#define NSLocale ICULocale
#define NSTimeZone ICUTimeZone
#include "unicode/udat.h"
#include "unicode/ucal.h"
#undef NSLocale
#undef NSTimeZone

//static NSString *DEFAULT_FORMAT = @"Y-MM-dd HH:mm:ss z";
static UChar DEFAULT_FORMAT[] = {'Y','-','M','M','-','d','d',' ','H','H',':','m','m',':','s','s',' ','z', 0};
@implementation NSDate

static NSDate *distantFuture = nil;
static NSDate *distantPast = nil;

+ (id) allocWithZone:(NSZone*)zone
{
	return NSAllocateObject( (self == [NSDate class]) ?
			[NSConcreteDate class] : (Class)self, 0, zone);
}

+ (NSDate*)date
{
	return [[self alloc] init];
}

+ (NSDate*)dateWithTimeIntervalSinceNow:(NSTimeInterval)secs
{
	return [[self alloc] initWithTimeIntervalSinceNow:secs];
}

+ (NSDate*)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)secs
{
	return [[self alloc] initWithTimeIntervalSinceReferenceDate:secs];
}

+ (NSDate*)dateWithTimeIntervalSince1970:(NSTimeInterval)seconds
{
	return [[self alloc] initWithTimeIntervalSince1970:seconds];
}

+ (NSDate *) dateWithTimeInterval:(NSTimeInterval)seconds sinceDate:(NSDate *)date
{
	return [[self alloc] initWithTimeInterval:seconds sinceDate:date];
}

+ (NSDate *)dateWithString:(NSString *)str
{
	return [[self alloc] initWithString:str];
}

+ (NSDate*)distantFuture
{
	if (!distantFuture)
	{
		distantFuture = [[self alloc]
			initWithTimeIntervalSinceReferenceDate:DISTANT_FUTURE];
	}

	return distantFuture;
}

+ (NSDate*)distantPast
{
	if (!distantPast)
	{
		distantPast =[[self alloc]
			initWithTimeIntervalSinceReferenceDate:DISTANT_PAST];
	}

	return distantPast;
}

- (id) init
{
	return [super init];
}

- (id) initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)secsToBeAdded
{
	[self subclassResponsibility:_cmd];
	return self;
}

- (id)initWithString:(NSString*)description
{
	UChar *descChars = NULL;
	UDateFormat *dfmt;
	UErrorCode ec = U_ZERO_ERROR;
	dfmt = udat_open(UDAT_IGNORE, UDAT_IGNORE, NULL, NULL, -1, DEFAULT_FORMAT, -1, &ec);
	if (U_FAILURE(ec))
		goto error;
	NSIndex descLen = [description length] + 1;
	UDate parsedDate;
	descChars = (UChar *)malloc(descLen * sizeof(NSUniChar));
	[description getCharacters:descChars range:NSMakeRange(0, descLen - 1)];
	descChars[descLen - 1] = 0;
	parsedDate = udat_parse(dfmt, descChars, -1, NULL, &ec);
	free(descChars);

	if (U_FAILURE(ec))
	{
		goto error;
	}

	self = [self initWithTimeIntervalSinceReferenceDate:UNIX_SEC(parsedDate)];
	return self;

error:
	return nil;
}

- (NSDate*)initWithTimeInterval:(NSTimeInterval)secsToBeAdded
sinceDate:(NSDate*)anotherDate
{
	return [self initWithTimeIntervalSinceReferenceDate:
		(secsToBeAdded + [anotherDate timeIntervalSinceReferenceDate])];
}

- (NSDate*)initWithTimeIntervalSinceNow:(NSTimeInterval)secsToBeAddedToNow
{
	return [self initWithTimeIntervalSinceReferenceDate:
		(secsToBeAddedToNow + [NSDate timeIntervalSinceReferenceDate])];
}

- (NSDate *)initWithTimeIntervalSince1970:(NSTimeInterval)seconds
{
	return [self initWithTimeIntervalSinceReferenceDate: seconds + UNIX_OFFSET];
}

/* Copying */

- (id)copyWithZone:(NSZone*)zone
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (NSDate *) dateByAddingTimeInterval:(NSTimeInterval)seconds
{
	return [[[self class] alloc] initWithTimeInterval:seconds sinceDate:self];
}

/* Representing Dates */

- (NSString*)description
{
	return [self descriptionWithCalendarFormat:nil timeZone:[NSTimeZone defaultTimeZone] locale:nil];
}

- (NSString *)descriptionWithCalendarFormat:(NSString *)formatString
	locale:(NSLocale *)locale
{
	return [self descriptionWithCalendarFormat:formatString
		timeZone:nil locale:locale];
}

- (NSString*)descriptionWithCalendarFormat:(NSString*)format
	timeZone:(NSTimeZone*)timeZone
	locale:(NSLocale*)locale
{
	NSString *result;
	NSIndex len = [format length] + 1;
	NSIndex outLen;
	UDate icuDate;
	NSUniChar *formatChars;
	if (format == nil)
		formatChars = DEFAULT_FORMAT;
	else
	{
		formatChars = malloc(len * sizeof(NSUniChar));
		[format getCharacters:formatChars range:NSMakeRange(0, len - 1)];
		formatChars[len - 1] = 0;
	}

	NSUniChar *output;
	UDateFormat *dfmt;
	UErrorCode ec = U_ZERO_ERROR;

	if (timeZone == nil)
		timeZone = [NSTimeZone defaultTimeZone];
	NSString *tzAbbrev = [timeZone abbreviation];
	size_t tzLen = [tzAbbrev length];
	NSUniChar tz[tzLen > 0 ? (tzLen + 1) : 1];
	[tzAbbrev getCharacters:tz range:(NSRange){0, tzLen}];
	tz[tzLen] = 0;

	dfmt = udat_open(UDAT_IGNORE, UDAT_IGNORE,
			[[locale localeIdentifier] UTF8String], (tzLen > 0 ? tz : NULL), tzLen,
			formatChars, len, &ec);
	icuDate = ICU_MSEC([self timeIntervalSinceReferenceDate]);
	outLen = udat_format(dfmt, icuDate, NULL, 0, NULL, &ec);
	
	/* We expect U_BUFFER_OVERFLOW_ERROR because we're trying to find the
	 * length. */
	if (ec != 0 && ec != U_BUFFER_OVERFLOW_ERROR)
		return nil;
	ec = U_ZERO_ERROR;
	output = malloc(outLen * sizeof(NSUniChar));

	outLen = udat_format(dfmt, icuDate, output, outLen, NULL, &ec);

	result = [NSString stringWithCharacters:output length:outLen-1];
	free(output);
	return result;
}

- (NSString*)descriptionWithLocale:(NSLocale*)locale
{
	return [self descriptionWithCalendarFormat:nil
		timeZone:nil locale:locale];
}

/* Adding and Getting Intervals */

+ (NSTimeInterval)timeIntervalSinceReferenceDate
{
	return SystemTime();
}

- (NSTimeInterval)timeIntervalSinceReferenceDate
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (NSTimeInterval)timeIntervalSinceDate:(NSDate*)anotherDate
{
	return [self timeIntervalSinceReferenceDate] -
		[anotherDate timeIntervalSinceReferenceDate];
}

- (NSTimeInterval)timeIntervalSinceNow
{
	return [self timeIntervalSinceReferenceDate] -
		[NSDate timeIntervalSinceReferenceDate];
}

- (NSTimeInterval)timeIntervalSince1970
{
	return [self timeIntervalSinceReferenceDate] - UNIX_OFFSET;
}

/* Comparing Dates */

- (NSDate*)earlierDate:(NSDate*)anotherDate
{
	if (!anotherDate) return self;

	return [self compare:anotherDate] == NSOrderedAscending?
		self : anotherDate;
}

- (NSDate*)laterDate:(NSDate*)anotherDate
{
	if (!anotherDate)
	{
		return self;
	}

	return [self compare:anotherDate] == NSOrderedAscending ?
		anotherDate : self;
}


- (NSComparisonResult)compare:(NSDate*)otherDate
{
	/* Any date is greater than nil. */
	if (otherDate == nil)
		return NSOrderedDescending;

	NSAssert([otherDate isKindOfClass:[NSDate class]],
			@"Cannot compare NSDate with %@", [otherDate class]);

	NSTimeInterval other = [otherDate timeIntervalSinceDate:self];
	return (other > 0)?NSOrderedAscending : (other < 0)?NSOrderedDescending : NSOrderedSame;
}

- (bool)isEqual:other
{
	return [other isKindOfClass:[NSDate class]] &&
		[self isEqualToDate:other];
}

- (bool)isEqualToDate:other
{
	return [self compare:other] == NSOrderedSame;
}

/* Encoding */
- (Class)classForCoder
{
	return [NSDate class];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	NSTimeInterval ti = [self timeIntervalSinceReferenceDate];
	if ([coder allowsKeyedCoding])
	{
		[coder encodeDouble:ti forKey:@"G.time"];
	}
	else
	{
		[coder encodeValueOfObjCType:@encode(NSTimeInterval) at:&ti];
	}
}

- (id) initWithCoder:(NSCoder *)coder
{
	NSTimeInterval ti;

	if ([coder allowsKeyedCoding])
	{
		ti = [coder decodeDoubleForKey:@"G.time"];
	}
	else
	{
		[coder decodeValueOfObjCType:@encode(NSTimeInterval) at:&ti];
	}

	if (ti == DISTANT_PAST)
	{
		return [NSDate distantPast];
	}
	else if (ti == DISTANT_FUTURE)
	{
		return [NSDate distantFuture];
	}
	return [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:ti];
}

@end

/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
 */

