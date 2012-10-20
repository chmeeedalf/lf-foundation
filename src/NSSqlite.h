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

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>

@class NSURL;
/*
 * An NSSqliteArray treats a database table as an NSMutableArray, where objects
 * are not necessarily unique.
 *
 * An NSSqliteDictionary treats a database table as an NSMutableDictionary,
 * where objects are unique based on a single key.
 *
 * Regardless of which type is chose, they are treated as a collection of
 * NSDictionary instances.  Adding a dictionary with an unrecognized key will
 * add a new column to the table.
 *
 * Available column types:
 * * NSString
 * * NSData
 * * NSNumber
 * * NSNull
 *
 * Similar to the property list types.  The schema is created with the first
 * item added to the collection, and updated appropriately.
 */

@interface NSSqliteDatabase	:	NSObject
{
}
+ (id) databaseWithURL:(NSURL *)url;
@end

@protocol NSSqlTable

@end

@interface NSSqliteArray	:	NSMutableArray
{
}
+ (id) arrayWithTableName:(NSString *)name database:(NSSqliteDatabase *)db;
@end

@interface NSSqliteDictionary	:	NSMutableDictionary
{
}
+ (id) dictionaryWithTableName:(NSString *)name identityKey:(NSString *)keyName database:(NSSqliteDatabase *)db;
@end
