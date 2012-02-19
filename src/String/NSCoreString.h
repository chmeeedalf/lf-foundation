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
   ConcreteString.h

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

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

#import <Foundation/NSArray.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#ifdef __cplusplus
#include "unicode/unistr.h"
using icu::UnicodeString;
#else
typedef struct UnicodeString UnicodeString;
#endif


/*
 * Classes used to allocate concrete instances upon initWith* methods
 */

enum {
	kStringEncodingFromData = -1,
};

/* Used for allocating immutable instances from NSString */
@interface NSTemporaryString : NSObject
{
	NSZone *_zone;
	id next;
}

+ allocWithZone:(NSZone*)zone;
- (NSZone*)zone;

/* initWith* methods from NSString */

- init;
- initWithCharacters:(const NSUniChar*)chars length:(NSIndex)length;
- initWithCharactersNoCopy:(const NSUniChar*)chars length:(NSIndex)length 
	freeWhenDone:(bool)flag;
- initWithString:(NSString*)aString;
- initWithFormat:(NSString*)format, ...;
- initWithFormat:(NSString*)format arguments:(va_list)argList;
- initWithFormat:(NSString*)format
		  locale:(NSLocale*)dictionary, ...;
- initWithFormat:(NSString*)format 
		  locale:(NSLocale*)dictionary arguments:(va_list)argList;	
- initWithData:(NSData*)data encoding:(NSStringEncoding)encoding;

@end

#define NSAssertMutable() \
	NSAssert(self->mutable == true, @"Cannot mutate contents of immutable string.")
/*
   The base of the actual string classes.  This contains common instance
   variables shared between the 3 subclasses:
   - Core8BitString	- All 8-bit strings
   - Core16BitString - UTF-16
   - Core32BitString - UTF-32 (Full unicode)
 */
@interface NSCoreString : NSString

- initWithCharacters:(const NSUniChar*)chars length:(NSIndex)length;
- initWithCharactersNoCopy:(const NSUniChar*)chars length:(NSIndex)length 
	freeWhenDone:(bool)flag;
- initWithCString:(const char*)byteString;
- initWithCString:(const char*)byteString length:(NSIndex)length;
- initWithCString:(const char*)byteString length:(NSIndex)length
	copy:(bool)copy;
- initWithCStringNoCopy:(const char*)byteString freeWhenDone:(bool)flag;
- initWithCStringNoCopy:(const char*)byteString length:(NSIndex)length 
	freeWhenDone:(bool)flag;
- initWithString:(NSString*)aString;
- initWithData:(NSData*)data encoding:(NSStringEncoding)encoding;
- initWithBytes:(const void *)bytes length:(unsigned long)length
	encoding:(NSStringEncoding)enc copy:(bool)copy freeWhenDone:(bool)flag;
- initWithUnicodeString:(UnicodeString *)src;
- (UnicodeString *)_unicodeString;

@end	// NSCoreString

@interface NSCoreMutableString	:	NSMutableString
{
	NSHashCode hash;
	UnicodeString *str;
	bool freeWhenDone;
	NSStringEncoding encoding;
}
-(void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString;
@end

/*
   vim:syntax=objc:
 */
