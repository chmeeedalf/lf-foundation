/*
   NSProxy.m

   Copyright (C) 2005 Gold Project.
   Copyright (C) 1998 MDlink online service center, Helge Hess
   All rights reserved.

   Author: Justin Hibbits <jrh29@po.cwru.edu>
   Author: Helge Hess (helge@mdlink.de)

   This file is part of the System framework (formerly libFoundation).

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
#include <stddef.h>
#include <stdlib.h>

#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSProxy.h>
#import <objc/runtime.h>
#import <objc/objc-arc.h>

@implementation NSProxy

- (void)_ARCCompliantRetainRelease
{
}

+ (id)alloc
{
	return [self allocWithZone:NULL];
}
+ (id)allocWithZone:(NSZone *)_zone
{
	return NSAllocateObject(self, 0, _zone);
}

- (void)dealloc
{
	NSDeallocateObject((NSObject *)self);
}

// getting the class

+ (Class)class
{
	return self;
}

// handling unimplemented methods

- (void)forwardInvocation:(NSInvocation *)_invocation
{
	@throw [NSInvalidArgumentException
		exceptionWithReason:@"NSProxy subclass should override forwardInvocation:"
		userInfo:nil];
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)_selector
{
	@throw [NSInvalidArgumentException
		exceptionWithReason:@"NSProxy subclass should override methodSignatureForSelector:"
		userInfo:nil];
	return nil;
}

// ******************** Class methods ************************

/*
   Usually instance methods of root classes are inherited to the class object
   of the root class. This isn't the case for most proxy methods, since the
   proxy implementations usually just forward to the real object using
forwardInvocation:.
 */

/* Identifying Class and Superclass */

+ (Class)superclass
{
	return class_getSuperclass(((Class)self));
}

/* Determining Allocation Zones */
+ (NSZone*)zone
{
	return NSZoneOf(self);
}

/* Identifying Proxies */
+ (bool)isProxy
{
	// while instances of NSProxy are proxies, the class itself isn't
	return false;
}

/* Testing Inheritance Relationships */
+ (bool)isKindOfClass:(Class)aClass
{
	// this is the behaviour specified in the MacOSX docs
	return (aClass == [NSObject class]);
}
+ (bool)isMemberOfClass:(Class)aClass
{
	// behaviour as specified in the MacOSX docs
	return false;
}

/* Testing for Protocol Conformance */
+ (bool)conformsToProtocol:(Protocol*)aProtocol
{
	return class_conformsToProtocol(self, aProtocol);
}

/* Testing Class Functionality */
+ (bool)respondsToSelector:(SEL)aSelector
{
	return (!aSelector)
		? false
		: (class_getClassMethod(self, aSelector) != NULL);
}

/* Managing Reference Counts */
+ (id)autorelease
{
	return self;
}

+ (oneway void)release
{
}

+ (id)retain
{
	return self;
}

/* Identifying and Comparing Instances */
+ (NSHashCode)hash
{
	return (NSHashCode)self;
}
+ (bool)isEqual:(id)anObject
{
	return (self == anObject) ? true : false;
}
+ (id)self
{
	return self;
}

/* Sending Messages Determined at Run Time */
+ (id)performSelector:(SEL)aSelector
{
	IMP msg = aSelector ? class_getMethodImplementation(object_getClass(self), aSelector) : NULL;

	if(!msg)
	{
		@throw [NSInternalInconsistencyException
			exceptionWithReason:
			[NSString stringWithFormat:@"invalid selector `%s' passed to %s",
			sel_getName(aSelector), sel_getName(_cmd)]
				userInfo:nil];
	}
	return (*msg)(self, aSelector);
}
+ (id)performSelector:(SEL)aSelector withObject:(id)anObject
{
	IMP msg = aSelector ? class_getMethodImplementation(object_getClass(self), aSelector) : NULL;

	if(!msg)
	{
		@throw [NSInternalInconsistencyException
			exceptionWithReason:
			[NSString stringWithFormat:@"invalid selector `%s' passed to %s",
			sel_getName(aSelector), sel_getName(_cmd)]
				userInfo:nil];
	}
	return (*msg)(self, aSelector, anObject);
}
+ (id)performSelector:(SEL)aSelector withObject:(id)anObject
withObject:(id)anotherObject
{
	IMP msg = aSelector ? class_getMethodImplementation(object_getClass(self), aSelector) : NULL;

	if(!msg)
	{
		@throw [NSInternalInconsistencyException
			exceptionWithReason:
			[NSString stringWithFormat:@"invalid selector `%s' passed to %s",
			sel_getName(aSelector), sel_getName(_cmd)]
				userInfo:nil];
	}
	return (*msg)(self, aSelector, anObject, anotherObject);
}

/* Describing the NSObject */
+ (NSString *)description
{
	return [NSString stringWithFormat:@"<class %s>",
		(char *)object_getClassName(self)];
}

// ******************** NSObject protocol ********************

static inline NSInvocation *_makeInvocation(NSProxy *self, SEL _cmd, const char *sig)
{
	NSMethodSignature *s;
	NSInvocation      *i;

	s = [NSMethodSignature signatureWithObjCTypes:sig];
	if (s == nil) return nil;
	i = [NSInvocation invocationWithMethodSignature:s];
	if (i == nil) return nil;

	[i setSelector:_cmd];
	[i setTarget:self];

	return i;
}
static inline NSInvocation *_makeInvocation1(NSProxy *self, SEL _cmd,
		const char *sig,
		id _object)
{
	NSInvocation *i = _makeInvocation(self, _cmd, sig);
	[i setArgument:&_object atIndex:2];
	return i;
}

