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

/*
   NSString.m

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

#import <Foundation/NSString.h>
#import "NSCoreString.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSScanner.h>
#include <ctype.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unicode/ustring.h>
#include <unicode/ustdio.h>
#include <unicode/ucnv.h>
#include <unicode/ucol.h>
#include <unicode/ucsdet.h>
#include <unicode/unorm.h>
#include <unicode/usearch.h>

#include "internal.h"

#define VERIFY_RANGE(range) \
	do { \
	if (NSMaxRange(range) > [self length]) \
	{ \
		@throw [NSRangeException exceptionWithReason:[NSString stringWithFormat: \
				@"range (%d,%d) in string %x of length %d in method %@", \
				range.location, range.length, self, [self length], NSStringFromSelector(_cmd)] \
			userInfo:nil]; \
	}\
	} while (0)


static int _StringFileWrite(void *cookie, const char *chars, int len)
{
	NSMutableString *outStr = (__bridge id)cookie;
	// TODO: _StringFileWrite() - This should get the encoding from the input
	// cookie, not assume UTF8
	NSString *tempStr = [[NSString alloc] initWithBytesNoCopy:chars length:len encoding:NSUTF8StringEncoding freeWhenDone:false];
	[outStr appendString:tempStr];
	return len;
}

static int32_t do_write_string(const void *p, UChar *chars, int32_t len)
{
	NSString *s = [(__bridge id)p description];

	if (chars == NULL)
	{
		return [s length];
	}
	[s getCharacters:chars range:NSMakeRange(0,MIN([s length], (unsigned int)len))];

	return [s length];
}

static NSString* Avsprintf(NSString* format, NSLocale *locale, va_list args)
{
	FILE *strFile;
	UFILE *uniFile;
	UChar *patternSpecification __cleanup(cleanup_pointer) =
		malloc(([format length] + 1) * sizeof(UChar));
	NSMutableString *str;

	strFile = fwopen((__bridge const void *)str, _StringFileWrite);
	uniFile = u_finit(strFile, [[locale localeIdentifier] UTF8String], "UTF-8");

	u_register_printf_handler('@', do_write_string);

	if (uniFile == NULL)
	{
		return nil;
	}
	str = [NSMutableString new];
	[format getCharacters:patternSpecification range:NSMakeRange(0, [format length])];
	patternSpecification[[format length]] = 0;

	u_vfprintf_u(uniFile, patternSpecification, args);
	u_fclose(uniFile);
	fclose(strFile);
	return str;
}

static UCollator *_CollatorFromOptions(unsigned long mask, NSLocale *locale)
{
	const char *locIdent = [[locale localeIdentifier] cStringUsingEncoding:NSUTF8StringEncoding];
	UErrorCode ec = U_ZERO_ERROR;
	UCollator *coll = ucol_open(locIdent, &ec);
	if (mask&NSNumericSearch)
		ucol_setAttribute(coll, UCOL_NUMERIC_COLLATION, UCOL_ON, &ec);
	ucol_setStrength(coll, (mask&NSDiacriticInsensitiveSearch)?UCOL_PRIMARY:UCOL_SECONDARY);
	if (mask & NSCaseInsensitiveSearch)
		ucol_setAttribute(coll, UCOL_CASE_LEVEL, UCOL_OFF, &ec);
	if (mask & NSWidthInsensitiveSearch)
		ucol_setAttribute(coll, UCOL_NORMALIZATION_MODE, UCOL_ON, &ec);
	if (U_FAILURE(ec))
	{
		ucol_close(coll);
		return NULL;
	}
	return coll;
}

/* Collator iterator */
struct StringIterContext
{
	__unsafe_unretained NSString *str;
	IMP iterMethod;
};

static UBool _stringHasPrevious(UCharIterator *iter)
{
	return iter->start < iter->index;
}

static UBool _stringHasNext(UCharIterator *iter)
{
	return iter->index < iter->limit;
}

static int32_t _stringGetIndex(UCharIterator *iter, UCharIteratorOrigin origin)
{
	switch (origin)
	{
		case UITER_ZERO:
			return iter->index;
		case UITER_LIMIT:
			return iter->index - iter->limit;
		case UITER_START:
			return iter->index - iter->start;
		case UITER_CURRENT:
			return 0;
		case UITER_LENGTH:
			return iter->length - (iter->index - iter->start);
	}
	return 0;
}

static int32_t _stringMove(UCharIterator *iter, int32_t delta, UCharIteratorOrigin origin)
{
	switch (origin)
	{
		case UITER_ZERO:
			iter->index = delta;
			break;
		case UITER_LIMIT:
			iter->index = iter->limit + delta;
			break;
		case UITER_START:
			iter->index = iter->start + delta;
			break;
		case UITER_CURRENT:
			iter->index += delta;
			break;
		case UITER_LENGTH:
			iter->index = iter->start + iter->length - delta;
			break;
	}
	if (iter->index >= iter->limit)
		iter->index = iter->limit - 1;
	if (iter->index < iter->start)
		iter->index = iter->start;
	return iter->index;
}

static UChar32 _stringGetCurrent(UCharIterator *iter)
{
	const struct StringIterContext *ctx = iter->context;
	return (UChar32)ctx->iterMethod(ctx->str, @selector(characterAtIndex:), iter->index);
}

static UChar32 _stringGetNext(UCharIterator *iter)
{
	const struct StringIterContext *ctx = iter->context;
	if (iter->index >= iter->limit)
		return U_SENTINEL;
	UChar ch =  (UChar32)ctx->iterMethod(ctx->str, @selector(characterAtIndex:), iter->index);
	iter->index++;
	return ch;
}

static UChar32 _stringGetPrevious(UCharIterator *iter)
{
	const struct StringIterContext *ctx = iter->context;
	if (iter->index <= iter->start)
		return U_SENTINEL;
	iter->index--;
	UChar ch =  (UChar32)ctx->iterMethod(ctx->str, @selector(characterAtIndex:), iter->index);
	return ch;
}

static uint32_t _stringGetState(const UCharIterator *iter)
{
	// DO NOTHING
	return 0;
}

static void _stringSetState(UCharIterator *iter, uint32_t state, UErrorCode *ec)
{
	// DO NOTHING
	return;
}

static void _CreateUCharIterFromString(NSString *str, UCharIterator *iter, NSRange r)
{
	struct StringIterContext *ctx = malloc(sizeof(*ctx));
	ctx->str = str;
	ctx->iterMethod = [str methodForSelector:@selector(characterAtIndex:)];
	memset(iter, 0, sizeof(*iter));
	iter->context = ctx;
	iter->start = r.location;
	iter->length = r.length;
	iter->index = iter->start;
	iter->limit = NSMaxRange(r);
	iter->hasPrevious = _stringHasPrevious;
	iter->hasNext = _stringHasNext;
	iter->getIndex = _stringGetIndex;
	iter->current = _stringGetCurrent;
	iter->next = _stringGetNext;
	iter->previous = _stringGetPrevious;
	iter->move = _stringMove;
	iter->getState = _stringGetState;
	iter->setState = _stringSetState;
}

