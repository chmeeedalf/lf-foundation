/* 
   NSComparisonPredicate.m
 * All rights reserved.

   Copyright (C) 2010-2012, Justin Hibbits
   Copyright (C) 2005, Helge Hess
   All rights reserved.

   Author: Helge Hess <helge.hess@opengroupware.org>

   This file is part of libSystem.

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

#import <Foundation/NSComparisonPredicate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSExpression.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import "internal.h"

@implementation NSComparisonPredicate

+ (NSPredicate *)predicateWithLeftExpression:(NSExpression *)_lhs
  rightExpression:(NSExpression *)_rhs
  customSelector:(SEL)_selector
{
	return [[self alloc] initWithLeftExpression:_lhs rightExpression:_rhs
								  customSelector:_selector];
}

+ (NSPredicate *)predicateWithLeftExpression:(NSExpression *)_lhs
	rightExpression:(NSExpression *)_rhs
	modifier:(NSComparisonPredicateModifier)_modifier
	type:(NSPredicateOperatorType)_type
	options:(NSComparisonPredicateOptions)_options
{
	return [[self alloc] initWithLeftExpression:_lhs rightExpression:_rhs
										modifier:_modifier type:_type 
										 options:_options];
}

- (id)initWithLeftExpression:(NSExpression *)_lhs
	rightExpression:(NSExpression *)_rhs
	customSelector:(SEL)_selector
{
	if ((self = [super init]) != nil)
	{
		self->lhs      = _lhs;
		self->rhs      = _rhs;
		self->opSel = _selector;
		self->op = NSCustomSelectorPredicateOperatorType;
	}
	return self;
}

- (id)initWithLeftExpression:(NSExpression *)_lhs
	rightExpression:(NSExpression *)_rhs
	modifier:(NSComparisonPredicateModifier)_modifier
	type:(NSPredicateOperatorType)_type
	options:(NSComparisonPredicateOptions)_options
{
	NSAssert(_type != NSCustomSelectorPredicateOperatorType, @"NSPredicate type must not be custom selector.");
	lhs = _lhs;
	rhs = _rhs;
	modifier = _modifier;
	op = _type;
	options = _options;
	return self;
}

- (id)init
{
	return [self initWithLeftExpression:nil rightExpression:nil
						 customSelector:NULL];
}

/* accessors */

- (NSExpression *)leftExpression
{
	return self->lhs;
}
- (NSExpression *)rightExpression
{
	return self->rhs;
}

- (SEL)customSelector
{
	return self->opSel;
}

- (NSComparisonPredicateModifier)comparisonPredicateModifier
{
	return modifier;
}

- (NSPredicateOperatorType)predicateOperatorType
{
	return op;
}

- (NSComparisonPredicateOptions)options
{
	return options;
}

