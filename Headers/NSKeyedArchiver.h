/*
 * Copyright (c) 2010	Justin Hibbits
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

#import <Foundation/NSCoder.h>

#import <Foundation/NSException.h>
#import <Foundation/NSPropertyList.h>

@class NSKeyedArchiver, NSKeyedUnarchiver;
@class NSURL, NSMutableData, NSError;
@class NSMapTable;

@interface NSInvalidArchiveOperationException	:	NSStandardException
@end

@interface NSInvalidUnarchiveOperationException	:	NSStandardException
@end

@protocol NSKeyedArchiverDelegate<NSObject>
@optional
- (void)archiver:(NSKeyedArchiver *)archiver didEncodeObject:(id)object;
- (id)archiver:(NSKeyedArchiver *)archiver willEncodeObject:(id)object;
- (void)archiver:(NSKeyedArchiver *)archiver willReplaceObject:(id)object withObject:(id)newObject;
- (void)archiverDidFinish:(NSKeyedArchiver *)archiver;
- (void)archiverWillFinish:(NSKeyedArchiver *)archiver;
@end

@protocol NSKeyedUnarchiverDelegate<NSObject>
@optional
- (Class)unarchiver:(NSKeyedUnarchiver *)unarchiver cannotDecodeObjectOfClassName:(NSString *)name originalClasses:(NSArray *)classNames;
- (id)unarchiver:(NSKeyedUnarchiver *)unarchiver didDecodeObject:(id)object;
- (void)unarchiver:(NSKeyedUnarchiver *)unarchiver willReplaceObject:(id)object withObject:(id)newObject;
- (void)unarchiverDidFinish:(NSKeyedUnarchiver *)unarchiver;
- (void)unarchiverWillFinish:(NSKeyedUnarchiver *)unarchiver;
@end

@class NSMutableArray, NSMutableDictionary;
/*!
  \class NSKeyedArchiver
 */
@interface NSKeyedArchiver	:	NSCoder

+ (NSData *)archivedDataWithRootObject:(id)rootObject;
+ (bool)archiveRootObject:(id)rootObject toURL:(NSURL *)path;

- (id) initForWritingWithMutableData:(NSMutableData *)d;

// Keyed coding

- (bool) allowsKeyedCoding;

- (void) encodeBool:(bool)boolv forKey:(NSString *)key;
- (void) encodeBytes:(const uint8_t *)bytes length:(size_t)len forKey:(NSString *)key;
- (void) encodeConditionalObject:(id)object forKey:(NSString *)key;
- (void) encodeDouble:(double)doublev forKey:(NSString *)key;
- (void) encodeFloat:(float)floatv forKey:(NSString *)key;
- (void) encodeInt:(int)intv forKey:(NSString *)key;
- (void) encodeInt32:(int32_t)int32v forKey:(NSString *)key;
- (void) encodeInt64:(int64_t)int64v forKey:(NSString *)key;
- (void) encodeObject:(id)object forKey:(NSString *)key;
- (void) encodePoint:(NSPoint)pointv forKey:(NSString *)key;
- (void) encodeRect:(NSRect)rectv forKey:(NSString *)key;
- (void) encodeSize:(NSSize)sizev forKey:(NSString *)key;
- (void) finishEncoding;

+ (NSString *) classNameForClass:(Class)cls;
+ (void) setClassName:(NSString *)name forClass:(Class)cls;
- (NSString *) classNameForClass:(Class)cls;
- (void) setClassName:(NSString *)name forClass:(Class)cls;

- (id<NSKeyedArchiverDelegate>) delegate;
- (void)setDelegate:(id<NSKeyedArchiverDelegate>)delegate;

- (void) setOutputFormat:(NSPropertyListFormat)format;
- (NSPropertyListFormat) outputFormat;

@end

@interface NSKeyedUnarchiver	:	NSCoder

+ (id)unarchiveObjectWithData:(NSData *)rootObject;
+ (id)unarchiveRootObjectWithURL:(NSURL *)path;

- (bool) containsValueForKey:(NSString *)key;
- (id) initForReadingWithData:(NSData *)d;

- (bool) decodeBoolForKey:(NSString *)key;
- (const uint8_t *) decodeBytesForKey:(NSString *)key returnedLength:(size_t *)len;
- (double) decodeDoubleForKey:(NSString *)key;
- (float) decodeFloatForKey:(NSString *)key;
- (int) decodeIntForKey:(NSString *)key;
- (int32_t) decodeInt32ForKey:(NSString *)key;
- (int64_t) decodeInt64ForKey:(NSString *)key;
- (id) decodeObjectForKey:(NSString *)key;
- (NSPoint) decodePointForKey:(NSString *)key;
- (NSRect) decodeRectForKey:(NSString *)key;
- (NSSize) decodeSizeForKey:(NSString *)key;
- (void) finishDecoding;

+ (NSString *) classNameForClass:(Class)cls;
+ (void) setClassName:(NSString *)name forClass:(Class)cls;
- (NSString *) classNameForClass:(Class)cls;
- (void) setClassName:(NSString *)name forClass:(Class)cls;

- (id<NSKeyedUnarchiverDelegate>) delegate;
- (void)setDelegate:(id<NSKeyedUnarchiverDelegate>)delegate;

@end

/*
   vim:syntax=objc:
 */
