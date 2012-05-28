/*
   NSData.m
 * All rights reserved.

   Copyright (C) 2005-2012 Justin Hibbits
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

#import <Foundation/NSData.h>
#import <Foundation/NSString.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSRange.h>
#include <netinet/in.h>
#include <string.h>
#include <stdlib.h>
#include <resolv.h>

#import "internal.h"
#import "NSCoreData.h"

@implementation NSData

/* Primitives */

- (const void*)bytes
{
    [self subclassResponsibility:_cmd];
    return NULL;
}

- (unsigned int)length
{
    [self subclassResponsibility:_cmd];
    return 0;
}

/* Class */

+ (id)allocWithZone:(NSZone*)zone
{
	return NSAllocateObject(((self == [NSData class]) ?
				[NSCoreData class] : (Class)self), 0, zone);
}

+ (id)data
{
	return [[self allocWithZone:NULL] initWithBytes:NULL length:0];
}

+ (id)dataWithBytes:(const void*)bytes
    length:(unsigned int)length
{
    return [[self allocWithZone:NULL] initWithBytes:bytes length:length];
}

+ (id)dataWithBytesNoCopy:(void*)bytes
    length:(unsigned int)length
{
	return [[self allocWithZone:NSDefaultAllocZone()]
			initWithBytesNoCopy:bytes
						 length:length];
}

+ (id)dataWithBytesNoCopy:(void*)bytes
    length:(unsigned int)length
	freeWhenDone:(bool)flag
{
	return [[self allocWithZone:NSDefaultAllocZone()]
			 initWithBytesNoCopy:bytes
						  length:length
					freeWhenDone:flag];
}

+ (id)dataWithData:(NSData *)source
{
	return [[self alloc] initWithData:source];
}

+ (id) dataWithContentsOfURL:(NSURL *)uri
{
	return [[NSFileManager defaultManager] contentsOfFileAtURL:uri shared:true error:NULL];
}

+ (id) dataWithContentsOfURL:(NSURL *)uri
	options:(NSDataReadingOptions)options
	  error:(NSError **)errorp
{
	return [[self allocWithZone:NULL] initWithContentsOfURL:uri options:options error:errorp];
}

- (id)initWithBytes:(const void*)bytes
    length:(unsigned int)length
{
	return self;
}

- (id)initWithBytesNoCopy:(void*)bytes
    length:(unsigned int)length
{
	return [self initWithBytesNoCopy:bytes length:length freeWhenDone:true];
}

- (id)initWithBytesNoCopy:(void*)bytes
    length:(unsigned int)length
	freeWhenDone:(bool)flag
{
	return self;
}

- (id) initWithContentsOfURL:(NSURL *)uri
{
	return [self initWithContentsOfURL:uri options:0 error:NULL];
}

- (id) initWithContentsOfURL:(NSURL *)uri options:(NSUInteger)options error:(NSError **)errp
{
	TODO;	// initWithContentsOfURL:options:error:

	[self notImplemented:_cmd];
	return nil;
}

- (id)initWithData:(NSData *)source
{
	return [self initWithBytes:[source bytes] length:[source length]];
}

- (bool) writeToURL:(NSURL *)url atomically:(bool)atomic
{
	NSDataWritingOptions opts = 0;

	if (atomic)
	{
		opts = NSDataWritingAtomic;
	}
	return [self writeToURL:url options:opts error:NULL];
}

- (bool) writeToURL:(NSURL *)url options:(NSDataWritingOptions)opts error:(NSError **)errp
{
	TODO; // -[NSData writeToURL:options:error:]
	return false;
}

- (id)copyWithZone:(NSZone*)zone
{
	return self;
}

- (id) mutableCopyWithZone:(NSZone *)zone
{
	return [[NSMutableData allocWithZone:zone] initWithData:self];
}

