/*
 * Copyright (c) 2007-2012	Justin Hibbits
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

#include <stdlib.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSCalendar.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSKeyValueCoding.h>	// for -setValue:forKey:
#import <Foundation/NSNumberFormatter.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import "Collections/NSConcreteCharacterSet.h"

#import "NSConcreteLocale.h"
#import "String/NSCoreString.h"

#include <unicode/ulocdata.h>
#include <unicode/locid.h>
#include <unicode/uloc.h>
#include <unicode/dcfmtsym.h>

static NSConcreteLocale *fallbackLocale;
static NSMutableDictionary *localeCache;

@implementation NSConcreteLocale
{
	NSString *localeID;
	NSMutableDictionary *localeDict;
	icu::Locale *locale;
	ULocaleData *locData;
}

static void LocaleDataOpen(NSConcreteLocale *self)
{
	UErrorCode err = U_ZERO_ERROR;
	if (self->locData != NULL)
		return;
	self->locData = ulocdata_open([self->localeID
			cStringUsingEncoding:NSASCIIStringEncoding], &err);
}

static NSString *LocaleDataGetDelimiter(NSConcreteLocale *self, ULocaleDataDelimiterType type)
{
	int len;
	UErrorCode err = U_ZERO_ERROR;
	LocaleDataOpen(self);

	len = ulocdata_getDelimiter(self->locData, type, NULL, 0,
			&err);
	if (!U_SUCCESS(err))
		return nil;
	{
		UChar delim[len];
		len = ulocdata_getDelimiter(self->locData, type, NULL, 0, &err);
		return [NSString stringWithCharacters:delim length:len];
	}
}

+ (void) initialize
{
	localeCache = [NSMutableDictionary new];
}

+ (id) fallbackLocale
{
	@synchronized(self)
	{
		if (fallbackLocale != nil)
			return fallbackLocale;
		/* en_US_POSIX is a recognized locale for libICU, so we use that just to
		 * get the "POSIX"-ness from it. */
		fallbackLocale = [[NSConcreteLocale alloc]
			initWithLocaleIdentifier:@"en_US_POSIX"];
	}
	return fallbackLocale;
}

- (id) initWithLocaleIdentifier:(NSString *)localeIdent
{
	const char *locID = [localeIdent UTF8String];
	int32_t localeLen;
	char *localeName;
	UErrorCode ec = U_ZERO_ERROR;
	NSString *localeStr;

	localeLen = uloc_getName(locID, NULL, 0, &ec);

	if (U_FAILURE(ec))
	{
		return nil;
	}
	ec = U_ZERO_ERROR;
	localeName = new char[localeLen];
	uloc_getName(locID, localeName, localeLen, &ec);
	localeStr = [[NSString alloc] initWithBytes:localeName length:localeLen
		encoding:NSASCIIStringEncoding];
	delete[] localeName;
	if ([localeCache objectForKey:localeStr] != nil)
	{
		self = [localeCache objectForKey:localeStr];
	}
	else
	{
		localeID = localeStr;
		[localeCache setObject:self forKey:localeID];
		localeDict = [NSMutableDictionary new];
		locale = new icu::Locale(localeName);
	}
	return self;
}

- (void) dealloc
{
	if (locale)
		delete locale;
}

