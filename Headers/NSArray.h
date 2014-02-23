/*
 * Copyright (c) 2004-2012	Justin Hibbits
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
#import <Foundation/NSRange.h>

@class NSDictionary;
@class NSEnumerator;
@class NSIndexSet;
@class NSLocale;
@class NSURL;

typedef NSUInteger NSBinarySearchingOptions;
enum
{
	NSBinarySearchingFirstEqual = (1 << 8),
	NSBinarySearchingLastEqual = (1 << 9),
	NSBinarySearchingInsertionIndex = (1 << 10),
};

/*!
 @class NSArray
 @brief Basic array class.
 @details The NSArray class a generic class for holding a contiguous list of
 Objective-C objects.  It is synonymous with a C array and STL Vector class.
 Currently the only concrete class holds all members in adjacent memory
 locations.  In the future, that may change, and linked lists may be added.

 Since the NSArray class is implemented as an abstract class, the concrete
 implementation is a class cluster.  Thus, subclasses may be written for
 preferred implementations.  To implement a subclass, the following methods must
 be overridden:
	\li -count
 	\li -objectAtIndex:
	\li -replaceObjectAtIndex;withObject: (NSMutableArray)
	\li -removeObjectAtIndex: (NSMutableArray)
	\li -insertObject:atIndex: (NSMutableArray)
 */
@interface NSArray	: NSObject <NSCoding,NSCopying,NSMutableCopying,NSFastEnumeration>

/*!
 * @brief Allocates an uninitialized NSArray object in a specific zone.
 * @param zone The zone in which to allocate the NSArray object.
 * @return Returns an unitialized NSArray object.
 */
+(id)allocWithZone:(NSZone*)zone;

/*!
 * @brief Returns an empty array.
 * @return Returns an empty array.
 */
+(id)array;

/*!
 * \brief Creates and returns an array with the contents of another array.
 */
+(id)arrayWithArray:(NSArray *)other;

+(id)arrayWithContentsOfURL:(NSURL *)url;

/*!
 * @brief Initializes an array with one element.
 * @param anObject NSObject to initialize the array with.
 * @return Returns an array initialized with one element.
 * @throw InvalidArgumentException anObject is nil.
 */
+(id)arrayWithObject:(id)anObject;

/*!
 * @brief Initializes an array with multiple objects.
 * @param firstObj The first object in the collection.
 * @return Returns an array with multiple objects.
 * @details The argument list is terminated by nil.
 */
+(id)arrayWithObjects:(id)firstObj, ...;

/*!
 * @brief Initializes an array with multiple objects.
 * @param firstObj NSArray of objects.
 * @param count NSNumber of objects.
 * @return Returns an array with multiple objects.
 */
+(id)arrayWithObjects:(const id[])firstObj count:(NSUInteger)count;

/*!
 * @brief Duplicates an array into a new instance.
 * @param anotherArray NSArray to clone.
 * @return Returns the initialized array which is a clone of the passed array.
 */
-(id)initWithArray:(NSArray*)anotherArray;

/*!
 * @brief Duplicates an array into a new instance.
 * @param anotherArray NSArray to clone.
 * @param flag Whether or not to copy the items into the new array.
 * @return Returns the initialized array which is a clone of the passed array.
 */
-(id)initWithArray:(NSArray*)anotherArray copyItems:(bool)flag;

-(id)initWithContentsOfURL:(NSURL *)url;

/*!
 * @brief Initializes an array with a set of objects.
 * @param firstObj First object in the argument list.
 * @return Returns an array containing all the objects passed.
 * @details Terminate the argument list with a nil.
 */
-(id)initWithObjects:(id)firstObj, ...;

/*!
 * @brief Initializes an array with a number of objects from an array.
 * @param objects NSArray of objects to add.
 * @param count NSNumber of objects to insert.
 * @return Returns an initialized array containing the objects.
 */
-(id)initWithObjects:(const id[])objects count:(NSUInteger)count;

// Querying the array....

/*!
 * @brief returns true if an object is present in the array.
 * @param anObject NSObject to check for presence in the array.
 * @return returns true if anObject is present, NO if not.
 */
-(bool)containsObject:(id)anObject;

/*!
 * @brief Returns the number of objects currently in the array.
 * @return Returns the number of objects currently in the array.
 */
