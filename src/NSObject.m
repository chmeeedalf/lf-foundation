/*
 * Copyright (c) 2004,2005	Gold Project
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
 * THIS SOFTWARE IS PROVIDED BY THE PROJECT ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */
// Parts of this file from libFoundation, copyright follows.
/*
   NSObject.m

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Ovidiu Predescu <ovidiu@bx.logicnet.ro>

   This file is part of libFoundation.

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

#import <Foundation/NSObject.h>

#include <string.h>
#include <stdlib.h>
#import <Foundation/NSArchiver.h>
#import <Foundation/NSClassDescription.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSDistantObject.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSPortCoder.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import <objc/objc-arc.h>
#import "internal.h"

@interface _Autoproxy	:	NSProxy
{
	id obj;
}
- (id) initWithObject:(id)obj;
@end

/* Shut up the compiler.  It's actually included in the base. */
@interface NSObject(GoldAddition)
- (id) copyWithZone:(NSZone*)zone;
- (id) mutableCopyWithZone:(NSZone*)zone;
@end

@implementation NSObject
// For ARC compatibility in libobjc
- (void)_ARCCompliantRetainRelease
{
}

extern bool objc_create_block_classes_as_subclasses_of(Class);
+ (void) load
{
	objc_create_block_classes_as_subclasses_of(self);
}

// creating and destroying instances
+(id)alloc
{
	// We pass NULL for the zone so AllocateObject() could use a GC-zone when we
	// create one.
	return [self allocWithZone:NULL];
}

+(id)allocWithZone:(NSZone*)zone
{
	return NSAllocateObject(self, 0, zone);
}

+(id)new
{
	return [[self alloc] init];
}

+(id)copyWithZone:(NSZone *)zone
{
	return self;
}

+(id)mutableCopyWithZone:(NSZone *)zone
{
	return self;
}

-(id)copy
{
	return [self copyWithZone:[self zone]];
}

-(id)mutableCopy
{
	return [self mutableCopyWithZone:NULL];
}

-(void)dealloc
{
	NSDeallocateObject(self);
}

+(void)dealloc
{
}

-(id)init
{
	return self;
}

// Testing class functionality
+(bool)instancesRespondToSelector:(SEL)aSelector
{
	return class_respondsToSelector(self, aSelector);
}

+(bool)respondsToSelector:(SEL)aSelector
{
	return class_respondsToSelector(object_getClass(self), aSelector);
}

-(bool)respondsToSelector:(SEL)aSelector
{
	return class_respondsToSelector(object_getClass(self), aSelector);
}

// Testing protocol conformance
+(bool)conformsToProtocol:(Protocol *)aProtocol
{
	return class_conformsToProtocol(self, aProtocol);
}

- (bool)conformsToProtocol:(Protocol*)aProtocol
{
	return class_conformsToProtocol(object_getClass(self), aProtocol);
}

// Obtaining method information
+(IMP)instanceMethodForSelector:(SEL)aSelector
{
	Method m = class_getInstanceMethod(self, aSelector);
	if (m != NULL)
	{
		return method_getImplementation(m);
	}
	return NULL;
}

-(IMP)methodForSelector:(SEL)aSelector
{
	Method m = class_getInstanceMethod(object_getClass(self), aSelector);
	if (m != NULL)
	{
		return method_getImplementation(m);
	}
	return NULL;
}

+ (NSMethodSignature*)instanceMethodSignatureForSelector:(SEL)aSelector
{
	Method mth;

	if (!aSelector)
		return nil;

	mth = class_getInstanceMethod(self, aSelector);
	if (mth != NULL)
		return [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(mth)];

	return nil;
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	Method mth;

	if (!aSelector)
		return nil;

	mth = class_getInstanceMethod(object_getClass(self), aSelector);

	if (mth != NULL)
		return [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(mth)];

	return nil;
}

// NSError handling
-(void)doesNotRecognizeSelector:(SEL)aSelector
{
	@throw [NSInternalInconsistencyException exceptionWithReason:
			[NSString stringWithFormat:@"%s (%s) does not recognize selector '%s'",
			object_getClassName(self), class_isMetaClass(object_getClass(self)) ? "class" : "instance",
			sel_getName(aSelector)]
		userInfo:nil];
}

// Forwarding messages
-(void)forwardInvocation:(NSInvocation *)anInvocation
{
	[self doesNotRecognizeSelector:[anInvocation selector]];
}

+ (bool) resolveClassMethod:(SEL)selector
{
	return false;
}

+ (bool) resolveInstanceMethod:(SEL)selector
{
	return false;
}

// Archiving
+(void)setVersion:(int)version
{
	class_setVersion( self, version );
}

+(int)version
{
	return class_getVersion(self);
}

// Identifying and Comparing instances
-(NSHashCode)hash
{
	// 16-byte aligned always, so remove low order bits
	return (unsigned long)(self) >> 4;
}

-(bool)isEqual:(id)anObject
{
	return (self == anObject)?true:false;
}

-(id)self
{
	return self;
}

