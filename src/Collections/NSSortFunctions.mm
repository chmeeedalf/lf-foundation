/*
 * Copyright (c) 2012	Justin Hibbits
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

#include <dispatch/dispatch.h>

#include <algorithm>
#include <numeric>
#include <vector>

#import <Foundation/NSObjCRuntime.h>
#import "internal.h"

@protocol NSPrivateProtocol
- (void) exchangeObjectAtIndex:(NSUInteger)idx
	withObjectAtIndex:(NSUInteger)idx;
- (id) objectAtIndex:(NSUInteger)idx;
@end

void NSSortRangeUsingOptionsAndComparator(id collToSort, NSRange range,
		NSSortOptions opts, NSComparator cmp)
{
	static NSUInteger numCores = [[NSProcessInfo processInfo] activeProcessorCount];
	NSUInteger count = [collToSort count];
	NSUInteger coresToUse = 1;
	__block std::vector<NSUInteger> indexes;

	indexes.reserve(range.length);
	std::iota(indexes.begin(), indexes.end(), range.location);
	
	if (opts & NSSortConcurrent)
	{
		coresToUse = (count / 16);

		if (coresToUse > numCores)
			coresToUse = numCores;
		if (coresToUse < 1)
			coresToUse = 1;
	}
	dispatch_apply(coresToUse,
			dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
			^(size_t idx){
			if (opts & NSSortStable)
			{
			std::stable_sort(indexes.begin() + idx * 16,
				(idx == coresToUse - 1) ? indexes.end() : indexes.begin() + (idx+1) * 16,
				[&](const NSUInteger a, const NSUInteger b){
					return (cmp([collToSort objectAtIndex:a],
							[collToSort objectAtIndex:b]) == NSOrderedAscending);
				});
			}
			else
			{
			std::sort(indexes.begin() + idx * 16,
				(idx == coresToUse - 1) ? indexes.end() : indexes.begin() + (idx+1) * 16,
				[&](const NSUInteger a, const NSUInteger b){
					return (cmp([collToSort objectAtIndex:a],
							[collToSort objectAtIndex:b]) == NSOrderedAscending);
				});
			}
			});

	/* Will be ignored if not concurrent. */
	for (NSUInteger i = 1; i < coresToUse; i++)
	{
		std::inplace_merge(indexes.begin(), indexes.begin() + i * 16,
				(i == coresToUse - 1) ? indexes.end() : indexes.begin() + (i+1) * 16,
				[&](const NSUInteger a, const NSUInteger b){
					return (cmp([collToSort objectAtIndex:a],
							[collToSort objectAtIndex:b]) == NSOrderedAscending);
				});
	}

	for (NSUInteger i = 0; i < count; i++)
	{
		if (i != indexes[i])
		{
			[collToSort exchangeObjectAtIndex:i withObjectAtIndex:indexes[i]];
		}
	}
}
