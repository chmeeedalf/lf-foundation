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

@class NSArray, NSEnumerator, NSLocale, NSSet, NSURL;

/*!
 \class NSDictionary
 \brief A key-value mapping collection.
 */
@interface NSDictionary	: NSObject <NSCoding,NSCopying,NSFastEnumeration,NSMutableCopying>

/// \category Creating and initializing an NSDictionary
/*!
 * \brief Allocates an unitialized NSDictionary in the specified zone.
 * \param zone Zone in which to allocate the dictionary object.
 */
+(id)allocWithZone:(NSZone *)zone;

/*!
 * \brief Creates and returns an empty NSDictionary object.
 */
+(id)dictionary;

/*!
 * \brief Creates and returns a new dictionary initialized with the
 * contents of another dictionary.
 * \param dictionary NSDictionary with which to initialize the receiver.
 */
+(id)dictionaryWithDictionary:(NSDictionary *)dictionary;

/*!
 * \brief Creates and returns an NSDictionary containing objects and keys from
 * the given arrays.
 * \param objects NSArray of objects to insert into the dictionary.
 * \param keys NSArray of keys to associate with the objects.
 */
+(id)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;

/*!
 * \brief Creates and returns a NSDictionary containing a single object and key.
 * \param objects NSArray of objects to insert into the dictionary.
 * \param keys NSArray of keys to associate with the objects.
 */
+(id)dictionaryWithObject:(id)objects forKey:(id<NSCopying>)key;

/*!
 * \brief Creates and returns an NSDictionary containing a given number of
 * objects from the passed array, associated with keys from the passed key
 * array.
 * \param objects NSArray of objects to insert into the dictionary.
 * \param keys NSArray of keys to associate with the objects.
 * \param count NSNumber of key/object pairs.
 */
+(id)dictionaryWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys
	count:(NSUInteger)count;

/*!
 * \brief Creates and returns an NSDictionary object that associates objects
 * and keys from the given argument list.
 * \param firstObject First object in the list of object,key,.. pairs.
 */
+(id)dictionaryWithObjectsAndKeys:(id)firstObject,...;

+(id)dictionaryWithContentsOfURL:(NSURL *)url;

+ (id) sharedKeySetForKeys:(NSArray *)keys;

/*!
 * \brief Initializes the newly allocated NSDictionary object with the
 * contents of another dictionary.
 * \param dictionary NSDictionary with which to initialize the receiver.
 */
-(id)initWithDictionary:(NSDictionary *)dictionary;

/*!
 * \brief Initializes the newly allocated NSDictionary object with a deep copy
 * of the contents of another dictionary.
 * \param dictionary NSDictionary with which to initialize the receiver.
 * \param copy Flag indicating to copy the contents instead of just retaining
 * them.
 */
-(id)initWithDictionary:(NSDictionary *)dictionary copyItems:(bool)copy;

/*!
 * \brief Initializes an NSDictionary object that associates objects and keys
 * from the given argument list.
 * \param firstObject First object in the list of object,key,.. pairs.
 */
-(id)initWithObjectsAndKeys:(id)firstObject,...;

/*!
 * \brief Initializes an NSDictionary object with the given Arrays of objects
 * and keys.
 * \param objects NSArray of objects to insert into the dictionary.
 * \param keys NSArray of keys to insert into the dictionary.
 */
-(id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;

/*!
 * \brief Initializes an NSDictionary containing a given number of objects
 * from the passed array, associated with keys from the passed key array.
 * \param objects NSArray of objects to insert into the dictionary.
 * \param keys NSArray of keys to associate with the objects.
 * \param count NSNumber of key/object pairs.
 */
-(id)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys
	count:(NSUInteger)count;

-(id)initWithContentsOfURL:(NSURL *)uri;

/// \category Accessing keys and values
/*!
 * \brief Returns an NSArray containing the receiver's keys, or an empty array
 * if the receiver is empty.
 */
-(NSArray *)allKeys;
- (NSArray *) allKeysForObject:(id)obj;

/*!
 * \brief Returns an NSArray containing all values from the receiver, or an
 * empty array if the receiver is empty.
 */
-(NSArray *)allValues;

- (void) getObjects:(__unsafe_unretained id[])objects andKeys:(__unsafe_unretained id[])keys;

/*!
 * \brief Returns the object associated with the given key.
 * \param aKey Key to search for.
 * \return The associated object.
 */
-(id)objectForKey:(id)aKey;
-(NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker;

/*!
 * \brief Returns an NSEnumerator that lets you access each of the receiver's
 * keys.
 */
-(NSEnumerator *)keyEnumerator;

/*!
 * \brief Returns an NSEnumerator that lets you access each of the receiver's
 * objects.
 */
-(NSEnumerator *)objectEnumerator;

#if __has_feature(blocks)
- (void) enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, bool *stop))block;
- (void) enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, bool *stop))block;
#endif

