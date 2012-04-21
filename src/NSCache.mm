/*
 * Copyright (c) 2011-2012	Justin Hibbits
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

#import <Foundation/NSCache.h>
#include <unordered_map>
#include <mutex>
using std::unordered_map;
using std::mutex;
using std::lock_guard;
#include <vector>
#import "internal.h"

// TODO: Think about adding all NSCache instances to a cache pool, to clear out
// all caches if necessary.

/* Policy states used in the cache:
   - Cost -- the cost of the object.  Used for cost-based eviction.
   - Count -- Number of times the object is accessed.
   - lastAccess -- Last access time.  For LRU-based eviction.
 */
struct cached_object
{
	cached_object(id inobj, NSUInteger _cost, NSUInteger _accTime, id k) :
		obj(inobj), key(k), cost(_cost) {}
	cached_object() {}
	__strong id obj;
	__weak id key;	// Weak reference to the key.
	NSUInteger cost = 0;
	NSUInteger count = 0;
	NSUInteger lastAccess = 0;
};

typedef unordered_map<id, cached_object> table_type;
@implementation NSCache
{
	NSString *name;
	NSUInteger countLimit;
	NSUInteger totalCostLimit;
	bool evictsObjectsWithDiscardedContent;
	id<NSCacheDelegate> delegate;
	mutex mtx;
	table_type table;
	NSUInteger currentAccess;
	NSUInteger currentCost;
}
@synthesize name;
@synthesize countLimit;
@synthesize totalCostLimit;
@synthesize evictsObjectsWithDiscardedContent;

- (id) init
{
	return self;
}

- (id) objectForKey:(id)key
{
	lock_guard<mutex> locker(mtx);

	auto iter = table.find(key);
	if (iter == table.end())
		return nil;
	++(currentAccess);
	iter->second.lastAccess = currentAccess;
	iter->second.count++;
	return iter->second.obj;
}

- (void) setObject:(id)obj forKey:(id)key
{
	[self setObject:obj forKey:key cost:0];
}

- (void) setObject:(id)obj forKey:(id)key cost:(NSUInteger)cost
{
	lock_guard<mutex> locker(mtx);

	++(currentAccess);
	currentCost += cost;
	table[key] = cached_object(obj, cost, currentAccess, key);
}

- (void) removeObjectForKey:(id)key
{
	lock_guard<mutex> locker(mtx);

	auto iter = table.find(key);

	if (iter == table.end())
		return;

	currentCost -= iter->second.cost;
	table.erase(iter);
}

- (void) removeAllObjects
{
	lock_guard<mutex> locker(mtx);
	table.clear();
}

- (id<NSCacheDelegate>) delegate
{
	return delegate;
}

- (void) setDelegate:(id<NSCacheDelegate>) newDel
{
	delegate = newDel;
}

- (void) _evictOldObjectsIfNeededForObjectWithCost:(NSUInteger)cost
{
	struct cache_sorter {
		bool operator()(cached_object *a, cached_object *b)
		{
			return (a->lastAccess < b->lastAccess);
		}
	};

	if ((currentCost + cost <= totalCostLimit) && 
			([self countLimit] > table.size()))
	{
		return;
	}

	std::vector<cached_object*> objs;

	for (auto i : table)
	{
		objs.push_back(&i.second);
	}
	std::sort(objs.begin(), objs.end(), cache_sorter());

	for (auto j : objs)
	{
		if (table.size() <= countLimit || currentCost < (totalCostLimit - cost))
		{
			break;
		}
		currentCost -= j->cost;
		if ([static_cast<id>(j->obj) conformsToProtocol:@protocol(NSDiscardableContent)])
		{
			if (![static_cast<id>(j->obj) isContentDiscarded])
			{
				[static_cast<id>(j->obj) discardContentIfPossible];
			}
			if (!evictsObjectsWithDiscardedContent)
			{
				continue;
			}
		}
		table.erase(j->key);
	}
}

@end
