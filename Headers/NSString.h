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

/*!
 * \file NSString.h
 */
#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSException.h>

@class NSData;
@class NSLocale;
@class NSCharacterSet;
@class NSArray;
@class NSURL;
@class NSError;

/*!
 * \brief Supported string encodings.
 */
typedef enum {
	NSASCIIStringEncoding = 1,
	NSNEXTSTEPStringEncoding = 2,
	NSJapaneseEUCStringEncoding = 3,
	NSUTF8StringEncoding = 4,
	NSISOLatin1StringEncoding = 5,
	NSSymbolStringEncoding = 6,
	NSNonLossyASCIIStringEncoding = 7,
	NSShiftJISStringEncoding = 8,
	NSISOLatin2StringEncoding = 9,
	NSUnicodeStringEncoding = 10,
	NSWindowsCP1251StringEncoding = 11,
	NSWindowsCP1252StringEncoding = 12,
	NSWindowsCP1253StringEncoding = 13,
	NSWindowsCP1254StringEncoding = 14,
	NSWindowsCP1250StringEncoding = 15,
	NSISO2022JPStringEncoding = 21,
	NSMacOSRomanStringEncoding = 30,
	NSUTF16StringEncoding = NSUnicodeStringEncoding,
	NSUTF16BigEndianStringEncoding = 0x90000100,
	NSUTF16LittleEndianStringEncoding = 0x94000100,
	NSUTF32StringEncoding = 0x8c000100,
	NSUTF32BigEndianStringEncoding = 0x98000100,
	NSUTF32LittleEndianStringEncoding = 0x9c000100,
	NSProprietaryStringEncoding = 65536,
} NSStringEncoding;

enum {
	NSCaseInsensitiveSearch = 1,
	NSLiteralSearch = 2,	///!< Not used yet.
	NSBackwardsSearch = 4,
	NSAnchoredSearch = 8,
	NSNumericSearch = 64,
	NSDiacriticInsensitiveSearch = 128,
	NSWidthInsensitiveSearch = 256,
	NSForcedOrderingSearch = 512,
	NSRegularExpressionSearch = 1024,
};
typedef NSUInteger NSStringCompareOptions;

enum {
	NSStringEncodingConversionAllowLossy = 1,
	NSStringEncodingConversionExternalRepresentation = 2,
};

typedef NSUInteger NSStringEncodingConversionOptions;

typedef NSUInteger NSStringEnumerationOptions;
enum
{
	NSStringEnumerationByLines = 0,
	NSStringEnumerationByParagraphs = 1,
	NSStringEnumerationByComposedCharacterSequence = 2,
	NSStringEnumerationByWords = 3,
	NSStringEnumerationBySentences = 4,
	NSStringEnumerationReverse = 1UL << 8,
	NSStringEnumerationSubstringNotRequired = 1UL << 9,
	NSStringEnumerationLocalized = 1UL << 10
};

@class NSString;
typedef NSString * const NSSymbol;

#define NSMakeSymbol(symname) \
	NSSymbol symname = @#symname

@interface NSCharacterConversionException	:	NSException
@end
@interface NSParseErrorException	:	NSException
@end

/*!
 \class NSString
 \brief Unicode string class for Gold.

 \details This implements a Unicode 5.0 compatible string class, with
 support for all Unicode operations (coming as soon as I feel like
 implementing).

 \todo Normalization
 \todo StringPrep
 \todo Finish conversion
 \todo Collation
 \todo Full RegEx
 \todo Full properties
 \todo Transliteration
 */
@interface NSString : NSObject <NSCoding,NSCopying,NSMutableCopying>

// Creating temporary strings
/*!
 * \brief Returns an empty string.
 */
+(id)string;

/*!
 \brief Returns a string created using the given format as a <b>printf()</b> style format string, and the following arguments as values to be substituted into the format string.
 \param format Format string and associated arguments.
 */
+(id)stringWithFormat:(NSString *)format,...;

/*!
 \brief Returns a string created with the passed format as a <b>printf()</b> style format string.
 \param format Format for the string.
 \param locale NSLocale and arguments to create the string.
 */
