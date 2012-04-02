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

@class NSArray, NSEnumerator, NSString, NSLocale;

/*!
 * \class NSSet
 * \brief An unsorted set of objects.
 */
@interface NSSet	: NSObject <NSCoding,NSCopying,NSMutableCopying,NSFastEnumeration>

// Allocating and initializing a set
/*!
 * \brief Creates and allocates an unitialized set object in the given zone.
 * \param zone Zone into which to allocate the set.
 */
+(id)allocWithZone:(NSZone *)zone;

/*!
 * \brief Creates and returns an empty set object.
 */
+(id)set;

/*!
 * \brief Creates and returns a set composed of objects from the passed array.
 * \param array NSArray containing the objects to insert into the set.
 */
+(id)setWithArray:(NSArray *)array;

/*!
 * \brief Creates and returns a set containing one object.
 * \param anObject NSObject to insert into the set.
 */
+(id)setWithObject:(id)anObject;

/*!
 * \brief Creates and returns a set containing the passed objects.
 * \param firstObj NSObject list to insert into the set, terminated with <b>nil</b>
 * \param count NSNumber of objects in the array.
 */
+(id)setWithObjects:(const id[])firstObj count:(unsigned)count;

/*!
 * \brief Creates and returns a set containing the passed objects.
 * \param firstObj NSObject list to insert into the set, terminated with <b>nil</b>
 */
+(id)setWithObjects:(id)firstObj,...;

/*!
 * \brief Creates and returns a set that's a copy of the argument.
 * \param other Source set.
 */
+(id)setWithSet:(NSSet *)other;

/*!
 * \brief Initializes a newly allocated set with the objects from the passed array.
 * \param array NSArray containing the objects to insert into the set.
 */
-(id)initWithArray:(NSArray *)array;

/*!
 * \brief Initializes a newly allocated set object with the objects in the argument list.
 * \param firstObj <b>nil</b> terminated argument list containing objects to insert into the set.
 */
-(id)initWithObjects:(id)firstObj,...;

/*!
 * \brief Initializes a newly allocated set object with the given number of objects.
 * \param objects NSArray of objects to insert into the array.
 * \param count NSNumber of objects to insert.
 */
-(id)initWithObjects:(const id[])objects count:(unsigned int)count;

/*!
 * \brief Initializes a newly allocated set object with the contents of another set.
 * \param anotherSet NSSet containing the objects to insert into the receiver.
 */
-(id)initWithSet:(NSSet *)anotherSet;

/*!
 * \brief Initializes a newly allocated set object with the contents of another array, copying them if the flag is true.
 * \param set NSSet containing objects to insert into the array.
 * \param flag If true, copies the objects, if NO just retains them.
 */
-(id)initWithSet:(NSSet *)set copyItems:(bool)flag;

- (NSSet *) setByAddingObject:(id)anObject;
- (NSSet *) setByAddingObjectsFromArray:(NSArray *)other;
- (NSSet *) setByAddingObjectsFromSet:(NSSet *)other;

// Querying the set
/*!
 * \brief Returns an array containing all the objects in the set.
 */
-(NSArray *)allObjects;

/*!
 * \brief Returns an object in the set, or <b>nil</b> if the set is empty.
 */
-(id)anyObject;

/*!
 * \brief Returns true if the passed object is in the set.
 * \param anObject NSObject to find in the set.
 */
-(bool)containsObject:(id)anObject;

/*!
 * \brief Returns the number of objects currently in the set.
 */
-(NSIndex)count;

/*!
 * \brief Returns the object in the set that is equal to the given object, or <b>nil</b> if none is equal.
 * \param anObject NSObject to search for.
 */
-(id)member:(id)anObject;

/*!
 * \brief Returns an enumerator object that lets you access each object in the set.
 */
-(NSEnumerator *)objectEnumerator;

#if __has_feature(blocks)
- (void) enumerateObjectsUsingBlock:(void (^)(id obj, bool *stop))block;
- (void) enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, bool *stop))block;
- (NSSet *) objectsPassingTest:(bool (^)(id obj, bool *stop))predicate;
- (NSSet *) objectsWithOptions:(NSEnumerationOptions)opts passingTest:(bool (^)(id obj, bool *stop))predicate;
#endif

// Sending messages to elements of the set
/*!
 * \brief Sends a given selector to each object in the set.
 * \param aSelector Selector message to send to the objects.
 */
-(void)makeObjectsPerformSelector:(SEL)aSelector;

/*!
 * \brief Sends a selector message to each object in the set, with the given object as an argument.
 * \param aSelector Selector message to send to the objects.
 * \param anObject NSObject to send as an extra argument.
 */
-(void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)anObject;

// Comparing sets
/*!
 * \brief Returns true if there's any object in the receiving set that's equal to an object in the passed set.
 * \param otherSet NSSet to find an intersection of with the receiver.
 */
