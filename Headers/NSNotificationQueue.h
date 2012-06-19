/* 
   NSNotificationQueue.h

   Copyright (C) 2012 Justin Hibbits
   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

   This file is part of libFoundation.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.
*/

#import <Foundation/NSNotification.h>

@class NSMutableArray;

/*
 * Posting styles into notification queue
 */

typedef enum {
    NSPostWhenIdle,	
    NSPostASAP,		
    NSPostNow		
} NSPostingStyle;

typedef enum {
    NSNotificationNoCoalescing = 0,	
    NSNotificationCoalescingOnName = 1,	
    NSNotificationCoalescingOnSender = 2,	
} NSNotificationCoalescing;

/*
 * NSNotificationQueue class
 */

@interface NSNotificationQueue : NSObject

/* Creating Notification Queues */

+ (NSNotificationQueue *)defaultQueue;
- (id)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter;

/* Inserting and Removing Notifications From a Queue */
 
- (void)dequeueNotificationsMatching:(NSNotification*)notification
  coalesceMask:(unsigned int)coalesceMask;

- (void)enqueueNotification:(NSNotification*)notification
  postingStyle:(NSPostingStyle)postingStyle;

- (void)enqueueNotification:(NSNotification*)notification
  postingStyle:(NSPostingStyle)postingStyle
  coalesceMask:(unsigned int)coalesceMask
  forModes:(NSArray*)modes;

@end
