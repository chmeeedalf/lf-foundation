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
#import <Foundation/NSTextCheckingResult.h>

@class NSDictionary;
@class NSOrthography;
@class NSSpellServer;
@class NSString;

extern NSString * const NSGrammarRange;
extern NSString * const NSGrammarUserDescription;
extern NSString * const NSGrammarCorrections;

@protocol NSSpellServerDelegate<NSObject>
@optional
- (NSRange) spellServer:(NSSpellServer *)server checkString:(NSString *)str offset:(NSUInteger)offset types:(NSTextCheckingTypes)checkingTypes options:(NSDictionary *)opts orthography:(NSOrthography *)orthography wordCount:(NSInteger *)wordCount;
- (NSArray *) spellServer:(NSSpellServer *)server suggestGuessesForWord:(NSString *)word inLanguage:(NSString *)lang;
- (NSRange) spellServer:(NSSpellServer *)server checkGrammarInString:(NSString *)string language:(NSString *)language details:(NSArray **)outDetails;
- (NSRange) spellServer:(NSSpellServer *)server findMisspelledWordInString:(NSString *)string language:(NSString *)lang wordCount:(NSInteger *)wordCount countOnly:(bool)countOnly;

- (void) spellServer:(NSSpellServer *)server didForgetWord:(NSString *)word inLanguage:(NSString *)lang;
- (void) spellServer:(NSSpellServer *)server didLearnWord:(NSString *)word inLanguage:(NSString *)lang;
- (NSArray *) spellServer:(NSSpellServer *)server suggestCompletionsForPartialWordRange:(NSRange)range inString:(NSString *)word language:(NSString *)lang;
- (void) spellServer:(NSSpellServer *)server recordResponse:(NSUInteger)response toCorrection:(NSString *)correction forWord:(NSString *)word language:(NSString *)lang;

@end

@interface NSSpellServer	:	NSObject
- (void) setDelegate:(id<NSSpellServerDelegate>)newDel;
- (id<NSSpellServerDelegate>) delegate;

- (bool) registerLanguage:(NSString *)language byVendor:(NSString *)vendor;
- (void) run;

- (bool) isWordInUserDictionaries:(NSString *)word caseSensitive:(bool)caseSensitive;
@end
