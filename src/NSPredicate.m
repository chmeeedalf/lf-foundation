/* 
   NSPredicate.m

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

#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSIndexSet.h>
#import <Foundation/NSPredicate.h>
#import <Foundation/NSString.h>

@interface NSTruePredicate : NSPredicate
@end

@interface NSFalsePredicate : NSPredicate
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
    return [self retain];
}

+ (NSPredicate *) predicateWithValue:(bool)val
{
	if (val)
		return [[NSTruePredicate new] autorelease];
	else
		return [[NSFalsePredicate new] autorelease];
}

- (NSString *) predicateFormat
{
	return [self subclassResponsibility:_cmd];
}

- (bool) evaluateWithObject:(id)obj substitutionVariables:(NSDictionary *)substVars
{
	return [self evaluateWithObject:obj];
}

- (NSPredicate *) predicateWithSubstitutionVariables:(NSDictionary *)vars
{
	return self;
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
	return [self retain];
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
	return [self retain];
}

@end /* NSFalsePredicate */


@implementation NSArray(NSPredicate)

- (NSArray *)filteredArrayUsingPredicate:(NSPredicate *)_predicate
{
	NSAutoreleasePool *pool;
	NSMutableArray *array = nil;
	NSArray  *result;
	unsigned count;

	pool = [[NSAutoreleasePool alloc] init];

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
	[pool release];
	return [result autorelease];
}

@end /* NSArray(NSPredicate) */

@implementation NSMutableArray(NSPredicate)

- (void)filterArrayUsingPredicate:(NSPredicate *)_predicate
{
	NSAutoreleasePool *pool;
	NSMutableIndexSet *indexes = [NSMutableIndexSet new];
	size_t count;

	pool = [[NSAutoreleasePool alloc] init];

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
	[indexes release];
	[pool release];
}

@end /* NSMutableArray(NSPredicate) */


/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
*/
