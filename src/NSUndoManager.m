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

#import <Foundation/NSObject.h>
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


@implementation NSUndoManager
{
    NSMutableArray *_undoStack;
    NSMutableArray *_redoStack;
    bool _groupsByEvent;
    NSArray *_modes;
    int _disableCount;
    long _levelsOfNSUndo;
    id _currentGroup;
    int _state;
    NSString *_actionName;
    id _preparedTarget;
    bool _performRegistered;
}

-(void)registerUndoWithTarget:(id)target selector:(SEL)selector object:(id)object
{
	TODO;	// -[NSUndoManager registerUndoWithTarget:selector:object:]
}

-(id)prepareWithInvocationTarget:(id)target
{
	TODO;	// -[NSUndoManager prepareWithInvocationTarget:]
	return nil;
}


-(bool)canUndo
{
	TODO;	// -[NSUndoManager canUndo]
	return false;
}

-(bool)canRedo
{
	TODO;	// -[NSUndoManager canRedo]
	return false;
}


-(void)undo
{
	TODO;	// -[NSUndoManager undo]
}

-(void)undoNestedGroup
{
	TODO;	// -[NSUndoManager undoNestedGroup]
}

-(void)redo
{
	TODO;	// -[NSUndoManager redo]
}


-(void)setLevelsOfUndo:(NSUInteger)levels
{
	TODO;	// -[NSUndoManager setLevelsOfUndo:]
}

-(NSUInteger)levelsOfUndo
{
	TODO;	// -[NSUndoManager levelsOfUndo]
	return 0;
}


-(void)beginUndoGrouping
{
	TODO;	// -[NSUndoManager beginUndoGrouping]
}

-(void)endUndoGrouping
{
	TODO;	// -[NSUndoManager endUndoGrouping]
}

-(bool)groupsByEvent
{
	TODO;	// -[NSUndoManager groupsByEvent]
	return false;
}

-(void)setGroupsByEvent:(bool)flag
{
	TODO;	// -[NSUndoManager setGroupsByEvent:]
}

-(NSInteger)groupingLevel
{
	TODO;	// -[NSUndoManager groupingLevel]
	return 0;
}


-(void)disableUndoRegistration
{
	TODO;	// -[NSUndoManager disableUndoRegistration]
}

-(void)enableUndoRegistration
{
	TODO;	// -[NSUndoManager enableUndoRegistration]
}

-(bool)isUndoRegistrationEnabled
{
	TODO;	// -[NSUndoManager isUndoRegistrationEnabled]
	return false;
}


-(bool)isUndoing
{
	TODO;	// -[NSUndoManager isUndoing]
	return false;
}

-(bool)isRedoing
{
	TODO;	// -[NSUndoManager isRedoing]
	return false;
}


-(void)removeAllActions
{
	TODO;	// -[NSUndoManager removeAllActions]
}

-(void)removeAllActionsWithTarget:(id)target
{
	TODO;	// -[NSUndoManager removeAllActionsWithTarget:]
}


-(void)setActionName:(NSString *)name
{
	TODO;	// -[NSUndoManager setActionName:]
}

-(NSString *)redoActionName
{
	TODO;	// -[NSUndoManager redoActionName]
	return nil;
}

-(NSString *)undoActionName
{
	TODO;	// -[NSUndoManager undoActionName]
	return nil;
}


-(NSString *)redoMenuItemTitle
{
	TODO;	// -[NSUndoManager redoMenuItemTitle]
	return nil;
}

-(NSString *)undoMenuItemTitle
{
	TODO;	// -[NSUndoManager undoMenuItemTitle]
	return nil;
}

-(NSString *)undoMenuTitleForUndoActionName:(NSString *)name
{
	TODO;	// -[NSUndoManager undoMenuTitleForUndoActionName:]
	return nil;
}

-(NSString *)redoMenuTitleForUndoActionName:(NSString *)name
{
	TODO;	// -[NSUndoManager redoMenuTitleForUndoActionName:]
	return nil;
}


-(NSArray *)runLoopModes
{
	TODO;	// -[NSUndoManager runLoopModes]
	return nil;
}

-(void)setRunLoopModes:(NSArray *)modes
{
	TODO;	// -[NSUndoManager setRunLoopModes:]
}


- (void) setActionIsDiscardable:(bool)discard
{
	TODO;	// -[NSUndoManager setActionIsDiscardable:]
}

- (bool) redoActionIsDiscardable
{
	TODO;	// -[NSUndoManager redoActionIsDiscardable]
	return false;
}

- (bool) undoActionIsDiscardable
{
	TODO;	// -[NSUndoManager undoActionIsDiscardable]
	return false;
}

@end