-(NSUInteger)count;

/*!
 */
- (void) getObjects:(__unsafe_unretained id [])objs range:(NSRange)range;

/*!
 * @brief Returns the first object in the array.
 * @return Returns the first object in the array.
 */
-(id)firstObject;

/*!
 * @brief Returns the last object in the array.
 * @return Returns the last object in the array.
 */
-(id)lastObject;

/*!
 * @brief Returns the object at the specified index.
 * @param index Index of the object to return.
 * @return The object at the specified index, or RangeException if index is beyond the size of the array.
 */
-(id)objectAtIndex:(NSUInteger)index;

/*!
 * @brief Returns the objects at the specified indices.
 * @param indices Indices of the objects to return.
 * @return The object at the specified indices, or RangeException if any index is beyond the size of the array.
 */
- (NSArray *)objectsAtIndexes:(NSIndexSet *)indices;

/*!
 * @brief Returns the enumerator for this array.
 * @return Returns the enumerator for accessing this array, starting with the first element.
 */
-(NSEnumerator *)objectEnumerator;

/*!
 * @brief Returns the enumerator for this array.
 * @return Returns the enumerator for accessing this array, starting with the last element.
 */
-(NSEnumerator *)reverseObjectEnumerator;


/*!
 * @brief Returns the index an object occurs at.
 * @param anObject NSObject to find the index of.
 * @return Returns the index the object occurs at.
 * @details This method uses isEqual: to compare objects.
 */
-(NSUInteger)indexOfObject:(id)anObject;

/*!
 * @brief Returns the index an object occurs at.
 * @param anObject NSObject to find the index of.
 * @param range NSRange to search in.
 * @return Returns the index the object occurs at.
 * @details This method uses isEqual: to compare objects.
 */
-(NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range;

/*!
 * @brief Returns the index of an object identical to the passed object.
 * @param anObject NSObject to find the index of.
 * @return Returns the index of the object identical to the passed object, or NotFound.
 * @details This method checks last to first, and compares id's.
 */
-(NSUInteger)indexOfObjectIdenticalTo:(id)anObject;

/*!
 * @brief Returns the index of an object identical to the passed object.
 * @param anObject NSObject to find the index of.
 * @param range NSRange to search in.
 * @return Returns the index of the object identical to the passed object, or NotFound.
 * @details This method checks last to first, and compares id's.
 */
-(NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range;

#if __has_feature(blocks)
- (NSUInteger) indexOfObjectPassingTest:(bool (^)(id obj, NSUInteger idx, bool *stop))predicate;

- (NSUInteger) indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(bool (^)(id obj, NSUInteger idx, bool *stop))predicate;

- (NSUInteger) indexOfObjectAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts passingTest:(bool (^)(id obj, NSUInteger idx, bool *stop))predicate;

- (NSIndexSet *) indexesOfObjectsPassingTest:(bool (^)(id obj, NSUInteger idx, bool *stop))predicate;

- (NSIndexSet *) indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(bool (^)(id obj, NSUInteger idx, bool *stop))predicate;

- (NSIndexSet *) indexesOfObjectsAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts passingTest:(bool (^)(id obj, NSUInteger idx, bool *stop))predicate;
#endif

- (NSUInteger) indexOfObject:(id)obj inSortedRange:(NSRange)r options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp;

// Sending messages to elements

/*!
 * @brief Sends a selector message to each object in the array.
 * @param aSelector Selector to send to the objects.
 */
-(void)makeObjectsPerformSelector:(SEL)aSelector;

/*!
 * @brief Sends a selector message to each object, along with an object to perform on.
 * @param aSelector Selector to send to objects.
 * @param anObject NSObject to send as a parameter.
 */
-(void)makeObjectsPerformSelector:(SEL)aSelector withObject:anObject;

#if __has_feature(blocks)
- (void) enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, bool *stop))block;
- (void) enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, bool *stop))block;
- (void) enumerateObjectsAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, bool *stop))block;
#endif


// Comparing Arrays....

/*!
 * @brief Returns the first object from the receiver's array that's equal to an object in another array.
 * @param otherArray NSArray to compare with.
 * @return Returns the first object equal to an object in the given array.
 */
-(id)firstObjectCommonWithArray:(NSArray *)otherArray;