- (NSString*)description
{
	unsigned i;
	unsigned int length = [self length];
	const char* bytes = [self bytes];
	/* '< ... >', == 4 + 2 * n.  length / 4 = groups of 8 chars (4 bytes) */
	unsigned int final_length = 4 + 2 * length + 1;
	if (length > 0)
		final_length = final_length + (length - 1) / 4;
	char* description = malloc(final_length);
	char* temp = description + 1;
	static const char possibleBytes[] = { '0', '1', '2', '3', '4', '5', '6',
		'7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };

	description[0] = '<';
	description[1] = ' ';
	description[final_length - 2] = '>';
	description[final_length - 3] = ' ';
	description[final_length - 1] = 0;
	for(i = 0; i < length; i++)
	{
		if (i % 4 == 0)
		{
			*temp++ = ' ';
		}
		*temp++ = possibleBytes[(bytes[i] & 0xF0) >> 4];
		*temp++ = possibleBytes[bytes[i] & 0x0F];
	}
	return [[NSString alloc] initWithBytesNoCopy:description length:(final_length - 1)
		encoding:NSASCIIStringEncoding freeWhenDone:true];
}

- (void)getBytes:(void*)buffer
  length:(unsigned int)_length
{
	NSRange r = {0, _length};
	[self getBytes:buffer range:r];
}

- (void)getBytes:(void*)buffer
    range:(NSRange)aRange
{
    unsigned int length = [self length];

    if(NSMaxRange(aRange) > length)
	{
		@throw [NSRangeException exceptionWithReason:nil userInfo:nil];
	}

    memcpy(buffer, (char *)[self bytes] + aRange.location, aRange.length);
}

- (NSData*)subdataWithRange:(NSRange)aRange
{
	char* buffer = malloc(aRange.length);

    [self getBytes:buffer range:aRange];
	return [[NSData alloc] initWithBytesNoCopy:buffer length:aRange.length freeWhenDone:true];
}

- (NSHashCode)hash
{
    return hashjb([self bytes], [self length]);
}

- (bool)isEqualToData:(NSData*)other
{
    if([self length] == [other length])
	{
		return memcmp([self bytes], [other bytes], [self length]) == 0;
	}
    else
		return false;
}

- (bool)isEqual:(id)anObject
{
	if([anObject isKindOfClass:[NSData class]])
	{
		return [self isEqualToData:anObject];
	} else {
		return false;
	}
}

- (NSRange) rangeOfData:(NSData *)subData options:(NSDataSearchOptions)mask range:(NSRange)searchRange
{
	NSRange result = NSMakeRange(NSNotFound, 0);
	NSParameterAssert(subData != nil);

	size_t selfLength = searchRange.length;
	size_t theirLength = [subData length];

	if (theirLength > selfLength)
	{
		return result;
	}
	if (theirLength == 0)
	{
		return NSMakeRange(0,0);
	}

	/* In case memory is allocated.  Generally isn't, but can't be too careful.  */
	@autoreleasepool {

		const unsigned char *ourBytes = (const unsigned char *)[self bytes] + searchRange.location;
		const unsigned char *theirBytes = [subData bytes];

		if (mask & NSDataSearchAnchored)
		{
			if (mask & NSDataSearchBackwards)
			{
				ourBytes = (ourBytes + selfLength - theirLength);
			}
			if (memcmp(ourBytes, theirBytes, theirLength) == 0)
			{
				result = NSMakeRange((mask&NSDataSearchBackwards ? selfLength - theirLength : 0) + searchRange.location, theirLength);
			}
			else
			{
				result = NSMakeRange(NSNotFound, 0);
			}
		}
		else
		{
			if (mask & NSDataSearchBackwards)
			{
				long start = selfLength - theirLength;

				while (start >= 0)
				{
					const unsigned char *s = memrchr(ourBytes, theirBytes[0], start);
					if (s == NULL)
					{
						break;
					}

					start = s - ourBytes;
					if (memcmp(s, theirBytes, theirLength) == 0)
					{
						result = NSMakeRange(start + searchRange.location, theirLength);
						break;
					}

					start--;
				}
			}
			else
			{
				unsigned char *resultStart = memmem(ourBytes, selfLength, theirBytes, theirLength);

				if (resultStart != NULL)
				{
					result = NSMakeRange(resultStart - ourBytes + searchRange.location, theirLength);
				}
			}
		}
	}
	return result;
}

+ (id) dataByDecodingBase64String:(NSString *)string
{
	unsigned      length=[string length],resultLength=0;
	unsigned char result[length];

	const char *inStr = [string UTF8String];

	resultLength = b64_pton(inStr, result, length);
	return [NSData dataWithBytes:result length:resultLength];
}

- (NSString *)encodedBase64String
{
	unsigned long len = [self length];
	char buf[(len+3) * 4/3 + 1];
	int outcount = 0;

	outcount = b64_ntop([self bytes], len, buf, sizeof(buf));

	buf[outcount] = 0;
	return [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		[coder encodeInteger:[self length] forKey:@"GD.D.Length"];
		[coder encodeBytes:[self bytes] length:[self length] forKey:@"GD.D.Bytes"];
	}
	else
	{
		size_t length = [self length];
		[coder encodeValueOfObjCType:@encode(size_t) at:&length];

		if (length > 0)
		{
			[coder encodeArrayOfObjCType:@encode(unsigned char *) count:length at:[self bytes]];
		}
	}
}

- (id) initWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		size_t encLength;
		const uint8_t *bytes = [coder decodeBytesForKey:@"GD.D.Bytes" returningLength:&encLength];
		self = [self initWithBytes:bytes length:encLength];
	}
	else
	{
		size_t length;
		[coder decodeValueOfObjCType:@encode(size_t) at:&length];

		if (length > 0)
		{
			unsigned char *bytes = malloc(sizeof(unsigned char) * length);
			[coder decodeArrayOfObjCType:@encode(unsigned char *) count:length at:bytes];
			self = [self initWithBytesNoCopy:bytes length:length freeWhenDone:true];
		}
	}
	return self;
}

