/* 
   NSDecimalNumber.m

   Copyright (C) 2012 Justin Hibbits
   Copyright (C) 2001, MDlink online service center GmbH, Helge Hess
   All rights reserved.

   Author: Helge Hess <helge.hess@mdlink.de>

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

#import <Foundation/NSDecimalNumber.h>
#import <Foundation/NSString.h>
#include <limits.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

#import "internal.h"

@implementation NSDecimalNumber

static id<NSDecimalNumberBehaviors> defBehavior = nil; // THREAD
static NSDecimalNumber *zero = nil; // THREAD
static NSDecimalNumber *one  = nil; // THREAD
static NSDecimalNumber *decNan  = nil; // THREAD
static NSDecimalNumber *minDec = nil;
static NSDecimalNumber *maxDec = nil;

+ (void) initialize
{
	NSDecimal d = {.isValid = false};
	decNan = [[self alloc] initWithDecimal:d];

	minDec = [[self alloc] initWithDecimal:d];
	maxDec = [[self alloc] initWithDecimal:d];

	zero = [[self alloc] initWithDouble:0.0];
	one = [[self alloc] initWithDouble:1.0];
}

+ (void)setDefaultBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	defBehavior = _beh;
}

+ (id<NSDecimalNumberBehaviors>)defaultBehavior
{
	return defBehavior;
}

+ (NSDecimalNumber *)zero
{
	return zero;
}

+ (NSDecimalNumber *)one
{
	return one;
}

+ (NSDecimalNumber *)notANumber
{
	return decNan;
}

+ (NSDecimalNumber *)maximumDecimalNumber
{
	return maxDec;
}

+ (NSDecimalNumber *)minimumDecimalNumber
{
	return minDec;
}

+ (NSDecimalNumber *)decimalNumberWithDecimal:(NSDecimal)_num
{
	return [[self alloc] initWithDecimal:_num];
}

+ (NSDecimalNumber *)decimalNumberWithMantissa:(unsigned long long)_mantissa
									  exponent:(short)_exp
									isNegative:(bool)_flag
{
	return [[self alloc] initWithMantissa:_mantissa
								 exponent:_exp isNegative:_flag];
}

+ (NSDecimalNumber *)decimalNumberWithString:(NSString *)_s
{
	return [[self alloc] initWithString:_s];
}

+ (NSDecimalNumber *)decimalNumberWithString:(NSString *)_s
									  locale:(NSLocale *)_locale
{
	return [[self alloc] initWithString:_s locale:_locale];
}

+ (NSDecimalNumber *)decimalNumberWithNumber:(NSNumber *)_number
{
	if ([_number isKindOfClass:[NSDecimalNumber class]])
		return (NSDecimalNumber *)_number;
	return (NSDecimalNumber *)[self numberWithDouble:[_number doubleValue]];
}

- (id)initWithDecimal:(NSDecimal)_num
{
	static const NSDecimal zeroDec = {};
	static const NSDecimal oneDec = {.mantissa[0] = 1};
	/* designated initializer */
	if (memcmp(&_num, &zeroDec, sizeof(_num)) == 0)
		return [[self class] zero];
	else if (memcmp(&_num, &oneDec, sizeof(_num)) == 0)
		return [[self class] one];

	self->decimal = _num;
	return self;
}

- (id)init
{
	return [self initWithMantissa:0 exponent:0 isNegative:false];
}

- (id)initWithMantissa:(unsigned long long)_mantissa
			  exponent:(short)_exp
			isNegative:(bool)_flag
{
	NSDecimal d = {};
	d.exponent   = _exp;
	d.isNegative = _flag ? true : false;
	d.mantissa[0] = _mantissa & (SHRT_MAX);
	d.mantissa[1] = (_mantissa >> 16) & SHRT_MAX;
	d.mantissa[2] = (_mantissa >> 32) & SHRT_MAX;
	d.mantissa[3] = (_mantissa >> 48) & SHRT_MAX;
	return [self initWithDecimal:d];
}

- (id)initWithString:(NSString *)_s locale:(NSLocale *)_locale
{
	return [self initWithDouble:[_s doubleValue]];
}

- (id)initWithString:(NSString *)_s
{
	return [self initWithString:_s locale:nil];
}

