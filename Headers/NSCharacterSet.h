/*
 * Copyright (c) 2004,2005	Gold Project
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
/*!
 \file CharacterSet.h
 \author Justin Hibbits
 */

#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>

/*!
 \class CharacterSet
 \brief Represents a set of Unicode-compliant characters.  Used primarily for searching.
 */
@interface NSCharacterSet	: NSObject <NSCopying>

// Creating a standard character set
/*!
 * \brief Returns a character set containing the alphanumeric characters.
 */
+(NSCharacterSet *)alphanumericCharacterSet;

+ (NSCharacterSet *) capitalizedLetterCharacterSet;

/*!
 * \brief Returns a character set containing the control characters.
 */
+(NSCharacterSet *)controlCharacterSet;

/*!
 * \brief Returns a character set containing only decimal digits.
 */
+(NSCharacterSet *)decimalDigitCharacterSet;

+ (NSCharacterSet *) decomposableCharacterSet;

/*!
 * \brief Returns a character set containing illegal characters.
 */
+ (NSCharacterSet*)illegalCharacterSet;

/*!
 * \brief Returns a character set containing all upper- and lowercase alphabetic characters.
 */
+(NSCharacterSet *)letterCharacterSet;

/*!
 * \brief Returns a character set containing all lowercase alphabetic characters.
 */
+(NSCharacterSet *)lowercaseLetterCharacterSet;

/*!
 * \brief Returns a character set containing all newline characters.
 */
+(NSCharacterSet *)newlineCharacterSet;

+ (NSCharacterSet *) nonBaseCharacterSet;

/*!
 * \brief Returns a character set containing punctionation symbols.
 */
+(NSCharacterSet *)punctuationCharacterSet;

/*!
 * \brief Returns a character set containing all symbols ($, ., etc).
 */
+(NSCharacterSet *)symbolCharacterSet;

/*!
 * \brief Returns a character set containing all uppercase alphabetic characters.
 */
+(NSCharacterSet *)uppercaseLetterCharacterSet;

/*!
 * \brief Returns a character set containing only whitespace and newline characters.
 */
+(NSCharacterSet *)whitespaceAndNewlineCharacterSet;

/*!
 * \brief Returns a character set containing only whitespace characters.
 */
+(NSCharacterSet *)whitespaceCharacterSet;

// Creating a custom character set
/*!
 * \brief Returns a character set containing characters determined by the bitmap representation.
 * \param data Bitmap representation of the character set.
 * result Returns the character set determined by the bitmap representation.
 */
+(NSCharacterSet *)characterSetWithBitmapRepresentation:(NSData *)data;

/*!
 * \brief Returns a character set containing the characters in the given string.
 * \param aString The string of characters to put in the character set, must not be nil.
 * \return Returns a string containing the characters of aString, the empty set if aString is empty.
 */
+(NSCharacterSet *)characterSetWithCharactersInString:(NSString *)aString;

/*!
 * \brief Returns a character set containing characters with unicode values in a given range.
 * \param aRange NSRange of unicode values for the character set.
 */
+(NSCharacterSet *)characterSetWithRange:(NSRange)aRange;

// Getting a binary representation
/*!
 * \brief Returns a bitmap representation of the character set.
 */
-(NSData *)bitmapRepresentation;

// Testing set membership
/*!
 * \brief Tests if a character is in the character set.
 * \param aCharacter Character to test.
 * \return Returns true if the character is in the character set, NO if not.
 */
-(bool)characterIsMember:(NSUniChar)aCharacter;

/*!
 * \brief Tests if a 32-bit character is in the character set.
 * \param aCharacter Character to test.
 * \return Returns true if the character is in the character set, NO if not.
 */
-(bool)longCharacterIsMember:(UTF32Char)aCharacter;

// Inverting a character set
/*!
 * \brief Returns a character set containing only characters not in the receiver.
 */
-(NSCharacterSet *)invertedSet;

- (bool) isSupersetOfSet:(NSCharacterSet *)other;
- (bool) hasMemberInPlane:(uint8_t)plane;
@end

@interface NSMutableCharacterSet	:	NSCharacterSet
{
}
- (void) addCharactersInRange:(NSRange)r;
- (void) removeCharactersInRange:(NSRange)r;
- (void) addCharactersInString:(NSString *)str;
- (void) removeCharactersInString:(NSString *)str;

- (void) formIntersectionWithCharacterSet:(NSCharacterSet *)other;
- (void) formUnionWithCharacterSet:(NSCharacterSet *)other;

- (void) invert;
@end

/*
   vim:syntax=objc:
 */
