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

/* 
   ConcreteDictionary.h

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

#ifndef __ConcreteDictionary_h__
#define __ConcreteDictionary_h__

#import <Foundation/NSEnumerator.h>
#import <Foundation/NSMapTable.h>
#import "internal.h"
#ifdef __cplusplus
#include <unordered_map>
typedef std::unordered_map<id,id> _map_table;
#else
typedef struct _map_table *_map_table;
#endif

@interface NSCoreDictionary : NSMutableDictionary
{
	_map_table table;
}

/* Allocating and Initializing an NSDictionary */
- (id)initWithObjects:(const id [])objects forKeys:(const id<NSCopying>[])keys 
  count:(NSUInteger)count;
- (id)initWithDictionary:(NSDictionary*)dictionary;

/* Accessing keys and values */
- (id)objectForKey:(id)aKey;
- (NSUInteger)count;
- (NSEnumerator *)keyEnumerator;

/* Private */
- (_map_table *)__dictObject;

/* Allocating and Initializing an NSDictionary */
- (id)init;
- (id)initWithCapacity:(NSUInteger)aNumItems;


/* Modifying dictionary */
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;
- (void)removeObjectForKey:(id)theKey;
- (void)removeAllObjects;

@end /* ConcreteMutableDictionary */

/*
 * NSDictionary NSEnumerator classes
 */

@interface _CoreDictionaryEnumerator : NSEnumerator
{
	NSCoreDictionary *d;
	_map_table *table;
#ifdef __cplusplus
	_map_table::const_iterator i;
#else
	void *i;
#endif
	bool valEnum;
}

- (id) initWithDictionary:(NSCoreDictionary*)_dict;
- (id) nextObject;

@end /* _ConcreteDictionaryEnumerator */

#endif /* __ConcreteDictionary_h__ */
