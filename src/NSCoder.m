/*
   NSCoder.m

   Copyright (C) 2005 Gold Project
   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Ovidiu Predescu <ovidiu@bx.logicnet.ro>

   This file is part of the System framework (from libFoundation).

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

#import <Foundation/NSCoder.h>
#import <Foundation/Memory.h>
#import <Foundation/NSPropertyListSerialization.h>
#import <Foundation/NSString.h>
#import "internal.h"
#include <stdlib.h>

@implementation NSCoder

- (void)encodeArrayOfObjCType:(const char*)types
	count:(unsigned int)count
	at:(const void*)array
{
    unsigned int i, offset, item_size = objc_sizeof_type(types);
	SEL encodeSelector = @selector(encodeValueOfObjCType:at:);
    IMP imp = [self methodForSelector:encodeSelector];

    for(i = offset = 0; i < count; i++, offset += item_size)
	{
		(*imp)(self, encodeSelector, types, (char*)array + offset);
	}
}

- (void)encodeBycopyObject:(id)anObject
{
    [self encodeObject:anObject];
}

- (void)encodeByrefObject:(id)anObject
{
    [self encodeObject:anObject];
}

- (void)encodeConditionalObject:(id)anObject
{
    [self encodeObject:anObject];
}

- (void) encodeDataObject:(NSData *)data
{
	[self subclassResponsibility:_cmd];
}

- (void)encodeObject:(id)anObject
{
	[self encodeValueOfObjCType:@encode(id) at:&anObject];
}

- (void)encodeRootObject:(id)rootObject
{
    [self encodeObject:rootObject];
}

- (void) encodeBytes:(const void *)bytes length:(size_t)len
{
	[self encodeValueOfObjCType:@encode(size_t) at:&len];
	[self encodeArrayOfObjCType:@encode(const uint8_t *) count:len at:bytes];
}

- (void)encodeValueOfObjCType:(const char*)type
	at:(const void*)address
{
    [self subclassResponsibility:_cmd];
}

- (void)encodeValuesOfObjCTypes:(const char*)types, ...
{
    va_list ap;
    IMP imp = [self methodForSelector:@selector(encodeValueOfObjCType:at:)];

    va_start(ap, types);
    for(; types && *types; types = objc_skip_typespec(types))
	{
		(*imp)(self, @selector(encodeValueOfObjCType:at:),
				types, va_arg(ap, void*));
	}
    va_end(ap);
}

- (void)encodePoint:(NSPoint)point
{
    [self encodeValueOfObjCType:@encode(NSPoint) at:&point];
}

- (void) encodePropertyList:(id)plist
{
	NSData *serializedPlist = [NSPropertyListSerialization dataWithPropertyList:plist format:NSPropertyListBinaryFormat options:0 error:NULL];

	if (serializedPlist != nil)
	{
		[self encodeObject:serializedPlist];
	}

}

- (void)encodeSize:(NSSize)size
{
    [self encodeValueOfObjCType:@encode(NSSize) at:&size];
}

- (void)encodeRect:(NSRect)rect
{
    [self encodeValueOfObjCType:@encode(NSRect) at:&rect];
}

- (void)decodeArrayOfObjCType:(const char*)types
	count:(unsigned)count
	at:(void*)address
{
	unsigned i, offset;
	NSIndex item_size = objc_sizeof_type(types);
	IMP imp = [self methodForSelector:@selector(decodeValueOfObjCType:at:)];

	for(i = offset = 0; i < count; i++, offset += item_size)
	{
		(*imp)(self, @selector(decodeValueOfObjCType:at:),
				types, (char*)address + offset);
	}
}

- (void *) decodeBytesWithReturnedLength:(size_t *)length
{
	char *bytes;
	[self decodeValueOfObjCType:@encode(size_t) at:length];
	bytes = malloc(*length);
	[self decodeArrayOfObjCType:@encode(char) count:*length at:bytes];
	return bytes;
}

- (NSData *) decodeDataObject
{
	return [self subclassResponsibility:_cmd];
}

- (id)decodeObject
{
	id obj;
	[self decodeValueOfObjCType:@encode(id) at:&obj];
    return obj;
}

- (id) decodePropertyList
{
	NSData *d;

	d = [self decodeObject];

	if (d != nil)
	{
		return [NSPropertyListSerialization propertyListWithData:d options:0
														format:NULL error:NULL];
	}

	return nil;
}

- (void)decodeValueOfObjCType:(const char*)type
	at:(void*)address
{
    [self subclassResponsibility:_cmd];
}

- (void)decodeValuesOfObjCTypes:(const char*)types, ...
{
    va_list ap;
    IMP imp = [self methodForSelector:@selector(decodeValueOfObjCType:at:)];

    va_start(ap, types);
    for(;types && *types; types = objc_skip_typespec(types))
	{
		(*imp)(self, @selector(decodeValueOfObjCType:at:),
				types, va_arg(ap, void*));
	}
    va_end(ap);
}

- (NSPoint)decodePoint
{
    NSPoint point;

    [self decodeValueOfObjCType:@encode(NSPoint) at:&point];
    return point;
}

- (NSSize)decodeSize
{
    NSSize size;

    [self decodeValueOfObjCType:@encode(NSSize) at:&size];
    return size;
}

- (NSRect)decodeRect
{
    NSRect rect;

    [self decodeValueOfObjCType:@encode(NSRect) at:&rect];
    return rect;
}

- (NSZone*)objectZone
{
    return NSDefaultAllocZone();
}

- (void)setObjectZone:(NSZone*)zone
{
}

- (unsigned int)systemVersion
{
    [self notImplemented:_cmd];
    return 0;
}

- (unsigned int)versionForClassName:(NSString*)className
{
    [self subclassResponsibility:_cmd];
    return 0;
}

// Keyed coding
- (bool) allowsKeyedCoding
{
	return false;
}

- (bool) containsValueForKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
	return false;
}

- (void) encodeBool:(bool)boolv forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (void) encodeBytes:(const uint8_t *)bytes length:(size_t)len forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (void) encodeConditionalObject:(id)object forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (void) encodeDouble:(double)doublev forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (void) encodeFloat:(float)floatv forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (void) encodeInt:(int)intv forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (void) encodeInteger:(NSInteger)intv forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (void) encodeInt32:(int32_t)int32v forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (void) encodeInt64:(int64_t)int64v forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (void) encodeObject:(id)object forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (void) encodePoint:(NSPoint)pointv forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (void) encodeRect:(NSRect)rectv forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (void) encodeSize:(NSSize)sizev forKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
}

- (bool) decodeBoolForKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
	return false;
}

- (const uint8_t *) decodeBytesForKey:(NSString *)key returningLength:(size_t *)length
{
	[self subclassResponsibility:_cmd];
	return NULL;
}

- (double) decodeDoubleForKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
	return 0.0;
}

- (float) decodeFloatForKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
	return 0.0;
}

- (int) decodeIntForKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (NSInteger) decodeIntegerForKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (int32_t) decodeInt32ForKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (int64_t) decodeInt64ForKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (id) decodeObjectForKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (NSPoint) decodePointForKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
	return NSZeroPoint;
}

- (NSRect) decodeRectForKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
	return NSZeroRect;
}

- (NSSize) decodeSizeForKey:(NSString *)key
{
	[self subclassResponsibility:_cmd];
	return NSZeroSize;
}

@end /* NSCoder */
