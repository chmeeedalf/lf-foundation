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

#import <Foundation/NSNetServices.h>

#import <Foundation/NSData.h>
#import <Foundation/NSDelegate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

#import "internal.h"

#include <avahi-client/lookup.h>
#include <avahi-common/malloc.h>

NSString * const NSNetServicesErrorCode = @"NSNetServicesErrorCode";
NSString * const NSNetServicesErrorDomain = @"NSNetServicesErrorDomain";

@interface NSNetServiceBrowser()
- (void) _avahiDomainBrowserDidFindDomain:(NSString *)domain eventType:(AvahiBrowserEvent)evt;
- (void) _avahiServiceBrowserDidFindService:(NSString *)service eventType:(AvahiBrowserEvent)evt;
@end

@implementation NSNetService
{
	NSString *srvDomain;
	NSString *srvType;
	NSString *srvName;
	id delegate;
	NSInteger port;
}

- (id) initWithDomain:(NSString *)domain type:(NSString *)type name:(NSString *)name
{
	return [self initWithDomain:domain type:type name:name port:-1];
}

- (id) initWithDomain:(NSString *)domain type:(NSString *)type name:(NSString *)name port:(int)srvPort
{
	if ((self = [super init]) != nil)
	{
		delegate = [[NSDelegate alloc] initWithProtocol:@protocol(NSNetServiceDelegate)];
		srvDomain = [domain copy];
		srvType = [type copy];
		srvName = [name copy];
		port = srvPort;
	}
	return self;
}

+ (NSData *) dataFromTXTRecordDictionary:(NSDictionary *)txtDictionary
{
	__block AvahiStringList *list = NULL;

	[txtDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, bool *stop)
	{
		if ([obj isKindOfClass:[NSNumber class]])
			obj = [obj stringValue];
		else if ([obj isKindOfClass:[NSData class]])
		{
			if ([obj length] > 255)
			{
				*stop = true;
				avahi_string_list_free(list);
				list = NULL;
				return;
			}
			list = avahi_string_list_add_pair_arbitrary(list, [key UTF8String],
					[obj bytes], [obj length]);
		}
		list = avahi_string_list_add_pair(list, [key UTF8String], [obj UTF8String]);
	}];

	NSAssert(list != NULL, @"Error creating TXT record from dictionary.");

	size_t len = avahi_string_list_serialize(list, NULL, 0);

	NSMutableData *d = [NSMutableData dataWithCapacity:len];
	[d setLength:len];
	avahi_string_list_serialize(list, [d mutableBytes], len);
	avahi_string_list_free(list);
	return d;
}

+ (NSDictionary *) dictionaryFromTXTRecordData:(NSData *)txtData
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	if (txtData != nil)
	{
		const char *bytes = [txtData bytes];
		size_t len = [txtData length];
		AvahiStringList *l = NULL;
		if (avahi_string_list_parse(bytes, len, &l) != 0)
		{
			NSAssert(0, @"Cannot parse TXT data");
			return nil;
		}

		AvahiStringList *pls = l;
		for (; pls != NULL; pls = avahi_string_list_get_next(pls))
		{
			char *key;
			char *val;
			NSString *k;
			NSData *v;

			if (avahi_string_list_get_pair(pls, &key, &val, &len) != 0)
			{
				NSAssert(0, @"Cannot parse TXT data");
				return nil;
			}
			if (key != NULL)
			{
				k = [NSString stringWithUTF8String:key];
				avahi_free(key);
			}
			if (val != NULL)
			{
				v = [NSData dataWithBytes:val length:len];
				avahi_free(val);
			}
			else
			{
				v = [NSData data];
			}
			[dict setObject:v forKey:k];
		}
		avahi_string_list_free(l);
	}
	return nil;
}

- (NSArray *) addresses
{
	TODO;	// -[NSNetService addresses]
	return nil;
}

- (NSString *) domain
{
	return srvDomain;
}

- (bool) getInputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream
{
	TODO; // -[NSNetService getInputStream:outputStream:]
	return false;
}

- (NSString *) hostName
{
	TODO;	// -[NSNetService hostName]
	return nil;
}

- (NSString *) name
{
	return srvName;
}

- (NSString *) type
{
	return srvType;
}

- (NSData *) TXTRecordData
{
	TODO; // -[NSNetService TXTRecordData]
	return nil;
}

- (bool) setTXTRecordData:(NSData *)data
{
	TODO; // -[NSNetService setTXTRecordData:]
	return false;
}

- (id<NSNetServiceDelegate>) delegate
{
	return [delegate delegate];
}

- (void) setDelegate:(id <NSNetServiceDelegate>)del
{
	[delegate setDelegate:del];
}

- (void) scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
	TODO; // -[NSNetService scheduleInRunLoop:forMode:]
}

- (void) removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
	TODO; // -[NSNetService removeFromRunLoop:forMode:]
}


- (void) publish
{
	[self publishWithOptions:0];
}

- (void) publishWithOptions:(NSNetServiceOptions)opts
{
	TODO; // -[NSNetService publishWithOptions:]
}

