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

#import <Foundation/NSString.h>
#import "NSCoreString.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSLocale.h>
#include <stdlib.h>
#include <string.h>

#include "unicode/ucnv.h"

@implementation NSSimpleCString
@end

@implementation NSConstantString

-(id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (NSIndex)length
{
	return length;
}

- (NSUniChar)characterAtIndex:(NSIndex)index
{
	if (index < length)
	{
		return bytes[index];
	}
	return 0;
}

- (const char *)cStringUsingEncoding:(NSStringEncoding)enc
{
	switch (enc)
	{
		case NSASCIIStringEncoding:
		case NSUTF8StringEncoding:
			return bytes;
		default:
			return [super cStringUsingEncoding:enc];
	}
}

- (char *)_cstringPointer
{
	return (char *)bytes;
}
@end /* NXConstantString */

@implementation NSCoreString
{
	NSHashCode hash;
	UnicodeString *str;
	bool freeWhenDone;
	NSStringEncoding encoding;
}

- (id) init
{
	return [self initWithCString:NULL length:0];
}

- (id) initWithBytes:(const void *)bytes length:(NSIndex)length
	encoding:(NSStringEncoding)enc
{
	return [self initWithBytes:bytes length:length encoding:enc copy:true
		freeWhenDone:false];
}

- (id) initWithBytesNoCopy:(const void *)bytes length:(NSIndex)length
	encoding:(NSStringEncoding)enc freeWhenDone:(bool)flag
{
	return [self initWithBytes:bytes length:length encoding:enc copy:false
		freeWhenDone:flag];
}

- (id) initWithBytes:(const void *)bytes length:(unsigned long)length
	encoding:(NSStringEncoding)enc copy:(bool)copy freeWhenDone:(bool)flag
{
	encoding = NSUnicodeStringEncoding;
	try
	{
		str = new UnicodeString((const char *)bytes, length, [[NSString
				localizedNameOfStringEncoding:enc] UTF8String]);
	}
	catch (...)
	{
		/* Trap all exceptions, and return nil if string can't be created. */
	}
	if (str == NULL)
	{
		self = nil;
	}
	if (flag)
		free((void *)bytes);
	return self;
}

- (id) initWithCharacters:(const NSUniChar*)chars length:(NSIndex)length
{
	return [self initWithBytes:(const void *)chars length:length * sizeof(NSUniChar)
		encoding:NSUnicodeStringEncoding copy:true freeWhenDone:false];
}

- (id) initWithCharactersNoCopy:(const NSUniChar*)chars length:(NSIndex)length
	freeWhenDone:(bool)flag
{
	return [self initWithBytes:(const void *)chars length:length * sizeof(NSUniChar)
		encoding:NSUnicodeStringEncoding copy:false freeWhenDone:flag];
}

- (id) initWithCString:(const char*)byteString
{
	return [self initWithCString:byteString length:-1
		copy:true];
}

- (id) initWithCString:(const char*)byteString length:(NSIndex)length
{
	return [self initWithCString:byteString length:length copy:true];
}

- (id) initWithCString:(const char*)byteString length:(NSIndex)length
	  copy:(bool)flag
{
	return [self initWithBytes:(const void *)byteString length:length
		encoding:NSASCIIStringEncoding copy:flag freeWhenDone:false];
}

- (id) initWithCStringNoCopy:(const char*)byteString freeWhenDone:(bool)flag
{
	return [self initWithCStringNoCopy:byteString length:strlen(byteString)
		freeWhenDone:flag];
}

- (id) initWithCStringNoCopy:(const char*)byteString length:(NSIndex)length
	freeWhenDone:(bool)flag
{
	self = [self initWithBytes:byteString length:length
		encoding:NSASCIIStringEncoding copy:false freeWhenDone:flag];
	return self;
}

- (id) initWithString:(NSString*)aString
{
	size_t length = [aString length];

	NSUniChar *chars = new NSUniChar[length];
	[aString getCharacters:chars range:NSRange(0, length)];
	self = [self initWithCharacters:chars length:length];
	delete[] chars;
	return self;
}

- (id) initWithUnicodeString:(UnicodeString *)src
{
	str = new UnicodeString(*src);
	return self;
}

- (id) initWithData:(NSData*)data encoding:(NSStringEncoding)enc
{
	return [self initWithBytes:[data bytes] length:[data length] encoding:enc];
}

- (NSStringEncoding)fastestEncoding
{
	return encoding;
}

- (NSUniChar)characterAtIndex:(NSIndex)index
{
	return str->charAt(index);
}

- (void)getCharacters:(NSUniChar*)buffer range:(NSRange)aRange
{
	str->extract(aRange.location, aRange.length, (UChar *)buffer);
}

- (NSIndex) length
{
	return str->length();
}

- (UnicodeString *)_unicodeString
{
	return str;
}

@end // NSCoreString

@implementation NSCoreMutableString

+ (void) initialize
{
	if ([self class] == [NSCoreMutableString class])
	{
		class_addBehavior(self, [NSCoreString class]);
	}
}

- (id) initWithCapacity:(unsigned int)capacity
{
	str = new UnicodeString(capacity, 0, 0);
	return self;
}

-(void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString
{
	NSIndex len = [aString length];
	const UChar *others = new UChar[len];
	[aString getCharacters:(NSUniChar *)others range:NSRange(0, len)];
	str->replace(aRange.location, aRange.length, others, len);
	delete others;
}

- (void) dealloc
{
	delete str;
}

@end // NSCoreMutableString
