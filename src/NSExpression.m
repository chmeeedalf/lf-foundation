/*
 * Copyright (c) 2010-2012	Gold Project
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

#include <math.h>
#include <stdlib.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSExpression.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSObjCRuntime.h>
#import "internal.h"

/*!
 * \file NSExpression.h
 */
@class NSArray, NSEnumerator, NSSet, NSString;

/*
 * Grouping class interface&implementations together for the concrete classes.
 * This should make it easier to read the file.
 */

@interface _AggregateExpression : NSExpression /* {{{ */
{
	id collection;
}
- initWithCollection:(id)collection;
@end
@implementation _AggregateExpression
- initWithCollection:(id)coll
{
	self = [super initWithExpressionType:NSAggregateExpressionType];
	if (self == nil)
		return nil;
	if ([coll isKindOfClass:[NSArray class]] ||
		[coll isKindOfClass:[NSSet class]] ||
		[coll isKindOfClass:[NSDictionary class]])
	{
		collection = coll;
	}
	else
	{
		self = nil;
	}
	return self;
}

- (id)collection
{
	return collection;
}

- (id) expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
	if ([collection isKindOfClass:[NSArray class]] || [collection isKindOfClass:[NSSet class]])
	{
		// Create a mutable copy of an empty instance of the collection's class.
		// This way if it's a set we get a set, and if it's an array we get an
		// array, without hard coding it.
		return [[collection map] expressionValueWithObject:object context:context];
	}
	else
	{
		id retExpr = [NSMutableDictionary new];
		for (id i in collection)
		{
			id key = [i expressionValueWithObject:object context:context];
			id value = [[collection valueForKey:i] expressionValueWithObject:object context:context];
			[retExpr setObject:value forKey:key];
		}
		return retExpr;
	}
}

- (id) _expressionWithSubstitutionVariables:(NSDictionary *)subVars
{
	id retExpr;
	if ([collection isKindOfClass:[NSArray class]] || [collection isKindOfClass:[NSSet class]])
	{
		// Create a mutable copy of an empty instance of the collection's class.
		// This way if it's a set we get a set, and if it's an array we get an
		// array, without hard coding it.
		id retColl = [[collection map] _expressionWithSubstitutionVariables:subVars];
		retExpr = [NSExpression expressionForAggregate:retColl];
	}
	else
	{
		id retColl = [NSMutableDictionary new];
		for (id i in collection)
		{
			id key = [i _expressionWithSubstitutionVariables:subVars];
			id value = [[collection valueForKey:i] _expressionWithSubstitutionVariables:subVars];
			[retColl setObject:value forKey:key];
		}
		retExpr = [NSExpression expressionForAggregate:retColl];
	}
	return retExpr;
}
@end /* }}} */

@interface _ConstantValueExpression	:	NSExpression/*{{{*/
{
	id value;
}
- initWithConstantValue:(id)value;
@end

@implementation _ConstantValueExpression
- initWithConstantValue:(id)val
{
	self = [super initWithExpressionType:NSEvaluatedObjectExpressionType];
	if (self == nil)
		return nil;
	value = val;
	return self;
}

- constantValue
{
	return value;
}

- expressionValueWithObject:object context:(NSMutableDictionary *)context
{
	return value;
}
@end/*}}}*/

@interface _KeyPathExpression	:	NSExpression/*{{{*/
{
	NSString *keyPath;
}
@end
@implementation _KeyPathExpression
- initWithKeyPath:(NSString *)path
{
	if ((self = [super initWithExpressionType:NSKeyPathExpressionType]) == nil)
		return nil;

	keyPath = [path copy];
	return self;
}

- expressionValueWithObject:(id)obj context:(NSMutableDictionary *)context
{
	return [obj valueForKeyPath:keyPath];
}

- (NSString *)keyPath
{
	return keyPath;
}
@end/*}}}*/

@interface _SelfExpression	:	NSExpression/*{{{*/
@end

