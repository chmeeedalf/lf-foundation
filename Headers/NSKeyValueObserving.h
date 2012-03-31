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
/* Copyright (c) 2007 Johannes Fortmann

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSOrderedSet.h>
#import <Foundation/NSSet.h>

/*!
 * \file NSKeyValueObserving.h
 */
@class NSDictionary;

/*! \defgroup kvodictkeys Key-value observing dictionary keys. */
/* @{ */
/*!
 * \brief Corresponding value is a NSNumber object containing a value
 * corresponding to a KeyValueChangeKindKey enumeration indicating what kind of
 * change has occurred.
 */
SYSTEM_EXPORT NSString *const NSKeyValueChangeKindKey;

/*!
 * \brief Corresponding value is the new value of the property.
 *
 * \details If the value of the KeyValueChangeKindKey entry is
 * KeyValueChangeSetting, and KeyValueObservingOptionNew was specified when the
 * observer was registered, the value of this key is the new value for the
 * property.  If the value of the KeyValueChangeKindKey entry is
 * KeyValueChangeInsertion or KeyValueChangeReplacement, the value for this key
 * is an NSArray instance that contains the objects that have been inserted or
 * replaced other objects, respectively.
 */
SYSTEM_EXPORT NSString *const NSKeyValueChangeNewKey;

/*!
 * \brief Corresponding value is the old value of the property.
 *
 * \details If the value of the KeyValueChangeKindKey entry is
 * KeyValueChangeSetting, and KeyValueObservingOptionOld was specified when the
 * observer was registered, the value of this key is the old value for the
 * property.  If the value of the KeyValueChangeKindKey entry is
 * KeyValueChangeRemoval or KeyValueChangeReplacement, the value for this key
 * is an NSArray instance that contains the objects that have been removed or
 * replaced, respectively.
 */
SYSTEM_EXPORT NSString *const NSKeyValueChangeOldKey;

/*!
 * \brief Corresponding value is an NSIndexSet object that contains the indexes of
 * inserted, removed, or replaced objects.
 */
SYSTEM_EXPORT NSString *const NSKeyValueChangeIndexesKey;

/*!
 * \brief This key is present in the dictionary sent prior to the change.
 */
SYSTEM_EXPORT NSString *const NSKeyValueChangeNotificationIsPriorKey;
/* @} */


/*!
 * \brief Key-value observation flags.
 */
enum {
	NSKeyValueObservingOptionNew = 0x01,	/*!< \brief Indicates that the change dictionary should provide the new attribute value. */
	NSKeyValueObservingOptionOld = 0x02,	/*!< \brief Indicates that the change dictionary should contain the old attribute value. */
	NSKeyValueObservingOptionInitial = 0x04,	/*!< \brief Indicates that a notification should be sent to the observer immediately, before the observer registration method returns. */
	NSKeyValueObservingOptionPrior = 0x08	/*!< \brief Indicates that a notification should be sent to the observer before and after each change instead of a single notification after the change. */
};

/*!
 * \brief Key-value observation flag set.
 */
typedef unsigned int NSKeyValueObservingOptions;

/*!
 * \brief Constants returned as the value for the KeyValueChangeKindKey key in
 * the change dictionary passed to
 * observeValueForKeyPath:ofObject:change:context: indicating the type of change.
 */
typedef enum {
	NSKeyValueChangeSetting,
	NSKeyValueChangeInsertion,
	NSKeyValueChangeRemoval,
	NSKeyValueChangeReplacement	
} NSKeyValueChange;

typedef enum {
	NSKeyValueUnionSetMutation = 1,
	NSKeyValueMinusSetMutation = 2,
	NSKeyValueIntersectSetMutation = 3,
	NSKeyValueSetSetMutation = 4,
} NSKeyValueSetMutationKind;

/*!
 * \brief Key-value observation extensions to the NSObject class.
 */
@interface NSObject (NSKeyValueObserving)

