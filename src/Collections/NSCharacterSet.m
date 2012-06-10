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

#include <string.h>

#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSData.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSException.h>
#import <Foundation/NSResourceManager.h>

#import "NSConcreteCharacterSet.h"
#import "internal.h"

/*
   All these sets are ``masked'' sets--They use a mask on Unicode characters,
   rather than a bitmap.
 */
static _NSICUCharacterSet *alphanumericCharacterSet = nil;
static _NSICUCharacterSet *capitalizedLetterCharacterSet = nil;
static _NSICUCharacterSet *controlCharacterSet = nil;
static _NSICUCharacterSet *decimalDigitCharacterSet = nil;
static _NSICUCharacterSet *emptyCharacterSet = nil;
static _NSICUCharacterSet *illegalCharacterSet = nil;
static _NSICUCharacterSet *letterCharacterSet = nil;
static _NSICUCharacterSet *lowercaseLetterCharacterSet = nil;
static _NSICUCharacterSet *newlineCharacterSet = nil;
static _NSICUCharacterSet *nonBaseCharacterSet = nil;
static _NSICUCharacterSet *punctuationCharacterSet = nil;
static _NSICUCharacterSet *symbolCharacterSet = nil;
static _NSICUCharacterSet *uppercaseLetterCharacterSet = nil;
static _NSICUCharacterSet *whitespaceAndNewlineCharacterSet = nil;
static _NSICUCharacterSet *whitespaceCharacterSet = nil;

#define MASKED_CHAR_SET(mask, name) \
	@synchronized(self) { \
		if (name == nil) \
			name = [[_NSICUCharacterSet alloc] initWithMask:mask inverted:false]; \
	} \
	return name

#define PROPERTY_CHAR_SET(mask, name) \
	@synchronized(self) { \
		if (name == nil) \
			name = [[_NSICUCharacterSet alloc] initWithProperty:mask inverted:false]; \
	} \
	return name

#define CTYPE_CHAR_SET(mask, name) \
	@synchronized(self) { \
		if (name == nil) \
			name = [[_NSICUCharacterSet alloc] initWithCharacterType:mask inverted:false]; \
	} \
	return name

@implementation NSCharacterSet

// Cluster allocation

+ (id)allocWithZone:(NSZone*)zone
{
    return NSAllocateObject( (self == [NSCharacterSet class]) ?
	[_NSICUCharacterSet class] : (Class)self, 0, zone);
}

// Creating a Standard Character Set

+ (id)alphanumericCharacterSet
{
	PROPERTY_CHAR_SET(UCHAR_POSIX_ALNUM, alphanumericCharacterSet);
}

+ (NSCharacterSet *) capitalizedLetterCharacterSet
{
	MASKED_CHAR_SET(U_GC_LT_MASK, capitalizedLetterCharacterSet);
}

+ (id)controlCharacterSet
{
	CTYPE_CHAR_SET(U_CONTROL_CHAR, controlCharacterSet);
}

+ (id)decimalDigitCharacterSet
{
	CTYPE_CHAR_SET(U_DECIMAL_DIGIT_NUMBER, decimalDigitCharacterSet);
}

+ (id) decomposableCharacterSet
{
	TODO; // +[NSCharacterSet decomposableCharacterSet]
	return nil;
}

+ (NSCharacterSet *)illegalCharacterSet
{
	PROPERTY_CHAR_SET(UCHAR_ALPHABETIC, illegalCharacterSet);
}

+ (id)letterCharacterSet
{
	PROPERTY_CHAR_SET(UCHAR_ALPHABETIC, letterCharacterSet);
}

+ (id)lowercaseLetterCharacterSet
{
	PROPERTY_CHAR_SET(UCHAR_LOWERCASE, lowercaseLetterCharacterSet);
}

+ (id)newlineCharacterSet
{
	MASKED_CHAR_SET(U_GC_ZL_MASK, newlineCharacterSet);
}

+ (NSCharacterSet *) nonBaseCharacterSet
{
	MASKED_CHAR_SET(U_GC_M_MASK, nonBaseCharacterSet);
}

+ (id)symbolCharacterSet
{
	MASKED_CHAR_SET(U_GC_S_MASK, symbolCharacterSet);
}

+ (id)uppercaseLetterCharacterSet
{
	PROPERTY_CHAR_SET(UCHAR_UPPERCASE, uppercaseLetterCharacterSet);
}

+ (id)whitespaceAndNewlineCharacterSet
{
	PROPERTY_CHAR_SET(UCHAR_WHITE_SPACE, whitespaceAndNewlineCharacterSet);
}

+ (id)whitespaceCharacterSet
{
	PROPERTY_CHAR_SET(UCHAR_POSIX_BLANK, whitespaceCharacterSet);
}

+ (id)punctuationCharacterSet
{
	MASKED_CHAR_SET(U_GC_P_MASK, punctuationCharacterSet);
}

+ (id)emptyCharacterSet
{
	@synchronized(self) {
		if (emptyCharacterSet == nil)
			emptyCharacterSet = [[_NSICUCharacterSet alloc]
				initWithString:@"" inverted:false];
	}
	return emptyCharacterSet;
}

// Creating a Custom Character Set

+ (id)characterSetWithBitmapRepresentation:(NSData*)data
{
	return [[_NSICUCharacterSet alloc]
			initWithBitmapRepresentation:data inverted:false];
}

