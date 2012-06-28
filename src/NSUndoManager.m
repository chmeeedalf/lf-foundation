/*
 * Copyright (c) 2010-2012	Justin Hibbits
 * All rights reserved.
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
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSUndoManager.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSValue.h>
#import "internal.h"

@class NSArray, NSMutableArray;
NSString * const  NSUndoManagerCheckpointNotification = @"NSUndoManagerCheckpointNotification";

NSString * const  NSUndoManagerDidOpenUndoGroupNotification = @"NSUndoManagerDidOpenUndoGroupNotification";
NSString * const  NSUndoManagerWillCloseUndoGroupNotification = @"NSUndoManagerWillCloseUndoGroupNotification";
NSString * const  NSUndoManagerDidCloseUndoGroupNotification = @"NSUndoManagerDidCloseUndoGroupNotification";

NSString * const  NSUndoManagerWillUndoChangeNotification = @"NSUndoManagerWillUndoChangeNotification";
NSString * const  NSUndoManagerDidUndoChangeNotification = @"NSUndoManagerDidUndoChangeNotification";

NSString * const  NSUndoManagerWillRedoChangeNotification = @"NSUndoManagerWillRedoChangeNotification";
NSString * const  NSUndoManagerDidRedoChangeNotification = @"NSUndoManagerDidRedoChangeNotification";

NSString * const  NSUndoManagerGroupIsDiscardableKey = @"NSUndoManagerGroupIsDiscardableKey";

@interface NSPrivateUndoGroup	:	NSObject
{
@package
	bool                isDiscardable;
	NSPrivateUndoGroup *parent;
	NSString           *title;
	NSMutableArray     *actions;
}

- (id) initWithParent:(NSPrivateUndoGroup *)parent;
- (void) setActionIsDiscardable:(bool)discard;
- (bool) discardable;
- (void) setActionName:(NSString *)name;
- (NSString *) name;
- (NSPrivateUndoGroup *) parent;
- (void) addInvocation:(NSInvocation *)inv;
- (void) perform;
- (void) setParent:(NSPrivateUndoGroup *)newParent;
- (NSUInteger) actionCount;
- (NSArray *) actions;
@end

@implementation NSPrivateUndoGroup
- (id) initWithParent:(NSPrivateUndoGroup *)parentGroup
{
	if ((self = [super init]) == nil)
		return nil;
	actions = [NSMutableArray new];
	parent = parentGroup;
	return self;
}

- (void) setActionIsDiscardable:(bool)discardable
{
	isDiscardable = discardable;
}

- (bool) discardable
{
	return isDiscardable;
}

- (void) setActionName:(NSString *)name
{
	title = [name copy];
}

- (NSString *) name
{
	return title;
}

- (NSPrivateUndoGroup *) parent
{
	return parent;
}

- (void) setParent:(NSPrivateUndoGroup *)newParent
{
	parent = newParent;
}

- (void) removeAllActionsWithTarget:(id)target
{
	for (NSUInteger i = [actions count]; i > 0; --i)
	{
		if ([[actions objectAtIndex:i - 1] target] == target)
		{
			NSInvocation *inv = [actions objectAtIndex:i - 1];
			[actions removeObjectAtIndex:i - 1];
			id obj;

			[inv getArgument:&obj atIndex:2];
		}
	}
}

- (void) addInvocation:(NSInvocation *)inv
{
	[actions addObject:inv];
}

- (NSUInteger) actionCount
{
	return [actions count];
}

- (void) perform
{
	for (NSInvocation *inv in [actions reverseObjectEnumerator])
		[inv invoke];
}

- (NSArray *) actions
{
	return actions;
}
@end

@implementation NSUndoManager
{
	NSMutableArray *redoActions;
	NSMutableArray *undoActions;
	NSArray *modes;
	NSUInteger disableCount;
	id undoTarget;
	id currentGroup;
	NSUInteger groupingLevel;
	NSUInteger levelsOfUndo;
	bool groupsByEvent;
	bool undoing;
	bool redoing;
}

- (void) _loop:(id)ignore
{
	if ([self groupsByEvent])
	{
		[self endUndoGrouping];
		[self beginUndoGrouping];
		[[NSRunLoop currentRunLoop] performSelector:@selector(_loop:)
											 target:self
										   argument:nil
											  order:NSUndoCloseGroupingRunLoopOrdering
											  modes:modes];
	}
}

- (id) init
{
	[self setRunLoopModes:@[NSDefaultRunLoopMode]];
	return self;
}

-(void)registerUndoWithTarget:(id)target selector:(SEL)selector object:(id)object
{
	if (disableCount > 0)
		return;

	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:selector]];
	[inv setTarget:target];
	[inv setSelector:selector];
	[inv setArgument:(__bridge_retained void *)object atIndex:2];
	
	[currentGroup addInvocation:inv];
	if (![self isUndoing] && ![self isRedoing])
		[redoActions removeAllObjects];
}

-(id)prepareWithInvocationTarget:(id)target
{
	undoTarget = target;
	return self;
}


-(bool)canUndo
{
	return ([undoActions count] > 0);
}

-(bool)canRedo
{
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:NSUndoManagerCheckpointNotification object:self];
	return ([redoActions count] > 0);
}


-(void)undo
{
	NSAssert([self groupingLevel] <= 1, @"Cannot undo while inside a nested group");
	if ([self groupingLevel] == 1)
	{
		[self endUndoGrouping];
	}
	[self undoNestedGroup];
}

-(void)undoNestedGroup
{
	NSAssert(!undoing && !redoing, @"Cannot undo while already undoing or redoing");
    if (currentGroup != nil)
		@throw [NSInternalInconsistencyException
			exceptionWithReason:@"undoNestedGroup called with open nested group"
					   userInfo:nil];

	[[NSNotificationCenter defaultCenter] postNotificationName:NSUndoManagerCheckpointNotification object:self];
	undoing = true;
	if ([undoActions count] > 0)
	{
		NSString *name;
		NSPrivateUndoGroup *undoGroup;

		[[NSNotificationCenter defaultCenter] postNotificationName:NSUndoManagerWillUndoChangeNotification object:self];
		
		undoGroup = [undoActions lastObject];
		[undoActions removeLastObject];
		name = [undoGroup name];
		[self beginUndoGrouping];
		[undoGroup perform];
		[self endUndoGrouping];
		[[undoActions lastObject] setActionName:name];

		[[NSNotificationCenter defaultCenter] postNotificationName:NSUndoManagerDidUndoChangeNotification object:self];
	}
}

-(void)redo
{
	NSAssert(!undoing && !redoing, @"Cannot redo while already undoing or redoing");
	[[NSNotificationCenter defaultCenter] postNotificationName:NSUndoManagerCheckpointNotification object:self];
	redoing = true;
	if ([redoActions count] > 0)
	{
		NSString *name;
		NSPrivateUndoGroup *redoGroup;
		NSPrivateUndoGroup *savedGroup;

		[[NSNotificationCenter defaultCenter] postNotificationName:NSUndoManagerWillRedoChangeNotification object:self];
		
		redoGroup = [redoActions lastObject];
		[redoActions removeLastObject];
		name = [redoGroup name];
		savedGroup = currentGroup;
		currentGroup = [[NSPrivateUndoGroup alloc] initWithParent:nil];
		[redoGroup perform];
		[self endUndoGrouping];
		[[undoActions lastObject] setActionName:name];
		currentGroup = savedGroup;

		[[NSNotificationCenter defaultCenter] postNotificationName:NSUndoManagerDidRedoChangeNotification object:self];
	}
}


-(void)setLevelsOfUndo:(NSUInteger)levels
{
	levelsOfUndo = levels;
	if (levelsOfUndo > 0)
	{
		if ([undoActions count] > levels)
		{
			[undoActions removeObjectsInRange:NSMakeRange(0, [undoActions count] - levels)];
		}
		if ([redoActions count] > levels)
		{
			[redoActions removeObjectsInRange:NSMakeRange(0, [redoActions count] - levels)];
		}
	}
}

-(NSUInteger)levelsOfUndo
{
	return levelsOfUndo;
}


-(void)beginUndoGrouping
{
	if (![self isUndoing])
		[[NSNotificationCenter defaultCenter] postNotificationName:NSUndoManagerCheckpointNotification object:self];
	groupingLevel++;
	currentGroup = [[NSPrivateUndoGroup alloc] initWithParent:currentGroup];
	[[NSNotificationCenter defaultCenter] postNotificationName:NSUndoManagerDidOpenUndoGroupNotification object:self];
}

-(void)endUndoGrouping
{
	NSAssert(currentGroup != nil, @"endUndoGrouping called without a paired beginUndoGrouping");
	[[NSNotificationCenter defaultCenter] postNotificationName:NSUndoManagerCheckpointNotification object:self];
	id parent = [currentGroup parent];
	if ([[currentGroup actions] count] > 0)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:NSUndoManagerWillUndoChangeNotification object:self userInfo:@{ NSUndoManagerWillCloseUndoGroupNotificationKey : @(true)}];
	}

	if (parent != nil)
	{
		for (id inv in [currentGroup actions])
			[parent addInvocation:inv];
		if ([parent discardable])
			[parent setActionIsDiscardable:[currentGroup discardable]];
	}
	else
	{
		NSMutableArray *stack;
		if (!undoing)
		{
			stack = undoActions;
		}
		else
		{
			stack = redoActions;
		}
		[stack addObject:currentGroup];
		if ([stack count] > levelsOfUndo)
			[stack removeObjectAtIndex:0];
	}
	currentGroup = parent;
	groupingLevel--;
	[[NSNotificationCenter defaultCenter] postNotificationName:NSUndoManagerDidCloseUndoGroupNotification object:self];
}

-(bool)groupsByEvent
{
	return groupsByEvent;
}

-(void)setGroupsByEvent:(bool)flag
{
	groupsByEvent = flag;
	if (groupsByEvent)
	{
		[[NSRunLoop currentRunLoop] performSelector:@selector(_loop:)
											 target:self
										   argument:nil
											  order:NSUndoCloseGroupingRunLoopOrdering
											  modes:modes];
	}
	else
	{
		[[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
	}
}

-(NSInteger)groupingLevel
{
	return groupingLevel;
}


-(void)disableUndoRegistration
{
	disableCount++;
}

-(void)enableUndoRegistration
{
	NSAssert(disableCount > 0, @"Undo registration not previously disabled");
	disableCount--;
}

-(bool)isUndoRegistrationEnabled
{
	return (disableCount == 0);
}


-(bool)isUndoing
{
	return undoing;
}

-(bool)isRedoing
{
	return redoing;
}


-(void)removeAllActions
{
	while (currentGroup != nil)
		[self endUndoGrouping];
	[undoActions removeAllObjects];
	[redoActions removeAllObjects];

	disableCount = 0;
}

-(void)removeAllActionsWithTarget:(id)target
{
	for (NSUInteger i = [undoActions count]; i > 0; --i)
	{
		NSPrivateUndoGroup *action = [undoActions objectAtIndex:i-1];
		[action removeAllActionsWithTarget:target];
		if ([action actionCount] == 0)
		{
			[undoActions removeObjectAtIndex:i-1];
		}
	}
	for (NSUInteger i = [redoActions count]; i > 0; --i)
	{
		NSPrivateUndoGroup *action = [redoActions objectAtIndex:i-1];
		[action removeAllActionsWithTarget:target];
		if ([action actionCount] == 0)
		{
			[redoActions removeObjectAtIndex:i-1];
		}
	}
}


-(void)setActionName:(NSString *)name
{
	[currentGroup setActionName:name];
}

-(NSString *)redoActionName
{
	if ([self canRedo])
	{
		return [[redoActions lastObject] name];
	}
	return nil;
}

-(NSString *)undoActionName
{
	if ([self canUndo])
	{
		return [[undoActions lastObject] name];
	}
	return nil;
}


-(NSString *)redoMenuItemTitle
{
	return [self redoMenuTitleForUndoActionName:[self redoActionName]];
}

-(NSString *)undoMenuItemTitle
{
	return [self undoMenuTitleForUndoActionName:[self undoActionName]];
}

-(NSString *)undoMenuTitleForUndoActionName:(NSString *)name
{
	if ([name length] > 0)
	{
		return [NSString stringWithFormat:@"Undo %@",name];
	}
	else
	{
		return @"Undo";
	}
}

-(NSString *)redoMenuTitleForUndoActionName:(NSString *)name
{
	if ([name length] > 0)
	{
		return [NSString stringWithFormat:@"Redo %@",name];
	}
	else
	{
		return @"Redo";
	}
}


-(NSArray *)runLoopModes
{
	return modes;
}

-(void)setRunLoopModes:(NSArray *)newModes
{
	if (modes != newModes)
	{
		[[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
	}
	modes = newModes;
}


- (void) setActionIsDiscardable:(bool)discard
{
	[currentGroup setActionIsDiscardable:discard];
}

- (bool) redoActionIsDiscardable
{
	return [currentGroup discardable];
}

- (bool) undoActionIsDiscardable
{
	return [currentGroup discardable];
}

@end