-(NSArray *)keysSortedByValueUsingSelector:(SEL)sel;
- (NSArray *) keysSortedByValueUsingComparator:(NSComparator)cmp;
- (NSArray *) keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmp;

#if __has_feature(blocks)
- (NSSet *) keysOfEntriesPassingTest:(bool (^)(id key, id obj, bool *stop))predicate;
- (NSSet *) keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(bool (^)(id key, id obj, bool *stop))predicate;
#endif

- (bool) writeToURL:(NSURL *)url atomically:(bool)atomically;

/// \category Counting entries
/*!
 * \brief Returns the number of key-value pairs in the receiver.
 */
-(NSUInteger)count;

// Comparing dictionaries
/*!
 * \brief Compares the receiver with the passed dictionary object.
 * \param other NSDictionary to compare with the receiver.
 * \return True if they are equal, NO if not.
 */
-(bool)isEqualToDictionary:(NSDictionary *)other;

/// \category Storing dictionaries
/*!
 * \brief Returns a string description of the receiver.
 */
-(NSString *)description;

/*!
 * \brief Returns a string description of the receiver using the given
 * locale dictionary.
 * \param localeDictionary NSLocale dictionary to use for the description.
 */
-(NSString *)descriptionWithLocale:(NSLocale *)localeDictionary;

/*!
 * \brief Returns a string representation of the receiver, indented for
 * better human readability.
 * \param localeDictionary NSLocale dictionary to consult when creating the string.
 * \param level Indent level to use.
 */
-(NSString *)descriptionWithLocale:(NSLocale *)localeDictionary
	indent:(NSUInteger)level;

-(NSString *)descriptionInStringsFileFormat;

/*!
 * \brief Equivalent to [NSDictionary objectForKey:]
 * \param key Key of object to return.
 * \sa [NSDictionary objectForKey:]
 */
-(id):(id)key;

- (id) objectForKeyedSubscript:(id)subscript;

@end

@interface NSMutableDictionary	: NSDictionary

/*!
 * \brief Creates and returns an unitialized NSMutableDictionary object with
 * the given capacity.
 * \param aNumItems Maximum capacity of the dictionary.
 */
+(id)dictionaryWithCapacity:(NSUInteger)aNumItems;

+ (id) dictionaryWithSharedKeySet:(id)keyset;

/*!
 * \brief Initializesan unitialized NSMutableDictionary object with the given
 * capacity.
 * \param aNumItems Maximum capacity of the dictionary.
 */
-(id)initWithCapacity:(NSUInteger)aNumItems;

/// \category Adding and removing entries
/*!
 * \brief Adds entries from another dictionary into the receiver.
 * \param otherDictionary NSDictionary from which to get the elements to add.
 */
-(void)addEntriesFromDictionary:(NSDictionary *)otherDictionary;

/*!
 * \brief Empties the receiver of all entries.
 */
-(void)removeAllObjects;

/*!
 * \brief Removes entries indexed by the given keys.
 * \param keyArray NSArray of keys to erase.
 */
-(void)removeObjectsForKeys:(NSArray *)keyArray;

/*!
 * \brief Removes entries indexed by the given keys.
 * \param key Key to erase.
 */
-(void)removeObjectForKey:(id)key;

/*!
 * \brief Adds an entry to the receiver consisting of the given key and
 * value pair.
 * \param anObject NSObject to add.
 * \param aKey Key to add, associated with the given object.
 */
-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;

/*!
 * \brief Sets the contents of the receiver to that of the passed dictionary.
 * \param otherDictionary NSDictionary to copy into the receiver.
 */
-(void)setDictionary:(NSDictionary *)otherDictionary;

- (void) setObject:(id)obj forKeyedSubscript:(id<NSCopying>)subscript;
@end

/*
   vim:syntax=objc:
 */
