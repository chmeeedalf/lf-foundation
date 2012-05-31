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

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSResourceManager.h>
#import <Foundation/NSSettingsManager.h>
#import <Foundation/NSString.h>

#import "NSConcreteLocale.h"
#import "internal.h"
#include <unicode/uloc.h>
#include <unicode/ucurr.h>
#include <stdlib.h>

// NSLocale strings
NSString * const NSLocaleDecimalDigits = @"NSLocaleDecimalDigits";
NSString * const NSLocaleThousandsSeparator = @"NSLocaleThousandsSeparator";
NSString * const NSLocaleIdentifier = @"NSLocaleIdentifier";
NSString * const NSLocaleLanguageCode = @"NSLocaleLanguageCode";
NSString * const NSLocaleCountryCode = @"NSLocaleCountryCode";
NSString * const NSLocaleScriptCode = @"NSLocaleScriptCode";
NSString * const NSLocaleVariantCode = @"NSLocaleVariantCode";
NSString * const NSLocaleExemplarCharacterSet = @"NSLocaleExemplarCharacterSet";
NSString * const NSLocaleCalendar = @"NSLocaleCalendar";
NSString * const NSLocaleCalendarIdentifier = @"NSLocaleCalendarIdentifier";
NSString * const NSLocaleCollationIdentifier = @"NSLocaleCollationIdentifier";
NSString * const NSLocaleUsesMetricSystem = @"NSLocaleUsesMetricSystem";
NSString * const NSLocaleMeasurementSystem = @"NSLocaleMeasurementSystem";
NSString * const NSLocaleDecimalSeparator = @"NSLocaleDecimalSeparator";
NSString * const NSLocaleGroupingSeparator = @"NSLocaleGroupingSeparator";
NSString * const NSLocaleCurrencySymbol = @"NSLocaleCurrencySymbol";
NSString * const NSLocaleCurrencyCode = @"NSLocaleCurrencyCode";
NSString * const NSLocaleCollatorIdentifier = @"NSLocaleCollatorIdentifier";
NSString * const NSLocaleQuotationBeginDelimiterKey = @"NSLocaleQuotationBeginDelimiterKey";
NSString * const NSLocaleQuotationEndDelimiterKey = @"NSLocaleQuotationEndDelimiterKey";
NSString * const NSLocaleAlternateQuotationBeginDelimiterKey = @"NSLocaleAlternateQuotationBeginDelimiterKey";
NSString * const NSLocaleAlternateQuotationEndDelimiterKey = @"NSLocaleAlternateQuotationEndDelimiterKey";
NSString * const NSLocaleTimeDateFormatString = @"NSLocaleTimeDateFormatString";

NSMakeSymbol(NSGregorianCalendar);
NSMakeSymbol(NSBuddhistCalendar);
NSMakeSymbol(NSChineseCalendar);
NSMakeSymbol(NSHebrewCalendar);
NSMakeSymbol(NSIslamicCalendar);
NSMakeSymbol(NSIslamicCivilCalendar);
NSMakeSymbol(NSJapaneseCalendar);
NSMakeSymbol(NSRepublicOfChinaCalendar);
NSMakeSymbol(NSPersianCalendar);
NSMakeSymbol(NSIndianCalendar);
NSMakeSymbol(NSISO8601Calendar);

@interface NSAutoLocale		:	NSLocale
{
}
@end


static NSLocale *systemLocale = nil;
static NSLocale *currentLocale = nil;

@implementation NSLocale

+ (void) initialize
{
	[self systemLocale];
	[self setCurrentLocale:[self systemLocale]];
}

+ (id) autoupdatingCurrentLocale
{
	static NSLocale *autoupdatingLocale = nil;

	if (autoupdatingLocale == nil)
	{
		@synchronized(self)
		{
			if (autoupdatingLocale == nil)
			{
				autoupdatingLocale = [[NSAutoLocale alloc] init];
			}
		}
	}
	return autoupdatingLocale;
}

