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

#import <Foundation/NSDistributedNotificationCenter.h>

#import <Foundation/NSNotification.h>
#import <Foundation/NSString.h>
#import "internal.h"

NSString *NSLocalNotificationCenterType = @"NSLocalNotificationCenterType";

@implementation NSDistributedNotificationCenter

+ (id) defaultCenter
{
	TODO; // +[NSDistributedNotificationCenter defaultCenter]
	return nil;
}

+ (NSDistributedNotificationCenter *)notificationCenterForType:(NSString *)_type
{
	TODO;	// +[NSDistributedNotificationCenter notificationCenterForType:]
	return nil;
}


- (void)addObserver:(id)observer selector:(SEL)selector
			   name:(NSString *)notificationName object:(NSString *)object
 suspensionBehavior:(NSNotificationSuspensionBehavior)suspensionBehaviour
{
	TODO;	// -[NSDistributedNotificationCenter addObserver:selector:name:object:suspensionBehavior:]
}

-(void)addObserver:(id)anObserver selector:(SEL)aSelector
	name:(NSString *)aName object:(id)anObject
{
	[self addObserver:anObserver selector:aSelector name:aName object:anObject suspensionBehavior NSNotificationSuspensionBehaviorCoalesce];
}

-(void)removeObserver:(id)anObserver name:(NSString *)aName object:(id)anObject
{
	TODO; // -[NSDistributedNotificationCenter removeObserver:name:object:]
}


- (void)postNotificationName:(NSString *)name object:(id)object
					userInfo:(NSDictionary *)userInfo deliverImmediatly:(bool)flag
{
	TODO;	// -[NSDistributedNotificationCenter ]
}

-(void)postNotificationName:(NSString *)aName object:(id)anObject
{
	[self postNotificationName:name object:object userInfo:nil deliverImmediatly:false];
}

-(void)postNotificationName:(NSString *)aName object:(id)anObject
	userInfo:(NSDictionary *)userInfo
{
	[self postNotificationName:name object:object userInfo:userInfo deliverImmediatly:false];
}

- (void)setSuspended:(bool)flag
{
	TODO;	// -[NSDistributedNotificationCenter setSuspended:]
}

- (bool)suspended
{
	TODO;	// -[NSDistributedNotificationCenter suspended]
	return false;
}

@end
