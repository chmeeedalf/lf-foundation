/*
 * Copyright (c) 2011-2012	Justin Hibbits
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

#import <Foundation/NSURLCredentialStorage.h>

#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURLCredential.h>
#import <Foundation/NSURLProtectionSpace.h>

NSString * const NSURLCredentialStorageChangedNotification = @"NSURLCredentialStorageChangedNotification";

static NSURLCredentialStorage *sharedStorage;

@implementation NSURLCredentialStorage
{
	NSMutableDictionary *defaultCredentials;
	NSMutableDictionary *allCredentials;
}

+ (void) initialize
{
	if (sharedStorage == nil)
		sharedStorage = [[NSURLCredentialStorage alloc] init];
}

+(NSURLCredentialStorage *)sharedCredentialStorage
{
	return sharedStorage;
}

+ (id) allocWithZone:(NSZone *)zone
{
	if (sharedStorage == nil)
	{
		@synchronized([NSURLCredentialStorage class])
		{
			if (sharedStorage == nil)
				sharedStorage = [super allocWithZone:zone];
		}
	}
	return sharedStorage;
}

-(id)init
{
	if (self == sharedStorage)
	{
		if (defaultCredentials == nil)
			defaultCredentials = [NSMutableDictionary new];
		if (allCredentials == nil)
			allCredentials = [NSMutableDictionary new];
	}
	return self;
}

-(NSDictionary *)allCredentials
{
	NSMutableDictionary *ret = [NSMutableDictionary new];

	for (NSDictionary *d in allCredentials)
	{
		[ret addEntriesFromDictionary:[allCredentials objectForKey:d]];
	}
	return ret;
}

-(NSDictionary *)credentialsForProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return [allCredentials objectForKey:protectionSpace];
}

-(NSURLCredential *)defaultCredentialForProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return [defaultCredentials objectForKey:protectionSpace];
}

-(void)setCredential:(NSURLCredential *)credential forProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	if ([allCredentials objectForKey:protectionSpace] == nil)
	{
		[allCredentials setObject:[NSMutableDictionary new] forKey:protectionSpace];
	}
	[[allCredentials objectForKey:protectionSpace] setObject:credential forKey:[credential user]];
}

-(void)setDefaultCredential:(NSURLCredential *)credential forProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	[defaultCredentials setObject:credential forKey:protectionSpace];
	[self setCredential:credential forProtectionSpace:protectionSpace];
}

-(void)removeCredential:(NSURLCredential *)credential forProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	if ([defaultCredentials objectForKey:protectionSpace] == credential)
	{
		[defaultCredentials removeObjectForKey:protectionSpace];
	}
	[[allCredentials objectForKey:protectionSpace] removeObjectForKey:[credential user]];
}

@end