static void _DestroyUCharIterWithString(UCharIterator *iter)
{
	free((void *)iter->context);
}

static void _ResetIter(UCharIterator *iter)
{
	iter->index = iter->start;
}

/***************************
 * NSString abstract class
 ***************************/

static Class StringClass;
static Class MutableStringClass;

@implementation NSString

+ (void) initialize
{
	StringClass = [NSString class];
	MutableStringClass = [NSMutableString class];
}

+ (id)allocWithZone:(NSZone *)zone
{
	return (self == StringClass) ?
		[NSTemporaryString allocWithZone:zone]
		: NSAllocateObject(self, 0, zone);
}

+(id)localizedStringWithFormat:(NSString *)format,...
{
	va_list ap;
	NSString *ret;

	if (format == nil)
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"Nil format argument" userInfo:nil];
	}

	va_start(ap, format);
	ret = [[self allocWithZone:NULL] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
	va_end(ap);
	return ret;
}

+ (id)stringWithFormat:(NSString*)format locale:(NSLocale *)locale,...
{
	va_list va;
	NSString* string;

	va_start(va, locale);
	string = [[self alloc] initWithFormat:format
			locale:locale arguments:va];
	va_end(va);
	return string;
}

+ (id)string
{
	return @"";
}

+ (id)stringWithCharacters:(const NSUniChar*)chars
length:(NSUInteger)length
{
	return [[self alloc] initWithCharacters:chars length:length];
}

+ (id)stringWithCharactersNoCopy:(NSUniChar*)chars
length:(NSUInteger)length freeWhenDone:(bool)flag
{
	return [[self alloc] initWithCharactersNoCopy:chars
			length:length freeWhenDone:flag];
}

+ (id)stringWithString:(NSString*)aString
{
	return [[self alloc] initWithString:aString];
}

+ (id)stringWithCString:(const char*)byteString
{
	return [[self class] stringWithCString:byteString encoding:[self defaultCStringEncoding]];
}

+ (id)stringWithUTF8String:(const char *)byteString
{
	return [[self alloc] initWithCString:byteString
			encoding:NSUTF8StringEncoding];
}

+ (id)stringWithCString:(const char *)byteString encoding:(NSStringEncoding)enc
{
	return [[self alloc] initWithCString:byteString encoding:enc];
}

+ (id)stringWithFormat:(NSString*)format,...
{
	va_list va;
	NSString* string;

	va_start(va, format);
	string = [[self alloc] initWithFormat:format arguments:va];
	va_end(va);
	return string;
}

+ (id)stringWithFormat:(NSString*)format arguments:(va_list)argList
{
	return [[self alloc] initWithFormat:format
			arguments:argList];
}

+ (id) stringWithContentsOfURL:(NSURL *)url
					  encoding:(NSStringEncoding)enc
					  	 error:(NSError **)errp
{
	return [[self alloc] initWithContentsOfURL:url encoding:enc error:errp];
}

- (bool) writeToURL:(NSURL *)uri atomically:(bool)atomic encoding:(NSStringEncoding)enc error:(NSError **)err
{
	return [[self dataUsingEncoding:enc allowLossyConversion:false] writeToURL:uri 
							options:NSDataWritingAtomic
							  error:err];
}

/* Getting a string's length */

- (NSUInteger)length
{
	[self subclassResponsibility:_cmd];
	return 0;
}

/* Accessing characters	*/

- (NSUniChar)characterAtIndex:(NSUInteger)index
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (void)getCharacters:(NSUniChar*)buffer
{
	NSRange range = NSMakeRange(0, [self length]);
	[self getCharacters:buffer range:range];
}

- (void)getCharacters:(NSUniChar*)buffer range:(NSRange)aRange
{
	NSUInteger i = 0;
	typedef NSUniChar (*UIMP)(id, SEL, NSUInteger);
	UIMP imp = (UIMP)[self methodForSelector:@selector(characterAtIndex:)];

	VERIFY_RANGE(aRange);

	for (i = 0; i < aRange.length; i++)
	{
		buffer[i] = (NSUniChar)(*imp)(self, @selector(characterAtIndex:),
				aRange.location + i);
	}
}

/* Combining strings */

- (NSString *)stringByAppendingFormat:(NSString *)format,...
{
	va_list ap;
	NSString *newStr;
	va_start(ap, format);
	newStr = [self stringByAppendingString:[NSString stringWithFormat:format
							   arguments:ap]];
	va_end(ap);
	return newStr;
}

- (NSString*)stringByAppendingString:(NSString*)aString
{
	NSUInteger len = [self length];
	NSUInteger aLen = [aString length];
	NSUInteger length = len + aLen;

	if (len == 0 && aLen == 0)
	{
		return @"";
	}

	NSUniChar *chars = malloc(length * sizeof(NSUniChar));
	if (chars == NULL)
	{
		@throw [NSMemoryException
			exceptionWithReason:@"Out of Memory creating string." userInfo:nil];
	}
	[self getCharacters:chars range:NSMakeRange(0, len)];
	[aString getCharacters:&chars[len] range:NSMakeRange(0, aLen)];
	return [NSString stringWithCharactersNoCopy:chars length:length freeWhenDone:true];
}

- (NSString *)stringByPaddingToLength:(size_t)len withString:(NSString *)pad startingAtIndex:(NSUInteger)startIdx
{
	NSMutableString *outStr;
	size_t padLength = [pad length];

	if (len < [self length])
	{
		return [self substringWithRange:NSMakeRange(0, len)];
	}

	outStr = [NSMutableString stringWithString:self];
	if (startIdx != 0)
	{
		[outStr appendString:[pad substringWithRange:NSMakeRange(startIdx, [pad length] - startIdx)]];
	}
	while ([outStr length] + padLength < len)
	{
		[outStr appendString:pad];
	}
	if ([outStr length] < len)
	{
		[outStr appendString:[pad substringWithRange:NSMakeRange(0, len - [outStr length])]];
	}
	return outStr;
}

- (NSString *)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)str
{
	NSMutableString *mutStr = [NSMutableString stringWithString:self];
	[mutStr replaceCharactersInRange:range withString:str];
	return mutStr;
}

- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)str withString:(NSString *)newStr
	options:(NSStringCompareOptions)options range:(NSRange)range
{
	NSMutableString *mutStr = [NSMutableString stringWithString:self];
	[mutStr replaceOccurrencesOfString:str withString:newStr options:options range:range];
	return mutStr;
}

- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)str withString:(NSString *)newStr
{
	return [self stringByReplacingOccurrencesOfString:str withString:newStr options:0 range:NSMakeRange(0, [self length])];
}

- (NSString *)stringByTrimmingCharactersInSet:(NSCharacterSet *)set
{
	NSRange r = {0, 0};
	NSRange r2 = {0, 0};
	r = [self rangeOfCharacterFromSet:set options:NSAnchoredSearch];
	r.location = r.length;
	r.length = [self length] - r.location;
	r2 = [self rangeOfCharacterFromSet:set options:(NSAnchoredSearch | NSBackwardsSearch) range:r];
	r.length -= r2.length;
	return [self substringWithRange:r];
}
/* Dividing strings */

- (NSArray *)componentsSeparatedByCharactersInSet:(NSCharacterSet *)set
{
	NSMutableArray* components = [NSMutableArray array];
	NSScanner *scan = [[NSScanner alloc] initWithString:self];
	NSString *temp;

	while (![scan isAtEnd])
	{
		[scan scanUpToCharactersFromSet:set intoString:&temp];
		[scan scanCharactersFromSet:set intoString:NULL];
		[components addObject:temp];
	}
	return components;
}

- (NSArray*)componentsSeparatedByString:(NSString*)separator
{
	NSUInteger first = 0, last = 0;
	NSUInteger slen = [separator length];
	NSMutableArray* components = [NSMutableArray array];

	while((first = [self indexOfString:separator fromIndex:last])
			!= NSNotFound)
	{
		NSRange range = NSMakeRange(last, first - last);

		[components addObject:[self substringWithRange:range]];
		last = first + slen;
	}

	if([self length] >= last)
	{
		NSString* lastComponent = [self substringFromIndex:last];
		[components addObject:lastComponent];
	}
	return components;
}

- (NSString*)substringWithRange:(NSRange)aRange
{
	NSUniChar * buf;

	VERIFY_RANGE(aRange);

	if (aRange.length == 0)
	{
		return @"";
	}

	buf = malloc(sizeof(NSUniChar) * (aRange.length + 1));

	[self getCharacters:buf range:aRange];
	return [NSString stringWithCharactersNoCopy:buf length:aRange.length freeWhenDone:true];
}

- (NSString*)substringFromIndex:(NSUInteger)index
{
	NSRange range = NSMakeRange(index, [self length] - index);

	return [self substringWithRange:range];
}

- (NSString*)substringToIndex:(NSUInteger)index
{
	NSRange range = {0, index};

	return [self substringWithRange:range];
}

/* Finding characters and substrings */

- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)aSet
{
	NSRange range = NSMakeRange(0, [self length]);

	return [self rangeOfCharacterFromSet:aSet options:0 range:range];
}

- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)aSet
	options:(NSStringCompareOptions)mask
{
	NSRange range = NSMakeRange(0, [self length]);

	return [self rangeOfCharacterFromSet:aSet options:mask range:range];
}

static inline bool SetHasCharacter(NSCharacterSet *set, NSUniChar c, bool insensitive, IMP imp)
{
	SEL sel = @selector(characterIsMember:);
	return ((*imp)(set, sel, c) ||
		(insensitive &&
		((NSStringCharIsLowercase(c) &&
		(*imp)(set, sel, NSStringCharToUppercase(c))) ||
		(NSStringCharIsUppercase(c) &&
		(*imp)(set, sel, NSStringCharToLowercase(c))))));
}

- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet*)aSet
	options:(NSStringCompareOptions)mask range:(NSRange)aRange
{
	NSUInteger i = 0;
	NSUInteger begin;
	NSUInteger end;
	int delta;
	SEL characterIsMemberSel = @selector(characterIsMember:);
	IMP imp = [aSet methodForSelector:characterIsMemberSel];

	VERIFY_RANGE(aRange);

	if (mask & NSBackwardsSearch)
	{
		begin = aRange.location + aRange.length - 1;
		end = aRange.location - 1;
		delta = -1;
	}
	else
	{
		begin = aRange.location;
		end = NSMaxRange(aRange);
		delta = 1;
	}
	for (i = begin; i != end; i = i + delta)
	{
		NSUniChar c = [self characterAtIndex:i];

		if (SetHasCharacter(aSet, c, mask & NSCaseInsensitiveSearch, imp))
		{
			begin = i;
			while (SetHasCharacter(aSet, c, mask & NSCaseInsensitiveSearch, imp))
			{
				i++;
				c = [self characterAtIndex:i];
			}
			break;
		}
		else
		{
			if (mask & NSAnchoredSearch)
				return NSMakeRange(0, 0);
		}
	}
	if (mask & NSBackwardsSearch)
	{
		return NSMakeRange(i + 1, begin - i);
	}
	else
	{
		return NSMakeRange(begin, i - begin);
	}
}

- (NSRange)rangeOfString:(NSString*)string
{
	NSRange range = NSMakeRange(0, [self length]);

	return [self rangeOfString:string options:0 range:range];
}

- (NSRange)rangeOfString:(NSString*)string options:(NSStringCompareOptions)mask
{
	NSRange range = NSMakeRange(0, [self length]);

	return [self rangeOfString:string options:mask range:range];
}

- (NSRange)rangeOfString:(NSString*)aString
	options:(NSStringCompareOptions)mask range:(NSRange)aRange
{
	return [self rangeOfString:aString options:mask range:aRange locale:nil];
}

-(NSRange)rangeOfString:(NSString *)aString
	options:(NSStringCompareOptions)mask range:(NSRange)aRange locale:(NSLocale *)locale
{
	NSRange range = NSMakeRange(0, 0);

	VERIFY_RANGE(aRange);

	NSUInteger a = [aString length];

	if (!a || aRange.length < a)
	{
		return range;
	}

	if ((mask & NSAnchoredSearch) || (aRange.length == a))
	{
		range.location = aRange.location +
			((mask & NSBackwardsSearch) ? aRange.length - a : 0);
		range.length = a;

		if ([self compare:aString options:mask range:range locale:locale] == NSOrderedSame)
		{
			return range;
		}
		else
		{
			return NSMakeRange(0,0);
		}
	}

	UCollator *coll = _CollatorFromOptions(mask, locale);
	UChar *myChars __cleanup(cleanup_pointer) = malloc(sizeof(UChar) * aRange.length);
	UChar *otherChars __cleanup(cleanup_pointer) = malloc(sizeof(UChar) * a);
	UErrorCode ec = U_ZERO_ERROR;

	[self getCharacters:myChars range:aRange];
	[aString getCharacters:otherChars range:NSMakeRange(0, a)];

	UStringSearch *search = usearch_openFromCollator(otherChars, a, myChars, aRange.length, coll, NULL, &ec);

	if (U_SUCCESS(ec))
	{
		int32_t start;
		if (mask & NSBackwardsSearch)
		{
			start = usearch_last(search, &ec);
		}
		else
		{
			start = usearch_first(search, &ec);
		}
		if (start != USEARCH_DONE)
			range = NSMakeRange(start + aRange.location, a);
	}

	return range;
}

