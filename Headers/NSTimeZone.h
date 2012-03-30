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
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSObject.h>

@class NSDate, NSString;
@class NSDictionary, NSArray;

/*!
 * \class NSTimeZone
 * \brief Defines a global timezone.
 */
@interface NSTimeZone	: NSObject <NSCopying>

typedef enum
{
	NSTimeZoneStyleStandard,
	NSTimeZoneStyleShortStandard,
	NSTimeZoneStyleDaylightSaving,
	NSTimeZoneStyleShortDaylightSaving
} NSTimeZoneNameStyle;

/*!
 * \brief Returns the default time zone as set for the current locale.
 */
+(NSTimeZone *)defaultTimeZone;

/*!
 * \brief Sets the specified time zone as the time zone appropriate for the current locale.
 * \param aTimeZone Time zone to set.
 * This new time zone replaced the previous default time zone.
 */
+(void)setDefaultTimeZone:(NSTimeZone *)aTimeZone;

/*!
 * \brief Returns the system's current time zone.
 */
+(NSTimeZone *)systemTimeZone;

+ (void) resetSystemTimeZone;

// Creating and initializing an NSTimeZone
/*!
 * \brief Returns an NSTimeZone representing the time zone with the given seconds offset from GMT.
 * \param seconds Seconds offset from GMT.
 * If there is no object matching the given offset, this method
 * creates and returns a new NSTimeZone bearing the value of the seconds
 * argument as a name.
 */
+(NSTimeZone *)timeZoneForSecondsFromGMT:(int)seconds;

/*!
 * \brief Returns the time zone object identified by the given abbreviation.
 * \param abbreviation Abbreviation of requested time zone.
 * If there's no match, this method returns <b>nil</b>.
 */
+(NSTimeZone *)timeZoneWithAbbreviation:(NSString *)abbreviation;

/*!
 * \brief Returns the time zone object with a name that corresponds with the specified geopolitical region.
 * \param aTimeZoneName Name of geopolitical region.
 * This method searches the regions dictionary for matching names.
 * If there is no match, returns <b>nil</b>.
 */
+(NSTimeZone *)timeZoneWithName:(NSString *)aTimeZoneName;

- (id) initWithName:(NSString *)tzID;

+ (NSString *)timeZoneDataVersion;

// Getting time zone information
/*!
 * \brief Returns a dictionary that maps abbreviations to region names, for example "PST" maps to "US Pacific".
 * If you know a region name for a key, you can obtain a valid
 * abbreviation from the dictionary and use it to obtain a detail time zone
 * object using <b>timeZoneWithAbbreviation:</b>.
 */
+(NSDictionary *)abbreviationDictionary;


/*!
 * \brief Returns the geopolitical name of the time zone.
 */
-(NSString *)name;

// Getting arrays of time zones
/*!
 * \brief Returns an array of string object arrays, each containing strings that show current geopolitical names for each time zone.
 * The subarrays are grouped by latitudinal region.
 */
+ (NSArray *)knownTimeZoneNames;

// New methods from MacOSX, which are deemed useful
/*!
 * \brief Returns the abbreviation, for example "EDT" for Eastern Daylight Time, for the receiver for the current date.
 */
-(NSString *)abbreviation;

/*!
 * \brief Returns the abbreviation for the receiver at the specified date.
 */
-(NSString*)abbreviationForDate:(NSDate *)_date;

/*!
 * \brief Returns true if the receiver is currently using daylight savings time.
 */
-(bool)isDaylightSavingTime;

/*!
 * \brief Returns true if the receiver uses daylight savings time at the specified date.
 */
-(bool)isDaylightSavingTimeForDate:(NSDate *)aDate;

- (NSTimeInterval)daylightSavingTimeOffset;
- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate;
- (NSDate *)nextDaylightSavingTimeTransition;
- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate;

/*!
 * \brief Returns the difference in seconds between the receiver and GMT for the current date.
 */
-(int)secondsFromGMT;

/*!
 * \brief Returns the difference in seconds between the receiver and GMT for the given date.
 */
-(int)secondsFromGMTForDate:(NSDate *)_date;

- (bool)isEqualToTimeZone:(NSTimeZone *)other;
- (NSString *)description;
- (NSString *)localizedName:(NSTimeZoneNameStyle)style locale:(NSLocale *)locale;
@end

/*
   vim:syntax=objc:
 */
