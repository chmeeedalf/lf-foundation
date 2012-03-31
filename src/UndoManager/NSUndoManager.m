/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Foundation/NSUndoManager.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/RunLoop.h>
#import <Foundation/Notification.h>
#import <Foundation/NSException.h>
#import <Foundation/Invocation.h>
#import "UndoGroup.h"

enum _UndoManagerState
{
	UndoManagerNormal,
	UndoManagerUndoing,
	UndoManagerRedoing
};

NSString * const UndoManagerCheckpointNotification=@"UndoManagerCheckpointNotification";
NSString * const UndoManagerDidOpenUndoGroupNotification=@"UndoManagerDidOpenUndoGroupNotification";
NSString * const UndoManagerWillCloseUndoGroupNotification=@"UndoManagerWillCloseUndoGroupNotification";
NSString * const UndoManagerWillUndoChangeNotification=@"UndoManagerWillUndoChangeNotification";
NSString * const UndoManagerDidUndoChangeNotification=@"UndoManagerDidUndoChangeNotification";
NSString * const UndoManagerWillRedoChangeNotification=@"UndoManagerWillRedoChangeNotification";
NSString * const UndoManagerDidRedoChangeNotification=@"UndoManagerDidRedoChangeNotification";

@implementation UndoManager

-(void)_registerPerform
{
	if(!_performRegistered){
		_performRegistered=true;
		[[RunLoop currentRunLoop] performSelector:@selector(runLoopUndo:) target:self argument:nil order:UndoCloseGroupingRunLoopOrdering modes:_modes];

	}
}

-(void)_unregisterPerform
{
	if(_performRegistered){
		_performRegistered=false;
		[[RunLoop currentRunLoop] cancelPerformSelector:@selector(runLoopUndo:) target:self argument:nil];    
	}
}


- (id)init
{
	_undoStack = [[NSMutableArray alloc] init];
	_redoStack = [[NSMutableArray alloc] init];
	_state = UndoManagerNormal;

	[self setGroupsByEvent:true];
	_performRegistered=false;

	return self;
}

- (void)dealloc
{
	[self _unregisterPerform];

	[_undoStack release];
	[_redoStack release];
	[_currentGroup release];
	[_modes release];
	[_actionName release];

	[super dealloc];
}

- (NSArray *)runLoopModes
{
	return _modes;
}

- (unsigned long)levelsOfUndo
{
	return _levelsOfUndo;
}

- (bool)groupsByEvent
{
	return _groupsByEvent;
}

- (void)setRunLoopModes:(NSArray *)modes
{
	[_modes release];
	_modes = [modes retain];
	[self _unregisterPerform];
	if (_groupsByEvent)
		[self _registerPerform];
}

- (void)setLevelsOfUndo:(unsigned long)levels
{
	_levelsOfUndo = levels;
	while ([_undoStack count] > _levelsOfUndo)
		[_undoStack removeObjectAtIndex:0];
	while ([_redoStack count] > _levelsOfUndo)
		[_redoStack removeObjectAtIndex:0];
}

- (void)setGroupsByEvent:(bool)flag
{
	_groupsByEvent = flag;
	if (_groupsByEvent)
		[self _registerPerform];
	else
		[self _unregisterPerform];
}

- (bool)isUndoRegistrationEnabled
{
	return (_disableCount == 0);
}

- (void)disableUndoRegistration
{
	_disableCount++;
}

- (void)enableUndoRegistration
{
	if (_disableCount == 0)
		@throw [InternalInconsistencyException
			exceptionWithReason:@"Attempt to enable registration with no disable message in effect" userInfo:nil];

	_disableCount--;
}

- (void)beginUndoGrouping
{
	UndoGroup *undoGroup = [UndoGroup undoGroupWithParentGroup:_currentGroup];

	if (!([_currentGroup parentGroup] == nil && _state == UndoManagerUndoing))
		[[NotificationCenter defaultCenter] postNotificationName:UndoManagerCheckpointNotification
														  object:self];

	[_currentGroup release];
	_currentGroup = [undoGroup retain];

	[[NotificationCenter defaultCenter] postNotificationName:UndoManagerDidOpenUndoGroupNotification object:self];
}

