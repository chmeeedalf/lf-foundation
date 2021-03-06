/*
 * Copyright (c) 2004-2012	Justin Hibbits
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

#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSString.h>
#import <objc/objc.h>

/*
 * When an object is deallocated, its class pointer points to the NSZombie
 * class.
 */
__attribute__((objc_root_class))
@interface NSZombie
@end

/*
 * Global variables
 */

// Keep variables static unless they're referenced elsewhere, to keep the
// symbol table small.
static Class __freedObjectClass = nil;

static void __attribute__((constructor)) init_refcounting (void)
{
	__freedObjectClass = objc_getClass("NSZombie");
}

/*
 * Allocate an NSObject
 */

id NSAllocateObject(Class aClass, size_t extraBytes, __unused NSZone *zone)
{
	return class_createInstance(aClass, extraBytes);
}

NSZone* NSZoneFromObject(__unused id<NSObject> anObject)
{
	return NULL;
	//return ZoneOf(anObject);
}

void NSDeallocateObject(id<NSObject> anObject)
{
	/* Set the class of anObject to NSZombie. The further messages to this
	   object will cause an error to occur. */
	object_setClass(anObject, __freedObjectClass);
	object_dispose(anObject);
}

/*
 * Retain / Release Object
 */

bool NSShouldRetainWithZone(__unused id<NSObject> anObject, __unused NSZone* requestedZone)
{
	return true;
}

@implementation NSZombie
- (void) forwardInvocation:(NSInvocation *)inv
{
	NSAssert(false, @"Selector %@ sent to a freed object.", [inv selector]);
}
@end
