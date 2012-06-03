/* 
   NSUserDefaults.h

   Copyright (C) 2012	Justin Hibbits
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

#import <Foundation/NSObject.h>

@class NSString, NSData, NSURL;
@class NSArray, NSMutableArray;
@class NSDictionary, NSMutableDictionary;
@class NSMutableSet;

@interface NSUserDefaults : NSObject

/* Creation of defaults */

+ (NSUserDefaults *)standardUserDefaults;
+ (void) resetStandardUserDefaults;

/* Initializing the User Defaults */

- (id)init;
- (id)initWithUser:(NSString *)userName;

- (void)registerDefaults:(NSDictionary *)dictionary;

/* Getting and Setting a Default */

- (NSArray *)arrayForKey:(NSString *)defaultName;
- (bool)boolForKey:(NSString *)defaultName;
- (NSData *)dataForKey:(NSString *)defaultName;
- (NSDictionary *)dictionaryForKey:(NSString *)defaultName;
- (float)floatForKey:(NSString *)defaultName;
- (NSInteger)integerForKey:(NSString *)defaultName;
- (NSArray *)stringArrayForKey:(NSString *)defaultName;
- (NSString *)stringForKey:(NSString *)defaultName;
- (double)doubleForKey:(NSString *)defaultName;
- (NSURL *)URLForKey:(NSString *)defaultName;

- (id)objectForKey:(NSString *)defaultName;
- (void)removeObjectForKey:(NSString *)defaultName;

- (void)setBool:(bool)value forKey:(NSString *)defaultName;
- (void)setFloat:(float)value forKey:(NSString *)defaultName;
- (void)setDouble:(double)value forKey:(NSString *)defaultName;
- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;
- (void)setObject:(id)value forKey:(NSString *)defaultName;
- (void)setURL:(NSURL *)value forKey:(NSString *)defaultName;

/* Maintaining Persistent Domains */

- (bool)synchronize;
- (NSDictionary *)persistentDomainForName:(NSString *)domainName;
- (NSArray *)persistentDomainNames;
- (void)removePersistentDomainForName:(NSString *)domainName;
- (void)setPersistentDomain:(NSDictionary *)domain
  forName:(NSString *)domainName;

/* Maintaining Volatile Domains */

- (void)removeVolatileDomainForName:(NSString *)domainName;
- (void)setVolatileDomain:(NSDictionary *)domain  
  forName:(NSString *)domainName;
- (NSDictionary *)volatileDomainForName:(NSString *)domainName;
- (NSArray *)volatileDomainNames;

/* Making Advanced Use of Defaults */

- (NSDictionary *)dictionaryRepresentation;

- (bool) objectIsForcedForKey:(NSString *)key;
- (bool) objectIsForcedForKey:(NSString *)key inDomain:(NSString *)domain;

- (void) addSuiteNamed:(NSString *)suiteName;
- (void) removeSuiteNamed:(NSString *)suiteName;
@end

/* Defaults domains */
SYSTEM_EXPORT NSString * const NSArgumentDomain;
SYSTEM_EXPORT NSString * const NSGlobalDomain;
SYSTEM_EXPORT NSString * const NSRegistrationDomain;

/* Notification name */
SYSTEM_EXPORT NSString * const NSUserDefaultsDidChangeNotification;

#endif /* __UserDefaults_h__ */

/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
 */
