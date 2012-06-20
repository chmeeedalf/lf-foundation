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

#import <Foundation/NSNotificationQueue.h>
#import "internal.h"

/*
 * NSNotificationQueue class
 */

@implementation NSNotificationQueue
{
    NSNotificationCenter            *center;
    struct _NSNotificationQueueList *asapQueue;
    struct _NSNotificationQueueList *idleQueue;
    NSZone *zone;
}

/* Creating Notification Queues */

+ (NSNotificationQueue *)defaultQueue
{
	TODO;	// +[NSNotificationQueue defaultQueue]
	return nil;
}

- (id)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter
{
	TODO;	// -[NSNotificationQueue initWithNotificationCenter:]
	return self;
}


/* Inserting and Removing Notifications From a Queue */
 
- (void)dequeueNotificationsMatching:(NSNotification*)notification
  coalesceMask:(unsigned int)coalesceMask
{
	TODO;	// -[NSNotificationQueue dequeueNotificationsMatching:coalesceMask:]
}


- (void)enqueueNotification:(NSNotification*)notification
  postingStyle:(NSPostingStyle)postingStyle
{
	TODO;	// -[NSNotificationQueue enqueueNotification:postingStyle:]
}


- (void)enqueueNotification:(NSNotification*)notification
  postingStyle:(NSPostingStyle)postingStyle
  coalesceMask:(unsigned int)coalesceMask
  forModes:(NSArray*)modes
{
	TODO;	// -[NSNotificationQueue enqueueNotification:postingStyle:coalesceMask:forModes:]
}

@end