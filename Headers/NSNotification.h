/*
 * Copyright (c) 2004-2012	Gold Project
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
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR COEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSObject.h>

@class NSDictionary, NSMutableDictionary, NSMapTable, NSOperationQueue, NSString;

/*!
 \class NSNotification
 \brief NSNotification class allows notifying other objects that an event has
 occurred.

 \details The NSNotification class is used for objects to communicate without
 knowing about each other.  NSNotifications are posted to a NSNotificationCenter,
 which manages receivers for the particular NSNotification.
 */
@interface NSNotification	: NSObject <NSCoding,NSCopying>

// Creating notification objects
/*!
 * \brief Returns a notification object associating the given name with the given object.
 * \param aName Name of the notification.
 * \param anObject NSObject to associate with the name, as the "sender" of the
 * notification.
 */
+(NSNotification *)notificationWithName:(NSString *)aName
	object:(id)anObject;

/*!
 * \brief Returns a notification object that associates the given name with the given object and dictionary of arbitrary data.
 * \param aName Name of the notification.
 * \param anObject NSObject associated with the name, as the "sender" of the
 * notification.
 * \param userInfo NSDictionary of arbitrary data, may be nil.
 */
+(NSNotification *)notificationWithName:(NSString *)aName
	object:(id)anObject userInfo:(NSDictionary *)userInfo;

/*!
 * \brief Initializes a newly notification object, associating the given name with the given object and dictionary of arbitrary data.
 * \param aName Name of the notification.
 * \param anObject NSObject associated with the name, as the "sender" of the
 * notification.
 * \param userInfo NSDictionary of arbitrary data, may be nil.
 */
- (id)initWithName:(NSString*)aName object:(id)anObject 
	userInfo:(NSDictionary*)userInfo;

// Querying a notification object
/*!
 * \brief Returns the name of the notification.
 */
-(NSString *)name;

/*!
 * \brief Returns the object associated with the receiver.
 */
-(id)object;

/*!
 * \brief Returns a dictionary object associated with this notification.
 */
-(NSDictionary *)userInfo;
@end

/*!
 \class NSNotificationCenter
 \brief NSNotificationCenter manages object communication via NSNotification
 objects.

 \details The NSNotificationCenter class maintains connections between objects via
 NSNotifications.  When an object posts a NSNotification the NSNotificationCenter
 passes the NSNotification to registered receivers, similar to Qt's signal/slot
 mechanism.

 Receivers can be added to one of four lists, specifying one, both, or neither
 of NSNotification and Sender, as follows:

 <TABLE><TR><TD>NSNotification</TD><TD>NSObject</TD></TR>
 <TR><TD>Specified</TD><TD>Specified</TD></TR>
 <TR><TD>Specified</TD><TD>Unspecified</TD></TR>
 <TR><TD>Unspecified</TD><TD>Specified</TD></TR>
 <TR><TD>Unspecified</TD><TD>Unspecified</TD></TD></TABLE>

 Receivers are notified in this order as well.
 */
@interface NSNotificationCenter	: NSObject

// Accessing the default notification center
/*!
 * \brief Returns the default notification center object.
 */
+(NSNotificationCenter *)defaultCenter;

// Adding and removing observers
/*!
 * \brief Registers an observer and selector with the receiver so that the observer receives the selector message when a notification of the given name is posted.
 * \param anObserver Observer object to register.
 * \param aSelector Selector to send to the observer when the notification is posted.
 * \param aName Name to register.  When this name is posted, a message is sent to the observer.
 * \param anObject NSObject to register.  When the name is posted by this object, a message is sent to the observer.
 */
-(void)addObserver:(id)anObserver selector:(SEL)aSelector
	name:(NSString *)aName object:(id)anObject;

#if __has_feature(blocks)
- (id) addObserverForName:(NSString *)name object:(id)obj queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *))block;
#endif

/*!
 * \brief Removes the passed observer as the observer of any notifications.
 * \param anObserver Observer object to remove.
 */
-(void)removeObserver:(id)anObserver;

/*!
 * \brief Removes the passed observer as the observer of the given name and object poster.
 * \param anObserver Observer to remove.
 * \param aName Name of message that observer watches.
 * \param anObject NSObject the observer watches.
 */
-(void)removeObserver:(id)anObserver name:(NSString *)aName object:(id)anObject;

// Posting notifications
/*!
 * \brief Posts a notification to the receiver.
 * \param aNSNotification NSNotification to post.
 */
-(void)postNotification:(NSNotification *)aNSNotification;

/*!
 * \brief Creates a notification object of the given name and object, and posts it to the notification center.
 * \param aName Name of notification to post.
 * \param anObject NSObject on the behalf of which to post the notification.
 */
-(void)postNotificationName:(NSString *)aName object:(id)anObject;

/*!
 * \brief Creates a notification object of the given name and object, and posts it to the notification center.
 * \param aName Name of notification to post.
 * \param anObject NSObject on the behalf of which to post the notification.
 * \param userInfo NSDictionary of arbitrary data for notification.
 */
-(void)postNotificationName:(NSString *)aName object:(id)anObject
	userInfo:(NSDictionary *)userInfo;
@end

/*
   vim:syntax=objc:
 */
