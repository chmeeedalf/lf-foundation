/*
 * Copyright (c) 2008-2012	Justin Hibbits
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

#include <sys/types.h>
#include <sys/event.h>
#include <sys/socket.h>

#include <netinet/in.h>

#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#import "internal.h"
#import <Foundation/NSSocket.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSHost.h>
#import <Foundation/NSString.h>

@implementation NSSocket
{
	@protected
	__weak id<NSSocketDelegate>	_delegate;
	bool isAsynchronous;
	int sockfd;
	int port;
	NSHost *target;
	NSNetworkAddress *addrInfo;
	bool connected;
	bool connectError;
	bool binded;
}
@synthesize delegate = _delegate;
@synthesize isAsynchronous;

- (id) initWithAddress:(NSNetworkAddress *)addr socketType:(NSSocketType)type protocol:(int)protocol
{
	int pid;
	struct sockaddr_storage saddr;

	memset(&saddr, 0, sizeof(saddr));
	if (addr != NULL)
	{
		[addr _sockaddrRepresentation:&saddr];
	}
	sockfd = socket(saddr.ss_family, type, protocol);
	if (sockfd < 0)
	{
		sockfd = 0;
		return nil;
	}
	fcntl(sockfd, F_SETFL, O_ASYNC|O_NONBLOCK);
	fcntl(sockfd, F_SETOWN, getpid());
	pid = fcntl(sockfd, F_GETOWN, 0);
	addrInfo = addr;
	return self;
}

- (id) initWithConnectedSocket:(int)connSocket
{
	sockfd = connSocket;
	connected = true;
	return self;
}

- (id) initRemoteWithHost:(NSHost *)host family:(NSAddressFamily)family type:(NSSocketType)type protocol:(int)protocol
{
	sockfd = socket(family, type, protocol);
	target = host;
	return self;
}

- (void) dealloc
{
	close(sockfd);
	_AsyncUnwatchDescriptor(sockfd, false);
	_AsyncUnwatchDescriptor(sockfd, true);
	[self setDelegate:nil];
}

- (void) sendData:(NSData *)data
{
	if (!connected)
	{
		if (connectError)
			return;
		if (addrInfo == nil)
		{
			addrInfo = [NSInetAddress inetAddressWithString:[target address]];
			if (addrInfo == nil)
				@throw [NSException exceptionWithName:@"BadSocketAddress"
											 reason:@"Could not determine socket address."
										   userInfo:nil];
		}
		[self connect];
	}

	int err = write(sockfd, [data bytes], [data length]);
	if (err < 0)
	{
		NSLog(@"NSError sending data: %d", err);
	}
}

- (void) _socketHandleAccept
{
	struct sockaddr_storage addr;
	NSSocket *sock;
	size_t sock_size;
	if ([_delegate respondsToSelector:@selector(socket:shouldAcceptConnection:)])
	{
		int newsock = accept(sockfd, (struct sockaddr *)&addr, &sock_size);

		sock = [[NSSocket alloc] initWithConnectedSocket:newsock];
		[sock setDelegate:_delegate];

		if ([_delegate socket:self shouldAcceptConnection:sock])
		{
			if ([self isAsynchronous])
				_AsyncWatchDescriptor(newsock, sock, @selector(_socketHandleReceive), false);
			else
				[[NSRunLoop currentRunLoop] addInputSource:sock forMode:NSRunLoopCommonModes];
		}
	}
	else
		NSLog(@"No delegate, so ignoring request");
}

- (void) listen
{
	struct	sockaddr_storage addr;
	int		err;
	int		one = 1;

	if (binded)
		return;

	memset(&addr, 0, sizeof(addr));
	err = setsockopt(sockfd, 0xffff, 0x04, &one, sizeof(one));
	if (err < 0)
		NSLog(@"Warning: error setting socket reuse: %d", err);
	[self _sockaddrRepresentation:&addr];
	if ((err = bind(sockfd, (struct sockaddr *)&addr, addr.ss_len)) < 0)
	{
		NSLog(@"Unable to bind to socket: %@, error code %d", self, -err);
		return;
	}
	binded = true;
	if ([self isAsynchronous])
		_AsyncWatchDescriptor(sockfd, self, @selector(_socketHandleAccept), false);
	err = listen(sockfd, -1);
	if (err < 0)
		NSLog(@"Warning: Listening failed due to error: %d", err);
}

- (NSHost *) remoteTarget
{
	return target;
}

- (void) connect
{
	struct sockaddr_storage addr;

	if (binded)
		@throw([NSInvalidArgumentException exceptionWithReason:@"Cannot connect a socket that is being listened on" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self,@"NSSocket",nil]]);
	memset(&addr, 0, sizeof(addr));

	if (addrInfo == nil)
		@throw([NSInvalidArgumentException exceptionWithReason:@"Cannot connect a socket to an empty address." userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self,@"NSSocket",nil]]);
	[self _sockaddrRepresentation:&addr];
	int err = connect(sockfd, (struct sockaddr *)&addr, addr.ss_len);
	if (err < 0 && err != -36)
	{
		NSLog(@"Can't connect: %d, socket: %d", err, sockfd);
		connectError = true;
	}
	if ([self isAsynchronous])
	{
		if (err == -36)
		{
			_AsyncWatchDescriptor(sockfd, self, @selector(_socketHandleConnect), true);
		}
		else
		{
			_AsyncWatchDescriptor(sockfd, self, @selector(_socketHandleReceive), false);
		}
	}
	else
		[[NSRunLoop currentRunLoop] addInputSource:self forMode:NSRunLoopCommonModes];
}

- (void) getEventRegistry:(struct kevent **)unused count:(size_t *)num forLoop:(NSRunLoop *)runLoop
{
}

- (void)handleEvent:(struct kevent *)unused forLoop:(NSRunLoop *)runLoop
{
}

- (void) handleEvent:(uint32_t)flags data:(uintptr_t)data
{
	if ([_delegate respondsToSelector:@selector(socketHasDataAvailable:)])
	{
		[_delegate socketHasDataAvailable:self];
	}
	else
	{
		[self _socketHandleReceive:data];
	}
}

- (uint32_t) descriptor
{
	return sockfd;
}

- (NSEventSourceType) sourceType
{
	return NSDescriptorEventSource;
}

- (uint32_t) flags
{
	return 0;
}

- (void) close
{
	close(sockfd);
	connected = false;
	binded = false;
}

- (void) _socketHandleConnect
{
	connected = true;
	if ([self isAsynchronous])
	{
		_AsyncUnwatchDescriptor(sockfd, true);
		_AsyncWatchDescriptor(sockfd, self, @selector(_socketHandleReceive), false);
	}
	[_delegate socketDidConnect:self];
}

- (void) _socketHandleReceive
{
	int len;
	int total_len = 0;
	void *mem = malloc(getpagesize()); //NSMemGetPages(1, true, NULL);
	NSMutableData *data = [NSMutableData new];

	do
	{
		len = read(sockfd, mem, getpagesize());
		if (len <= 0)
			break;
		[data setLength:len];
		[data replaceBytesInRange:NSMakeRange(0, len) withBytes:mem];
		[_delegate socket:self didReceiveData:data];
		total_len += len;
	} while (len == getpagesize());
	if (len < 0)
	{
		if (len != -35)
			NSLog(@"NSError: %d", -len);
	}
	else if (total_len == 0)
	{
		[self close];
	}
	free(mem);
}

- (void) _socketHandleReceive:(size_t)size
{
	void *bytes = malloc(size);
	NSData *data;

	read(sockfd, bytes, size);

	data = [[NSData alloc] initWithBytes:bytes length:size];
	free(bytes);
	
	[_delegate socket:self didReceiveData:data];
}

- (void) _sockaddrRepresentation:(struct sockaddr_storage *)saddr
{
	[addrInfo _sockaddrRepresentation:saddr];
}

- (void)handleEvent:(struct kevent *)event
{
	switch (event->filter)
	{
		case EVFILT_READ:
			if (binded)
				[self _socketHandleAccept];
			else
				[self _socketHandleReceive:event->data];
			if (event->flags & EV_EOF)
				[self close];
			break;
		case EVFILT_WRITE:
			// We don't handle asynchronous writes yet.
			break;
	}
}

@end

@implementation NSTCPSocket
- (id) initWithAddress:(NSNetworkAddress *)addr port:(int)sockPort
{
	self = [self initWithAddress:addr socketType:NSStreamSocketType protocol:0];
	if (self != nil)
		port = sockPort;
	return self;
}

- (id) initWithHost:(NSHost *)host port:(int)port
{
	return [self initRemoteWithHost:host family:NSInternetAddressFamily type:NSStreamSocketType protocol:NSInternetProtocolFamily];
}

- (id) initForListeningWithPort:(int)port
{
	return self;
}

- (void) setPort:(int)newPort
{
	NSAssert(!connected, @"Can't change port for a connected socket");
	port = newPort;
}

@end

@implementation NSUDPSocket
- (id) initWithAddress:(NSNetworkAddress *)addr port:(int)sockPort
{
	self = [self initWithAddress:addr socketType:NSStreamSocketType protocol:0];
	if (self != nil)
		port = sockPort;
	return self;
}

- (id) initWithHost:(NSHost *)host port:(int)port
{
	return [self initRemoteWithHost:host family:NSInternetAddressFamily type:NSDatagramSocketType protocol:NSInternetProtocolFamily];
}

- (id) initForListeningWithPort:(int)sockPort
{
	port = sockPort;
	return self;
}

- (void) setPort:(int) sockPort
{
	NSAssert(!connected, @"Can't change port for a connected socket");
	port = sockPort;
}
@end
