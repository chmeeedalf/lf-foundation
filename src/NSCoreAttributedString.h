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

#import <Foundation/NSObject.h>
#import <Foundation/NSAttributedString.h>

@interface _AttributedRange	: NSObject
{
	@public
		NSDictionary *attributes;
		NSRange range;
}
@end

@class NSArray, NSMutableArray;

@interface NSCoreAttributedString	:	NSAttributedString
{
	NSString *str;
	NSArray *attributeRanges;
}

- (id) initWithString:(NSString *)str attributes:(NSDictionary *)attributes;
- (id) initWithAttributedString:(NSAttributedString *)str;
- (id) string;

- (NSDictionary *)attributesAtIndex:(NSIndex)idx effectiveRange:(NSRange *)range;
@end

@interface CoreMutableAttributedString	:	NSMutableAttributedString
{
	NSMutableString *str;
	NSMutableArray *attributeRanges;
}

- (NSMutableString *)mutableString;

- (void) replaceCharactersInRange:(NSRange)r withString:(NSString *)str;

- (void) setAttributes:(NSDictionary *)attribs range:(NSRange)r;

- (void) beginEditing;
- (void) endEditing;
@end
