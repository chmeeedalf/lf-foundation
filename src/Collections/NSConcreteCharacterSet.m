/*
 * Copyright (c) 2005-2012	Justin Hibbits
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

#include "internal.h"

#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSData.h>
#import "NSConcreteCharacterSet.h"
#import <unicode/ustring.h>
#include <stdlib.h>

/*
 * _ICUCharacterSet
 */
/*
 * This uses ICU to handle all the CharacterSet internals.  When interacting
 * with other sets, this will create temporary ICU versions of the other set.
 * It does waste memory, but the usage of non-ICU character sets should be very
 * low.
 */

@implementation _NSICUCharacterSet

- (id) init
{
	self = [super init];
	if (self != nil)
	{
		set = uset_openEmpty();
	}
	return self;
}

- (id) initWithRange:(NSRange)aRange inverted:(bool)inv
{
	self = [self init];
	if (self != nil)
	{
		uset_addRange(set, aRange.location, NSMaxRange(aRange));
	}
	[self applyInvert:inv];

	return self;
}

- (id) initWithString:(NSString *)string inverted:(bool)inv
{
	self = [super init];
	if (self != nil)
	{
		size_t len = [string length];
		for (NSIndex i = 0; i < len; i++)
		{
			uset_add(set, [string characterAtIndex:i]);
		}
	}
	[self applyInvert:inv];

	return self;
}

- (id) initWithPattern:(NSString *)_pattern inverted:(bool)inv
{
	NSUniChar		*pat;
	int32_t		patternLength;
	patternLength = [_pattern length];
	pat = malloc(patternLength);
	[_pattern getCharacters:pat range:NSMakeRange(0, patternLength)];
	set = uset_openPattern(pat, patternLength, NULL);
	[self applyInvert:inv];
	free(pat);
	return self;
}

- (id) initWithCharacterType:(uint32_t)_mask inverted:(bool)inv
{
	self = [self init];

	if (self != nil)
	{
		UErrorCode ec = U_ZERO_ERROR;
		uset_applyIntPropertyValue(set, UCHAR_GENERAL_CATEGORY, _mask, &ec);
	}
	[self applyInvert:inv];

	return self;
}

- (id) initWithMask:(uint32_t)_mask inverted:(bool)inv
{
	self = [self init];

	if (self != nil)
	{
		UErrorCode ec = U_ZERO_ERROR;
		uset_applyIntPropertyValue(set, UCHAR_GENERAL_CATEGORY_MASK, _mask, &ec);
	}
	[self applyInvert:inv];

	return self;
}

- (id) initWithProperty:(uint32_t)_mask inverted:(bool)inv
{
	self = [self init];

	if (self != nil)
	{
		UErrorCode ec = U_ZERO_ERROR;
		uset_applyIntPropertyValue(set, _mask, 1, &ec);
	}
	[self applyInvert:inv];

	return self;
}

- (id) initWithBitmapRepresentation:(NSData *)bitmap inverted:(bool)inv
{
	self = [self init];

	if (self != nil)
	{
		const uint8_t *bytes = [bitmap bytes];
		size_t len = [bitmap length];

		if (bytes != NULL)
		{
			for (size_t i = 0; i < (len * 8); i++)
			{
				if ((bytes[i >> 3] & (1 << (i & 7))) != 0)
				{
					uset_add(set, i);
				}
			}
		}
	}
	[self applyInvert:inv];
	return self;
}

- (void) applyInvert:(bool)inv
{
	if (inv)
	{
		uset_complement(set);
	}
}

- (void)dealloc
{
	uset_close(set);
}

- (bool)characterIsMember:(NSUniChar)aCharacter
{
	return uset_contains(set, aCharacter);
}

- (bool)longCharacterIsMember:(UTF32Char)aCharacter
{
	return uset_contains(set, aCharacter);
}

- (bool)hasMemberInPlane:(uint8_t)plane
{
	// Each plane is 65536 characters, 16 bits
	USet *testSet = uset_open(plane << 16, (plane + 1) << 16 - 1);
	bool isMember;

	isMember = uset_containsSome(set, testSet);
	uset_close(testSet);
	return isMember;
}

- (NSCharacterSet *)invertedSet
{
	_NSICUCharacterSet *newSet;

	newSet = [[[self class] alloc] init];
	uset_close(newSet->set);
	newSet->set = uset_clone(set);
	uset_complement(newSet->set);

	return newSet;
}

// Copying

- (id) copyWithZone:(NSZone*)zone
{
	_NSICUCharacterSet *newSet;

	newSet = [[_NSICUCharacterSet alloc] init];
	uset_close(newSet->set);
	newSet->set = uset_clone(set);
	
	return newSet;
}

/* Mutability.  Will be moved later... */

- (void) addCharactersInRange:(NSRange)r
{
	uset_addRange(set, r.location, NSMaxRange(r));
}

- (void) removeCharactersInRange:(NSRange)r
{
	uset_removeRange(set, r.location, NSMaxRange(r));
}

- (void) addCharactersInString:(NSString *)str
{
	UChar *chars = malloc(sizeof(UChar) * [str length]);

	[str getCharacters:chars range:NSMakeRange(0, [str length])];
	uset_addString(set, chars, [str length]);
}

- (void) removeCharactersInString:(NSString *)str
{
	UChar *chars = malloc(sizeof(UChar) * [str length]);

	[str getCharacters:chars range:NSMakeRange(0, [str length])];
	uset_removeString(set, chars, [str length]);
}

- (void) formIntersectionWithCharacterSet:(NSCharacterSet *)other
{
	_NSICUCharacterSet *otherSet;
	if (![other isKindOfClass:[self class]])
	{
		/* Create a temporary ICU character set to add to this set. */
		otherSet = [[_NSICUCharacterSet alloc] initWithBitmapRepresentation:[other bitmapRepresentation] inverted:false];
	}
	else
	{
		otherSet = (_NSICUCharacterSet *)other;
	}
	uset_retainAll(set, otherSet->set);
}

- (void) formUnionWithCharacterSet:(NSCharacterSet *)other
{
	_NSICUCharacterSet *otherSet;
	if (![other isKindOfClass:[self class]])
	{
		/* Create a temporary ICU character set to add to this set. */
		otherSet = [[_NSICUCharacterSet alloc] initWithBitmapRepresentation:[other bitmapRepresentation] inverted:false];
	}
	else
	{
		otherSet = (_NSICUCharacterSet *)other;
	}
	uset_addAll(set, otherSet->set);
}

- (void) invert
{
	[self applyInvert:true];
}

- (void) _setICUCharacterSet:(USet *)newSet
{
	uset_addAll(set, newSet);
}

@end /* _ICUCharacterSet */