@implementation _SelfExpression
- init
{
	self = [super initWithExpressionType:NSEvaluatedObjectExpressionType];
	return self;
}

- expressionValueWithObject:object context:(NSMutableDictionary *)context
{
	return object;
}
@end/*}}}*/

@interface _FunctionExpressionTarget	:	NSExpression/*{{{*/
{
}
@end
@implementation _FunctionExpressionTarget
- (NSNumber *) average:(NSArray *)arg
{
	int count = [arg count];
	double total = 0;

	for (NSNumber *n in arg)
	{
		total += ([n doubleValue] / count);
	}
	return [NSNumber numberWithDouble:total];
}
- (NSNumber *) sum:(NSArray *)arg
{
	double total = 0;

	for (NSNumber *n in arg)
	{
		total += [n doubleValue];
	}
	return [NSNumber numberWithDouble:total];
}

- (NSNumber *) count:(NSArray *)arg
{
	return [NSNumber numberWithLongLong:[arg count]];
}

- (NSNumber *) max:(NSArray *)arg
{
	NSNumber *curMax = [arg firstObject];

	for (NSNumber *n in arg)
	{
		if ([n isGreaterThan:curMax])
		{
			curMax = n;
		}
	}
	return curMax;
}

- (NSNumber *) min:(NSArray *)arg
{
	NSNumber *curMax = [arg firstObject];

	for (NSNumber *n in arg)
	{
		if ([n isLessThan:curMax])
		{
			curMax = n;
		}
	}
	return curMax;
}

- (NSNumber *) mode:(NSArray *)arg
{
	NSCountedSet *s = [[NSCountedSet alloc] initWithCapacity:[arg count]];
	NSNumber *mode = 0;
	size_t mode_count = 0;
	NSNumber *n;

	for (n in arg)
		[s addObject:n];

	for (n in s)
	{
		if ([s countForObject:n] > mode_count)
		{
			mode = n;
			mode_count = [s countForObject:n];
		}
	}

	return mode;
}

- (NSNumber *) stddev:(NSArray *)arg
{
	double avg = [[self average:arg] doubleValue];
	double total = 0;

	for (NSNumber *n in arg)
	{
		double tmp = [n doubleValue] - avg;
		total += tmp * tmp;
	}
	total /= [arg count];
	total = sqrt(total);
	return [NSNumber numberWithDouble:total];
}

- (NSNumber *) add:(NSNumber *)a to:(NSNumber *)b
{
	return [NSNumber numberWithDouble:([a doubleValue] + [b doubleValue])];
}

- (NSNumber *) from:(NSNumber *)a subtract:(NSNumber *)b
{
	return [NSNumber numberWithDouble:([a doubleValue] - [b doubleValue])];
}

- (NSNumber *) multiply:(NSNumber *)a by:(NSNumber *)b
{
	return [NSNumber numberWithDouble:([a doubleValue] * [b doubleValue])];
}

- (NSNumber *) divide:(NSNumber *)a by:(NSNumber *)b
{
	return [NSNumber numberWithDouble:([a doubleValue] / [b doubleValue])];
}

- (NSNumber *) modulus:(NSNumber *)a by:(NSNumber *)b
{
	return [NSNumber numberWithDouble:fmod([a doubleValue], [b doubleValue])];
}

- (NSNumber *) raise:(NSNumber *)a toPower:(NSNumber *)b
{
	return [NSNumber numberWithDouble:pow([a doubleValue], [b doubleValue])];
}

- (NSNumber *) sqrt:(NSNumber *)a
{
	return [NSNumber numberWithDouble:sqrt([a doubleValue])];
}

- (NSNumber *) log:(NSNumber *)a
{
	return [NSNumber numberWithDouble:log10([a doubleValue])];
}

- (NSNumber *) ln:(NSNumber *)a
{
	return [NSNumber numberWithDouble:log([a doubleValue])];
}

