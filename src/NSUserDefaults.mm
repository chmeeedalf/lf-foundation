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

#include <dispatch/dispatch.h>

#import <Foundation/NSUserDefaults.h>

#import <Foundation/NSData.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSValue.h>

#import "internal.h"

@class NSString, NSData, NSURL;
@class NSArray, NSMutableArray;
@class NSDictionary, NSMutableDictionary;
@class NSMutableSet;

static NSUserDefaults *standardDefaults;

@interface NSUserDefaults()
- (id) _objectOfClass:(Class)cls forKey:(NSString *)key;
@end

@implementation NSUserDefaults
{
	NSURL               *directoryForSaving;
	NSString            *appDomain;
	NSMutableDictionary *persistentDomains;
	NSMutableDictionary *volatileDomains;
	NSMutableArray      *searchList;
	NSMutableSet        *domainsToRemove;
	NSMutableSet        *dirtyDomains;
	dispatch_source_t    synchronizeSource;
}

/* Creation of defaults */

+ (NSUserDefaults *)standardUserDefaults
{
	NSUserDefaults *s = standardDefaults;

	if (s == nil)
	{
		@synchronized(self)
		{
			s = standardDefaults;
			if (s == nil)
			{
				s = [[NSUserDefaults alloc] init];
				standardDefaults = s;
			}
		}
	}
	return s;
}

+ (void) resetStandardUserDefaults
{
	standardDefaults = nil;
}


/* Initializing the User Defaults */

- (id)init
{
	return [self initWithUser:NSUserName()];
}

- (id)initWithUser:(NSString *)userName
{
	synchronizeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD,
			0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
	dispatch_source_set_event_handler(synchronizeSource, ^{[self synchronize];});
	return nil;
}

- (void) dealloc
{
	[self synchronize];
}


- (void)registerDefaults:(NSDictionary *)dictionary
{
	@synchronized(self)
	{
		NSMutableDictionary *defaults = [volatileDomains objectForKey:NSRegistrationDomain];
		if (defaults == nil)
		{
			defaults = [dictionary mutableCopy];
			[volatileDomains setObject:defaults forKey:NSRegistrationDomain];
		}
		else
		{
			[defaults addEntriesFromDictionary:dictionary];
		}
	}
}


/* Getting and Setting a Default */

- (id) _objectOfClass:(Class)cls forKey:(NSString *)defaultName
{
	id dflt = [self objectForKey:defaultName];

	if (![dflt isKindOfClass:cls])
		return nil;
	return dflt;
}

- (NSArray *)arrayForKey:(NSString *)defaultName
{
	return [self _objectOfClass:[NSArray class] forKey:defaultName];
}

- (bool)boolForKey:(NSString *)defaultName
{
	id dflt = [self _objectOfClass:[NSNumber class] forKey:defaultName];

	if (dflt == nil)
		return false;
	return [dflt boolValue];
}

- (NSData *)dataForKey:(NSString *)defaultName
{
	return [self _objectOfClass:[NSData class] forKey:defaultName];
}

- (NSDictionary *)dictionaryForKey:(NSString *)defaultName
{
	return [self _objectOfClass:[NSDictionary class] forKey:defaultName];
}

- (float)floatForKey:(NSString *)defaultName
{
	id dflt = [self objectForKey:defaultName];

	if (![dflt isKindOfClass:[NSNumber class]])
		return 0.0f;
	return [dflt floatValue];
}

- (NSInteger)integerForKey:(NSString *)defaultName
{
	id dflt = [self objectForKey:defaultName];

	if (![dflt isKindOfClass:[NSNumber class]])
		return 0.0;
	return [dflt doubleValue];
}

- (NSArray *)stringArrayForKey:(NSString *)defaultName
{
	id dflt = [self _objectOfClass:[NSArray class] forKey:defaultName];

	for (id obj in dflt)
	{
		if (![obj isKindOfClass:[NSString class]])
			return nil;
	}
	return dflt;
}

- (NSString *)stringForKey:(NSString *)defaultName
{
	return [self _objectOfClass:[NSString class] forKey:defaultName];
}

