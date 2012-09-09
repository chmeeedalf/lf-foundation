/*
 * Copyright (c) 2012	Justin Hibbits
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

#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>

#include <string.h>
#include <unistd.h>

#import <Foundation/NSPort.h>

#import <Foundation/NSData.h>

#import "internal.h"

static bool _NSPrivateSetupSockaddr(NSData *addr, struct sockaddr_storage *sas)
{
	switch (sas->ss_family)
	{
		case PF_INET:
			{
				struct sockaddr_in *sin = (struct sockaddr_in *)sas;
				[addr getBytes:&sin->sin_addr range:NSMakeRange(0, sizeof(sin->sin_addr))];
				sin->sin_len = sizeof(*sin);
			}
			break;
		case PF_INET6:
			{
				struct sockaddr_in6 *sin = (struct sockaddr_in6 *)sas;
				sin->sin6_len = sizeof(*sin);
				[addr getBytes:&sin->sin6_addr range:NSMakeRange(0, sizeof(sin->sin6_addr))];
			}
			break;
		case PF_LOCAL:
			{
				struct sockaddr_un *sun = (struct sockaddr_un *)sas;
				sun->sun_len = sizeof(*sun);
				[addr getBytes:&sun->sun_path range:NSMakeRange(0, MIN([addr length], sizeof(sun->sun_path)))];
			}
			break;
		default:
			return false;
			break;
	}
	return true;
}

@implementation NSSocketPort
{
	int family;
	int type;
	int protocol;
	NSData *addr;
	NSSocketNativeHandle sockfd;
}

- (id) init
{
	return [self initWithTCPPort:0];
}

- (id) initWithTCPPort:(unsigned short)port
{
	return [self initWithProtocolFamily:PF_INET socketType:SOCK_STREAM protocol:0 address:nil];
}

- (id) initWithProtocolFamily:(int)fam socketType:(int)sockType protocol:(int)proto address:(NSData *)address
{
	struct sockaddr_storage sas;
	memset(&sas, 0, sizeof(sas));
	family = fam;
	type = sockType;
	protocol = proto;
	addr = [address copy];

	if (!_NSPrivateSetupSockaddr(addr, &sas))
		return nil;

	sockfd = socket(fam, type, proto);
	if (sockfd < 0)
		return nil;

	if (bind(sockfd, (struct sockaddr *)&sas, sas.ss_len) < 0)
	{
		close(sockfd);
		return nil;
	}
	return self;
}

- (id) initWithProtocolFamily:(int)fam socketType:(int)sockType protocol:(int)proto socket:(NSSocketNativeHandle)sock
{
	family = fam;
	type = sockType;
	protocol = proto;
	sockfd = sock;
	return self;
}

- (id) initWithSocket:(NSSocket *)socket
{
	TODO; // -[NSSocketPort initWithSocket:]
	return self;
}

- (id) initRemoteWithTCPPort:(int)port host:(NSString *)hostName
{
	return [self initRemoteWithProtocolFamily:PF_INET socketType:SOCK_STREAM protocol:0 address:nil];
}

- (id) initRemoteWithProtocolFamily:(int)fam socketType:(int)sockType protocol:(int)proto address:(NSData *)address
{
	family = fam;
	type = sockType;
	protocol = proto;
	addr = [address copy];
	return self;
}


- (NSData *) address
{
	return addr;
}

- (int) protocol
{
	if (protocol == 0 && sockfd != 0)
	{
		getsockopt(sockfd, SOL_SOCKET, SO_PROTOCOL, &protocol, &(socklen_t){sizeof(protocol)});
	}
	return protocol;
}

- (int) protocolFamily
{
	return family;
}

- (NSSocketNativeHandle) socket
{
	return sockfd;
}

- (int) socketType
{
	return type;
}

- (void) removeFromRunLoop:(NSRunLoop *)loop forMode:(NSString *)mode
{
	TODO; // -[NSSocketPort removeFromRunLoop:forMode:];
}

- (void) scheduleInRunLoop:(NSRunLoop *)loop forMode:(NSString *)mode
{
	TODO; // -[NSSocketPort scheduleInRunLoop:forMode:];
}

- (bool) sendBeforeDate:(NSDate *)date msgid:(uint32_t)msgid components:(NSArray *)comp from:(NSPort *)from reserved:(size_t)reserved
{
	// Only remote sockets are lazy connected
	if (sockfd == 0)
	{
		struct sockaddr_storage sas;
		memset(&sas, 0, sizeof(sas));
		sockfd = socket(family, type, protocol);
		if (sockfd < 0)
		{
			sockfd = 0;
			return false;
		}
		sas.ss_family = family;
		if (!_NSPrivateSetupSockaddr(addr, &sas))
		{
			close(sockfd);
			sockfd = 0;
			return false;
		}
		if (connect(sockfd, (struct sockaddr *)&sas, sas.ss_len) < 0)
		{
			close(sockfd);
			sockfd = 0;
			return false;
		}
	}
	TODO; // -[NSSocketPort sendBeforeDate:msgid:components:from:reserved:]
	return false;
}


@end
