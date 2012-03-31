/* $Gold$	*/
/*
 * All rights reserved.
 * Copyright (c) 2009-2011	Justin Hibbits
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

typedef size_t (*NSSizeFunction)(const void *);
typedef void *(*NSAcquireFunction)(const void *, NSSizeFunction, bool);
typedef NSString *(*NSDescriptionFunction)(const void *);
typedef NSHashCode (*NSHashFunction)(const void *, NSSizeFunction);
typedef bool (*NSIsEqualFunction)(const void *, const void *, NSSizeFunction);
typedef void (*NSRelinquishFunction)(const void *, NSSizeFunction);

typedef unsigned long NSPointerFunctionsOptions;

enum
{
	NSPointerFunctionsStrongMemory = (0 << 0),
	NSPointerFunctionsZeroingWeakMemory = (1 << 0),
	NSPointerFunctionsOpaqueMemory = (2 << 0),
	NSPointerFunctionsMallocMemory = (3 << 0),
	NSPointerFunctionsObjectPersonality = (0 << 8),
	NSPointerFunctionsOpaquePersonality = (1 << 8),
	NSPointerFunctionsObjectPointerPersonality = (2 << 8),
	NSPointerFunctionsCStringPersonality = (3 << 8),
	NSPointerFunctionsStructPersonality = (4 << 8),
	NSPointerFunctionsIntegerPersonality = (5 << 8),
	NSPointerFunctionsCopyIn = (1 << 16),
};

@interface NSPointerFunctions	:	NSObject<NSCopying>
{
	NSAcquireFunction acquireFunction;
	NSDescriptionFunction descriptionFunction;
	NSHashFunction hashFunction;
	NSIsEqualFunction isEqualFunction;
	NSRelinquishFunction relinquishFunction;
	NSSizeFunction sizeFunction;
	bool usesStrongWriteBarrier;
	bool usesWeakReadAndWriteBarriers;
}
@property NSAcquireFunction acquireFunction;
@property NSDescriptionFunction descriptionFunction;
@property NSHashFunction hashFunction;
@property NSIsEqualFunction isEqualFunction;
@property NSRelinquishFunction relinquishFunction;
@property NSSizeFunction sizeFunction;
@property bool usesStrongWriteBarrier;
@property bool usesWeakReadAndWriteBarriers;

+ (NSPointerFunctions *)pointerFunctionsWithOptions:(NSPointerFunctionsOptions)options;
- (id)initWithOptions:(NSPointerFunctionsOptions)options;
@end

#ifdef __cplusplus
namespace Gold
{
	struct Hash
	{
		NSSizeFunction size;
		NSHashFunction hash;
		Hash() {};
		Hash(NSPointerFunctions *funcs)
		{
			size = [funcs sizeFunction];
			hash = [funcs hashFunction];
		}
		size_t operator()(const void *const h) const
		{
			return hash(h, size);
		}
	};

	struct Equal
	{
		NSSizeFunction size;
		NSIsEqualFunction equal;
		Equal() {};
		Equal(NSPointerFunctions *funcs)
		{
			size = [funcs sizeFunction];
			equal = [funcs isEqualFunction];
		}
		size_t operator()(const void *const v1, const void *const v2) const
		{
			return equal(v1, v2, size);
		}
	};
}
#endif