+ (id) systemLocale
{
	@synchronized(self)
	{
		if (systemLocale == nil)
		{
			systemLocale = [[self alloc] initWithLocaleIdentifier:[[NSSettingsManager
				defaultSettingsManager] objectForKey:@"SystemLocale"]];
			if (systemLocale == nil)
				systemLocale = [NSConcreteLocale fallbackLocale];
		}
	}
	return systemLocale;
}

+ (id) currentLocale
{
	if (currentLocale == nil)
	{
		[self setCurrentLocale:[self systemLocale]];
	}
	return currentLocale;
}

+ (void)setCurrentLocale:(NSLocale *)locale
{
	UErrorCode ec = U_ZERO_ERROR;
	uloc_setDefault([[locale localeIdentifier] UTF8String], &ec);
	if (!U_FAILURE(ec))
		currentLocale = locale;
}

+ (NSArray *) preferredLanguages
{
	TODO; // +[NSLocale preferredLanguages]
	return nil;
}

+ (NSLocaleLanguageDirection) characterDirectionForLanguage:(NSString *)lang
{
	const char *locID = [lang UTF8String];
	UErrorCode err = U_ZERO_ERROR;
	ULayoutType dir = uloc_getCharacterOrientation(locID, &err);

	switch (dir)
	{
		case ULOC_LAYOUT_LTR:
			return NSLocaleLanguageDirectionLeftToRight;
		case ULOC_LAYOUT_RTL:
			return NSLocaleLanguageDirectionRightToLeft;
		case ULOC_LAYOUT_TTB:
			return NSLocaleLanguageDirectionTopToBottom;
		case ULOC_LAYOUT_BTT:
			return NSLocaleLanguageDirectionBottomToTop;
		default:
			return NSLocaleLanguageDirectionUnknown;
	}
}

+ (NSLocaleLanguageDirection) lineDirectionForLanguage:(NSString *)lang
{
	const char *locID = [lang UTF8String];
	UErrorCode err = U_ZERO_ERROR;
	ULayoutType dir = uloc_getLineOrientation(locID, &err);

	switch (dir)
	{
		case ULOC_LAYOUT_LTR:
			return NSLocaleLanguageDirectionLeftToRight;
		case ULOC_LAYOUT_RTL:
			return NSLocaleLanguageDirectionRightToLeft;
		case ULOC_LAYOUT_TTB:
			return NSLocaleLanguageDirectionTopToBottom;
		case ULOC_LAYOUT_BTT:
			return NSLocaleLanguageDirectionBottomToTop;
		default:
			return NSLocaleLanguageDirectionUnknown;
	}
}

+ (NSString *) canonicalLanguageIdentifierFromString:(NSString *)str
{
	TODO; // +[NSLocale canonicalLanguageIdentifierFromString:]
	return nil;
}

+ (NSString *) canonicalLocaleIdentifierFromString:(NSString *)ident
{
	char *outName;
	int32_t len;
	UErrorCode ec = U_ZERO_ERROR;
	const char *srcLocale = [ident UTF8String];

	len = uloc_canonicalize(srcLocale, NULL, 0, &ec);

	if (U_FAILURE(ec))
		return nil;

	outName = malloc(len);
	uloc_canonicalize(srcLocale, outName, len, &ec);

	return [[NSString alloc] initWithBytesNoCopy:outName length:len
		encoding:NSASCIIStringEncoding freeWhenDone:true];
}

- (id) initWithLocaleIdentifier:(NSString *)localeName
{
	return self;
}

- (id) objectForKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (NSString *)localeIdentifier
{
	return [self objectForKey:NSLocaleIdentifier];
}

- (NSString *)localeDisplayName
{
	[self subclassResponsibility:_cmd];
	return nil;
}

+ (NSArray *)commonISOCurrencyCodes
{
	UErrorCode err = U_ZERO_ERROR;
	UEnumeration *e;
	static NSMutableArray *retCodes = nil;

	if (retCodes != nil)
		return retCodes;

	e = ucurr_openISOCurrencies(UCURR_COMMON, &err);
	if (!U_SUCCESS(err))
		return nil;
	retCodes = [NSMutableArray new];
	int len = 0;
	for (const char *i = uenum_next(e, &len, &err); i != NULL && U_SUCCESS(err); i = uenum_next(e, &len, &err))
	{
		[retCodes addObject:[NSString stringWithCString:i encoding:NSASCIIStringEncoding]];
	}
	return retCodes;
}

