/*
 * Copyright (c) 2009-2012	Justin Hibbits
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

#import "NSCoreAttributedString.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>

@implementation _AttributedRange
@end

@implementation NSCoreAttributedString

- (id) initWithString:(NSString *)string attributes:(NSDictionary *)attributes
{
	str = string;
	_AttributedRange *r = [_AttributedRange new];
	r->attributes = attributes;
	r->range = (NSRange){0, [str length]};
	attributeRanges = [[NSArray alloc] initWithObjects:r,nil];
	return self;
}

- (id) initWithAttributedString:(NSAttributedString *)string
{
	str = [[string string] copy];
	NSMutableArray *a = [NSMutableArray new];
	size_t len = [str length];
	for (size_t i = 0; i < len;)
	{
		NSRange r;
		NSDictionary *d;
		_AttributedRange *ar = [_AttributedRange new];
		d = [string attributesAtIndex:i effectiveRange:&r];
		ar->attributes = d;
		ar->range = r;
		[a addObject:ar];
		i = NSMaxRange(r);
	}
	attributeRanges = a;
	return self;
}

- (NSString *) string
{
	return str;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)idx effectiveRange:(NSRange *)range
{
	for (_AttributedRange *r in attributeRanges)
	{
		if (NSLocationInRange(idx, r->range))
		{
			if (range != NULL)
				*range = r->range;
			return r->attributes;
		}
	}
	if (range != NULL)
		*range = NSMakeRange(0, [self length]);
	return nil;
}

@end

@implementation CoreMutableAttributedString

+ (void) initialize
{
	class_addBehavior(self, [NSCoreAttributedString class]);
}

- (NSMutableString *)mutableString
{
	return [self subclassResponsibility:_cmd];
}

- (void) _fixRange:(NSRange)r length:(size_t)len
{
	size_t i = 0;
	int delind[[attributeRanges count]];
	for (_AttributedRange *ar in attributeRanges)
	{
		/* If the attributes aren't in the deleted range, ignore. */
		if (NSMaxRange(ar->range) < r.location)
			continue;
		else if (NSMaxRange(r) <= ar->range.location)
		{
			ar->range.location -= r.length;
			ar->range.location += len;
		}
		/* If it's wholely contained within the deleted range, delete it
		 * completely.
		 */
		if (NSEqualRanges(NSIntersectionRange(ar->range, r), ar->range))
		{
			delind[i] = 1;
			continue;
		}
		delind[i] = 0;
		if (ar->range.location < r.location && NSMaxRange(ar->range) > r.location)
			ar->range.length = (r.location - ar->range.location);
		else if (NSLocationInRange(ar->range.location, r))
		{
			ar->range.length = NSMaxRange(ar->range) - NSMaxRange(r);
			ar->range.location = len + r.location;
		}
		else
			delind[i] = 0;
		i++;
	}
	len = [attributeRanges count];
	for (i = len; i > 0; --i)
	{
		if (delind[i-1] == 1)
			[attributeRanges removeObjectAtIndex:i];
	}
}

- (void) replaceCharactersInRange:(NSRange)r withString:(NSString *)s
{
	if (str == nil)
		str = [NSMutableString new];
	[str replaceCharactersInRange:r withString:s];
	size_t len = [str length];
	[self _fixRange:r length:len];
}

- (void) setAttributes:(NSDictionary *)attribs range:(NSRange)r
{
	[self _fixRange:r length:r.length];
	int len = [attributeRanges count];
	int i = 0;
	for (; i < len; i++)
	{
		_AttributedRange *ar = [attributeRanges objectAtIndex:i];
		if (NSMaxRange(ar->range) < r.location)
		{
			i++;
			break;
		}
		else if (NSMaxRange(r) < ar->range.location)
			break;
	}
	_AttributedRange *ar = [_AttributedRange new];
	ar->range = r;
	ar->attributes = attribs;
	[attributeRanges insertObject:ar atIndex:i];
	return;
}

- (void) beginEditing
{
}

- (void) endEditing
{
}

@end