+(id)stringWithFormat:(NSString *)format locale:(NSLocale *)locale,...;
+(id)localizedStringWithFormat:(NSString *)format,...;

/*!
 \brief Returns a string containing the passed unicode characters.
 \param chars Characters to place into the string.
 \param length NSNumber of characters from the unicode string to place into the NSString object.
 */
+(id)stringWithCharacters:(const NSUniChar *)chars
	length:(NSUInteger)length;

/*!
 \brief Returns a string containing the characters from the passed string object.
 \param string NSString instance to copy.
 */
+(id)stringWithString:(NSString *)string;

/*!
 \brief Returns a string containing the characters from the passed C-style string using the default C encoding.
 \param byteString C-style string to initialize the NSString with.
 \param enc Encoding of C-style string.
 */
+(id)stringWithCString:(const char *)byteString encoding:(NSStringEncoding)enc;

/*!
 \brief Returns a string containing the characters from the passed C-style
 string using UTF-8 encoding
 \param byteString C-style string to initialize the NSString with.
 */
+(id)stringWithUTF8String:(const char *)byteString;


+ (id) stringWithContentsOfURL:(NSURL *)uri encoding:(NSStringEncoding)enc error:(NSError **)err;
+ (id) stringWithContentsOfURL:(NSURL *)uri usedEncoding:(NSStringEncoding*)enc error:(NSError **)err;

- (bool) writeToURL:(NSURL *)uri atomically:(bool)atomic encoding:(NSStringEncoding)enc error:(NSError **)err;

// Getting a string's length
/*!
 \brief Returns the number of characters in the receiver.
 This number includes the individual characters of composed
 character sequences.
 */
-(NSUInteger)length;

/*!
 * \brief Returns the number of bytes given a specific encoding.
 */
-(size_t)lengthOfBytesUsingEncoding:(NSStringEncoding)encoding;

/*!
 * \brief Returns an upper-bound estimate of the number of bytes needed to hold
 * the string in the given encoding.
 */
-(size_t)maximumLengthOfBytesUsingEncoding:(NSStringEncoding)encoding;

// Accessing characters
/*!
 \brief Returns the character at the array position given by the passed index.
 \param index Index of the character to return.

 \details This method raises an StringBoundsError exception if the index
 is beyond the end of the string.
 */
-(NSUniChar)characterAtIndex:(NSUInteger)index;

/*!
 \brief Copies the characters in the given range from the receiver into the passed buffer.
 \param buffer Buffer into which to place the characters.
 \param aRange NSRange of characters to copy.

 \details This method does not add the null terminating character.  This
 method raises StringBoundsError exception if any part of the range is
 beyond the end of the string.
 */
-(void)getCharacters:(NSUniChar *)buffer range:(NSRange)aRange;

/*!
 \brief Copies the receiver's characters as bytes into the given buffer.
 \param buffer Buffer into which to place the C string representation of the receiver.
 \param maxLength Maximum length of the C string.
 \param aRange NSRange of characters to copy.
 \param leftoverRange If not all characters can be copied, the range of extra characters is put into the location pointed to by this argument.

 \details The passed buffer must be large enough to contain the resulting
 C string plus a terminating null character, which is added by this method.
 This method raises an StringBoundsError exception if any part of the range
 is beyond the end of the string.
 */
- (bool)getBytes:(void*)bytes maxLength:(NSUInteger)maxLength usedLength:(NSUInteger *)used
	encoding:(NSStringEncoding)encoding options:(NSStringEncodingConversionOptions)options
	range:(NSRange)fromRange remainingRange:(NSRange*)remainingRange;

// Getting C strings
/*!
  \brief Returns a representation of the receiver as a C string in the given
  encoding.
  \param enc Encoding to use.
 */
- (const char *)cStringUsingEncoding:(NSStringEncoding)enc;

/*!
 \brief Converts the receiver's contents to a given encoding and stores them in the given buffer.
 \param buffer Buffer into which to place the C string representation of the receiver.
 \param maxLength Maximum length of the C string.
 \param encoding Encoding to use.

 \details The passed buffer must be large enough to contain the resulting
 C string plus a terminating null character, which is added by this method.
 */
-(bool)getCString:(char *)buffer maxLength:(NSUInteger)maxLength encoding:(NSStringEncoding)encoding;