- (NSUInteger)indexOfString:(NSString*)substring
{
	NSRange range = NSMakeRange(0, [self length]);

	range = [self rangeOfString:substring options:0 range:range];
	return range.length ? range.location : NSNotFound;
}

- (NSUInteger)indexOfString:(NSString*)substring fromIndex:(NSUInteger)index
{
	NSRange range = NSMakeRange(index, [self length]-index);

	range = [self rangeOfString:substring options:0 range:range];
	return range.length ? range.location : NSNotFound;
}

- (NSUInteger)indexOfString:(NSString*)substring range:(NSRange)range
{
	range = [self rangeOfString:substring options:0 range:range];
	return range.length ? range.location : NSNotFound;
}

- (NSRange) lineRangeForRange:(NSRange)inRange
{
	NSUInteger start;
	NSUInteger end;
	[self getLineStart:&start end:&end contentsEnd:NULL forRange:inRange];
	return NSMakeRange(start, end - start);
}

- (NSRange) paragraphRangeForRange:(NSRange)inRange
{
	NSUInteger start;
	NSUInteger end;
	[self getParagraphStart:&start end:&end contentsEnd:NULL forRange:inRange];
	return NSMakeRange(start, end - start);
}

- (void) enumerateLinesUsingBlock:(void (^)(NSString *, bool *))block
{
	NSScanner *scanner = [NSScanner scannerWithString:self];
	NSCharacterSet *chars = [NSCharacterSet newlineCharacterSet];
	bool stop = false;

	while (![scanner isAtEnd] && !stop)
	{
		NSString *s;
		if ([scanner scanUpToCharactersFromSet:chars intoString:&s])
		{
			block(s, &stop);
		}
		[scanner scanCharactersFromSet:chars intoString:NULL];
	}
}

- (void) enumerateSubstringsInRange:(NSRange)range options:(NSStringEnumerationOptions)opts usingBlock:(void (^)(NSString *, NSRange, NSRange, bool *))block
{
	TODO; // -[NSString enumerateSubstringsInRange:options:usingBlock:]
}

/* Identifying and comparing strings */

- (NSComparisonResult)caseInsensitiveCompare:(NSString*)aString
{
	NSRange range = NSMakeRange(0, [self length]);

	return [self compare:aString options:NSCaseInsensitiveSearch range:range];
}

- (NSComparisonResult)compare:(NSString *)aString
{
	NSRange range = NSMakeRange(0, [self length]);

	return [self compare:aString options:0 range:range];
}

- (NSComparisonResult)compare:(NSString*)aString options:(NSStringCompareOptions)mask
{
	NSRange range = NSMakeRange(0, [self length]);

	return [self compare:aString options:mask range:range];
}

- (NSComparisonResult)compare:(NSString*)aString
options:(NSStringCompareOptions)mask range:(NSRange)aRange
{
	return [self compare:aString options:mask range:aRange locale:nil];
}

- (NSComparisonResult)compare:(NSString*)aString options:(NSStringCompareOptions)mask
					  range:(NSRange)aRange locale:(NSLocale *)locale
{
	UErrorCode ec = U_ZERO_ERROR;
	UCollator *coll;
	
	mask &= (NSCaseInsensitiveSearch | NSLiteralSearch | NSNumericSearch);
	coll = _CollatorFromOptions(mask, locale);

	UCharIterator thisIter;
	UCharIterator otherIter;
	_CreateUCharIterFromString(self, &thisIter, aRange);
	_CreateUCharIterFromString(aString, &otherIter, NSMakeRange(0, [aString length]));

	NSComparisonResult result = (NSComparisonResult)ucol_strcollIter(coll, &thisIter, &otherIter, &ec);
	if (result == NSOrderedSame && (mask & NSForcedOrderingSearch))
	{
		ucol_close(coll);
		coll = _CollatorFromOptions(0, locale);
		_ResetIter(&thisIter);
		_ResetIter(&otherIter);
		result = (NSComparisonResult)ucol_strcollIter(coll, &thisIter, &otherIter, &ec);
	}
	_DestroyUCharIterWithString(&thisIter);
	_DestroyUCharIterWithString(&otherIter);
	ucol_close(coll);
	return result;

}

- (bool)hasPrefix:(NSString*)aString
{
	NSUInteger mLen = [self length];
	NSUInteger aLen = [aString length];
	NSRange range = {0, aLen};

	if (aLen > mLen)
	{
		return false;
	}

	return [self compare:aString options:0 range:range] == NSOrderedSame;
}

- (bool)hasSuffix:(NSString*)aString
{
	NSUInteger mLen = [self length];
	NSUInteger aLen = [aString length];
	NSRange range = {mLen-aLen, aLen};

	if (aLen > mLen)
	{
		return false;
	}

	return [self compare:aString options:0 range:range] == NSOrderedSame;
}

- (bool)isEqual:(id)anObject
{
	if (self == anObject)
	{
		return true;
	}

	if ([anObject isKindOfClass:[NSString class]])
	{
		NSRange range = {0, [self length]};
		return [self compare:anObject options:0 range:range] == NSOrderedSame;
	}

	return false;
}

- (bool)isEqualToString:(NSString*)aString
{
	NSRange range = {0, [self length]};

	if (self == aString)
	{
		return true;
	}

	return [self compare:aString options:0 range:range] == NSOrderedSame;
}

- (NSHashCode)hash
{
	NSHashCode hash = 0, hash2;
	NSUInteger i, n = [self length];

	for(i = 0; i < n; i++)
	{
		hash <<= 4;
		// UNICODE - must use a for independent of composed characters
		hash += [self characterAtIndex:i];
		if((hash2 = hash & 0xf0000000))
		{
			hash ^= (hash2 >> 24) ^ hash2;
		}
	}

	return hash;
}

/* Getting a shared prefix */

- (NSString*)commonPrefixWithString:(NSString*)aString
	options:(NSStringCompareOptions)mask
{
	// ENCODINGS - this code applies to the system's default encoding
	NSRange range = {0, 0};
	NSUInteger mLen;
	NSUInteger aLen;
	NSUInteger i;

	mLen = [self length];
	aLen = [aString length];

	for (i = 0; i < mLen && i < aLen; i++)
	{
		NSUniChar c1 = [self characterAtIndex:i];
		NSUniChar c2 = [self characterAtIndex:i];

		if ((c1 != c2) && ((mask & NSCaseInsensitiveSearch)
					&& ((NSStringCharIsLowercase(c1) && (NSStringCharToUppercase(c1) != c2))
						&& (NSStringCharIsLowercase(c2) && (NSStringCharToUppercase(c2) != c1)))))
		{
			break;
		}
	}

	range.length = i;
	return [self substringWithRange:range];
}