+ (NSArray *)ISOLanguageCodes
{
	const char *const *langs = uloc_getISOLanguages();
	const char * const *langEnum = langs;
	static NSMutableArray *retCodes = nil;

	if (retCodes != nil)
		return retCodes;

	retCodes = [NSMutableArray new];

	for (; *langEnum != NULL; langEnum++)
	{
		[retCodes addObject:[NSString stringWithCString:*langEnum encoding:NSASCIIStringEncoding]];
	}
	return retCodes;
}

+ (NSArray *)ISOCurrencyCodes
{
	UErrorCode err = U_ZERO_ERROR;
	UEnumeration *e;
	static NSMutableArray *retCodes = nil;

	if (retCodes != nil)
		return retCodes;

	e = ucurr_openISOCurrencies(UCURR_ALL, &err);
	if (!U_SUCCESS(err))
		return nil;
	retCodes = [NSMutableArray new];
	int len = 0;
	for (const char *i = uenum_next(e, &len, &err); i != NULL && U_SUCCESS(err); i = uenum_next(e, &len, &err))
	{
		[retCodes addObject:[NSString stringWithCString:i encoding:NSASCIIStringEncoding]];
	}
	return retCodes;
}

+ (NSArray *)ISOCountryCodes
{
	const char *const *countries = uloc_getISOCountries();
	const char * const *countryEnum = countries;
	static NSMutableArray *retCodes;
	
	if (retCodes != nil)
		return retCodes;

	retCodes = [NSMutableArray new];

	for (; *countryEnum != NULL; countryEnum++)
	{
		[retCodes addObject:[NSString stringWithCString:*countryEnum encoding:NSASCIIStringEncoding]];
	}
	return retCodes;
}

+ (NSArray *)availableLocaleIdentifiers
{
	static NSMutableArray *retIdents = nil;

	if (retIdents != nil)
		return retIdents;

	retIdents = [NSMutableArray new];
	int localeCount = uloc_countAvailable();

	for (int i = 0; i < localeCount; i++)
	{
		NSString *s = [[NSString alloc] initWithCString:uloc_getAvailable(i) encoding:NSASCIIStringEncoding];
		[retIdents addObject:s];
	}

	return retIdents;
}

+ (NSString *)localeIdentifierFromComponents:(NSDictionary *)components
{
	NSString *lang = [components objectForKey:NSLocaleLanguageCode];
	NSString *country = [components objectForKey:NSLocaleCountryCode];
	NSString *variant = [components objectForKey:NSLocaleVariantCode];
	NSString *script = [components objectForKey:NSLocaleScriptCode];
	NSMutableString *str = [NSMutableString new];

	if (lang != nil)
		[str appendString:lang];
	if (script != nil)
	{
		[str appendString:@"_"];
		[str appendString:script];
	}
	if (country != nil)
	{
		[str appendString:@"_"];
		[str appendString:country];
	}
	if (variant != nil)
	{
		[str appendString:@"_"];
		[str appendString:variant];
	}
	return str;
}