/*!
 * \brief Returns whether the receiver supports automatic key-value observation
 * for the given key.
 * \returns \c true if the key-value observing machinery should automatically
 * invoke -willChangeValueForKey:/didChangeValueForKey: and
 * willChange:valuesAtIndexes:forKey:/didChange:valuesAtIndexes:forKey: whenever
 * instances of the class receive key-value coding messages for the given key.
 * Otherwise, returns \c false.
 *
 * \details The default implementation returns \c true.
 */
+ (bool)automaticallyNotifiesObserversForKey:(NSString *)key;

/*!
 * \brief Returns a set of key paths for properties whose values affect the
 * value of the specified key.
 * \param key The key whose value is affected by the key paths.
 *
 * \details When an observer for the key is registered with an instance of the
 * receiving class, key-value observing automatically observes all the key paths
 * for the same instance, and sends change notifications for the key to the
 * observer for any of the key paths changes.  The default implementation of
 * this method searches the receiving class for a method whose name matches the
 * string \c +keyPathsForValuesAffecting\<Key\> and returns the result of that
 * method if found.  The method must return a NSSet object.  If no such method is
 * found, the NSSet computed from the last call to
 * +setKeys:triggerChangeNotificationsForDependentKey: is returned.
 */
+(NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key;

/*!
 * \brief Called when the value at the given key path has changed.
 * \param keyPath Path to key whose value has changed.
 * \param object NSObject which changed.
 * \param changeDict NSDictionary of change attributes.
 * \param context Arbitrary context, provided when the receiver registered for
 * observation.
 */
-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)changeDict context:(void*)context;

/*!
 * \brief Registers a new observer for a value change on a given key path.
 * \param observer Observer to register.  The object must implement the
 * key-value observing protocol.
 * \param keyPath Key path, relative to the receiver, of the property to
 * observe.
 * \param options One or more KeyValueObservingOptions values that specifies
 * what is included in observation notifications.
 * \param context Arbitrary data passed to the observer in
 * -observeValueForKeyPath:ofObject:change:context:.
 */
-(void)addObserver:(NSObject *)observer forKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options context:(void*)context;

/*!
 * \brief Unregisters an observer for the given key path.
 * \param observer Observer to unregister.
 * \param keyPath Property key path to stop observing.
 */
-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString*)keyPath;
-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;

/*!
 * \brief Invoked to inform the receiver that the value of a given property is
 * about to change.
 */
-(void)willChangeValueForKey:(NSString*)key;
-(void)willChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects;

/*!
 * \brief Invoked to inform the receiver that the value of a given property has
 * changed.
 */
-(void)didChangeValueForKey:(NSString*)key;
-(void)didChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects;

/*!
 * \brief Invoked to inform the receiver that the specified change is about to
 * be executed at the given indexes in an ordered to-many relationship.
 * \param change The type of change being made.
 * \param indexes Set of indices to be changed.
 * \param key The name of the property to be changed at each index.
 */
-(void)willChange:(NSKeyValueChange)change valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key;

/*!
 * \brief Invoked to inform the receiver that the specified change has been
 * executed at the given indexes in an ordered to-many relationship.
 * \param change The type of change that was made.
 * \param indexes Set of indices that were affected.
 * \param key The name of the property whose value was changed at each index.
 */
-(void)didChange:(NSKeyValueChange)change valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key;

/*!
 * \brief Sets the observation info for the receiver.
 * \param newInfo New observation info for the receiver.
 *
 * \details As an optimization, the receiver may cache the opaque data pointer
 * by overriding this method and \c observationInfo, and storing the pointer in
 * an instance variable.
 */
-(void)setObservationInfo:(void*)newInfo;

/*!
 * \brief Returns the observation info.
 *
 * \details As an optimization, the receiver may cache the opaque data pointer
 * by overriding this method and \c setObservationInfo:, and storing the pointer in
 * an instance variable.
 */
-(void*)observationInfo;
@end

/*!
 * \brief NSArray extensions for key-value observing.
 */
@interface NSArray (NSKeyValueObserving)

