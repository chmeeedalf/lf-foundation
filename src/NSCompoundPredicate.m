/* 
   NSCompoundPredicate.m

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

#import <Foundation/NSCompoundPredicate.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSString.h>

@implementation NSCompoundPredicate

+ (NSPredicate *)andPredicateWithSubpredicates:(NSArray *)_subs
{
	return [[[self alloc] initWithType:NSAndPredicateType subpredicates:_subs]
		autorelease];
}
+ (NSPredicate *)orPredicateWithSubpredicates:(NSArray *)_subs
{
	return [[[self alloc] initWithType:NSOrPredicateType subpredicates:_subs]
		autorelease];
}
+ (NSPredicate *)notPredicateWithSubpredicate:(NSPredicate *)_subs
{
	return [[[self alloc] initWithType:NSNotPredicateType subpredicates:[NSArray arrayWithObject:_subs]] 
		autorelease];
}

- (id)initWithType:(NSCompoundPredicateType)_type subpredicates:(NSArray *)_s
{
	if ((self = [super init]) != nil)
	{
		type = _type;
		subs = [_s copy];
	}
	return self;
}
- (id)init
{
	return [self initWithType:NSNotPredicateType subpredicates:nil];
}

- (void)dealloc
{
	[self->subs release];
	[super dealloc];
}

/* accessors */

- (NSCompoundPredicateType)compoundPredicateType
{
	return self->type;
}

- (NSArray *)subpredicates
{
	return self->subs;
}

/* evaluation */

- (bool)evaluateWithObject:(id)_object
{
	for (id obj in subs)
	{
		bool ok;

		ok = [obj evaluateWithObject:_object];

		/* Note: we treat NOT as a "AND (NOT x)*" */
		if (self->type == NSNotPredicateType)
			ok = ok ? false : true;

		if (self->type == NSOrPredicateType)
		{
			if (ok) return true; /* short circuit */
		}
		else { /* AND or AND-NOT */
			if (!ok)
				return false; /* short circuit */
		}
	}

	return true; /* TOD: empty == true? */
}

- (bool) evaluateWithObject:(id)obj substitutionVariables:(NSDictionary *)subVars
{
	for (id sub in subs)
	{
		bool ok;

		ok = [sub evaluateWithObject:obj substitutionVariables:subVars];

		/* Note: we treat NOT as a "AND (NOT x)*" */
		if (self->type == NSNotPredicateType)
			ok = ok ? false : true;

		if (self->type == NSOrPredicateType)
		{
			if (ok) return true; /* short circuit */
		}
		else { /* AND or AND-NOT */
			if (!ok)
				return false; /* short circuit */
		}
	}

	return true; /* TOD: empty == true? */
}

- (NSPredicate *) predicateWithSubstitutionVariables:(NSDictionary *)subVars
{
	id newsubs = [[subs map] predicateWithSubstitutionVariables:subVars];
	return [[[NSCompoundPredicate alloc] initWithType:type subpredicates:newsubs] autorelease];
}

- (NSString *) predicateFormat
{
	switch (type)
	{
		case NSNotPredicateType:
			{
				return [NSString stringWithFormat:@"NOT(%@)",[subs objectAtIndex:0]];
			}
		case NSOrPredicateType:
			{
				if ([subs count] == 1)
				{
					return [[subs objectAtIndex:0] predicateFormat];
				}
				else
				{
					NSMutableArray *joiner = [NSMutableArray new];
					for (id obj in subs)
					{
						[joiner addObject:[obj predicateFormat]];
					}
					id retval = [NSString stringWithFormat:@"(%@)",[joiner componentsJoinedByString:@") OR ("]];
					[joiner release];
					return retval;
				}
			}
		case NSAndPredicateType:
			{
				if ([subs count] == 1)
				{
					return [[subs objectAtIndex:0] predicateFormat];
				}
				else
				{
					NSMutableArray *joiner = [NSMutableArray new];
					for (id obj in subs)
					{
						[joiner addObject:[obj predicateFormat]];
					}
					id retval = [NSString stringWithFormat:@"(%@)",[joiner componentsJoinedByString:@") AND ("]];
					[joiner release];
					return retval;
				}
			}
		default:
			break;
	}
	return nil;
}

/* Coding */

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeValueOfObjCType:@encode(int) at:&(self->type)];
	[aCoder encodeObject:self->subs];
}
- (id)initWithCoder:(NSCoder*)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]) != nil)
	{
	 [aDecoder decodeValueOfObjCType:@encode(int) at:&(self->type)];
	 self->subs = [[aDecoder decodeObject] retain];
	}
	return self;
}

@end /* NSCompoundPredicate */

/*
   Local Variables:
	c-basic-offset: 4
		 tab-width: 8
			   End:
			   */
