/* 
   NSUserDefaults.h

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

   This file is part of libFoundation.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.
*/

#ifndef __UserDefaults_h__
#define __UserDefaults_h__

#include <Foundation/NSObject.h>

@class NSString, NSData, NSURI;
@class NSArray, NSMutableArray;
@class NSDictionary, NSMutableDictionary;
@class NSMutableSet;

@interface NSUserDefaults : NSObject
{
	NSURI               *directoryForSaving;
	NSString            *appDomain;
	NSMutableDictionary *persistentDomains;
	NSMutableDictionary *volatileDomains;
	NSMutableArray      *searchList;
	NSMutableSet        *domainsToRemove;
	NSMutableSet        *dirtyDomains;
}

/* Creation of defaults */

+ (NSUserDefaults *)standardUserDefaults;
+ (void) resetStandardUserDefaults;

/* Getting and Setting a Default */

- (NSArray *)arrayForKey:(NSString *)defaultName;
- (NSDictionary *)dictionaryForKey:(NSString *)defaultName;
- (NSData *)dataForKey:(NSString *)defaultName;
- (NSArray *)stringArrayForKey:(NSString *)defaultName;
- (NSString *)stringForKey:(NSString *)defaultName;
- (bool)boolForKey:(NSString *)defaultName;
- (float)floatForKey:(NSString *)defaultName;
- (double)doubleForKey:(NSString *)defaultName;
- (NSInteger)integerForKey:(NSString *)defaultName;
- (NSURI *)URIForKey:(NSString *)defaultName;

- (id)objectForKey:(NSString *)defaultName;
- (void)removeObjectForKey:(NSString *)defaultName;

- (void)setBool:(bool)value forKey:(NSString *)defaultName;
- (void)setFloat:(float)value forKey:(NSString *)defaultName;
- (void)setDouble:(double)value forKey:(NSString *)defaultName;
- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;
- (void)setObject:(id)value forKey:(NSString *)defaultName;
- (void)setURI:(NSURI *)value forKey:(NSString *)defaultName;

/* Initializing the User Defaults */

- (id)init;
- (id)initWithUser:(NSString *)userName;

/* Maintaining Persistent Domains */

- (NSDictionary *)persistentDomainForName:(NSString *)domainName;
- (NSArray *)persistentDomainNames;
- (void)removePersistentDomainForName:(NSString *)domainName;
- (void)setPersistentDomain:(NSDictionary *)domain
  forName:(NSString *)domainName;
- (bool)synchronize;
- (void)persistentDomainHasChanged:(NSString *)domainName;

/* Maintaining Volatile Domains */

- (void)removeVolatileDomainForName:(NSString *)domainName;
- (void)setVolatileDomain:(NSDictionary *)domain  
  forName:(NSString *)domainName;
- (NSDictionary *)volatileDomainForName:(NSString *)domainName;
- (NSArray *)volatileDomainNames;

/* Making Advanced Use of Defaults */

- (NSDictionary *)dictionaryRepresentation;
- (void)registerDefaults:(NSDictionary *)dictionary;

- (void) addSuiteNamed:(NSString *)suiteName;
- (void) removeSuiteNamed:(NSString *)suiteName;
@end

/* Defaults domains */
SYSTEM_EXPORT NSString * const ArgumentDomain;
SYSTEM_EXPORT NSString * const GlobalDomain;
SYSTEM_EXPORT NSString * const RegistrationDomain;

/* const  Defaults Domains */
SYSTEM_EXPORT  NSString * const ArgumentDomain;
SYSTEM_EXPORT  NSString * const GlobalDomain;
SYSTEM_EXPORT  NSString * const RegistrationDomain;
/* const  Notification name */
SYSTEM_EXPORT  NSString * const UserDefaultsDidChangeNotification;

#endif /* __UserDefaults_h__ */

/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
*/
