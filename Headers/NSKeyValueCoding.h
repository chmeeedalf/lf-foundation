/* Copyright (c) 2006-2007 Johannes Fortmann

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSException.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSSet.h>

/*!
 * \file NSKeyValueCoding.h
 * \brief Key-value coding extensions.
 */
@class NSDictionary;
@class NSArray;
@class NSError;

@interface NSKeyValueCodingException : NSStandardException
@end

/*!
 * \brief NSException thrown when a key is not defined.
 */
@interface NSUndefinedKeyException : NSKeyValueCodingException
@end

/*!
 * \brief NSObject extensions for key-value coding.
 */
@interface NSObject (KeyValueCoding)

/*!
 * \brief Class method that indicates if instance variables can be accessed
 * directly or not.
 */
+(bool)accessInstanceVariablesDirectly;

/*!
 * \brief Initialize an object with the given dictionary.
 * \param dict NSDictionary of key-value pairs to initialize the object with.
 *
 * \details Each key must correspond to a setter or instance variable, and the
 * corresponding value in the dictionary must be of the acceptable type for that
 * instance variable.
 */
- (id)initWithDictionary:(NSDictionary *)dict;
// primitive methods
/*!
 * \brief Returns an object-encoded value for the given key.
 * \param key Key to read.  May be a key for a setter or an instance variable.
 */
-(id)valueForKey:(NSString*)key;

/*!
 * \brief Sets the value of a property with the given key to the given value.
 * \param value New value to set for the property.
 * \param key Key of property to set.
 */
-(void)setValue:(id)value forKey:(NSString *)key;

/*!
 * \brief Returns whether or not a value is valid for the given key.
 * \param ioValue NSValue to validate.
 * \param key Key of property to validate against.
 * \retval outError NSError that occurs in the validation.
 */
-(bool)validateValue:(id *)ioValue forKey:(NSString *)key error:(NSError **)outError;

// key path methods
/*!
 * \brief Returns an object-encoded value for the given key path.
 * \param keyPath Key path to property to read.  May be a key for a setter or an instance variable.
 */
-(id)valueForKeyPath:(NSString*)keyPath;

/*!
 * \brief Sets the value of a property with the given key to the given value.
 * \param value New value to set for the property.
 * \param keyPath Key path of property to set.
 */
-(void)setValue:(id)value forKeyPath:(NSString *)keyPath;

/*!
 * \brief Returns whether or not a value is valid for the given key path.
 * \param ioValue NSValue to validate.
 * \param keyPath Key path to property to validate against.
 * \retval outError NSError that occurs in the validation.
 */
-(bool)validateValue:(id *)ioValue forKeyPath:(NSString *)keyPath error:(NSError **)outError;

// dictionary methods
/*!
 * \brief Returns a dictionary of all values with properties in the given key
 * NSArray.
 * \param keys NSArray of keys to return in the dictionary.
 */
-(NSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys;

/*!
 * \brief Sets values for a set of properties, identified in the given
 * dictionary.
 * \param keyedValues NSDictionary of property keys and associated values to set.
 */
-(void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues;

// undefined keys etc.
/*!
 * \brief Invoked by \c -valueForKey: when no property is found for the given
 * key.
 * \param key Key to undefined property.
 * \throws UndefinedKeyException By default.
 *
 * \details Subclasses can override this method to do something else.
 */
-(id)valueForUndefinedKey:(NSString *)key;

/*!
 * \brief Invoked by \c -setValue:forKey: when no property is found for the given
 * key.
 * \param value NSValue to set.
 * \param key Key for undefined property.
 * \throws UndefinedKeyException By default.
 *
 * \details Subclasses can override this method to do something else.
 */
-(void)setValue:(id)value forUndefinedKey:(NSString *)key;

/*!
 * \brief Invoked by \c -setValue:forKey: when given a \c nil value for a scalar.
 */
-(void)setNilValueForKey:(id)key;

/*!
 * \brief Returns an array that provides read-write access to an ordered list of
 * objects at the given key.
 * \param key Key for array.
 */
-(id)mutableArrayValueForKey:(id)key;

/*!
 * \brief Returns an array that provides read-write access to an ordered list of
 * objects at the given key path.
 * \param keyPath Key path for array.
 */
-(id)mutableArrayValueForKeyPath:(id)keyPath;
@end

@interface NSArray(NSKeyValueCoding)
/*!
 * \brief Invokes \c setValue:forKey: on each of the receiver's items using the
 * given arguments.
 */
-(void)setValue:(id)value forKey:(NSString *)key;

/*!
 * \brief Returns an array created by calling \c valueForKey: on each of the
 * receiver's items.
 *
 * The returned array will have \c Null elements for each object that returns \c
 * nil.
 */
-(id)valueForKey:(NSString *)key;
@end

@interface NSSet(NSKeyValueCoding)
/*!
 * \brief Returns a set containing the result of calling \c valueForKey: on each member of the receiver.
 */
-(id)valueForKey:(NSString *)key;

/*!
 * \brief Invokes \c setValue:forKey: on each member of the receiver.
 */
-(void)setValue:(id)value forKey:(NSString *)key;

@end

@interface NSDictionary(NSKeyValueCoding)

/*!
 * \brief Returns the object associated with the given key.
 * \param aKey Key to search for.
 * \return The associated object.
 *
 * This is used primarily for key-value coding.  If the key begins with '@',
 * the '@' is first stripped, then \c[super valueForKey:] is called with the new
 * key.  Otherwise, \ref objectForKey: is invoked.
 */
-(id)valueForKey:(id)aKey;

@end

@interface NSMutableDictionary(NSKeyValueCoding)

/*!
 * \brief Adds an entry to the receiver consisting of the given key and
 * value pair.
 * \param anObject NSObject to add.
 * \param aKey Key to add, associated with the given object.
 * If anObject is nil, removes the key associated.
 */
-(void)setValue:(id)anObject forKey:(id)aKey;

@end