/*!
 \brief Returns a representation of the receiver as a C string in UTF8
 encoding
 */
-(const char *)UTF8String;


// Combining strings
/*!
 * \brief Returns a string made by appending the passed format.
 */
-(NSString *)stringByAppendingFormat:(NSString *)format,...;

/*!
 \brief Returns a string made by appending the passed string object to the receiver.
 \param aString NSString to append to the receiver.
 */
-(NSString *)stringByAppendingString:(NSString *)aString;

/*!
 * \brief Returns a new string with the receiver's contents either truncated or
 * padded to the specified length.
 */
-(NSString *)stringByPaddingToLength:(size_t)newLength withString:(NSString *)pad startingAtIndex:(NSUInteger)start;


// Dividing strings into substrings
/*!
 \brief Returns an array containing all components of the string separated by the given substring.
 \param separator Separator string to divide with.

 \details The strings appear in the array in the order they did in the
 receiver.
 */
-(NSArray *)componentsSeparatedByString:(NSString *)separator;

/*!
 \brief Returns an array containing all components of the string separated by characters from the given character set.
 \param separator Character set to split on.

 \details The strings appear in the array in the order they did in the
 receiver.
 */
-(NSArray *)componentsSeparatedByCharactersInSet:(NSCharacterSet *)separator;

/*!
 * \brief Returns a string with the characters from the given set trimmed.
 */
-(NSString *)stringByTrimmingCharactersInSet:(NSCharacterSet *)chars;

/*!
 \brief Returns a string object containing the characters from the receiver starting at the given index and extending to the end.
 \param index Index to start the substring.

 \details This method raises an StringBoundsError exception if the index
 lies beyond the end of the string.
 */
-(NSString *)substringFromIndex:(NSUInteger)index;

/*!
 \brief Returns a string object containing the characters of the receiver which lie in the given range.
 \param aRange NSRange of characters for the substring.

 \details This method raises StringBoundsError exception if any part of the
 range lies outside the string.
 */
-(NSString *)substringWithRange:(NSRange)aRange;

/*!
 \brief Returns a string object containing the characters from the receiver starting at the beginning  and extending to the given index.
 \param index Index to end the substring.

 \details This method raises an StringBoundsError exception if the index
 lies beyond the end of the string.
 */
-(NSString *)substringToIndex:(NSUInteger)index;


// Finding ranges of characters and substrings
/*!
 \brief Invokes <b>rangeOfCharacterFromSet:options:</b> with no options.
 \param aSet Character set of which the first character will be searched.
 */
