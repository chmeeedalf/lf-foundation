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

#import <Foundation/NSObject.h>

/*!
 * \struct NSArgumentInfo
 * \brief Method argument information.
 */
typedef struct {
	int offset;	/*!< \brief Offset into the argument structure to find this argument. */
	int size;			/*!< \brief Size of the argument. */
	const char *type;	/*!< \brief Type of the argument. */
} NSArgumentInfo;

/*!
 * \class NSMethodSignature
 * \brief Method signature information -- argument types and return type.
 */
@interface NSMethodSignature	: NSObject
{
	char *types;			/*!< \brief Argument type list. */
	unsigned long  numberOfArguments;	/*!< \brief NSNumber of arguments accepted by this method. */
}

// Creating a method signature
/*!
 * \brief Creates a method signature object given the encoded method return and argument type string.
 * \param types Type string.
 */
+(NSMethodSignature *)signatureWithObjCTypes:(const char *)types;

// Querying a method signature

/*!
 * \brief Returns the number of bytes that the arguments, taken together, would occupy on the stack.
 */
-(unsigned int)frameLength;

/*!
 * \brief Returns the number of bytes required by the return value.
 */
-(unsigned int)methodReturnLength;

/*!
 * \brief Returns a string encoding the return type of the method.
 */
-(const char *)methodReturnType;

/*!
 * \brief Returns the number of arguments recordered in the receiver.
 */
-(unsigned int)numberOfArguments;

/*!
 * \brief Returns the argument type for the given index.
 */
- (const char *)getArgumentTypeAtIndex:(unsigned int)index;

- (bool) isOneway;
@end

/*!
 * \internal
 * \brief Extensions for the MethodSignature class that should generally not be
 * used.
 */
@interface NSMethodSignature(Extensions)
/*!
 * \brief Return the raw type list for this method signature.
 */
- (const char *) types;

@end

/*
   vim:syntax=objc:
 */
