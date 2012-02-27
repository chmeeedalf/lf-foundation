/*
 * Copyright (c) 2009-2011	Gold Project
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

#import <Foundation/NSObject.h>

enum {
	NSAttributedStringEnumerationReverse = (1UL << 1),
	NSAttributedStringEnumerationLongestEffectiveRangeNotRequired = (1UL << 20),
};
typedef NSUInteger NSAttributedStringEnumerationOptions;

@class NSString, NSMutableString, NSDictionary;
@interface NSAttributedString	:	NSObject<NSCoding,NSCopying,NSMutableCopying>
- initWithString:(NSString *)str;
- initWithString:(NSString *)str attributes:(NSDictionary *)attributes;
- initWithAttributedString:(NSAttributedString *)str;

- (NSString *) string;
- (size_t) length;

- (NSDictionary *) attributesAtIndex:(NSIndex)idx effectiveRange:(NSRange *)range;
- (NSDictionary *) attributesAtIndex:(NSIndex)idx longestEffectiveRange:(NSRange *)range inRange:(NSRange)inRange;
- (id) attribute:(NSString *)attrib atIndex:(NSIndex)idx effectiveRange:(NSRange *)range;
- (id) attribute:(NSString *)attrib atIndex:(NSIndex)idx longestEffectiveRange:(NSRange *)range inRange:(NSRange)inRange;

- (NSAttributedString *) attributedSubstringFromRange:(NSRange)range;
- (bool) isEqualToAttributedString:(NSAttributedString *)otherString;

#if __has_feature(blocks)
- (void) enumerateAttribute:(NSString *)attrName inRange:(NSRange)range options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id value, NSRange range, bool *stop))block;
- (void) enumerateAttributesInRange:(NSRange)range options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id value, NSRange range, bool *stop))block;
#endif
@end

@interface NSMutableAttributedString	:	NSAttributedString

- (NSMutableString *) mutableString;
- (void) setAttributedString:(NSAttributedString *)attribStr;

- (void) replaceCharactersInRange:(NSRange)r withString:(NSString *)str;
- (void) replaceCharactersInRange:(NSRange)r withAttributedString:(NSAttributedString *)str;
- (void) deleteCharactersInRange:(NSRange)r;

- (void) setAttributes:(NSDictionary *)attribs range:(NSRange)r;
- (void) addAttributes:(NSDictionary *)attribs range:(NSRange)r;
- (void) addAttribute:(NSString *)attribs value:(id)val range:(NSRange)r;
- (void) removeAttribute:(NSString *)attrib range:(NSRange)r;
- (void) appendAttributedString:(NSAttributedString *)attribString;
- (void) insertAttributedString:(NSAttributedString *)str atIndex:(NSIndex)idx;

- (void) beginEditing;
- (void) endEditing;
@end
