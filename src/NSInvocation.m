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
/*
   NSInvocation.m

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

#import "internal.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSString.h>
#include <stdlib.h>
#include <string.h>
#include <ffi.h>
#include <objc/slot.h>
#include <objc/hooks.h>

static ffi_type *ffi_type_from_encoding(const char *str);

struct _InvocationPrivate
{
	ffi_closure *closure;
	ffi_cif cif;
	void **args;
	void *ret;
};

@interface NSInvocation(PrivateExtensions)
+ (NSInvocation *)invocationWithCallbackData:(struct _InvocationPrivate *)data arguments:(void **)args signature:(NSMethodSignature *)sig;
- (id) initWithCallbackData:(struct _InvocationPrivate *)data arguments:(void **)args signature:(NSMethodSignature *)sig;
- (void) _verifySignature;
- (void) _retainReleaseArguments:(bool)release;
@end

/* Private isdigit macro because we only need this very simple case */
#define isdigit(x)  ((x) >= '0' && (x) <= '9')
/* Returns YES iff t1 and t2 have same method types, but we ignore
   the argframe layout */
static bool
sel_types_match (const char* t1, const char* t2)
{
	if (!t1 || !t2)
		return false;
	while (1)
	{
		if (*t1 == '+') t1++;
		if (*t2 == '+') t2++;
		while (isdigit(*t1)) t1++;
		while (isdigit(*t2)) t2++;
		/* xxx Remove these next two lines when qualifiers are put in
		   all selectors, not just Protocol selectors. */
		t1 = objc_skip_type_qualifiers(t1);
		t2 = objc_skip_type_qualifiers(t2);
		if (!*t1 && !*t2)
			return true;
		if (*t1 != *t2)
			return false;
		t1++;
		t2++;
	}
	return false;
}

/* This table and the following function are used to convert a single
 * @encode()'d typestring into a libffi type map.
 */
static ffi_type * const ffi_type_match[CHAR_MAX] = {
#if CHAR_MAX == UCHAR_MAX
	[_C_CHR] = &ffi_type_uchar,
#else
	[_C_CHR] = &ffi_type_schar,
#endif
	[_C_UCHR] = &ffi_type_uchar,
	[_C_SHT] = &ffi_type_sshort,
	[_C_USHT] = &ffi_type_ushort,
	[_C_INT] = &ffi_type_sint,
	[_C_UINT] = &ffi_type_uint,
	[_C_LNG] = &ffi_type_slong,
	[_C_ULNG] = &ffi_type_ulong,
	[_C_LNG_LNG] = &ffi_type_sint64,
	[_C_ULNG_LNG] = &ffi_type_uint64,
	[_C_BOOL] = &ffi_type_uint,
	[_C_PTR] = &ffi_type_pointer,
	[_C_CLASS] = &ffi_type_pointer,
	[_C_SEL] = &ffi_type_pointer,
	[_C_ID] = &ffi_type_pointer,
	[_C_CHARPTR] = &ffi_type_pointer,
	[_C_FLT] = &ffi_type_float,
	[_C_DBL] = &ffi_type_double,
	[_C_VOID] = &ffi_type_void,
	[_C_ARY_B] = &ffi_type_pointer,
};

static ffi_type *ffi_type_from_encoding(const char *str)
{
	str = objc_skip_type_qualifiers(str);
	if (ffi_type_match[(unsigned int)*str] != NULL)
	{
		return ffi_type_match[(unsigned int)*str];
	}
	// FIXME: finish this (structs)
	return NULL;
}

static struct _InvocationPrivate *_setupFrame(const char *types)
{
	struct _InvocationPrivate *frame;
	ffi_type *rtype;
	ffi_type **arg_types;
	int nargs = 0;
	const char *typesInd = types;
	
	for(nargs = -1; *typesInd; nargs++)
	{
		typesInd = objc_skip_argspec(typesInd);
	}

	frame = malloc(sizeof(*frame));
	frame->closure = NULL;

	// First get encoding for ffi...
	arg_types = malloc((nargs + 1) * sizeof(ffi_type *));
	rtype = ffi_type_from_encoding(types);
	types = objc_skip_argspec(types);

	for (int i = 0; i < nargs; i++)
	{
		arg_types[i] = ffi_type_from_encoding(types);
		types = objc_skip_argspec(types);
	}
	arg_types[nargs] = NULL;
	ffi_prep_cif(&frame->cif, FFI_DEFAULT_ABI, nargs, rtype, arg_types);

	return frame;
}

static inline size_t roundAlign(size_t size, size_t align)
{
	return ((size + (align - 1)) / align) * align;
}

/* Set up the frame argument storage.  O(n) operation, going forwards then back.
 * Forwards to gather the sizes of the arguments, backwards to set the pointers
 * to the storage.
 */