- (NSString *) predicateFormat
{
	NSString *mod = nil;
	NSString *compOp = nil;
	char opts[7] = "";

	switch (modifier)
	{
		case NSDirectPredicateModifier:
			mod = @"";
			break;
		case NSAnyPredicateModifier:
			mod = @"ANY ";
			break;
		case NSAllPredicateModifier:
			mod = @"ALL ";
			break;
	}

	switch (op)
	{
		case NSLessThanPredicateOperatorType:
			compOp = @"<";
			break;
		case NSLessThanOrEqualToPredicateOperatorType:
			compOp = @"<=";
			break;
		case NSGreaterThanPredicateOperatorType:
			compOp = @">";
			break;
		case NSGreaterThanOrEqualToPredicateOperatorType:
			compOp = @">=";
			break;
		case NSEqualToPredicateOperatorType:
			compOp = @"==";
			break;
		case NSNotEqualToPredicateOperatorType:
			compOp = @"!=";
			break;
		case NSMatchesPredicateOperatorType:
			compOp = @"MATCHES";
			break;
		case NSLikePredicateOperatorType:
			compOp = @"LIKE";
			break;
		case NSBeginsWithPredicateOperatorType:
			compOp = @"BEGINSWITH";
			break;
		case NSEndsWithPredicateOperatorType:
			compOp = @"ENDSWITH";
			break;
		case NSInPredicateOperatorType:
			compOp = @"IN";
			break;
		case NSCustomSelectorPredicateOperatorType:
			compOp = NSStringFromSelector(opSel);
			break;
		case NSContainsPredicateOperatorType:
			compOp = @"CONTAINS";
			break;
		case NSBetweenPredicateOperatorType:
			compOp = @"BETWEEN";
			break;
	}

	if (options != 0)
	{
		int i = 0;
		opts[i++] = '[';
		if (options & NSCaseInsensitivePredicateOptions)
		{
			opts[i++] = 'c';
		}
		if (options & NSDiacriticInsensitivePredicateOption)
		{
			opts[i++] = 'd';
		}
		if (options & NSNormalizedPredicateOption)
		{
			opts[i++] = 'n';
		}
		if (options & NSLocaleSensitivePredicateOption)
		{
			opts[i++] = 'l';
		}
		opts[i] = ']';
	}

	return [NSString stringWithFormat:@"%@%@ %@%s %@",
		   mod, lhs, compOp, opts, rhs];
}

- (bool) _evaluateStringWithLeft:(NSString *)lobj right:(NSString *)robj
{
	NSStringCompareOptions opts = 0;

	if (options & NSCaseInsensitivePredicateOptions)
	{
		opts |= NSCaseInsensitiveSearch;
	}
	if (options & NSDiacriticInsensitivePredicateOption)
	{
		opts |= NSDiacriticInsensitiveSearch;
	}
	if (options & NSNormalizedPredicateOption)
	{
		// Pre-normalized, so it's a literal search.
		opts &= ~(NSDiacriticInsensitiveSearch|NSCaseInsensitiveSearch);
	}
	if (options & NSLocaleSensitivePredicateOption)
	{
	
	}

	if (op == NSBeginsWithPredicateOperatorType)
	{
		opts |= NSAnchoredSearch;
	}
	if (op == NSEndsWithPredicateOperatorType)
	{
		opts |= (NSAnchoredSearch|NSBackwardsSearch);
	}
	if (op == NSLikePredicateOperatorType)
	{
		opts |= NSRegularExpressionSearch;
	}
	if (op == NSMatchesPredicateOperatorType)
	{
		opts |= NSRegularExpressionSearch;
	}

	/* If an IN predicate, swap the left and right operands. */
	if (op == NSInPredicateOperatorType)
	{
		id tmp = lobj;
		lobj = robj;
		robj = tmp;
	}

	NSComparisonResult r;
	switch (op)
	{
		case NSLessThanPredicateOperatorType:
		case NSLessThanOrEqualToPredicateOperatorType:
		case NSGreaterThanPredicateOperatorType:
		case NSGreaterThanOrEqualToPredicateOperatorType:
		case NSEqualToPredicateOperatorType:
			r = [lobj compare:robj options:opts range:NSMakeRange(0, [lobj length]) locale:nil];
			break;
		default:
			return (([lobj rangeOfString:robj options:opts range:NSMakeRange(0, [lobj length]) locale:nil]).location != NSNotFound);
			break;
	}

	switch (op)
	{
		case NSLessThanPredicateOperatorType:
			return (r == NSOrderedAscending);
		case NSLessThanOrEqualToPredicateOperatorType:
			return (r != NSOrderedDescending);
		case NSGreaterThanPredicateOperatorType:
			return (r == NSOrderedDescending);
		case NSGreaterThanOrEqualToPredicateOperatorType:
			return (r != NSOrderedAscending);
		case NSEqualToPredicateOperatorType:
			return (r == NSOrderedSame);
		case NSNotEqualToPredicateOperatorType:
			return (r != NSOrderedSame);
		default:
			return false;
	}
}