/* Changing case */
static inline NSString *strSetCase(NSString *self, int (*xlate)(UChar *, int32_t, const UChar *, int32_t, const char *, UErrorCode *))
{
	NSUInteger length = [self length];
	UErrorCode ec = U_ZERO_ERROR;
	NSUniChar* buf __cleanup(cleanup_pointer) = malloc(sizeof(NSUniChar) * (length + 1));
	[self getCharacters:buf range:NSMakeRange(0,length)];

	xlate(buf, length, buf, length, NULL, &ec);
	buf[length] = 0;
	NSString *s = [[NSString alloc] initWithCharacters:buf length:length];
	return s;
}

- (NSString*)capitalizedString
{
	// UNICODE
	// ENCODINGS - this code applies to the system's default encoding
	NSUInteger length = [self length];
	UErrorCode ec = U_ZERO_ERROR;
	NSUniChar* buf __cleanup(cleanup_pointer) = malloc(sizeof(NSUniChar) * (length + 1));
	[self getCharacters:buf range:NSMakeRange(0,length)];

	u_strToTitle(buf, length, buf, length, NULL, NULL, &ec);
	buf[length] = 0;
	NSString *s = [[NSString alloc] initWithCharacters:buf length:length];
	return s;
}

- (NSString*)lowercaseString
{
	return strSetCase(self, u_strToLower);
}

- (NSString*)uppercaseString
{
	return strSetCase(self, u_strToUpper);
}

/* Getting C strings */

- (const char *)cStringUsingEncoding:(NSStringEncoding)enc
{
	size_t maxlen = [self maximumLengthOfBytesUsingEncoding:enc] + 1;
	char *c = malloc(maxlen);
	[self getCString:c maxLength:maxlen encoding:enc];
	return [[[NSData alloc] initWithBytesNoCopy:c length:maxlen freeWhenDone:true] bytes];
}

- (const char *)UTF8String
{
	char *utf8Str;
	int32_t len;
	int32_t selfLen = [self length];
	NSUniChar *chars __cleanup(cleanup_pointer) = malloc(selfLen * sizeof(NSUniChar));
	int error = 0;

	[self getCharacters:chars range:NSMakeRange(0, selfLen)];

	u_strToUTF8(NULL, 0, &len, chars, selfLen, &error);

	if (U_FAILURE(error) && error != U_BUFFER_OVERFLOW_ERROR)
	{
		free(chars);
		return NULL;
	}
	error = 0;

	utf8Str = malloc(len + 1);
	if (utf8Str == NULL)
	{
		free(chars);
		return NULL;
	}
	u_strToUTF8(utf8Str, len+1, &len, chars, selfLen, &error);
	return [[[NSData alloc] initWithBytesNoCopy:utf8Str length:len+1 freeWhenDone:true] bytes];
}

- (bool)getCString:(char *)buffer maxLength:(NSUInteger)maxLength encoding:(NSStringEncoding)enc
{
	NSRange len = {0, [self length]};
	bool result = [self getBytes:buffer maxLength:maxLength-1 usedLength:NULL encoding:enc
		options:0 range:len remainingRange:NULL];
	buffer[maxLength - 1] = 0;
	return result;
}

- (bool)getBytes:(void*)buffer maxLength:(NSUInteger)maxLength
	usedLength:(NSUInteger*)used
	encoding:(NSStringEncoding)encoding
	options:(NSStringEncodingConversionOptions)options
	range:(NSRange)fromRange
	remainingRange:(NSRange*)remainingRange
{
	NSUInteger toMove = (maxLength < fromRange.length)? maxLength : fromRange.length;
	NSUInteger cLength = [self length];
	UErrorCode err;
	UConverter *conv;
	char *target = buffer;
	char *targetEnd = target + maxLength;
	/* A static buffer for quick extraction and converting. */
	const int BYTES_BUFSIZE = 80;
	UChar internalBuffer[BYTES_BUFSIZE];

	VERIFY_RANGE(fromRange);

	conv = ucnv_open([[NSString localizedNameOfStringEncoding:encoding] UTF8String], &err);
	if (conv == 0)
		return false;
	if (options & NSStringEncodingConversionAllowLossy)
	{
		ucnv_setFallback(conv, true);
	}
	if (remainingRange)
	{
		remainingRange->location = fromRange.location + toMove;
		remainingRange->length = cLength - remainingRange->location;
	}

	while (target != targetEnd && fromRange.length > 0)
	{
		size_t buflen = MIN(BYTES_BUFSIZE, fromRange.length);
		const UChar *buf = internalBuffer;
		[self getCharacters:internalBuffer range:NSMakeRange(fromRange.location, buflen)];
		err = U_ZERO_ERROR;
		ucnv_fromUnicode(conv, &target, targetEnd, &buf, internalBuffer + buflen, NULL, (buflen < fromRange.length), &err);
		fromRange.length -= buflen;
		if (err == U_BUFFER_OVERFLOW_ERROR)
			break;
	}
	if (target < targetEnd)
		*target = 0;
	if (used != NULL)
		*used = (NSUInteger)(target - (char *)buffer);
	ucnv_close(conv);
	return true;
}

/* Getting numeric values */

- (bool)boolValue
{
	bool val = false;
	NSScanner *scan = [[NSScanner alloc] initWithString:self];
	[scan scanBool:&val];
	return val;
}
- (double)doubleValue
{
	// UNICODE
	// ENCODINGS
	double val = 0;
	NSScanner *scan = [[NSScanner alloc] initWithString:self];
	[scan scanDouble:&val];
	return val;
}

- (float)floatValue
{
	// UNICODE
	// ENCODINGS
	float val = 0;
	NSScanner *scan = [[NSScanner alloc] initWithString:self];
	[scan scanFloat:&val];
	return val;
}

- (int)intValue
{
	// UNICODE
	// ENCODINGS
	int val = 0;
	NSScanner *scan = [[NSScanner alloc] initWithString:self];
	[scan scanInt:&val];
	return val;
}

- (NSInteger)integerValue
{
	// UNICODE
	// ENCODINGS
	NSInteger val = 0;
	NSScanner *scan = [[NSScanner alloc] initWithString:self];
	[scan scanInteger:&val];
	return val;
}

- (long long)longLongValue
{
	long long val = 0;
	NSScanner *scan = [[NSScanner alloc] initWithString:self];
	[scan scanLongLong:&val];
	return val;
}

/* Working with encodings */