-(NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet;

/*!
 \brief Invokes rangeOfCharacterFromSet:options:range: with the given character set and option mask, and the entire extent of the reciever as the range.
 \param aSet Set of which the first character will be searched.
 \param mask Option mask as a combination (bitwise OR) of NSCaseInsensitiveSearch, NSLiteralSearch, and NSBackwardsSearch.
 */
-(NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet
	options:(NSStringCompareOptions)mask;

/*!
 \brief Returns the range of the first character in the character set, restricted to the given range and option mask.
 \param aSet Set of which the first character will be searched.
 \param mask Option mask as a combination (bitwise OR) of NSCaseInsensitiveSearch, NSLiteralSearch, and NSBackwardsSearch.
 \param aRange NSRange to restrict the search.
 */
-(NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet
	options:(NSStringCompareOptions)mask range:(NSRange)aRange;

/*!
 \brief Invokes <b>rangeOfString:options:</b> with no options.
 \param string NSString to search for.
 */
-(NSRange)rangeOfString:(NSString *)string;

/*!
 \brief Invokes rangeOfString:options:range: with the given string and option mask, and the entire extent of the reciever as the range.
 \param string NSString to search for.
 \param mask Option mask as a combination (bitwise OR) of NSCaseInsensitiveSearch, NSLiteralSearch, and NSBackwardsSearch.
 */
-(NSRange)rangeOfString:(NSString *)string
	options:(NSStringCompareOptions)mask;

/*!
 \brief Returns the range of the given string, restricted to the given range and option mask.
 \param aString NSString to search for.
 \param mask Option mask as a combination (bitwise OR) of NSCaseInsensitiveSearch, NSLiteralSearch, and NSBackwardsSearch.
 \param aRange NSRange to restrict the search.
 */
-(NSRange)rangeOfString:(NSString *)aString
	options:(NSStringCompareOptions)mask range:(NSRange)aRange;

/*!
 \brief Returns the range of the string, restricted to the given range and option mask.
 \param aString NSString to search for.
 \param mask Option mask as a combination (bitwise OR) of NSCaseInsensitiveSearch, NSLiteralSearch, and NSBackwardsSearch.
 \param aRange NSRange to restrict the search.
 \param locale NSLocale to use when comparing.
 */
-(NSRange)rangeOfString:(NSString *)aString
	options:(NSStringCompareOptions)mask range:(NSRange)aRange locale:(NSLocale *)locale;

- (void) enumerateLinesUsingBlock:(void (^)(NSString *, bool *))block;
- (void) enumerateSubstringsInRange:(NSRange)range options:(NSStringEnumerationOptions)opts usingBlock:(void (^)(NSString *, NSRange, NSRange, bool *))block;

// Replacing substrings
/*!
 * \brief Returns a string in which all occurrences of a target string in the
 * receiver are replaced.
 */
-(NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)newString;

/*!
 * \brief Returns a new string in which all occurrences of a target string in a
 * given range of the receiver are replaced.
 */
-(NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)newString options:(NSStringCompareOptions)options range:(NSRange)range;

/*!
 * \brief Returns a new string in which characters of the receiver in the given
 * range are replaced by a different string.
 */
-(NSString *)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)newString;


- (void) getLineStart:(NSUInteger *)startIndex end:(NSUInteger *)lineEndIndex contentsEnd:(NSUInteger *)contentsEnd forRange:(NSRange)aRange;

/*!
 * \brief Returns the range of a line of text within the given range.
 */
- (NSRange) lineRangeForRange:(NSRange)r;

- (void) getParagraphStart:(NSUInteger *)startIndex end:(NSUInteger *)parEndIndex contentsEnd:(NSUInteger *)contentsEnd forRange:(NSRange)aRange;
/*!
 * \brief Returns the range of a paragraph of text within the given range.
 */
- (NSRange) paragraphRangeForRange:(NSRange)r;

- (NSRange) rangeOfComposedCharacterSequenceAtIndex:(NSUInteger)idx;
- (NSRange) rangeOfComposedCharacterSequencesForRange:(NSRange)range;

// Identifying and comparing strings
/*!
 \brief Invokes compare:options: with the option CaseInsensitiveSearch.
 \param aString NSString to compare with the receiver.
 */
-(NSComparisonResult)caseInsensitiveCompare:(NSString *)aString;

- (NSComparisonResult) localizedCaseInsensitiveCompare:(NSString *)aString;

/*!
 \brief Invokes compare:options: with no options.
 \param aString NSString to compare with the receiver.
 */
-(NSComparisonResult)compare:(NSString *)aString;

-(NSComparisonResult)localizedCompare:(NSString *)aString;
- (NSComparisonResult)localizedStandardCompare:(NSString *)aString;

/*!
 \brief Invokes compare:options:range: with the given mask, string, and the receiver's full extent as the range.
 \param aString NSString to compare with the receiver.
 \param mask Option mask, may be NSCaseInsensitiveSearch or NSLiteralSearch, or a bitwise-OR of them.
 */
-(NSComparisonResult)compare:(NSString *)aString options:(NSStringCompareOptions)mask;

/*!
 \brief Compares the given string with the receiver and returns their lexical ordering.
 \param aString NSString to compare with the receiver.
 \param mask Option mask, may be NSCaseInsensitiveSearch or NSLiteralSearch, or a bitwise-OR of them.
 \param aRange NSRange to restrict the comparison.
 */
-(NSComparisonResult)compare:(NSString *)aString options:(NSStringCompareOptions)mask
	range:(NSRange)aRange;

/*!
 \brief Compares the given string with the receiver and returns their lexical ordering.
 \param aString NSString to compare with the receiver.
 \param mask Option mask, may be NSCaseInsensitiveSearch or NSLiteralSearch, or a bitwise-OR of them.
 \param aRange NSRange to restrict the comparison.
 \param locale NSLocale to use for comparison.
 */
-(NSComparisonResult)compare:(NSString *)aString options:(NSStringCompareOptions)mask
	range:(NSRange)aRange locale:(NSLocale *)locale;

/*!
 \brief Returns true if the receiver has as its prefix the given string.
 \param aString NSString to check as prefix.
 */
-(bool)hasPrefix:(NSString *)aString;

/*!
 \brief Returns true if the receiver has as its suffix the given string.
 \param aString NSString to check as suffix.
 */
-(bool)hasSuffix:(NSString *)aString;

/*!
 \brief Returns true if both the receiver and the passed object have the same <b>id</b> or if they compare as OrderedSame.
 \param aString NSString to compare with the receiver.
 */
-(bool)isEqualToString:(NSString *)aString;

/*!
 \brief Returns an unsigned integer that can be used as a table address in a hash table structure.

 \details If two string objects are equal (as determined by
 <b>isEqual:</b>), they must have the same hash value.
 */
-(NSHashCode)hash;

/*!
 * \brief Returns a string with the given character folding options applied.
 */
-(NSString *)stringByFoldingWithOptions:(NSStringCompareOptions)options locale:(NSLocale *)locale;

// Getting a shared prefix
/*!
 \brief Returns the substring of the receiver containing characters that the receiver and the passed string have in common.
 \param aString NSString to compare with the receiver.
 \param mask Option mask, containing bitwise-OR of one or more of: NSCaseInsensitiveSearch and NSLiteralSearch.
 */
-(NSString *)commonPrefixWithString:(NSString *)aString
	options:(NSStringCompareOptions)mask;

// Changing case
/*!
 \brief Returns a string with the first character of each word changed to its corresponding uppercase value.
 */
-(NSString *)capitalizedString;

/*!
 \brief Returns a string with each character changed to its corresponding lowercase value.
 */
-(NSString *)lowercaseString;

/*!
 \brief Returns a string with each character changed to its corresponding uppercase value.
 */
-(NSString *)uppercaseString;

// Getting Strings with Mappings
- (NSString *) decomposedStringWithCanonicalMapping;
- (NSString *) decomposedStringWithCompatibilityMapping;
- (NSString *) precomposedStringWithCanonicalMapping;
- (NSString *) precomposedStringWithCompatibilityMapping;

// Getting numeric values
/*!
 * \brief Returns the boolean value of the receiver's text.
 */
-(bool)boolValue;

/*!
 \brief Returns the double precision floating point value of the receiver's text.

 \details Whitespace at the beginning of the string is skipped.  If the
 receiver begins with a valid text representation of a floating-point number,
 the number's value is returned, otherwise 0.0 is returned.  HUGE_VAL or
 -HUGE_VAL is returned on overflow.  0.0 is returned on underflow.
 Characters following the number are ignored.
 */
-(double)doubleValue;

/*!
 \brief Returns the floating point value of the receiver's text.

 \details Whitespace at the beginning of the string is skipped.  If the
 receiver begins with a valid text representation of a floating-point number,
 the number's value is returned, otherwise 0.0 is returned.  HUGE_VAL or
 -HUGE_VAL is returned on overflow.  0.0 is returned on underflow.
 Characters following the number are ignored.
 */
-(float)floatValue;

/*!
 \brief Returns the integer value of the receiver's text.

 \details Whitespace at the beginning of the string is skipped.  If the
 receiver begins with a valid representation of an integer, that number's
 value is returned, otherwise 0 is returned.  INT_MAX or INT_MIN is returned
 on overflow.  Characters following the number are ignored.
 */
-(int)intValue;
-(NSInteger)integerValue;

/*!
 \brief Returns the long long integer value of the receiver's text.

 \details Whitespace at the beginning of the string is skipped.  If the
 receiver begins with a valid representation of an integer, that number's
 value is returned, otherwise 0 is returned.  INT_MAX or INT_MIN is returned
 on overflow.  Characters following the number are ignored.
 */
-(long long)longLongValue;

// Working with encodings
/*!
 \brief Returns a null terminated array of available string encodings.
 */
+(const NSStringEncoding *)availableStringEncodings;

/*!
 \brief Returns the C string encoding assumed for any method accepting a C string as an argument.
 */
+(NSStringEncoding)defaultCStringEncoding;

/*!
 \brief Returns the localized name of the specified string encoding.
 \param encoding NSString encoding of which to get the localized name.
 */
+(NSString *)localizedNameOfStringEncoding:(NSStringEncoding)encoding;

/*!
 \brief Returns true if the receiver can be converted to the specified encoding without loss of information.
 \param encoding NSString encoding to encode the string into.
 */
-(bool)canBeConvertedToEncoding:(NSStringEncoding)encoding;

/*!
 \brief Invokes dataUsingEncoding:allowLossyConversion: with NO as the argument to allow lossy conversion.
 \param encoding NSString encoding to encode into for the data object.
 */
-(NSData *)dataUsingEncoding:(NSStringEncoding)encoding;

/*!
 \brief Returns an NSData object containing a representation of the receiver in the specified encoding.
 \param encoding Encoding of the data object to reeturn.
 \param flag Whether or not to allow lossy conversion.

 \details If the allowLossyConversion flag is not set and the receiver
 can't be converted without losing information this method returns
 <b>nil</b>.  If the flag is true and the receiver can't be converted without
 losing some information, some characters may be removed or altered in
 conversion.
 */
-(NSData *)dataUsingEncoding:(NSStringEncoding)encoding
	allowLossyConversion:(bool)flag;

// Storing the string
/*!
 \brief Returns the string itself.
 */
-(NSString *)description;

/*!
 \brief Returns the encoding in which this string can be expressed (with lossless conversion) most quickly.
 */
-(NSStringEncoding)fastestEncoding;

/*!
 \brief Returns the encoding in which this string can be expressed (with lossless conversion) in the most space efficient manner.
 */
-(NSStringEncoding)smallestEncoding;

/*!
 \brief Returns the index of the given substring in the receiver, found from the given index.
 */
-(NSUInteger)indexOfString:(NSString*)substring fromIndex:(NSUInteger)index;

/*!
 \brief Returns the index of the given substring in the receiver.
 */
- (NSUInteger)indexOfString:(NSString*)substring;

-(NSString *) stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)enc;
-(NSString *) stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)enc;

