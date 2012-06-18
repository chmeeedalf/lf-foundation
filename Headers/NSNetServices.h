/*
 * Copyright (c) 2011	Justin Hibbits
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

@class NSData;
@class NSDictionary;
@class NSInputStream;
@class NSOutputStream;
@class NSString;
@class NSNetService;
@class NSNetServiceBrowser;
@class NSRunLoop;

extern NSString * const NSNetServicesErrorCode;
extern NSString * const NSNetServicesErrorDomain;

typedef enum
{
	NSNetServicesUnknownError = -72000,
	NSNetServicesCollisionError = -72001,
	NSNetServicesNotFoundError = -72002,
	NSNetServicesActivityInProgress = -72003,
	NSNetServicesBadArgumentError = -72004,
	NSNetServicesCancelledError = -72005,
	NSNetServicesInvalidError = -72006,
	NSNetServicesTimeoutError = -72007,
} NSNetServicesError;

enum
{
	NSNetServiceNoAutoRename = 1 << 0,
};
typedef NSUInteger NSNetServiceOptions;

@protocol NSNetServiceDelegate<NSObject>
@optional
- (void) netServiceWillPublish:(NSNetService *)service;
- (void) nsetService:(NSNetService *)service didNotPublish:(NSDictionary *)errorDict;
- (void) netServiceDidPublish:(NSNetService *)service;
- (void) netServiceWillResolve:(NSNetService *)service;
- (void) nsetService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict;
- (void) netServiceDidResolve:(NSNetService *)service;
- (void) netService:(NSNetService *)service didUpdateTXTRecordData:(NSData *)txtData;
- (void) netServiceDidStop:(NSNetService *)service;
@end

@interface NSNetService	:	NSObject

- (id) initWithDomain:(NSString *)domain type:(NSString *)type name:(NSString *)name;
- (id) initWithDomain:(NSString *)domain type:(NSString *)type name:(NSString *)name port:(int)port;

+ (NSData *) dataFromTXTRecordDictionary:(NSDictionary *)txtDictionary;
+ (NSDictionary *) dictionaryFromTXTRecordData:(NSData *)txtData;

- (NSArray *) addresses;
- (NSString *) domain;
- (bool) getInputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream;
- (NSString *) hostName;
- (NSString *) name;
- (NSString *) type;
- (NSData *) TXTRecordData;
- (bool) setTXTRecordData:(NSData *)data;
- (id<NSNetServiceDelegate>) delegate;
- (void) setDelegate:(id <NSNetServiceDelegate>)del;

- (void) scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void) removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;

- (void) publish;
- (void) publishWithOptions:(NSNetServiceOptions)opts;
- (void) resolveWithTimeout:(NSTimeInterval)timeout;
- (NSInteger) port;
- (void) startMonitoring;
- (void) stop;
- (void) stopMonitoring;

@end

@protocol NSNetServiceBrowserDelegate<NSObject>
@optional
- (void) netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domain moreComing:(bool)moreComing;
- (void) netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domain moreComing:(bool)moreComing;
- (void) netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSString *)service moreComing:(bool)moreComing;
- (void) netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSString *)service moreComing:(bool)moreComing;
- (void) netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser;
- (void) netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errInfo;
- (void) netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser;
@end
@interface NSNetServiceBrowser	:	NSObject
- (id) init;

- (id<NSNetServiceBrowserDelegate>) delegate;
- (void) setDelegate:(id<NSNetServiceBrowserDelegate>)newDel;

- (void) searchForBrowsableDomains;
- (void) searchForRegistrationDomains;
- (void) searchForServicesOfType:(NSString *)type inDomain:(NSString *)domainName;
- (void) stop;

- (void) scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void) removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;

@end
