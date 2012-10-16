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

#import <Foundation/NSOrderedSet.h>

#import <Foundation/NSIndexSet.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSKeyValueObserving.h>
#import <Foundation/NSString.h>
#import "NSKVCMutableOrderedSet.h"

@interface NSKVCFastMutableOrderedSet	:	NSKVCMutableOrderedSet
{
	SEL insertSel;
	SEL insertMSel;
	SEL rmSel;
	SEL rmMSel;
	SEL replSel;
	SEL replMSel;
}
@end

@interface NSKVCSlowMutableOrderedSet	:	NSKVCMutableOrderedSet
{
	SEL setSel;
}
@end

@interface NSKVCIvarMutableOrderedSet	:	NSKVCMutableOrderedSet
@end

@interface NSKVCDummyMutableOrderedSet	:	NSKVCMutableOrderedSet
@end

@implementation NSKVCMutableOrderedSet
{
	@protected
	id target;
	id owner;
	NSString *key;
}

+ (id) orderedSetWithTargetObject:(id)obj forKey:(NSString *)k
{
	id proxy;

	proxy = [[NSKVCFastMutableOrderedSet alloc] initWithTargetObject:obj forKey:k];

	if (proxy == nil)
	{
		proxy = [[NSKVCSlowMutableOrderedSet alloc] initWithTargetObject:obj forKey:k];

		if (proxy == nil)
		{
			proxy = [[NSKVCIvarMutableOrderedSet alloc] initWithTargetObject:obj forKey:k];
			if (proxy == nil)
			{
				proxy = [[NSKVCDummyMutableOrderedSet alloc] initWithTargetObject:obj forKey:k];
			}
		}
	}
	return proxy;
}

+ (bool) automaticallyNotifiesObserversForKey:(NSString *)k
{
	return false;
}

- (id) initWithTargetObject:(id)obj forKey:(NSString *)k
{
	if ((self = [super init]) == nil)
		return nil;

	owner = obj;
	key = [k copy];

	return self;
}

- (id) _targetObject
{
	if (target == nil)
		target = [owner valueForKey:key];
	return target;
}

- (id) objectAtIndex:(NSUInteger)idx
{
	return [[self _targetObject] objectAtIndex:idx];
}

- (NSUInteger) count
{
	return [[self _targetObject] count];
}

- (void) _realInsertObject:(id)obj atIndex:(NSUInteger)idx
{
}

- (void) insertObject:(id)obj atIndex:(NSUInteger)idx
{
	NSIndexSet *idxs = [NSIndexSet indexSetWithIndex:idx];
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:idxs forKey:key];
	[self _realInsertObject:obj atIndex:idx];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:idxs forKey:key];
}

- (void) _realInsertObjects:(id)obj atIndexes:(NSIndexSet *)indexes
{
}

- (void) insertObjects:(id)obj atIndexes:(NSIndexSet *)indexes
{
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:key];
	[self _realInsertObjects:obj atIndexes:indexes];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:key];
}

- (void) _realRemoveObjectAtIndex:(NSUInteger)idx
{
}

- (void) removeObjectAtIndex:(NSUInteger)idx
{
	NSIndexSet *idxs = [NSIndexSet indexSetWithIndex:idx];
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:idxs forKey:key];
	[self _realRemoveObjectAtIndex:idx];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:idxs forKey:key];
}

- (void) _realRemoveObjectsAtIndexes:(NSIndexSet *)indexes
{
}

- (void) removeObjectsAtIndexes:(NSIndexSet *)indexes
{
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:key];
	[self _realRemoveObjectsAtIndexes:indexes];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:key];
}

- (void) _realReplaceObjectAtIndex:(NSUInteger)idx withObject:(id)obj
{
	[self _realInsertObject:obj atIndex:idx];
	[self _realRemoveObjectAtIndex:idx+1];
}

- (void) replaceObjectAtIndex:(NSUInteger)idx withObject:(id)obj
{
	NSIndexSet *idxs = [NSIndexSet indexSetWithIndex:idx];
	[self willChange:NSKeyValueChangeReplacement valuesAtIndexes:idxs forKey:key];
	[self _realReplaceObjectAtIndex:idx withObject:obj];
	[self didChange:NSKeyValueChangeReplacement valuesAtIndexes:idxs forKey:key];
}

- (void) _realReplaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objs
{
	[self _realRemoveObjectsAtIndexes:indexes];
	[self _realInsertObjects:objs atIndexes:indexes];
}

- (void) replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objs
{
	[self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:key];
	[self _realReplaceObjectsAtIndexes:indexes withObjects:objs];
	[self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:key];
}

@end

@implementation NSKVCFastMutableOrderedSet

