/*
 * Copyright (c) 2004	Gold Project
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
   NSConcreteValue.m

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

#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#import <Foundation/NSCoder.h>
#import <Foundation/Memory.h>
#import <Foundation/NSGeometry.h>
#include <string.h>
#include <stdlib.h>

#include "internal.h"
#import "NSConcreteValue.h"

/*
 * Abstract superclass of concrete value classes
 */

@implementation NSConcreteValue

+ allocForType:(const char*)type zone:(NSZone*)zone
{
	int dataSize = objc_sizeof_type(type);
	id  value = NSAllocateObject([NSConcreteObjCValue class], dataSize, zone);

	return value;
}

- initValue:(const void*)value withObjCType:(const char*)type
{
	[self subclassResponsibility:_cmd];
	return self;
}

- (void*)valueBytes
{
	[self subclassResponsibility:_cmd];
	return NULL;
}

- (id)nonretainedObjectValue
{
	@throw [NSInternalInconsistencyException
		exceptionWithReason:@"this value does not contain an id type value"
		userInfo:nil];
	return nil;
}

- (void*)pointerValue
{
	@throw [NSInternalInconsistencyException
		exceptionWithReason:@"this value does not contain a void* value"
		userInfo:nil];
	return NULL;
}

- (NSRect)rectValue
{
	@throw [NSInternalInconsistencyException
		exceptionWithReason:@"this value does not contain a NSRect"
		userInfo:nil];
	return NSMakeRect(0,0,0,0);
}

- (NSSize)sizeValue
{
	@throw [NSInternalInconsistencyException
		exceptionWithReason:@"this value does not contain a NSSize"
		userInfo:nil];
	return NSMakeSize(0,0);
}

- (NSPoint)pointValue
{
	@throw [NSInternalInconsistencyException
		exceptionWithReason:@"this value does not contain a NSPoint"
		userInfo:nil];
	return NSMakePoint(0,0);
}

@end

/*
 * Any type concrete value class
 */

@implementation NSConcreteObjCValue

// Allocating and Initializing

- initValue:(const void*)value withObjCType:(const char*)type
{
	int	size;

	if (!value || !type)
	{
		@throw [NSInternalInconsistencyException exceptionWithReason:@"null value or type"
			userInfo:nil];
	}

	self = [super init];
	objctype = strdup(type);
	size = objc_sizeof_type(type);
	memcpy(data, value, size);
	return self;
}

- (void)dealloc
{
	free(objctype);
	[super dealloc];
}

// Copying

- (id)copyWithZone:(NSZone*)zone
{
	if (NSShouldRetainWithZone(self, zone))
	{
		return RETAIN(self);
	} else
	{
		return [[NSConcreteObjCValue allocForType:objctype zone:zone]
			initValue:(void*)data withObjCType:objctype];
	}
}

// Accessing NSData

- (void*)valueBytes
{
	return data;
}

- (void)getValue:(void*)value
{
	if (!value)
	{
		@throw [NSInternalInconsistencyException exceptionWithReason:@"NULL buffer in -getValue"
			userInfo:nil];
	} else
	{
		memcpy(value, data, objc_sizeof_type(objctype));
	}
}

- (const char*)objCType
{
	return objctype;
}

- (void*)pointerValue
{
	if (*objctype != _C_PTR)
	{
		@throw [NSInternalInconsistencyException
			exceptionWithReason:@"this value does not contain a pointer"
			userInfo:nil];
	}
	return *((void **)data);
}

- (NSRect)rectValue
{
	if (strcmp(objctype, @encode(NSRect)))
	{
		@throw [NSInternalInconsistencyException
			exceptionWithReason:@"this value does not contain a NSRect object"
			userInfo:nil];
	}
	return *((NSRect*)data);
}

- (NSSize)sizeValue
{
	if (strcmp(objctype, @encode(NSSize)))
	{
		@throw [NSInternalInconsistencyException
			exceptionWithReason:@"this value does not contain a NSSize object"
			userInfo:nil];
	}
	return *((NSSize*)data);
}