/*!
 * @brief Compares the receiving array to the given array.
 * @param otherArray NSArray to compare with the receiving array.
 * @return Returns true if they are equal, NO if they are not.
 */
-(bool)isEqualToArray:(NSArray *)otherArray;

// Deriving new arrays....

/*!
 * \brief Returns a new array with the contents of the receiver plus one
 * additional element.
 */
-(NSArray *)arrayByAddingObject:(id)obj;

/*!
 * \brief Returns a new array with the contents of both the receiver and another
 * array.
 */
-(NSArray *)arrayByAddingObjectsFromArray:(NSArray *)other;

/*!
 * @brief Returns an array that consists of a range of the receiver's elements.
 * @param range NSRange of objects to get.
 * @return Returns a subarray of the receiver, consisting of the given range.
 */
-(NSArray *)subarrayWithRange:(NSRange)range;

- (NSData *) sortedArrayHint;
- (NSArray *) sortedArrayUsingComparator:(NSComparator)cmp;
- (NSArray *) sortedArrayUsingDescriptors:(NSArray *)sortDescriptors;
- (NSArray *) sortedArrayUsingFunction:(NSComparisonResult (*)(id, id, void *))comparator context:(void *)ctx;
- (NSArray *) sortedArrayUsingFunction:(NSComparisonResult (*)(id, id, void *))comparator context:(void *)ctx hint:(NSData *)hint;
- (NSArray *) sortedArrayUsingSelector:(SEL)sel;
- (NSArray *) sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmp;


// Joining string elements

/*!
 * @brief Returns a string consisting of elements joined by a given string.
 * @param separator Separator to use when joining the elements.
 * @return NSString consisting of the elements of the array joined by the given string.
 */
-(NSString *)componentsJoinedByString:(NSString *)separator;

// Creating a string description of the array

/*!
 * @brief Returns a string representation of the array.
 */
-(NSString *)description;

/*!
 * @brief Returns a localized string representation of the array.
 * @param localeDictionary NSLocale dictionary to use for localization.
 * @return Returns a localizes string representation of the array.
 */
-(NSString *)descriptionWithLocale:(NSLocale*)localeDictionary;

/*!
 * @brief Returns a localized string representation of the array, indented for easier reading.
 * @param localeDictionary NSLocale dictionary to use for localization.
 * @param level Indent level to use, gets multiplied by 4 spaces.
 * @return Returns a localizes string representation of the array.
 */
-(NSString *)descriptionWithLocale:(NSLocale *)localeDictionary
	indent:(NSUInteger)level;

-(bool) writeToURL:(NSURL *)url atomically:(bool)atomic;

/*!
  @brief Return the object at the given index.
   This is short-hand for objectAtIndex:
 */
-(id):(NSUInteger)idx;

- (id) objectAtIndexedSubscript:(NSUInteger)index;
@end

/*!
 * @class NSMutableArray
 * @brief Mutable version of basic array class.
 *
 * Mutable subclass of NSArray.  This allows items to be added, removed, and
 * replaced within the array.
 */
@interface NSMutableArray	: NSArray

/*!
 * @brief Creates and returns an array with a given capacity in the default zone.
 * @param aNumItems NSNumber of items to hold.
 * @return Returns an array holding a specified number of elements.
 */
+(id)arrayWithCapacity:(NSUInteger)aNumItems;

/*!
 * @brief Initializes an allocated array with a given capacity.
 * @param aNumItems NSNumber of items the array should hold.
 * @return Returns an initialized array with a given capacity.
 */
-(id)initWithCapacity:(NSUInteger)aNumItems;

// Adding objects

/*!
 * @brief Adds an object to the array.
 * @param anObject NSObject to add.
 */
-(void)addObject:(id)anObject;

/*!
 * @brief Appends the objects from another array to the receiver.
 * @param anotherArray The array to get the objects from.
 */
-(void)addObjectsFromArray:(NSArray *)anotherArray;

/*!
 * @brief Inserts an object at the given index.
 * @param anObject NSObject to insert into the array.
 * @param index Index to insert the object at.
 */
-(void)insertObject:(id)anObject atIndex:(NSUInteger)index;

/*!
 * @brief Inserts an object at the given index.
 * @param anObject NSObject to insert into the array.
 * @param index Index to insert the object at.
 */
