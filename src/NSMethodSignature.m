/*
 * Copyright (c) 2004	Justin Hibbits
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
   MethodSignature.m

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

#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSValue.h>
#include <stdlib.h>
#include <string.h>
#import "internal.h"

/*
   The format of a method type list is:
   Rx1y2z3a

   R - Return type
   x - Size of argument list
   1,2,3 - Argument type at that position
   y,z,a - Size of argument preceding it
 */

@implementation NSMethodSignature

+ (NSMethodSignature *)signatureWithObjCTypes:(const char *)_types
{
	NSMethodSignature   *signature;
	//const char *p;

	if(_types == NULL) {
		@throw [NSInvalidArgumentException
			exceptionWithReason:@"Null types passed to signatureWithObjCTypes:"
			userInfo:nil];
	}

	signature = [NSMethodSignature alloc];
	NSAssert(signature, @"couldn't allocate method signature");

	signature->types = strdup(_types);

	/* Compute no of arguments. The first type is the return type. */
	for(signature->numberOfArguments = -1; *_types; signature->numberOfArguments++)
	{
		_types = objc_skip_argspec(_types);
	}

	return signature;
}

- (void)dealloc
{
	free(types);
}

- (NSHashCode)hash
{
	return hashjb(types, strlen(types));
}

- (bool)isEqual:anotherSignature
{
	return [anotherSignature isKindOfClass:object_getClass(self)]
		&& !strcmp(types, [anotherSignature types]);
}

- (const char *)getArgumentTypeAtIndex:(unsigned int)_index
{
	const char *typesInd = types;
	const char *end;

	if (_index > numberOfArguments)
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"Index out of range"
			userInfo:@{
			@"index": @(_index),
				@"Number of arguments": @(numberOfArguments)}];
		return NULL;
	}

	for (;_index > 0; _index--)
	{
		typesInd = objc_skip_argspec(typesInd);
	}
	end = objc_skip_argspec(typesInd);
	return end;
}

- (unsigned)frameLength
{
	size_t len = 0;
	const char *typeInd = types;
	for (;*typeInd != 0;typeInd = objc_skip_argspec(typeInd))
	{
		len += objc_sizeof_type(typeInd);
	}
	return len;
}

- (unsigned)methodReturnLength
{
	return objc_sizeof_type(types);
}

- (const char*)methodReturnType
{
	return objc_skip_type_qualifiers(types);
}

- (unsigned)numberOfArguments
{
	return numberOfArguments;
}

- (bool) isOneway
{
	return objc_get_type_qualifiers(types) & _F_ONEWAY;
}

@end /* MethodSignature */

@implementation NSMethodSignature (Extensions)

- (const char*)types	{ return types; }

@end /* MethodSignature (Extensions) */
