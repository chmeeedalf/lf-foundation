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

#import <Foundation/NSObject.h>

@class NSDictionary, NSString, NSMutableSet;

SYSTEM_EXPORT NSString * const NSSettingsDidChangeNotification;

/*!
  \class SettingsManager
  \brief Manages the reading and writing of program and system settings.

  \details The settings manager uses the ResourceManager to read the settings
  objects, and manage the writing of settings.
 */
@interface NSSettingsManager	:	NSObject
{
	NSMutableArray *searchList;
	NSMutableSet *persistentDomains;
	NSMutableSet *volatileDomains;
	NSMutableDictionary *allDomains;
}

/*!
 * \brief Returns the process-global SettingsManager singleton.
 */
+ (NSSettingsManager *)defaultSettingsManager;

// Retrieving settings
/*!
 * \brief Returns the object value for the given key.
 * \param key Key to return the value for.
 *
 * \details Will return \c nil if the key does not exist in the SettingsManager
 * database.
 */
- (id) objectForKey:(NSString *)key;

/*!
 * \brief Returns the boolean value of the given key.
 * \param key Key of the boolean to retrieve.
 * \sa [SettingsManager objectForKey:]
 */
- (bool)boolForKey:(NSString *)key;

/*!
 * \brief Returns the integer value of the given key.
 * \param key Key of the integer to retrieve.
 * \sa [SettingsManager objectForKey:]
 */
- (int)integerForKey:(NSString *)key;

/*!
 * \brief Returns the floating point value of the given key.
 * \param key Key of the floating point to retrieve.
 * \sa [SettingsManager objectForKey:]
 */
- (float)floatForKey:(NSString *)key;

/*!
 * \brief Returns the double-precision floating point value of the given key.
 * \param key Key of the double-precision floating point to retrieve.
 * \sa [SettingsManager objectForKey:]
 */
- (double)doubleForKey:(NSString *)key;

// Setting settings
/*!
 * \brief Set the object value for a given key, in the persistent domain.
 * \param val NSValue to set.
 * \param key Key to set the value for.
 */
- (void)setObject:(id)val forKey:(NSString *)key;

/*!
 * \brief Set the integer value for a given key, in the persistent domain.
 * \param val NSValue to set.
 * \param key Key to set the value for.
 * \sa [SettingsManager setObject:forKey:]
 */
- (void)setInteger:(int)val forKey:(NSString *)key;

/*!
 * \brief Set the floating point value for a given key, in the persistent domain.
 * \param val NSValue to set.
 * \param key Key to set the value for.
 * \sa [SettingsManager setObject:forKey:]
 */
- (void)setFloat:(float)val forKey:(NSString *)key;

/*!
 * \brief Set the boolean value for a given key, in the persistent domain.
 * \param val NSValue to set.
 * \param key Key to set the value for.
 * \sa [SettingsManager setObject:forKey:]
 */
- (void)setBool:(bool)val forKey:(NSString *)key;

- (void) removeObjectForKey:(NSString *)key;

- (void) synchronize;
- (NSDictionary *) persistentDomainForName:(NSString *)name;
- (NSArray *) persistentDomainNames;
- (void) removePersistentDomainForName:(NSString *)name;
- (void) setPersistentDomain:(NSDictionary *)domain forName:(NSString *)domainName;

- (void) removeVolatileDomainForName:(NSString *)name;
- (void) setVolatileDomain:(NSDictionary *)domain forName:(NSString *)domainName;
- (NSDictionary *) volatileDomainForName:(NSString *)name;
- (NSArray *) volatileDomainNames;

- (void) addSuiteNamed:(NSString *)name;
- (void) removeSuiteNamed:(NSString *)name;
@end

/*
   vim:syntax=objc:
 */
