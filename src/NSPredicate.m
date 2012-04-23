/* 
   NSPredicate.m
 * All rights reserved.

   Copyright (C) 2010-2012	Justin Hibbits
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

#import <Foundation/NSDictionary.h>
#import <Foundation/NSIndexSet.h>
#import <Foundation/NSPredicate.h>
#import <Foundation/NSString.h>

@interface NSTruePredicate : NSPredicate
@end

@interface NSFalsePredicate : NSPredicate
@end

@interface NSBlockPredicate : NSPredicate
{
	bool (^block)(id, NSDictionary *);
	NSDictionary *substVars;
}
@end

@implementation NSPredicate

/* evaluation */

- (bool)evaluateWithObject:(id)_object
{
    [self subclassResponsibility:_cmd];
    return false;
}

/* Coding */

- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    return self;
}

/* Copying */

- (id)copyWithZone:(NSZone *)zone
{
    /* NSPredicate objects are immutable! */
    return self;
}

+ (NSPredicate *) predicateWithValue:(bool)val
{
	if (val)
		return [NSTruePredicate new];
	else
		return [NSFalsePredicate new];
}

- (NSString *) predicateFormat
{
	return [self subclassResponsibility:_cmd];
}

- (bool) evaluateWithObject:(id)obj substitutionVariables:(NSDictionary *)substVars
{
	return [[self predicateWithSubstitutionVariables:substVars] evaluateWithObject:obj];
}

- (NSPredicate *) predicateWithSubstitutionVariables:(NSDictionary *)vars
{
	return self;
}

+ (NSPredicate *) predicateWithBlock:(bool (^)(id, NSDictionary *))block
{
	return nil;
}
@end /* NSPredicate */


@implementation NSTruePredicate

/* evaluation */

- (bool)evaluateWithObject:(id)_object
{
    return true;
}

- (NSString *) predicateFormat
{
	return @"TRUEPREDICATE";
}

- (id) copyWithZone:(NSZone *)zone
{
	return self;
}

@end /* NSTruePredicate */

@implementation NSFalsePredicate

/* evaluation */

- (bool)evaluateWithObject:(id)_object
{
    return false;
}

- (NSString *) predicateFormat
{
	return @"FALSEPREDICATE";
}

- (id) copyWithZone:(NSZone *)zone
{
	return self;
}

@end /* NSFalsePredicate */

@implementation NSBlockPredicate

- (id) initWithBlock:(bool (^)(id, NSDictionary *))blk
{
	block = blk;
	return self;
}

- (bool) evaluateWithObject:(id)obj
{
	return block(obj, substVars);
}

- (id) predicateWithSubstitutionVariables:(NSDictionary *)substitutionVars
{
	NSBlockPredicate *other = [[NSBlockPredicate alloc] init];

	other->block = block;
	other->substVars = [substitutionVars copy];

	return other;
}

@end

@implementation NSArray(NSPredicate)

- (NSArray *)filteredArrayUsingPredicate:(NSPredicate *)_predicate
{
	NSMutableArray *array = nil;
	NSArray  *result;
	unsigned count;

	@autoreleasepool {
		count = [self count];
		array = [NSMutableArray arrayWithCapacity:count];
		for (id o in self)
		{
			if ([_predicate evaluateWithObject:o])
			{
				[array addObject:o];
			}
		}
		result = [array copy];
	}
	return result;
}

@end /* NSArray(NSPredicate) */

@implementation NSMutableArray(NSPredicate)

- (void)filterArrayUsingPredicate:(NSPredicate *)_predicate
{
	NSMutableIndexSet *indexes = [NSMutableIndexSet new];
	size_t count;

	@autoreleasepool {
		count = 0;
		for (id o in self)
		{
			if (![_predicate evaluateWithObject:o])
			{
				[indexes addIndex:count];
			}
			count++;
		}

		[self removeObjectsAtIndexes:indexes];
	}
}

@end /* NSMutableArray(NSPredicate) */


/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
 */