- (NSNumber *) exp:(NSNumber *)a
{
	return [NSNumber numberWithDouble:exp([a doubleValue])];
}

- (NSNumber *) trunc:(NSNumber *)a
{
	return [NSNumber numberWithDouble:trunc([a doubleValue])];
}

- (NSNumber *) abs:(NSNumber *)a
{
	return [NSNumber numberWithDouble:fabs([a doubleValue])];
}

- (NSNumber *) random
{
	return [NSNumber numberWithInt:rand()];
}

- (NSNumber *) random:(NSNumber *)a
{
	return [NSNumber numberWithInt:(rand() % [a longValue])];
}

- (NSDate *) now
{
	return [NSDate date];
}

- (id) expressionValueWithObject:(id)obj context:(NSMutableDictionary *)context
{
	return self;
}
@end
@interface _FunctionExpression	:	NSExpression
{
	NSExpression *target;
	SEL selector;
	NSArray *arguments;
}
- initWithOperand:(id)op selector:(SEL)sel arguments:(NSArray *)args;
@end
@implementation _FunctionExpression
- initWithOperand:(id)op selector:(SEL)sel arguments:(NSArray *)args
{
	if ((self = [super initWithExpressionType:NSFunctionExpressionType]) == nil)
		return nil;
	target = op;
	selector = sel;
	arguments = args;
	return self;
}

- expressionValueWithObject:(id)obj context:(NSMutableDictionary*)context
{
	id t = [target expressionValueWithObject:obj context:context];
	Method m = class_getInstanceMethod(t, selector);
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(m)]];
	int count = [arguments count];
	int i = 0;
	[inv setTarget:t];
	[inv setSelector:selector];
	for (i = 0; i < count; i++)
	{
		[inv setArgument:(__bridge void *)[[arguments objectAtIndex:i] expressionValueWithObject:obj context:context] atIndex:i+2];
	}
	if (i < [[inv methodSignature] numberOfArguments])
	{
		for (int j = [[inv methodSignature] numberOfArguments]; j > i+2; j--)
		{
			[inv setArgument:nil atIndex:j];
		}
	}
	[inv invoke];

	id retval;
	[inv getReturnValue:&retval];
	return retval;
}

- _expressionWithSubstitutionVariables:(NSDictionary *)subVars
{
	id t = [target _expressionWithSubstitutionVariables:subVars];
	id args = [[arguments map] _expressionWithSubstitutionVariables:subVars];

	return [NSExpression expressionForFunction:t selectorName:NSStringFromSelector(selector) arguments:args];
}

- (NSString *) function
{
	return NSStringFromSelector(selector);
}

- (NSArray *) arguments
{
	return arguments;
}

@end/*}}}*/

@interface _VariableExpression	:	NSExpression/*{{{*/
{
	NSString *variable;
}
- initWithVariable:(NSString *)var;
@end
@implementation _VariableExpression
- initWithVariable:(NSString *)var
{
	if ((self = [super initWithExpressionType:NSVariableExpressionType]) == nil)
		return nil;
	variable = [var copy];
	return self;
}

- _expressionWithSubstitutionVariables:(NSDictionary *)substVars
{
	return [NSExpression expressionForConstantValue:[substVars objectForKey:variable]];
}

- expressionValueWithObject:(id)obj context:(NSMutableDictionary *)context
{
	return [context valueForKey:variable];
}

@end/*}}}*/

@interface _SetExpression	:	NSExpression/*{{{*/
{
	NSExpression *left;
	NSExpression *right;
}
- initWithExpressionType:(NSExpressionType)t left:(NSExpression *)l right:(NSExpression *)r;
@end
@implementation _SetExpression
- initWithExpressionType:(NSExpressionType)t left:(NSExpression *)l right:(NSExpression *)r
{
	if ((self = [super initWithExpressionType:t]) == nil)
		return nil;
	left = l;
	right = r;
	return self;
}

- leftExpression
{
	return left;
}