- (id) objectForKey:(NSString *)key
{
	id output = [localeDict objectForKey:key];

	if (output != nil)
		return output;

	/* If we're already the fallback locale, don't bother trying again. */
	if (self == fallbackLocale)
		return output;

	if ([key isEqualToString:NSLocaleIdentifier])
		return localeID;
	if ([key isEqualToString:NSLocaleLanguageCode])
	{
		output = [NSString stringWithCString:locale->getLanguage()
			encoding:NSASCIIStringEncoding];
	}
	if ([key isEqualToString:NSLocaleScriptCode])
	{
		output = [NSString stringWithCString:locale->getScript()
			encoding:NSASCIIStringEncoding];
	}
	if ([key isEqualToString:NSLocaleVariantCode])
	{
		output = [NSString stringWithCString:locale->getVariant()
			encoding:NSASCIIStringEncoding];
	}
	if ([key isEqualToString:NSLocaleExemplarCharacterSet])
	{
		_NSICUCharacterSet *set = [_NSICUCharacterSet new];

		if (set != nil)
		{
			LocaleDataOpen(self);
			if (locData != NULL)
			{
				UErrorCode ec = U_ZERO_ERROR;
				USet *locset = ulocdata_getExemplarSet(locData, NULL, 0,
						ULOCDATA_ES_STANDARD, &ec);
				[set _setICUCharacterSet:locset];
				uset_close(locset);
			}
			else
			{
				set = nil;
			}
		}
		output = set;
	}
	if ([key isEqualToString:NSLocaleCalendar])
	{
		char buffer[ULOC_KEYWORDS_CAPACITY + 1];
		UErrorCode ec = U_ZERO_ERROR;
		int len;
		NSString *calName = NSGregorianCalendar;

		len = locale->getKeywordValue("calendar", buffer, sizeof(buffer) - 1, ec);

		if (U_SUCCESS(ec) && (len > 0))
		{
			buffer[len] = 0;
			calName = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
		}

		output = [[NSCalendar alloc] initWithCalendarIdentifier:calName];
	}
	if ([key isEqualToString:NSLocaleUsesMetricSystem])
	{
		output = @([[self objectForKey:NSLocaleMeasurementSystem]
			isEqualToString:@"Metric"]);
	}
	if ([key isEqualToString:NSLocaleMeasurementSystem])
	{
		const char *locID = [localeID UTF8String];
		static NSString * const measures[] = {@"Metric", @"U.S."};
		UErrorCode err = U_ZERO_ERROR;

		UMeasurementSystem ms = ulocdata_getMeasurementSystem(locID, &err);
		if (U_SUCCESS(err))
		{
			output = measures[ms];
		}
	}
	if ([key isEqualToString:NSLocaleDecimalSeparator])
	{
		UErrorCode err = U_ZERO_ERROR;
		icu::DecimalFormatSymbols dfs(*locale, err);
		if (!U_SUCCESS(err))
			return nil;
		icu::UnicodeString us = dfs.getSymbol(icu::DecimalFormatSymbols::kDecimalSeparatorSymbol);
		output = [[NSCoreString alloc] initWithUnicodeString:&us];
	}
	if ([key isEqualToString:NSLocaleGroupingSeparator])
	{
		UErrorCode err = U_ZERO_ERROR;
		icu::DecimalFormatSymbols dfs(*locale, err);
		if (!U_SUCCESS(err))
			return nil;
		icu::UnicodeString us =
			dfs.getSymbol(icu::DecimalFormatSymbols::kGroupingSeparatorSymbol);
		output = [[NSCoreString alloc] initWithUnicodeString:&us];
	}
	if ([key isEqualToString:NSLocaleCurrencySymbol])
	{
		UErrorCode err = U_ZERO_ERROR;
		icu::DecimalFormatSymbols dfs(*locale, err);
		if (!U_SUCCESS(err))
			return nil;
		icu::UnicodeString us =
			dfs.getSymbol(icu::DecimalFormatSymbols::kCurrencySymbol);
		output = [[NSCoreString alloc] initWithUnicodeString:&us];
	}
	if ([key isEqualToString:NSLocaleCurrencyCode])
	{
		NSNumberFormatter *fm = [[NSNumberFormatter alloc] init];
		[fm setNumberStyle:NSNumberFormatterCurrencyStyle];
		[fm setLocale:self];
		
		output = [fm currencyCode];
	}
	if ([key isEqualToString:NSLocaleCollatorIdentifier])
	{
		// TODO: objectForKey: LocaleCollatorIdentifier
	}
	if ([key isEqualToString:NSLocaleQuotationBeginDelimiterKey])
	{
		output = LocaleDataGetDelimiter(self, ULOCDATA_QUOTATION_START);
	}
	if ([key isEqualToString:NSLocaleQuotationEndDelimiterKey])
	{
		output = LocaleDataGetDelimiter(self, ULOCDATA_QUOTATION_END);
	}
	if ([key isEqualToString:NSLocaleAlternateQuotationBeginDelimiterKey])
	{
		output = LocaleDataGetDelimiter(self, ULOCDATA_ALT_QUOTATION_START);
	}
	if ([key isEqualToString:NSLocaleAlternateQuotationEndDelimiterKey])
	{
		output = LocaleDataGetDelimiter(self, ULOCDATA_ALT_QUOTATION_END);
	}

	// use setValue:forKey: instead of setObject:forKey: because output may be
	// nil.
	[localeDict setValue:output forKey:key];

	return output;
}

- (NSString *) localeIdentifier
{
	return localeID;
}

- (NSString *) localeDisplayName
{
	icu::UnicodeString us;

	locale->getDisplayName(us);

	return [[NSCoreString alloc] initWithUnicodeString:&us];
}

@end
