/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSObject.h>

__BEGIN_DECLS
@class NSArray,NSMutableArray,Invocation;

enum {
 NSUndoCloseGroupingRunLoopOrdering=350000,
};

SYSTEM_EXPORT NSString * const NSUndoManagerCheckpointNotification;

SYSTEM_EXPORT NSString * const NSUndoManagerDidOpenUndoGroupNotification;
SYSTEM_EXPORT NSString * const NSUndoManagerWillCloseUndoGroupNotification;

SYSTEM_EXPORT NSString * const NSUndoManagerWillUndoChangeNotification;
SYSTEM_EXPORT NSString * const NSUndoManagerDidUndoChangeNotification;

SYSTEM_EXPORT NSString * const NSUndoManagerWillRedoChangeNotification;
SYSTEM_EXPORT NSString * const NSUndoManagerDidRedoChangeNotification;


@interface NSUndoManager : NSObject {
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

-(NSArray *)runLoopModes;
-(unsigned long)levelsOfUndo;
-(bool)groupsByEvent;

-(void)setRunLoopModes:(NSArray *)modes;
-(void)setLevelsOfUndo:(unsigned long)levels;
-(void)setGroupsByEvent:(bool)flag;

-(bool)isUndoRegistrationEnabled;
-(void)disableUndoRegistration;
-(void)enableUndoRegistration;

-(void)beginUndoGrouping;
-(void)endUndoGrouping;

-(long)groupingLevel;

-(bool)canUndo;
-(void)undo;
-(void)undoNestedGroup;
-(bool)isUndoing;

-(bool)canRedo;
-(void)redo;
-(bool)isRedoing;

-(void)registerUndoWithTarget:(id)target selector:(SEL)selector object:(id)object;

-(void)removeAllActions;
-(void)removeAllActionsWithTarget:(id)target;

-(id)prepareWithInvocationTarget:(id)target;
-(void)forwardInvocation:(Invocation *)invocation;

-(NSString *)undoActionName;
-(NSString *)undoMenuItemTitle;
-(NSString *)undoMenuTitleForUndoActionName:(NSString *)name;
-(void)setActionName:(NSString *)name;

-(NSString *)redoActionName;
-(NSString *)redoMenuItemTitle;
-(NSString *)redoMenuTitleForUndoActionName:(NSString *)name;

- (void)clearRedoStackIfStateIsNormal;
@end

__END_DECLS
