/*
 * Copyright (c) 2004-2012	Gold Project
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
 * THIS SOFTWARE IS PROVIDED BY THE PROJECT ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
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
#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>

@class NSString, NSLocale;

/*!
 * \class NSValue
 * \brief Generic type container.
 *
 * \details The NSValue class can be used for inserting non-objects into container
 * classes such as Dictionaries and Arrays.
 */
@interface NSValue	: NSObject <NSCopying, NSCoding>

// Allocating and initalizing value objects
/*!
 * \brief Creates and returns a value object containing the given value of the given Objective-C type.
 * \param value NSValue of the object.
 * \param type Objective-C type of the object.
 */
+(NSValue *)valueWithBytes:(const void *)value objCType:(const char *)type;

/*!
 * \brief Creates and returns a value object containing the given object, without retaining it.
 * \param anObject NSObject to create the value object with, not retained.
 *  This is provided as a convenience method: the statement [NSValue
 * valueWithNonretainedObject:anObject] is equivalent to the statement [NSValue
 * value:&anObject withObjCType:\@encode(void *)].
 */
+(NSValue *)valueWithNonretainedObject:(id)anObject;

/*!
 * \brief Creates and returns a value object that contains the specified pointer.
 * \param pointer Pointer to initialize the value object with.
 */
+(NSValue *)valueWithPointer:(const void *)pointer;

// Allocating and initializing geometry value objects
/*!
 * \brief Creates and returns a value object that contains the specified NSPoint structure.
 * \param point NSPoint to initialize the value object with.
 */
+(NSValue *)valueWithPoint:(NSPoint)point;

/*!
 * \brief Creates and returns a value object that contains the specified NSRange.
 */
+(NSValue *)valueWithRange:(NSRange)range;

/*!
 * \brief Creates and returns a value object that contains the specified NSRect structure, representing a rectangle.
 * \param rect Rectangle to initialize the value object with.
 */
+(NSValue *)valueWithRect:(NSRect)rect;

/*!
 * \brief Creates and returns a value object that contains the specified NSSize structure (which stores a width and height).
 * \param size NSSize structure to initialize the value object with.
 */
+(NSValue *)valueWithSize:(NSSize)size;

- (id) initWithBytes:(const void *)value objCType:(const char *)type;

// Accessing data in value objects
/*!
 * \brief Copies the receiver's data into the location pointed to by the argument.
 * \param value Pointer to place the receiver's data.
 */
-(void)getValue:(void *)value;

/*!
 * \brief Returns the non-retained object that's contained in the receiver.
 *  It is an error to send this message to an NSValue that doesn't
 * store a nonretained object.
 */
-(id)nonretainedObjectValue;

/*!
 * \brief Returns the Objective-C type of the data contained in the receiver.
 */
-(const char *)objCType;

/*!
 * \brief Returns the value pointed to by a pointer contained in a value object.
 *  It is an error to send this message to an NSValue that doesn't
 * store a pointer.
 */
-(void *)pointerValue;

// Accessing data in value geometry objects
/*!
 * \brief Returns the point structure that's contained in the receiver.
 */
-(NSPoint)pointValue;

/*!
 * \brief Returns the range structure that's contained in the receiver.
 */
-(NSRange)rangeValue;

/*!
 * \brief Returns the rectangle structure that's contained in the receiver.
 */
-(NSRect)rectValue;

/*!
 * \brief Returns the size structure that's contained in the receiver.
 */
-(NSSize)sizeValue;

/*!
 * \brief Returns true if the receiver and specified value are equal.
 */
-(bool)isEqualToValue:(NSValue *)aValue;

/*!
 * \brief Returns the raw bytes used in the receiver.
 */
-(void *)valueBytes;

@end

/*!
 * \class NSNumber
 * \brief An immutable number container.
 *
 * \details NSNumber is a special subclass of NSValue specifically handling numeric
 * types.  Subclasses of NSNumber could exist to provide features such as
 * arbitrary precision values.
 */
@interface NSNumber	: NSValue

// Allocating and initializing
/*!
 * \brief Creates and returns a number object representing a value of the type <b>bool</b>.
 */
+(NSNumber *)numberWithBool:(bool)value;

/*!
 * \brief Creates and returns a number object representing a value of the type <b>char</b>.
 */
+(NSNumber *)numberWithChar:(char)value;

/*!
 * \brief Creates and returns a number object representing a value of the type <b>double</b>.
 */
+(NSNumber *)numberWithDouble:(double)value;

/*!
 * \brief Creates and returns a number object representing a value of the type <b>float</b>.
 */
+(NSNumber *)numberWithFloat:(float)value;

/*!
 * \brief Creates and returns a number object representing a value of the type <b>int</b>.
 */
+(NSNumber *)numberWithInt:(int)value;

/*!
 * \brief Creates and returns a number object representing a value of the type <b>NSInteger</b>.
 */
+(NSNumber *)numberWithInteger:(NSInteger)value;

/*!
 * \brief Creates and returns a number object representing a value of the type <b>long</b>.
 */
+(NSNumber *)numberWithLong:(long)value;

/*!
 * \brief Creates and returns a number object representing a value of the type <b>long long</b>.
 */
+(NSNumber *)numberWithLongLong:(long long)value;

/*!
 * \brief Creates and returns a number object representing a value of the type <b>short</b>.
 */