- (NSPoint)pointValue
{
	if (strcmp(objctype, @encode(NSPoint)))
	{
		@throw [NSInternalInconsistencyException
			exceptionWithReason:@"this value does not contain a NSPoint object"
			userInfo:nil];
	}
	return *((NSPoint*)data);
}

- (NSHashCode)hash
{
	return hashjb (objctype, strlen (objctype));
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<NSValue with objc type '%s'>",
		   [self objCType]];
}

@end /* ConcreteObjCValue */

/*
 * Non retained object concrete value
 */

@implementation NSNonretainedObjectValue

// Allocating and Initializing

- initValue:(const void*)value withObjCType:(const char*)type
{
	data = *(id*)value;
	return self;
}

- (bool)isEqual:(id)aValue
{
	return strcmp([self objCType], [aValue objCType]) == 0
		&& [[self nonretainedObjectValue]
		isEqual:[aValue nonretainedObjectValue]];
}

// Copying

- (id)copyWithZone:(NSZone*)zone
{
	if (NSShouldRetainWithZone(self, zone))
	{
		return RETAIN(self);
	} else
	{
		return [[NSNonretainedObjectValue alloc]
			initValue:(void*)&data withObjCType:NULL];
	}
}

// Accessing NSData

- (void*)valueBytes
{
	return &data;
}

- (void)getValue:(void*)value
{
	if (!value)
	{
		@throw [NSInternalInconsistencyException exceptionWithReason:@"NULL buffer in -getValue"
			userInfo:nil];
	} else
	{
		*(id*)value = data;
	}
}

- (const char*)objCType
{
	return @encode(id);
}

-(id)nonretainedObjectValue;
{
	return data;
}

- (NSHashCode)hash
{
	return (unsigned long)data;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<NSValue with object %@>", data];
}

@end /* NSNonretainedObjectValue */

/*
 * Void NSPointer concrete value
 */

@implementation NSPointerValue

// Allocating and Initializing

- initValue:(const void*)value withObjCType:(const char*)type
{
	data = *(void**)value;
	return self;
}

// Copying

- (id)copyWithZone:(NSZone*)zone
{
	if (NSShouldRetainWithZone(self, zone))
	{
		return RETAIN(self);
	} else
	{
		return [[NSNonretainedObjectValue alloc]
			initValue:(void*)&data withObjCType:NULL];
	}
}

// Accessing NSData

- (void*)valueBytes
{
	return &data;
}

- (void)getValue:(void*)value
{
	if (!value)
	{
		@throw [NSInternalInconsistencyException exceptionWithReason:@"NULL buffer in -getValue"
			userInfo:nil];
	} else
	{
		*(void**)value = data;
	}
}

- (const char*)objCType
{
	return @encode(void*);
}

- (void*)pointerValue;
{
	return data;
}

- (NSHashCode)hash
{
	return (unsigned long)data;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<NSValue with pointer 0x%08x>", data];
}

@end /* NSPointerValue */

/*
 * NSRect concrete value
 */

@implementation NSRectValue

// Allocating and Initializing

- initValue:(const void*)value withObjCType:(const char*)type
{
	data = *(NSRect*)value;
	return self;
}

// Copying

- (id)copyWithZone:(NSZone*)zone
{
	if (NSShouldRetainWithZone(self, zone))
	{
		return RETAIN(self);
	} else
	{
		return [[NSRectValue alloc]
			initValue:(void*)&data withObjCType:NULL];
	}
}

// Accessing NSData

- (void*)valueBytes
{
	return &data;
}

- (void)getValue:(void*)value
{
	if (!value)
	{
		@throw [NSInternalInconsistencyException exceptionWithReason:@"NULL buffer in -getValue"
			userInfo:nil];
	} else
	{
		*(NSRect*)value = data;
	}
}

- (const char*)objCType
{
	return @encode(NSRect);
}

