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
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR COEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSObject.h>

@class NSString, NSMethodSignature, NSInvocation;

/*!
  \brief Root class for proxy objects.

  \details The NSProxy class provides the bare implementation of the NSObject
  protocol for proxy classes.  Subclasses must override certain methods,
  specifically the -forwardNSInvocation: method.
 */
@interface NSProxy <NSObject>
{
	Class isa;	/*!< \brief Pointer to the class metadata. */
}

// Creating and destroying instances
/*!
 * \brief Returns a new, unitialized instance of the receiving class.
 */
+(id)alloc;

/*!
 * \brief Returns a new, unitialized instance of the receiving class in the specified zone.
 * \param zone Zone into which to allocate the instance.
 */
+(id)allocWithZone:(NSZone *)zone;

/*!
 * \brief Deallocates hte memory occupied by the receiver.
 */
-(void)dealloc;
- (void) finalize;

// Identifying classes
/*!
 * \brief Returns <b>self</b>.
 * Since this is a class method it returns the class object.
 */
+(Class)class;

// Obtaining method information
/*!
 * \brief Implemented by subclasses to return an object that contains a description of the selector method, or <b>nil</b> if the method can't be found.
 * \param aSelector Selector to return the method signature of.
 * The NSProxy implementation of this method raises an
 * InvalidArgumentException.
 */
-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;

// Describing objects
/*!
 * \brief Returns the name of the receiver's class and the hexadecimal value of its <b>id</b>.
 */
-(NSString *)description;

// Forwarding messages
/*!
 * \brief Implemented by subclasses to forward messages to other objects.
 * \param invocation NSInvocation to forward.
 * The NSProxy implmentation of this method raises an
 * InvalidArgumentException.
 */
-(void)forwardInvocation:(NSInvocation *)invocation;

- (bool) respondsToSelector:(SEL)sel;

@end

/*
   vim:syntax=objc:
 */
