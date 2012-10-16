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
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSHost.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSString.h>
#import <Foundation/NSSocket.h>
#import "internal.h"
#include <netdb.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

@interface NSHost()
- (id) resolve;
- (id) initWithName:(NSString*)name;
- (id) initWithAddressString:(NSString*)address;
- (void) _resolveHost;
@end

@implementation NSHost

+ (NSHost *)currentHost
{
    return [NSHost hostWithName:[[NSProcessInfo processInfo] hostName]];
}

+ (NSHost *)hostWithName:(NSString *)name
{
    return [[NSHost alloc] initWithName:name];
}

+ (NSHost *)hostWithAddress:(NSString *)address
{
    return [[NSHost alloc] initWithAddressString:address];
}

- (bool)isEqualToHost:(NSHost *)aHost
{
	NSArray *theAddresses;
	int i, count;

	theAddresses = [aHost addresses];
	count = [theAddresses count];
	for (i = 0; i < count; i++)
	{
		if ([addresses containsObject:[theAddresses objectAtIndex:i]])
		{
			return true;
		}
	}

	return false;
}

- (bool)isEqual:(id)anotherHost
{
	return [self isEqualToHost:anotherHost];
}

- (NSString *)localizedName
{
	TODO; // -[NSHost localizedName]
	return [self name];
}

- (NSString *)name
{
	return [[self names] objectAtIndex:0];
}

- (NSArray *)names
{
	if ([names count] == 0)
		[self resolve];
	return names;
}

- (NSString *)address
{
	return [[self addresses] objectAtIndex:0];
}

- (NSArray *)addresses
{
	if ([addresses count] == 0)
		[self resolve];
	return addresses;
}

- (id) initWithName:(NSString*)name
{
	if ((self = [super init]) != nil)
	{
		names = [[NSMutableArray alloc] initWithObjects:name,nil];
	}
	return self;
}

- (id) initWithAddressString:(NSString*)address
{
	if ((self = [super init]) != nil)
	{
		NSInetAddress *addr = [[NSInetAddress alloc] initWithString:address];
		addresses = [[NSMutableArray alloc] initWithObjects:addr,nil];
	}

	return self;
}

- (void) _resolveName
{
	struct addrinfo *addrinfo;
	struct addrinfo ai_hints = { .ai_flags = AI_CANONNAME | AI_ADDRCONFIG };

	const char *name = [[names objectAtIndex:0] UTF8String];
	addresses = [NSMutableArray new];
	if (getaddrinfo(name, NULL, &ai_hints, &addrinfo) < 0)
		return;

	for (struct addrinfo *info = addrinfo; info != NULL; info = info->ai_next)
	{
		NSInetAddress *addr = nil;
		if (info->ai_family == AF_INET6)
		{
			addr = [[NSInet6Address alloc] initWithAddress:((struct sockaddr_in6 *)(void *)info->ai_addr)->sin6_addr.s6_addr];
		}
		else if (info->ai_family == AF_INET)
		{
			addr = [[NSInet4Address alloc] initWithAddress:(uint8_t *)&((struct sockaddr_in *)(void *)info->ai_addr)->sin_addr.s_addr];
		}
		if (info->ai_canonname != NULL)
			[names addObject:[NSString stringWithCString:info->ai_canonname encoding:NSASCIIStringEncoding]];
		if (addr == nil)
			continue;

		/* Remove duplicates. */
		if ([addresses indexOfObject:addr] == NSNotFound)
		{
			[addresses addObject:addr];
		}
	}

	freeaddrinfo(addrinfo);
}

- (void) _resolveAddress
{
	struct sockaddr_storage sa;
	char hostname[NI_MAXHOST];

	[[addresses objectAtIndex:0] _sockaddrRepresentation:&sa];
	if (getnameinfo((struct sockaddr *)&sa, sa.ss_len, hostname, sizeof(hostname), NULL, 0, 0) < 0)
		return;
	names = [NSMutableArray new];
	[names addObject:[NSString stringWithCString:hostname encoding:NSASCIIStringEncoding]];
}

- (void) _resolveHost
{
	if ([names count] > 0)
	{
		[self _resolveName];
	}
	else if ([addresses count] > 0)
	{
		[self _resolveAddress];
	}
}

- (id) resolveWithTarget:(id)targetObj selector:(SEL)sel
{
	bool found = false;
	// Do something to resolve...

	[self _resolveHost];
	found = ([names count] > 0 && [addresses count] > 0);
	if (found && targetObj != nil)
		; //objc_msgSend(targetObj, sel, self);
	return self;
}

- (id) resolve
{
	return [self resolveWithTarget:nil selector:NULL];
}
@end