-(bool)intersectsSet:(NSSet *)otherSet;

/*!
 * \brief Returns true if every object in the receiver is equal to that in the passed set.
 * \param otherSet NSSet to find an intersection of with the receiver.
 */
-(bool)isEqualToSet:(NSSet *)otherSet;

/*!
 * \brief Returns true if every object in the receiver is equal to an object in the passed set, and the receiving set contains no more objects than the passed set.
 * \param otherSet Supserset of the receiver.
 */
-(bool)isSubsetOfSet:(NSSet *)otherSet;

// Creating a string description of the set
/*!
 * \brief Returns a string object that describes the contents of the receiver.
 */
-(NSString *)description;

/*!
 * \brief Returns a string representation of the receiver, including keys and values that represent the locale data from the given locale dictionary.
 * \param localeDictionary NSLocale dictionary to use in description.
 */
-(NSString *)descriptionWithLocale:(NSLocale *)localeDictionary;

/*!
 * \brief Returns a string representation of the receiver, including keys and values that represent the locale data from the given locale dictionary.
 * \param locale NSLocale dictionary to use in description.
 * \param indent Indent level.
 */
- (NSString*)descriptionWithLocale:(NSLocale*)locale
   indent:(unsigned int)indent;

- (NSArray *)sortedArrayUsingDescriptors:(NSArray *)sortDescriptors;
@end

@interface NSMutableSet	:	NSSet

/*!
 * \brief Creates and returns a set with the given capacity.
 * \param numItems Capacity of the set.
 */
+(id)setWithCapacity:(unsigned int)numItems;

/*!
 * \brief Initializes a newly allocated set object with the given capacity.
 * \param numItems Capacity of the set.
 */
-(id)initWithCapacity:(unsigned int)numItems;

// Adding objects
/*!
 * \brief Adds the given object to the receiver unless an equal object is already there.
 * \param object NSObject to insert into the set.
 */
-(void)addObject:(id)object;

/*!
 * \brief Adds all the objects in the given array into the receiver by calling addObject: on each member.
 * \param array NSArray whose contents to add to the set.
 */
-(void)addObjectsFromArray:(NSArray *)array;

/*!
 * \brief Adds to the receiver all the objects in the passed set by calling addObject: for each one.
 * \param other NSSet to union with the receiver.
 */
-(void)unionSet:(NSSet *)other;

// Removing objects
/*!
 * \brief Removes from the receiver every object that's not equal to an object in the passed set by calling removeObject:.
 * \param other NSSet to intersect with the receiver.
 */
-(void)intersectSet:(NSSet *)other;

/*!
 * \brief Removes from the receiver every object that's equal to some object in the passed set by calling removeObject:.
 * \param other NSSet to remove from the receiver.
 */
-(void)minusSet:(NSSet *)other;

/*!
 * \brief Empties the set of all its elements.
 */
-(void)removeAllObjects;

/*!
 * \brief Removes any object equal to the passed object from the set.
 * \param object NSObject to remove from the set.
 */
-(void)removeObject:(id)object;

- (void) setSet:(NSSet *)other;

@end

/*!
 * \class CountedSet
 */
@interface NSCountedSet	: NSMutableSet
// Allocating and initializing a set

/*!
 * \brief Initializes a newly allocated set object with the given capacity.
 * \param numItems Capacity of the set.
 */
-(id)initWithCapacity:(unsigned int)numItems;

/*!
 * \brief Initializes a newly allocated set object with the given array of
 * objects.
 * \param objects NSArray of objects to insert into the set.
 */
-(id)initWithArray:(NSArray *)objects;

/*!
 * \brief Initializes a newly allocated set object with the given set of * objects.
 * \param objects NSSet of objects to insert into the set.
 */
-(id)initWithSet:(NSSet *)objects;

/*!
 * \brief Returns the number of objects currently in the set.
 */
-(NSIndex)count;

/*!
 * \brief Returns the object in the set that is equal to the given object, or <b>nil</b> if none is equal.
 * \param anObject NSObject to search for.
 */
-(id)member:(id)anObject;

/*!
 * \brief Returns an enumerator object that lets you access each object in the set.
 */
-(NSEnumerator *)objectEnumerator;

// Sending messages to elements of the set
/*!
 * \brief Returns true if every object in the receiver is equal to that in the passed set.
 * \param otherSet NSSet to find an intersection of with the receiver.
 */
-(bool)isEqualToSet:(NSSet *)otherSet;

// Adding objects
/*!
 * \brief Adds the given object to the receiver unless an equal object is already there.
 * \param object NSObject to insert into the set.
 */
-(void)addObject:(id)object;

/*!
 * \brief Removes any object equal to the passed object from the set.
 * \param object NSObject to remove from the set.
 */
-(void)removeObject:(id)object;

-(size_t) countForObject:(id)object;

@end

/*
   vim:syntax=objc:
 */
