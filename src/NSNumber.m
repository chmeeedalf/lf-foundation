/*
 * Copyright (c) 2004-2012	Justin Hibbits
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

/*
   NSNumber.m

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

#import <Foundation/NSValue.h>
#import "NSConcreteNumber.h"

#import <Foundation/NSException.h>
#import <Foundation/NSString.h>

#import "NSConcreteValue.h"
#include <string.h>

/*
 * Temporary number used to allocate and initialize Numbers
 * through initWith... methods in constructs like [[NSNumber alloc] initWith...
 */

@interface NSTemporaryNumber : NSNumber
@end

@implementation NSTemporaryNumber

#define TempNum(type, name) \
	- (id) initWith##name:(type)value \
	{ \
		return (id)[[NS##name##Number alloc] initValue:&value withObjCType:NULL]; \
	} struct hack

TempNum(bool, Bool);
TempNum(char, Char);
TempNum(unsigned char, UnsignedChar);
TempNum(short, Short);
TempNum(unsigned short, UnsignedShort);
TempNum(int, Int);
TempNum(unsigned int, UnsignedInt);
TempNum(long, Long);
TempNum(unsigned long, UnsignedLong);
TempNum(long long, LongLong);
TempNum(unsigned long long, UnsignedLongLong);
TempNum(float, Float);
TempNum(double, Double);

@end

/*
 *  NSNumber class implementation
 */

@implementation NSNumber

+ (id)allocWithZone:(NSZone*)zone
{
	return NSAllocateObject((self == [NSNumber class])
			? [NSTemporaryNumber class] : (Class)self,
			0, zone);
}

#define FactoryNum(type, name, retName) \
	+ (NSNumber *)numberWith##name:(type)value \
	{ \
		return [[NS##name##Number alloc] initValue:&value withObjCType:NULL]; \
	} \
	- (id) initWith##name:(__unused type)value \
	{ \
		[self subclassResponsibility:_cmd]; \
		self = nil; \
		return self; \
	} \
	- (type) retName##Value \
	{ \
		[self subclassResponsibility:_cmd]; \
		return 0; \
	} \
	struct hack
	

FactoryNum(bool, Bool, bool);
FactoryNum(char, Char, char);
FactoryNum(unsigned char, UnsignedChar, unsignedChar);
FactoryNum(short, Short, short);
FactoryNum(unsigned short, UnsignedShort, unsignedShort);
FactoryNum(int, Int, int);
FactoryNum(unsigned int, UnsignedInt, unsignedInt);
FactoryNum(long, Long, long);
FactoryNum(unsigned long, UnsignedLong, unsignedLong);
FactoryNum(long long, LongLong, longLong);
FactoryNum(unsigned long long, UnsignedLongLong, unsignedLongLong);
FactoryNum(float, Float, float);
FactoryNum(double, Double, double);
FactoryNum(NSInteger, Integer, integer);
FactoryNum(NSUInteger, UnsignedInteger, unsignedInteger);


/* These methods are not written in concrete subclassses */

- (NSHashCode)hash
{
	return [self unsignedIntValue];
}

- (NSComparisonResult)compare:(__unused NSNumber*)otherNumber
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (bool)isEqualToNumber:(NSNumber*)aNumber
{
	return [self compare:aNumber] == NSOrderedSame;
}

- (bool)isEqual:(id)aNumber
{
	return [aNumber isKindOfClass:[NSNumber class]]
		&& [self isEqualToNumber:aNumber];
}

- (NSString*)description
{
	return [self descriptionWithLocale:nil];
}

- (NSString*)descriptionWithLocale:(__unused NSLocale*)locale
{
	return [self subclassResponsibility:_cmd];
}

- (NSString*)stringValue
{
	return [self descriptionWithLocale:nil];
}

@end