@end

/*!
 \category NSString(stringInitialization)
 \brief NSString initialization methods.
 */
@interface NSString (NSStringInitialization)
// Initializing newly allocated strings
/*!
 \brief Initializes a newly allocated NSString to contain no characters.
 This is the only initialization method that a subclass should
 invoke.
 */
-(id)init;

/*!
 \brief Initializes a newly allocated NSString to contain the given bytes.
 \param bytes Bytes in the given encoding for the string.
 \param length Length of the byte string.
 \param encoding NSString encoding of the bytes.
 */
- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length
	encoding:(NSStringEncoding)encoding;

/*!
 \brief Initializes a newly allocated NSString to contain the given bytes.
 \param bytes Bytes in the given encoding for the string.
 \param length Length of the byte string.
 \param encoding NSString encoding of the bytes.
 \param flag Whether or not to free the bytes when done.

 \details The object takes full ownership of the byte string.
 */
- (id)initWithBytesNoCopy:(const void *)bytes length:(NSUInteger)length
	encoding:(NSStringEncoding)encoding freeWhenDone:(bool)flag;

/*!
 \brief Initializes an NSString containing the passed unicode characters.
 \param chars Characters to place into the string.
 \param length NSNumber of characters from the unicode string to place into the NSString object.
 */
-(id)initWithCharacters:(const NSUniChar *)chars
	length:(NSUInteger)length;