static void _setupFrameArgs(struct _InvocationPrivate *frame)
{
	size_t frame_size = 0;
	frame->ret = malloc(roundAlign(frame->cif.rtype->size, MAX(frame->cif.rtype->alignment, sizeof(void *))));
	char *arg_frame;
	void **args;
	unsigned int i;

	for (i = 0; i < frame->cif.nargs; i++)
	{
		frame_size += roundAlign(frame->cif.arg_types[i]->size, frame->cif.arg_types[i]->alignment);
	}
	arg_frame = malloc(frame_size);
	args = malloc((frame->cif.nargs) * sizeof(void *));
	for (; i > 0; i--)
	{
		frame_size -= roundAlign(frame->cif.arg_types[i - 1]->size, frame->cif.arg_types[i - 1]->alignment);
		args[i - 1] = arg_frame + frame_size;
	}

	frame->args = args;
}

static void forwardCallback(ffi_cif *cif, void *ret, void **args, void *data)
{
	id self;
	SEL _cmd;
	NSInvocation *inv;

	self = *(const id *)args[0];
	_cmd = *(SEL *)args[1];

	if (!class_respondsToSelector(object_getClass(self), @selector(forwardInvocation:)))
	{
		NSLog(@"%s '%s' does not respond to selector %s",
				(class_isMetaClass(self) ? "Class" : "Instance of class"),
				object_getClassName(self),
				sel_getName(_cmd));
		abort();
	}

	inv = [NSInvocation invocationWithCallbackData:data arguments:args signature:[NSMethodSignature signatureWithObjCTypes:sel_getType_np(_cmd)]];
	[inv setTarget:self];
	[inv setSelector:_cmd];
	[self forwardInvocation:inv];
	[inv getReturnValue:ret];
}

static IMP forward2(id self, SEL _cmd)
{
	struct _InvocationPrivate *frame;
	void *func;
	
	frame = _setupFrame(sel_getType_np(_cmd));

	frame->closure = ffi_closure_alloc(sizeof(ffi_closure), &func);
	ffi_prep_closure_loc(frame->closure, &frame->cif, forwardCallback, frame, func);
	return (IMP)func;
}

static pthread_key_t slot_key;
static struct objc_slot *forward3(id self, SEL _cmd)
{
	struct objc_slot *slot;
	slot = pthread_getspecific(slot_key);
	if (slot == NULL)
	{
		slot = malloc(sizeof(*slot));
		pthread_setspecific(slot_key, slot);
	}
	slot->method = forward2(self, _cmd);
	return slot;
}

@implementation NSInvocation

+ (void) initialize
{
	__objc_msg_forward3 = forward3;
	__objc_msg_forward2 = forward2;
	pthread_key_create(&slot_key, free);
}

+(NSInvocation *)invocationWithMethodSignature:(NSMethodSignature *)sig
{
	NSInvocation *inv = [[self alloc] initWithMethodSignature:sig];
	return inv;
}

+ (NSInvocation *)invocationWithCallbackData:(struct _InvocationPrivate *)data arguments:(void **)args signature:(NSMethodSignature *)sig
{
	return [[self alloc] initWithCallbackData:data arguments:args signature:sig];
}

- (id) initWithMethodSignature:(NSMethodSignature *)sig
{
	self->signature = sig;
	_d = _setupFrame([sig types]);
	_setupFrameArgs(_d);
	return self;
}

- (id) initWithCallbackData:(struct _InvocationPrivate *)data arguments:(void **)args signature:(NSMethodSignature *)sig
{
	_d = data;
	_d->args = args;
	signature = sig;
	return self;
}

/* Free a tree of ffi_type pointers.  If a given type's 'elements' pointer is
 * non-NULL, then it's a struct so recurse, otherwise it's a primitive, so
 * ignore it.
 */
static void free_ffi_types(ffi_type **types)
{
	for (; *types != NULL; types++)
	{
		if ((*types)->elements != NULL)
		{
			free_ffi_types((*types)->elements);
		}
	}
	free(types);
}

- (void) dealloc
{
    if (argumentsRetained)
	{
		[self _retainReleaseArguments:true];
	}
    if (_d != NULL)
	{
		// If there is a closure, then we don't own the frame, it was a forward.
		if (_d->args != NULL && _d->closure == NULL)
		{
			free(_d->args);
		}
		else if (_d->closure != NULL)
		{
			ffi_closure_free(_d->closure);
		}

		if (_d->ret != NULL)
		{
			free(_d->ret);
		}
		free_ffi_types(_d->cif.arg_types);
	}
	free(_d);
}

- (bool)argumentsRetained
{
	return argumentsRetained;
}

- (void)getReturnValue:(void *)retLoc
{
	//NSAssert(*[signature methodReturnType] == _C_VOID, @"NSInvocation must be invoked first.");

	if (*[signature methodReturnType] != _C_VOID)
		memcpy(retLoc, _d->ret, [signature methodReturnLength]);
}

- (void)setReturnValue:(void *)retLoc
{
	const char* retType;
	int retSize;

	[self _verifySignature];

	NSAssert(signature, @"You must previously set the signature object");

	retType = [signature methodReturnType];
	retSize = [signature methodReturnLength];

	if(*retType != _C_VOID) {
		memcpy(_d->ret, retLoc, retSize);
	}
}


- (NSMethodSignature *)methodSignature
{
	return signature;
}

- (SEL)selector
{
	return selector;
}

- (id)target
{
	return target;
}

