/*
 * Copyright (c) 2009	Gold Project
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

#import <Foundation/NSRegex.h>
#import "NSCoreString.h"

#include <stdlib.h>
#include <unicode/unistr.h>
#include <unicode/regex.h>
#include <vector>

@interface _RegexPatternPrivate : NSObject
{
	@public
	icu::RegexPattern *pattern;
}
@end

@implementation _RegexPatternPrivate
- (void) dealloc
{
	if (pattern)
		delete pattern;
	[super dealloc];
}
@end

#define _private (*(_RegexPatternPrivate **)&self->_private)

@interface NSRegexPattern()
- (icu::RegexPattern *)_icuPattern;
@end

@interface NSRegexMatcher()
- initWithPattern:(NSRegexPattern *)pattern string:(NSString *)str;
- (void) setString:(NSString *)str;
@end

@implementation NSRegexPattern
+ compiledPatternWithString:(NSString *)str
{
	return [self compiledPatternWithString:str flags:0];
}

+ compiledPatternWithString:(NSString *)str flags:(NSRegexFlags)flags
{
	return [[[self alloc] initWithStringPattern:str flags:flags] autorelease];
}

- initWithStringPattern:(NSString *)str flags:(NSRegexFlags)flags
{
	NSUniChar *outstr_unicode = new NSUniChar[[str length] + 1];
	UParseError pe = {};
	UErrorCode ec = U_ZERO_ERROR;
	[str getCharacters:outstr_unicode range:NSRange(0,[str length])];
	outstr_unicode[[str length]] = 0;
	icu::UnicodeString ustr(outstr_unicode);

	_private = [_RegexPatternPrivate new];
	_private->pattern = icu::RegexPattern::compile(ustr, flags, pe, ec);
	delete[] outstr_unicode;
	patternString = [str copy];

	return self;
}

- (NSRegexMatcher *)matcherForString:(NSString *)str
{
	return [[[NSRegexMatcher alloc] initWithPattern:self string:str] autorelease];
}

- (NSRegexMatcher *)matcher
{
	return [[[NSRegexMatcher alloc] initWithPattern:self string:nil] autorelease];
}

- (void) dealloc
{
	delete _private->pattern;
	[super dealloc];
}

- (icu::RegexPattern *)_icuPattern
{
	return _private->pattern;
}

- (NSString *) pattern
{
	return patternString;
}

#undef _private
- (bool) isEqualToPattern:(NSRegexPattern *)other
{
	return (other->_private != nil) && (((_RegexPatternPrivate *)_private)->pattern ==
			((_RegexPatternPrivate *)other->_private)->pattern);
}

@end

@interface _RegexMatcherPrivate : NSObject
{
	@public
	icu::RegexMatcher *matcher;
	icu::UnicodeString *input;
}
@end

@implementation _RegexMatcherPrivate
- (void) dealloc
{
	if (matcher)
		delete matcher;
	if (input)
		delete input;
	[super dealloc];
}
@end

#define _private (*(_RegexMatcherPrivate **)&self->_private)
@implementation NSRegexMatcher
/* regex is weakly referenced, held on only by referencing the source pattern,
 * which must contain the regex.
 */
- initWithPattern:(NSRegexPattern *)pattern string:(NSString *)str
{
	UErrorCode ec = U_ZERO_ERROR;
	_private = [_RegexMatcherPrivate new];
	_private->matcher = [pattern _icuPattern]->matcher(ec);
	sourcePattern = [pattern retain];
	[self setString:str];
	return self;
}

- (void) setString:(NSString *)str
{
	if (_private->input != NULL)
		delete _private->input;
	if ([str respondsToSelector:@selector(_unicodeString)])
		_private->matcher->reset(*[(NSCoreString *)str _unicodeString]);
	else
	{
		size_t len = [str length];
		UChar *buff = new UChar[len + 1];
		buff[len] = 0;
		[str getCharacters:buff range:NSRange(0, len)];
		_private->input = new icu::UnicodeString(buff);
		_private->matcher->reset(*_private->input);
		delete[] buff;
	}
}

- (bool) matches
{
	UErrorCode ec = U_ZERO_ERROR;
	return _private->matcher->matches(ec);
}

- (NSRange) rangeOfNextMatch
{
	if (!_private->matcher->find())
		return NSRange(0,0);
	UErrorCode ec = U_ZERO_ERROR;
	NSIndex i = _private->matcher->start(ec);
	if (U_FAILURE(ec))
		return NSRange(0,0);
	return NSRange(i, _private->matcher->end(ec) - i);
}

