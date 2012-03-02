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
/*
   NSValue.m

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

#import <Foundation/NSCoder.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#include <stdlib.h>
#include <string.h>

#import "NSConcreteValue.h"
#import "NSConcreteNumber.h"
#import <objc/encoding.h>

@implementation NSValue

/*
 * Returns concrete class for a given encoding
 * Should we return Numbers ?
 */

+ (Class)concreteClassForObjCType:(const char*)type
{
	/* Let someone else deal with this error */
	if (!type)
		@throw [NSInvalidArgumentException exceptionWithReason:@"NULL type" userInfo:nil];

	if (strlen(type) == 1)
	{
		switch(*type)
		{
			case _C_CHR:	return [NSCharNumber class];
			case _C_UCHR:	return [NSUnsignedCharNumber class];
			case _C_SHT:	return [NSShortNumber class];
			case _C_USHT:	return [NSUnsignedShortNumber class];
			case _C_INT:	return [NSIntNumber class];
			case _C_UINT:	return [NSUnsignedIntNumber class];
			case _C_LNG:	return [NSLongNumber class];
			case _C_ULNG:	return [NSUnsignedLongNumber class];
			case _C_FLT:	return [NSFloatNumber class];
			case _C_DBL:	return [NSDoubleNumber class];
			case _C_ID:		return [NSNonretainedObjectValue class];
			case _C_LNG_LNG:	return [NSLongLongNumber class];
			case _C_ULNG_LNG:	return [NSUnsignedLongLongNumber class];
		}
	}
	else
	{
		if(!strcmp(@encode(NSPoint), type))
			return [NSPointValue class];
		else if(!strcmp(@encode(NSRect), type))
			return [NSRectValue class];
		else if(!strcmp(@encode(NSSize), type))
			return [NSSizeValue class];
		else if(!strcmp(@encode(void*), type))
			return [NSPointerValue class];
	}

	return nil;
}

// Allocating and Initializing

+ (NSValue*)valueWithBytes:(const void*)value objCType:(const char*)type
{
	return [[self alloc] initWithBytes:value objCType:type];
}

+ (NSValue*)valueWithNonretainedObject:(id)anObject
{
	return [[NSNonretainedObjectValue alloc]
			initValue:&anObject withObjCType:@encode(id)];
}

+ (NSValue*)valueWithPointer:(const void*)pointer
{
	return [[NSPointerValue alloc]
			initValue:&pointer withObjCType:@encode(void*)];
}

+ (NSValue*)valueWithPoint:(NSPoint)point
{
	return [[NSPointValue alloc]
			initValue:&point withObjCType:@encode(NSPoint)];
}

+ (NSValue*)valueWithRange:(NSRange)range
{
	return [[NSRangeValue alloc]
			initValue:&range withObjCType:@encode(NSRange)];
}

+ (NSValue*)valueWithRect:(NSRect)rect
{
	return [[NSRectValue alloc]
			initValue:&rect withObjCType:@encode(NSRect)];
}

+ (NSValue*)valueWithSize:(NSSize)size
{
	return [[NSSizeValue alloc]
			initValue:&size withObjCType:@encode(NSSize)];
}

- (id) initWithBytes:(const void*)value objCType:(const char*)type
{
	Class theClass = [[self class] concreteClassForObjCType:type];

	if (theClass)
		self = [[theClass alloc] initValue:value withObjCType:type];
	else
		self = [[NSConcreteValue allocForType:type zone:NULL]
			initValue:value withObjCType:type];

	return self;
}

- (bool)isEqual:aValue
{
	if ([aValue isKindOfClass:[NSValue class]])
		return [self isEqualToValue:aValue];
	else
		return false;
}

- (bool)isEqualToValue:(NSValue*)aValue
{
	return strcmp([self objCType], [aValue objCType]) == 0
		&& memcmp([self valueBytes], [aValue valueBytes],
				objc_sizeof_type([self objCType])) == 0;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<NSValue with objc type '%s'>",
		   [self objCType]];
}

// Copying

- (id)copyWithZone:(NSZone*)zone
{
	if (NSShouldRetainWithZone(self, zone))
		return self;
	else
	{
		Class theClass = [[self class] concreteClassForObjCType:[self objCType]];
		return [[theClass allocWithZone:zone]
			initValue:[self valueBytes] withObjCType:[self objCType]];
	}
}

// Accessing NSData - implemented in concrete subclasses

- (void*)valueBytes
{
	[self subclassResponsibility:_cmd];
	return NULL;
}

- (void)getValue:(void*)value
{
	[self subclassResponsibility:_cmd];
}

- (const char*)objCType
{
	[self subclassResponsibility:_cmd];
	return NULL;
}

- (id)nonretainedObjectValue
{
	return [self subclassResponsibility:_cmd];
}

- (void*)pointerValue
{
	[self subclassResponsibility:_cmd];
	return NULL;
}

- (NSRange)rangeValue
{
	[self subclassResponsibility:_cmd];
	return NSMakeRange(0,0);
}

- (NSRect)rectValue
{
	[self subclassResponsibility:_cmd];
	return NSMakeRect(0,0,0,0);
}

- (NSSize)sizeValue
{
	[self subclassResponsibility:_cmd];
	return NSMakeSize(0,0);
}

- (NSPoint)pointValue
{
	[self subclassResponsibility:_cmd];
	return NSMakePoint(0,0);
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	[self subclassResponsibility:_cmd];
}

- (id) initWithCoder:(NSCoder *)coder
{
	[self subclassResponsibility:_cmd];
	return self;
}
@end