// Identifying class and superclass
+(Class)class
{
	return self;
}

-(Class)class
{
	return object_getClass(self);
}

+(Class)superclass
{
	return class_getSuperclass(self);
}

-(Class)superclass
{
	return class_getSuperclass(object_getClass(self));
}

// Determining allocation zones
-(NSZone *)zone
{
	return NULL;
}

// sending messages determined at runtime
-(id)performSelector:(SEL)aSelector
{
	return class_getMethodImplementation([self class], aSelector)(self, aSelector);
}

-(id)performSelector:(SEL)aSelector withObject:(id)anObject
{
	return class_getMethodImplementation([self class], aSelector)(self, aSelector, anObject);
}

-(id)performSelector:(SEL)aSelector withObject:(id)anObject
	withObject:(id)anotherObject
{
	return class_getMethodImplementation([self class], aSelector)(self, aSelector, anObject, anotherObject);
}

// Identifying proxies
-(bool)isProxy
{
	return false;
}

- (id) awakeAfterUsingCoder:(NSCoder *)coder
{
	return self;
}

- (Class) classForCoder
{
	return [self class];
}

- (Class) classForArchiver
{
	return [self classForCoder];
}

- (Class) classForKeyedArchiver
{
	return [self classForCoder];
}

- (Class) classForPortCoder
{
	return [self classForCoder];
}

- (id) replacementObjectForCoder:(NSCoder *)coder
{
	return self;
}

- (id) replacementObjectForKeyedArchiver:(NSKeyedArchiver *)archiver
{
	return [self replacementObjectForCoder:archiver];
}

- (id) replacementObjectForArchiver:(NSArchiver *)archiver
{
	return [self replacementObjectForCoder:archiver];
}

- (id) replacementObjectForPortCoder:(NSPortCoder *)coder
{
	id replacement = [self replacementObjectForCoder:coder];

	if (replacement == nil)
		return nil;

	if ([coder isBycopy])
		return replacement;
	return [NSDistantObject proxyWithLocal:replacement connection:[coder connection]];
}

// Testing inheritance relationships
+(bool)isKindOfClass:(Class)aClass
{
	return class_isKindOfClass(self, aClass);
}

-(bool)isKindOfClass:(Class)aClass
{
	return class_isKindOfClass(object_getClass(self), aClass);
}

-(bool)isMemberOfClass:(Class)aClass
{
	return ([self class] == aClass);
}

// Managing reference counts
+(id)autorelease
{
	return self;
}

+ (void) release
{
}

+(id)retain
{
	return self;
}

// Describing Objects
+(NSString *)description
{
	return [NSString stringWithFormat:@"<class: %s>",object_getClassName(self)];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"<%s: %p>",object_getClassName(self),self];
}

-(NSString *)className
{
    return NSStringFromClass([self class]);
}

-(void)log
{
	NSLog(@"%@", self);
}

- (id) forwardingTargetForSelector:(SEL)sel
{
	return nil;
}

+ (NSArray *) classFallbacksForKeyedArchiver
{
	return nil;
}

+ (Class) classForKeyedUnarchiver
{
	return self;
}

+ (bool) isSubclassOfClass:(Class)ancestor
{
	return class_isKindOfClass(self, ancestor);
}

+ (void) initialize
{
	// NOTHING
}

- (id) autoContentAccessingProxy
{
	if ([self conformsToProtocol:@protocol(NSDiscardableContent)] &&
			![(id<NSDiscardableContent>)self isContentDiscarded])
		return [[_Autoproxy alloc] initWithObject:self];
	return self;
}

@end

@implementation NSObject (GNU)

- (id) subclassResponsibility:(SEL)aSel
{
	@throw [NSInternalInconsistencyException exceptionWithReason:
			[NSString stringWithFormat:@"subclass of %s should override '%s'",object_getClassName(self), sel_getName(aSel)]
		userInfo:nil];
    return self;
}

- (id) shouldNotImplement:(SEL)aSel
{
	@throw [NSInternalInconsistencyException exceptionWithReason:
			[NSString stringWithFormat:@"%s should not implement '%s'",
			object_getClassName(self), sel_getName(aSel)]
		userInfo:nil];
    return self;
}

- (id) notImplemented:(SEL)aSel
{
	@throw [NSInternalInconsistencyException exceptionWithReason:
			[NSString stringWithFormat:@"%s does not implement '%s'",
			object_getClassName(self), sel_getName(aSel)]
		userInfo:nil];
	return self;
}

@end /* NSObject (GNU) */


@implementation NSObject(Introspection)
static NSString *_inspectVariable(Ivar var, id obj)
{
	const char *type = ivar_getTypeEncoding(var);
	switch(*type)
	{

		default:
			return [[NSValue valueWithBytes:((char *)(__bridge void *)obj + ivar_getOffset(var)) objCType:type] description];
		case _C_ID:
			{
				id objvar;
				object_getInstanceVariable(obj, ivar_getName(var), (__bridge void *)objvar);
				if (objvar == nil)
					return @"<nil>";
				return [NSString stringWithFormat:@"<%s %p>",object_getClassName(objvar),objvar];
			}
	}
}

