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

#import <Foundation/NSArray.h>
#import <Foundation/NSConnection.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSPort.h>
#import <Foundation/NSProxy.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSString.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSThread.h>

/* Private API. */
@interface NSConnection()
- (void) _runConnThread;
@end

/*
 * This is how connections work:
 *
 * Add a Port subclass, and its corresponding PortCoder subclass.  These two
 * classes work together to handle the connection transport.
 * 
 * The coder class will take as input either an Invocation object or a NSData
 * object.  NSData objects for decoding are assumed to be encoded from the wire, as the output
 * of the subclass's -receiveData method.
 *
 * The goal is to mimic the Distributed Objects from NeXTSTEP, while shedding
 * baggage, and improving things where fit.  For example, one connection can
 * handle multiple objects, by registering on different paths.  A root object
 * should still be requested, though.
 */
@implementation NSConnection

static NSMutableSet *allConnections;

+ (void) initialize
{
	if (self == [NSConnection class])
	{
		allConnections = [[NSMutableSet alloc] init];
	}
}

// Initializing a connection...
-(id)init
{
	[allConnections addObject:self];
	requestModes = [NSMutableSet new];
	served = [NSMapTable new];
	localProxies = [NSMutableDictionary new];
	proxies = [NSMutableDictionary new];

	return self;
}

- (id) initWithReceivePort:(NSPort *)rPort sendPort:(NSPort *)sPort
{
	self = [self init];
	receivePort = rPort;
	sendPort = sPort;

	return self;
}

- (void) dealloc
{
	[allConnections removeObject:self];
}

// Establishing a connection...
+(NSConnection *)connectionWithRegisteredName:(NSString *)name
	target:(id<NSConnectable>)target
{
	[self subclassResponsibility:_cmd];
	return nil;
}

+ (NSConnection *) connectionWithRegisteredName:(NSString *)name host:(NSString *)hostName
{
	TODO; // +connectionWithRegisteredName:host:
	return nil;
}

+(NSDistantObject *)rootProxyForConnectionWithRegisteredName:(NSString *)name
	target:(id<NSConnectable>)target
{
	return [[NSConnection connectionWithRegisteredName:name target:target] rootProxy];
}

+ (NSConnection *) connectionWithReceivePort:(NSPort *)recvPort sendPort:(NSPort *)sendPort
{
	return [[self alloc] initWithReceivePort:recvPort sendPort:sendPort];
}

+ (NSDistantObject *) rootProxyForConnectionWithRegisteredName:(NSString *)name host:(NSString *)host
{
	return [[self connectionWithRegisteredName:name host:host] rootProxy];
}

// Determining connections
+(NSArray *)allConnections
{
	return [allConnections allObjects];
}

-(bool)isValid
{
	return false;
}

// Registering a connection...
-(bool)registerName:(NSString *)name
{
	[self subclassResponsibility:_cmd];
	return false;
}

// Assigning a delegate...
-(id)delegate
{
	return _delegate;
}

-(void)setDelegate:(id)anObject
{
	_delegate = anObject;
}

// Getting and setting the root object...
-(id)rootObject
{
	return [served objectForKey:@"/"];
}

-(NSDistantObject *)rootProxy
{
	id rootObj = [self rootObject];

	/* If we have a root object, we're a server, so return the root object. */
	if (rootObj != nil)
	{
		return rootObj;
	}
	TODO;	// -rootProxy
	return nil;
}

- (NSDistantObject *) proxyForLocal:(id)local
{
	return [localProxies objectForKey:local];
}

- (void) addProxy:(NSDistantObject *)proxy forLocal:(id)local
{
	[localProxies setObject:proxy forKey:local];
}

-(void)setRootObject:(id)anObject
{
	[self registerObject:anObject withPath:@"/"];
}

// Subclasses should call this (super), to register the object with the runtime system
- (void) registerObject:(id)anObject withPath:(NSString *)path
{
	[served setObject:anObject forKey:path];
}

// Request mode
-(NSString *)requestMode
{
	TODO;	// -requestMode
	return nil;
}

-(void)setRequestMode:(NSString *)mode
{
	TODO; // -[NSConnection setRequestMode:]
}

// Timeouts
-(NSTimeInterval)replyTimeout
{
	return _replyTimeout;
}

-(NSTimeInterval)requestTimeout
{
	return _replyTimeout;
}

-(void)setReplyTimeout:(NSTimeInterval)interval
{
	_replyTimeout = interval;
}

-(void)setRequestTimeout:(NSTimeInterval)interval
{
	_requestTimeout = interval;
}

// Get statistics
-(NSDictionary *)statistics
{
	TODO;	// -statistics
	return nil;
}

- (NSPort *) sendPort
{
	return sendPort;
}

- (NSPort *) receivePort
{
	return receivePort;
}

+ (id) currentConversation
{
	TODO;	// +currentConversation
	return nil;
}

- (bool) independentConversationQueueing
{
	return independentQueueing;
}

- (void) setIndependentConversationQueueing:(bool)indepQueue
{
	independentQueueing = indepQueue;
}

- (NSArray *) requestModes
{
	return [requestModes allObjects];
}

- (void) addRequestMode:(NSString *)mode
{
	[requestModes addObject:mode];
}

- (void) removeRequestMode:(NSString *)mode
{
	[requestModes removeObject:mode];
}

- (void) addRunLoop:(NSRunLoop *)loop
{
	if ([runloops containsObject:loop])
	{
		return;
	}

	for (NSString *mode in requestModes)
	{
		[receivePort addConnection:self toRunLoop:loop forMode:mode];
	}
	[runloops addObject:loop];
}

- (void) removeRunLoop:(NSRunLoop *)loop
{
	if (![runloops containsObject:loop])
	{
		return;
	}

	for (NSString *mode in requestModes)
	{
		[receivePort removeConnection:self fromRunLoop:loop forMode:mode];
	}
	[runloops removeObject:loop];
}

- (void) _runConnThread
{
	NSRunLoop *loop = [NSRunLoop currentRunLoop];
	[self addRunLoop:loop];
	[loop run];
}

- (void) runInNewThread
{
	[self performSelectorInBackground:@selector(_runConnThread) withObject:nil];
}

- (void) invalidate
{
	TODO; // -invalidate
}

- (NSArray *) localObjects
{
	TODO; // -localObjects
	return nil;
}

- (NSArray *) remoteObjects
{
	return [proxies allValues];
}

- (void) forwardInvocation:(NSInvocation *)inv forProxy:(NSProxy *)proxy
{
	TODO; // -[NSConnection forwardInvocation:forProxy:]
}
@end
