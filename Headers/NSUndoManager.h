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

#import <Foundation/NSObject.h>

__BEGIN_DECLS
@class NSArray,NSMutableArray,Invocation;

enum
{
	NSUndoCloseGroupingRunLoopOrdering=350000,
};

SYSTEM_EXPORT NSString * const NSUndoManagerCheckpointNotification;

SYSTEM_EXPORT NSString * const NSUndoManagerDidOpenUndoGroupNotification;
SYSTEM_EXPORT NSString * const NSUndoManagerWillCloseUndoGroupNotification;
SYSTEM_EXPORT NSString * const NSUndoManagerDidCloseUndoGroupNotification;

SYSTEM_EXPORT NSString * const NSUndoManagerWillUndoChangeNotification;
SYSTEM_EXPORT NSString * const NSUndoManagerDidUndoChangeNotification;

SYSTEM_EXPORT NSString * const NSUndoManagerWillRedoChangeNotification;
SYSTEM_EXPORT NSString * const NSUndoManagerDidRedoChangeNotification;

SYSTEM_EXPORT NSString * const NSUndoManagerGroupIsDiscardableKey;


@interface NSUndoManager	:	NSObject

-(void)registerUndoWithTarget:(id)target selector:(SEL)selector object:(id)object;
-(id)prepareWithInvocationTarget:(id)target;

-(bool)canUndo;
-(bool)canRedo;

-(void)undo;
-(void)undoNestedGroup;
-(void)redo;

-(void)setLevelsOfUndo:(NSUInteger)levels;
-(NSUInteger)levelsOfUndo;

-(void)beginUndoGrouping;
-(void)endUndoGrouping;
-(bool)groupsByEvent;
-(void)setGroupsByEvent:(bool)flag;
-(NSInteger)groupingLevel;

-(void)disableUndoRegistration;
-(void)enableUndoRegistration;
-(bool)isUndoRegistrationEnabled;

-(bool)isUndoing;
-(bool)isRedoing;

-(void)removeAllActions;
-(void)removeAllActionsWithTarget:(id)target;

-(void)setActionName:(NSString *)name;
-(NSString *)redoActionName;
-(NSString *)undoActionName;

-(NSString *)redoMenuItemTitle;
-(NSString *)undoMenuItemTitle;
-(NSString *)undoMenuTitleForUndoActionName:(NSString *)name;
-(NSString *)redoMenuTitleForUndoActionName:(NSString *)name;

-(NSArray *)runLoopModes;
-(void)setRunLoopModes:(NSArray *)modes;

- (void) setActionIsDiscardable:(bool)discard;
- (bool) redoActionIsDiscardable;
- (bool) undoActionIsDiscardable;
@end

__END_DECLS
