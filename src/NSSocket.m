/*
 * Copyright (c) 2008	Gold Project
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

#import <Foundation/NSSocket.h>
#import <Foundation/NSException.h>
#import <Foundation/NSHost.h>
#import <Foundation/NSString.h>
#import "NSSocketImp.h"

@implementation _NSSocketPrivate
@end

@implementation NSSocket
@synthesize delegate = _delegate;
@synthesize isAsynchronous;

- initWithAddress:(NSNetworkAddress *)addr socketType:(NSSocketType)type protocol:(int)protocol
{
	NSLog(@"Oops, this should be done with a category!");
	return self;
}

- initWithConnectedSocket:(int)sockfd
{
	NSLog(@"Oops, this should be done with a category!");
	return self;
}

- initRemoteWithHost:(NSHost *)host family:(NSAddressFamily)family type:(NSSocketType)type protocol:(int)protocol
{
	_private->target = host;
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void) sendData:(NSData *)data
{
	if (!_private->connected)
	{
		if (_private->addrInfo == nil)
		{
			_private->addrInfo = [NSInetAddress inetAddressWithString:[_private->target address]];
			if (_private->addrInfo == nil)
				@throw [NSException exceptionWithName:@"BadSocketAddress"
											 reason:@"Could not determine socket address."
										   userInfo:nil];
		}
		[self connect];
	}
	NSLog(@"Oops, %s should be done with a category!", __func__);
}

- (void) listen
{
}

- (NSHost *) remoteTarget
{
	return _private->target;
}

- (void) connect
{
}

- (void) getEventRegistry:(struct kevent **)unused count:(size_t *)num forLoop:(RunLoop *)runLoop
{
}

- (void)handleEvent:(struct kevent *)unused forLoop:(RunLoop *)runLoop
{
}

/* These are overridden by BSDSocket. */
- (void) handleEvent:(uint32_t)flags data:(uintptr_t)data
{
	/* Default implementation, do nothing. */
}

- (uint32_t) descriptor
{
	return 0;
}

- (NSEventSourceType) sourceType
{
	return NSDescriptorEventSource;
}

- (uint32_t) flags
{
	return 0;
}

@end

@implementation NSTCPSocket
- initWithAddress:(NSNetworkAddress *)addr port:(int)port
{
	self = [self initWithAddress:addr socketType:NSStreamSocketType protocol:0];
	if (self != nil)
		_private->port = port;
	return self;
}

- initWithHost:(NSHost *)host port:(int)port
{
	return [self initRemoteWithHost:host family:NSInternetAddressFamily type:NSStreamSocketType protocol:NSInternetProtocolFamily];
}

- initForListeningWithPort:(int)port
{
	return self;
}

- (void) setPort:(int) port
{
	NSAssert(!_private->connected, @"Can't change port for a connected socket");
	_private->port = port;
}

@end

@implementation NSUDPSocket
- initWithAddress:(NSNetworkAddress *)addr port:(int)port
{
	self = [self initWithAddress:addr socketType:NSStreamSocketType protocol:0];
	if (self != nil)
		_private->port = port;
	return self;
}

- initWithHost:(NSHost *)host port:(int)port
{
	return [self initRemoteWithHost:host family:NSInternetAddressFamily type:NSDatagramSocketType protocol:NSInternetProtocolFamily];
}

- initForListeningWithPort:(int)port
{
	return self;
}

- (void) setPort:(int) port
{
	NSAssert(!_private->connected, @"Can't change port for a connected socket");
	_private->port = port;
}
@end