/*!
 \brief Initializes an NSString containing the passed unicode characters.
 \param chars Characters to place into the string.
 \param length NSNumber of characters from the unicode string to place into the NSString object.
 \param flag Flag for whether to free the string when done.

 \details This method does not stop at a null byte.  The receiver becomes
 the owner of the C string.  If the flag is true, it will free the memory of
 the C string when it no longer needs it.
 */
-(id)initWithCharactersNoCopy:(const NSUniChar *)chars
	length:(NSUInteger)length freeWhenDone:(bool)flag;

/*!
 \brief Initializes an NSString with the contents of the given string.
 \param string NSString to create a copy of in the receiver.
 */
-(id)initWithString:(NSString *)string;

/*!
 \brief Initializes an NSString with the given C-style string.
 \param byteString A C-style (null-terminated) string in the default C encoding.
 \param enc Encoding of byte string.

 \details This method converts the one-byte characters in the string into
 Unicode characters.
 */
-(id)initWithCString:(const char *)byteString encoding:(NSStringEncoding)enc;
- (id)initWithUTF8String:(const char *)utf8String;

/*!
 \brief Initializes an NSString created using the given format as a <b>printf()</b> style format string, and the following arguments as values to be substituted into the format string.
 \param format Format string and associated arguments.
 */