+ (id)characterSetWithCharactersInString:(NSString*)aString
{
	return [[_NSICUCharacterSet alloc] initWithString:aString inverted:false];
}

+ (id)characterSetWithPattern:(NSString *)pattern
{
	return [[_NSICUCharacterSet alloc] initWithPattern:pattern inverted:false];
}

+ (id)characterSetWithRange:(NSRange)aRange
{
	return [[_NSICUCharacterSet alloc] initWithRange:aRange inverted:false];
}

// Getting a Binary Representation

- (NSData*)bitmapRepresentation
{
	[self subclassResponsibility:_cmd];
	return nil;
}

// Testing Set Membership

- (bool)characterIsMember:(NSUniChar)aCharacter
{
	[self subclassResponsibility:_cmd];
	return false;
}

- (bool)longCharacterIsMember:(UTF32Char)aCharacter
{
	[self subclassResponsibility:_cmd];
	return false;
}

- (bool) isSupersetOfSet:(NSCharacterSet *)other
{
	NSData *thisBitmapData = [self bitmapRepresentation];
	NSData *otherBitmapData = [other bitmapRepresentation];

	const char *thisBitmap = [thisBitmapData bytes];
	const char *otherBitmap = [otherBitmapData bytes];

	NSUInteger len = MAX(thisBitmapData, otherBitmapData);
	for (NSUInteger i = 0; i < len; i++)
	{
		if ((thisBitmap[i] & otherBitmap[i]) != otherBitmap[i])
			return false;
	}
	return true;
}

- (bool) hasMemberInPlane:(uint8_t)plane
{
	NSMutableCharacterSet *testSet = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(plane << 16, 65536)];

	[testSet formIntersectionWithCharacterSet:self];

	return ![testSet isEqual:[NSCharacterSet emptyCharacterSet]];
}

// Inverting a Character Set

- (NSCharacterSet*)invertedSet
{
	return [[_NSICUCharacterSet alloc] initWithBitmapRepresentation:[self bitmapRepresentation] inverted:true];
}

// Copying

- (id) copyWithZone:(NSZone*)zone
{
	if (NSShouldRetainWithZone(self, zone))
	{
		return self;
	}
	else
	{
		id data = [self bitmapRepresentation];
		return [[_NSICUCharacterSet alloc] initWithBitmapRepresentation:data inverted:false];
	}
}

- (bool) isEqual:(id)other
{
	if (![other isKindOfClass:[NSCharacterSet class]])
	{
		return false;
	}

	NSData *bmrep = [self bitmapRepresentation];
	return (memcmp([bmrep bytes], [[other bitmapRepresentation] bytes], [bmrep length]) == 0);
}

@end /* CharacterSet */

@implementation NSMutableCharacterSet

+ (NSCharacterSet*)alphanumericCharacterSet
{
	return [[NSCharacterSet alphanumericCharacterSet] mutableCopy];
}

+ (NSCharacterSet*)controlCharacterSet
{
	return [[NSCharacterSet controlCharacterSet] mutableCopy];
}

+ (NSCharacterSet*)decimalDigitCharacterSet
{
	return [[NSCharacterSet decimalDigitCharacterSet] mutableCopy];
}

+ (NSCharacterSet *)illegalCharacterSet
{
	return [[NSCharacterSet illegalCharacterSet] mutableCopy];
}

+ (NSCharacterSet*)letterCharacterSet
{
	return [[NSCharacterSet letterCharacterSet] mutableCopy];
}

+ (NSCharacterSet*)lowercaseLetterCharacterSet
{
	return [[NSCharacterSet lowercaseLetterCharacterSet] mutableCopy];
}

+ (NSCharacterSet*)newlineCharacterSet
{
	return [[NSCharacterSet newlineCharacterSet] mutableCopy];
}

+ (NSCharacterSet*)symbolCharacterSet
{
	return [[NSCharacterSet symbolCharacterSet] mutableCopy];
}

+ (NSCharacterSet*)uppercaseLetterCharacterSet
{
	return [[NSCharacterSet uppercaseLetterCharacterSet] mutableCopy];
}

+ (NSCharacterSet*)whitespaceAndNewlineCharacterSet
{
	return [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
}

+ (NSCharacterSet*)whitespaceCharacterSet
{
	return [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
}

+ (NSCharacterSet*)punctuationCharacterSet
{
	return [[NSCharacterSet punctuationCharacterSet] mutableCopy];
}

+ (NSCharacterSet*)emptyCharacterSet
{
	return [_NSICUCharacterSet new];
}

- (void) addCharactersInRange:(NSRange)r
{
	[self subclassResponsibility:_cmd];
}

- (void) removeCharactersInRange:(NSRange)r
{
	[self subclassResponsibility:_cmd];
}

- (void) addCharactersInString:(NSString *)str
{
	[self subclassResponsibility:_cmd];
}

- (void) removeCharactersInString:(NSString *)str
{
	[self subclassResponsibility:_cmd];
}

- (void) formIntersectionWithCharacterSet:(NSCharacterSet *)other
{
	[self subclassResponsibility:_cmd];
}

- (void) formUnionWithCharacterSet:(NSCharacterSet *)other
{
	[self subclassResponsibility:_cmd];
}

- (void) invert
{
	[self subclassResponsibility:_cmd];
}

@end
