/*
 * Copyright (c) 2004,2005	Justin Hibbits
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
#import <Foundation/NSRange.h>

#ifdef __cplusplus
#include <algorithm>
#endif

/*!
 * \brief Matches NSFastEnumerationState per Apple's Objective-C 2.0 documents.
 */

struct NSFastEnumerationState;
typedef struct NSFastEnumerationState NSFastEnumerationState;
struct NSFastEnumerationState
{
	unsigned long state;
	__unsafe_unretained id *itemsPtr;
	unsigned long *mutationsPtr;
	unsigned long extra[ 5 ];

#ifdef __cplusplus
	explicit inline
	NSFastEnumerationState()
			: state(), itemsPtr(), mutationsPtr(), extra() {}
#endif
};

@class NSArray;

@protocol NSFastEnumeration
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])stackBuf count:(NSUInteger)len;
@end

/*!
 \class NSEnumerator
 \brief Base class for enumerators.

 \details This is an abstract base class for all enumerators.  Classes that can
 be enumerated over must provide an -enumerator method, and subclass this
 NSEnumerator class.
 */
@interface NSEnumerator	: NSObject <NSFastEnumeration>
{
	id nextObject; /*!< */
}

/*!
 * \brief Returns the next object in the collection being enumerated.  Returns nil when the collection has been traversed.
 */
-(id)nextObject;

- (NSArray *) allObjects;
@end

@interface NSBlockEnumerator : NSEnumerator
{
}

// The block gets copied.
- (id) initWithBlock:(id (^)())block;
@end

/*
   vim:syntax=objc:
 */