- (id) initWithTargetObject:(id)obj forKey:(NSString *)k
{
	NSString *capKey = [k capitalizedString];

	key = k;
	if ((self = [super initWithTargetObject:obj forKey:k]) == nil)
	{
		return nil;
	}

	insertSel = NSSelectorFromString([NSString stringWithFormat:@"insertObject:in%@AtIndex:",capKey]);
	rmSel = NSSelectorFromString([NSString stringWithFormat:@"removeObjectFrom%@AtIndex:",capKey]);
	insertMSel = NSSelectorFromString([NSString stringWithFormat:@"insert%@:atIndexes:",capKey]);
	rmMSel = NSSelectorFromString([NSString stringWithFormat:@"remove%@AtIndexes:",capKey]);

	if (![obj respondsToSelector:insertSel] && ![obj respondsToSelector:insertMSel])
		return nil;

	if (![obj respondsToSelector:rmSel] && ![obj respondsToSelector:rmMSel])
		return nil;

	if (![obj respondsToSelector:insertSel])
		insertSel = NULL;
	if (![obj respondsToSelector:insertMSel])
		insertMSel = NULL;
	if (![obj respondsToSelector:rmSel])
		rmSel = NULL;
	if (![obj respondsToSelector:rmMSel])
		rmMSel = NULL;
	if (![obj respondsToSelector:replSel])
		replSel = NULL;
	if (![obj respondsToSelector:replMSel])
		replMSel = NULL;

	return self;
}

- (void) _realInsertObject:(id)obj atIndex:(NSUInteger)idx
{
	if (insertSel != 0)
	{
		void (*ins)(id, SEL, id, NSUInteger) = (void (*)(id,SEL,id,NSUInteger))[[self _targetObject] methodForSelector:insertMSel];
		ins([self _targetObject], insertMSel, obj, idx);
	}
	else
	{
		[self _realInsertObjects:@[obj] atIndexes:[NSIndexSet indexSetWithIndex:idx]];
	}
	return;
}

- (void) _realInsertObjects:(NSArray *)objs atIndexes:(NSIndexSet *)indexes
{

	if (insertMSel != 0)
	{
		void (*ins)(id, SEL, id, id) = (void (*)(id,SEL,id,id))[[self _targetObject] methodForSelector:insertMSel];
		ins([self _targetObject], insertMSel, objs, indexes);
	}
	else
	{
		__block NSUInteger i = 0;
		[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, bool *stop){
			[self _realInsertObject:objs[i++] atIndex:idx];
		}];
	}
}

- (void) _realRemoveObjectAtIndex:(NSUInteger)idx
{
	if (rmSel != 0)
	{
		void (*rem)(id, SEL, NSUInteger) = (void (*)(id,SEL,NSUInteger))[[self _targetObject] methodForSelector:rmSel];
		rem([self _targetObject], rmSel, idx);
	}
	else
	{
		[self removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:idx]];
	}
	return;
}

- (void) _realRemoveObjectsAtIndexes:(NSIndexSet *)indexes
{

	if (rmMSel != 0)
	{
		void (*rem)(id, SEL, id) = (void (*)(id,SEL,id))[[self _targetObject] methodForSelector:rmMSel];
		rem([self _targetObject], rmMSel, indexes);
	}
	else
	{
		[indexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, bool *stop){
			[self _realRemoveObjectAtIndex:idx];
		}];
	}
}

- (void) _realReplaceObjectAtIndex:(NSUInteger)idx withObject:(id)obj
{
	if (replSel != NULL)
	{
		void (*repl)(id, SEL, NSUInteger, id) = (void (*)(id,SEL,NSUInteger,id))[[self _targetObject] methodForSelector:replSel];
		repl([self _targetObject], replSel, idx, obj);
	}
	else
	{
		[super _realReplaceObjectAtIndex:idx withObject:obj];
	}
}

- (void) _realRemoveObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(id)obj
{
	if (replMSel != NULL)
	{
		void (*repl)(id, SEL, id, id) = (void (*)(id,SEL,id,id))[[self _targetObject] methodForSelector:replMSel];
		repl([self _targetObject], replSel, indexes, obj);
	}
	else
	{
		[super _realReplaceObjectsAtIndexes:indexes withObjects:obj];
	}
}

@end

@implementation NSKVCSlowMutableOrderedSet
- (id) initWithTargetObject:(id)obj forKey:(NSString *)k
{
	if ((self = [super initWithTargetObject:obj forKey:k]) == nil)
		return nil;

	setSel = NSSelectorFromString([NSString stringWithFormat:@"set%@",[k capitalizedString]]);
	if (![obj respondsToSelector:setSel])
		return nil;

	target = owner;

	return self;
}

