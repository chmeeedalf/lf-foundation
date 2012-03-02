/* $Gold$	*/
/*
 * Copyright (c) 2009-2012	Gold Project
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

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSKeyValueObserving.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSOperation.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#include <stdlib.h>
#include <dispatch/dispatch.h>

@implementation NSOperation
{
	dispatch_semaphore_t wait_sema;
	NSMutableArray *dependencies;
	NSOperationQueuePriority _priority;
	void (^completionBlock)(void);
	double _threadPriority;
	bool _isFinished;
	bool _isExecuting;
	bool _isCancelled;
	bool _isReady;
}

+ (bool) automaticallyNotifiesObserversForKey:(NSString *)key
{
	return false;
}

- (id) init
{
	wait_sema = dispatch_semaphore_create(0);
	dependencies = [NSMutableArray new];
	_isReady = true;
	_threadPriority = 0.5;
	return self;
}

- (void) dealloc
{
	dispatch_release(wait_sema);
}

- (void) setThreadPriority:(double)prio
{
	_threadPriority = prio;
}

- (double) threadPriority
{
	return _threadPriority;
}

- (void) start
{
	double prio = [NSThread threadPriority];
	[NSThread setThreadPriority:_threadPriority];
	@try
	{
		if (![self isCancelled])
			[self main];
		[self willChangeValueForKey:@"isFinished"];
		_isFinished = true;
		[self didChangeValueForKey:@"isFinished"];
	}
	@finally
	{
		[NSThread setThreadPriority:prio];
	}
}

- (void) main
{
	// Empty by default
}

- (bool) isCancelled
{
	return _isCancelled;
}

- (void) cancel
{
	if (!_isCancelled)
	{
		@synchronized(self)
		{
			if (!_isCancelled)
			{
				[self willChangeValueForKey:@"isCancelled"];
				_isCancelled = true;
				if (!_isReady)
				{
					[self willChangeValueForKey:@"isReady"];
					_isReady = true;
					[self didChangeValueForKey:@"isReady"];
				}
				[self didChangeValueForKey:@"isCancelled"];
			}
		}
	}
}

- (bool) isConcurrent
{
	return false;
}

- (bool) isExecuting
{
	return _isExecuting;
}

- (bool) isFinished
{
	return _isFinished;
}

- (bool) isReady
{
	return _isReady;
}

- (NSOperationQueuePriority) queuePriority
{
	return _priority;
}

- (void) setQueuePriority:(NSOperationQueuePriority)newPrio
{
	if (newPrio <= NSOperationQueuePriorityVeryLow)
		newPrio = NSOperationQueuePriorityVeryLow;
	else if (newPrio <= NSOperationQueuePriorityLow)
		newPrio = NSOperationQueuePriorityLow;
	else if (newPrio <= NSOperationQueuePriorityNormal)
		newPrio = NSOperationQueuePriorityNormal;
	else if (newPrio <= NSOperationQueuePriorityHigh)
		newPrio = NSOperationQueuePriorityNormal;
	else if (newPrio <= NSOperationQueuePriorityVeryHigh)
		newPrio = NSOperationQueuePriorityHigh;
	else
		newPrio = NSOperationQueuePriorityVeryHigh;

	if (newPrio != _priority)
	{
		@synchronized(self)
		{
			if (newPrio == _priority)
				return;
			[self willChangeValueForKey:@"queuePriority"];
			_priority = newPrio;
			[self didChangeValueForKey:@"queuePriority"];
		}
	}
}

- (void) setCompletionBlock:(void (^)(void))block
{
	completionBlock = [block copy];
}

- (void (^)(void)) completionBlock
{
	return completionBlock;
}

- (NSArray *) dependencies
{
	return [dependencies copy];
}

- (void) addDependency:(NSOperation *)dep
{
	@synchronized(self)
	{
		if ([dependencies indexOfObjectIdenticalTo:dep] == NSNotFound)
		{
			[self willChangeValueForKey:@"dependencies"];
			[dependencies addObject:dep];
			if (![dep isFinished] && ![self isCancelled] && ![self isExecuting] && ![self isFinished])
			{
				[dep addObserver:self forKeyPath:@"isFinished"
						options:NSKeyValueObservingOptionNew context:NULL];
				if (_isReady)
				{
					[self willChangeValueForKey:@"isReady"];
					_isReady = false;
					[self didChangeValueForKey:@"isReady"];
				}
			}
			[self didChangeValueForKey:@"dependencies"];
		}
	}
}

- (void) removeDependency:(NSOperation *)dep
{
	NSParameterAssert([dependencies indexOfObjectIdenticalTo:dep] != NSNotFound);

	@synchronized(self)
	{
		[dependencies removeObjectIdenticalTo:dep];
		// Fake a key-path change, because removing this dependency may cause this
		// operation to be ready.
		[self observeValueForKeyPath:@"isFinished" ofObject:dep change:nil context:NULL];
	}
}

- (void) waitUntilFinished
{
	if (![self isFinished])
	{
		dispatch_semaphore_wait(wait_sema, DISPATCH_TIME_FOREVER);
	}
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)obj
						 change:(NSDictionary *)change context:(void *)context
{
	[obj removeObserver:self forKeyPath:@"isFinished"];
	if (obj == self)
	{
		if (completionBlock != NULL)
			completionBlock();
		dispatch_semaphore_signal(wait_sema);
		return;
	}

	@synchronized(self)
	{
		for (id dep in [self dependencies])
		{
			if (![dep isFinished])
			{
				return;
			}
		}
		[self willChangeValueForKey:@"isReady"];
		_isReady = true;
		[self didChangeValueForKey:@"isReady"];
	}
}
@end

@implementation NSInvocationOperationVoidResultException
@end
@implementation NSInvocationOperationCancelledException
@end

@implementation NSInvocationOperation
- (id) initWithTarget:(id)target selector:(SEL)sel object:(id)object
{
	NSInvocation *inv;
	
	inv = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:sel]];
	[inv setTarget:target];
	[inv setSelector:sel];
	[inv setArgument:(__bridge void *)object atIndex:2];
	return [self initWithInvocation:inv];
}

- (id) initWithInvocation:(NSInvocation *)inv
{
	if ((self = [super init]) == nil)
		return nil;

	_inv = inv;
	return self;
}

- (NSInvocation *) invocation
{
	return _inv;
}

- (id) result
{
	id retval;
	if (_except != nil)
		@throw _except;
	if ([self isCancelled])
		@throw [NSInvocationOperationCancelledException
			exceptionWithReason:@"InvocationOperation cancelled." userInfo:nil];
	if (*[[_inv methodSignature] methodReturnType] == _C_VOID)
		@throw [NSInvocationOperationVoidResultException
			exceptionWithReason:@"Void return value" userInfo:nil];

	[_inv getReturnValue:&retval];
	return retval;
}

- (void) main
{
	@try
	{
		[_inv invoke];
	}
	@catch (id except)
	{
		_except = except;
	}
}

@end

@implementation NSOperationQueue
/*
 * Implementation of NSOperationQueue:
 *
 * The NSOperationQueue is a complex wrapper over a dispatch_queue_t from
 * libdispatch.  It uses dispatch semaphores for communication and barriers.
 * There is a dedicated dispatch_queue_t for each NSOperationQueue, which
 * eventually dispatches an NSOperation into one of the three global queues.
 *
 * For now, we will ignore the maxConcurrentOperationCount, and dispatch all
 * operations as soon as they are ready.  Eventually, the NSOperationQueue will
 * keep track of the number of in-flight operations, and watch for them to
 * finish, replacing them if necessary.
 *
 * Things left TODO:
 * - Enforce the maxConcurrentOperationCount.
 * - Thread priority on operations.
 */
