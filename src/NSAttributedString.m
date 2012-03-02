/*
 * Copyright (c) 2009-2012	Gold Project
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

#import "NSCoreAttributedString.h"
#import <Foundation/NSAttributedString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import "internal.h"

@implementation NSAttributedString

+ (id) allocWithZone:(NSZone *)zone
{
	if ([self class] == [NSAttributedString class])
		return NSAllocateObject([NSCoreAttributedString class], 0, zone);
	else
		return [super allocWithZone:zone];
}

- (id) initWithString:(NSString *)str
{
	return [self initWithString:str attributes:nil];
}

- (id) initWithString:(NSString *)str attributes:(NSDictionary *)attributes
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (id) initWithAttributedString:(NSAttributedString *)str
{
	[self subclassResponsibility:_cmd];
	return nil;
}


- (NSString *)string
{
	return [self subclassResponsibility:_cmd];
}

- (size_t) length
{
	return [[self string] length];
}


- (NSDictionary *)attributesAtIndex:(NSIndex)idx effectiveRange:(NSRange *)range
{
	return [self subclassResponsibility:_cmd];
}

- (NSDictionary *)attributesAtIndex:(NSIndex)idx longestEffectiveRange:(NSRange *)range inRange:(NSRange)inRange
{
	NSDictionary *attrs, *tmpDict;
	NSRange attrRange;

	if (NSMaxRange(inRange) > [self length])
		@throw [NSRangeException exceptionWithReason:@"Out of bounds in -[NSAttributedString attributesAtIndex:longestEffectiveRange:inRange:]" userInfo:nil];

	attrs = [self attributesAtIndex:idx effectiveRange:range];
	if (range == NULL)
		return attrs;

	while (range->location > inRange.location)
	{
		tmpDict = [self attributesAtIndex:(range->location-1) effectiveRange:&attrRange];
		if (![tmpDict isEqualToDictionary:attrs])
			break;
		range->length = NSMaxRange(*range) - attrRange.location;
		range->location = attrRange.location;
	}
	while (NSMaxRange(*range) < NSMaxRange(inRange))
	{
		tmpDict = [self attributesAtIndex:NSMaxRange(*range) effectiveRange:&attrRange];
		if (![tmpDict isEqualToDictionary:attrs])
			break;
		range->length = NSMaxRange(attrRange) - range->location;
	}
	*range = NSIntersectionRange(*range, inRange);
	return attrs;
}


- (bool) isEqualToAttributedString:(NSAttributedString *)otherString
{
	if (![[self string] isEqual:[otherString string]])
		return false;
	size_t l = [self length];
	for (size_t i = 0; i < l;)
	{
		NSRange myRange, otherRange;
		NSDictionary *mine = [self attributesAtIndex:i effectiveRange:&myRange];
		NSDictionary *others = [otherString attributesAtIndex:i effectiveRange:&otherRange];
		if (![mine isEqual:others])
			return false;
		if (!NSEqualRanges(myRange, otherRange))
			return false;
		i = NSMaxRange(myRange);
	}
	return true;
}

- (id) mutableCopyWithZone:(NSZone *)z
{
	return [[NSMutableAttributedString allocWithZone:z] initWithAttributedString:self];
}

- (id) copyWithZone:(NSZone *)z
{
	return [[NSAttributedString allocWithZone:z] initWithAttributedString:self];
}

- (NSAttributedString *) attributedSubstringFromRange:(NSRange)range
{
	if (NSMaxRange(range) > [self length])
		@throw [NSRangeException exceptionWithReason:@"-[NSAttributedString attributedSubstringFromRange:] invalid range" userInfo:nil];
	

	NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[[self string] substringWithRange:range]];

	for (NSUInteger i = range.location; i < NSMaxRange(range);)
	{
		NSRange effectiveRange;
		NSDictionary *d = [self attributesAtIndex:i effectiveRange:&effectiveRange];
		effectiveRange.location -= range.location;
		if (d != nil)
		{
			[str setAttributes:d range:effectiveRange];
			i += effectiveRange.length;
		}
		else
			i++;
	}
	return str;
}

- (id) attribute:(NSString *)attrib atIndex:(NSIndex)idx effectiveRange:(NSRange *)range
{
	NSRange tempRange;
	NSDictionary *attributes = [self attributesAtIndex:idx effectiveRange:&tempRange];
	id obj = [attributes objectForKey:attrib];

	if (obj != nil)
	{
		if (range)
			*range = tempRange;
		return obj;
	}
	return nil;
}

- (id) attribute:(NSString *)attrib atIndex:(NSIndex)idx longestEffectiveRange:(NSRange *)range inRange:(NSRange)inRange
{
	if (NSMaxRange(*range) > [self length])
		@throw [NSRangeException exceptionWithReason:@"-[NSAttributedString attribute:atIndex:longestEffectiveRange:inRange:] invalid range" userInfo:nil];

	id obj = [self attribute:attrib atIndex:idx effectiveRange:range];
	id tmpObj;
	NSRange attrRange;

	if (range == NULL)
		return obj;

	while (range->location > inRange.location)
	{
		tmpObj = [self attribute:attrib atIndex:(range->location-1) effectiveRange:&attrRange];
		if (tmpObj == nil)
			break;
		range->length = NSMaxRange(*range) - attrRange.location;
		range->location = attrRange.location;
	}
	while (NSMaxRange(*range) < NSMaxRange(inRange))
	{
		tmpObj = [self attribute:attrib atIndex:NSMaxRange(*range) effectiveRange:&attrRange];
		if (tmpObj == nil)
			break;
		range->length = NSMaxRange(attrRange) - range->location;
	}
	*range = NSIntersectionRange(*range, inRange);
	return obj;
}

- (void) enumerateAttribute:(NSString *)attrName inRange:(NSRange)range options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id value, NSRange range, bool *stop))block
{
	NSUInteger i;
	NSUInteger end;
	int offset;

	if (opts & NSAttributedStringEnumerationReverse)
	{
		i = NSMaxRange(range);
		end = range.location;
		offset = -1;
	}
	else
	{
		i = range.location;
		end = NSMaxRange(range);
	}
	for (;i != end;)
	{
		NSRange r;
		id val;
		bool stop;
		
		if (opts & NSAttributedStringEnumerationLongestEffectiveRangeNotRequired)
			val = [self attribute:attrName atIndex:i effectiveRange:&r];
		else
			val = [self attribute:attrName atIndex:i longestEffectiveRange:&r inRange:range];
		r = NSIntersectionRange(r, range);
		if (val == nil || NSMaxRange(r) == 0)
		{
			i++;
			continue;
		}
		block(val, r, &stop);
		if (opts & NSAttributedStringEnumerationReverse)
			i = r.location;
		else
			i = NSMaxRange(r);
		if (stop)
			break;
	}
}

- (void) enumerateAttributesInRange:(NSRange)range options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id value, NSRange range, bool *stop))block
{
	NSUInteger i;
	NSUInteger end;
	int offset;

	if (opts & NSAttributedStringEnumerationReverse)
	{
		i = NSMaxRange(range);
		end = range.location;
		offset = -1;
	}
	else
	{
		i = range.location;
		end = NSMaxRange(range);
	}
	for (;i != end;)
	{
		NSRange r;
		id attrs;
		bool stop;
		
		if (opts & NSAttributedStringEnumerationLongestEffectiveRangeNotRequired)
			attrs = [self attributesAtIndex:i effectiveRange:&r];
		else
			attrs = [self attributesAtIndex:i longestEffectiveRange:&r inRange:range];
		r = NSIntersectionRange(r, range);
		if (attrs == nil || NSMaxRange(r) == 0)
		{
			i++;
			continue;
		}
		block(attrs, r, &stop);
		if (opts & NSAttributedStringEnumerationReverse)
			i = r.location;
		else
			i = NSMaxRange(r);
		if (stop)
			break;
	}
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	TODO; // encodeWithCoder:
	return;
}

- (id) initWithCoder:(NSCoder *)coder
{
	TODO; // initWithCoder:
	return nil;
}

@end

@implementation NSMutableAttributedString

+ (id) allocWithZone:(NSZone *)zone
{
	if ([self class] == [NSMutableAttributedString class])
		return NSAllocateObject([CoreMutableAttributedString class], 0, zone);
	else
		return [super allocWithZone:zone];
}

- (NSMutableString *)mutableString
{
	return [self subclassResponsibility:_cmd];
}

- (void) setAttributedString:(NSAttributedString *)attribStr
{
	[self replaceCharactersInRange:NSMakeRange(0,[[self string] length]) withAttributedString:attribStr];
}


- (void) replaceCharactersInRange:(NSRange)r withString:(NSString *)str
{
	[self subclassResponsibility:_cmd];
}

- (void) replaceCharactersInRange:(NSRange)r withAttributedString:(NSAttributedString *)str
{
	NSString *attributedString = [str string];
	[self beginEditing];
	[self replaceCharactersInRange:r withString:attributedString];
	size_t max = [str length];

	if (max > 0)
	{
		size_t loc = 0;

		while (loc < max)
		{
			NSRange tmpRange;
			NSDictionary *d = [str attributesAtIndex:loc effectiveRange:&tmpRange];
			loc += MAX(tmpRange.length, 1);
			[self setAttributes:d range:NSMakeRange(r.location + tmpRange.location, tmpRange.length)];
		}
	}

	[self endEditing];
}

- (void) deleteCharactersInRange:(NSRange)r
{
	[self replaceCharactersInRange:r withString:@""];
}


- (void) setAttributes:(NSDictionary *)attribs range:(NSRange)r
{
	[self subclassResponsibility:_cmd];
}

- (void) addAttributes:(NSDictionary *)attribs range:(NSRange)r
{
	NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
	for (size_t loc = r.location; loc < NSMaxRange(r);)
	{
		NSRange tmpRange;
		[d setDictionary:attribs];
		NSDictionary *oldAttribs = [self attributesAtIndex:loc effectiveRange:&tmpRange];
		[d addEntriesFromDictionary:oldAttribs];
		[self setAttributes:d range:NSIntersectionRange(tmpRange, r)];
		loc += NSIntersectionRange(tmpRange, r).length;
	}
}

- (void) addAttribute:(NSString *)attrib value:(id)val range:(NSRange)r
{
	NSDictionary *d = [[NSDictionary alloc] initWithObjects:&val forKeys:&attrib count:1];
	[self addAttributes:d range:r];
}

- (void) removeAttribute:(NSString *)attrib range:(NSRange)r
{
}

- (void) appendAttributedString:(NSAttributedString *)attribString
{
	[self replaceCharactersInRange:NSMakeRange([[self string] length],0) withAttributedString:attribString];
}

- (void) insertAttributedString:(NSAttributedString *)str atIndex:(NSIndex)idx
{
	[self replaceCharactersInRange:NSMakeRange(idx,0) withAttributedString:str];
}


- (void) beginEditing
{
}

- (void) endEditing
{
}

@end
