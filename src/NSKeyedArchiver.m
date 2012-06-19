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

#import <Foundation/NSKeyedArchiver.h>
#import "internal.h"

/*!
  \class NSKeyedArchiver
 */
@implementation NSKeyedArchiver
{
	NSMutableDictionary	*_enc;
	NSMutableDictionary	*_cmap;
	NSMutableDictionary	*_umap;
	NSMutableArray		*_encStack;
	unsigned long		 _keyIndex;
	id delegate;
	NSMapTable			*classNameMap;
	NSMutableData			*_outData;
}

+ (NSData *)archivedDataWithRootObject:(id)rootObject
{
	TODO;	// -[NSKeyedArchiver archivedDataWithRootObject:]
	return nil;
}

+ (bool)archiveRootObject:(id)rootObject toURL:(NSURL *)path
{
	TODO;	// -[NSKeyedArchiver archiveRootObject:toURL:]
	return false;
}


- (id) initForWritingWithMutableData:(NSMutableData *)d
{
	TODO;	// -[NSKeyedArchiver initForWritingWithMutableData:]
	return self;
}


// Keyed coding

- (bool) allowsKeyedCoding
{
	return true;
}

- (bool) containsValueForKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver containsValueForKey:]
	return false;
}


- (void) encodeBool:(bool)boolv forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodeBool:forKey:]
}

- (void) encodeBytes:(const uint8_t *)bytes length:(size_t)len forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodeBytes:length:forKey:]
}

- (void) encodeConditionalObject:(id)object forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodeConditionalObject:forKey:]
}

- (void) encodeDouble:(double)doublev forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodeDouble:forKey:]
}

- (void) encodeFloat:(float)floatv forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodeFloat:forKey:]
}

- (void) encodeInt:(int)intv forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodeInt:forKey:]
}

- (void) encodeInt32:(int32_t)int32v forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodeInt32:forKey:]
}

- (void) encodeInt64:(int64_t)int64v forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodeInt64:forKey:]
}

- (void) encodeObject:(id)object forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodeObject:forKey:]
}

- (void) encodePoint:(NSPoint)pointv forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodePoint:forKey:]
}

- (void) encodeRect:(NSRect)rectv forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodeRect:forKey:]
}

- (void) encodeSize:(NSSize)sizev forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodeSize:forKey:]
}

- (void) finishEncoding
{
	TODO;	// -[NSKeyedArchiver finishEncoding]
}


+ (NSString *) classNameForClass:(Class)cls
{
	TODO;	// -[NSKeyedArchiver classNameForClass:]
	return nil;
}

+ (void) setClassName:(NSString *)name forClass:(Class)cls
{
	TODO;	// -[NSKeyedArchiver setClassName:forClass:]
}

- (NSString *) classNameForClass:(Class)cls
{
	TODO;	// -[NSKeyedArchiver classNameForClass:]
	return nil;
}

- (void) setClassName:(NSString *)name forClass:(Class)cls
{
	TODO;	// -[NSKeyedArchiver setClassName:forClass:]
}


- (id<NSKeyedArchiverDelegate>) delegate
{
	TODO;	// -[NSKeyedArchiver delegate]
	return nil;
}

- (void)setDelegate:(id<NSKeyedArchiverDelegate>)delegate
{
	TODO;	// -[NSKeyedArchiver setDelegate:]
}


@end

@implementation NSKeyedUnarchiver
{
	unsigned long		_keyIndex;
	id delegate;
	NSMapTable			*classNameMap;
}

+ (id)unarchivedObjectWithData:(NSData *)rootObject
{
	TODO;	// -[NSKeyedUnarchiver unarchivedObjectWithData:]
	return nil;
}

+ (id)unarchivedRootObjectWithURL:(NSURL *)path
{
	TODO;	// -[NSKeyedUnarchiver unarchivedRootObjectWithURL:]
	return nil;
}


- (id) initForReadingWithData:(NSData *)d
{
	TODO;	// -[NSKeyedUnarchiver initForReadingWithData:]
	return self;
}


- (bool) decodeBoolForKey:(NSString *)key
{
	TODO;	// -[NSKeyedUnarchiver decodeBoolForKey:]
	return false;
}

- (const uint8_t *) decodeBytesForKey:(NSString *)key returnedLength:(size_t *)len
{
	TODO;	// -[NSKeyedUnarchiver decodeBytesForKey:returnedLength:]
	return NULL;
}

- (double) decodeDoubleForKey:(NSString *)key
{
	TODO;	// -[NSKeyedUnarchiver decodeDoubleForKey:]
	return 0.0;
}

- (float) decodeFloatForKey:(NSString *)key
{
	TODO;	// -[NSKeyedUnarchiver decodeFloatForKey:]
	return 0.0;
}

- (int) decodeIntForKey:(NSString *)key
{
	TODO;	// -[NSKeyedUnarchiver decodeIntForKey:]
	return 0;
}

- (int32_t) decodeInt32ForKey:(NSString *)key
{
	TODO;	// -[NSKeyedUnarchiver decodeInt32ForKey:]
	return 0;
}

- (int64_t) decodeInt64ForKey:(NSString *)key
{
	TODO;	// -[NSKeyedUnarchiver decodeInt64ForKey:]
	return 0;
}

- (id) decodeObjectForKey:(NSString *)key
{
	TODO;	// -[NSKeyedUnarchiver decodeObjectForKey:]
	return nil;
}

- (NSPoint) decodePointForKey:(NSString *)key
{
	TODO;	// -[NSKeyedUnarchiver decodePointForKey:]
	return NSZeroPoint;
}

- (NSRect) decodeRectForKey:(NSString *)key
{
	TODO;	// -[NSKeyedUnarchiver decodeRectForKey:]
	return NSZeroRect;
}

- (NSSize) decodeSizeForKey:(NSString *)key
{
	TODO;	// -[NSKeyedUnarchiver decodeSizeForKey:]
	return NSZeroSize;
}

- (void) finishDecoding
{
	TODO;	// -[NSKeyedUnarchiver finishDecoding]
}


+ (NSString *) classNameForClass:(Class)cls
{
	TODO;	// -[NSKeyedUnarchiver classNameForClass:]
	return nil;
}

+ (void) setClassName:(NSString *)name forClass:(Class)cls
{
	TODO;	// -[NSKeyedUnarchiver setClassName:forClass:]
}

- (NSString *) classNameForClass:(Class)cls
{
	TODO;	// -[NSKeyedUnarchiver classNameForClass:]
	return nil;
}

- (void) setClassName:(NSString *)name forClass:(Class)cls
{
	TODO;	// -[NSKeyedUnarchiver setClassName:forClass:]
}


- (id<NSKeyedUnarchiverDelegate>) delegate
{
	TODO;	// -[NSKeyedUnarchiver delegate]
	return nil;
}

- (void)setDelegate:(id<NSKeyedUnarchiverDelegate>)delegate
{
	TODO;	// -[NSKeyedUnarchiver setDelegate:]
}


@end

/*
   vim:syntax=objc:
 */
