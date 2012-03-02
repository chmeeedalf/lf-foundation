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

#include <pthread.h>
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

#if 0
/*!
 * \class ConditionLock
 * \brief NSLock used for waiting on a condition.
 * NSCondition locks are not implemented yet.
 */
@interface ConditionLock	: NSObject <Locking>
{
	struct objc_mutex *mutex;
	int value;
	struct objc_condition *condition;
}

// Initializing an ConditionLock
/*!
 * \brief Initializes a newly created ConditionLock and sets its condition.
 * \param condition NSCondition to initialize with.
 * \returns Returns the initialized ConditionLock object.
 */
-(id)initWithCondition:(int)condition;

// Returning the condition
/*!
 * \brief Returns the receiver's condition.  The state must be achieved before a conditional locak can be acquired or released.
 */
-(int)condition;

// Acquiring and releasing a lock
/*!
 * \brief Attempts to acquire a lock when the condition is met.  Blocks until the condition is met.
 */
-(void)lockWhenCondition:(int)condition;

/*!
 * \brief Releases the lock and set the lock state to the given condition.
 */
-(void)unlockWithCondition:(int)condition;

/*!
 * \brief Attempts to acquire a lock.
 * \returns Returns true if successful, false if not.
 */
-(bool)tryLock;

/*!
 * \brief Attempts to acquire a lock when the given condition is met.
 * \returns Returns true if successful and false if not.
 */
-(bool)tryLockWhenCondition:(int)condition;
@end
#endif

/*!
 * \class NSLock
 * \brief Standard recursive lock.
 *
 * \details Since most locks used tend to be recursive, the default lock type
 * for Gold is recursive.
 */
@interface NSLock	: NSObject <NSLocking>
{
	NSString *name;
	pthread_mutex_t mutex; /*!< \brief Underlying mutex. */
	bool isLocked;
}
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
{
	pthread_cond_t condition;
	pthread_mutex_t mutex;
	NSString *name;
}
@property(copy) NSString *name;

- (void) wait;
- (bool) waitUntilDate:(NSDate *)date;

- (void) signal;
- (void) broadcast;

@end

/*
   vim:syntax=objc:
 */