+(NSNumber *)numberWithShort:(short)value;

/*!
 * \brief Creates and returns a number object representing a value of the
 * type <b>unsigned char</b>.
 */
+(NSNumber *)numberWithUnsignedChar:(unsigned char)value;

/*!
 * \brief Creates and returns a number object representing a value of the
 * type <b>unsigned int</b>.
 */
+(NSNumber *)numberWithUnsignedInt:(unsigned int)value;
+(NSNumber *)numberWithUnsignedInteger:(NSUInteger)value;

/*!
 * \brief Creates and returns a number object representing a value of the
 * type <b>unsigned long</b>.
 */
+(NSNumber *)numberWithUnsignedLong:(unsigned long)value;

/*!
 * \brief Creates and returns a number object representing a value of the
 * type <b>unsigned long long</b>.
 */
+(NSNumber *)numberWithUnsignedLongLong:(unsigned long long)value;

/*!
 * \brief Creates and returns a number object representing a value of the
 * type <b>unsigned short</b>.
 */
+(NSNumber *)numberWithUnsignedShort:(unsigned short)value;

/*!
 * \brief initializes a number object representing a value of the type <b>bool</b>.
 */
- (id)initWithBool:(bool)value;

/*!
 * \brief initializes a number object representing a value of the type <b>char</b>.
 */
- (id)initWithChar:(char)value;

/*!
 * \brief initializes a number object representing a value of the type <b>double</b>.
 */
- (id)initWithDouble:(double)value;

/*!
 * \brief initializes a number object representing a value of the type <b>float</b>.
 */
- (id)initWithFloat:(float)value;

/*!
 * \brief initializes a number object representing a value of the type <b>int</b>.
 */
- (id)initWithInt:(int)value;

/*!
 * \brief initializes a number object representing a value of the type <b>NSInteger</b>.
 */
- (id)initWithInteger:(NSInteger)value;

/*!
 * \brief initializes a number object representing a value of the type <b>long</b>.
 */
- (id)initWithLong:(long)value;

/*!
 * \brief initializes a number object representing a value of the type <b>long long</b>.
 */
- (id)initWithLongLong:(long long)value;

/*!
 * \brief initializes a number object representing a value of the type <b>short</b>.
 */
- (id)initWithShort:(short)value;

/*!
 * \brief initializes a number object representing a value of the
 * type <b>unsigned char</b>.
 */
- (id)initWithUnsignedChar:(unsigned char)value;

/*!
 * \brief initializes a number object representing a value of the
 * type <b>unsigned int</b>.
 */
- (id)initWithUnsignedInt:(unsigned int)value;
- (id)initWithUnsignedInteger:(NSUInteger)value;

/*!
 * \brief initializes a number object representing a value of the
 * type <b>unsigned long</b>.
 */
- (id)initWithUnsignedLong:(unsigned long)value;

/*!
 * \brief initializes a number object representing a value of the
 * type <b>unsigned long long</b>.
 */
- (id)initWithUnsignedLongLong:(unsigned long long)value;

/*!
 * \brief initializes a number object representing a value of the
 * type <b>unsigned short</b>.
 */
- (id)initWithUnsignedShort:(unsigned short)value;

// Accessing data
/*!
 * \brief Returns the receiver's value as a boolean value.
 */
-(bool)boolValue;

/*!
 * \brief Returns the receiver's value as a character value.
 */
-(char)charValue;

/*!
 * \brief Returns the receiver's value as a double precision floating-point value.
 */
-(double)doubleValue;

/*!
 * \brief Returns the receiver's value as a single precision floating-point value.
 */
-(float)floatValue;

/*!
 * \brief Returns the receiver's value as an integer value.
 */
-(int)intValue;
-(NSInteger)integerValue;

/*!
 * \brief Returns the receiver's value as a long long integer value.
 */
-(long long)longLongValue;

/*!
 * \brief Returns the receiver's value as a long integer value.
 */
-(long)longValue;

/*!
 * \brief Returns the receiver's value as a short integer value.
 */
-(short)shortValue;

/*!
 * \brief Returns the receiver's value as a string contained in an NSString object.
 */
-(NSString *)stringValue;

/*!
 * \brief Returns the receiver's value as a unsigned character value.
 */
-(unsigned char)unsignedCharValue;

/*!
 * \brief Returns the receiver's value as an unsigned integer value.
 */
-(unsigned int)unsignedIntValue;
-(NSUInteger)unsignedIntegerValue;

/*!
 * \brief Returns the receiver's value as an unsigned long long integer value.
 */
-(unsigned long long)unsignedLongLongValue;

/*!
 * \brief Returns the receiver's value as an unsigned long integer value.
 */
-(unsigned long)unsignedLongValue;

/*!
 * \brief Returns the receiver's value as an unsigned short integer value.
 */
-(unsigned short)unsignedShortValue;

// Comparing data
/*!
 * \brief Compares the receiver to the specified other number object, using AI C rules for type conversion, and returns an ComparisonResult.
 */
-(NSComparisonResult)compare:(NSNumber *)otherNumber;
-(bool) isEqualToNumber:(NSNumber *)other;

// Description....
/*!
 * \brief Returns a string description of the receiver using the specified locale dictionary.
 */
-(NSString *)descriptionWithLocale:(NSLocale *)localeDictionary;
@end

/*
   vim:syntax=objc:
 */
