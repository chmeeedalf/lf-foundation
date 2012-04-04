/*
 * Copyright (c) 2004-2007,2009,2011-2012	Justin Hibbits
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

#include <Foundation/primitives.h>
#include <Foundation/NSString.h>
#include <unicode/uchar.h>

#define PUNCTUATION_MASK 0x200

/* Returns 1 for Unicode characters having the category 'Zl' or type
   'B', 0 otherwise. */

int NSStringCharIsLinebreak(NSUniChar ch)
{
	return u_charType(ch) == U_LINE_SEPARATOR;
}

/* Returns the titlecase Unicode characters corresponding to ch or just
   ch if no titlecase mapping is known. */

NSUniChar NSStringCharToTitlecase(register NSUniChar ch)
{
	return u_totitle(ch);
}

/* Returns 1 for Unicode characters having the category 'Lt', 0
   otherwise. */

int NSStringCharIsTitlecase(NSUniChar ch)
{
	return u_charType(ch) == U_TITLECASE_LETTER;
}

/* Returns the integer decimal (0-9) for Unicode characters having
   this property, -1 otherwise. */

int NSStringCharToDecimalDigit(NSUniChar ch)
{
	return u_charDigitValue(ch);
}

int NSStringCharIsDecimalDigit(NSUniChar ch)
{
	return u_charType(ch) == U_DECIMAL_DIGIT_NUMBER;
}

/* Returns 1 for Unicode characters having the bidirectional type
   'WS', 'B' or 'S' or the category 'Zs', 0 otherwise. */

int NSStringCharIsWhitespace(NSUniChar ch)
{
	return u_hasBinaryProperty(ch, UCHAR_WHITE_SPACE);
}

/* Returns 1 for Unicode characters having the category 'Ll', 0
   otherwise. */

int NSStringCharIsLowercase(NSUniChar ch)
{
	return u_hasBinaryProperty(ch, UCHAR_LOWERCASE);
}

/* Returns 1 for Unicode characters having the category 'Lu', 0
   otherwise. */

int NSStringCharIsUppercase(NSUniChar ch)
{
	return u_hasBinaryProperty(ch, UCHAR_UPPERCASE);
}

/* Returns the uppercase Unicode characters corresponding to ch or just
   ch if no uppercase mapping is known. */

NSUniChar NSStringCharToUppercase(NSUniChar ch)
{
	return u_toupper(ch);
}

/* Returns the lowercase Unicode characters corresponding to ch or just
   ch if no lowercase mapping is known. */

NSUniChar NSStringCharToLowercase(NSUniChar ch)
{
	return u_tolower(ch);
}

/* Returns 1 for Unicode characters having the category 'Ll', 'Lu', 'Lt',
   'Lo' or 'Lm',  0 otherwise. */

int NSStringCharIsAlpha(NSUniChar ch)
{
	return u_hasBinaryProperty(ch, UCHAR_ALPHABETIC);
}

int NSStringCharIsMasked(NSUniChar ch, uint32_t mask)
{
	if (mask == U_GC_P_MASK)
		return u_ispunct(ch);
	return 0;
}