-(void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;

// Removing objects

/*!
 * @brief Removes and releases all objects from the array.
 */
-(void)removeAllObjects;

/*!
 * @brief Removes and releases the last object in the array.
 */
-(void)removeLastObject;

/*!
 * @brief Removes and releases all occurances of an object.  isEqual is used to test.
 * @param anObject NSObject to remove from the array.
 */
-(void)removeObject:(id)anObject;

/*!
 * \brief Removes all occurrences of a given object in the given range  from the receiver.
 */
-(void)removeObject:(id)anObject inRange:(NSRange)range;

/*!
 * @brief Removes and releases the object located at the given index.
 * @param index Index of the object to remove.
 */
-(void)removeObjectAtIndex:(NSUInteger)index;

- (void) removeObjectsAtIndexes:(NSIndexSet *)indexes;

/*!
 * @brief Removes and releases all objects identical to the passed object.
 * @param anObject NSObject to compare and remove.
 */
-(void)removeObjectIdenticalTo:(id)anObject;

/*!
 * @brief Removes and releases all objects identical to the passed object in the
 * given range.
 * @param anObject NSObject to compare and remove.
 */
-(void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range;

/*!
 * @brief Removes and releases the objects in the receiver that match the passed array.
 * @param otherArray NSArray to find the objects to release from the receiver.
 */
-(void)removeObjectsInArray:(NSArray *)otherArray;

/*!
  @brief Removes objects in the given range.
  @param aRange NSRange of objects to remove from the array.
 */
- (void)removeObjectsInRange:(NSRange)aRange;

// Replacing objects

/*!
 * @brief Replaces the object at the given index with another object.
 * @param index Index of the object to replace.
 * @param anObject NSObject to replace with.
 * @throw InvalidArgumentException anObject is nil.
 * @throw RangeException index is not within the bounds of the array.
 */
-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

/*!
 * @brief Replaces the objects at the given indices with objects from the given
 * array.
 */
-(void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects;

/*!
 * @brief Replaces the objects in the receiver specified by the given range with all the objects from the given array.
 * @param aRange NSRange of objects to replace.
 * @param otherArray NSArray to get the replacement objects from.
 */
-(void)replaceObjectsInRange:(NSRange)aRange 
	withObjectsFromArray:(NSArray *)otherArray;

/*!
 * @brief Replaces the objects in the receiver specified by the given range with objects from the given array in the given index.
 * @param aRange NSRange of objects to replace.
 * @param otherArray NSArray to get the replacement objects from.
 * @param otherRange NSRange of objects from the other array for replacements.
 */
-(void)replaceObjectsInRange:(NSRange)aRange 
	withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange;

/*!
 * @brief Set the receiver to another array, sorting the elements.
 * @param otherArray NSArray to set the receiver to.
 */
-(void)setArray:(NSArray *)otherArray;

/*!
 * \brief Exchange two objects in the receiver.
 */
-(void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
/*!
 * @brief Sorts the array using the given function.
 * @param comparator Comparing function to sort with.
 * @param context Arbitrary third parameter to the sorting function.
 */
-(void)sortUsingFunction:(NSComparisonResult (*)(id, id, void *))comparator
	context:(void *)context;

/*!
 * @brief Sorts the array using the given selector.
 * @param comparator Selector used to sort the array.
 */
-(void)sortUsingSelector:(SEL)comparator;

/*!
 * \brief Sorts the receiver using the given descriptors.
 */
-(void)sortUsingDescriptors:(NSArray *)descriptors;

- (void) sortUsingComparator:(NSComparator)cmp;
- (void) sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmp;

- (void) setObject:(id)newObject atIndexedSubscript:(NSUInteger)index;
@end

/*!
 * @brief Functional programming extensions for NSArray class.
 */
@interface NSArray(Functional)

/*!
  @brief	Makes all objects perform a selector and returns an array of the
  results.
  @details Example:  \code [[anArray map] fooBar:baz withObject:foo]; \endcode
 */
- (id)map;

/*!
  @brief	Returns a proxy to be used to return an array of all objects which
  respond to a given selector with 'true'.
  @details Example:  \code [[anArray filter] respondsToSelector:\@selector("foo")]; \endcode
 */
- (id)filter;
@end

/*
   vim:syntax=objc:
 */
