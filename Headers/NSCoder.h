/*
 * Copyright (c) 2004,2005	Justin Hibbits
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
#import <Foundation/NSGeometry.h>

/*!
  \class NSCoder
  \brief NSObject encoder/decoder.
 */
@interface NSCoder	: NSObject

// Encoding data
/*!
 \brief Encodes an array of Objective-C types.
 \param types Types to encode.
 \param count NSNumber of objects to encode.
 \param array Starting address of the types.
 */
-(void)encodeArrayOfObjCType:(const char *)types count:(unsigned int)count
	at:(const void *)array;

/*!
 \brief Encodes an object such that it gets copied on decode instead of proxied.
 \param anObject NSObject to copy/encode.
 Overridden by subclasses to encode the supplied object so that a
 copy is created rather than the object being proxied.  NSCoder's
 implementation just calls encodeObject:.
 */
-(void)encodeBycopyObject:(id)anObject;

- (void) encodeByrefObject:(id)object;
- (void) encodeDataObject:(NSData *)object;
- (void) encodeBytes:(const void *)bytes length:(size_t)length;

/*!
 \brief Encodes an object only if it is an intrinsic member of a larger data structure.
 \param anObject NSObject to encode.
 Overridden by subclasses to conditionally encode the object.
 NSCoder's implementation just calls encodeObject:.
 */
-(void)encodeConditionalObject:(id)anObject;

/*!
 \brief Encodes an Objective-C object.
 \param anObject NSObject to encode.
 */
-(void)encodeObject:(id)anObject;

/*!
 \brief Encodes the supplied point.
 \param point NSPoint to encode.
 */
-(void)encodePoint:(NSPoint)point;

- (void) encodePropertyList:(id)plist;

/*!
 \brief Encode the supplied rectangle structure.
 \param rect Rectangle to encode.
 */
-(void)encodeRect:(NSRect)rect;

/*!
 \brief Overridden by subclasses to start encoding an interconnected group of Objective-C objects, starting with rootObject.
 \param rootObject Starting object for encoding.
 \details NSCoder's implementation just invokes encodeObject:.
 */
-(void)encodeRootObject:(id)rootObject;

/*!
 \brief Encodes the supplied size structure.
 \param size NSSize structure to encode.
 */
-(void)encodeSize:(NSSize)size;

/*!
 \brief Encodes data of the specified Objective-C type.
 \param type Type of object to encode.
 \param address Address of object to encode.
 */
-(void)encodeValueOfObjCType:(const char *)type at:(const void *)address;

/*!
 \brief Encodes values corresponding to the Objective-C types listed in the argument list.
 \param types Type argument list to encode.
 */
-(void)encodeValuesOfObjCTypes:(const char *)types,...;

// Decoding data

/*!
 \brief Decodes data of Objective-C types.
 \param types Types to decode.
 \param count NSNumber of types to decode.
 \param address Starting address of types.
 */
-(void)decodeArrayOfObjCType:(const char *)types count:(unsigned int)count
	at:(void *)address;

- (void *) decodeBytesWithReturnedLength:(size_t *)len;
- (NSData *) decodeDataObject;

/*!
 \brief Decodes an Objective-C object.
 \return Returns the decoded object.
 */
-(id)decodeObject;

/*!
 \brief Decodes a point structure.
 \return Returns the decoded point structure.
 */
-(NSPoint)decodePoint;

- (id) decodePropertyList;

/*!
 \brief Decodes a rectangle structure.
 \return Returns the decoded rectangle structure.
 */
-(NSRect)decodeRect;

/*!
 \brief Decodes a size structure.
 \return Returns the decoded size structure.
 */
-(NSSize)decodeSize;

/*!
 \brief Decodes data of the specified type into the given address.
 \param type Type of object to decode.
 \param address Address to decode into.
 You are responsible for releasing the resulting object.
 */
-(void)decodeValueOfObjCType:(const char *)type at:(void *)address;

/*!
 \brief Decodes values corresponding to the Objective-C types listed in the given argument list.
 \param types Types of the values to decode.
 You are responsible for releasing the resulting objects.
 */
-(void)decodeValuesOfObjCTypes:(const char *)types,...;

// Managing zones

/*!
 \brief Returns the memory used by decoded objects.
 For instances of NSCoder, this is the default zone, returned by
 DefaultMallocZone().
 */
-(NSZone *)objectZone;

/*!
 \brief Sets the memory zone used by decoded objects.
 */
-(void)setObjectZone:(NSZone *)zone;

/*!
 \brief Returns the system version number as of the time the archive was created.
 */
-(unsigned int)systemVersion;

/*!
 \brief Returns the version number of the given class name as of the time it was archived.
 \param className Name of the class to get the version of.
 \return Returns the version of the class at time of archive.
 */
-(unsigned int)versionForClassName:(NSString *)className;

// Keyed coding

- (bool) allowsKeyedCoding;
- (bool) containsValueForKey:(NSString *)key;

- (void) encodeBool:(bool)boolv forKey:(NSString *)key;
- (void) encodeBytes:(const uint8_t *)bytes length:(size_t)len forKey:(NSString *)key;
- (void) encodeConditionalObject:(id)object forKey:(NSString *)key;
- (void) encodeDouble:(double)doublev forKey:(NSString *)key;
- (void) encodeFloat:(float)floatv forKey:(NSString *)key;
- (void) encodeInt:(int)intv forKey:(NSString *)key;
- (void) encodeInteger:(NSInteger)intv forKey:(NSString *)key;
- (void) encodeInt32:(int32_t)int32v forKey:(NSString *)key;
- (void) encodeInt64:(int64_t)int64v forKey:(NSString *)key;
- (void) encodeObject:(id)object forKey:(NSString *)key;
- (void) encodePoint:(NSPoint)pointv forKey:(NSString *)key;
- (void) encodeRect:(NSRect)rectv forKey:(NSString *)key;
- (void) encodeSize:(NSSize)sizev forKey:(NSString *)key;

- (bool) decodeBoolForKey:(NSString *)key;
- (const uint8_t *) decodeBytesForKey:(NSString *)key returningLength:(size_t *)lengthp;
- (double) decodeDoubleForKey:(NSString *)key;
- (float) decodeFloatForKey:(NSString *)key;
- (int) decodeIntForKey:(NSString *)key;
- (NSInteger) decodeIntegerForKey:(NSString *)key;
- (int32_t) decodeInt32ForKey:(NSString *)key;
- (int64_t) decodeInt64ForKey:(NSString *)key;
- (id) decodeObjectForKey:(NSString *)key;
- (NSPoint) decodePointForKey:(NSString *)key;
- (NSRect) decodeRectForKey:(NSString *)key;
- (NSSize) decodeSizeForKey:(NSString *)key;
@end

@interface NSObject(coding)
- (id) replacementObjectForCoder:(NSCoder *)coder;
@end