- (bool) _evaluateLeft:(id)lobj right:(id)robj
{
	if (op == NSCustomSelectorPredicateOperatorType)
		return ([lobj performSelector:opSel withObject:robj]);

	if ([lobj isKindOfClass:[NSString class]] && [robj isKindOfClass:[NSString class]])
	{
		return [self _evaluateStringWithLeft:lobj right:robj];
	}

	switch (op)
	{
		case NSLessThanPredicateOperatorType:
			{
				return ([lobj isLessThan:rhs]);
			}
			break;
		case NSLessThanOrEqualToPredicateOperatorType:
			{
				return ([lobj isLessThanOrEqualTo:rhs]);
			}
			break;
		case NSGreaterThanPredicateOperatorType:
			{
				return ([lobj isGreaterThan:rhs]);
			}
			break;
		case NSGreaterThanOrEqualToPredicateOperatorType:
			{
				return ([lobj isGreaterthanOrEqualto:rhs]);
			}
			break;
		case NSEqualToPredicateOperatorType:
			{
				return ([lobj isEqual:rhs]);
			}
			break;
		case NSNotEqualToPredicateOperatorType:
			{	
				return (![lobj isEqual:rhs]);
			}
			break;
		case NSMatchesPredicateOperatorType:
		case NSLikePredicateOperatorType:
		case NSBeginsWithPredicateOperatorType:
		case NSEndsWithPredicateOperatorType:
			@throw [NSInvalidArgumentException exceptionWithReason:@"Attempting to use a String predicate with non-string operands." userInfo:[NSDictionary dictionaryWithObjectsAndKeys:lhs,@"LeftExpression",rhs,@"RightExpression",nil]];
			break;
		case NSInPredicateOperatorType:
			{
				NSAssert([robj respondsToSelector:@selector(objectEnumerator)], @"Right expression must evaluate to a collection, or both expressions must be strings for an 'IN' predicate operation.");
				if ([lobj isKindOfClass:[NSString class]])
				{
					// String check.
				}
			}
			break;
		case NSContainsPredicateOperatorType:
			{
				return ([lobj containsObject:robj]);
			}
			break;
		case NSBetweenPredicateOperatorType:
			{
			}
			break;
		default:
			break;
	}
	return false;
}

- (bool) _evaluateObject:(id)obj left:(id)left right:(id)right
{
	NSMutableDictionary *ctx = [NSMutableDictionary new];
	id lobj = [left expressionValueWithObject:obj context:ctx];
	id robj = [right expressionValueWithObject:obj context:ctx];

	if (modifier == NSDirectPredicateModifier)
	{
		return [self _evaluateLeft:lobj right:robj];
	}
	else
	{
		bool baseline = (modifier == NSAllPredicateModifier);
		NSAssert ([lobj respondsToSelector:@selector(objectEnumerator:)] || [lobj conformsToProtocol:@protocol(NSFastEnumeration)], @"Left side of predicate must be a collection.");

		/* Use fast enumeration where possible. */
		id enumerator = lobj;
		if (![lobj conformsToProtocol:@protocol(NSFastEnumeration)])
			enumerator = [lobj objectEnumerator];

		for (id o in enumerator)
		{
			if ([self _evaluateLeft:o right:robj] != baseline)
				return !baseline;
		}
		return baseline;
	}
}

- (bool) evaluateWithObject:(id)obj substitutionVariables:(NSDictionary *)subVars
{
	id lobj = [lhs _expressionWithSubstitutionVariables:subVars];
	id robj = [rhs _expressionWithSubstitutionVariables:subVars];

	return [self _evaluateObject:obj left:lobj right:robj];
}

- (bool) evaluateWithObject:(id)obj
{
	return [self _evaluateObject:obj left:lhs right:rhs];
}

@end /* NSComparisonPredicate */

/*
	Local Variables:
	c-basic-offset: 4
	tab-width: 8
	End:
 */