- (double)doubleForKey:(NSString *)defaultName
{
	id dflt = [self _objectOfClass:[NSNumber class] forKey:defaultName];

	if (dflt == nil)
		return 0.0;
	return [dflt doubleValue];
}

- (NSURL *)URLForKey:(NSString *)defaultName
{
	id dflt = [self objectForKey:defaultName];

	if ([dflt isKindOfClass:[NSData class]])
	{
		return [NSKeyedUnarchiver unarchiveObjectWithData:dflt];
	}
	else if ([dflt isKindOfClass:[NSString class]])
	{
		return [NSURL fileURLWithPath:[dflt stringByExpandingTildeInPath]];
	}
	return nil;
}


- (id)objectForKey:(NSString *)defaultName
{
	// TODO: use reader-writer locks instead of mutexes
	@synchronized(self)
	{
		for (NSString *domain in searchList)
		{
			NSDictionary *domainDict = [persistentDomains objectForKey:domain];
			if (domainDict == nil)
			{
				domainDict = [volatileDomains objectForKey:domain];
			}
			id retval = [domainDict objectForKey:defaultName];
			if (retval != nil)
			{
				return retval;
			}
		}
	}
	return nil;
}

- (void)removeObjectForKey:(NSString *)defaultName
{
	[[persistentDomains objectForKey:appDomain] removeObjectForKey:defaultName];
	[dirtyDomains addObject:appDomain];
	dispatch_source_merge_data(synchronizeSource, 1);
}


- (void)setBool:(bool)value forKey:(NSString *)defaultName
{
	[self setObject:@(value) forKey:defaultName];
}

- (void)setFloat:(float)value forKey:(NSString *)defaultName
{
	[self setObject:@(value) forKey:defaultName];
}

- (void)setDouble:(double)value forKey:(NSString *)defaultName
{
	[self setObject:@(value) forKey:defaultName];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName
{
	[self setObject:@(value) forKey:defaultName];
}

static bool isPlistObject(id obj)
{
	if ([obj isKindOfClass:[NSNumber class]])
		return true;
	if ([obj isKindOfClass:[NSString class]])
		return true;
	if ([obj isKindOfClass:[NSData class]])
		return true;
	if ([obj isKindOfClass:[NSDate class]])
		return true;
	if ([obj isKindOfClass:[NSArray class]])
	{
		for (id item in obj)
		{
			if (!isPlistObject(item))
				return false;
			return true;
		}
	}
	if ([obj isKindOfClass:[NSDictionary class]])
	{
		__block bool isValid;
		[obj enumerateKeysAndObjectsUsingBlock:^(id key, id val, bool *stop){
			if (!isPlistObject(key) || !isPlistObject(val))
			{
				isValid = false;
				*stop = true;
			}
		}];
		return isValid;
	}
	return false;
}

- (void)setObject:(id)value forKey:(NSString *)defaultName
{
	if (!isPlistObject(value))
	{
		@throw [NSInvalidArgumentException exceptionWithReason:[NSString stringWithFormat:@"Attempting to set default value of invalid type (%@)",[value class]] userInfo:nil];
	}
	@synchronized(self)
	{
		[[persistentDomains objectForKey:appDomain] setObject:[value copy] forKey:defaultName];
		[dirtyDomains addObject:appDomain];
	}
}

- (void)setURL:(NSURL *)value forKey:(NSString *)defaultName
{
	if ([value isFileURL])
	{
		[self setObject:[[[value absoluteURL] path] stringByAbbreviatingWithTildeInPath]
				 forKey:defaultName];
	}
	else
	{
		[self setObject:[NSKeyedArchiver archivedDataWithRootObject:value]
				 forKey:defaultName];
	}
}


/* Maintaining Persistent Domains */

- (bool)synchronize
{
	TODO; // -[NSUserDefaults synchronize]
	return false;
}

- (NSDictionary *)persistentDomainForName:(NSString *)domainName
{
	NSDictionary *domain = [persistentDomains objectForKey:domainName];

	if (domain == nil)
	{
		@synchronized(self)
		{
			domain = [persistentDomains objectForKey:domainName];
			if (domain == nil)
			{
			}
		}
	}
	return domain;
}

- (NSArray *)persistentDomainNames
{
	return [persistentDomains allKeys];
}

- (void)removePersistentDomainForName:(NSString *)domainName
{
	@synchronized(self)
	{
		if ([persistentDomains objectForKey:domainName] == nil)
			return;
		if (![domainName isEqualToString:appDomain])
		{
			[searchList removeObject:domainName];
		}
		// If the domain isn't found in the persistent domain list, it's ignored
		// anyway
		[persistentDomains removeObjectForKey:domainName];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:NSUserDefaultsDidChangeNotification object:self];
}

- (void)setPersistentDomain:(NSDictionary *)domain
  forName:(NSString *)domainName
{
	[persistentDomains setObject:domain forKey:domainName];

	if (![searchList containsObject:domainName])
	{
		// appDomain should always be in searchList
		[searchList insertObject:[domainName copy] atIndex:[searchList
			indexOfObjectIdenticalTo:appDomain] + 1];
	}

	if ([domainName isEqualToString:appDomain])
	{
		[dirtyDomains addObject:[domainName copy]];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:NSUserDefaultsDidChangeNotification object:self];
}


/* Maintaining Volatile Domains */

- (void)removeVolatileDomainForName:(NSString *)domainName
{
	[volatileDomains setObject:nil forKey:domainName];
}

- (void)setVolatileDomain:(NSDictionary *)domain  
  forName:(NSString *)domainName
{
	if ([volatileDomains objectForKey:domainName] != nil)
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"Volatile domain already exists" userInfo:@{ @"NSDomainName" : domainName }];
	}
	[volatileDomains setObject:domain forKey:domainName];
}

