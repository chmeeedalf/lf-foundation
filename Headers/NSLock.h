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

@class NSDate;

/*!
 \brief All lock classes implement the locking protocol.
 */
@protocol NSLocking
/*!
 * \brief NSLock the object.
 */
-(void)lock;

/*!
 * \brief unlock the object.
 */
-(void)unlock;
@end

/*!
 * \class NSConditionLock
 * \brief NSLock used for waiting on a condition.
 * NSCondition locks are not implemented yet.
 */
@interface NSConditionLock	: NSObject <NSLocking>
@property(copy) NSString *name;

// Initializing an NSConditionLock
/*!
 * \brief Initializes a newly created ConditionLock and sets its condition.
 * \param condition NSCondition to initialize with.
 * \returns Returns the initialized ConditionLock object.
 */
-(id)initWithCondition:(NSInteger)condition;

// Returning the condition
/*!
 * \brief Returns the receiver's condition.  The state must be achieved before a conditional locak can be acquired or released.
 */
-(NSInteger)condition;

// Acquiring and releasing a lock
/*!
 * \brief Attempts to acquire a lock when the condition is met.  Blocks until the condition is met.
 */
-(void)lockWhenCondition:(NSInteger)condition;

/*!
 * \brief Releases the lock and set the lock state to the given condition.
 */
-(void)unlockWithCondition:(NSInteger)condition;

- (bool) lockBeforeDate:(NSDate *)lockDate;

/*!
 * \brief Attempts to acquire a lock.
 * \returns Returns true if successful, false if not.
 */
-(bool)tryLock;

/*!
 * \brief Attempts to acquire a lock when the given condition is met.
 * \returns Returns true if successful and false if not.
 */
-(bool)tryLockWhenCondition:(NSInteger)condition;
@end

/*!
 * \class NSLock
 * \brief Standard lock.
 */
@interface NSLock	: NSObject <NSLocking>
@property(copy) NSString *name;

// Acquiring a lock
/*!
 * \brief Attempts to acquire a lock.  Returns immediately.
 * \result Returns true if successful, false if not.
 */
-(bool)tryLock;

- (bool) lockBeforeDate:(NSDate *)lockDate;

/*!
 * \brief Return if the lock is locked.
 */
-(bool)isLocked;

@end

/*!
 * \class NSRecursiveLock
 * \brief Standard recursive lock.
 */
@interface NSRecursiveLock	: NSObject <NSLocking>
@property(copy) NSString *name;

// Acquiring a lock
/*!
 * \brief Attempts to acquire a lock.  Returns immediately.
 * \result Returns true if successful, false if not.
 */
-(bool)tryLock;

- (bool) lockBeforeDate:(NSDate *)lockDate;

/*!
 * \brief Return if the lock is locked.
 */
-(bool)isLocked;

@end

/*!
 * @brief NSThread condition variable.
 *
 * The NSCondition class implements a condition variable with semantics based on
 * the POSIX-style conditions.
 */
@interface NSCondition	:	NSObject<NSLocking>
@property(copy) NSString *name;

- (void) wait;
- (bool) waitUntilDate:(NSDate *)date;

- (void) signal;
- (void) broadcast;

@end

/*
   vim:syntax=objc:
 */
