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

/* 
   NSAutoreleasePool.h

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

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

#ifdef __cplusplus
namespace std
{
	template <typename T> class allocator;
	template <typename T, class A> class deque;
}
typedef std::deque<id, std::allocator<id> > NSAutoreleasePoolChunk;
#else
typedef struct __NSAutoreleasePoolChunk NSAutoreleasePoolChunk;
#endif

/*!
 \class NSAutoreleasePool
 \brief Holds objects that should be released in the future, by emptying the
 pool.
 */
@interface NSAutoreleasePool : NSObject
{
	NSAutoreleasePool *parentPool;                //!< \brief Next pool up on stack 
	NSAutoreleasePoolChunk* firstChunk;           //!< \brief First chunk of objects
	id ownerThread;                             //!< \brief NSThread that owns the pool
}

/* Instance initialization */
/*! 
 *  \brief  Initialize the pool and set it as default.
 *
 *  \details Since autorelease pools are chained, this adds to the chain, and
 *  sets it as the default pool.
 */
- init;

/* Instance deallocation */
/*! 
 *  \brief  Empty pool and remove it from the chain.
 *
 *  \details This empties the autorelease pool, releasing all objects owned by
 *  it, and removes it from the chain.  This includes releasing all pools
 *  contained within it, all the way down to the default pool.  It also sets the
 *  default pool for the thread to its parent.
 */
- (void)dealloc;

/*!
 * \brief Adds an object to the active autorelease pool.
 * \param anObject The object to add.
 */
+ (void)addObject:anObject;

/*!
 * \brief Adds an object to the receiver.
 * \param anObject The object to add.
 */
- (void)addObject:anObject;

/*!
 * \brief Drains the receiver without deallocating it.
 *
 * \details This is used primarily by the RunLoop class.
 */
- (void) drain;

/* Default pool */
/*! 
 *  \brief  Returns the default NSAutoreleasePool object for this thread.
 *  \return the current autorelease pool.
 *
 *  \details  The default pool can change when a new pool is created in the
 *  thread.  At thread launch time there is always an NSAutoreleasePool, and new
 *  pools can be created at any time.
 */
+ defaultPool;

@end

/*!
 *  \class AutoreleasedPointer
 *  \brief Holds a pointer that should be released when the owning
 *  NSAutoreleasePool is released.
 *  
 *  \details Any pointer added as an AutoreleasedPointer is passed to free()
 *  when the NSAutoreleasePool is flushed.
 */
@interface NSAutoreleasedPointer : NSObject
{
@private
    void* theAddress;
}
/*!
 * \brief Add the given address to the current autorelease pool.
 * \param address Address to add.
 * \return New pointer wrapper object, already added to the pool.
 */
+ (id)autoreleasePointer:(void*)address;
/*!
 * \internal
 * \brief Initialize the pointer with the given address.
 */
- initWithPointerAddress:(void*)address;
@end

/*
   vim:syntax=objc:
 */
