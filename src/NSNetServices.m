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

#import <Foundation/NSDelegate.h>

#import "internal.h"

NSString * const NSNetServicesErrorCode = @"NSNetServicesErrorCode";
NSString * const NSNetServicesErrorDomain = @"NSNetServicesErrorDomain";

@implementation NSNetService
{
	NSString *srvDomain;
	NSString *srvType;
	NSString *srvName;
	id delegate;
	int port;
}

- (id) initWithDomain:(NSString *)domain type:(NSString *)type name:(NSString *)name
{
	return [self initWithDomain:domain type:type name:name port:-1];
}

- (id) initWithDomain:(NSString *)domain type:(NSString *)type name:(NSString *)name port:(int)port
{
	TODO; // -[NSNetService initWithDomain:type:name:port:]
	delegate = [[NSDelegate alloc] initWithProtocol:@protocol(NSNetServiceDelegate)];
	return self;
}

+ (NSData *) dataFromTXTRecordDictionary:(NSDictionary *)txtDictionary
{
	TODO;	// +[NSNetService dataFromTXTRecordDictionary:]
	return nil;
}

+ (NSDictionary *) dictionaryFromTXTRecordData:(NSData *)txtData
{
	TODO;	// +[NSNetService dictionaryFromTXTRecordDictionary:]
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
	TODO; // -[NSNetService publish]
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
	TODO; // -[NSNetService port]
	return 0;
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

@implementation NSNetServiceBrowser
{
}

- (id) init
{
	TODO;	// -[NSNetServiceBrowser init]
	return self;
}


- (id<NSNetServiceBrowserDelegate>) delegate
{
	TODO;	// -[NSNetServiceBrowser delegate]
	return nil;
}

- (void) setDelegate:(id<NSNetServiceBrowserDelegate>)newDel
{
	TODO;	// -[NSNetServiceBrowser setDelegate:]
}


- (void) searchForBrowsableDomains
{
	TODO;	// -[NSNetServiceBrowser searchForBrowsableDomains]
}

- (void) searchForRegistrationDomains
{
	TODO;	// -[NSNetServiceBrowser searchForRegistrationDomains]
}

- (void) searchForServicesOfType:(NSString *)type inDomain:(NSString *)domainName
{
	TODO;	// -[NSNetServiceBrowser searchForServicesOfType:inDomain:]
}

- (void) stop
{
	TODO;	// -[NSNetServiceBrowser stop]
}


- (void) scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
	TODO;	// -[NSNetServiceBrowser scheduleInRunLoop:forMode:]
}

- (void) removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
	TODO;	// -[NSNetServiceBrowser removeFromRunLoop:forMode:]
}


@end