/* integer init's */

- (id)initWithBool:(bool)value
{
	return [self initWithInt:value ? 1 : 0];
}

- (id)initWithChar:(char)value
{
	return [self initWithInt:value];
}

- (id)initWithUnsignedChar:(unsigned char)value
{
	return [self initWithInt:value];
}

- (id)initWithShort:(short)value
{
	return [self initWithInt:value];
}

- (id)initWithUnsignedShort:(unsigned short)value
{
	return [self initWithInt:value];
}

- (id)initWithInt:(int)value
{
	bool isNeg = false;
	if (value < 0)
	{
		value = -value;
		isNeg = true;
	}
	return [self initWithMantissa:value exponent:0 isNegative:isNeg];
}

- (id)initWithUnsignedInt:(unsigned int)value
{
	return [self initWithMantissa:value exponent:0 isNegative:false];
}

- (id)initWithLong:(long)value
{
	bool isNeg = false;
	if (value < 0)
	{
		value = -value;
		isNeg = true;
	}
	return [self initWithMantissa:value exponent:0 isNegative:isNeg];
}

- (id)initWithUnsignedLong:(unsigned long)value
{
	return [self initWithMantissa:value exponent:0 isNegative:false];
}

- (id)initWithLongLong:(long long)value
{
	bool isNeg = false;
	if (value < 0)
	{
		value = -value;
		isNeg = true;
	}
	return [self initWithMantissa:value exponent:0 isNegative:isNeg];
}

- (id)initWithUnsignedLongLong:(unsigned long long)value
{
	return [self initWithMantissa:value exponent:0 isNegative:false];
}

/* floating point inits */

- (id)initWithFloat:(float)value
{
	return [self initWithDouble:(double)value];
}

- (id)initWithDouble:(double)value
{
	NSDecimal d;

	/* Assume 64-bit IEEE-754 double precision:
	 * SEEEEEEEEEEEM....M
	 * S - sign bit
	 * E - 11-bit exponent
	 * M - 52-bit mantissa
	 */
	unsigned long long mantissa;
	unsigned long long x = *(unsigned long long*)&value;

	d.isNegative = value < 0.0 ? true : false;
	
	d.exponent = (x >> 52) & 0x7FF;
	mantissa = (x & ((1ULL << 52) - 1)) | (1ULL << 52);
	d.length = (52 / 16) + 1;

	memset(d.mantissa, 0, sizeof(d.mantissa));

	for (int i = 0; i < 4; i++)
	{
		d.mantissa[i] = mantissa & 0xFFFF;
		mantissa >>= 16;
	}

	return [self initWithDecimal:d];
}

/* type */

- (const char *)objCType
{
	return "d";
}

/* values */

- (int)intValue
{
	long long x = [self longLongValue];
	
	if (x > INT_MAX)
		return INT_MAX;
	else if (x < INT_MIN)
		return INT_MIN;
	return x;
}

- (bool)boolValue
{
	return [self intValue] ? true : false;
}

- (char)charValue
{
	return [self intValue];
}

- (unsigned char)unsignedCharValue
{
	return [self intValue];
}

- (short)shortValue
{
	return [self intValue];
}

- (unsigned short)unsignedShortValue
{
	return [self unsignedIntValue];
}

- (unsigned int)unsignedIntValue
{
	return [self unsignedLongValue];
}

- (long)longValue
{
	return [self longLongValue];
}

- (unsigned long)unsignedLongValue
{
	return [self unsignedLongLongValue];
}

- (long long)longLongValue
{
	return [self doubleValue];
}

- (unsigned long long)unsignedLongLongValue
{
	if (self->decimal.exponent == 0 && !self->decimal.isNegative)
	{
		return ((unsigned long long)self->decimal.mantissa[0]) |
			((unsigned long long)self->decimal.mantissa[1] << 16) |
			((unsigned long long)self->decimal.mantissa[2] << 32) |
			((unsigned long long)self->decimal.mantissa[3] << 48);
	}
	return [self doubleValue];
}

- (float)floatValue
{
	return [self doubleValue];
}

- (double)doubleValue
{
	TODO; // -[NSDecimalNumber doubleValue]
	return 0.0;
}