@synthesize maxConcurrentOperationCount = _maxConcurrentOperationCount;
@synthesize name;

static NSOperationQueue *mainQueue = nil;
static NSString * const mainQueueKey = @"_NSOperationQueueMainQueryKey";

static void queue_operation(void *ctx);

+ (bool) automaticallyNotifiesObserversForKey:(NSString *)key
{
	return false;
}

+ (id) currentQueue
{
	return (__bridge id)dispatch_get_context(dispatch_get_current_queue());
}

+ (id) mainQueue
{
	if (mainQueue == nil)
	{
		@synchronized(mainQueueKey)
		{
			if (mainQueue == nil)
			{
				mainQueue = [self new];
				mainQueue->_private = dispatch_get_main_queue();
			}
		}
	}
	return mainQueue;
}

- (id) init
{
	_private = dispatch_queue_create(NULL, NULL);
	_operations = [NSMutableArray new];
	dispatch_set_context(_private, (__bridge void *)self);
	return self;
}

- (void) dealloc
{
	dispatch_release(_private);
}


static char assocObjKey;
- (void) _addOperation:(NSOperation *)op
{
	@synchronized(op)
	{
		[op addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:NULL];
		objc_setAssociatedObject(op, &assocObjKey, self, OBJC_ASSOCIATION_RETAIN);
		[_operations addObject:op];
	}
	dispatch_async_f(_private, (__bridge void *)op, queue_operation);
}