static NSMutableString *inspectObject(id self, Class startAt)
{
	Ivar *vars;
	Ivar var;
	unsigned int icount = 0;
	unsigned int i;
	NSMutableString *ret;
	/* NSObject has no superclass or instance variables */
	if ([startAt superclass] == Nil)
		ret = [NSMutableString new];
	else
		ret = inspectObject(self, [startAt superclass]);

	vars = class_copyIvarList(startAt, &icount);
	if (vars == NULL)
		return ret;

	for (i = 0; i < icount; i++)
	{
		var = vars[i];
		if (strcmp(ivar_getName(var), "isa") == 0)
			continue;
		if ([ret length] > 0)
			[ret appendString:@", "];
		{
			NSString *temp = [[NSString alloc] initWithFormat:@"%s=%@",ivar_getName(var),_inspectVariable(var,self)];
			[ret appendString:temp];
		}
	}
	return ret;
}

- (NSString *) inspect
{
	NSMutableString *ret;
	ret = inspectObject(self, [self class]);
	return [NSString stringWithFormat:@"{<%@>: %@}",[self className], ret];
}
@end

/*
 * Shuts up the compiler.  These methods aren't actually implemented in NSObject.
 */
@interface NSObject(compare)
- (NSComparisonResult) compare:other;
- (NSIndex) indexOfObjectIdenticalTo:other;
@end

@implementation NSObject (ComparisonMethods)
- (bool) isLessThan:other
{
	return [self compare:other] == NSOrderedAscending;
}

- (bool) isGreaterThan:other
{
	return [self compare:other] == NSOrderedDescending;
}

- (bool) isEqualTo:other
{
	return [self compare:other] == NSOrderedSame;
}

- (bool) isGreaterthanOrEqualto:other
{
	NSComparisonResult c = [self compare:other];
	return (c == NSOrderedDescending) || (c == NSOrderedSame);
}

- (bool) isLessThanOrEqualTo:other
{
	NSComparisonResult c = [self compare:other];
	return (c == NSOrderedAscending) || (c == NSOrderedSame);
}

- (bool) isNotEqualTo:other
{
	return [self compare:other] != NSOrderedSame;
}

- (bool) doesContain:other
{
	return [self indexOfObjectIdenticalTo:other] != NSNotFound;
}
@end

@implementation _Autoproxy

- (id) initWithObject:(id)anObj
{
	obj = [anObj retain];
	[obj beginContentAccess];

	return self;
}

- (void) dealloc
{
	[obj endContentAccess];
}

- (NSMethodSignature *) methodSignatureForSelector:(SEL)sel
{
	return [obj methodSignatureForSelector:sel];
}

- (void) forwardInvocation:(NSInvocation *)inv
{
	[inv invokeWithTarget:obj];
}
@end

void class_addBehavior(Class targetClass, Class behavior)
{
	unsigned int myListCount;
	Ivar *myList = class_copyIvarList(targetClass, &myListCount);
	unsigned int itsListCount;
	Ivar *itsList = class_copyIvarList(behavior, &itsListCount);

	if (myListCount < itsListCount)
	{
		return;
	}

	if (!class_isKindOfClass(targetClass, class_getSuperclass(behavior)))
	{
		return;
	}

	for (unsigned int i = 0; i < itsListCount; i++)
	{
		const char *myEnc = objc_skip_type_qualifiers(ivar_getTypeEncoding(myList[i]));
		const char *itsEnc = objc_skip_type_qualifiers(ivar_getTypeEncoding(itsList[i]));
		if (myEnc[0] == _C_ID && itsEnc[0] == _C_ID)
		{
			// FIXME: For now we assume that any IDs are somewhat compatible
			continue;
		}
		if (strcmp(objc_skip_type_qualifiers(myEnc), objc_skip_type_qualifiers(itsEnc)) != 0)
			return;
	}

	/* Behavior has a subset of ivars for the target. */
	free(myList);
	free(itsList);

	Method *itsMethodList = class_copyMethodList(behavior, &itsListCount);
	for (unsigned int i = 0; i < itsListCount; i++)
	{
		Method m = itsMethodList[i];
		class_addMethod(targetClass, method_getName(m), method_getImplementation(m), method_getTypeEncoding(m));
	}
	free(itsMethodList);

	itsMethodList = class_copyMethodList(object_getClass(behavior), &itsListCount);
	for (unsigned int i = 0; i < itsListCount; i++)
	{
		Method m = itsMethodList[i];
		Class cls = object_getClass(targetClass);
		class_addMethod(cls, method_getName(m), method_getImplementation(m), method_getTypeEncoding(m));
	}
	free(itsMethodList);
}

bool class_isKindOfClass(Class aClass, Class kindClass)
{
	Class cls = aClass;

	for (; cls != NULL; cls = class_getSuperclass(cls))
	{
		if (kindClass == cls)
			return true;
	}
	return false;
}