- (NSRect)rectValue;
{
	return data;
}

- (NSHashCode)hash
{
	return (unsigned)(NSMaxX(data) + NSMaxY(data));
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<NSValue with rect %@>",
		   NSStringFromRect(data)];
}

@end /* NSRectValue */

/*
 * NSSize concrete value
 */

@implementation NSSizeValue

// Allocating and Initializing

- initValue:(const void*)value withObjCType:(const char*)type
{
	data = *(NSSize*)value;
	return self;
}

// Copying

- (id)copyWithZone:(NSZone*)zone
{
	if (NSShouldRetainWithZone(self, zone))
	{
		return RETAIN(self);
	}
	else
	{
		return [[NSSizeValue alloc]
			initValue:(void*)&data withObjCType:NULL];
	}
}

// Accessing NSData

- (void*)valueBytes
{
	return &data;
}

- (void)getValue:(void*)value
{
	if (!value)
	{
		@throw [NSInternalInconsistencyException exceptionWithReason:@"NULL buffer in -getValue"
			userInfo:nil];
	}
	else
	{
		*(NSSize*)value = data;
	}
}

- (const char*)objCType
{
	return @encode(NSSize);
}

- (NSPoint)pointValue;
{
	return NSMakePoint(data.width, data.height);
}

- (NSSize)sizeValue;
{
	return data;
}

- (NSHashCode)hash
{
	return (unsigned)(data.width + data.height);
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<NSValue with size %@>",
		   NSStringFromSize(data)];
}

@end /* NSSizeValue */

/*
 * NSPoint concrete value
 */

@implementation NSPointValue

// Allocating and Initializing

- initValue:(const void*)value withObjCType:(const char*)type
{
	data = *(NSPoint*)value;
	return self;
}

// Copying

- (id)copyWithZone:(NSZone*)zone
{
	if (NSShouldRetainWithZone(self, zone))
	{
		return RETAIN(self);
	}
	else
	{
		return [[NSPointValue alloc]
			initValue:(void*)&data withObjCType:NULL];
	}
}

// Accessing NSData

- (void*)valueBytes
{
	return &data;
}

- (void)getValue:(void*)value
{
	if (!value)
	{
		@throw [NSInternalInconsistencyException exceptionWithReason:@"NULL buffer in -getValue"
			userInfo:nil];
	}
	else
	{
		*(NSPoint*)value = data;
	}
}

- (const char*)objCType
{
	return @encode(NSPoint);
}

- (NSPoint)pointValue;
{
	return data;
}

- (NSSize)sizeValue;
{
	return NSMakeSize(data.x, data.y);
}

- (NSHashCode)hash
{
	return (unsigned)(data.x + data.y);
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<NSValue with point %@>",
		   NSStringFromPoint(data)];
}

@end /* NSPointValue */

/*
 * NSRange concrete value
 */

@implementation NSRangeValue

// Allocating and Initializing

- initValue:(const void*)value withObjCType:(const char*)type
{
	data = *(NSRange*)value;
	return self;
}

// Copying

- (id)copyWithZone:(NSZone*)zone
{
	if (NSShouldRetainWithZone(self, zone))
	{
		return RETAIN(self);
	} else
	{
		return [[NSPointValue alloc]
			initValue:(void*)&data withObjCType:NULL];
	}
}

// Accessing NSData

- (void*)valueBytes
{
	return &data;
}

- (void)getValue:(void*)value
{
	if (!value)
	{
		@throw [NSInternalInconsistencyException exceptionWithReason:@"NULL buffer in -getValue"
			userInfo:nil];
	} else
	{
		*(NSRange*)value = data;
	}
}

- (NSRange)rangeValue
{
	return data;
}

- (const char*)objCType
{
	return @encode(NSPoint);
}

- (NSHashCode)hash
{
	return (unsigned)(data.location + data.length);
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<NSValue with range %@>",
		   NSStringFromRange(data)];
}

@end /* NSPointValue */
