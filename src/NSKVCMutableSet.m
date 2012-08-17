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

#import <Foundation/NSSet.h>

#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSKeyValueObserving.h>
#import <Foundation/NSString.h>
#import "NSKVCMutableSet.h"

@interface NSKVCFastMutableSet	:	NSKVCMutableSet
{
	SEL addSel;
	SEL addMSel;
	SEL rmSel;
	SEL rmMSel;
	SEL replSel;
	SEL replMSel;
}
@end

@interface NSKVCSlowMutableSet	:	NSKVCMutableSet
{
	SEL setSel;
}
@end

@interface NSKVCIvarMutableSet	:	NSKVCMutableSet
@end

@interface NSKVCDummyMutableSet	:	NSKVCMutableSet
@end

@implementation NSKVCMutableSet
{
	@protected
	id target;
	id owner;
	NSString *key;
}

+ (id) setWithTargetObject:(id)obj forKey:(NSString *)k
{
	id proxy;

	proxy = [[NSKVCFastMutableSet alloc] initWithTargetObject:obj forKey:k];

	if (proxy == nil)
	{
		proxy = [[NSKVCSlowMutableSet alloc] initWithTargetObject:obj forKey:k];

		if (proxy == nil)
		{
			proxy = [[NSKVCIvarMutableSet alloc] initWithTargetObject:obj forKey:k];
			if (proxy == nil)
			{
				proxy = [[NSKVCDummyMutableSet alloc] initWithTargetObject:obj forKey:k];
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

- (id) member:(id)memb
{
	return [[self _targetObject] member:(memb)];
}

- (NSUInteger) count
{
	return [[self _targetObject] count];
}

- (void) _realAddObject:(id)obj
{
}

- (void) addObject:(id)obj
{
	NSSet *objs = [NSSet setWithObject:obj];
	[self willChangeValueForKey:key withSetMutation:NSKeyValueUnionSetMutation usingObjects:objs];
	[self _realAddObject:obj];
	[self didChangeValueForKey:key withSetMutation:NSKeyValueUnionSetMutation usingObjects:objs];
}

- (void) _realUnionSet:(id)obj
{
}

- (void) unionSet:(id)obj
{
	[self willChangeValueForKey:key withSetMutation:NSKeyValueUnionSetMutation usingObjects:obj];
	[self _realUnionSet:obj];
	[self didChangeValueForKey:key withSetMutation:NSKeyValueUnionSetMutation usingObjects:obj];
}

- (void) _realRemoveObject:(id)obj
{
}

- (void) removeObject:(id)obj
{
	NSSet *objs = [NSSet setWithObject:obj];
	[self willChangeValueForKey:key withSetMutation:NSKeyValueMinusSetMutation usingObjects:objs];
	[self _realRemoveObject:obj];
	[self didChangeValueForKey:key withSetMutation:NSKeyValueMinusSetMutation usingObjects:objs];
}

- (void) _realMinusSet:(NSSet *)objs
{
}

- (void) minusSet:(NSSet *)objs
{
	[self willChangeValueForKey:key withSetMutation:NSKeyValueMinusSetMutation usingObjects:objs];
	[self _realMinusSet:objs];
	[self didChangeValueForKey:key withSetMutation:NSKeyValueMinusSetMutation usingObjects:objs];
}

@end

@implementation NSKVCFastMutableSet

- (id) initWithTargetObject:(id)obj forKey:(NSString *)k
{
	NSString *capKey = [k capitalizedString];

	key = k;
	if ((self = [super initWithTargetObject:obj forKey:k]) == nil)
	{
		return nil;
	}

	addSel = NSSelectorFromString([NSString stringWithFormat:@"add%@Object:",capKey]);
	rmSel = NSSelectorFromString([NSString stringWithFormat:@"remove%@Object:",capKey]);
	addMSel = NSSelectorFromString([NSString stringWithFormat:@"add%@:",capKey]);
	rmMSel = NSSelectorFromString([NSString stringWithFormat:@"remove%@:",capKey]);

	if (![obj respondsToSelector:addSel] && ![obj respondsToSelector:addMSel])
		return nil;

	if (![obj respondsToSelector:rmSel] && ![obj respondsToSelector:rmMSel])
		return nil;

	return self;
}

- (void) _realAddObject:(id)obj
{
	if (addSel != 0)
	{
		void (*ins)(id, SEL, id) = (void (*)(id,SEL,id))[[self _targetObject] methodForSelector:addMSel];
		ins([self _targetObject], addMSel, obj);
	}
	else
	{
		[self _realUnionSet:[NSSet setWithObject:obj]];
	}
	return;
}

- (void) _realUnionSet:(NSSet *)objs
{

	if (addMSel != 0)
	{
		void (*ins)(id, SEL, id) = (void (*)(id,SEL,id))[[self _targetObject] methodForSelector:addMSel];
		ins([self _targetObject], addMSel, objs);
	}
	else
	{
		[objs enumerateObjectsUsingBlock:^(id obj, bool *stop){
			[self _realAddObject:obj];
		}];
	}
}

- (void) _realRemoveObject:(id)obj
{
	if (rmSel != 0)
	{
		void (*rem)(id, SEL, id) = (void (*)(id,SEL,id))[[self _targetObject] methodForSelector:rmSel];
		rem([self _targetObject], rmSel, obj);
	}
	else
	{
		[self minusSet:[NSSet setWithObject:obj]];
	}
	return;
}

- (void) _realMinusSet:(NSSet *)other
{

	if (rmMSel != 0)
	{
		void (*rem)(id, SEL, id) = (void (*)(id,SEL,id))[[self _targetObject] methodForSelector:rmMSel];
		rem([self _targetObject], rmMSel, other);
	}
	else
	{
		[other enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, bool *stop){
			[self _realRemoveObject:obj];
		}];
	}
}

@end

@implementation NSKVCSlowMutableSet
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

- (void) _realAddObject:(id)obj
{
	NSMutableSet *arr = [NSMutableSet setWithSet:[target valueForKey:key]];
	[arr addObject:obj];
	[target setValue:arr forKey:key];
}

- (void) _realUnionSet:(id)objs
{
	NSMutableSet *arr = [NSMutableSet setWithSet:[target valueForKey:key]];
	[arr unionSet:objs];
	[target setValue:arr forKey:key];
}

- (void) _realRemoveObject:(id)obj
{
	NSMutableSet *arr = [NSMutableSet setWithSet:[target valueForKey:key]];
	[arr removeObject:obj];
	[target setValue:arr forKey:key];
}

- (void) _realMinusSet:(NSSet *)other
{
	NSMutableSet *arr = [NSMutableSet setWithSet:[target valueForKey:key]];
	[arr minusSet:other];
	[target setValue:arr forKey:key];
}
@end

@implementation NSKVCIvarMutableSet
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

- (void) _realAddObject:(id)obj
{
	[target addObject:obj];
}

- (void) _realUnionSet:(id)objs
{
	[target unionSet:objs];
}

- (void) _realRemoveObject:(id)obj
{
	[target removeObject:obj];
}

- (void) _realMinusSet:(NSSet *)objs
{
	[target minusSet:objs];
}
@end

@implementation NSKVCDummyMutableSet
- (id) initWithTargetObject:(id)obj forKey:(NSString *)k
{
	self = [super initWithTargetObject:obj forKey:k];
	return self;
}

- (void) addObject:(id)obj
{
	[target setValue:obj forUndefinedKey:key];
}

- (void) unionSet:(id)objs
{
	[target setValue:objs forUndefinedKey:key];
}

- (void) removeObject:(id)obj
{
	[target setValue:nil forUndefinedKey:key];
}

- (void) minusSet:(NSSet *)objs
{
	[target setValue:nil forUndefinedKey:key];
}

@end
