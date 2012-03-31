/*
 * Copyright (c) 2010-2011	Justin Hibbits
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

@interface NSIndexPath	:	NSObject<NSCopying,NSCoding>
{
	NSUInteger *_indexes;
	size_t _length;
	NSHashCode _hash;
}

+ (id) indexPathWithIndex:(NSUInteger)index;
+ (id) indexPathWithIndexes:(NSUInteger *)indexes length:(size_t)length;
- (id) initWithIndex:(NSUInteger)index;
- (id) initWithIndexes:(NSUInteger *)indexes length:(size_t)len;

- (void) getIndexes:(NSUInteger *)indexes;
- (NSUInteger) indexAtPosition:(NSUInteger)pos;
- (NSIndexPath *) indexPathByAddingIndex:(NSUInteger)idx;
- (NSIndexPath *) indexPathByRemovingLastIndex;
- (size_t) length;

- (NSComparisonResult) compare:(NSIndexPath *)other;
@end
