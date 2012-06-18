/*
 * Copyright (c) 2011-2012	Justin Hibbits
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

#import <Foundation/NSNotification.h>

@class NSString;

SYSTEM_EXPORT NSString *NSLocalNotificationCenterType;

enum {
	NSNotificationDeliverImmediately = 1,
	NSNotificationPostToAllSessions = (1 << 1)
};

typedef enum {
  NSNotificationSuspensionBehaviorDrop,
  NSNotificationSuspensionBehaviorCoalesce,
  NSNotificationSuspensionBehaviorHold,
  NSNotificationSuspensionBehaviorDeliverImmediatly
} NSNotificationSuspensionBehavior;

@interface NSDistributedNotificationCenter : NSNotificationCenter

+ (id) defaultCenter;
+ (NSDistributedNotificationCenter *)notificationCenterForType:(NSString *)type;

// Managing observers

- (void)addObserver:(id)observer selector:(SEL)sel
  name:(NSString *)name object:(NSString *)object
  suspensionBehavior:(NSNotificationSuspensionBehavior)suspensionBehaviour;

-(void)addObserver:(id)anObserver selector:(SEL)aSelector
	name:(NSString *)aName object:(id)anObject;

-(void)removeObserver:(id)anObserver name:(NSString *)aName object:(id)anObject;

// Posting notifications

-(void)postNotificationName:(NSString *)aName object:(id)anObject;
-(void)postNotificationName:(NSString *)aName object:(id)anObject
	userInfo:(NSDictionary *)userInfo;
- (void)postNotificationName:(NSString *)name object:(id)object
  userInfo:(NSDictionary *)ui deliverImmediatly:(bool)flag;

// Suspending and resuming delivery

- (void)setSuspended:(bool)flag;
- (bool)suspended;

@end