- (void)endUndoGrouping
{
	NSMutableArray *stack = nil;
	UndoGroup *parentGroup = [[_currentGroup parentGroup] retain];

	if (_currentGroup == nil)
		@throw [InternalInconsistencyException
			exceptionWithReason:@"endUndoGrouping called without first calling beginUndoGrouping" userInfo:nil];

	[[NotificationCenter defaultCenter] postNotificationName:UndoManagerCheckpointNotification
													  object:self];

	if (parentGroup == nil && [[_currentGroup invocations] count] > 0)
	{
		switch (_state)
		{
			case UndoManagerNormal:
				[[NotificationCenter defaultCenter] postNotificationName:UndoManagerWillCloseUndoGroupNotification object:self];

			case UndoManagerRedoing:
				stack = _undoStack;
				break;

			case UndoManagerUndoing:
				stack = _redoStack;
				break;
		}

		[stack addObject:_currentGroup];
		if (_levelsOfUndo > 0)
			if ([stack count] > _levelsOfUndo)
				[stack removeObjectAtIndex:0];
	}
	else
	{
		// a nested group was closed. fold its invocations into its parent, preserving the
		// order for future changes on the parent.
		[parentGroup addInvocationsFromArray:[_currentGroup invocations]];
	}

	[_currentGroup release];
	_currentGroup = parentGroup;
}

- (long)groupingLevel
{
	UndoGroup *temp = _currentGroup;
	int level = (_currentGroup != nil);

	while ((temp = [temp parentGroup])!=nil)
		level++;

	return level;
}

- (void)runLoopUndo:(id)dummy
{
	return;

	// FIXME: grouping by event is broken, causes a constant spin condition on the run loop by requeueing this method in itself
	// is the run loop method broken or this one?

	if (_groupsByEvent == true)
	{
		if (_currentGroup != nil)
			[self endUndoGrouping];

		[self beginUndoGrouping];

		[[RunLoop currentRunLoop] performSelector:@selector(runLoopUndo:) target:self argument:nil order:UndoCloseGroupingRunLoopOrdering modes:_modes];
	}
}

- (bool)canUndo
{
	if ([_undoStack count] > 0)
		return true;

	if ([[_currentGroup invocations] count] > 0)
		return true;

	return false;
}

- (void)undoNestedGroup
{
	UndoGroup *undoGroup;

	if (_currentGroup != nil)
		@throw [InternalInconsistencyException
			exceptionWithReason:@"undo called with open nested group" userInfo:nil];

	[[NotificationCenter defaultCenter] postNotificationName:UndoManagerCheckpointNotification
													  object:self];

	[[NotificationCenter defaultCenter] postNotificationName:UndoManagerWillUndoChangeNotification
													  object:self];

	_state = UndoManagerUndoing;
	undoGroup = [[_undoStack lastObject] retain];
	[_undoStack removeLastObject];
	[self beginUndoGrouping];
	[undoGroup invokeInvocations];
	[self endUndoGrouping];
	[undoGroup release];
	_state = UndoManagerNormal;

	[[NotificationCenter defaultCenter] postNotificationName:UndoManagerDidUndoChangeNotification
													  object:self];
}

- (void)undo
{
	if ([self groupingLevel] == 1)
		[self endUndoGrouping];

	[self undoNestedGroup];
}

- (bool)isUndoing
{
	return (_state == UndoManagerUndoing);
}


- (bool)canRedo
{
	[[NotificationCenter defaultCenter] postNotificationName:UndoManagerCheckpointNotification
													  object:self];
	return ([_redoStack count] > 0);
}

- (void)redo
{
	UndoGroup *undoGroup;

	if (_state == UndoManagerUndoing)
		@throw [InternalInconsistencyException
			exceptionWithReason:@"redo called while undoing" userInfo:nil];

	[[NotificationCenter defaultCenter] postNotificationName:UndoManagerCheckpointNotification
													  object:self];

	[[NotificationCenter defaultCenter] postNotificationName:UndoManagerWillRedoChangeNotification
													  object:self];

	[self endUndoGrouping];
	_state = UndoManagerRedoing;
	undoGroup = [[_redoStack lastObject] retain];
	[_redoStack removeLastObject];
	[self beginUndoGrouping];
	[undoGroup invokeInvocations];
	[self endUndoGrouping];
	[undoGroup release];
	_state = UndoManagerNormal;
	[self beginUndoGrouping];

	[[NotificationCenter defaultCenter] postNotificationName:UndoManagerDidRedoChangeNotification
													  object:self];
}