-(id)initWithFormat:(NSString *)format,...;

/*!
 \brief Initializes an NSString created using the given format as a <b>vprintf()</b> style format string, and the following arguments as values to be substituted into the format string.
 \param format Format string.
 \param argList Variable argument list containing the values for the format.
 */
-(id)initWithFormat:(NSString *)format arguments:(va_list)argList;

/*!
 \brief Initializes an NSString created using the given format as a <b>printf()</b> style format string, and the following arguments as values to be substituted into the format string.
 \param format Format string.
 \param dictionary NSLocale dictionary and associated arguments.
 */
-(id)initWithFormat:(NSString *)format 
	locale:(NSLocale *)dictionary,...;

/*!
 \brief Initializes an NSString created using the given format as a <b>vprintf()</b> style format string, and the following arguments as values to be substituted into the format string.
 \param format Format string.
 \param dictionary NSLocale dictionary.
 \param argList Variable argument list containing the values for the format.
 */
-(id)initWithFormat:(NSString *)format
	locale:(NSLocale *)dictionary arguments:(va_list)argList;

/*!
 \brief Initializes an NSString by converting the bytes in the given data object into Unicode characters.
 \param data NSData object to convert to Unicode.
 \param encoding Encoding of data object.

 \details The data object must be an NSData object containing bytes in the
 given encoding and in the default "plain text" format for that encoding.
 */