+ (const NSStringEncoding*)availableStringEncodings
{
	// UNICODE
	// ENCODINGS
	static const NSStringEncoding availableEncodings[] =
	{
		NSASCIIStringEncoding,
		NSUTF8StringEncoding,
		NSUTF16LittleEndianStringEncoding,
		NSUTF16BigEndianStringEncoding,
		0
	};

	return availableEncodings;
}

+ (NSStringEncoding)defaultCStringEncoding
{
	// UNICODE
	// ENCODINGS
	return NSUTF8StringEncoding;
}

+ (NSStringEncoding) stringEncodingFromName:(NSString *)name
{
	name = [name uppercaseString];
	if ([name isEqualToString:@"US-ASCII"])
		return NSASCIIStringEncoding;
	if ([name isEqualToString:@"UTF-8"])
		return NSUTF8StringEncoding;
	if ([name isEqualToString:@"ISO8859-1"])
		return NSISOLatin1StringEncoding;
	if ([name isEqualToString:@"ISO88590"])
		return NSISOLatin2StringEncoding;
	if ([name isEqualToString:@"UTF-16"])
		return NSUTF16StringEncoding;
	if ([name isEqualToString:@"UTF16BE"])
		return NSUTF16BigEndianStringEncoding;
	if ([name isEqualToString:@"UTF16LE"])
		return NSUTF16LittleEndianStringEncoding;
	if ([name isEqualToString:@"EUC"])
		return NSJapaneseEUCStringEncoding;
	if ([name isEqualToString:@"SHIFT-JIS"])
		return NSShiftJISStringEncoding;
	return NSProprietaryStringEncoding;
}

+ (NSString*)localizedNameOfStringEncoding:(NSStringEncoding)encoding
{
	switch(encoding)
	{
		case NSASCIIStringEncoding:
			return @"us-ascii";
		case NSUTF8StringEncoding:
			return @"UTF-8";
		case NSNonLossyASCIIStringEncoding:
			return @"iso8859-1";
		case NSISOLatin1StringEncoding:
			return @"iso8859-1";
		case NSISOLatin2StringEncoding:
			return @"iso8859-2";
		case NSUnicodeStringEncoding:
			return @"utf-16";
		case NSUTF16BigEndianStringEncoding:
			return @"utf16be";
		case NSUTF16LittleEndianStringEncoding:
			return @"utf16le";
		case NSJapaneseEUCStringEncoding:
			return @"euc";
		case NSSymbolStringEncoding:
			return @"SymbolStringEncoding";
		case NSShiftJISStringEncoding:
			return @"shift-jis";
		default:
			return @"Invalid encoding";
	}
}

- (bool)canBeConvertedToEncoding:(NSStringEncoding)encoding
{
	id data = [self dataUsingEncoding:encoding allowLossyConversion:false];
	return data ? true : false;
}

- (NSData*)dataUsingEncoding:(NSStringEncoding)encoding
{
	return [self dataUsingEncoding:encoding allowLossyConversion:false];
}

- (NSData*)dataUsingEncoding:(NSStringEncoding)enc
	  allowLossyConversion:(bool)flag
{
	size_t maxLen = [self maximumLengthOfBytesUsingEncoding:enc];
	char *buffer __cleanup(cleanup_pointer) = malloc(maxLen);
	NSUInteger usedLen = 0;
	NSData *d = nil;
	if ([self getBytes:buffer maxLength:maxLen usedLength:&usedLen encoding:enc
		options:(flag?NSStringEncodingConversionAllowLossy:0)
		range:NSMakeRange(0, [self length]) remainingRange:NULL])
	{
		d = [NSData dataWithBytes:buffer length:usedLen];
	}
	return d;
}

- (NSStringEncoding)fastestEncoding
{
	// UNICODE
	// ENCODINGS
	return NSUnicodeStringEncoding;
}

- (NSStringEncoding)smallestEncoding
{
	return NSUTF8StringEncoding;
}

/* Copying methods */

- (id)copyWithZone:(NSZone*)zone
{
	return [[NSString allocWithZone:zone] initWithString:self];
}

/* MutableCopying methods */

- (id)mutableCopyWithZone:(NSZone*)zone
{
	return [[NSMutableString allocWithZone:zone] initWithString:self];
}

/* NSObject protocol */

- (NSString*)description
{
	return self;
}

- (size_t)maximumLengthOfBytesUsingEncoding:(NSStringEncoding)enc
{
	UConverter *conv;
	UErrorCode err;
	size_t retval;

	conv = ucnv_open([[NSString localizedNameOfStringEncoding:enc] cStringUsingEncoding:NSASCIIStringEncoding], &err);
	if (conv == 0)
		return [self length] * sizeof(UChar);
	retval = ucnv_getMaxCharSize(conv) * [self length];
	ucnv_close(conv);
	return retval;
}

- (size_t) lengthOfBytesUsingEncoding:(NSStringEncoding)enc
{
	UConverter *conv;
	UErrorCode err;
	size_t retval = 0;
	size_t len = [self length];
	static const int bufsize = 256;

	conv = ucnv_open([[NSString localizedNameOfStringEncoding:enc] cStringUsingEncoding:NSASCIIStringEncoding], &err);
	if (conv == 0)
		return [self length] * sizeof(UChar);
	for (size_t i = 0; i < len; i = i + bufsize)
	{
		UChar buffer[256];
		char target[512];
		const UChar *bufptr = buffer;
		UChar *bufend = &buffer[bufsize];
		err = U_BUFFER_OVERFLOW_ERROR;
		[self getCharacters:buffer range:NSMakeRange(i, MIN(len - i, bufsize))];
		while (err == U_BUFFER_OVERFLOW_ERROR)
		{
			char *targetBase = target;
			bool flush = false;
			if (len - i <= bufsize)
				flush = true;
			ucnv_fromUnicode(conv, &targetBase, target + sizeof(target), &bufptr, bufend, NULL, flush, &err);
			retval += (targetBase - target);
		}
	}
	ucnv_close(conv);
	return retval;
}

-(NSString *)stringByFoldingWithOptions:(NSStringCompareOptions)options locale:(NSLocale *)locale
{
	TODO;	// -[NSString stringByFoldingWithOptions:locale:]
	return nil;
#if 0

	UCharIterator iter;
	UBool didNormalize = false;
	UErrorCode ec = U_ZERO_ERROR;
	_CreateUCharIterFromString(self, &iter, NSMakeRange(0, [self length]));
	int32_t len = unorm_next(&iter, NULL, 0, 0, 0, true, &didNormalize, &ec);
#endif
}