- (void) _realInsertObject:(id)obj atIndex:(NSUInteger)idx
{
	NSMutableOrderedSet *arr = [NSMutableOrderedSet orderedSetWithOrderedSet:[target valueForKey:key]];
	[arr insertObject:obj atIndex:idx];
	[target setValue:arr forKey:key];
}

- (void) _realInsertObjects:(id)objs atIndexes:(NSIndexSet *)idxs
{
	NSMutableOrderedSet *arr = [NSMutableOrderedSet orderedSetWithOrderedSet:[target valueForKey:key]];
	[arr insertObjects:objs atIndexes:idxs];
	[target setValue:arr forKey:key];
}

- (void) _realRemoveObjectAtIndex:(NSUInteger)idx
{
	NSMutableOrderedSet *arr = [NSMutableOrderedSet orderedSetWithOrderedSet:[target valueForKey:key]];
	[arr removeObjectAtIndex:idx];
	[target setValue:arr forKey:key];
}

- (void) _realRemoveObjectsAtIndexes:(NSIndexSet *)idxs
{
	NSMutableOrderedSet *arr = [NSMutableOrderedSet orderedSetWithOrderedSet:[target valueForKey:key]];
	[arr removeObjectsAtIndexes:idxs];
	[target setValue:arr forKey:key];
}

- (void) _realReplaceObjectAtIndex:(NSUInteger)idx withObject:(id)obj
{
	NSMutableOrderedSet *arr = [NSMutableOrderedSet orderedSetWithOrderedSet:[target valueForKey:key]];
	[arr replaceObjectAtIndex:idx withObject:obj];
	[target setValue:arr forKey:key];
}

- (void) _realReplaceObjectsAtIndexes:(NSIndexSet *)idxs withObjects:(id)objs
{
	[target replaceObjectsAtIndexes:idxs withObjects:objs];
	NSMutableOrderedSet *arr = [NSMutableOrderedSet orderedSetWithOrderedSet:[target valueForKey:key]];
	[arr replaceObjectsAtIndexes:idxs withObjects:objs];
	[target setValue:arr forKey:key];
}
@end

@implementation NSKVCIvarMutableOrderedSet
- (id) initWithTargetObject:(id)obj forKey:(NSString *)k
{
	if (![[obj class] accessInstanceVariablesDirectly])
	{
		return nil;
	}
	if ((self = [super initWithTargetObject:obj forKey:k]) == nil)
		return nil;

	char name[[k length] + 3];
	[key getCString:(name+1) maxLength:sizeof(name) encoding:NSASCIIStringEncoding];

	name[0] = '_';
	Ivar var = class_getInstanceVariable([obj class], name);

	if (var == NULL)
	{
		var = class_getInstanceVariable([obj class], &name[1]);
	}
	if (var == NULL)
	{
		return nil;
	}

	target = object_getIvar(obj, var);

	return self;
}

- (void) _realInsertObject:(id)obj atIndex:(NSUInteger)idx
{
	[target insertObject:obj atIndex:idx];
}

- (void) _realInsertObjects:(id)objs atIndexes:(NSIndexSet *)idxs
{
	[target insertObjects:objs atIndexes:idxs];
}

- (void) _realRemoveObjectAtIndex:(NSUInteger)idx
{
	[target removeObjectAtIndex:idx];
}

- (void) _realRemoveObjectsAtIndexes:(NSIndexSet *)idxs
{
	[target removeObjectsAtIndexes:idxs];
}

- (void) _realReplaceObjectAtIndex:(NSUInteger)idx withObject:(id)obj
{
	[target replaceObjectAtIndex:idx withObject:obj];
}

- (void) _realReplaceObjectsAtIndexes:(NSIndexSet *)idxs withObjects:(id)objs
{
	[target replaceObjectsAtIndexes:idxs withObjects:objs];
}
@end

@implementation NSKVCDummyMutableOrderedSet
- (id) initWithTargetObject:(id)obj forKey:(NSString *)k
{
	self = [super initWithTargetObject:obj forKey:k];
	return self;
}

- (void) insertObject:(id)obj atIndex:(NSUInteger)idx
{
	[target setValue:obj forUndefinedKey:key];
}

- (void) insertObjects:(id)objs atIndexes:(NSIndexSet *)idxs
{
	[target setValue:objs forUndefinedKey:key];
}

- (void) removeObjectAtIndex:(NSUInteger)idx
{
	[target setValue:nil forUndefinedKey:key];
}

- (void) removeObjectsAtIndexes:(NSIndexSet *)idxs
{
	[target setValue:nil forUndefinedKey:key];
}

- (void) replaceObjectAtIndex:(NSUInteger)idx withObject:(id)obj
{
	[target setValue:obj forUndefinedKey:key];
}

- (void) replaceObjectsAtIndexes:(NSIndexSet *)idxs withObjects:(id)objs
{
	[target setValue:objs forUndefinedKey:key];
}
@end