- (NSString *)stringOfLastMatch
{
	UErrorCode ec = U_ZERO_ERROR;
	UnicodeString us = _private->matcher->group(ec);
	if (U_FAILURE(ec))
	{
		if (ec == U_REGEX_INVALID_STATE)
		{
			if (!_private->matcher->find())
				return nil;
			us = _private->matcher->group(ec);
		}
		else
			return nil;
	}
	return [NSString stringWithCharacters:us.getBuffer() length:us.length()];
}

- (NSString *)groupWithIndexInLastMatch:(NSIndex)indx
{
	UErrorCode ec = U_ZERO_ERROR;
	UnicodeString us = _private->matcher->group(indx, ec);
	if (U_FAILURE(ec))
	{
		if (ec == U_REGEX_INVALID_STATE)
		{
			if (!_private->matcher->find())
				return nil;
			us = _private->matcher->group(indx, ec);
		}
		else
			return nil;
	}
	return [NSString stringWithCharacters:us.getBuffer() length:us.length()];
}

- (NSIndex)numberOfGroups
{
	return _private->matcher->groupCount();
}

- (NSArray *)splitStringWithCount:(size_t)max
{
	std::vector<UnicodeString> s(max);
	UErrorCode ec = U_ZERO_ERROR;
	_private->matcher->split(*_private->input, &s.front(), max, ec);
	if (U_FAILURE(ec))
		return nil;
	NSString *strings[max];

	size_t i = 0;
	for (; i < max; i++)
	{
		strings[i] = [[NSString alloc] initWithCharacters:s[i].getBuffer()
			length:s[i].length()];
	}
	NSArray *ret = [NSArray arrayWithObjects:strings count:max];

	for (i = 0; i < max; i++)
	{
		[strings[i] release];
	}
	return ret;
}

- (void) dealloc
{
	[sourcePattern release];
	[_private release];
	[super dealloc];
}
@end

#undef _private
@implementation NSString(RegularExpressions)
- (bool) matchesRegularExpression:(NSRegexPattern *)pattern
{
	return [[pattern matcherForString:self] matches];
}

- (NSArray *) componentsSeparatedByPattern:(NSRegexPattern *)pattern
{
	NSRegexMatcher *matcher = [pattern matcherForString:self];
	NSRange r;
	NSIndex i = 0;
	NSMutableArray *arr = [NSMutableArray array];

	do
	{
		r = [matcher rangeOfNextMatch];
		if (r.length > 0)
			[arr addObject:[self substringWithRange:NSRange(i, r.location - i)]];
		i = r.location + r.length;
	}
	while (r.length != 0);
	if (i < [self length])
		[arr addObject:[self substringFromIndex:i]];
	return arr;
}

- (NSArray *) componentsMatchingPattern:(NSRegexPattern *)pattern
{
	NSRegexMatcher *matcher = [pattern matcherForString:self];
	NSRange r;
	NSMutableArray *arr = [NSMutableArray array];

	do
	{
		r = [matcher rangeOfNextMatch];
		if (r.length > 0)
			[arr addObject:[self substringWithRange:NSRange(r.location,
					r.length)]];
	}
	while (r.length != 0);
	return arr;
}

- (NSString *) stringByReplacingOccurrencesOfPattern:(NSRegexPattern *)pattern
	withString:(NSString *)newString
{
	return [[self componentsSeparatedByPattern:pattern]
		componentsJoinedByString:newString];
}
@end

@implementation NSScanner(RegularExpressions)
- (bool) scanUpToPattern:(NSRegexPattern *)pattern intoString:(NSString **)str
{
	NSIndex i = [self scanLocation];
	NSRange r = [[pattern matcherForString:[[self string]
		substringFromIndex:i]] rangeOfNextMatch];
	if (r.length == 0)
		return false;
	if (str != NULL)
	{
		*str = [[self string] substringWithRange:NSRange(i + r.location, i +
				r.location + r.length)];
	}
	return true;
}

- (bool) scanPattern:(NSRegexPattern *)pattern intoString:(NSString **)str
{
	NSIndex i = [self scanLocation];
	NSRange r = [[pattern matcherForString:[[self string]
		substringFromIndex:i]] rangeOfNextMatch];
	if (r.length == 0 || r.location != 0)
		return false;
	if (str != NULL)
	{
		*str = [[self string] substringWithRange:NSRange(i, i + r.length)];
	}
	return true;
}
@end