- (NSString *) _composedStringUsingNormalizationMode:(UNormalizationMode)mode
{
	NSUInteger len = [self length];
	NSUInteger outLen;
	UChar *inChars __cleanup(cleanup_pointer) = malloc(len * sizeof(UChar));
	UChar *outChars;
	UErrorCode ec = U_ZERO_ERROR;
	NSString *retVal;
	
	[self getCharacters:inChars range:NSMakeRange(0, len)];
	outLen = unorm_normalize(inChars, len, mode, 0, NULL, 0, &ec);
	if (U_FAILURE(ec) && ec != U_BUFFER_OVERFLOW_ERROR)
	{
		return nil;
	}
	outChars = malloc(sizeof(UChar) * outLen);
	unorm_normalize(inChars, len, mode, 0, outChars, outLen, &ec);
	free(inChars);
	if (U_FAILURE(ec))
	{
		return nil;
	}

	retVal = [NSString stringWithCharacters:outChars length:outLen];
	return retVal;
}

- (NSString *) precomposedStringWithCompatibilityMapping
{
	return [self _composedStringUsingNormalizationMode:UNORM_NFKC];
}

- (NSString *) precomposedStringWithCanonicalMapping
{
	return [self _composedStringUsingNormalizationMode:UNORM_NFC];
}

- (NSString *) decomposedStringWithCompatibilityMapping
{
	return [self _composedStringUsingNormalizationMode:UNORM_NFKD];
}

- (NSString *) decomposedStringWithCanonicalMapping
{
	return [self _composedStringUsingNormalizationMode:UNORM_NFD];
}

static inline int hexval(char digit)
{
	if (digit > 'a')
		return 10 + (digit - 'a');
	if (digit > 'A')
		return 10 + (digit - 'A');
	return digit - '0';
}

/* XXX: This doesn't work for multibyte encodings. */
- (NSString *) stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)enc
{
	const char *strBytes = [self cStringUsingEncoding:NSASCIIStringEncoding];
	char *outChars = strdup(strBytes);

	size_t len = strlen(strBytes);
	size_t j = 0;

	for (size_t i = 0; i < len; i++)
	{
		if (outChars[i] == '%')
		{
			if (i > len - 3)
			{
				free(outChars);
				return nil;
			}
			i++;
			if (!(isxdigit(outChars[i]) && isxdigit(outChars[i+1])))
			{
				free(outChars);
				return nil;
			}
			outChars[j] = (hexval(outChars[i]) << 4) + hexval(outChars[i + 1]);
			i++;
		}
		j++;
	}
	outChars[j] = '\0';
	NSString *out = [NSString stringWithCString:outChars encoding:enc];
	free(outChars);

	return out;
}

- (NSString *) stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)enc
{
	NSData *d = [self dataUsingEncoding:enc];

	if (d != nil)
	{
		size_t len = [d length];
		const char *b = [d bytes];
		char *outBytes = malloc(len * 3);
		static const char legal[] = {';', '/', '?', ':', '@', '&', '=', '+', '$', ',',
			'-', '_', '.', '!', '~', '*', '\'', '(', ')'};
		static const char hex[] = "0123456789abcdef";
		int outLen = 0;

		for (size_t i = 0; i < len; i++)
		{
			if (!isalnum(b[i]) && !strchr(legal, b[i]))
			{
				outBytes[outLen++] = '%';
				outBytes[outLen++] = hex[((unsigned char)b[i] >> 4) & 0xF];
				outBytes[outLen++] = hex[(unsigned char)b[i] & 0xF];
			}
			else
			{
				outBytes[outLen++] = b[i];
			}
		}
		return [[NSString alloc] initWithBytesNoCopy:outBytes
											  length:outLen
											encoding:NSASCIIStringEncoding
										freeWhenDone:true];
	}
	return nil;
}

- (NSRange) rangeOfComposedCharacterSequenceAtIndex:(NSUInteger)idx
{
	TODO; // -[NSString rangeOfComposedCharacterSequenceAtIndex:];
	[self notImplemented:_cmd];
	return NSMakeRange(0,0);
}

- (NSRange) rangeOfComposedCharacterSequencesForRange:(NSRange)range
{
	TODO; // -[NSString rangeOfComposedCharacterSequencesForRange:];
	[self notImplemented:_cmd];
	return NSMakeRange(0,0);
}

- (NSComparisonResult) localizedCompare:(NSString *)other
{
	return [self compare:other options:0 range:NSMakeRange(0, [self length]) locale:[NSLocale currentLocale]];
}

- (NSComparisonResult) localizedCaseInsensitiveCompare:(NSString *)other
{
	return [self compare:other options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length]) locale:[NSLocale currentLocale]];
}

// For now, it's identical to CaseInsensitiveCompare
- (NSComparisonResult) localizedStandardCompare:(NSString *)other
{
	return [self compare:other options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length]) locale:[NSLocale currentLocale]];
}

- (void) getLineStart:(NSUInteger *)startIndex end:(NSUInteger *)lineEndIndex contentsEnd:(NSUInteger *)contentsEnd forRange:(NSRange)aRange
{
	[self notImplemented:_cmd];
}

- (void) getParagraphStart:(NSUInteger *)startIndex end:(NSUInteger *)parEndIndex contentsEnd:(NSUInteger *)contentsEnd forRange:(NSRange)aRange
{
	[self notImplemented:_cmd];
}

+ (id) stringWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding*)enc error:(NSError **)errp
{
	return [[self alloc] initWithContentsOfURL:url usedEncoding:enc error:errp];
}

- (id) initWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding*)enc error:(NSError **)err
{
	UErrorCode ec = U_ZERO_ERROR;
	NSData *data = [NSData dataWithContentsOfURL:url options:0 error:err];
	UCharsetDetector *det = ucsdet_open(&ec);
	NSStringEncoding inEnc;

	if (data == nil)
		return nil;

	if (U_FAILURE(ec))
		return nil;

	ucsdet_setText(det, [data bytes], [data length], &ec);

	const UCharsetMatch *match = ucsdet_detect(det, &ec);

	if (U_FAILURE(ec))
	{
		ucsdet_close(det);
	}
	const char *name = ucsdet_getName(match, &ec);

	inEnc = [NSString stringEncodingFromName:@(name)];
	if (enc != NULL)
		*enc = inEnc;

	return [self initWithData:data encoding:inEnc];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	size_t count = [self length];
	[coder encodeValueOfObjCType:@encode(size_t) at:&count];

	if (count > 0)
	{
		NSStringEncoding enc = NSUnicodeStringEncoding;
		NSUniChar *chars __cleanup(cleanup_pointer) = malloc(count * sizeof(NSUniChar));

		[coder encodeValueOfObjCType:@encode(NSStringEncoding) at:&enc];
		[self getCharacters:chars range:NSMakeRange(0, count)];
		[coder encodeArrayOfObjCType:@encode(NSUniChar) count:count at:chars];
	}
}