/*!
 * \brief Registers a new observer for a value change on a given key path.
 * \param observer Observer to register.  The object must implement the
 * key-value observing protocol.
 * \param keyPath Key path, relative to the receiver, of the property to
 * observe.
 * \param options One or more KeyValueObservingOptions values that specifies
 * what is included in observation notifications.
 * \param context Arbitrary data passed to the observer in
 * -observeValueForKeyPath:ofObject:change:context:.
 */
-(void)addObserver:(NSObject *)observer forKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options context:(void*)context;

/*!
 * \brief Add an observer for key-value observation notifications for changes in
 * a set of indices.
 * \param observer Observer to notify.
 * \param indexes Set of indices to be notified for.
 * \param keyPath Key path for property to be notified for.
 * \param options Options for dictionary attributes to be reported.
 * \param context Arbitrary context to pass down to the notified observer.
 */
-(void)addObserver:(NSObject *)observer toObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;

/*!
 * \brief Remove an observer for key-value observation notifications.
 * \param observer Observer to remove.
 * \param indexes Set of indices to be remove watch on.
 * \param keyPath Key path for property to stop watching.
 */
-(void)removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath;

/*!
 * \brief Unregisters an observer for the given key path.
 * \param observer Observer to unregister.
 * \param keyPath Property key path to stop observing.
 */
-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString*)keyPath;

/*!
 * \brief Unregisters an observer for the given key path.
 * \param observer Observer to unregister.
 * \param keyPath Property key path to stop observing.
 */
-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString*)keyPath context:(void *)context;

/*!
 * \brief Remove an observer for key-value observation notifications.
 * \param observer Observer to remove.
 * \param indexes Set of indices to be remove watch on.
 * \param keyPath Key path for property to stop watching.
 */
-(void)removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath context:(void *)context;
@end

@interface NSSet(KeyValueObserving)
/*!
 * \brief Registers a new observer for a value change on a given key path.
 * \param observer Observer to register.  The object must implement the
 * key-value observing protocol.
 * \param keyPath Key path, relative to the receiver, of the property to
 * observe.
 * \param options One or more KeyValueObservingOptions values that specifies
 * what is included in observation notifications.
 * \param context Arbitrary data passed to the observer in
 * -observeValueForKeyPath:ofObject:change:context:.
 */
- (void) addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)opts context:(void *)context;

/*!
 * \brief Unregisters an observer for the given key path.
 * \param observer Observer to unregister.
 * \param keyPath Property key path to stop observing.
 */
-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString*)keyPath;

/*!
 * \brief Unregisters an observer for the given key path.
 * \param observer Observer to unregister.
 * \param keyPath Property key path to stop observing.
 */
-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString*)keyPath context:(void *)context;
@end

@interface NSOrderedSet(KeyValueObserving)
/*!
 * \brief Registers a new observer for a value change on a given key path.
 * \param observer Observer to register.  The object must implement the
 * key-value observing protocol.
 * \param keyPath Key path, relative to the receiver, of the property to
 * observe.
 * \param options One or more KeyValueObservingOptions values that specifies
 * what is included in observation notifications.
 * \param context Arbitrary data passed to the observer in
 * -observeValueForKeyPath:ofObject:change:context:.
 */
- (void) addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)opts context:(void *)context;

/*!
 * \brief Unregisters an observer for the given key path.
 * \param observer Observer to unregister.
 * \param keyPath Property key path to stop observing.
 */
-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString*)keyPath;

/*!
 * \brief Unregisters an observer for the given key path.
 * \param observer Observer to unregister.
 * \param keyPath Property key path to stop observing.
 */
-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString*)keyPath context:(void *)context;
@end

/*!
 * \brief Key-value observer protocol.
 */
@protocol NSKeyValueObserver

/*!
 * \brief Called when the value at the given key path has changed.
 * \param keyPath Path to key whose value has changed.
 * \param object NSObject which changed.
 * \param changeDict NSDictionary of change attributes.
 * \param context Arbitrary context, provided when the receiver registered for
 * observation.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)changeDict context:(void *)context;
@end
