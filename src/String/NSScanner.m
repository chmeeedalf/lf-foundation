/*
 * Copyright (c) 2004-2012	Gold Project
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
   NSScanner.m

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Ovidiu Predescu <ovidiu@bx.logicnet.ro>

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

#import <Foundation/NSScanner.h>
#import "NSConcreteScanner.h"

#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSString.h>
#include <ctype.h>
#include <float.h>
#include <stdlib.h>
#include <unicode/unum.h>

@implementation NSScanner

+ (id)allocWithZone:(NSZone*)zone
{
	return NSAllocateObject([NSConcreteScanner class], 0, zone);
}

- (id)copyWithZone:(NSZone*)zone
{
	if (NSShouldRetainWithZone(self, zone))
	{
		return self;
	} else {
		return [[NSScanner alloc] initWithString:[self string]];
	}
}

+ (id)scannerWithString:(NSString*)string
{
	NSScanner* scanner = [[NSConcreteScanner alloc]
			initWithString:string];
	[scanner setCharactersToBeSkipped:
		[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return scanner;
}

+ (id)localizedScannerWithString:(NSString*)string
{
	NSScanner* scanner = [self scannerWithString:string];
	[scanner setLocale:[NSLocale systemLocale]];
	return scanner;
}

- (id)initWithString:(NSString*)string
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (NSString*)string
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (void)setScanLocation:(NSIndex)index
{
	[self subclassResponsibility:_cmd];
}

- (NSIndex)scanLocation
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (void)setCaseSensitive:(bool)flag
{
	[self subclassResponsibility:_cmd];
}

- (bool)caseSensitive
{
	[self subclassResponsibility:_cmd];
	return false;
}

- (void)setCharactersToBeSkipped:(NSCharacterSet*)skipSet
{
	[self subclassResponsibility:_cmd];
}

- (NSCharacterSet*)charactersToBeSkipped
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (bool)scanCharactersFromSet:(NSCharacterSet*)scanSet
intoString:(NSString**)value
{
	id string = [self string];
	NSIndex orig = [self scanLocation];
	NSIndex length = [string length];
	NSIndex location = orig;

	for (; location < length; location++)
	{
		if (![scanSet characterIsMember:[string characterAtIndex:location]])
		{
			break;
		}
	}

	/* Check if we scanned anything */
	if (location != orig)
	{
		if (value)
		{
			NSRange range = { orig, location - orig };
			*value = [string substringWithRange:range];
		}
		[self setScanLocation:location];
		return true;
	}

	return false;
}

- (bool)scanUpToCharactersFromSet:(NSCharacterSet*)stopSet
intoString:(NSString**)value
{
	return [self scanCharactersFromSet:[stopSet invertedSet] intoString:value];
}

enum ParseIntType {
	INT32_TYPE,
	INT64_TYPE,
	FLOAT_TYPE,
	DOUBLE_TYPE
};

