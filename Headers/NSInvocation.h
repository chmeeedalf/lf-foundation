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

@class NSMethodSignature;

/*!
 \class NSInvocation
 \brief Holds all information necessary to invoke a method call.

 \details The NSInvocation class is used to forward method calls to other
 processes and objects.  It contains all the data needed to reconstruct a method
 call, and code to perform it.
 */
@interface NSInvocation	: NSObject<NSCoding>
{
	/*! \internal
	 * @{ */
	SEL selector;
	id target;
	NSMethodSignature* signature;
	struct _InvocationPrivate *_d;
	bool argumentsRetained;
	/* @} */
}

// Creating invocations
/*!
 * \brief Returns an invocation object able to construct calls to objects.
 * \param sig Signature with which to initialize the invocation object.
 */
+(NSInvocation *)invocationWithMethodSignature:(NSMethodSignature *)sig;

/*!
 * \brief Returns an invocation object able to construct calls to objects.
 * \param sig Signature with which to initialize the invocation object.
 */
- (id) initWithMethodSignature:(NSMethodSignature *)sig;

// Managing invocation arguments
/*!
 * \brief Returns true if arguments are retained.
 */
-(bool)argumentsRetained;

/*!
 * \brief Copies the argument stored at the given index into the storage pointed to by the given buffer pointer.
 */
-(void)getArgument:(void*)argumentLocation atIndex:(int)index;

/*!
 * \brief Copies the invocation's return value into the location pointed to by the argument.
 * \param retLoc Pointer to the location to place the return value.
 */
-(void)getReturnValue:(void *)retLoc;

/*!
 * \brief Returns the invocation's method signature object.
 */
-(NSMethodSignature *)methodSignature;

/*!
 * \brief Instructs the invocation object to retain the target and arguments, and make copies of C strings.
 */
-(void)retainArguments;

/*!
 * \brief Returns the invocation's selector.
 */
-(SEL)selector;

/*!
 * \brief Sets the argument stored at the given index to the given storage.
 * \param argumentLocation Pointer to the argument location.
 * \param index Index of argument to replace.
 * Index starts at 2 for the first argument, 3 for the second.
 */
-(void)setArgument:(void *)argumentLocation atIndex:(int)index;

/*!
  \brief Sets the return value of this invocation.
  \param retVal Pointer to the fudged return value;
 */
-(void)setReturnValue:(void *)retVal;

/*!
 * \brief Sets the invocation's selector to the given selector.
 * \param selector Selector to set the invocation.
 */
-(void)setSelector:(SEL)selector;

/*!
 * \brief Sets the invocation's target.
 * \param target New target for invocation.
 */
-(void)setTarget:(id)target;

/*!
 * \brief Returns the invocation's target.
 */
-(id)target;

// Dispatching an invocation
/*!
 * \brief Invokes the message encoded in the invocation.
 */
-(void)invoke;

/*!
 * \brief invokes the mesage encoded in the invocation with the given object.
 * \param target Target of message.
 */
-(void)invokeWithTarget:(id)target;

@end

/*!
 * \brief Rarely used NSInvocation methods.
 */
@interface NSInvocation(Extensions)

/*!
 * \brief Returns the frame for the return value of the invoked method.
 */
- (retval_t) returnFrame;

@end

/*
   vim:syntax=objc:
 */
