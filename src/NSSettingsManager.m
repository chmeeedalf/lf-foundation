/*
 * Copyright (c) 2007-2012	Justin Hibbits
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
#import <Foundation/NSException.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSSettingsManager.h>
#import <Foundation/NSString.h>
#import "internal.h"

static NSSettingsManager *defaultSettingsManager = nil;
static NSMutableDictionary *mutableSettings = nil;
static NSMutableDictionary *registrationDomain = nil;

NSString * const NSSettingsDidChangeNotification = @"NSSettingsDidChangeNotification";

@implementation NSSettingsManager

/*
   TODO: Make this work.
   - Use resource manager to load 'bundle' settings.
   - Use object manager to load 'personal' settings.
 */
+ (void)initialize
{
	defaultSettingsManager = [NSSettingsManager new];
}

+ (NSSettingsManager *)defaultSettingsManager
{
	return defaultSettingsManager;
}

- (void) registerSettings:(NSDictionary *) dictionary
{
	[registrationDomain addEntriesFromDictionary:dictionary];
}

// Retrieving settings
- (id) objectForKey:(NSString *)key
{
	@synchronized(self)
	{
		for (NSString *name in searchList)
		{
			id obj = [[allDomains objectForKey:name] objectForKey:key];
			if (obj != nil)
			{
				return obj;
			}
		}
		return nil;
	}
}

- (id) valueForKey:(NSString *)key
{
	return [self objectForKey:key];
}

- (NSArray *) arrayForKey:(NSString *)key
{
	id obj = [self objectForKey:key];

	if (![obj isKindOfClass:[NSArray class]])
		return nil;
	return obj;
}

- (bool)boolForKey:(NSString *)key
{
	id obj = [self objectForKey:key];

	if (![obj isKindOfClass:[NSNumber class]])
		return false;
	return [obj boolValue];
}

- (NSData *) dataForKey:(NSString *)key
{
	id obj = [self objectForKey:key];

	if (![obj isKindOfClass:[NSData class]])
		return nil;
	return obj;
}

- (NSDictionary *) dictionaryForKey:(NSString *)key
{
	id obj = [self objectForKey:key];

	if (![obj isKindOfClass:[NSDictionary class]])
		return nil;
	return obj;
}

- (double)doubleForKey:(NSString *)key
{
	id obj = [self objectForKey:key];

	if (![obj isKindOfClass:[NSNumber class]])
		return 0.0;
	return [obj doubleValue];
}

- (int)integerForKey:(NSString *)key
{
	id obj = [self objectForKey:key];

	if (![obj isKindOfClass:[NSNumber class]])
		return 0;
	return [obj intValue];
}

- (float)floatForKey:(NSString *)key
{
	id obj = [self objectForKey:key];

	if (![obj isKindOfClass:[NSNumber class]])
		return 0.0;
	return [obj floatValue];
}

- (NSString *) stringForKey:(NSString *)key
{
	id obj = [self objectForKey:key];

	if (![obj isKindOfClass:[NSString class]])
		return nil;
	return obj;
}

// Setting settings
- (void)setObject:(id)val forKey:(NSString *)key
{
	[mutableSettings setObject:val forKey:key];
}

- (void)setInteger:(int)val forKey:(NSString *)key
{
	[self setObject:[NSNumber numberWithInt:val] forKey:key];
}

- (void)setFloat:(float)val forKey:(NSString *)key
{
	[self setObject:[NSNumber numberWithFloat:val] forKey:key];
}

- (void)setDouble:(double)val forKey:(NSString *)key
{
	[self setObject:[NSNumber numberWithDouble:val] forKey:key];
}

- (void)setBool:(bool)val forKey:(NSString *)key
{
	[self setObject:[NSNumber numberWithBool:val] forKey:key];
}

- (void) removeObjectForKey:(NSString *)key
{
	TODO; // -[NSSettingsManager removeObjectForKey:]
}

- (void) synchronize
{
	TODO; // -[NSSettingsManager synchronize]
}

- (NSDictionary *) persistentDomainForName:(NSString *)name
{
	if (![persistentDomains member:name])
		return nil;
	return [allDomains objectForKey:name];
}

- (NSArray *) persistentDomainNames
{
	return [persistentDomains allObjects];
}

- (void) removePersistentDomainForName:(NSString *)name
{
	if ([persistentDomains member:name])
	{
		[persistentDomains removeObject:name];
		[allDomains setObject:nil forKey:name];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:NSSettingsDidChangeNotification object:self];
}

- (void) setPersistentDomain:(NSDictionary *)domain forName:(NSString *)domainName
{
	if ([volatileDomains member:domainName])
		@throw [NSInvalidArgumentException exceptionWithReason:@"Volatile domain already exists." userInfo:[NSDictionary dictionaryWithObjectsAndKeys:domainName,@"Domain name"]];
	[persistentDomains addObject:domainName];
	[allDomains setObject:domain forKey:domainName];
	[[NSNotificationCenter defaultCenter] postNotificationName:NSSettingsDidChangeNotification object:self];
}

- (void) removeVolatileDomainForName:(NSString *)name
{
	if ([volatileDomains member:name])
	{
		[volatileDomains removeObject:name];
		[allDomains setObject:nil forKey:name];
	}
}

- (void) setVolatileDomain:(NSDictionary *)domain forName:(NSString *)domainName
{
	if ([persistentDomains member:domainName])
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"Persistent domain already exists." userInfo:[NSDictionary dictionaryWithObjectsAndKeys:domainName,@"Domain name"]];
	}
	if ([volatileDomains member:domainName])
		@throw [NSInvalidArgumentException exceptionWithReason:@"Volatile domain already exists." userInfo:[NSDictionary dictionaryWithObjectsAndKeys:domainName,@"Domain name"]];
	[volatileDomains addObject:domainName];
	[allDomains setObject:domain forKey:domainName];
}

- (NSDictionary *) volatileDomainForName:(NSString *)name
{
	if (![volatileDomains member:name])
		return nil;
	return [allDomains objectForKey:name];
}

- (NSArray *) volatileDomainNames
{
	return [volatileDomains allObjects];
}

- (void) addSuiteNamed:(NSString *)name
{
	[self notImplemented:_cmd];
}

- (void) removeSuiteNamed:(NSString *)name
{
	[self notImplemented:_cmd];
}
@end
