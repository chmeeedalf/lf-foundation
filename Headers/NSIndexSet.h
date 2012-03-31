/*
 * Copyright (c) 2008-2012	Justin Hibbits
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
/* Copyright (c) 2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>

@interface NSIndexSet : NSObject <NSCoding,NSCopying,NSMutableCopying>

+ (id) indexSetWithIndexesInRange:(NSRange)range;
+ (id) indexSetWithIndex:(NSUInteger)index;
+ (id) indexSet;

- (id) initWithIndexSet:(NSIndexSet *)other;
- (id) initWithIndexesInRange:(NSRange)range;
- (id) initWithIndex:(NSUInteger)index;
- (id) init;

-(bool)isEqualToIndexSet:(NSIndexSet *)other;

-(NSUInteger)count;
-(NSUInteger)countOfIndexesInRange:(NSRange)range;
-(NSUInteger)firstIndex;
-(NSUInteger)lastIndex;
-(NSUInteger)getIndexes:(NSUInteger *)buffer maxCount:(NSUInteger)capacity inIndexRange:(NSRange *)range;

-(bool)containsIndexesInRange:(NSRange)range;
-(bool)containsIndexes:(NSIndexSet *)other;
-(bool)containsIndex:(NSUInteger)index;

-(NSUInteger)indexGreaterThanIndex:(NSUInteger)index;
-(NSUInteger)indexGreaterThanOrEqualToIndex:(NSUInteger)index;
-(NSUInteger)indexLessThanIndex:(NSUInteger)index;
-(NSUInteger)indexLessThanOrEqualToIndex:(NSUInteger)index;

-(bool)intersectsIndexesInRange:(NSRange)range;

#if __has_feature(blocks)
- (NSUInteger) indexPassingTest:(bool (^)(NSUInteger, bool *))predicate;
- (NSUInteger) indexWithOptions:(NSEnumerationOptions)opts passingTest:(bool (^)(NSUInteger, bool *))predicate;
- (NSUInteger) indexInRange:(NSRange)range options:(NSEnumerationOptions)opts passingTest:(bool (^)(NSUInteger, bool *))predicate;
- (NSIndexSet *) indexesPassingTest:(bool (^)(NSUInteger, bool *))predicate;
- (NSIndexSet *) indexesWithOptions:(NSEnumerationOptions)opts passingTest:(bool (^)(NSUInteger, bool *))predicate;
- (NSIndexSet *) indexesInRange:(NSRange)range options:(NSEnumerationOptions)opts passingTest:(bool (^)(NSUInteger, bool *))predicate;

- (void) enumerateIndexesUsingBlock:(void (^)(NSUInteger, bool *))predicate;
- (void) enumerateIndexesWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(NSUInteger, bool *))predicate;
- (void) enumerateIndexesInRange:(NSRange)range options:(NSEnumerationOptions)opts usingBlock:(void (^)(NSUInteger, bool *))predicate;
- (void) enumerateRangesUsingBlock:(void (^)(NSRange, bool *))block;
- (void) enumerateRangesWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(NSRange, bool *))block;
- (void) enumerateRangesInRange:(NSRange)range options:(NSEnumerationOptions)opts usingBlock:(void (^)(NSRange, bool *))block;
#endif

@end

@interface NSMutableIndexSet : NSIndexSet
{
   unsigned _capacity;
}

-(void)addIndexesInRange:(NSRange)range;
-(void)addIndexes:(NSIndexSet *)other;
-(void)addIndex:(NSUInteger)index;

-(void)removeAllIndexes;
-(void)removeIndexesInRange:(NSRange)range;
-(void)removeIndexes:(NSIndexSet *)other;
-(void)removeIndex:(NSUInteger)index;

-(void)shiftIndexesStartingAtIndex:(NSUInteger)index by:(NSInteger)delta;

@end
