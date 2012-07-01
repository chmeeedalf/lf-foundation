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
#include <math.h>
#include <stdio.h>
#include <string.h>

#import "internal.h"

@interface NSDecimalZeroNumber : NSDecimalNumber
@end

@interface NSDecimalOneNumber : NSDecimalNumber
@end

@interface NSDecimalNotANumber : NSDecimalNumber
@end

@implementation NSDecimalNumber

static id<NSDecimalNumberBehaviors> defBehavior = nil; // THREAD
static NSDecimalNumber *zero = nil; // THREAD
static NSDecimalNumber *one  = nil; // THREAD
static NSDecimalNumber *decNan  = nil; // THREAD

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
	if (zero == nil)
		zero = [[NSDecimalZeroNumber alloc] init];
	return zero;
}

+ (NSDecimalNumber *)one
{
	if (one == nil)
		one = [[NSDecimalOneNumber alloc] init];
	return one;
}

+ (NSDecimalNumber *)notANumber
{
	if (decNan == nil)
		decNan = [[NSDecimalNotANumber alloc] init];
	return decNan;
}

+ (NSDecimalNumber *)maximumDecimalNumber
{
	return [self notImplemented:_cmd];
}

+ (NSDecimalNumber *)minimumDecimalNumber
{
	return [self notImplemented:_cmd];
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
	/* TO BE FIXED ! */
	TODO; // -[NSDecimalNumber decimalNumberWithNumber:]
	return nil;
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
	unsigned short exponent;
	unsigned long long mantissa;
	unsigned long long x = *(unsigned long long*)&value;

	d.isNegative = value < 0.0 ? true : false;
	
	exponent = (x >> 52) & 0x7FF;
	mantissa = (x & ((1ULL << 52) - 1)) | (1ULL << 52);

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
		return self->decimal.mantissa;
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

- (NSDecimalNumber *)decimalNumberByMultiplyingByPowerOf10:(NSDecimalNumber *)_num
{
	return [self decimalNumberByMultiplyingByPowerOf10:_num withBehavior:defBehavior];
}

- (NSDecimalNumber *)decimalNumberByDividingBy:(NSDecimalNumber *)_num
{
	return [self decimalNumberByDividingBy:_num withBehavior:defBehavior];
}

- (NSDecimalNumber *)decimalNumberByRaisingToPower:(NSDecimalNumber *)_num
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

- (NSDecimalNumber *)decimalNumberByMultiplyingByPowerOf10:(NSDecimalNumber *)_num
  withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	TODO; // -[NSDecimalNumber decimalNumberByMultiplyingByPowerOf10:withBehavior:]
	return nil;
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

- (NSDecimalNumber *) decimalNumberByRaisingToPower:(NSDecimalNumber *)_num
									   withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	TODO; // -[NSDecimalNumber decimalNumberByRaisingToPower:withBehavior:]
	return nil;
}

- (NSDecimalNumber *) decimalNumberByRoundingAccordingToBehavior:(id<NSDecimalNumberBehaviors>)behavior
{
	TODO; // -[NSDecimalNumber decimalNumberByRoundingAccordingToBehavior:]
	return nil;
}

/* comparison */

- (NSComparisonResult)compareWithDecimalNumber:(NSDecimalNumber *)_num
{
	TODO; // -[NSDecimalNumber compareWithDecimalNumber:]
	return NSOrderedSame;
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

@implementation NSDecimalZeroNumber

- (id)init
{
	// Defaults to all clear
	return self;
}

/* operations */

- (NSDecimalNumber *)decimalNumberByAdding:(NSDecimalNumber *)_num
							  withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	return _num;
}

- (NSDecimalNumber *)decimalNumberBySubtracting:(NSDecimalNumber *)_num
								   withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	NSDecimal d;
	d = [_num decimalValue];
	d.isNegative = !d.isNegative;
	return [NSDecimalNumber decimalNumberWithDecimal:d];
}

- (NSDecimalNumber *)decimalNumberByMultiplyingBy:(NSDecimalNumber *)_num
									 withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	return self;
}

- (NSDecimalNumber *)decimalNumberByDividingBy:(NSDecimalNumber *)_num
								  withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	/* should check for _num==zero ??? */
	return self;
}

/* description */

- (NSString *)descriptionWithLocale:(NSLocale *)_locale
{
	return @"0";
}
- (NSString *)description
{
	return @"0";
}

@end /* NSDecimalZeroNumber */

@implementation NSDecimalOneNumber

- (id)init
{
	self->decimal.mantissa[0] = 1;
	return self;
}

/* operations */

- (NSDecimalNumber *)decimalNumberByAdding:(NSDecimalNumber *)_num
							  withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	return _num;
}

- (NSDecimalNumber *)decimalNumberByMultiplyingBy:(NSDecimalNumber *)_num
									 withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	/* 1 * x = x */
	return _num;
}

/* description */

- (NSString *)descriptionWithLocale:(NSLocale *)_locale
{
	return @"1";
}
- (NSString *)description
{
	return @"1";
}

@end /* NSDecimalOneNumber */

@implementation NSDecimalNotANumber

- (id)init
{
	self->decimal.exponent   = (signed char)0xFF;
	self->decimal.isNegative = false;
	return self;
}

/* operations */

- (NSDecimalNumber *)decimalNumberByAdding:(NSDecimalNumber *)_num
							  withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	return self;
}

- (NSDecimalNumber *)decimalNumberBySubtracting:(NSDecimalNumber *)_num
								   withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	return self;
}

- (NSDecimalNumber *)decimalNumberByMultiplyingBy:(NSDecimalNumber *)_num
									 withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	return self;
}

- (NSDecimalNumber *)decimalNumberByDividingBy:(NSDecimalNumber *)_num
								  withBehavior:(id<NSDecimalNumberBehaviors>)_beh
{
	/* should check for 0-divide ?? */
	return self;
}

/* description */

- (NSString *)descriptionWithLocale:(NSLocale *)_locale
{
	return @"NaN";
}

@end /* NSDecimalNotANumber */

@implementation NSDecimalNumberHandler

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
					  scale:(short)scale
		   raiseOnExactness:(bool)raiseOnExactness
			raiseOnOverflow:(bool)raiseOnOverflow
		   raiseOnUnderflow:(bool)raiseOnUnderflow
		raiseOnDivideByZero:(bool)raiseOnDivZero
{
	TODO; // -[NSDecimalNumberHandler initWithRoundingMode:scale:raiseOnExactness:raiseOnOverflow:raiseOnUnderflow:raiseOnDivideByZero:]
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
	return NSRoundBankers;
}

- (short)scale
{
	return 0;
}

@end /* NSDecimalNumberHandler */