/* This is to support scanInt, scanLongLong, scanFloat, and scanDouble. */
bool scanNumber(int numType, void *dest, NSScanner *self)
{
	NSCharacterSet* decimals = nil;
	NSString *string = [self string];
	NSLocale *locale = [self locale];
	NSIndex orig;
	NSIndex length = [string length];
	NSIndex location;
	NSUniChar thousandSep = ',';
	NSUniChar decimalSep = '.';
	NSUniChar exponentSep = 'e';
	NSUniChar plusChar = '+';
	NSUniChar minusChar = '-';
	NSUniChar *numChars;
	NSUniChar c;
	UErrorCode ec = U_ZERO_ERROR;
	UNumberFormat *numFmt;
	if ([self isAtEnd])
		return false;

	numFmt = unum_open(UNUM_DEFAULT, NULL, 0,
			[[locale localeIdentifier] UTF8String], NULL, &ec);

	unum_getSymbol(numFmt, UNUM_GROUPING_SEPARATOR_SYMBOL,
			&thousandSep, 1, &ec);
	unum_getSymbol(numFmt, UNUM_DECIMAL_SEPARATOR_SYMBOL,
			&decimalSep, 1, &ec);
	unum_getSymbol(numFmt, UNUM_EXPONENTIAL_SYMBOL,
			&exponentSep, 1, &ec);
	unum_getSymbol(numFmt, UNUM_MINUS_SIGN_SYMBOL,
			&minusChar, 1, &ec);
	unum_getSymbol(numFmt, UNUM_PLUS_SIGN_SYMBOL,
			&plusChar, 1, &ec);

	/* First skip the blank characters */
	[self scanCharactersFromSet:[self charactersToBeSkipped] intoString:NULL];

	/* Create the decimals set */

	decimals = [NSCharacterSet decimalDigitCharacterSet];

	orig = [self scanLocation];
	c = [string characterAtIndex:orig];
	if (c == minusChar || c == plusChar) {
		orig++;
	}

	for (location = orig; location < length; location++) {
		c = [string characterAtIndex:location];
		if ([decimals characterIsMember:c]) 
			continue;
		if (c == thousandSep || c == decimalSep || c == exponentSep)
			continue;

		/* If `c' is neither a decimal nor a thousand separator, break. */
		break;
	}
	if (location == orig)
		return false;

	numChars = malloc(sizeof(NSUniChar) * (location - orig));

	[string getCharacters:numChars range:(NSRange){orig, (location - orig)}];

	switch(numType)
	{
		case INT64_TYPE:
			*(int64_t*)dest = unum_parseInt64(numFmt, numChars,
					location - orig, NULL, &ec);
			break;
		case INT32_TYPE:
			*(int32_t*)dest = unum_parse(numFmt, numChars,
					location - orig, NULL, &ec);
			break;
		case FLOAT_TYPE:
			{
				double d;
				d = unum_parseDouble(numFmt, numChars,
						location - orig, NULL, &ec);
				if (d > FLT_MAX || d < FLT_MIN)
				{
					ec = U_ILLEGAL_ARGUMENT_ERROR;
					break;
				}
				*(float *)dest = d;
				break;
			}
		case DOUBLE_TYPE:
			*(double*)dest = unum_parseDouble(numFmt, numChars,
					location - orig, NULL, &ec);
			break;
	}

	[self setScanLocation:location];
	free(numChars);

	if (ec != U_ZERO_ERROR)
		return false;
	return true;
}

static inline int hexDigit(char ch)
{
	if (ch >= '0' && ch <= '9')
		return (ch - '0');
	if (ch >= 'A' && ch <= 'F')
		return (ch - 'A' + 10);
	if (ch >= 'a' && ch <= 'f')
		return (ch - 'a' + 10);
	return 0;
}

static inline bool ScanHexInteger(NSScanner *self, unsigned long long *result)
{
	unsigned long long val = 0;
	int i = 0;
	NSIndex scanLoc;
	NSUniChar chars[2 * sizeof(int)];

	// skip the leading 0x/0X
	if (![self scanString:@"0x" intoString:NULL]&&![self scanString:@"0X" intoString:NULL])
	{
		return false;
	}

	scanLoc = [self scanLocation];
	[[self string] getCharacters:chars range:NSMakeRange(scanLoc, sizeof(chars))];

	if (!isxdigit(chars[0]))
	{
		return false;
	}

	for (;; i++)
	{
		if (!isxdigit(chars[i % (sizeof(chars)/sizeof(chars[0]))]))
		{
			break;
		}
		val = (val << 4) + hexDigit(chars[i]);
	}
	[self setScanLocation:scanLoc + i];

	if (result != NULL)
	{
		*result = val;
	}
	return false;
}

- (bool)scanBool:(bool *)value
{
	NSCharacterSet *plusminus = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
	bool scanned = true;
	while (scanned)
	{
		[self scanCharactersFromSet:plusminus intoString:NULL];
		[self scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
	}

	return [self scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"123456789tTyY"] intoString:NULL];
}

- (bool)scanDouble:(double*)value
{
	return scanNumber(DOUBLE_TYPE, value, self);
}

