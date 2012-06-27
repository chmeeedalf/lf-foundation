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

#import <Foundation/NSData.h>
#import <Foundation/NSDelegate.h>
#import <Foundation/NSMapTable.h>
#import <Foundation/NSValue.h>
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
	NSDelegate *delegate;
	NSMapTable			*classNameMap;
	NSMutableData			*_outData;
}

static NSMapTable *keyedArchiverClassMap;

+ (void) initialize
{
	keyedArchiverClassMap = [NSMapTable mapTableWithStrongToStrongObjects];
}

+ (NSData *)archivedDataWithRootObject:(id)rootObject
{
	NSMutableData *d = [NSMutableData new];
	NSKeyedArchiver *archiver = [[self alloc] initForWritingWithMutableData:d];

	[archiver encodeRootObject:rootObject];
	return [d copy];
}

+ (bool)archiveRootObject:(id)rootObject toURL:(NSURL *)path
{
	return [[self archivedDataWithRootObject:rootObject] writeToURL:path options:0 error:NULL];
}


- (id) initForWritingWithMutableData:(NSMutableData *)d
{
	TODO;	// -[NSKeyedArchiver initForWritingWithMutableData:]
	delegate = [[NSDelegate alloc] initWithProtocol:@protocol(NSKeyedArchiverDelegate)];
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
	[self encodeObject:@(boolv) forKey:key];
}

- (void) encodeBytes:(const uint8_t *)bytes length:(size_t)len forKey:(NSString *)key
{
	[self encodeObject:[NSData dataWithBytes:bytes length:len] forKey:key];
}

- (void) encodeConditionalObject:(id)object forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodeConditionalObject:forKey:]
}

- (void) encodeDouble:(double)doublev forKey:(NSString *)key
{
	[self encodeObject:@(doublev) forKey:key];
}

- (void) encodeFloat:(float)floatv forKey:(NSString *)key
{
	[self encodeObject:@(floatv) forKey:key];
}

- (void) encodeInt:(int)intv forKey:(NSString *)key
{
	[self encodeObject:@(intv) forKey:key];
}

- (void) encodeInt32:(int32_t)int32v forKey:(NSString *)key
{
	[self encodeObject:@(int32v) forKey:key];
}

- (void) encodeInt64:(int64_t)int64v forKey:(NSString *)key
{
	[self encodeObject:@(int64v) forKey:key];
}

- (void) encodeObject:(id)object forKey:(NSString *)key
{
	TODO;	// -[NSKeyedArchiver encodeObject:forKey:]
}

- (void) encodePoint:(NSPoint)pointv forKey:(NSString *)key
{
	[self encodeObject:[NSValue valueWithPoint:pointv] forKey:key];
}

- (void) encodeRect:(NSRect)rectv forKey:(NSString *)key
{
	[self encodeObject:[NSValue valueWithRect:rectv] forKey:key];
}

- (void) encodeSize:(NSSize)sizev forKey:(NSString *)key
{
	[self encodeObject:[NSValue valueWithSize:sizev] forKey:key];
}

- (void) finishEncoding
{
	TODO;	// -[NSKeyedArchiver finishEncoding]
}


+ (NSString *) classNameForClass:(Class)cls
{
	@synchronized(self)
	{
		return [keyedArchiverClassMap objectForKey:cls];
	}
}

+ (void) setClassName:(NSString *)name forClass:(Class)cls
{
	@synchronized(self)
	{
		[keyedArchiverClassMap setObject:name forKey:cls];
	}
}

- (NSString *) classNameForClass:(Class)cls
{
	return [classNameMap objectForKey:cls];
}

- (void) setClassName:(NSString *)name forClass:(Class)cls
{
	[classNameMap setObject:name forKey:cls];
}


- (id<NSKeyedArchiverDelegate>) delegate
{
	return [delegate delegate];
}

- (void)setDelegate:(id<NSKeyedArchiverDelegate>)newDel
{
	[delegate setDelegate:newDel];
}


@end

@implementation NSKeyedUnarchiver
{
	unsigned long		_keyIndex;
	NSDelegate *delegate;
	NSMapTable			*classNameMap;
}

static NSMapTable *keyedUnarchiverClassMap;

+ (void) initialize
{
	keyedUnarchiverClassMap = [NSMapTable mapTableWithStrongToStrongObjects];
}

