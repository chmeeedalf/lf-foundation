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

#import <Foundation/NSObject.h>

@class NSArray;
@class NSOrthography;
@class NSString;

enum
{
	NSLinguisticTaggerOmitWords		= 1 << 0,
	NSLinguisticTaggerOmitPunctuation	= 1 << 1,
	NSLinguisticTaggerOmitWhitespace	= 1 << 2,
	NSLinguisticTaggerOmitOther			= 1 << 3,
	NSLinguisticTaggerJoinNames			= 1 << 4
};
typedef NSUInteger NSLinguisticTaggerOptions;

extern NSString * const NSLinguisticTagSchemeTokenType;
extern NSString * const NSLinguisticTagSchemeLexicalClass;
extern NSString * const NSLinguisticTagSchemeNameType;
extern NSString * const NSLinguisticTagSchemeNameTypeOrLexicalClass;
extern NSString * const NSLinguisticTagSchemeLemma;
extern NSString * const NSLinguisticTagSchemeLanguage;
extern NSString * const NSLinguisticTagSchemeScript;

extern NSString * const NSLinguisticTagWord;
extern NSString * const NSLinguisticTagPunctuation;
extern NSString * const NSLinguisticTagWhitespace;
extern NSString * const NSLinguisticTagOther;

extern NSString * const NSLinguisticTagNoun;
extern NSString * const NSLinguisticTagVerb;
extern NSString * const NSLinguisticTagAdjective;
extern NSString * const NSLinguisticTagAdverb;
extern NSString * const NSLinguisticTagPronoun;
extern NSString * const NSLinguisticTagDeterminer;
extern NSString * const NSLinguisticTagParticle;
extern NSString * const NSLinguisticTagPreposition;
extern NSString * const NSLinguisticTagNumber;
extern NSString * const NSLinguisticTagConjunction;
extern NSString * const NSLinguisticTagInterjection;
extern NSString * const NSLinguisticTagClassifier;
extern NSString * const NSLinguisticTagIdiom;
extern NSString * const NSLinguisticTagOtherWord;
extern NSString * const NSLinguisticTagSentenceTerminator;
extern NSString * const NSLinguisticTagOpenQuote;
extern NSString * const NSLinguisticTagCloseQuote;
extern NSString * const NSLinguisticTagOpenParenthesis;
extern NSString * const NSLinguisticTagCloseParenthesis;
extern NSString * const NSLinguisticTagWordJointer;
extern NSString * const NSLinguisticTagDash;
extern NSString * const NSLinguisticTagOtherPunctuation;
extern NSString * const NSLinguisticTagParagraphBreak;
extern NSString * const NSLinguisticTagOtherWhitespace;

extern NSString * const NSLinguisticTagPersonalName;
extern NSString * const NSLinguisticTagPlaceName;
extern NSString * const NSLinguisticTagOrganizationName;

@interface NSLinguisticTagger	:	NSObject

- (id) initWithTagSchemes:(NSArray *)schemes options:(NSUInteger)opts;

- (NSArray *) tagSchemes;
+ (NSArray *) availableTagSchemesForLanguage:(NSString *)lang;

- (NSString *) string;
- (void) setString:(NSString *)string;
- (NSString *) stringEditedInRange:(NSRange)range changeInLength:(NSInteger)deltaLen;

- (void) setOrthography:(NSOrthography *)orth range:(NSRange)range;
- (NSOrthography *) orthographyAtIndex:(NSUInteger)idx effectiveRange:(NSRange *)rangep;

- (void) enumerateTagsInRange:(NSRange)range scheme:(NSString *)tagScheme options:(NSLinguisticTaggerOptions)opts usingBlock:(void (^)(NSString *, NSRange, NSRange, bool *))block;
- (NSArray *) possibleTagsAtIndex:(NSUInteger)charIndex scheme:(NSString *)tagScheme tokenRange:(NSRangePointer)tokenRange sentenceRange:(NSRangePointer)sentenceRange scores:(NSArray **)scores;
- (NSString *) tagAtIndex:(NSUInteger)charIndex scheme:(NSString *)tagScheme tokenRange:(NSRangePointer)tokenRange sentenceRange:(NSRangePointer)sentenceRange;
- (NSArray *) tagsInRange:(NSRange)range scheme:(NSString *)tagScheme options:(NSLinguisticTaggerOptions)opts tokenRanges:(NSArray **)tokenRanges;

@end

@interface NSString (NSLinguisticTagging)
- (void) enumerateLinguisticTagsInRange:(NSRange)range scheme:(NSString *)tagScheme options:(NSLinguisticTaggerOptions)opts orthography:(NSOrthography *)orth usingBlock:(void (^)(NSString *, NSRange, NSRange, bool *);
- (NSArray *) linguisticTagsInRange:(NSRange)range scheme:(NSString *)tagScheme options:(NSLinguisticTaggerOptions)opts orthography:(NSOrthography *)orth tokenRanges:(NSArray **)tokenRanges;
@end