@end

@implementation NSMutableData

/* Primitives needed to override. */

- (char *)mutableBytes
{
	[self subclassResponsibility:_cmd];
	return NULL;
}

- (void)setLength:(unsigned int)length
{
    [self subclassResponsibility:_cmd];
}


/* The meat of the class. */

+ (id) allocWithZone:(NSZone *)zone
{
    return NSAllocateObject(((self == [NSMutableData class]) ?
	    [NSCoreData class] : (Class)self), 0, zone);
}

+ (id)data
{
    return [[self allocWithZone:NULL] initWithBytes:NULL length:0];
}

+ (id)dataWithCapacity:(unsigned int)numBytes
{
    return [[self allocWithZone:NULL] initWithCapacity:numBytes];
}

+ (id)dataWithLength:(unsigned int)length
{
    return [[self allocWithZone:NULL] initWithLength:length];
}

- (id)initWithCapacity:(unsigned int)capacity
{
	return self;
}

- (id)initWithLength:(unsigned int)length
{
	[self setLength:length];
	return self;
}

- (id) copyWithZone:(NSZone *)zone
{
	return [[NSData allocWithZone:zone] initWithData:self];
}

- (id) mutableCopyWithZone:(NSZone *)zone
{
	return [[NSMutableData allocWithZone:zone] initWithData:self];
}

- (void)increaseLengthBy:(unsigned int)extraLength
{
	[self setLength:[self length] + extraLength];
}

- (void)appendBytes:(const void*)_bytes
    length:(unsigned int)_length
{
	char *bytes;
	size_t len = [self length];

	[self setLength:len + _length];
	bytes = [self mutableBytes];
	memcpy(bytes + len, (char *)_bytes, _length);
}

- (void)appendData:(NSData*)other
{
    [self appendBytes:[other bytes] length:[other length]];
}

- (void)replaceBytesInRange:(NSRange)aRange
    withBytes:(const void*)bytes
{
	unsigned int length = [self length];

	if(NSMaxRange(aRange) > length)
	{
		@throw [NSRangeException exceptionWithReason:nil userInfo:nil];
	}

	char *mBytes = [self mutableBytes];
	memcpy(mBytes + aRange.location, bytes, aRange.length);
}

- (void)replaceBytesInRange:(NSRange)aRange withBytes:(const void *)bytes length:(size_t)length
{
	char *mBytes;
	if (length > aRange.length)
	{
		[self setLength:([self length] + (length - aRange.length))];
	}
	mBytes = [self mutableBytes];
	if (length != aRange.length)
	{
		memmove(mBytes + NSMaxRange(aRange), mBytes + aRange.location + length, [self length] - NSMaxRange(aRange));
	}
	memcpy(mBytes + aRange.location, bytes, length);
	if (length < aRange.length)
	{
		[self setLength:([self length] - (length - aRange.length))];
	}
}

- (void)setData:(NSData*)aData
{
	[self setLength:[aData length]];
	[self replaceBytesInRange:NSMakeRange(0, [self length])
		withBytes:[aData bytes]];
}

- (void)resetBytesInRange:(NSRange)aRange
{
	unsigned int length = [self length];

	if(NSMaxRange(aRange) > length)
	{
		@throw [NSRangeException exceptionWithReason:nil userInfo:nil];
	}

	char* mBytes = [self mutableBytes];
	memset(mBytes + aRange.location, 0, aRange.length);
}

@end /* NSMutableData */