- (bool) scanHexDouble:(double *)value
{
	double d = 0.0;

	[self scanCharactersFromSet:[self charactersToBeSkipped] intoString:NULL];

	if (![self scanString:@"0x" intoString:NULL] && ![self scanString:@"0X" intoString:NULL])
		return false;
	TODO; // scanHexDouble:
	return false;
}

- (bool)scanFloat:(float*)value
{
	return scanNumber(FLOAT_TYPE, value, self);
}

- (bool) scanHexFloat:(float *)value
{
	NSIndex idx = [self scanLocation];
	double d;

	if (![self scanHexDouble:&d] || (d > FLT_MAX))
	{
		[self setScanLocation:idx];
		return false;
	}
	*value = d;
	return true;
}

- (bool)scanInt:(int*)value
{
	return scanNumber(INT32_TYPE, value, self);
}

- (bool) scanHexInt:(unsigned int *)value
{
	unsigned long long val = 0;
	bool result = ScanHexInteger(self, &val);
	if (!result || val > UINT_MAX)
	{
		if (val > UINT_MAX && value != NULL)
			*value = UINT_MAX;
		return false;
	}
	*value = (unsigned int)val;
	return true;
}

- (bool) scanInteger:(NSInteger *)value
{
	if (sizeof(NSInteger) == sizeof(long long))
	{
		return [self scanLongLong:(long long*)value];
	}
	return [self scanInt:(int *)value];
}

- (bool)scanLongLong:(long long*)value
{
	return scanNumber(INT64_TYPE, value, self);
}

- (bool) scanHexLongLong:(unsigned long long *)value
{
	return ScanHexInteger(self, value);
}

- (bool)scanString:(NSString*)searchString intoString:(NSString**)value
{
	id string = [self string];
	NSIndex searchStringLength = [searchString length];
	NSRange range;
	unsigned int options;
	NSIndex location;

	/* First skip the blank characters */
	[self scanCharactersFromSet:[self charactersToBeSkipped] intoString:NULL];

	range.location = location = [self scanLocation];
	range.length = searchStringLength;

	/* Check if the searchString can be contained in the remained scanned
	   string. */
	if ([string length] < range.location + range.length)
	{
		return false;
	}

	options = NSAnchoredSearch;
	if (![self caseSensitive])
	{
		options |= NSCaseInsensitiveSearch;
	}

	if ([string compare:searchString options:options range:range]
			== NSOrderedSame)
	{
		[self setScanLocation:(range.location + range.length)];
		if (value)
		{
			*value = [searchString copy];
		}
		return true;
	}

	return false;
}

- (bool)scanUpToString:(NSString*)stopString intoString:(NSString**)value
{
	id string = [self string];
	int length = [string length];
	NSRange range, lastRange;
	unsigned int options = 0;
	NSIndex location;

	/* First skip the blank characters */
	[self scanCharactersFromSet:[self charactersToBeSkipped] intoString:NULL];

	if (![self caseSensitive])
	{
		options = NSCaseInsensitiveSearch;
	}

	range.location = location = [self scanLocation];
	range.length = length - location;
	lastRange = range;
	range = [string rangeOfString:stopString options:options range:range];

	if (range.length)
	{
		/* A match was found */
		[self setScanLocation:range.location];
		if (value)
		{
			range.length = range.location - location;
			range.location = location;
			*value = [string substringWithRange:range];
		}
		return true;
	}
	else
	{
		/* Return the remaining of the string as the result of scanning */
		[self setScanLocation:length];
		if (value)
		{
			*value = [string substringWithRange:lastRange];
		}
		return true;
	}

	return false;
}

- (bool)isAtEnd
{
	return [self scanLocation] >= [[self string] length];
}

- (void)setLocale:(NSLocale*)locale
{
	[self subclassResponsibility:_cmd];
}

- (NSLocale*)locale
{
	[self subclassResponsibility:_cmd];
	return nil;
}


@end /* NSScanner */
