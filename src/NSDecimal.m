/* 
   NSDecimal.m

   Copyright (C) 2012, Justin Hibbits
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

#include <math.h>
#include <string.h>

#include <Foundation/NSDecimal.h>
#include <Foundation/NSString.h>
#import "internal.h"

/* operations */

NSCalculationError NSDecimalAdd
(NSDecimal *res, const NSDecimal *_l, const NSDecimal *_r, NSRoundingMode rmod)
{
	NSCalculationError e;
	NSDecimal l, r;

	NSDecimalCopy(&l, _l);
	NSDecimalCopy(&r, _r);

	if (l.isNegative != r.isNegative)
	{
		NSDecimal d;
		NSDecimalCopy(&d, _r);
		d.isNegative = !_r->isNegative;

		return NSDecimalSubtract(res, _l, &d, rmod);
	}

	if ((e = NSDecimalNormalize(&l, &r, rmod)) != NSCalculationOK)
		return e;

	res->exponent = l.exponent;

	unsigned int carry = 0;
	/* both are positive or both are negative */
	for (int i = 0; i < NSDecimalMaxSize; i++)
	{
		carry += l.mantissa[i];
		carry += r.mantissa[i];
		res->mantissa[i] = carry;
		carry >>= 16;
	}
	if (carry != 0)
	{
		if (res->exponent == 127)
		{
			return NSCalculationOverflow;
		}

		for (int i = NSDecimalMaxSize; i > 0; --i)
		{
			carry <<= 16;
			carry += res->mantissa[NSDecimalMaxSize-1];
			res->mantissa[i] = carry / 10;
			carry %= 10;
		}
		res->exponent++;
	}
	res->isNegative = l.isNegative;

	return NSCalculationOK;
}

NSCalculationError NSDecimalSubtract
(NSDecimal *result, const NSDecimal *l, const NSDecimal *r, NSRoundingMode rmod)
{
	NSCalculationError e;
	NSDecimal inL, inR, d;

	if (r->isNegative != l->isNegative)
	{
		NSDecimalCopy(&d, r);
		d.isNegative = !r->isNegative;
		return NSDecimalAdd(result, l, &d, rmod);
	}

	NSDecimalCopy(&inL, l);
	NSDecimalCopy(&inR, r);
	if ((e = NSDecimalNormalize(&inL, &inR, rmod)) != NSCalculationOK)
		return e;

	/* Check if we're going negative.  If so, subtract the other way, then
	 * negate the result.
	 */
	for (int i = NSDecimalMaxSize; i > 0; --i)
	{
		if (inR.mantissa[i-1] > inL.mantissa[i-1])
		{
			e = NSDecimalSubtract(result, r, l, rmod);
			result->isNegative = !result->isNegative;
			return e;
		}
		else if (inR.mantissa[i-1] < inL.mantissa[i-1])
			break;
	}
	result->exponent = l->exponent;

	unsigned int carry = 0;
	for (int i = 0; i < NSDecimalMaxSize; i++)
	{
		if (i < NSDecimalMaxSize-1)
			carry += (inL.mantissa[i + 1] << 16);
		carry -= inR.mantissa[i];
		result->mantissa[i] = carry;
		carry >>= 16;
	}
	result->isNegative = l->isNegative;

	return e;
}

NSCalculationError NSDecimalMultiply
(NSDecimal *res, const NSDecimal *_l, const NSDecimal *_r, NSRoundingMode rmod)
{
	/* WARNING: no overflow checks ... */
	NSCalculationError e;
	NSDecimal l, r;

	NSDecimalCopy(&l, _l);
	NSDecimalCopy(&r, _r);

	if ((e = NSDecimalNormalize(&l, &r, rmod)) != NSCalculationOK)
		return e;

	if (r.exponent > 0)
	{
		r.exponent = -r.exponent;
		return NSDecimalDivide(res, &l, &r, rmod);
	}
	if (r.exponent + l.exponent > 127)
	{
		return NSCalculationOverflow;
	}

	unsigned int tmp = 0;
	for (int j = 0; j < NSDecimalMaxSize; j++)
	{
		// Shortcut, skip this one if the right side is 0.
		if (r.mantissa[j] == 0)
			continue;

		for (int i = 0; i < NSDecimalMaxSize; i++)
		{
			unsigned int tmp2 = l.mantissa[i];
			tmp = tmp2 * r.mantissa[i];
			res->mantissa[j + i] += tmp;
		}
	}

	res->isNegative = l.isNegative==r.isNegative ? NO : YES;
	res->exponent = l.exponent + r.exponent;

	return NSCalculationOK;
}

NSCalculationError NSDecimalDivide
(NSDecimal *result, const NSDecimal *l, const NSDecimal *r, NSRoundingMode rmod)
{
	if (r->mantissa == 0)
		return NSCalculationDivideByZero;

	return NSCalculationNotImplemented;
}

NSCalculationError NSDecimalMultiplyByPowerOf10
(NSDecimal *result, const NSDecimal *n, short p, NSRoundingMode rmod)
{
	/* simple left shift .. */
	if (n->exponent + p > 127)
		return NSCalculationOverflow;
	if (n->exponent + p < -128)
		return NSCalculationUnderflow;

	NSDecimalCopy(result, n);
	result->exponent += p;
	return NSCalculationNotImplemented;
}

NSCalculationError NSDecimalPower
(NSDecimal *result, const NSDecimal *n, unsigned int p, NSRoundingMode rmod)
{
	return NSCalculationNotImplemented;
}

/* comparisons */

NSComparisonResult NSDecimalCompare(const NSDecimal *l, const NSDecimal *r)
{
	if (l == r) return NSOrderedSame;
	return NSOrderedAscending;
}

bool NSDecimalIsNotANumber(const NSDecimal *decimal)
{
	return NO;
}

/* misc */

void NSDecimalRound
(NSDecimal *result, const NSDecimal *n, int scale, NSRoundingMode rmode)
{
}

void NSDecimalCompact(NSDecimal *number)
{
}

void NSDecimalCopy(NSDecimal *dest, const NSDecimal *src)
{
	memcpy(dest, src, sizeof(NSDecimal));
}

NSCalculationError NSDecimalNormalize
(NSDecimal *number1, NSDecimal *number2, NSRoundingMode rmod)
{
	if (number1->exponent == number2->exponent)
		return NSCalculationOK;

	return NSCalculationNotImplemented;
}

NSString *NSDecimalString(const NSDecimal *_num, NSLocale *locale)
{
	TODO; // NSDecimalString()
	return nil;
}
