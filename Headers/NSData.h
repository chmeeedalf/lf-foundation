/*
 * Copyright (c) 2004,2005	Gold Project
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
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR COEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>

enum
{
	NSDataReadingMapped = 1UL,
	NSDataReadingUncached = 1UL << 1
};
typedef NSUInteger NSDataReadingOptions;

enum
{
	NSDataSearchBackwards = 1UL,
	NSDataSearchAnchored = 1UL << 1,
};
typedef NSUInteger NSDataSearchOptions;

@class NSURI, NSError;
/*!
 @class NSData
 @brief The NSData class holds data of an arbitrary size and format.
 */
@interface NSData	: NSObject <NSCoding,NSCopying,NSMutableCopying>

/*!
 @brief Creates and returns an unitialized object from the given zone.
 */
+(id)allocWithZone:(NSZone *)zone;

/*!
 @brief Creates and returns an empty NSData object.
 */
+(id)data;

/*!
 @brief Creates and returns an object containing data bytes of a given length.
 @param bytes Bytes to put in the data object.
 @param length Length of the byte buffer.
 @result Returns an initialized (autoreleased) data object of given length.
 */
+(id)dataWithBytes:(const void *)bytes length:(unsigned int)length;

/*!
 @brief Creates and returns an object of given length of bytes without copying the data.
 @param bytes NSData buffer.
 @param length Length of the buffer.
 @result Returns an initialized data object of given length of bytes, not copying the bytes.
 */
+(id)dataWithBytesNoCopy:(void*)bytes length:(unsigned int)length;
+(id)dataWithBytesNoCopy:(void*)bytes length:(unsigned int)length freeWhenDone:(bool)free;

/*!
 * @brief Creates and returns a copy of the given argument.
 */
+(id)dataWithData:(NSData *)other;

+ (id) dataByDecodingBase64String:(NSString *)string;

+ (id) dataWithContentsOfURI:(NSURI *)uri;
+ (id) dataWithContentsOfURI:(NSURI *)uri options:(NSDataReadingOptions)options error:(NSError **)err;

/*!
 @brief Initializes a newly allocated data object with the given byte buffer.
 @param bytes Byte buffer to initialize the data object with.
 @param length Length of the data buffer.
 @result Returns the initialized data object.
 */
-(id)initWithBytes:(const void*)bytes length:(unsigned int)length;

/*!
 @brief Initializes an allocated data object with the given byte buffer, without copying.
 @param bytes Byte buffer with which to initialize the data object.
 @param length Length of the data buffer.
 @result Returns the initialized object.
 */
-(id)initWithBytesNoCopy:(void *)bytes length:(unsigned int)length;
-(id)initWithBytesNoCopy:(void *)bytes length:(unsigned int)length freeWhenDone:(bool)free;

/*!
 * \brief Initialize the receiver with the given data argument.
 */
-(id)initWithData:(NSData *)other;
-(id)initWithContentsOfURI:(NSURI *)uri;
-(id)initWithContentsOfURI:(NSURI *)uri options:(NSDataReadingOptions)options error:(NSError **)err;

// Accessing data
/*!
 @brief returns a pointer to the object's contents.
 */
-(const void *)bytes;

/*!
 @brief Returns an NSString object containing a hexidecimal representation of the receiver's contents.
 */
-(NSString *)description;

/*!
 @brief copies a length of the receiver's bytes into the buffer.
 @param[out] buffer Buffer into which to copy the bytes.
 @param length NSNumber of bytes to copy into the buffer.
 */
-(void)getBytes:(void *)buffer length:(unsigned int)length;

/*!
 @brief Copies into the given buffer a range of bytes specified by the given range argument.
 @param[out] buffer Buffer into which to copy the bytes.
 @param aRange NSRange of bytes to copy.

 @throws RangeException if the range is not within the range
 of the receiver's data.
 */
-(void)getBytes:(void *)buffer range:(NSRange)aRange;

/*!
 @brief Returns an object containing a copy of a portion of the receiver's bytes.
 @param aRange NSRange of bytes to return in the subdata object.
 @result Returns an NSData object containing a range of the receive's bytes.
 @throws RangeException if the given range is out of the
 range of the receiver's data.
 */
-(NSData *)subdataWithRange:(NSRange)aRange;

// Querying a data object
/*!
 @brief Compares the receiver object to another data object.
 @param other Other data object to compare with receiver.
 @result Returns true if they are equal, NO if not.
 */
-(bool)isEqualToData:(NSData *)other;

-(NSRange)rangeOfData:(NSData *)data options:(NSDataSearchOptions)options range:(NSRange)inRange;

/*!
 @brief Returns the number of bytes contained in the receiver.
 */
-(unsigned int)length;

- (NSString *)encodedBase64String;

@end

@interface NSMutableData	: NSData

/*!
 @brief Creates and returns a mutable data object with the given capacity.
 @param numBytes Maximum capacity of this data object.
 */
+(id)dataWithCapacity:(unsigned int)numBytes;

/*!
 @brief Creates and returns a mutable data object with the given capacity, filled with zeros.
 @param length Maximum capacity of the data object.
 */
+(id)dataWithLength:(unsigned int)length;

/*!
 @brief Initializes a newly allocated mutable data object with the given capacity.
 @param capacity Capacity of the data object.
 */
-(id)initWithCapacity:(unsigned int)capacity;

/*!
 @brief Initializes a newly allocated mutable data object with the given capacity, filling it with zeros.
 @param length Maximum capacity of the data object.
 */
-(id)initWithLength:(unsigned int)length;

/*!
 @brief Increases the length of a mutable data object by the given length
 zero-filled bytes.
 @param extraLength Length to add to the data.
 */
-(void)increaseLengthBy:(unsigned int)extraLength;

/*!
 @brief Sets the length of the data object's byte buffer to the given length.
 @param length Length to which to set the data object's buffer.
 */
-(void)setLength:(unsigned int)length;

// Appending data
/*!
 @brief Appends the given length of bytes to the data object's buffer.
 @param bytes Pointer to the bytes to append to the data object.
 @param length NSNumber of bytes to append.
 */
-(void)appendBytes:(const void *)bytes length:(unsigned int)length;

/*!
 @brief Appends the given data object to the receiver's byte buffer.
 @param other NSData object whose bytes to append to the receiver.
 */
-(void)appendData:(NSData *)other;

// Modifying data
/*!
 @brief Replaces the receiver's bytes located in the given range with the given bytes.
 @param aRange NSRange of bytes to replace.
 @param bytes Bytes replacing the receiver's bytes.
 @throws RangeException if out of range.
 */
-(void)replaceBytesInRange:(NSRange)aRange withBytes:(const void *)bytes;

/*!
 @brief Replaces the receiver's bytes located in the given range with the given bytes.
 @param aRange NSRange of bytes to replace.
 @param bytes Bytes replacing the receiver's bytes.
 @param len NSNumber of bytes to insert.
 @throws RangeException if out of range.
 */
-(void)replaceBytesInRange:(NSRange)aRange withBytes:(const void *)bytes length:(size_t)len;

/*!
 @brief Replaces the receiver's bytes in the given range with zeros.
 @param aRange NSRange of bytes to clear.
 @throws RangeException if out of range.
 */
-(void)resetBytesInRange:(NSRange)aRange;

/*!
 @brief Sets the receiver to the contents of the passed object.
 @param data NSData to set the contents of the receiver.
 */
-(void)setData:(NSData *)data;

/*!
 * \brief Returns a pointer to the mutable data bytes from this object.
 */
- (char *)mutableBytes;
@end

/*
   vim:syntax=objc:
 */
