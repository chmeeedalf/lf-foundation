/*
 * Copyright (c) 2004-2012	Gold Project
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
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR COEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#ifndef _OBJC_RUNTIME_
#define _OBJC_RUNTIME_
#include <debug.h>
#include <limits.h>
#include <Foundation/primitives.h>
#include <stddef.h>

__BEGIN_DECLS
/*!
 * \file NSObjCRuntime.h
 * \brief Core Objective-C header.
 */

#include <objc/runtime.h>
#ifndef DOXYGEN_SHOULD_SKIP_THIS
#define NS_INLINE static inline
#endif

/*!
 * \brief Generic return value container.
 */
typedef void *retval_t;

#if 0

/*!
 * \brief Argument frame for message forwarding.
 */
typedef union {
  char *arg_ptr;					/*!< \brief Pointer to stack arguments in this frame. */
  char arg_regs[sizeof (char*)];	/*!< \brief Register arguments in this frame. */
} *arglist_t;			/* argument frame */
#endif

Class *class_copySubclassList(Class cls, size_t *count);
// Included from other headers, matches the Apple runtime...

/*!
 \brief Returns true if aClass is kindClass or subclassed from it.
 */
bool class_isKindOfClass(Class aClass, Class kindClass);

/*!
 * @brief Adds methods from \c behavior to \c targetClass.
 */
void class_addBehavior(Class targetClass, Class behavior);

extern const char *objc_skip_argspec(const char *);

unsigned int encoding_getNumberOfArguments(const char *typedesc);
#if 0
{
	unsigned int count = 0;
	if (typedesc == NULL)
		return 0;

	while (*typedesc != 0)
	{
		typedesc = objc_skip_argspec(typedesc);
		count++;
	}
	return (count - 1);
}
#endif

unsigned int encoding_getSizeOfArguments(const char *typedesc);
unsigned int encoding_getArgumentInfo(const char *typedesc, int arg, const char **type, int *offset);
void encoding_getReturnType(const char *t, char *dst, size_t dst_len);
char *encoding_copyReturnType(const char *t);
void encoding_getArgumentType(const char *t, unsigned int index, char *dst, size_t dst_len);
char *encoding_copyArgumentType(const char *t, unsigned int index);

#ifndef __has_feature
#define __has_feature(x) 0
#endif
#if __has_feature(blocks)
typedef NSComparisonResult (^NSComparator)(id obj1, id obj2);
#else
typedef NSComparisonResult (*NSComparator)(id obj1, id obj2);
#endif

typedef NSUInteger NSEnumerationOptions;
enum
{
	NSEnumerationConcurrent = (1UL << 0),
	NSEnumerationReverse = (1UL << 1),
};

typedef NSUInteger NSSortOptions;
enum
{
	NSSortConcurrent = (1UL << 0),
	NSSortStable = (1UL << 4),
};

enum {NSNotFound = LONG_MAX};
__END_DECLS

#endif

/*
   vim:syntax=objc:
 */
