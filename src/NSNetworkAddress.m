/*
 * Copyright (c) 2009	Gold Project
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
#import <Foundation/NSByteOrder.h>
#import <Foundation/NSString.h>
#import <Foundation/NSSocket.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

/* TODO: Add caching to the NetworkAddress classes. */

static bool parseIPv4Address(NSString *addr, uint8_t *output)
{
	int len = [addr length];
	NSUniChar charAddr[len + 1];
	uint16_t num = 0;
	uint8_t count = 1;
	[addr getCharacters:charAddr
		range:NSMakeRange(0, len)];
	charAddr[len] = 0;

	for (int i = 0; i < sizeof(charAddr); i++)
	{
		if (charAddr[i] == '\0')
		{
			break;
		}
		else if (charAddr[i] == '.')
		{
			if ((i > 0 && charAddr[i-1] == '.') || i == 0)
			{
				return false;
			}
			*output++ = num, num = 0, count++;
		}
		else if (charAddr[i] >= '0' && charAddr[i] <= '9')
		{
			num = num * 10 + charAddr[i] - '0';
		}
		else
		{
			return false;
		}
		if (num > 255)
		{
			return false;
		}
		if (count > 4)
		{
			return false;
		}
	}
	if (count != 4)
	{
		return false;
	}
	*output = num;
	return true;
}

static inline bool hexQuad(NSUniChar *chars, uint16_t *value)
{
	uint16_t val = 0;
	for (int i = 0; i < 4; i++)
	{
		if (*chars == 0)
		{
			break;
		}
		val <<= 4;
		if (*chars >= '0' && *chars <= '9')
		{
			val += *chars - '0';
		}
		else if (*chars >= 'a' && *chars <= 'f')
		{
			val += *chars - 'a' + 0xa;
		}
		else if (*chars >= 'A' && *chars <= 'F')
		{
			val += *chars - 'A' + 0xa;
		}
		else
		{
			return false;
		}
		chars++;
	}
	if (*chars != 0)
		return false;

	*value = val;
	return true;
}

static bool parseIPv6Address(NSString *strAddr, uint8_t *output)
{
	uint8_t addr[16];
	NSArray *components = [strAddr componentsSeparatedByString:@":"];
	// 8 sets of 4 bytes, plus colon
	int count = [components count];
	int i = 0;
	int j = 16;
	int fc = 9 - count;
	int emptyCount = 0;
	NSString *str;

	if (count < 3 || count > 8)
	{
		return false;
	}

	for (i = count - 1; i >= 0; --i)
	{
		/* We fail if we're still parsing and have run out of space */
		if (j <= 0)
		{
			return false;
		}

		str = [components objectAtIndex:i];
		if ([str length] == 0)
		{
			emptyCount++;
			if (i == count - 1)
			{
				if ([[components objectAtIndex:(i-1)] length] != 0)
				{
					return false;
				}
				addr[--j] = 0;
				addr[--j] = 0;
			}
			else if (i == 0)
			{
				/* The address can start with a "::", but not a ":" */
				if ([[components objectAtIndex:1] length] != 0)
				{
					return false;
				}
				addr[--j] = 0;
				addr[--j] = 0;
			}
			else
			{
				/* Can't have more than one set of "::" in an address. */
				if (emptyCount > 1)
					return false;
				for (; fc > 0; fc--)
				{
					if (j <= 0)
					{
						return false;
					}
					addr[--j] = 0;
					addr[--j] = 0;
				}
			}
		}
		else
		{
			uint16_t val;
			NSIndex len = [str length];
			NSUniChar chars[len + 1];
			[str getCharacters:chars range:NSMakeRange(0, len)];
			chars[len] = 0;
			if (!hexQuad(chars, &val))
			{
				if (i != count - 1)
				{
					return false;
				}

				uint8_t ipv4addr[4];
				if (!parseIPv4Address(str, ipv4addr))
				{
					return false;
				}
				addr[--j] = ipv4addr[3];
				addr[--j] = ipv4addr[2];
				addr[--j] = ipv4addr[1];
				addr[--j] = ipv4addr[0];
				--fc;
			}
			else
			{
				addr[--j] = val & 0xff;
				addr[--j] = (val >> 8) & 0xff;
			}
		}
	}
	memcpy(output, addr, sizeof(addr));
	return true;
}

@implementation NSNetworkAddress
- (enum NSProtocolFamily) protocolFamily
{
	return NSUnspecifiedProtocolFamily;
}
@end

@implementation NSInetAddress
+ inetAddressWithString:(NSString *)str
{
	return [[[NSInetAddress alloc] initWithString:str] autorelease];
}

- initWithString:(NSString *)str
{
	uint8_t addr_bytes[16];
	[self release];
	if (parseIPv6Address(str, addr_bytes))
	{
		return [[NSInet6Address alloc] initWithString:str];
	}
	else if (parseIPv4Address(str, addr_bytes))
	{
		return [[NSInet4Address alloc] initWithString:str];
	}
	else
	{
		return nil;
	}
}
@end

@implementation NSInet4Address
#define INET4_LOCAL ((uint32_t)(127 << 24) | (1))
+ localhostInet4Address
{
	uint32_t local = htonl(INET4_LOCAL);
	return [[[NSInet4Address alloc] initWithAddress:(uint8_t *)&local] autorelease];
}

+ anyInet4Address
{
	return [[[NSInet4Address alloc] initWithAddress:INADDR_ANY] autorelease];
}

- initWithString:(NSString *)str
{
	uint8_t bytes[4];
	if (!parseIPv4Address(str, bytes))
	{
		[self release];
		return nil;
	}
	else
	{
		memcpy(&addr, bytes, sizeof(addr));
		addr = htonl(addr);
	}
	return self;
}

- initWithAddress:(uint8_t *)addr_src
{
	memcpy(&addr, addr_src, sizeof(addr));
	return self;
}

- (enum NSProtocolFamily)protocolFamily
{
	return NSInternetProtocolFamily;
}

- (void)_sockaddrRepresentation:(struct sockaddr_storage *)_saddr
{
	struct sockaddr_in *inaddr = (struct sockaddr_in *)_saddr;
	inaddr->sin_len = sizeof(struct sockaddr_in);
	inaddr->sin_addr.s_addr = addr;
	inaddr->sin_family = NSInternetProtocolFamily;
}

- (NSString *) description
{
	char str[255];

	inet_ntop(AF_INET, &addr, str, sizeof(str));
	return [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
}
@end

@implementation NSInet6Address
+ localhostInet6Address
{
	return [[[NSInet6Address alloc] initWithString:@"::1"] autorelease];
}

+ anyInet6Address
{
	return [[[NSInet6Address alloc] initWithString:@"::"] autorelease];
}

- initWithString:(NSString *)str
{
	if (!parseIPv6Address(str, addr))
	{
		[self release];
		return nil;
	}
	return self;
}

- initWithAddress:(uint8_t *)addr_src
{
	memcpy(addr, addr_src, sizeof(addr));
	return self;
}

- (enum NSProtocolFamily)protocolFamily
{
	return NSInternet6ProtocolFamily;
}

- (void)_sockaddrRepresentation:(struct sockaddr_storage *)_saddr
{
	struct sockaddr_in6 *inaddr = (struct sockaddr_in6 *)_saddr;
	memcpy(&inaddr->sin6_addr, addr, sizeof(addr));
	inaddr->sin6_family = NSInternet6ProtocolFamily;
	inaddr->sin6_len = sizeof(struct sockaddr_in6);
}

- (NSString *) description
{
	char str[255];

	inet_ntop(AF_INET6, &addr, str, sizeof(str));
	return [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
}
@end
