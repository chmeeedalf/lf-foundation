/* $Gold$	*/
/*
 * All rights reserved.
 * Copyright (c) 2009-2012	Justin Hibbits
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
#import <Foundation/NSException.h>

@class NSMutableArray;
typedef enum {
	NSOperationQueuePriorityVeryLow = -8,
	NSOperationQueuePriorityLow = -4,
	NSOperationQueuePriorityNormal = 0,
	NSOperationQueuePriorityHigh = 4,
	NSOperationQueuePriorityVeryHigh = 8,
} NSOperationQueuePriority;

@interface NSOperation	:	NSObject
@property(readonly) bool isCancelled;
@property(readonly) bool isFinished;
@property(readonly) bool isExecuting;
@property(readonly) bool isReady;
@property NSOperationQueuePriority queuePriority;

- (id) init;
- (void) start;
- (void) main;

- (bool) isCancelled;
- (void) cancel;
- (bool) isConcurrent;
- (bool) isExecuting;
- (bool) isFinished;
- (bool) isReady;

- (NSOperationQueuePriority) queuePriority;
- (void) setQueuePriority:(NSOperationQueuePriority)newPrio;

- (NSArray *) dependencies;
- (void) addDependency:(NSOperation *)dep;
- (void) removeDependency:(NSOperation *)dep;

- (void) waitUntilFinished;

#if __has_feature(blocks)
- (void (^)(void)) completionBlock;
- (void) setCompletionBlock:(void (^)(void))block;
#endif

- (void) setThreadPriority:(double)priority;
- (double) threadPriority;
@end

enum
{
	NSOperationQueueDefaultMaxConcurrentOperationCount = -1,
};

@interface NSOperationQueue	:	NSObject
{
@private
	void *_private;
	bool _suspended;
	NSInteger _maxConcurrentOperationCount;
	NSMutableArray *_operations;
}
@property NSInteger maxConcurrentOperationCount;
@property(copy) NSString *name;

+ (id) currentQueue;
+ (id) mainQueue;

- (void) addOperation:(NSOperation *)op;
- (void) addOperations:(NSArray *)ops waitUntilFinished:(bool)wait;
- (void) addOperationWithBlock:(void (^)(void))block;
- (void) cancelAllOperations;

- (bool) isSuspended;
- (void) setSuspended:(bool)suspend;

- (NSInteger) maxConcurrentOperationCount;
- (void) setMaxConcurrentOperationCount:(NSInteger)count;

- (NSUInteger) operationCount;
- (NSArray *) operations;
- (void) waitUntilAllOperationsAreFinished;
@end

@class NSInvocation;
@interface NSInvocationOperationCancelledException	:	NSStandardException
@end
@interface NSInvocationOperationVoidResultException	:	NSStandardException
@end
@interface NSInvocationOperation	:	NSOperation
{
	NSInvocation *_inv;
	id _except;
}

- (id) initWithTarget:(id)target selector:(SEL)sel object:(id)object;
- (id) initWithInvocation:(NSInvocation *)inv;

- (NSInvocation *) invocation;
- (id) result;
@end

@interface NSBlockOperation	:	NSOperation
+ (id) blockOperationWithBlock:(void (^)(void))block;

- (void) addExecutionBlock:(void (^)(void))block;
- (NSArray *) executionBlocks;
@end
