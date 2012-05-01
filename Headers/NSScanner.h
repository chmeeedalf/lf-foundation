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

@class NSString, NSLocale, NSCharacterSet;

/*!
 * @class NSScanner
 * @brief Class for scanning strings for values.
 * @details A NSScanner is used to scan for various values in a string.  Typically
 * it's used to parse out values, such as integers and floating point numbers.
 */
@interface NSScanner	: NSObject <NSCopying>

// Creating an NSScanner
/*!
 * @brief Creates and returns a scanner that scans the given string.
 * @param aString NSString with which to initialize the scanner.
 * @return Returns a new NSScanner object for the given string.
 * Invokes initWithString: and sets the locale to the user's default locale.
 */
+(id)localizedScannerWithString:(NSString *)aString;

/*!
 * @brief Creates and returns a scanner that scans the given string.
 * @param aString NSString for the scanner to scan.
 */
+(id)scannerWithString:(NSString *)aString;

/*!
 * @brief Initializes a newly allocated scanner to scan the given string.
 * @param aString NSString to scan.
 */
-(id)initWithString:(NSString *)aString;

// Getting an NSScanner's NSString
/*!
 * @brief Returns the string object that the scanner was created with.
 */
-(NSString *)string;

// Configuring an NSScanner
/*!
 * @brief Returns true if the scanner distinguishes case, NO otherwise.
 * Scanners are by default not case sensitive.
 */
-(bool)caseSensitive;

/*!
 * @brief Returns a character set object containing those characters that the scanner ignores when looking for an element.
 * The default set is the whitespace and newline character set.
 */
-(NSCharacterSet *)charactersToBeSkipped;

/*!
 * @brief Returns a dictionary object containing locale information.
 */
-(NSLocale *)locale;

/*!
 * @brief Returns the character Returns the character index at which the scanner will begin its next scanning operation.
 */
-(NSUInteger)scanLocation;

/*!
 * @brief Sets whether or not the scanner should be case sensitive.
 * @param flag If true, scanner is case sensitive.
 */
-(void)setCaseSensitive:(bool)flag;

/*!
 * @brief Sets the scanner to ignore the specified characters.
 * @param aSet Character set to skip.
 */
-(void)setCharactersToBeSkipped:(NSCharacterSet *)aSet;

/*!
 * @brief Sets the scanner's locale.
 * @param locale The locale dictionary to use with the scanner.
 */
-(void)setLocale:(NSLocale *)locale;

/*!
 * @brief Sets the location at which the next scan will begin.
 * @param anIndex Index to begin the next scan.
 */
-(void)setScanLocation:(NSUInteger)anIndex;

// Scanning a string
/*!
 * @brief Scans the string as long as characters from the given set are encountered, accumulating the characters into the given string, if not nil.
 * @param aSet NSSet of characters to scan.
 * @param value Optional pointer to the string into which to place the scanned characters.
 * @return Returns true if any characters are scanned, NO otherwise.
 */
-(bool)scanCharactersFromSet:(NSCharacterSet *)aSet
	intoString:(NSString **)value;

/*!
 * @brief Scans a <b>bool</b> into the given pointer.
 * @param value Pointer to the bool to place the read value.
 * @return Returns true if a character in the range 1-9,yY,tT is scanned,
 * skipping whitespace and + and - characters.
 */
-(bool)scanBool:(bool *)value;

/*!
 * @brief Scans a <b>double</b> into the given pointer.
 * @param value Pointer to the double to place the read value.
 * @return Returns true if a valid floating-point expression was scanned, otherwise NO.
 */
-(bool)scanDouble:(double *)value;
- (bool) scanHexDouble:(double *)value;

/*!
 * @brief Scans a <b>float</b>, placing it into the given pointer if possible.
 * @param value Pointer to the location into which to place the value.
 * @return Returns true if a valid expression was read, NO otherwise.
 */
-(bool)scanFloat:(float *)value;
- (bool) scanHexFloat:(float *)value;

/*!
 * @brief Scans an <b>int</b> placing it into the given pointer if possible.
 * @param value Pointer to the location into which to place the value.
 * @return Returns true if a valid expression was read, NO otherwise.
 */
-(bool)scanInt:(int *)value;
- (bool) scanInteger:(NSInteger *)value;
- (bool) scanHexInt:(unsigned int *)value;

/*!
 * @brief Scans a <b>long long int</b> into the given pointer if possible.
 * @param value Pointer to the location into which to place the scanned value.
 * @return Returns true if a valid expression was read, NO otherwise.
 */
-(bool)scanLongLong:(long long *)value;
- (bool) scanHexLongLong:(unsigned long long *)value;

/*!
 * @brief Scans for the specified string, and if a match is found returns by reference in the optional value pointer.
 * @param aString NSString to search for.
 * @param value Pointer to the location into which to place the pointer to the scanned string.
 * @return Returns true if the string was found, NO if not.
 */
-(bool)scanString:(NSString *)aString intoString:(NSString **)value;

/*!
 * @brief Scans the string until a character from the given character set is found.
 * @param aSet NSSet of characters to search for.
 * @param value Pointer to the location into which to place the pointer to the scanned string.
 * @return Returns true if a character from the set was found, else NO.
 */
-(bool)scanUpToCharactersFromSet:(NSCharacterSet *)aSet
	intoString:(NSString **)value;

/*!
 * @brief Scans up to the specified string, and if a match is found returns by reference in the optional value pointer.
 * @param aString NSString to search for.
 * @param value Pointer to the location into which to place the pointer to the scanned string.
 * @return Returns true if the string was found, NO if not.
 */
-(bool)scanUpToString:(NSString *)aString intoString:(NSString **)value;

/*!
 * @brief Returns true if at the end of the string, false if not.
 */
-(bool)isAtEnd;

@end

/*
   vim:syntax=objc:
 */
