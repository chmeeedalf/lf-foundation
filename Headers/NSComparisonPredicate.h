/* 
   NSComparisonPredicate.h

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

#ifndef __ComparisonPredicate_H__
#define __ComparisonPredicate_H__

#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSPredicate.h>

@class NSExpression;

typedef enum {
    NSDirectPredicateModifier = 0,
    NSAllPredicateModifier,
    NSAnyPredicateModifier
} NSComparisonPredicateModifier;

typedef enum {
    NSLessThanPredicateOperatorType = 0,
    NSLessThanOrEqualToPredicateOperatorType,
    NSGreaterThanPredicateOperatorType,
    NSGreaterThanOrEqualToPredicateOperatorType,
    NSEqualToPredicateOperatorType,
    NSNotEqualToPredicateOperatorType,
    NSMatchesPredicateOperatorType,
    NSLikePredicateOperatorType,
    NSBeginsWithPredicateOperatorType,
    NSEndsWithPredicateOperatorType,
    NSInPredicateOperatorType,
    NSCustomSelectorPredicateOperatorType,
    NSContainsPredicateOperatorType,
    NSBetweenPredicateOperatorType,
} NSPredicateOperatorType;

enum {
    NSCaseInsensitivePredicateOptions     = 0x01,
    NSDiacriticInsensitivePredicateOption = 0x02,
    NSNormalizedPredicateOption = 0x04,
    NSLocaleSensitivePredicateOption = 0x08,
};

typedef NSUInteger NSComparisonPredicateOptions;

@interface NSComparisonPredicate : NSPredicate
{
	NSExpression *lhs;
	NSExpression *rhs;
	NSPredicateOperatorType op;
	NSComparisonPredicateOptions options;
	NSComparisonPredicateModifier modifier;
	SEL          opSel;
}

+ (NSPredicate *)predicateWithLeftExpression:(NSExpression *)_lhs
  rightExpression:(NSExpression *)_rhs
  customSelector:(SEL)_selector;
+ (NSPredicate *)predicateWithLeftExpression:(NSExpression *)_lhs
  rightExpression:(NSExpression *)_rhs
  modifier:(NSComparisonPredicateModifier)_modifier
  type:(NSPredicateOperatorType)_type
  options:(unsigned)_options;

- (id)initWithLeftExpression:(NSExpression *)_lhs
  rightExpression:(NSExpression *)_rhs
  customSelector:(SEL)_selector;
- (id)initWithLeftExpression:(NSExpression *)_lhs
  rightExpression:(NSExpression *)_rhs
  modifier:(NSComparisonPredicateModifier)_modifier
  type:(NSPredicateOperatorType)_type
  options:(unsigned)_options;

/* accessors */

- (NSExpression *)leftExpression;
- (NSExpression *)rightExpression;

- (SEL)customSelector;

- (NSComparisonPredicateModifier)comparisonPredicateModifier;
- (NSPredicateOperatorType)predicateOperatorType;
- (NSComparisonPredicateOptions)options;

@end

#endif /* __ComparisonPredicate_H__ */

/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
*/
