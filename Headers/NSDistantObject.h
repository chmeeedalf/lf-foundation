/*
 * Copyright (c) 2004-2011	Gold Project
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

#import <Foundation/NSProxy.h>
#import <Foundation/NSCoder.h>

@class NSConnection, Protocol;

/*!
 * \class NSDistantObject
 * \brief NSProxy an object over a connection.
 */
@interface NSDistantObject	: NSProxy <NSCoding>
{
	NSConnection	*_connection;
	id 			 _trueObject;
	Protocol	*_protocol;
}

// Building a proxy
/*!
 * \brief Builds and returns a local proxy for a local object, forming a remote proxy on the other side of the given connection.
 * \param target Local object for proxy.
 * \param connection NSConnection to remote proxy.
 */
+(NSDistantObject *)proxyWithLocal:(id)target 
	connection:(NSConnection *)connection;

/*!
 * \brief Builds and returns a remote proxy where the given target is on the other side of the given connection.
 * \param target Local object for proxy.
 * \param connection NSConnection to remote proxy.
 */
+(NSDistantObject *)proxyWithTarget:(id)target 
	connection:(NSConnection *)connection;

// Initializing a proxy
/*!
 * \brief Builds and returns a local proxy for a local object, forming a remote proxy on the other side of the given connection.
 * \param target Local object for proxy.
 * \param connection NSConnection to remote proxy.
 * You may not retain or otherwise use this proxy.
 */
-(id)initWithLocal:(id)target connection:(NSConnection *)connection;

/*!
 * \brief Builds and returns a remote proxy where the given target is on the other side of the given connection.
 * \param target Local object for proxy.
 * \param connection NSConnection to remote proxy.
 * This method may deallocate and return \b nil if this target
 * is already known on this connection.  This is the designated initializer for
 * subclasses.
 */
-(id)initWithTarget:(id)target connection:(NSConnection *)connection;

// Specifying a protocol
/*!
 * \brief Sets the proxy's protocol to the given protocol for efficiency.
 * \param proto New protocol for the proxy
 */
-(void)setProtocolForProxy:(Protocol *)proto;

// Returning the proxy's connection
/*!
 * \brief Returns the NSConnection instance used by the receiver.
 */
-(NSConnection *)connectionForProxy;

@end
