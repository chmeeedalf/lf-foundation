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

#import <Foundation/NSObject.h>

@class NSDate, NSString;
@class NSLocale;
@class NSTimeZone;

typedef double NSTimeInterval;

/*!
 * @class NSDate
 @brief NSDate class.  Used for time intervals and reference points.
 */
@interface NSDate	: NSObject <NSCoding,NSCopying>

// Creating an NSDate object
/*!
 * @brief Allocate an unitialized NSDate object in the given zone.
 * @param zone Zone to use when allocating the object.
 */
+(id)allocWithZone:(NSZone *)zone;

/*!
 * @brief Creates and returns an NSDate object set to the current date and time.
 */
+(id)date;

/*!
 * @brief Creates and returns a new NSDate object given a string.
 * @param description NSString representation of a date in the format YYYY-MM-DD HH:MM:SS - HHMM
 */
+(id)dateWithString:(NSString *)description;

/*!
 * @brief Creates and returns a NSDate set to given seconds from the current time.
 * @param seconds Seconds from the current time to set the NSDate.
 */
+(id)dateWithTimeIntervalSinceNow:(NSTimeInterval)seconds;

/*!
 * @brief Creates and returns a NSDate with a time interval relative to another NSDate object.
 * @param seconds Interval from the date object.
 * @param anotherDate Reference date from which to calculate the new date.
 */
+(id)dateWithTimeInterval:(NSTimeInterval)seconds
	sinceDate:(NSDate *)anotherDate;

/*!
 * @brief Creates and returns a NSDate set to the given seconds from the beginning of the UNIX Epoch.
 * @param seconds Seconds from the UNIX epoch (January 1, 1970, 00:00.00).
 */
+(id)dateWithTimeIntervalSince1970:(NSTimeInterval)seconds;

/*!
 * @brief Creates and returns an NSDate set to the given seconds from the
 * absolute reference date (January 1, 2001, 00:00.00).
 * @param seconds Seconds from the absolute reference date.
 */
+(id)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)seconds;

/*!
 * @brief Creates and returns an NSDate in the distant future.
 */
+(id)distantFuture;

/*!
 * @brief Creates and returns an NSDate in the distant past.
 */
+(id)distantPast;

/*!
 * @brief Initializes a newly allocated NSDate to the current date and time.
 */
-(id)init;

/*!
 * @brief Initializes a newly allocated NSDate to the time in the passed description.
 * @param description NSString representation of a date in the format YYYY-MM-DD HH:MM:SS - HHMM
 */
-(id)initWithString:(NSString *)description;

/*!
 * @brief Initializes an NSDate with a time interval relative to another NSDate object.
 * @param seconds Interval from the date object.
 * @param anotherDate Reference date from which to calculate the new date.
 */
-(NSDate *)initWithTimeInterval:(NSTimeInterval)seconds
	sinceDate:(NSDate *)anotherDate;

/*!
 * @brief Initializes an NSDate object with a time offset from the current time.
 * @param seconds Seconds to offset from the current time.
 */
-(NSDate *)initWithTimeIntervalSinceNow:(NSTimeInterval)seconds;

/*!
 * @brief Initializes an NSDate object with the given offset from the absolute reference date.
 * @param seconds Seconds offset from the reference date.
 */
-(id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)seconds;

/*!
 * @brief Initializes an NSDate to the given seconds from the beginning of the UNIX Epoch.
 * @param seconds Seconds from the UNIX epoch (January 1, 1970, 00:00.00).
 */
-(NSDate *)initWithTimeIntervalSince1970:(NSTimeInterval)seconds;

// Representing dates
/*!
 * @brief Returns a string description of the date object.
 * NSDate conforms to the international standard format: YY-MM-DD HH:MM:SS -HHMM.
 */
-(NSString *)description;

/*!
 * @brief Returns a string representation of the receiver.
 * @param formatString A strftime-style format string.
 * @param aTimeZone	The time zone to use for this description.
 * @param locale NSDictionary of locale data.
 * @return a string representation of the receiver.
 */
- (NSString*)descriptionWithCalendarFormat:(NSString*)formatString
	timeZone:(NSTimeZone*)aTimeZone
	locale:(NSLocale*)locale;
/*!
 * @brief Returns a string representation of the receiver using the given locale dictionary.
 * @param localeDictionary NSDictionary of locale data.
 */
-(NSString *)descriptionWithLocale:(NSLocale *)localeDictionary;

/*!
 * @brief Returns the interval between the reference time and the current time.
 */
+(NSTimeInterval)timeIntervalSinceReferenceDate;

/*!
 * @brief Returns the interval between the receiver and the UNIX reference date.
 */
-(NSTimeInterval)timeIntervalSince1970;

/*!
 * @brief Returns the interval between the receiver and the given date object.
 * @param anotherDate NSDate to compare with the receiver.
 * @return the interval between the given date and the receiver.
 */
-(NSTimeInterval)timeIntervalSinceDate:(NSDate *)anotherDate;

/*!
 * @brief Returns the interval between the receiver and the current date and time.
 */
-(NSTimeInterval)timeIntervalSinceNow;

/*!
 * @brief Returns the interval between the receiver and January 1, 2001.
 */
-(NSTimeInterval)timeIntervalSinceReferenceDate;

// Comparing dates
/*!
 * @brief Comares the receiver with another NSDate object.
 * @param anotherDate NSDate to compare with the receiver.
 * @return OrderDescending if the receiver is temporally later, OrderAscending if temporally earlier, or OrderedSame if they are equal.
 */
-(NSComparisonResult)compare:(NSDate *)anotherDate;

/*!
 * @brief Compares the receiver with another date, and returns the earlier one.
 * @param anotherDate NSDate to compare with the receiver.
 * @return the earlier date.
 */
-(NSDate *)earlierDate:(NSDate *)anotherDate;

/*!
 * @brief Returns true if the receiver and the given date object are equal.
 * @param other NSDate to compare with the receiver.
 * @return true if equal, NO otherwise.
 */
-(bool)isEqualToDate:other;

/*!
 * @brief Compares the receiver's date with the given date object.
 * @param anotherDate NSDate to compare with the receiver.
 * @return the later date.
 */
-(NSDate *)laterDate:(NSDate *)anotherDate;

- (id) dateByAddingTimeInterval:(NSTimeInterval)seconds;
@end

/*
   vim:syntax=objc:
 */
