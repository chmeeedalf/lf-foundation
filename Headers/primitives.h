/* $Id$	*/
/*
 * Copyright (c) 2004	Gold Project
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

#ifndef __PRIMITIVES_H
#define __PRIMITIVES_H

#include <sys/cdefs.h>
#include <sys/types.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
#	define SYSTEM_EXPORT extern "C"
#else
#	define SYSTEM_EXPORT	extern
#endif

#define __private __attribute__ ((visibility("hidden")))

typedef uint16_t	UCS2Char;
typedef int32_t		UCS4Char;
typedef int32_t		UTF32Char;
typedef uint16_t	unichar;
typedef UCS2Char	NSUniChar;

typedef uint32_t	NSOptionFlags;

typedef unsigned long	NSIndex;
typedef unsigned long	NSHashCode;
typedef intptr_t NSInteger;
typedef uintptr_t NSUInteger;

#define NSIntegerMax	INTPTR_MAX
#define NSIntegerMin	INTPTR_MIN
#define NSUIntegerMax	UINTPTR_MAX

/*!
 @enum ComparisonResult
 */
typedef enum NSComparisonResult {
	NSOrderedAscending = -1,
	NSOrderedSame,
	NSOrderedDescending
} NSComparisonResult;

#endif /* __PRIMITIVES_H */
