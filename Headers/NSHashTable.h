/*
 * Copyright (c) 2009-2012	Gold Project
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

#import <Foundation/NSEnumerator.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSPointerFunctions.h>
#import <Foundation/Memory.h>

/*!
 * \file NSHashTable.h
 */
@class NSArray, NSEnumerator, NSSet, NSString;

@interface NSHashTable	:	NSObject<NSFastEnumeration>
{
}
+ (id) hashTableWithOptions:(NSPointerFunctionsOptions)options;
+ (id) hashTableWithWeakObjects;
- (id) initWithOptions:(NSPointerFunctionsOptions)options capacity:(size_t)cap;
- (id) initWithPointerFunctions:(NSPointerFunctions *)pfuncts capacity:(size_t)cap;

- (NSArray *)allObjects;
- (id)anyObject;
- (bool)containsObject:(id)obj;
- (size_t)count;
- (id)member:(id)obj;
- (NSEnumerator *)objectEnumerator;
- (NSSet *)setRepresentation;

- (void)addObject:(id)obj;
- (void)removeAllObjects;
- (void)removeObject:(id)obj;

- (bool)intersectsHashTable:(NSHashTable *)other;
- (bool)isEqualToHashTable:(NSHashTable *)other;
- (bool)isSubsetOfHashTable:(NSHashTable *)other;

- (void)intersetHashTable:(NSHashTable *)other;
- (void)minusHashTable:(NSHashTable *)other;
- (void)unionHashTable:(NSHashTable *)other;

- (NSPointerFunctions *)pointerFunctions;
@end
