/*
 * Copyright (c) 2007	Gold Project
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

/*
   \file NSLocale.h
   \brief Contains the NSLocale class and associated constants for accessing locale information.
 */

#import <Foundation/NSObject.h>

@class NSArray;
@class NSDictionary;
@class NSString;

enum {
	NSLocaleLanguageDirectionUnknown = 0,
	NSLocaleLanguageDirectionLeftToRight,
	NSLocaleLanguageDirectionRightToLeft,
	NSLocaleLanguageDirectionTopToBottom,
	NSLocaleLanguageDirectionBottomToTop,
};
typedef NSUInteger NSLocaleLanguageDirection;

/*!
 * \brief Localization information class.
 */
@interface NSLocale	:	NSObject

+ autoupdatingCurrentLocale;

/*!
 * \brief Returns the systemwide NSLocale instance.
 */
+ systemLocale;

/*!
 * \brief Returns the current process NSLocale instance.
 */
+ currentLocale;

/*!
 * \brief Sets the current process NSLocale.
 */
+ (void)setCurrentLocale:(NSLocale *)locale;

/*!
 * \brief Returns a locale with the given name.
 */
+ localeWithIdentifier:(NSString *)localeName;

- initWithIdentifier:(NSString *)localeName;

// Identifier -- NSLocale pairs
/*!
 * \brief Returns the list of locales available on the system, identified by
 * name.
 */
+ (NSArray *) availableLocaleIdentifiers;

/*!
 * \brief Return the locale's "real" name
 * */
- (NSString *)localeIdentifier;

/*!
 * \brief Returns locale's "ISO" display name -- en_US, ...
 * */
- (NSString *)localeDisplayName;

/*!
 * \brief Returns the locale information for a given key.
 */
- objectForKey:(NSString *)key;

- (NSString *)displayNameForKey:(id)key value:(id)value;

+ (NSArray *)ISOCountryCodes;
+ (NSArray *)ISOCurrencyCodes;
+ (NSArray *)ISOLanguageCodes;
+ (NSArray *)commonISOCurrencyCodes;
+ (NSDictionary *)componentsFromLocaleIdentifier:(NSString *)ident;
+ (NSString *)localeIdentifierFromComponents:(NSDictionary *)components;
+ (NSLocaleLanguageDirection) characterDirectionForLanguage:(NSString *)isoLangCode;
+ (NSLocaleLanguageDirection) lineDirectionForLanguage:(NSString *)isoLangCode;

@end

extern NSString * const NSLocaleIdentifier;
extern NSString * const NSLocaleLanguageCode;
extern NSString * const NSLocaleScriptCode;
extern NSString * const NSLocaleVariantCode;
extern NSString * const NSLocaleExemplarCharacterSet;
extern NSString * const NSLocaleCalendar;
extern NSString * const NSLocaleCalendarIdentifier;
extern NSString * const NSLocaleCollationIdentifier;
extern NSString * const NSLocaleUsesMetricSystem;
extern NSString * const NSLocaleMeasurementSystem;
extern NSString * const NSLocaleDecimalSeparator;
extern NSString * const NSLocaleGroupingSeparator;
extern NSString * const NSLocaleCurrencySymbol;
extern NSString * const NSLocaleCurrencyCode;
extern NSString * const NSLocaleCollatorIdentifier;
extern NSString * const NSLocaleQuotationBeginDelimiterKey;
extern NSString * const NSLocaleQuotationEndDelimiterKey;
extern NSString * const NSLocaleAlternateQuotationBeginDelimiterKey;
extern NSString * const NSLocaleAlternateQuotationEndDelimiterKey;
extern NSString * const NSLocaleTimeDateFormatString;

extern NSString * const NSCurrentLocaleDidChangeNotification;

extern NSString * const NSGregorianCalendar;
extern NSString * const NSBuddhistCalendar;
extern NSString * const NSChineseCalendar;
extern NSString * const NSHebrewCalendar;
extern NSString * const NSIslamicCalendar;
extern NSString * const NSIslamicCivilCalendar;
extern NSString * const NSJapaneseCalendar;
extern NSString * const NSRepublicOfChinaCalendar;
extern NSString * const NSPersianCalendar;
extern NSString * const NSIndianCalendar;
extern NSString * const NSISO8601Calendar;

/*
   vim:syntax=objc:
 */
