/*
 * Copyright (c) 2012	Gold Project
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
#import <Foundation/NSKeyValueObserving.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSIndexSet.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import <unordered_map>

NSString *const NSKeyValueChangeKindKey = @"NSKeyValueChangeKindKey";
NSString *const NSKeyValueChangeNewKey = @"NSKeyValueChangeNewKey";
NSString *const NSKeyValueChangeOldKey = @"NSKeyValueChangeOldKey";
NSString *const NSKeyValueChangeIndexesKey = @"NSKeyValueChangeIndexesKey";
NSString *const NSKeyValueChangeNotificationIsPriorKey = @"NSKeyValueChangeNotificationIsPriorKey";
static char observationKey;

static std::unordered_map<void *, void *> observationInfos;

@implementation NSObject (NSKeyValueObserving)

+ (bool)automaticallyNotifiesObserversForKey:(NSString *)key
{
	return true;
}

+(NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key
{
	return [NSSet set];
}

-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)changeDict context:(void*)context
{
}

#define SETTER_BLOCK(type) imp_implementationWithBlock((__bridge void *)^(id self, type val){ \
	if ([self automaticallyNotifiesObserversForKey:key]) \
	{\
		[self willChangeValueForKey:key];\
		\
		[self didChangeValueForKey:key];\
	} \
	else \
	{\
		\
	}\
})

-(void)addObserver:(NSObject *)observer forKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options context:(void*)context
{
	IMP blkImp;
	SEL setSel;
	id key;

	setSel = NSSelectorFromString([NSString
			stringWithFormat:@"set%@:",[keyPath capitalizedString]]);
	blkImp = SETTER_BLOCK(id);
}

-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString*)keyPath
{
}

-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
}

-(void)willChangeValueForKey:(NSString*)key
{
}

-(void)willChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects
{
}

-(void)didChangeValueForKey:(NSString*)key
{
}

-(void)didChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects
{
}

-(void)willChange:(NSKeyValueChange)change valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key
{
}

-(void)didChange:(NSKeyValueChange)change valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key
{
}

- (void) setObservationInfo:(void *)info
{
	objc_setAssociatedObject(self, &observationKey, (__bridge id)info,
			OBJC_ASSOCIATION_ASSIGN);
}

- (void *) observationInfo
{
	return (__bridge void *)objc_getAssociatedObject(self, &observationKey);
}
@end