- (NSDictionary *)volatileDomainForName:(NSString *)domainName
{
	return [volatileDomains objectForKey:domainName];
}

- (NSArray *)volatileDomainNames
{
	return [volatileDomains allKeys];
}


/* Making Advanced Use of Defaults */

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary new];
	@synchronized(self)
	{
		for (NSString *domain in searchList)
		{
			NSDictionary *domainDict = [persistentDomains objectForKey:domain];
			if (domainDict == nil)
			{
				domainDict = [volatileDomains objectForKey:domain];
			}
			[domainDict enumerateKeysAndObjectsUsingBlock:^(id key, id val,
					bool *stop){
				if ([dict objectForKey:key] == nil)
				{
					[dict setObject:val forKey:key];
				}
			}];
		}
	}
	return [dict copy];
}

- (bool) objectIsForcedForKey:(NSString *)key
{
	TODO; // -[NSUserDefaults objectIsForcedForKey:];
	return false;
}

- (bool) objectIsForcedForKey:(NSString *)key inDomain:(NSString *)domain
{
	TODO; // -[NSUserDefaults objectIsForcedForKey:inDomain:];
	return false;
}

- (void) addSuiteNamed:(NSString *)suiteName
{
	if (suiteName == nil)
	{
		@throw [NSInvalidArgumentException
			exceptionWithReason:@"Attempt to remove a suite with a nil name"
			userInfo:nil];
	}
	@synchronized(self)
	{
		suiteName = [suiteName copy];
		[searchList removeObject:suiteName];
		[searchList insertObject:suiteName atIndex:[searchList
			indexOfObject:appDomain]];
		// Load the domain
		[self persistentDomainForName:suiteName];
	}
}

- (void) removeSuiteNamed:(NSString *)suiteName
{
	if (suiteName == nil)
	{
		@throw [NSInvalidArgumentException
			exceptionWithReason:@"Attempt to remove a suite with a nil name"
			userInfo:nil];
	}
	@synchronized(self)
	{
		[searchList removeObject:suiteName];
		[persistentDomains removeObjectForKey:suiteName];
	}
}

@end

/* Defaults domains */
NSString * const NSArgumentDomain = @"NSArgumentDomain";
NSString * const NSGlobalDomain = @"NSGlobalDomain";
NSString * const NSRegistrationDomain = @"NSRegistrationDomain";

/* Notification name */
NSString * const NSUserDefaultsDidChangeNotification =
	@"NSUserDefaultsDidChangeNotification";