- (id)autorelease
{
	return objc_autorelease(self);
}

- (id)retain
{
	return objc_retain(self);
}

- (oneway void)release
{
	objc_release(self);
}

- (oneway void)release:(bool)autorelease
{
	if (autorelease)
	{
		NSDecrementAutoreleaseRefCount(self);
	}
	[self release];
}

- (Class)class
{
	// Note that this returns the proxy class, not the real one !
	return object_getClass(self);
}
- (Class)superclass
{
	// Note that this returns the proxy's class superclass, not the real one !
	return class_getSuperclass([self class]);
}

- (bool)conformsToProtocol:(Protocol *)_protocol
{
	NSInvocation *i = _makeInvocation1(self, _cmd, "C@:@", _protocol);
	bool         r;
	[self forwardInvocation:i];
	[i getReturnValue:&r];
	return r;
}
- (bool)isKindOfClass:(Class)_class
{
	NSInvocation *i = _makeInvocation1(self, _cmd, "C@:@", _class);
	bool result;
	[self forwardInvocation:i];
	[i getReturnValue:&result];
	return result;
}
- (bool)isMemberOfClass:(Class)_class
{
	NSInvocation *i = _makeInvocation1(self, _cmd, "C@:@", _class);
	bool result;
	[self forwardInvocation:i];
	[i getReturnValue:&result];
	return result;
}

- (bool)isProxy
{
	return true;
}

- (bool)respondsToSelector:(SEL)_selector
{
	NSInvocation *i;
	bool         r;

	if (_selector)
	{
		if (class_getInstanceMethod(object_getClass(self), _selector)) return true;
	}

	i = _makeInvocation(self, _cmd, "C@::");
	[i setArgument:&_selector atIndex:2];
	[self forwardInvocation:i];
	[i getReturnValue:&r];
	return r;
}

- (id)performSelector:(SEL)_selector
{
	NSInvocation *i;
	id           result;
	IMP          msg;

	if (_selector == NULL)
	{
		@throw [NSInvalidArgumentException
			exceptionWithReason:@"passed NULL selector to performSelector:"
			userInfo:nil];
	}

	if ((msg = class_getMethodImplementation(object_getClass(self), _selector)))
		return msg(self, _selector);

	i = [NSInvocation invocationWithMethodSignature:
		[NSMethodSignature signatureWithObjCTypes:"@@:"]];
	[i setTarget:self];
	[i setSelector:_selector];
	[self forwardInvocation:i];
	[i getReturnValue:&result];
	return result;
}
- (id)performSelector:(SEL)_selector withObject:(id)_object
{
	NSInvocation *i;
	id           result;
	IMP          msg;

	if (_selector == NULL)
	{
		@throw [NSInvalidArgumentException
			exceptionWithReason:@"passed NULL selector to performSelector:"
			userInfo:nil];
	}

	if ((msg = class_getMethodImplementation(object_getClass(self), _selector)))
		return msg(self, _selector, _object);

	i = [NSInvocation invocationWithMethodSignature:
		[NSMethodSignature signatureWithObjCTypes:"@@:@"]];
	[i setTarget:self];
	[i setSelector:_selector];
	[i setArgument:&_object atIndex:2];
	[self forwardInvocation:i];
	[i getReturnValue:&result];
	return result;
}
- (id)performSelector:(SEL)_selector withObject:(id)_object withObject:(id)_object2
{
	NSInvocation *i;
	id           result;
	IMP          msg;

	if (_selector == NULL)
	{
		@throw [NSInvalidArgumentException
			exceptionWithReason:@"passed NULL selector to performSelector:"
			userInfo:nil];
	}

	if ((msg = class_getMethodImplementation(object_getClass(self), _selector)))
		return msg(self, _selector, _object, _object2);

	i = [NSInvocation invocationWithMethodSignature:
		[NSMethodSignature signatureWithObjCTypes:"@@:@@"]];
	[i setTarget:self];
	[i setSelector:_selector];
	[i setArgument:&_object  atIndex:2];
	[i setArgument:&_object2 atIndex:3];
	[self forwardInvocation:i];
	[i getReturnValue:&result];
	return result;
}

- (id)self
{
	return self;
}

- (NSZone *)zone
{
	return NSZoneOf((NSObject *)self);
}

- (bool)isEqual:(id)_object
{
	NSInvocation *i = _makeInvocation1(self, _cmd, "i@:@", _object);
	bool result;

	[self forwardInvocation:i];
	[i getReturnValue:&result];
	return result;
}
- (NSHashCode)hash
{
	NSInvocation *i = _makeInvocation(self, _cmd, "I@:");
	unsigned hc;
	[self forwardInvocation:i];
	[i getReturnValue:&hc];
	return hc;
}

// description

- (NSString *)description
{
	NSInvocation *i = _makeInvocation(self, _cmd, "@@:");
	NSString *result;

	[self forwardInvocation:i];
	[i getReturnValue:&result];
	return result;
}

// ******************** forwarding ********************

- (retval_t)forward:(SEL)_selector:(arglist_t)argFrame
{
	void         *result;
	NSInvocation *invocation;

	invocation = [NSInvocation invocationWithMethodSignature:
		[self methodSignatureForSelector:_selector]];
	[invocation setArgumentFrame:argFrame];
	[invocation setTarget:self];
	[invocation setSelector:_selector];

	[self forwardInvocation:invocation];

	result = [invocation returnFrame];

	return result;
}

- (void) finalize
{
}
@end
