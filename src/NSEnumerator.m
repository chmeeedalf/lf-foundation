/*
   NSEnumerator.m

   Copyright (C) 2005 Gold Project.
   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Justin Hibbits <jrh29@po.cwru.edu>
   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

   This file is from libFoundation, now part of the System framework.

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

#import <Foundation/NSEnumerator.h>
#import <Foundation/NSArray.h>

@implementation NSEnumerator

- nextObject
{
    [self subclassResponsibility:_cmd];
    return self;
}

- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackBuf count:(unsigned long)len
{
	int i = 0;
	if (state->state == 0)
	{
		state->state = 1;
	}
	state->itemsPtr = stackBuf;
	for (i = 0; i < len; i++)
	{
		id obj = [self nextObject];
		if (obj == nil)
			break;
		stackBuf[i] = obj;
	}
	state->mutationsPtr = (unsigned long *)self;
	return i;
}

- (NSArray *) allObjects
{
	NSMutableArray *a = [NSMutableArray new];
	id obj;

	while ((obj = [self nextObject]) != nil)
	{
		[a addObject:obj];
	}

	if ([a count] == 0)
	{
		[a release];
		return nil;
	}
	else
	{
		[a autorelease];
		return a;
	}
}
@end