- (NSDecimal)decimalValue
{
	return self->decimal;
}

/* operations */

- (NSDecimalNumber *)decimalNumberByAdding:(NSDecimalNumber *)_num
{
	return [self decimalNumberByAdding:_num withBehavior:defBehavior];
}

- (NSDecimalNumber *)decimalNumberBySubtracting:(NSDecimalNumber *)_num
{
	return [self decimalNumberBySubtracting:_num withBehavior:defBehavior];
}

- (NSDecimalNumber *)decimalNumberByMultiplyingBy:(NSDecimalNumber *)_num
{
	return [self decimalNumberByMultiplyingBy:_num withBehavior:defBehavior];
}

- (NSDecimalNumber *)decimalNumberByMultiplyingByPowerOf10:(short)_num
{
	return [self decimalNumberByMultiplyingByPowerOf10:_num withBehavior:defBehavior];
}

- (NSDecimalNumber *)decimalNumberByDividingBy:(NSDecimalNumber *)_num
{
	return [self decimalNumberByDividingBy:_num withBehavior:defBehavior];
}

- (NSDecimalNumber *)decimalNumberByRaisingToPower:(NSUInteger)_num
{
	return [self decimalNumberByRaisingToPower:_num withBehavior:defBehavior];
}

- (NSDecimalNumber *)decimalNumberByAdding:(NSDecimalNumber *)_num
							  withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	NSDecimal          res, r;
	NSCalculationError err;

	r = [_num decimalValue];

	err = NSDecimalAdd(&res, &(self->decimal), &r, [_beh roundingMode]);

	if (err != NSCalculationOK)
	{
		return [_beh exceptionDuringOperation:_cmd
										error:err
								  leftOperand:self
								 rightOperand:_num];
	}

	return [NSDecimalNumber decimalNumberWithDecimal:res];
}

- (NSDecimalNumber *)decimalNumberBySubtracting:(NSDecimalNumber *)_num
								   withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	NSDecimal          res, r;
	NSCalculationError err;

	r = [_num decimalValue];

	err = NSDecimalSubtract(&res, &(self->decimal), &r, [_beh roundingMode]);

	if (err != NSCalculationOK)
	{
		return [_beh exceptionDuringOperation:_cmd
										error:err
								  leftOperand:self
								 rightOperand:_num];
	}

	return [NSDecimalNumber decimalNumberWithDecimal:res];
}

- (NSDecimalNumber *)decimalNumberByMultiplyingBy:(NSDecimalNumber *)_num
									 withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	NSDecimal          res, r;
	NSCalculationError err;

	r = [_num decimalValue];

	err = NSDecimalMultiply(&res, &(self->decimal), &r, [_beh roundingMode]);

	if (err != NSCalculationOK)
	{
		return [_beh exceptionDuringOperation:_cmd
										error:err
								  leftOperand:self
								 rightOperand:_num];
	}

	return [NSDecimalNumber decimalNumberWithDecimal:res];
}

- (NSDecimalNumber *)decimalNumberByMultiplyingByPowerOf10:(short)num
  withBehavior:(id<NSDecimalNumberBehaviors>)beh
{
	NSDecimal d;
	NSCalculationError err;

	err = NSDecimalMultiplyByPowerOf10(&d, &decimal, num, [beh roundingMode]);

	if (err != NSCalculationOK)
	{
		return [beh exceptionDuringOperation:_cmd
										error:err
								  leftOperand:self
								 rightOperand:(NSDecimalNumber *)[NSDecimalNumber numberWithShort:num]];
	}
	return [[NSDecimalNumber alloc] initWithDecimal:d];
}

- (NSDecimalNumber *)decimalNumberByDividingBy:(NSDecimalNumber *)_num
								  withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	NSDecimal          res, r;
	NSCalculationError err;

	r = [_num decimalValue];

	err = NSDecimalDivide(&res, &(self->decimal), &r, [_beh roundingMode]);

	if (err != NSCalculationOK)
	{
		return [_beh exceptionDuringOperation:_cmd
										error:err
								  leftOperand:self
								 rightOperand:_num];
	}

	return [NSDecimalNumber decimalNumberWithDecimal:res];
}