- (bool)isRedoing
{
	return (_state == UndoManagerRedoing);
}

- (void)registerUndoWithTarget:(id)target selector:(SEL)selector object:(id)object
{
	Invocation *invocation;
	MethodSignature *signature;

	if (_disableCount > 0)
		return;

	if (_currentGroup == nil)
		@throw [InternalInconsistencyException
			exceptionWithReason:@"forwardInvocation called without first opening an undo group" userInfo:nil];

	signature = [target methodSignatureForSelector:selector];
	invocation = [Invocation invocationWithMethodSignature:signature];

	[invocation setTarget:target];
	[invocation setSelector:selector];
	[invocation setArgument:object atIndex:2];
	[invocation retainArguments];

	[_currentGroup addInvocation:invocation];

	if (_state == UndoManagerNormal)
		[_redoStack removeAllObjects];
}

- (void)removeAllActions
{
	[_undoStack removeAllObjects];
	[_redoStack removeAllObjects];
	_disableCount = 0;
}

- (void)removeAllActionsWithTarget:(id)target
{
	UndoGroup *undoGroup;
	int i;

	[_currentGroup removeInvocationsWithTarget:target];

	for (i = 0; i < [_undoStack count]; ++i)
	{
		undoGroup = [_undoStack objectAtIndex:i];

		[undoGroup removeInvocationsWithTarget:target];
		if ([[undoGroup invocations] count] == 0)
			[_undoStack removeObject:undoGroup];
	}
	for (i = 0; i < [_redoStack count]; ++i)
	{
		undoGroup = [_redoStack objectAtIndex:i];

		[undoGroup removeInvocationsWithTarget:target];
		if ([[undoGroup invocations] count] == 0)
			[_redoStack removeObject:undoGroup];
	}
}

- (id)prepareWithInvocationTarget:(id)target
{
	_preparedTarget = [target retain];

	return self;
}

-(MethodSignature *)methodSignatureForSelector:(SEL)selector
{
	return [_preparedTarget methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(Invocation *)invocation
{
	if (_disableCount > 0)
		return;

	if (_preparedTarget == nil)
		@throw [InternalInconsistencyException
			exceptionWithReason:@"forwardInvocation called without first preparing a target" userInfo:nil];
	if (_currentGroup == nil)
		@throw [InternalInconsistencyException
			exceptionWithReason:@"forwardInvocation called without first opening an undo group" userInfo:nil];

	[invocation setTarget:_preparedTarget];
	[_currentGroup addInvocation:invocation];
	[invocation retainArguments];

	if (_state == UndoManagerNormal)
		[_redoStack removeAllObjects];

	[_preparedTarget release];
	_preparedTarget = nil;
}

- (void)setActionName:(NSString *)name
{
	[_actionName release];
	_actionName = [name retain];
}

- (NSString *)undoActionName
{
	if ([self canUndo])
		return _actionName;

	return nil;
}

- (NSString *)undoMenuItemTitle
{
	return [self undoMenuTitleForUndoActionName:[self undoActionName]];
}

// needs localization
- (NSString *)undoMenuTitleForUndoActionName:(NSString *)name
{
	if (name != nil)
	{
		if ([name length] > 0)
			return [NSString stringWithFormat:@"Undo %@", name];

		return @"Undo";
	}

	return name;
}

- (NSString *)redoActionName
{
	if ([self canRedo])
		return _actionName;

	return nil;
}

- (NSString *)redoMenuItemTitle
{
	return [self redoMenuTitleForUndoActionName:[self redoActionName]];
}

- (NSString *)redoMenuTitleForUndoActionName:(NSString *)name
{
	if (name != nil)
	{
		if ([name length] > 0)
			return [NSString stringWithFormat:@"Redo %@", name];

		return @"Redo";
	}

	return name;
}

- (void)clearRedoStackIfStateIsNormal
{
	if (_state == UndoManagerNormal)
		[_redoStack removeAllObjects];
}

@end