+ (NSDictionary *)componentsFromLocaleIdentifier:(NSString *)identifier
{
	const char *locID = [identifier cStringUsingEncoding:NSUTF8StringEncoding];
	char buf[ULOC_FULLNAME_CAPACITY+ULOC_KEYWORD_AND_VALUES_CAPACITY];
	UErrorCode ec = U_ZERO_ERROR;
	size_t len;
	NSMutableDictionary *components = [NSMutableDictionary new];

	len = uloc_getLanguage(locID, buf, sizeof(buf), &ec);
	if (U_SUCCESS(ec) && len > 0)
	{
		NSString *s = [[NSString alloc] initWithCString:buf encoding:NSUTF8StringEncoding];
		[components setObject:s forKey:NSLocaleLanguageCode];
	}
	ec = U_ZERO_ERROR;
	len = uloc_getScript(locID, buf, sizeof(buf), &ec);
	if (U_SUCCESS(ec) && len > 0)
	{
		NSString *s = [[NSString alloc] initWithCString:buf encoding:NSUTF8StringEncoding];
		[components setObject:s forKey:NSLocaleScriptCode];
	}
	ec = U_ZERO_ERROR;
	len = uloc_getCountry(locID, buf, sizeof(buf), &ec);
	if (U_SUCCESS(ec) && len > 0)
	{
		NSString *s = [[NSString alloc] initWithCString:buf encoding:NSUTF8StringEncoding];
		[components setObject:s forKey:NSLocaleCountryCode];
	}
	ec = U_ZERO_ERROR;
	len = uloc_getVariant(locID, buf, sizeof(buf), &ec);
	if (U_SUCCESS(ec) && len > 0)
	{
		NSString *s = [[NSString alloc] initWithCString:buf encoding:NSUTF8StringEncoding];
		[components setObject:s forKey:NSLocaleVariantCode];
	}

	UEnumeration *locEnum = uloc_openKeywords(locID, &ec);
	const char *locKey = NULL;
	
	while ((locKey = uenum_next(locEnum, NULL, &ec)) && U_SUCCESS(ec))
	{
		char valBuf[ULOC_KEYWORD_AND_VALUES_CAPACITY];
		if (uloc_getKeywordValue(locID, locKey, valBuf, sizeof(buf), &ec) > 0 && U_SUCCESS(ec))
		{
			NSString *key = [[NSString alloc] initWithCString:locKey encoding:NSASCIIStringEncoding];
			NSString *value = [[NSString alloc] initWithCString:valBuf encoding:NSASCIIStringEncoding];
			[components setObject:value forKey:key];
		}
	}
	return components;
}

- (NSString *)displayNameForKey:(id)key value:(id)value
{
	UChar dest[ULOC_FULLNAME_CAPACITY];
	int32_t len = 0;
	const char *locale = [[self localeIdentifier] UTF8String];
	UErrorCode ec = U_ZERO_ERROR;
	if ([key isEqualToString:NSLocaleIdentifier])
	{
		len = uloc_getDisplayName([value UTF8String], locale, dest, sizeof(dest), &ec);
	}
	else if ([key isEqualToString:NSLocaleLanguageCode])
	{
		len = uloc_getDisplayLanguage([value UTF8String], locale, dest, sizeof(dest), &ec);
	}
	else if ([key isEqualToString:NSLocaleCountryCode])
	{
		len = uloc_getDisplayCountry([value UTF8String], locale, dest, sizeof(dest), &ec);
	}
	else if ([key isEqualToString:NSLocaleScriptCode])
	{
		len = uloc_getDisplayScript([value UTF8String], locale, dest, sizeof(dest), &ec);
	}
	else if ([key isEqualToString:NSLocaleVariantCode])
	{
		len = uloc_getDisplayVariant([value UTF8String], locale, dest, sizeof(dest), &ec);
	}
	else if ([key isEqualToString:NSLocaleCalendarIdentifier])
	{
		len = uloc_getDisplayKeywordValue([value UTF8String], "calendar", locale, dest, sizeof(dest), &ec);
	}
	else if ([key isEqualToString:NSLocaleCollationIdentifier])
	{
		len = uloc_getDisplayKeywordValue([value UTF8String], "collation", locale, dest, sizeof(dest), &ec);
	}
	
	if (U_SUCCESS(ec) && len > 0)
	{
		return [NSString stringWithCharacters:dest length:len];
	}
	return nil;
}
@end

@implementation NSAutoLocale

- (NSString *) displayNameForKey:(id)key value:(id)value
{
	return [[NSLocale currentLocale] displayNameForKey:key value:value];
}

- (NSString *) localeIdentifier
{
	return [[NSLocale currentLocale] localeIdentifier];
}

- (id) objectForKey:(NSString *)key
{
	return [[NSLocale currentLocale] objectForKey:key];
}

@end