- (void) _validateOperation:(NSOperation *)op
{
	if ([op isExecuting] || [op isFinished])
		@throw [NSInvalidArgumentException exceptionWithReason:@"Operation already executing or finished." userInfo:[NSDictionary dictionaryWithObject:op forKey:@"Object"]];
	if (objc_getAssociatedObject(op, &assocObjKey) != nil)
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"Operation already in another queue." userInfo:[NSDictionary dictionaryWithObject:op forKey:@"Object"]];
	}
}

- (void) addOperation:(NSOperation *)op
{
	@synchronized(self)
	{
		[self willChangeValueForKey:@"operationCount"];
		[self willChangeValueForKey:@"operations"];
		[self _addOperation:op];
		[self didChangeValueForKey:@"operations"];
		[self didChangeValueForKey:@"operationCount"];
	}
}

- (void) addOperationWithBlock:(void (^)(void))block
{
	[self addOperation:[NSBlockOperation blockOperationWithBlock:block]];
}

- (void) addOperations:(NSArray *)ops waitUntilFinished:(bool)wait
{
	for (id op in ops)
	{
		[self _validateOperation:op];
	}

	[self willChangeValueForKey:@"operationCount"];
	[self willChangeValueForKey:@"operations"];
	for (id op in ops)
	{
		[self _addOperation:op];
	}
	[self didChangeValueForKey:@"operations"];
	[self didChangeValueForKey:@"operationCount"];

	if (wait)
	{
		for (id op in ops)
		{
			[op waitUntilFinished];
		}
	}
}

- (void) cancelAllOperations
{
	@synchronized(self)
	{
		[[[self operations] map] cancel];
	}
}

- (NSUInteger) operationCount
{
	return [_operations count];
}

- (NSArray *) operations
{
	return [_operations copy];
}

- (bool) isSuspended
{
	return _suspended;
}

- (void) setSuspended:(bool)suspend
{
	@synchronized(self)
	{
		if (suspend == _suspended)
			return;

		[self willChangeValueForKey:@"suspended"];
		if (suspend)
		{
			dispatch_suspend(_private);
		}
		else
		{
			dispatch_resume(_private);
		}
		_suspended = suspend;
		[self didChangeValueForKey:@"suspended"];
	}
}

- (void) waitUntilAllOperationsAreFinished
{
	NSOperation *op;
	do
	{
		// Synchronization is only required when retrieving an operation, not
		// releasing it.
		@synchronized(self)
		{
			op = [_operations lastObject];
		}
		[op waitUntilFinished];
	} while (op != nil);
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)obj
						 change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"isFinished"])
	{
		@synchronized(self)
		{
			[self willChangeValueForKey:@"operationCount"];
			[self willChangeValueForKey:@"operations"];
			[_operations removeObjectIdenticalTo:obj];
			[self didChangeValueForKey:@"operations"];
			[self didChangeValueForKey:@"operationCount"];
		}
	}
	else if ([keyPath isEqualToString:@"isReady"])
	{
		if ([obj isReady])
		{
			dispatch_async_f(_private, (__bridge void *)obj, queue_operation);
		}
	}
}

/* This actually runs the operation on the appropriate global queue. */
static void run_operation(void *ctx)
{
	NSOperation *op = (__bridge NSOperation *)ctx;
	[op start];
}

/* This processes an NSOperation on the NSOperationQueue's dispatch_queue. */
static void queue_operation(void *ctx)
{
	NSOperation *op = (__bridge NSOperation *)ctx;
	int queue;

	if (![op isReady])
		return;

	switch ([op queuePriority])
	{
		case NSOperationQueuePriorityVeryLow:
		case NSOperationQueuePriorityLow:
			queue = DISPATCH_QUEUE_PRIORITY_LOW;
			break;
		case NSOperationQueuePriorityVeryHigh:
		case NSOperationQueuePriorityHigh:
			queue = DISPATCH_QUEUE_PRIORITY_HIGH;
			break;
		default:
			queue = DISPATCH_QUEUE_PRIORITY_DEFAULT;
			break;
	}
	dispatch_async_f(dispatch_get_global_queue(queue, 0), (__bridge void *)op, run_operation);
}
@end
