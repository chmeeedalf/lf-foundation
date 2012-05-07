/* Copyright (c) 2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>

@interface NSIndexSet : NSObject <NSCoding,NSCopying,NSMutableCopying>
{
   unsigned _length;
   NSRange *_ranges; 
}

+indexSetWithIndexesInRange:(NSRange)range;
+indexSetWithIndex:(unsigned)index;
+indexSet;

-initWithIndexSet:(NSIndexSet *)other;
-initWithIndexesInRange:(NSRange)range;
-initWithIndex:(unsigned)index;
-init;

-(bool)isEqualToIndexSet:(NSIndexSet *)other;

-(unsigned)count;
-(unsigned long)countOfIndexesInRange:(NSRange)range;
-(unsigned)firstIndex;
-(unsigned)lastIndex;
-(NSUInteger)getIndexes:(NSUInteger *)buffer maxCount:(NSUInteger)capacity inIndexRange:(NSRange *)range;

-(bool)containsIndexesInRange:(NSRange)range;
-(bool)containsIndexes:(NSIndexSet *)other;
-(bool)containsIndex:(unsigned)index;

-(unsigned)indexGreaterThanIndex:(unsigned)index;
-(unsigned)indexGreaterThanOrEqualToIndex:(unsigned)index;
-(unsigned)indexLessThanIndex:(unsigned)index;
-(unsigned)indexLessThanOrEqualToIndex:(unsigned)index;

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
#endif

@end

@interface NSMutableIndexSet : NSIndexSet
{
   unsigned _capacity;
}

-(void)addIndexesInRange:(NSRange)range;
-(void)addIndexes:(NSIndexSet *)other;
-(void)addIndex:(unsigned)index;

-(void)removeAllIndexes;
-(void)removeIndexesInRange:(NSRange)range;
-(void)removeIndexes:(NSIndexSet *)other;
-(void)removeIndex:(unsigned)index;

-(void)shiftIndexesStartingAtIndex:(unsigned)index by:(int)delta;

@end
