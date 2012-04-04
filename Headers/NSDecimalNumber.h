/* 
   NSDecimalNumber.h

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

#ifndef __NSDecimalNumber_h__
#define __NSDecimalNumber_h__

#include <Foundation/NSValue.h>
#include <Foundation/NSDecimal.h>

@class NSDecimalNumber, NSString, NSLocale;

@protocol NSDecimalNumberBehaviors

- (NSDecimalNumber *)exceptionDuringOperation:(SEL)method
  error:(NSCalculationError)_error
  leftOperand:(NSDecimalNumber *)_lhs
  rightOperand:(NSDecimalNumber *)_rhs;

- (NSRoundingMode)roundingMode;

- (short)scale;

@end

@interface NSDecimalNumber : NSNumber
{
  NSDecimal decimal;
}

+ (NSDecimalNumber *)decimalNumberWithDecimal:(NSDecimal)_num;
+ (NSDecimalNumber *)decimalNumberWithMantissa:(unsigned long long)_mantissa
  exponent:(short)_exp
  isNegative:(bool)_flag;
+ (NSDecimalNumber *)decimalNumberWithString:(NSString *)_s;
+ (NSDecimalNumber *)decimalNumberWithString:(NSString *)_s
  locale:(NSLocale *)_locale;

+ (NSDecimalNumber *)one;
+ (NSDecimalNumber *)zero;
+ (NSDecimalNumber *)notANumber;

- (id)initWithDecimal:(NSDecimal)_num;
- (id)initWithMantissa:(unsigned long long)_mantissa
  exponent:(short)_exp
  isNegative:(bool)_flag;
- (id)initWithString:(NSString *)_s;
- (id)initWithString:(NSString *)_s locale:(NSLocale *)_locale;

/* operations */

- (NSDecimalNumber *)decimalNumberByAdding:(NSDecimalNumber *)_num;
- (NSDecimalNumber *)decimalNumberBySubtracting:(NSDecimalNumber *)_num;
- (NSDecimalNumber *)decimalNumberByMultiplyingBy:(NSDecimalNumber *)_num;
- (NSDecimalNumber *)decimalNumberByDividingBy:(NSDecimalNumber *)_num;
- (NSDecimalNumber *)decimalNumberByRaisingToPower:(NSDecimalNumber *)_num;
- (NSDecimalNumber *)decimalNumberByMultiplyingByPowerOf10:(NSDecimalNumber *)_num;

- (NSDecimalNumber *)decimalNumberByAdding:(NSDecimalNumber *)_num
  withBehavior:(id<NSDecimalNumberBehaviors>)_beh;
- (NSDecimalNumber *)decimalNumberBySubtracting:(NSDecimalNumber *)_num
  withBehavior:(id<NSDecimalNumberBehaviors>)_beh;
- (NSDecimalNumber *)decimalNumberByMultiplyingBy:(NSDecimalNumber *)_num
  withBehavior:(id<NSDecimalNumberBehaviors>)_beh;
- (NSDecimalNumber *)decimalNumberByDividingBy:(NSDecimalNumber *)_num
  withBehavior:(id<NSDecimalNumberBehaviors>)_beh;
- (NSDecimalNumber *)decimalNumberByRaisingToPower:(NSDecimalNumber *)_num
  withBehavior:(id<NSDecimalNumberBehaviors>)_beh;
- (NSDecimalNumber *)decimalNumberByMultiplyingByPowerOf10:(NSDecimalNumber *)_num
  withBehavior:(id<NSDecimalNumberBehaviors>)_beh;


- (NSDecimalNumber *) decimalNumberByRoundingAccordingToBehavior:(id<NSDecimalNumberBehaviors>)behavior;

/* values */

- (NSDecimal)decimalValue;
- (double)doubleValue;

/* description */

- (NSString *)descriptionWithLocale:(NSLocale *)_locale;

- (const char *) objCType;

+ (void)setDefaultBehavior:(id<NSDecimalNumberBehaviors>)_beh;
+ (id<NSDecimalNumberBehaviors>)defaultBehavior;

/* comparison */

- (NSComparisonResult)compare:(NSNumber *)_num;

+ (NSDecimalNumber *)maximumDecimalNumber;
+ (NSDecimalNumber *)minimumDecimalNumber;

@end

@interface NSDecimalNumberHandler : NSObject < NSDecimalNumberBehaviors >
+ (id) defaultDecimalNumberHandler;
+ (id) decimalNumberHandlerWithRoundingMode:(NSRoundingMode)roundingMode scale:(short)scale raiseOnExactness:(bool)raiseOnExactness raiseOnOverflow:(bool)raiseOnOverflow raiseOnUnderflow:(bool)raiseOnUnderflow raiseOnDivideByZero:(bool)raiseOnDivZero;
- (id) initWithRoundingMode:(NSRoundingMode)roundingMode scale:(short)scale raiseOnExactness:(bool)raiseOnExactness raiseOnOverflow:(bool)raiseOnOverflow raiseOnUnderflow:(bool)raiseOnUnderflow raiseOnDivideByZero:(bool)raiseOnDivZero;
@end

#endif /* __NSDecimalNumber_h__ */