-(id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

/*
- (id) initWithMessageFormat:(NSString *)format locale:(NSLocale *)locale
	arguments:(va_list)argList;
- (id) initWithMessageFormat:(NSString *)format arguments:(va_list)argList;
- (id) initWithMessageFormat:(NSString *)format locale:(NSLocale *)locale,...;
- (id) initWithMessageFormat:(NSString *)format,...;
 */

- (id) initWithContentsOfURL:(NSURL *)uri encoding:(NSStringEncoding)enc error:(NSError **)err;
- (id) initWithContentsOfURL:(NSURL *)uri usedEncoding:(NSStringEncoding*)enc error:(NSError **)err;
@end

/*!
 \class NSMutableString
 \brief Mutable subclass of NSString.

 \details Since the NSString class is immutable, the NSMutableString class is
 offered.  It is bad style to accept and return NSMutableString instances as
 part of the public API, because some scripting languages don't like their
 strings changing underneath them (case in point, Python, and any functional
 language).
 */
@interface NSMutableString	: NSString

// Creating temporary strings
/*!
 \brief Returns an empty mutable string of the given capacity.
 \param capacity Capacity of the string.
 */
+(id)stringWithCapacity:(unsigned int)capacity;

// Initializing a mutable string
/*!
 \brief Initializes a newly allocated  mutable string of the given capacity.
 \param capacity Capacity of the string.
 */
-(id)initWithCapacity:(unsigned int)capacity;

// Modifying a string
/*!
 * \brief Append a string format to the receiver.
 */
-(void)appendFormat:(NSString *)format,...;

/*!
 \brief Appends the given string to the receiver.
 \param aString NSString to append to the receiver.
 */
-(void)appendString:(NSString *)aString;

/*!
 \brief Removes from the receiver all characters in the given range.
 \param range NSRange of characters to remove.

 \details This method raises an StringBoundsError exception if any part
 of the range lies beyond the end of the string.
 */
-(void)deleteCharactersInRange:(NSRange)range;

/*!
 \brief Inserts the characters in the specified string into the receiver at the specified index.
 \param aString NSString to insert into the receiver.
 \param index Index into the receiver at the point to insert the string.

 \details This method raises an StringBoundsError exception if the index
 is beyond the end of the string.
 */
-(void)insertString:(NSString *)aString atIndex:(unsigned int)index;

/*!
 \brief Replaces the characters in the given range with the specified string.
 \param aRange NSRange of characters to replace.
 \param aString Replacement string.

 \details This method raises an StringBoundsError exception if the index
 is beyond the end of the string.
 */
-(void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString;


/*!
  \brief Replace all occurences of of the given string in the given range
  with another given string, returning the number of replacements done.
  \param target Target string to replace.
  \param replacement Replacement string.
  \param options Search options to use.
  \param searchRange NSRange of receiver to search.
  \return Returns the number of strings replaced.
 */
-(unsigned int)replaceOccurrencesOfString:(NSString *)target
	withString:(NSString *)replacement options:(NSStringCompareOptions)options
	range:(NSRange)searchRange;
	
/*!
 \brief Sets the receiver to the contents of the specified string.
 \param aString NSString to set the receivers contents to.
 */
-(void)setString:(NSString *)aString;

@end

/*!
 \class SimpleCString
 \brief Base class for the dummy class for @"" strings.
 */
@interface NSSimpleCString	: NSString
{
	char *bytes;			/*!< \brief Pointer to the character string. */
	unsigned int length;	/*!< \brief Length of this string. */
}
@end

/*!
 \class NXConstantString
 \brief Dummy class for the @"" strings.
 */
@interface NSConstantString	: NSSimpleCString
@end

/*! 
 *  \brief Returns whether or not the unicode character is a alphabetical character.
 *  \param ch Character to check.
 */
int	NSStringCharIsAlpha(NSUniChar ch);

/*! 
 *  \brief Returns whether or not the unicode character is a linebreak character.
 *  \param ch Character to check.
 */
int	NSStringCharIsLinebreak(NSUniChar ch);

/*! 
 *  \brief Convert a unicode character to titlecase.
 *  \param ch Character to convert.
 *  \return Titlecase character equivalent.
 */
NSUniChar NSStringCharToTitlecase(register NSUniChar ch);

/*!
 * \brief Returns whether or not the unicode character has the Titlecase type.
 * \param ch Character to check.
 */
int		NSStringCharIsTitlecase(NSUniChar ch);

/*!
 * \brief Convert a unicode character to its uppercase counterpart.
 * \param ch Character to convert.
 * \return Uppercase counterpart to the input character.
 */
NSUniChar NSStringCharToUppercase(register NSUniChar ch);

/*!
 * \brief Returns whether or not the unicode character has the Uppercase type.
 * \param ch Character to check.
 */
int		NSStringCharIsUppercase(NSUniChar ch);

/*!
 * \brief Convert a unicode character to its uppercase counterpart.
 * \param ch Character to convert.
 * \return Uppercase counterpart to the input character.
 */
NSUniChar NSStringCharToLowercase(register NSUniChar ch);

/*!
 * \brief Returns whether or not the unicode character has the Lowercase type.
 * \param ch Character to check.
 */
int		NSStringCharIsLowercase(NSUniChar ch);

/*!
 * \brief Returns whether or not the unicode character is a whitespace
 * character.
 * \param ch Character to check.
 */
int		NSStringCharIsWhitespace(NSUniChar ch);

/*!
 * \brief Returns whether or not the unicode character has the given property
 * mask.
 * \param ch Character to check.
 * \param mask Mask to check on the character.
 */
int		NSStringCharIsMasked(NSUniChar ch, uint32_t mask);

/*!
 * \brief Returns whether or not the unicode character is a decimal digit
 * character.
 * \param ch Character to check.
 */
int		NSStringCharIsDecimalDigit(NSUniChar ch);

/*!
 * \brief Convert a unicode character to its decimal digit value, or -1 if
 * unable to.
 * \param ch Character to check.
 */
int		NSStringCharToDecimalDigit(NSUniChar ch);
/*
   vim:syntax=objc:
 */