- (id) initWithCoder:(NSCoder *)coder
{
	size_t count;

	[coder decodeValueOfObjCType:@encode(size_t) at:&count];

	// TODO: In the future, this should support ASCII as well as Unicode.
	// For now, just unicode.
	if (count > 0)
	{
		NSUniChar *chars = malloc(count * sizeof(NSUniChar));

		[coder decodeArrayOfObjCType:@encode(NSUniChar) count:count at:chars];
		self = [self initWithCharactersNoCopy:chars length:count freeWhenDone:true];
	}
	return self;
}

@end /* NSString */

@implementation NSMutableString

+ (id)allocWithZone:(NSZone *)zone
{
	return (self == MutableStringClass) ? 
		[NSCoreMutableString allocWithZone:zone] 
		: NSAllocateObject(self, 0, zone);
}

+ (id)stringWithCapacity:(unsigned int)capacity
{
	return [[self alloc] initWithCapacity:capacity];
}

+ (id)string
{
	return [self stringWithCapacity:0];
}

- (id) initWithCapacity:(unsigned int)capacity
{
	[self subclassResponsibility:_cmd];
	return nil;
}

// Modifying a string
-(void)appendFormat:(NSString *)format,...
{
	va_list ap;
	va_start(ap, format);
	[self appendString:[NSString stringWithFormat:format arguments:ap]];
	va_end(ap);
}

-(void)appendString:(NSString *)aString
{
	NSRange range = NSMakeRange([self length], 0);

	[self replaceCharactersInRange:range
		withString:aString];
}

-(void)deleteCharactersInRange:(NSRange)range
{
	[self replaceCharactersInRange:range withString:nil];
}

-(void)insertString:(NSString *)aString atIndex:(unsigned int)index
{
	NSRange range = NSMakeRange(index, 0);

	[self replaceCharactersInRange:range withString:aString];
}

-(void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString
{
	[self subclassResponsibility:_cmd];
}

-(unsigned int)replaceOccurrencesOfString:(NSString *)target
	withString:(NSString *)replacement options:(NSStringCompareOptions)options
	range:(NSRange)searchRange
{
	NSRange r;
	unsigned int numMatches;
	for (numMatches = 0; searchRange.length != 0; numMatches++)
	{
		r = [self rangeOfString:target options:options
			range:searchRange];
		if (r.length == 0)
			break;
		[self replaceCharactersInRange:r withString:replacement];
		searchRange.length -= (NSMaxRange(r) - searchRange.location);
		if (!(options & NSBackwardsSearch))
			searchRange.location = r.location + r.length;
	}
	return numMatches;
}

-(void)setString:(NSString *)aString
{
	NSRange range = NSMakeRange(0, [self length]);

	[self replaceCharactersInRange:range withString:aString];
}

@end

/****************************
 * Allocate concrete strings
 ****************************/
/*
 * Classes used for allocation of NSString concrete instances
 */

@implementation NSTemporaryString

static NSTemporaryString *defaultTemp = nil;
static NSTemporaryString *zoneStrings = nil;

+ (void)initialize
{
	static bool initialized = false;

	if (!initialized)
	{
		defaultTemp = (id)NSAllocateObject(self, 0, NSDefaultAllocZone());
	}
}

+ (id) allocWithZone:(NSZone*)zone
{
	NSTemporaryString* obj = nil;

	// This is always available, so make it fast.
	if (zone == NSDefaultAllocZone() || zone == NULL)
	{
		return defaultTemp;
	}

	@synchronized(self)
	{
		obj = zoneStrings;
		while (obj != NULL && obj->_zone != zone)
		{
			obj = obj->next;
		}
		if (!obj)
		{
			obj = (id)NSAllocateObject(self, 0, zone);
			obj->_zone = zone;
			obj->next = zoneStrings;
			zoneStrings = obj;
		}
	}

	return obj;
}

// Don't do anything, we're only a single instance.
- (void)dealloc
{
}

- (NSZone*)zone
{
	return _zone;
}

/*
 * Methods that return strings
 */

- (id) init
{
	id str = @"";

	return str;
}

- (id) initWithBytes:(const void *)bytes length:(NSUInteger)length
	encoding:(NSStringEncoding)enc
{
	return (id)[[NSCoreString alloc] initWithBytes:bytes length:length encoding:enc copy:true
		freeWhenDone:false];
}

- (id) initWithBytesNoCopy:(const void *)bytes length:(NSUInteger)length
	encoding:(NSStringEncoding)encoding freeWhenDone:(bool)flag
{
	return (id)[[NSCoreString alloc] initWithBytesNoCopy:bytes length:length
		encoding:encoding freeWhenDone:flag];
}

- (id) initWithCharacters:(const NSUniChar*)chars length:(NSUInteger)length
{
	return (id)[[NSCoreString alloc] initWithCharacters:chars length:length];
}

- (id) initWithCharactersNoCopy:(const NSUniChar*)chars
length:(NSUInteger)length freeWhenDone:(bool)flag
{
	// UNICODE
	return (id)[[NSCoreString alloc] initWithCharactersNoCopy:chars length:length
		freeWhenDone:flag];
}

- (id) initWithCString:(const char*)byteString encoding:(NSStringEncoding)enc
{
	if (byteString == NULL)
		return [self init];

	int length = strlen(byteString);
	id str = [[NSCoreString allocWithZone:_zone]
		initWithBytes:byteString length:length encoding:enc
		copy:true freeWhenDone:false];

	return str;
}

- (id) initWithUTF8String:(const char *)utf8Str
{
	return [self initWithCString:utf8Str encoding:NSUTF8StringEncoding];
}

- (id) initWithString:(NSString*)aString
{
	id str = [[NSCoreString allocWithZone:_zone] initWithString:aString];
	return str;
}

- (id) initWithFormat:(NSString*)format, ...
{
	id str;
	va_list va;

	va_start(va, format);
	str = [self initWithFormat:format arguments:va];
	va_end(va);
	return str;
}

- (id) initWithFormat:(NSString*)format arguments:(va_list)argList
{
	return [self initWithFormat:format locale:nil arguments:argList];
}

- (id) initWithFormat:(NSString*)format
	locale:(NSLocale*)locale, ...
{
	id str;
	va_list va;

	va_start(va, locale);
	str = [self initWithFormat:format locale:locale arguments:va];
	va_end(va);
	return str;
}

- (id) initWithFormat:(NSString*)format
		locale:(NSLocale*)locale arguments:(va_list)argList
{
	id str = Avsprintf(format, locale, argList);
	str = [str copyWithZone:_zone];
	return str;
}

- (id) initWithData:(NSData*)data encoding:(NSStringEncoding)encoding
{
	// UNICODE
	id str = [[NSCoreString allocWithZone:_zone]
		initWithCString:(const char*)[data bytes] length:[data length]];
	return str;
}

@end /* NSTemporaryString */

@implementation NSCharacterConversionException
@end
@implementation NSParseErrorException
@end