- (NSDecimalNumber *) decimalNumberByRaisingToPower:(NSUInteger)_num
									   withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	NSDecimal res;
	NSCalculationError err;

	err = NSDecimalPower(&res, &decimal, _num, [_beh roundingMode]);

	if (err != NSCalculationOK)
	{
		return [_beh exceptionDuringOperation:_cmd
										error:err
								  leftOperand:self
								 rightOperand:[[NSDecimalNumber alloc] initWithUnsignedLong:_num]];
	}
	return [NSDecimalNumber decimalNumberWithDecimal:res];
}

- (NSDecimalNumber *) decimalNumberByRoundingAccordingToBehavior:(id<NSDecimalNumberBehaviors>)behavior
{
	NSDecimal result;

	NSDecimalRound(&result, &decimal, [behavior scale], [behavior roundingMode]);
	return [[NSDecimalNumber alloc] initWithDecimal:result];
}

/* comparison */

- (NSComparisonResult)compareWithDecimalNumber:(NSDecimalNumber *)other
{
	return NSDecimalCompare(&decimal, &(other->decimal));
}

- (NSComparisonResult)compare:(NSNumber *)_num
{
	NSDecimalNumber *num;

	if (_num == self) return NSOrderedSame;

	if ([_num isKindOfClass:[NSDecimalNumber class]])
		num = (NSDecimalNumber *)_num;
	else
		num = [NSDecimalNumber decimalNumberWithNumber:_num];

	return [self compareWithDecimalNumber:num];
}

/* description */

- (NSString *)stringValue
{
	return [self description];
}

- (NSString *)descriptionWithLocale:(NSLocale *)_locale
{
	return NSDecimalString(&(self->decimal), _locale);
}

- (NSString *)description
{
	return [self descriptionWithLocale:nil];
}

@end /* NSDecimalNumber */

@implementation NSDecimalNumberHandler
{
	NSRoundingMode roundMode;
	short scale;
	bool exactness;
	bool overflow;
	bool underflow;
	bool divZero;
}

+ (id) defaultDecimalNumberHandler
{
	static NSDecimalNumberHandler *defHandler;

	if (defHandler == nil)
	{
		@synchronized(self)
		{
			if (defHandler == nil)
			{
				defHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:38 raiseOnExactness:false raiseOnOverflow:true raiseOnUnderflow:true raiseOnDivideByZero:true];
			}
		}
	}
	return defHandler;
}

+ (id) decimalNumberHandlerWithRoundingMode:(NSRoundingMode)roundingMode
									  scale:(short)scale
						   raiseOnExactness:(bool)raiseOnExactness
							raiseOnOverflow:(bool)raiseOnOverflow
						   raiseOnUnderflow:(bool)raiseOnUnderflow
						raiseOnDivideByZero:(bool)raiseOnDivZero
{
	return [[self alloc] initWithRoundingMode:roundingMode
										scale:scale
							 raiseOnExactness:raiseOnExactness
							  raiseOnOverflow:raiseOnOverflow
							 raiseOnUnderflow:raiseOnUnderflow
						  raiseOnDivideByZero:raiseOnDivZero];
}

- (id) initWithRoundingMode:(NSRoundingMode)roundingMode
					  scale:(short)inScale
		   raiseOnExactness:(bool)raiseOnExactness
			raiseOnOverflow:(bool)raiseOnOverflow
		   raiseOnUnderflow:(bool)raiseOnUnderflow
		raiseOnDivideByZero:(bool)raiseOnDivZero
{
	roundMode = roundingMode;
	scale = inScale;
	exactness = raiseOnExactness;
	overflow = raiseOnOverflow;
	underflow = raiseOnUnderflow;
	divZero = raiseOnDivZero;
	return nil;
}

- (NSDecimalNumber *)exceptionDuringOperation:(SEL)method
										error:(NSCalculationError)_error
								  leftOperand:(NSDecimalNumber *)_lhs
								 rightOperand:(NSDecimalNumber *)_rhs
{
	return nil;
}

- (NSRoundingMode)roundingMode
{
	return roundMode;
}

- (short)scale
{
	return scale;
}

@end /* NSDecimalNumberHandler */
