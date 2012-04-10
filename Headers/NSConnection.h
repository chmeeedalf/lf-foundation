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

#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSException.h>
#import <Foundation/NSMapTable.h>

@class NSConnection;
@class NSDistantObject;
@class NSDistantObjectRequest;
@class NSDictionary;
@class NSException;
@class NSMutableDictionary;
@class NSMutableSet;
@class NSPortNameServer;
@class NSPort;
@class NSRunLoop;

/*! This is used generally internally for distributed objects.  Port
 * implementations can use this in the msgid: field of the
 * sendBeforeDate:msgid:components:from:reserved: method to direct the
 * conversation.
 */
enum NSConnectionMessageId
{
	NSObjectMessageId = 0,
	NSInvocationMessageId = 1,
	NSInvocationReturnMessageId = 2,
	NSConnectionShutdownMessageId = 3,
};

typedef enum NSConnectionMessageId NSConnectionMessageId;

extern NSString * const NSConnectionDidDieNotification;
extern NSString * const NSConnectionDidInitializeNotification;
extern NSString * const NSConnectionReplyMode;

/*!
  @protocol NSConnectable
  */
@protocol NSConnectable

/*!
  @brief Create and return a NSConnection object, allowing communication with the receiver.
  */
- (id) openConnection;

/*!
  @brief Terminates the connection on the remote end, and destroys the connection object.
  */
- (void) closeConnection;

@end

@protocol NSConnectionDelegate<NSObject>
@optional
- (bool) authenticateComponents:(NSArray *)components withData:(NSData *)authData;
- (bool) authenticationDataForComponents:(NSArray *)components;

- (bool) connection:(NSConnection *)conn handleRequest:(NSDistantObjectRequest *)doReq;
- (bool) connection:(NSConnection *)conn shouldMakeNewConnection:(NSConnection *)newConn;
- (id) createConversationForConnection:(NSConnection *)conn;
- (bool) makeNewConnection:(NSConnection *)newConn sender:(NSConnection *)conn;
@end

/*!
 * \brief "Base" protocol for all exported protocols.
 *
 * Conform directly to this protocol in order to export an interface.  The
 * export will not work correctly unless your protocol conforms explicitly to
 * this protocol.
 */
@protocol NSExportedProtocol
@end

@interface NSFailedAuthenticationException : NSStandardException
@end

/*!
 * @class NSConnection
 */
@interface NSConnection	: NSObject

// Establishing a connection...
+(NSConnection *)connectionWithReceivePort:(NSPort *)receivePort sendPort:(NSPort *)sendPort;

-(id)initWithReceivePort:(NSPort *)receivePort sendPort:(NSPort *)sendPort;

-(void)runInNewThread;

-(void)addRunLoop:(NSRunLoop *)runLoop;
-(void)removeRunLoop:(NSRunLoop *)runLoop;

+ (id) serviceConnectionWithName:(NSString *)name rootObject:(id)root usingNameServer:(NSPortNameServer *)server;
+ (id) serviceConnectionWithName:(NSString *)name rootObject:(id)root;

/*!
 * @brief Registers the connection with given name on the local system.
 * @param name Name to register with on the local system.
 * @result Returns true if successful, false otherwise.
 */
-(bool)registerName:(NSString *)name;
-(bool)registerName:(NSString *)name withNameServer:(NSPortNameServer *)nameServer;

// Getting and setting the root object...
/*!
 * @brief Sets the root object to the given object.
 * If the root object already exists, it is replaced by the given
 * object.  If the root object is replaced with an open connection, all
 * proxies will still go to the previous root object.
 */
-(void)setRootObject:(id)anObject;

/*!
 * @brief Returns the root object served.
 */
-(id)rootObject;


+(NSConnection *)connectionWithRegisteredName:(NSString *)name host:(NSString *)hostName usingNameServer:(NSPortNameServer *)nameServer;
+(NSConnection *)connectionWithRegisteredName:(NSString *)name host:(NSString *)hostName;

/*!
 * @brief Returns the proxy to the root object served by this connection.
 */
-(NSDistantObject *)rootProxy;
+(NSDistantObject *)rootProxyForConnectionWithRegisteredName:(NSString *)name host:(NSString *)hostName usingNameServer:(NSPortNameServer *)nameServer;
+(NSDistantObject *)rootProxyForConnectionWithRegisteredName:(NSString *)name host:(NSString *)hostName;
-(NSArray *)remoteObjects;
-(NSArray *)localObjects;


+ (id)currentConversation;

// Determining connections
/*!
 * @brief Returns an array describing all existing valid connections.
 */
+(NSArray *)allConnections;


/*!
 * @brief Sets the request timeout interval to the specified value.
 * @param interval New request timeout interval.
 */
-(void)setRequestTimeout:(NSTimeInterval)interval;
-(NSTimeInterval)requestTimeout;

/*!
 * @brief Sets the reply timeout interval to the specified value.
 * @param interval New reply timeout interval.
 */
-(void)setReplyTimeout:(NSTimeInterval)interval;
-(NSTimeInterval)replyTimeout;

-(void)setIndependentConversationQueueing:(bool)flag;
-(bool)independentConversationQueueing;

-(void)addRequestMode:(NSString *)mode;
-(void)removeRequestMode:(NSString *)mode;
-(NSArray *)requestModes;

/*!
 * @brief Identifies that the receiver is a valid connection.
 * @result Returns true if valid, false if not.
 */
- (bool) isValid;
- (void) invalidate;

- (NSPort *) receivePort;
- (NSPort *) sendPort;

// Assigning a delegate...
/*!
 * @brief Returns the connection's delegate.
 */
-(id)delegate;

/*!
 * @brief Sets the connection's delegate.
 * @param anObject NSObject to set as the delegate.
 */
-(void)setDelegate:(id)anObject;

// Get statistics
/*!
 * @brief Returns statistics for this connection.
 */
-(NSDictionary *)statistics;

@end

@interface NSDistantObjectRequest	:	NSObject
- (NSConnection *) connection;
- (id) conversation;
- (NSInvocation *) invocation;
- (void) replyWithException:(NSException *)exception;
@end
