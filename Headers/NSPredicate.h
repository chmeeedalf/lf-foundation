/* 
   NSPredicate.h
 * All rights reserved.

   Copyright (C) 2010-2012	Justin Hibbits
   Copyright (C) 2005, Helge Hess
   All rights reserved.

   Author: Helge Hess <helge.hess@opengroupware.org>

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

#ifndef __Predicate_H__
#define __Predicate_H__

#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSSet.h>

@class NSArray, NSMutableArray, NSDictionary, NSSet, NSMutableSet;

@interface NSPredicate : NSObject < NSCoding, NSCopying >
{
}
+ (NSPredicate *)predicateWithValue:(bool)value;
- (NSPredicate *)predicateWithSubstitutionVariables:(NSDictionary *)variables;

/* evaluation */

- (bool)evaluateWithObject:(id)_object;
- (bool)evaluateWithObject:(id)_object substitutionVariables:(NSDictionary *)subVar;

- (NSString *) predicateFormat;
@end

@interface NSPredicate(Parsing)
+ (NSPredicate *)predicateWithFormat:(NSString *)_format,...;
+ (NSPredicate *)predicateWithFormat:(NSString *)format arguments:(va_list)argList;
+ (NSPredicate *)predicateWithFormat:(NSString *)_format 
  argumentArray:(NSArray *)_arguments;
@end

#include <Foundation/NSArray.h>

@interface NSArray(NSPredicate)
- (NSArray *)filteredArrayUsingPredicate:(NSPredicate *)_predicate;
@end

@interface NSMutableArray(NSPredicate)
- (void)filterArrayUsingPredicate:(NSPredicate *)_predicate;
@end

@interface NSSet(NSPredicate)
- (NSSet *)filteredSetUsingPredicate:(NSPredicate *)_predicate;
@end

@interface NSMutableSet(NSPredicate)
- (void)filterUsingPredicate:(NSPredicate *)_predicate;
@end
#endif /* __Predicate_H__ */

/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
 */