- (void) resolveWithTimeout:(NSTimeInterval)timeout
{
	TODO; // -[NSNetService resolveWithTimeout:]
}

- (NSInteger) port
{
	return port;
}

- (void) startMonitoring
{
	TODO; // -[NSNetService startMonitoring]
}

- (void) stop
{
	TODO; // -[NSNetService stop]
}

- (void) stopMonitoring
{
	TODO; // -[NSNetService stopMonitoring]
}

@end

static void NSAvahiNetServiceBrowserDomainCallback(AvahiDomainBrowser *b,
		AvahiIfIndex idx,
		AvahiProtocol proto,
		AvahiBrowserEvent evt,
		const char *domain,
		AvahiLookupResultFlags flags,
		void *userdata)
{
	[(__bridge NSNetServiceBrowser *)userdata
		_avahiDomainBrowserDidFindDomain:[NSString stringWithUTF8String:domain]
							   eventType:evt];
}

@implementation NSNetServiceBrowser
{
	NSDelegate *delegate;

	AvahiPoll avahi_poll;
	AvahiClient *client;
	AvahiServiceBrowser *browser;
	AvahiDomainBrowser *domainBrowser;
}

- (id) init
{
	if ((self = [super init]) != nil)
	{
		delegate = [[NSDelegate alloc] initWithProtocol:@protocol(NSNetServiceBrowserDelegate)];

		avahi_poll.userdata = (__bridge void *)self;
		client = avahi_client_new(&avahi_poll, 0, NULL, NULL, NULL);

		if (client == NULL)
			return nil;
	}
	return self;
}

- (void) dealloc
{
	[self stop];
	avahi_client_free(client);
}

- (id<NSNetServiceBrowserDelegate>) delegate
{
	return [delegate delegate];
}

- (void) setDelegate:(id<NSNetServiceBrowserDelegate>)newDel
{
	[delegate setDelegate:newDel];
}

- (void) searchForDomainsOfType:(AvahiDomainBrowserType)type
{
	@synchronized(self)
	{
		/* Only allow one browse at a time. */
		if (domainBrowser != NULL)
			return;
		domainBrowser = avahi_domain_browser_new(client, AVAHI_IF_UNSPEC,
				AVAHI_PROTO_UNSPEC,
				"local.",
				type,
				0,
				NSAvahiNetServiceBrowserDomainCallback,	// Handle event callback
				(__bridge void *)self);
	}
}

- (void) searchForBrowsableDomains
{
	[self searchForDomainsOfType:AVAHI_DOMAIN_BROWSER_BROWSE];
}

- (void) searchForRegistrationDomains
{
	[self searchForDomainsOfType:AVAHI_DOMAIN_BROWSER_REGISTER];
}

- (void) searchForServicesOfType:(NSString *)type inDomain:(NSString *)domainName
{
	@synchronized(self)
	{
		if (browser != NULL)
			return;

		browser = avahi_service_browser_new(client, AVAHI_IF_UNSPEC,
				AVAHI_PROTO_UNSPEC,
				[type UTF8String],
				[domainName UTF8String],
				0,
				NULL,	// Handle event callback
				(__bridge void *)self);
	}
}

- (void) stop
{
	@synchronized(self)
	{
		if (domainBrowser != NULL)
		{
			avahi_domain_browser_free(domainBrowser);
		}
		if (browser != NULL)
		{
			avahi_service_browser_free(browser);
		}
	}
}


- (void) scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
	TODO;	// -[NSNetServiceBrowser scheduleInRunLoop:forMode:]
}

- (void) removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
	TODO;	// -[NSNetServiceBrowser removeFromRunLoop:forMode:]
}

- (void) _avahiDomainBrowserDidFindDomain:(NSString *)domain eventType:(AvahiBrowserEvent)evt
{
	if (evt == AVAHI_BROWSER_REMOVE)
	{
		[(id<NSNetServiceBrowserDelegate>)delegate netServiceBrowser:self
													 didRemoveDomain:domain
														  moreComing:(evt == AVAHI_BROWSER_ALL_FOR_NOW)];
	}
	else
	{
		[(id<NSNetServiceBrowserDelegate>)delegate netServiceBrowser:self
													   didFindDomain:domain
														  moreComing:(evt == AVAHI_BROWSER_ALL_FOR_NOW)];
	}
}

- (void) _avahiServiceBrowserDidFindService:(NSString *)service eventType:(AvahiBrowserEvent)evt
{
	if (evt == AVAHI_BROWSER_REMOVE)
	{
		[(id<NSNetServiceBrowserDelegate>)delegate netServiceBrowser:self
			didRemoveService:service
				 moreComing:(evt == AVAHI_BROWSER_ALL_FOR_NOW)];
	}
	else
	{
		[(id<NSNetServiceBrowserDelegate>)delegate netServiceBrowser:self
			didFindService:service
				moreComing:(evt == AVAHI_BROWSER_ALL_FOR_NOW)];
	}
}

@end
