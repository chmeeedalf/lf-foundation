/*
 * Copyright (c) 2012	Justin Hibbits
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

#import <Foundation/NSLinguisticTagger.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import "internal.h"

@class NSArray;
@class NSOrthography;
@class NSString;

NSString * const  NSLinguisticTagSchemeTokenType = @"NSLinguisticTagSchemeTokenType";
NSString * const  NSLinguisticTagSchemeLexicalClass = @"NSLinguisticTagSchemeLexicalClass";
NSString * const  NSLinguisticTagSchemeNameType = @"NSLinguisticTagSchemeNameType";
NSString * const  NSLinguisticTagSchemeNameTypeOrLexicalClass = @"NSLinguisticTagSchemeNameTypeOrLexicalClass";
NSString * const  NSLinguisticTagSchemeLemma = @"NSLinguisticTagSchemeLemma";
NSString * const  NSLinguisticTagSchemeLanguage = @"NSLinguisticTagSchemeLanguage";
NSString * const  NSLinguisticTagSchemeScript = @"NSLinguisticTagSchemeScript";

NSString * const  NSLinguisticTagWord = @"NSLinguisticTagWord";
NSString * const  NSLinguisticTagPunctuation = @"NSLinguisticTagPunctuation";
NSString * const  NSLinguisticTagWhitespace = @"NSLinguisticTagWhitespace";
NSString * const  NSLinguisticTagOther = @"NSLinguisticTagOther";

NSString * const  NSLinguisticTagNoun = @"NSLinguisticTagNoun";
NSString * const  NSLinguisticTagVerb = @"NSLinguisticTagVerb";
NSString * const  NSLinguisticTagAdjective = @"NSLinguisticTagAdjective";
NSString * const  NSLinguisticTagAdverb = @"NSLinguisticTagAdverb";
NSString * const  NSLinguisticTagPronoun = @"NSLinguisticTagPronoun";
NSString * const  NSLinguisticTagDeterminer = @"NSLinguisticTagDeterminer";
NSString * const  NSLinguisticTagParticle = @"NSLinguisticTagParticle";
NSString * const  NSLinguisticTagPreposition = @"NSLinguisticTagPreposition";
NSString * const  NSLinguisticTagNumber = @"NSLinguisticTagNumber";
NSString * const  NSLinguisticTagConjunction = @"NSLinguisticTagConjunction";
NSString * const  NSLinguisticTagInterjection = @"NSLinguisticTagInterjection";
NSString * const  NSLinguisticTagClassifier = @"NSLinguisticTagClassifier";
NSString * const  NSLinguisticTagIdiom = @"NSLinguisticTagIdiom";
NSString * const  NSLinguisticTagOtherWord = @"NSLinguisticTagOtherWord";
NSString * const  NSLinguisticTagSentenceTerminator = @"NSLinguisticTagSentenceTerminator";
NSString * const  NSLinguisticTagOpenQuote = @"NSLinguisticTagOpenQuote";
NSString * const  NSLinguisticTagCloseQuote = @"NSLinguisticTagCloseQuote";
NSString * const  NSLinguisticTagOpenParenthesis = @"NSLinguisticTagOpenParenthesis";
NSString * const  NSLinguisticTagCloseParenthesis = @"NSLinguisticTagCloseParenthesis";
NSString * const  NSLinguisticTagWordJointer = @"NSLinguisticTagWordJointer";
NSString * const  NSLinguisticTagDash = @"NSLinguisticTagDash";
NSString * const  NSLinguisticTagOtherPunctuation = @"NSLinguisticTagOtherPunctuation";
NSString * const  NSLinguisticTagParagraphBreak = @"NSLinguisticTagParagraphBreak";
NSString * const  NSLinguisticTagOtherWhitespace = @"NSLinguisticTagOtherWhitespace";

NSString * const  NSLinguisticTagPersonalName = @"NSLinguisticTagPersonalName";
NSString * const  NSLinguisticTagPlaceName = @"NSLinguisticTagPlaceName";
NSString * const  NSLinguisticTagOrganizationName = @"NSLinguisticTagOrganizationName";

@implementation NSLinguisticTagger
{
	NSString *string;
}

- (id) initWithTagSchemes:(NSArray *)schemes options:(NSUInteger)opts
{
	TODO;	// -[NSLinguisticTagger initWithTagSchemes:options:]
	return self;
}


- (NSArray *) tagSchemes
{
	TODO;	// -[NSLinguisticTagger tagSchemes]
	return nil;
}

+ (NSArray *) availableTagSchemesForLanguage:(NSString *)lang
{
	TODO;	// -[NSLinguisticTagger availableTagSchemesForLanguage:]
	return nil;
}


- (NSString *) string
{
	return string;
}

- (void) setString:(NSString *)newString
{
	string = newString;
	TODO;	// -[NSLinguisticTagger setString:] -- clear status data
}

- (NSString *) stringEditedInRange:(NSRange)range changeInLength:(NSInteger)deltaLen
{
	TODO;	// -[NSLinguisticTagger stringEditedInRange:changeInLength:]
	return nil;
}


- (void) setOrthography:(NSOrthography *)orth range:(NSRange)range
{
	TODO;	// -[NSLinguisticTagger setOrthography:range:]
}

- (NSOrthography *) orthographyAtIndex:(NSUInteger)idx effectiveRange:(NSRange *)rangep
{
	TODO;	// -[NSLinguisticTagger orthographyAtIndex:effectiveRange:]
	return nil;
}


- (void) enumerateTagsInRange:(NSRange)range scheme:(NSString *)tagScheme options:(NSLinguisticTaggerOptions)opts usingBlock:(void (^)(NSString *, NSRange, NSRange, bool *))block
{
	TODO;	// -[NSLinguisticTagger enumerateTagsInRange:scheme:options:usingBlock:]
	NSRange tokenRange = NSMakeRange(0, 0);
	NSRange sentenceRange;
	for (NSUInteger i = range.location; i < NSMaxRange(range); i += NSMaxRange(tokenRange) )
	{
		NSString *tag;

		if (opts != 0)
		{
			tag = [self tagAtIndex:i scheme:NSLinguisticTagSchemeTokenType
						tokenRange:&tokenRange sentenceRange:&sentenceRange];

			if (opts & NSLinguisticTaggerOmitWords)
			{
				if ([tag isEqualToString:NSLinguisticTagWord])
					continue;
			}
			if (opts & NSLinguisticTaggerOmitPunctuation)
			{
				if ([tag isEqualToString:NSLinguisticTagPunctuation])
					continue;
			}
			if (opts & NSLinguisticTaggerOmitWhitespace)
			{
				if ([tag isEqualToString:NSLinguisticTagWhitespace])
					continue;
			}
			if (opts & NSLinguisticTaggerOmitOther)
			{
				if ([tag isEqualToString:NSLinguisticTagOther])
					continue;
			}
			if (opts & NSLinguisticTaggerJoinNames)
			{
			}
		}
		tag = [self tagAtIndex:i scheme:tagScheme
					tokenRange:&tokenRange sentenceRange:&sentenceRange];

		bool stop = false;
		block(tag, tokenRange, sentenceRange, &stop);
		if (stop)
		{
			break;
		}
	}
}

- (NSArray *) possibleTagsAtIndex:(NSUInteger)charIndex scheme:(NSString *)tagScheme tokenRange:(NSRangePointer)tokenRange sentenceRange:(NSRangePointer)sentenceRange scores:(NSArray **)scores
{
	TODO;	// -[NSLinguisticTagger availableTagSchemesForLanguage:scheme:tokenRange:sentenceRange:scores:]
	return nil;
}

- (NSString *) tagAtIndex:(NSUInteger)charIndex scheme:(NSString *)tagScheme tokenRange:(NSRangePointer)tokenRange sentenceRange:(NSRangePointer)sentenceRange
{
	TODO;	// -[NSLinguisticTagger tagScheme:scheme:tokenRange:sentenceRange:]
	return nil;
}

- (NSArray *) tagsInRange:(NSRange)range scheme:(NSString *)tagScheme options:(NSLinguisticTaggerOptions)opts tokenRanges:(NSArray **)tokenRanges
{
	NSMutableArray *ret = [NSMutableArray array];
	NSMutableArray *outRanges = nil;

	if (tokenRanges != NULL)
		outRanges = [NSMutableArray array];

	[self enumerateTagsInRange:range scheme:tagScheme options:opts usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, bool *stop)
	{
		[ret addObject:tag];
		[outRanges addObject:[NSValue valueWithRange:tokenRange]];
	}];

	if (tokenRanges != NULL)
	{
		*tokenRanges = outRanges;
	}
	return ret;
}


@end

@implementation NSString (NSLinguisticTagging)

- (void) enumerateLinguisticTagsInRange:(NSRange)range scheme:(NSString *)tagScheme options:(NSLinguisticTaggerOptions)opts orthography:(NSOrthography *)orth usingBlock:(void (^)(NSString *, NSRange, NSRange, bool *))block
{
	NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:@[tagScheme] options:opts];
	[tagger setString:self];
	[tagger setOrthography:orth range:NSMakeRange(0, [self length])];
	[tagger enumerateTagsInRange:range scheme:tagScheme options:opts usingBlock:block];
}

- (NSArray *) linguisticTagsInRange:(NSRange)range scheme:(NSString *)tagScheme options:(NSLinguisticTaggerOptions)opts orthography:(NSOrthography *)orth tokenRanges:(NSArray **)tokenRanges
{
	NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:nil options:opts];
	[tagger setString:self];
	[tagger setOrthography:orth range:NSMakeRange(0, [self length])];
	return [tagger tagsInRange:range scheme:tagScheme options:opts tokenRanges:tokenRanges];
}

@end
