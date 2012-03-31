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
#import <Foundation/NSEnumerator.h>

@class NSArray, NSEnumerator, NSIndexSet, NSString, NSLocale, NSSet;

/*!
 * \class NSOrderedSet
 */
@interface NSOrderedSet	: NSObject <NSCoding,NSCopying,NSMutableCopying,NSFastEnumeration>

+ (id) orderedSet;
+ (id) orderedSetWithArray:(NSArray *)array;
+ (id) orderedSetWithArray:(NSArray *)array range:(NSRange)range copyItems:(bool)copy;
+ (id) orderedSetWithObject:(id)obj;
+ (id) orderedSetWithObjects:(id)obj,...;
+ (id) orderedSetWithObjects:(const id[])objs count:(NSUInteger)count;
+ (id) orderedSetWithOrderedSet:(NSOrderedSet *)set;
+ (id) orderedSetWithOrderedSet:(NSOrderedSet *)set range:(NSRange)range copyItems:(bool)copy;
+ (id) orderedSetWithSet:(NSSet *)set;
+ (id) orderedSetWithSet:(NSSet *)set range:(NSRange)range copyItems:(bool)copy;

- (id) initWithArray:(NSArray *)array;
- (id) initWithArray:(NSArray *)array range:(NSRange)range copyItems:(bool)copy;
- (id) initWithObject:(id)obj;
- (id) initWithObjects:(id)obj,...;
- (id) initWithObjects:(const id[])objs count:(NSUInteger)count;
- (id) initWithOrderedSet:(NSOrderedSet *)set;
- (id) initWithOrderedSet:(NSOrderedSet *)set range:(NSRange)range copyItems:(bool)copy;
- (id) initWithSet:(NSSet *)set;
- (id) initWithSet:(NSSet *)set range:(NSRange)range copyItems:(bool)copy;

- (NSUInteger) count;

- (bool) containsObject:(id)obj;
- (void) enumerateObjectsAtIndexes:(NSIndexSet *)indexes options:(NSEnumerationOptions) usingBlock:(void (^)(id, NSUInteger, bool *))block;
- (void) enumerateObjectsUsingBlock:(void (^)(id, NSUInteger, bool *))block;
- (void) enumerateObjectsWithOptions:(NSEnumerationOptions) usingBlock:(void (^)(id, NSUInteger, bool *))block;
- (id) firstObject;
- (id) lastObject;
- (id) objectAtIndex:(NSUInteger)index;
- (NSArray *) objectsAtIndexes:(NSIndexSet *)indexes;
- (NSUInteger) indexOfObject:(id)obj;
- (NSUInteger) indexOfObject:(id)obj inSortedRange:(NSRange)range options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp;
- (NSUInteger) indexOfObjectAtIndexes:(NSIndexSet *)indexes options:(NSEnumerationOptions)opts passingTest:(bool (^)(id, NSUInteger, bool *))predicate;
- (NSUInteger) indexOfObjectPassingTest:(bool (^)(id, NSUInteger, bool *))predicate;
- (NSUInteger) indexOfObjectWithOptions:(NSBinarySearchingOptions)opts passingTest:(bool (^)(id, NSUInteger, bool *))predicate;;
- (NSIndexSet *) indexesOfObjectsAtIndexes:(NSIndexSet *)indexes options:(NSEnumerationOptions)opts passingTest:(bool (^)(id, NSUInteger, bool *))predicate;
- (NSIndexSet *) indexesOfObjectsPassingTest:(bool (^)(id, NSUInteger, bool *))predicate;
- (NSIndexSet *) indexesOfObjectsWithOptions:(NSBinarySearchingOptions)opts passingTest:(bool (^)(id, NSUInteger, bool *))predicate;;
- (NSEnumerator *) objectEnumerator;
- (NSEnumerator *) reverseObjectEnumerator;
- (NSOrderedSet *) reversedOrderedSet;
- (void) getObjects:(id[])objs range:(NSRange)range;

- (bool) isEqualToOrderedSet:(NSOrderedSet *)other;
- (bool) intersectsOrderedSet:(NSOrderedSet *)other;
- (bool) intersectsSet:(NSSet *)other;
- (bool) isSubsetOfOrderedSet:(NSOrderedSet *)other;
- (bool) isSubsetOfSet:(NSSet *)set;

- (NSArray *) sortedArrayUsingComparator:(NSComparator)cmp;
- (NSArray *) sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmp;

- (NSString *) description;
- (NSString *) descriptionWithLocale:(NSLocale *)locale;
- (NSString *) descriptionWithLocale:(NSLocale *)locale indent:(NSUInteger)indent;

- (NSArray *) array;
- (NSSet *) set;
@end

@interface NSMutableOrderedSet	:	NSOrderedSet
+ (id) orderedSetWithCapacity:(NSUInteger)cap;
- (id) initWithCapacity:(NSUInteger)cap;

- (void) addObject:(id)obj;
- (void) addObjects:(const id[])objs count:(NSUInteger)count;
- (void) addObjectsFromArray:(NSArray *)array;
- (void) insertObject:(id)obj atIndex:(NSUInteger)idx;
- (void) insertObjects:(NSArray *)objs atIndexes:(NSIndexSet *)idxs;
- (void) removeObject:(id)obj;
- (void) removeObjectAtIndex:(id)idx;
- (void) removeObjectsAtIndexes:(NSIndexSet *)idxs;
- (void) removeObjectsInArray:(NSArray *)array;
- (void) removeObjectsInRange:(NSRange)range;
- (void) removeAllObjects;
- (void) replaceObjectAtIndex:(NSUInteger)idx withObject:(id)obj;
- (void) replaceObjectsAtIndexes:(NSIndexSet *)idxs withObjects:(NSArray *)objs;
- (void) replaceObjectsInRange:(NSRange)range withObjects:(const id[])objs count:(NSUInteger)count;
- (void) setObject:(id)obj atIndex:(NSUInteger)idx;
- (void) moveObjectsAtIndexes:(NSIndexSet *)idxs toIndex:(NSUInteger)newIdx;
- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;

- (void) sortUsingComparator:(NSComparator)cmp;
- (void) sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmp;
- (void) sortRange:(NSRange)range options:(NSSortOptions)opts usingComparator:(NSComparator)cmp;

- (void) intersectOrderedSet:(NSOrderedSet *)other;
- (void) intersectSet:(NSSet *)other;
- (void) minusOrderedSet:(NSOrderedSet *)other;
- (void) minusSet:(NSSet *)other;
- (void) unionOrderedSet:(NSOrderedSet *)other;
- (void) unionSet:(NSSet *)other;

@end
/*
   vim:syntax=objc:
 */
