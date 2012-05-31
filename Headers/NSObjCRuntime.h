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

#ifndef _OBJC_RUNTIME_
#define _OBJC_RUNTIME_
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

@class NSString;

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

#ifndef __has_feature
#define __has_feature(x) 0
#endif
#if __has_feature(blocks)
typedef NSComparisonResult (^NSComparator)(id obj1, id obj2);
#else
typedef NSComparisonResult (*NSComparator)(id obj1, id obj2);
#endif

const char *NSGetSizeAndAlignment(const char *typePtr, NSUInteger *sizep, NSUInteger *alignp);

/*!
 \brief Returns the class object given by the specified name, or nil if none exists.
 \param aClassName Name of the class to return.
 */
Class NSClassFromString(NSString *aClassName);

/*!
 \brief Returns the selector named by the specified name, or zero if none exists.
 \param aSelectorName Name of the selector to return.
 */
SEL NSSelectorFromString(NSString *aSelectorName);

/*!
 \brief Returns an NSString containing the name of the given class.
 \param aClass Class to name.
 */
NSString *NSStringFromClass(Class aClass);

/*!
 \brief Returns an NSString containing the name of the given selector.
 \param aSelector Selector to name.
 */
NSString *NSStringFromSelector(SEL aSelector);

Protocol *NSProtocolFromString(NSString *str);
NSString *NSStringFromProtocol(Protocol *proto);

/*!
 \brief Log a message to <b>stderr</b>, using a <b>printf()</b> style argument list.
 \param format Format and associated arguments to log to the console.
 */
SYSTEM_EXPORT void NSLog(NSString *format, ...);

/*!
 \brief Log a message to <b>stderr</b>, using a <b>printf()</b> style argument list.
 \param format Format and associated arguments to log to the console.
 \param args  Variable length argument list frame, generally retrieved from
 va_start() and va_copy().
 */
SYSTEM_EXPORT void NSLogv(NSString *format, va_list args);

/*!
 \brief Log a message to <b>stderr</b>, NUL-terminated.
 \param message Raw C-string message to log.
 */
SYSTEM_EXPORT void NSLogRaw(const char *message);

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
