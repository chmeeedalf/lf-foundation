/*
 * Copyright (c) 2005	Gold Project
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
#import <Foundation/NSProxy.h>

@class AsynchronousQueue, Invocation;

@interface AsynchronousObject :	NSObject
{
	// Queue of invocations, each tied to an event ID.
	AsynchronousQueue *queue;
	UUID currentEvent;
	bool busy;
}

/*!
  @brief Post an event to the receiver's queue.
  @param inv Invocation to post.
  @param evID Event ID to post on.
  */
- postInvocationToQueue:(Invocation *)inv withID:(UUID)evID;

/*!
  @brief Removes the specified event ID from the queue.
  */
- removeEventID:(UUID)evID;
@end

/*!
  Created by asynchronous objects to handle objects
  created/returned by method calls to asynchronous objects.
  */
@interface AsyncObjectProxy : NSProxy
{
	Queue *queue;
	id realObject;
}

- forwardInvocation:(Invocation *)inv;
@end

@class AsynchronousQueue : NSObject
{

}

- (void) addInvocation:(Invocation *)inv withEventID:(UUID)evid
	returnObject:(id)obj;
@end

/* Use this to define an asynchronous method.  Use ASYNCHRONOUS_RET_OBJECT() to
 * define an asynchronous method that returns an object.
 */
#define ASYNCHRONOUS() \
	if (![queue empty] && [[queue findUUID:currentEvent] selector] != _cmd) { \
		UUID uid; \
		Invocation *i = [Invocation invocationWithMethodSignature]; \
		[i setArgumentFrame:__builtin_apply_args()]; \
		[i setSelector:_cmd]; \
		uid = [[NSThread currentThread] addHandler:i]; \
		[queue addInvocation:i withEventID:uid returnObject:nil]; \
		return; \
	}

#define ASYNCHRONOUS_RET_OBJECT(ret) \
	if (![queue empty] && [[queue findUUID:currentEvent] selector] != _cmd) { \
		UUID uid; \
		Invocation *i = [Invocation invocationWithMethodSignature]; \
		[i setArgumentFrame:__builtin_apply_args()]; \
		[i setSelector:_cmd]; \
		uid = [[NSThread currentThread] addHandler:i]; \
		ret = [AsynchronousObject new]; \
		[queue addInvocation:i withEventID:uid returnObject:ret]; \
		return ret; \
	} \
	else { \
		AsynchronousQueueObject *qobj = [queue objectWithEventID:currentEvent];\
		ret = [qobj returnObject]; \
	}

/* Empty the asynchronous event queue before we continue. */
#define SYNCHRONOUS() \
	while (![queue empty]) \
		hold();

/*
   vim:syntax=objc:
 */
