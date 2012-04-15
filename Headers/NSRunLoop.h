/* $Gold$	*/
/*
 * All rights reserved.
 * Copyright (c) 2009	Justin Hibbits
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
#import <Foundation/NSDate.h>
#ifdef __cplusplus
#include <Alepha/RunLoop.h>
typedef Alepha::RunLoop ARunLoop;
#else
typedef struct ARunLoop ARunLoop;
#endif

typedef enum
{
	NSDescriptorEventSource = 1,
	NSProcessEventSource,
	NSVNodeEventSource,
	NSSignalEventSource,
	NSUserEventSource,
} NSEventSourceType;

@protocol NSEventSource
- (NSEventSourceType) sourceType;
- (uintptr_t) descriptor;
- (uint32_t) flags;

- (void) handleEvent:(uint32_t)flags data:(uintptr_t)data;
@end

@class NSArray, NSDate, NSTimer;

SYSTEM_EXPORT NSString * const NSDefaultRunLoopMode;
SYSTEM_EXPORT NSString * const NSRunLoopCommonModes;

@interface NSRunLoop	:	NSObject
+ (id) currentRunLoop;
- (NSString *) currentMode;
- (NSDate *) limitDateForMode:(NSString *)mode;
+ (NSRunLoop *) mainRunLoop;

- (void) addInputSource:(NSObject<NSEventSource> *)obj forMode:(NSString *)mode;
- (void) removeInputSource:(NSObject<NSEventSource> *)obj forMode:(NSString *)mode;
- (void) addTimer:(NSTimer *)timer forMode:(NSString *)mode;
- (void) removeTimer:(NSTimer *)timer forMode:(NSString *)mode;

- (void) run;
- (void) runUntilDate:(NSDate *)date;
- (void) runMode:(NSString *)mode beforeDate:(NSDate *)date;
- (void) acceptInputForMode:(NSString *)mode beforeDate:(NSDate *)date;

/* End the loop at the end of event processing. */
- (void) exit;

/* End the loop as soon as possible, generally when this event handler exits. */
- (void) terminate;

- (bool) isCanceled;
- (bool) isTerminated;

- (void) performSelector:(SEL)sel target:(id)target argument:(id)arg order:(unsigned long)order modes:(NSArray *)modes;
- (void) cancelPerformSelector:(SEL)sel target:(id)target argument:(id)arg;
- (void) cancelPerformSelectorsWithTarget:(id)target;

#ifdef __cplusplus
- (void) addRunLoopSource:(Alepha::RunLoop::Source *)src target:(id)tgt selector:(SEL)sel mode:(NSString *)mode;
- (Alepha::RunLoop *) coreRunLoop;
#endif
@end

@interface NSObject(RunLoopAdditions)
+ (void) cancelPreviousPerformRequestsWithTarget:(id)target;
+ (void) cancelPreviousPerformRequestsWithTarget:(id)target selector:(SEL)sel object:(id)arg;
- (void) performSelector:(SEL)sel withObject:(id)obj afterDelay:(NSTimeInterval)delay;
- (void) performSelector:(SEL)sel withObject:(id)obj afterDelay:(NSTimeInterval)delay inModes:(NSArray *)modes;
@end