- rightExpression
{
	return right;
}

- expressionValueWithObject:(id)obj context:(NSMutableDictionary *)context
{
	NSMutableSet *l = [[left expressionValueWithObject:obj context:context] mutableCopy];
	NSSet *r = [right expressionValueWithObject:obj context:context];

	switch (expressionType)
	{
		case NSIntersectSetExpressionType:
			[l intersectSet:r];
			break;
		case NSMinusSetExpressionType:
			[l minusSet:r];
			break;
		case NSUnionSetExpressionType:
			[l unionSet:r];
			break;
		default:
			break;
	}
	return l;
}
@end/*}}}*/

@implementation NSExpression

+ expressionForConstantValue:value
{
	return [[_ConstantValueExpression alloc] initWithConstantValue:value];
}

+ expressionForEvaluatedObject
{
	return [[_SelfExpression alloc] init];
}

+ expressionForKeyPath:(NSString *)keyPath
{
	return [[_KeyPathExpression alloc] initWithKeyPath:keyPath];
}

+ expressionForVariable:(NSString *)variable
{
	return [[_VariableExpression alloc] initWithVariable:variable];
}

+ expressionForAggregate:(NSArray *)aggregate
{
	return [[_AggregateExpression alloc] initWithCollection:aggregate];
}

+ expressionForUnionSet:(NSExpression *)left with:(NSExpression *)right
{
	return [[_SetExpression alloc] initWithExpressionType:NSUnionSetExpressionType left:left right:right];
}

+ expressionForIntersectSet:(NSExpression *)left with:(NSExpression *)right
{
	return [[_SetExpression alloc] initWithExpressionType:NSIntersectSetExpressionType left:left right:right];
}

+ expressionForMinusSet:(NSExpression *)left with:(NSExpression *)right
{
	return [[_SetExpression alloc] initWithExpressionType:NSMinusSetExpressionType left:left right:right];
}

+ expressionForSubquery:(NSExpression *)expr usingIteratorVariable:(NSString *)var predicate:(id)pred
{
	TODO;
	return nil;
}

+ expressionForFunction:(NSString *)func arguments:(NSArray *)args
{
	NSExpression *e = [_FunctionExpressionTarget new];
	NSExpression *fe = [self expressionForFunction:e selectorName:func arguments:args];
	return fe;
}

+ expressionForFunction:(NSExpression *)target selectorName:(NSString *)sel arguments:(NSArray *)args
{
	NSParameterAssert(NSSelectorFromString(sel) != NULL);
	SEL s = NSSelectorFromString(sel);
	return [[_FunctionExpression alloc] initWithOperand:target selector:s arguments:args];
}

- initWithExpressionType:(NSExpressionType)type
{
	expressionType = type;
	return self;
}

- _expressionWithSubstitutionVariables:(NSDictionary *)substVars
{
	return self;
}

- (NSArray *)arguments
{
	return [self subclassResponsibility:_cmd];
}

- (id)collection
{
	return [self subclassResponsibility:_cmd];
}

- (id) constantValue
{
	return [self subclassResponsibility:_cmd];
}

- (NSExpressionType) expressionType
{
	return expressionType;
}

- expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
	return [self subclassResponsibility:_cmd];
}

- (NSString *)function
{
	return [self subclassResponsibility:_cmd];
}

- (NSString *)keyPath
{
	return [self subclassResponsibility:_cmd];
}

- (NSExpression *)leftExpression
{
	return [self subclassResponsibility:_cmd];
}

- (NSExpression *)operand
{
	return [self subclassResponsibility:_cmd];
}

- (NSPredicate *)predicate
{
	return [self subclassResponsibility:_cmd];
}

- (NSExpression *)rightExpression
{
	return [self subclassResponsibility:_cmd];
}

- (NSString *) variable
{
	return [self subclassResponsibility:_cmd];
}

@end

/*
  vim:foldmethod=marker:
 */