+ (id)unarchiveObjectWithData:(NSData *)rootObject
{
	NSKeyedUnarchiver *unarchiver = [[self alloc] initForReadingWithData:rootObject];
	id root = [unarchiver decodeObjectForKey:@"root"];
	[unarchiver finishDecoding];
	return root;
}

+ (id)unarchiveRootObjectWithURL:(NSURL *)path
{
	return [self unarchiveObjectWithData:[NSData dataWithContentsOfURL:path]];
}


- (id) initForReadingWithData:(NSData *)d
{
	TODO;	// -[NSKeyedUnarchiver initForReadingWithData:]
	delegate = [[NSDelegate alloc] initWithProtocol:@protocol(NSKeyedUnarchiverDelegate)];
	return self;
}


- (bool) decodeBoolForKey:(NSString *)key
{
	id boolv = [self decodeObjectForKey:key];

	if (![boolv isKindOfClass:[NSNumber class]])
		return false;
	return [boolv boolValue];
}

- (const uint8_t *) decodeBytesForKey:(NSString *)key returnedLength:(size_t *)len
{
	NSData *d = [self decodeObjectForKey:key];
	if (![d isKindOfClass:[NSData class]])
		return NULL;

	if (len != NULL)
		*len = [d length];
	return [d bytes];
}

- (double) decodeDoubleForKey:(NSString *)key
{
	id doublev = [self decodeObjectForKey:key];

	if (![doublev isKindOfClass:[NSNumber class]])
		return 0.0;
	return [doublev doubleValue];
}

- (float) decodeFloatForKey:(NSString *)key
{
	id floatv = [self decodeObjectForKey:key];

	if (![floatv isKindOfClass:[NSNumber class]])
		return 0.0f;
	return [floatv floatValue];
}

- (int) decodeIntForKey:(NSString *)key
{
	id intv = [self decodeObjectForKey:key];

	if (![intv isKindOfClass:[NSNumber class]])
		return 0;
	return [intv intValue];
}

- (int32_t) decodeInt32ForKey:(NSString *)key
{
	id integerv = [self decodeObjectForKey:key];

	if (![integerv isKindOfClass:[NSNumber class]])
		return 0;
	return [integerv integerValue];
}

- (int64_t) decodeInt64ForKey:(NSString *)key
{
	id longLongv = [self decodeObjectForKey:key];

	if (![longLongv isKindOfClass:[NSNumber class]])
		return 0;
	return [longLongv longLongValue];
}

- (id) decodeObjectForKey:(NSString *)key
{
	TODO;	// -[NSKeyedUnarchiver decodeObjectForKey:]
	return nil;
}

- (NSPoint) decodePointForKey:(NSString *)key
{
	id pointv = [self decodeObjectForKey:key];

	if (![pointv isKindOfClass:[NSValue class]])
		return NSZeroPoint;
	return [pointv pointValue];
}

- (NSRect) decodeRectForKey:(NSString *)key
{
	id rectv = [self decodeObjectForKey:key];

	if (![rectv isKindOfClass:[NSValue class]])
		return NSZeroRect;
	return [rectv rectValue];
}

- (NSSize) decodeSizeForKey:(NSString *)key
{
	id sizev = [self decodeObjectForKey:key];

	if (![sizev isKindOfClass:[NSValue class]])
		return NSZeroSize;
	return [sizev sizeValue];
}

- (void) finishDecoding
{
	TODO;	// -[NSKeyedUnarchiver finishDecoding]
}


+ (NSString *) classNameForClass:(Class)cls
{
	@synchronized(self)
	{
		return [keyedUnarchiverClassMap objectForKey:cls];
	}
}

+ (void) setClassName:(NSString *)name forClass:(Class)cls
{
	@synchronized(self)
	{
		[keyedUnarchiverClassMap setObject:name forKey:cls];
	}
}

- (NSString *) classNameForClass:(Class)cls
{
	return [classNameMap objectForKey:cls];
}

- (void) setClassName:(NSString *)name forClass:(Class)cls
{
	[classNameMap setObject:name forKey:cls];
}


- (id<NSKeyedUnarchiverDelegate>) delegate
{
	return [delegate delegate];
}

- (void)setDelegate:(id<NSKeyedUnarchiverDelegate>)newDel
{
	[delegate setDelegate:newDel];
}


@end

/*
   vim:syntax=objc:
 */