/* Retain or release arguments */
- (void) _retainReleaseArguments:(bool)release
{
	unsigned int arg_cnt = [signature numberOfArguments] - 1;
	const char *argType;
	void *c;

	for (;arg_cnt; arg_cnt--)
	{
		argType = [signature getArgumentTypeAtIndex:arg_cnt];
		if (*argType == _C_ID)
		{
			id tmp;
			[self getArgument:&c atIndex:arg_cnt];
			if (release)
				tmp = (__bridge_transfer id)c;
			else
			{
				tmp = (__bridge id)c;
				c = (__bridge_retained void *)tmp;
			}
		}
		else if (*argType == _C_CHARPTR)
		{
			char *s;

			[self getArgument:&c atIndex:arg_cnt];
			s = strdup(c);
			[self setArgument:&s atIndex:arg_cnt];
		}
	}
	argumentsRetained = true;
}

- (void)retainArguments
{
	[self _retainReleaseArguments:false];
}

- (void)setSelector:(SEL)aSel
{
	selector = aSel;
}

- (void)setTarget:(id)_target
{
	target = _target;
}

-(void)getArgument:(void *)arg atIndex:(int)argIndex
{
	NSAssert(signature != nil, @"Method signature must be created first.");
	NSAssert((unsigned int)argIndex < _d->closure->cif->nargs, @"Index out of range");

	memcpy(arg, _d->args[argIndex], _d->closure->cif->arg_types[argIndex]->size);
}

-(void)setArgument:(void *)arg atIndex:(int)index
{
	/* If the argument to be set is not the target, verify the signature */
	if(index)
		[self _verifySignature];

	if(index >= (int)[signature numberOfArguments])
		@throw([NSRangeException
				exceptionWithReason:@"Argument index out of range."
						   userInfo:nil]);
	else {
		if (arg)
		{
			memcpy(_d->args[index], arg, _d->cif.arg_types[index]->size);
		}
	}
}

// Actual invocation code....

- (void)invoke
{
	[self invokeWithTarget:target];
}

- (void)invokeWithTarget:(id)_target
{
    id         old_target = target;

    /*  Set the target. We assign '_target' to 'target' because some
        of the NSInvocation's methods assume a valid target. */
    target = _target;
    [self _verifySignature];

    {
        Method m;

        m = class_getInstanceMethod(object_getClass(_target), selector);
        
		[self setArgument:&_target atIndex:0];
		[self setArgument:&selector atIndex:1];
		ffi_call(&_d->cif, (void (*)())method_getImplementation(m), _d->ret, _d->args);
    }

    /* Restore the old target. */
    target = old_target;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<%s %p selector: %@ target: %@>", \
			object_getClassName(self), \
			self, \
			selector ? NSStringFromSelector(selector) : @"nil", \
			target ? NSStringFromClass([target class]) : @"nil" \
			];
}

- (void)_verifySignature
{
	Method mth;

	NSAssert(target != nil, @"Null target for invocation");
	NSAssert(selector != NULL, @"Null selector for invocation");

	mth = class_getInstanceMethod([target class], selector);

	if (mth) {
		/* a method matching the selector does exist */
		const char *types;

		types = method_getTypeEncoding(mth);

		NSAssert(types != NULL, @"Method has no type list!");

		if(signature) {
			NSAssert(sel_types_match(types, [signature types]),
					@"types don't match: '%s', '%s'", types, [signature types]);
		}
		else {
			signature = [NSMethodSignature signatureWithObjCTypes:types];
		}
	}
	else {
		/* no method matching the selector does exist */
		signature = [target methodSignatureForSelector:selector];
	}

	NSAssert(signature != nil, @"No signature for selector: %s",
			sel_getName(selector));
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	const char *types = [signature types];
	int count = [signature numberOfArguments];
	const char *argType;

	[coder encodeValueOfObjCType:@encode(const char *) at:&types];

	if ([signature methodReturnLength] > 0)
	{
		// Encode the return only if it's not void.
		[coder encodeValueOfObjCType:[signature methodReturnType] at:_d->args[0]];
	}
	
	for (int i = 0; i < count; i++)
	{
		argType = [signature getArgumentTypeAtIndex:i];
		[coder encodeValueOfObjCType:argType at:(_d->args[i + 1])];
	}
}

- (id) initWithCoder:(NSCoder *)coder
{
	const char *types;
	int count = [signature numberOfArguments];
	const char *argType;
	NSMethodSignature *newSig;

	[coder decodeValueOfObjCType:@encode(const char *) at:&types];
	newSig = [NSMethodSignature signatureWithObjCTypes:types];
	free((void *)types);

	self = [NSInvocation invocationWithMethodSignature:newSig];

	if ([signature methodReturnLength] > 0)
	{
		[coder decodeValueOfObjCType:[signature methodReturnType] at:_d->args[0]];
	}
	
	for (int i = 0; i < count; i++)
	{
		argType = [signature getArgumentTypeAtIndex:i];
		[coder decodeValueOfObjCType:argType at:(_d->args[i + 1])];
	}

	return self;
}

@end /* NSInvocation */
