/* Copyright (c) 2007-2008 Johannes Fortmann

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSKeyValueObserving.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSException.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSString.h>
#import <Foundation/NSIndexSet.h>

#include <stdlib.h>
#include <stdio.h>
#import <string.h>
#import <ctype.h>

#import "NSString+KVCAdditions.h"
#import "KeyValueObserving-Private.h"

/*
 * XXX: Key-Value Observing is broken.
 */
NSString *const NSKeyValueChangeKindKey = @"NSKeyValueChangeKindKey";
NSString *const NSKeyValueChangeNewKey = @"NSKeyValueChangeNewKey";
NSString *const NSKeyValueChangeOldKey = @"NSKeyValueChangeOldKey";
NSString *const NSKeyValueChangeIndexesKey = @"NSKeyValueChangeIndexesKey";
NSString *const NSKeyValueChangeNotificationIsPriorKey = @"NSKeyValueChangeNotificationIsPriorKey";

static NSString *const _KVO_DependentKeysTriggeringChangeNotification = @"_NSKVO_DependentKeysTriggeringChangeNotification";
static NSString *const _KVO_KeyPathsForValuesAffectingValueForKey = @"_NSKVO_KeyPathsForValuesAffectingValueForKey";

static NSMutableDictionary *observationInfos = nil;
static NSLock *kvoLock = nil;

@interface NSObject (KVOSettersForwardReferencs)
+ (void)_KVO_buildDependencyUnion;
@end

@interface NSObject (KVCPrivateMethod)
- (void)_demangleTypeEncoding:(const char*)type to:(char*)cleanType;
@end

// definition for change type
#define CHANGE_DEFINE(type) - ( void ) KVO_notifying_change_##type:( type ) value

// selector for change type
#define CHANGE_SELECTOR(type) KVO_notifying_change_##type:

// original selector called by swizzled selector
#define ORIGINAL_SELECTOR(name) NSSelectorFromString([NSString stringWithFormat:@"_original_%@", name])

// FIX: add more types
@interface NSObject (KVOSetters)
CHANGE_DEFINE(float);
CHANGE_DEFINE(double);
CHANGE_DEFINE(id);
CHANGE_DEFINE(int);
CHANGE_DEFINE(NSSize);
CHANGE_DEFINE(NSPoint);
CHANGE_DEFINE(NSRect);
CHANGE_DEFINE(NSRange);
CHANGE_DEFINE(char);
CHANGE_DEFINE(long);
CHANGE_DEFINE(SEL);
@end

@implementation NSObject (KeyValueObserving)

- (void*)observationInfo
{
	return [[observationInfos objectForKey:[NSValue valueWithPointer:self]] pointerValue];
}

- (void)setObservationInfo:(void*)info
{
	if(!observationInfos)
	{
		observationInfos = [NSMutableDictionary new];
	}
	[observationInfos setObject:[NSValue valueWithPointer:info] forKey:[NSValue valueWithPointer:self]];
}

+ (void*)observationInfo
{
	return [[observationInfos objectForKey:[NSValue valueWithPointer:self]] pointerValue];
}

+ (void)setObservationInfo:(void*)info
{
	if(!observationInfos)
	{
		observationInfos = [NSMutableDictionary new];
	}
	[observationInfos setObject:[NSValue valueWithPointer:info] forKey:[NSValue valueWithPointer:self]];
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options context:(void*)context;
{
	[self _KVO_swizzle];
	NSString*remainingKeyPath;
	NSString*key;
	[keyPath _KVC_partBeforeDot:&key afterDot:&remainingKeyPath];

	// get observation info dictionary
	NSMutableDictionary*observationInfo = [self observationInfo];
	// get all observers for current key
	NSMutableArray *observers = [observationInfo objectForKey:key];

	// find if already observing
	_ObservationInfo *oldInfo = nil;
	_ObservationInfo *current;
	for (current in observers)
	{
		if(current->observer == observer)
		{
			oldInfo = current;
			break;
		}
	}

	// create new info
	_ObservationInfo *info = nil;
	if(oldInfo)
	{
		info = oldInfo;
	}
	else
	{
		info = [[_ObservationInfo new] autorelease];
	}

	// We now add the observer to the rest of the path, then to the dependents.
	// Any of the following may fail if a key path doesn't exist.
	// We have to keep track of how far we have come to be able to roll back.
	id lastPathTried = nil;
	NSSet*dependentPathsForKey = [object_getClass(self) keyPathsForValuesAffectingValueForKey:key];
	@try
	{
		// if observing a key path, also observe all deeper levels
		// info object acts as a proxy replacing remainingKeyPath with keyPath
		if([remainingKeyPath length])
		{
			lastPathTried = remainingKeyPath;
			[[self valueForKey:key] addObserver:info
			 forKeyPath:remainingKeyPath
			 options:options
			 context:context];
		}

		// now try all dependent key paths
		NSString *path;
		for (path in dependentPathsForKey)
		{
			lastPathTried = path;
			[self addObserver:info
			 forKeyPath:path
			 options:options
			 context:context];
		}
	}
	@catch(id ex)
	{
		// something went wrong. rollback all the work we've done so far.
		bool wasInDependentKey = false;

		if(lastPathTried != remainingKeyPath)
		{
			wasInDependentKey = true;
			// adding to a dependent path failed. roll back for all the paths before.
			if([remainingKeyPath length])
			{
				[[self valueForKey:key] removeObserver:info forKeyPath:remainingKeyPath];
			}

			NSString *path;
			for (path in dependentPathsForKey)
			{
				if(path == lastPathTried)
				{
					break; // this is the one that failed
				}
				[self removeObserver:info forKeyPath:path];
			}
		}

		// reformat exceptions to be more expressive
		if([ex isKindOfClass:[NSUndefinedKeyException class]])
		{
			if(!wasInDependentKey)
			{
				@throw([NSUndefinedKeyException exceptionWithReason:[NSString stringWithFormat:@"Undefined key while adding observer for key path %@ to object %p", keyPath, self] userInfo:nil]);
			}
			else
			{
				@throw([NSUndefinedKeyException exceptionWithReason:[NSString stringWithFormat:@"Undefined key while adding observer for dependent key path %@ to object %p", keyPath, self] userInfo:nil]);
			}
		}
		@throw;
	}

	// we were able to observe the full length of our key path, and the dependents.
	// now make the changes to our own observers array

	// create observation info dictionary if it's not there
	// (we have to re-check: it may have been created while observing our dependents
	if(!observationInfo && !(observationInfo = [self observationInfo]))
	{
		[self setObservationInfo:[NSMutableDictionary new]];
		observationInfo = [self observationInfo];
		observers = [observationInfo objectForKey:key];
	}

	// get all observers for current key
	if(!observers)
	{
		observers = [NSMutableArray new];
		[observationInfo setObject:observers forKey:key];
		[observers release];
	}

	// set info options
	info->observer = observer;
	info->options = options;
	info->context = context;
	info->object = self;
	[info setKeyPath:keyPath];

	if(!oldInfo)
	{
		[observers addObject:info];
	}

	if(options & NSKeyValueObservingOptionInitial)
	{
		[self willChangeValueForKey:keyPath];
		[self didChangeValueForKey:keyPath];
	}
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString*)keyPath;
{
	NSString*key, *remainingKeyPath;
	[keyPath _KVC_partBeforeDot:&key afterDot:&remainingKeyPath];

	// now remove own observer
	NSMutableDictionary*observationInfo = [self observationInfo];
	NSMutableArray *observers = [observationInfo objectForKey:key];

	_ObservationInfo *info;
	for (info in [[observers copy] autorelease])
	{
		if(info->observer == observer)
		{
			[[info retain] autorelease];
			[observers removeObject:info];
			if(![observers count])
			{
				[observationInfo removeObjectForKey:key];
			}
			if(![observationInfo count])
			{
				[self setObservationInfo:nil];
				[observationInfo release];
			}

			if(remainingKeyPath)
			{
				[[self valueForKey:key] removeObserver:info forKeyPath:remainingKeyPath];
			}

			NSSet*keysPathsForKey = [object_getClass(self) keyPathsForValuesAffectingValueForKey:key];
			NSString *path;
			for (path in keysPathsForKey)
			{
				[self removeObserver:info
				 forKeyPath:path];
			}

			return;
		}
	}
	// 10.4 Apple implementation will crash at this point...
	@throw([NSException exceptionWithName:@"KVOException" reason:[NSString stringWithFormat:@"trying to remove observer %@ for unobserved key path %@", observer, keyPath] userInfo:nil]);
}

- (void)willChangeValueForKey:(NSString*)key
{
	NSMutableDictionary *dict = [NSMutableDictionary new];

	[dict setObject:[NSNumber numberWithInt:NSKeyValueChangeSetting]
	 forKey:@"KeyValueChangeKindKey"];
	[self _willChangeValueForKey:key changeOptions:dict];
	[dict release];
}

- (void)didChangeValueForKey:(NSString*)key
{
	[self _didChangeValueForKey:key changeOptions:nil];
}

- (void)willChange:(NSKeyValueChange)change valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key
{
	NSMutableDictionary *dict = [NSMutableDictionary new];

	[dict setObject:[NSNumber numberWithInt:change]
	 forKey:NSKeyValueChangeKindKey];
	[dict setObject:indexes
	 forKey:NSKeyValueChangeIndexesKey];
	[self _willChangeValueForKey:key changeOptions:dict];
	[dict release];
}

- (void)didChange:(NSKeyValueChange)change valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key
{
	[self _didChangeValueForKey:key changeOptions:nil];
}

- (void)_willChangeValueForKey:(NSString*)key changeOptions:(NSDictionary*)changeOptions
{
	NSMutableDictionary*observationInfo = [self observationInfo];

	if(!observationInfo)
	{
		return;
	}

	NSMutableArray *observers = [observationInfo objectForKey:key];

	_ObservationInfo *info;
	for (info in [[observers copy] autorelease])
	{
		// increment change count for nested did/willChangeValue's
		info->willChangeCount++;
		if(info->willChangeCount > 1)
		{
			continue;
		}
		NSString*keyPath = info->keyPath;

		if(![info changeDictionary])
		{
			id cd = [changeOptions copy];
			[info setChangeDictionary:cd];
			[cd release];
		}

		// store old value if applicable
		if(info->options & NSKeyValueObservingOptionOld)
		{
			id idxs = [info->changeDictionary objectForKey:NSKeyValueChangeIndexesKey];

			if(idxs)
			{
				int type = [[info->changeDictionary objectForKey:NSKeyValueChangeKindKey] intValue];
				// for to-many relationships, oldvalue is only sensible for replace and remove
				if(type == NSKeyValueChangeReplacement ||
				   type == NSKeyValueChangeRemoval)
				{
					[info->changeDictionary setValue:[[self mutableArrayValueForKeyPath:keyPath] objectsAtIndexes:idxs] forKey:NSKeyValueChangeOldKey];
				}
			}
			else
			{
				[info->changeDictionary setValue:[self valueForKeyPath:keyPath] forKey:NSKeyValueChangeOldKey];
			}
		}

		// inform observer of change
		if(info->options & NSKeyValueObservingOptionPrior)
		{
			[info->changeDictionary setObject:[NSNumber numberWithBool:true]
			 forKey:NSKeyValueChangeNotificationIsPriorKey];
			[info->observer observeValueForKeyPath:info->keyPath
			 ofObject:self
			 change:info->changeDictionary
			 context:info->context];
			[info->changeDictionary removeObjectForKey:NSKeyValueChangeNotificationIsPriorKey];
		}

		NSString*firstPart, *rest;
		[keyPath _KVC_partBeforeDot:&firstPart afterDot:&rest];

		// remove deeper levels (those items will change)
		if(rest)
		{
			[[self valueForKey:firstPart] removeObserver:info forKeyPath:rest];
		}
	}
}

- (void)_didChangeValueForKey:(NSString*)key changeOptions:(NSDictionary*)ignored
{
	NSMutableDictionary*observationInfo = [self observationInfo];

	if(!observationInfo)
	{
		return;
	}

	NSMutableArray *observers = [[observationInfo objectForKey:key] copy];
	_ObservationInfo *info;
	for (info in observers)
	{
		// decrement count and only notify after last didChange
		info->willChangeCount--;
		if(info->willChangeCount > 0)
		{
			continue;
		}
		NSString*keyPath = info->keyPath;

		// store new value if applicable
		if(info->options & NSKeyValueObservingOptionNew)
		{
			id idxs = [info->changeDictionary objectForKey:NSKeyValueChangeIndexesKey];
			if(idxs)
			{
				int type = [[info->changeDictionary objectForKey:NSKeyValueChangeKindKey] intValue];
				// for to-many relationships, newvalue is only sensible for replace and insert

				if(type == NSKeyValueChangeReplacement ||
				   type == NSKeyValueChangeInsertion)
				{
					[info->changeDictionary setValue:[[self mutableArrayValueForKeyPath:keyPath] objectsAtIndexes:idxs] forKey:NSKeyValueChangeNewKey];
				}
			}
			else
			{
				[info->changeDictionary setValue:[self valueForKeyPath:keyPath] forKey:NSKeyValueChangeNewKey];
			}
		}

		// restore deeper observers if applicable
		NSString*firstPart, *rest;
		[keyPath _KVC_partBeforeDot:&firstPart afterDot:&rest];

		if(rest)
		{
			[[self valueForKey:firstPart]
			 addObserver:info
			 forKeyPath:rest
			 options:info->options
			 context:info->context];
		}

		// inform observer of change
		[info->observer observeValueForKeyPath:info->keyPath
		 ofObject:self
		 change:info->changeDictionary
		 context:info->context];

		[info setChangeDictionary:nil];
	}
	[observers release];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
	NSString *methodName = [[NSString alloc] initWithFormat:@"keyPathsForValuesAffecting%@", [key capitalizedString]];
	NSSet*ret = nil;
	SEL sel = NSSelectorFromString(methodName);

	if([self respondsToSelector:sel])
	{
		ret = [self performSelector:sel];
	}
	else
	{
		[self _KVO_buildDependencyUnion];
		NSMutableDictionary*observationInfo = [self observationInfo];
		NSMutableDictionary *keyPathsByKey = [observationInfo objectForKey:_KVO_KeyPathsForValuesAffectingValueForKey];
		ret = [keyPathsByKey objectForKey:key];
	}
	[methodName release];
	return ret;
}

- (void)KVO_notifying_change_setObject:(id)object forKey:(NSString*)key
{
	[self willChangeValueForKey:key];
	typedef id (*sender)(id obj, SEL selector, id object, id key);
	sender implementation = (sender)[[self superclass] instanceMethodForSelector:_cmd];
	implementation(self, _cmd, object, key);
	[self didChangeValueForKey:key];
}

- (void)KVO_notifying_change_removeObjectForKey:(NSString*)key
{
	[self willChangeValueForKey:key];
	typedef id (*sender)(id obj, SEL selector, id key);
	sender implementation = (sender)[[self superclass] instanceMethodForSelector:_cmd];
	implementation(self, _cmd, key);
	[self didChangeValueForKey:key];
}

- (void)KVO_notifying_change_insertObject:(id)object inKeyAtIndex:(int)index
{
	const char*origName = sel_getName(_cmd);

	int selLen = strlen(origName);
	char *sel = __builtin_alloca(selLen + 1);

	strcpy(sel, origName);
	sel[selLen - 1] = '\0';
	sel += strlen("insertObject:in");
	sel[strlen(sel) - strlen("AtIndex:") + 1] = '\0';

	sel[0] = tolower(sel[0]);

	NSString *key = [[NSString alloc] initWithCString:sel encoding:NSASCIIStringEncoding];
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:key];
	typedef id (*sender)(id obj, SEL selector, id value, int index);
	sender implementation = (sender)[[self superclass] instanceMethodForSelector:_cmd];
	(void)*implementation(self, _cmd, object, index);
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:key];
	[key release];
}

- (void)KVO_notifying_change_addKeyObject:(id)object
{
	const char*origName = sel_getName(_cmd);

	int selLen = strlen(origName);
	char *sel = __builtin_alloca(selLen + 1);

	strcpy(sel, origName);
	sel[selLen - 1] = '\0';
	sel += strlen("add");
	sel[strlen(sel) - strlen("NSObject:") + 1] = '\0';

	char *countSelName = __builtin_alloca(strlen(sel) + strlen("countOf") + 1);
	strcpy(countSelName, "countOf");
	strcat(countSelName, sel);

	unsigned int idx = (int)[self performSelector:sel_getUid(countSelName)];

	sel[0] = tolower(sel[0]);

	NSString *key = [[NSString alloc] initWithCString:sel encoding:NSASCIIStringEncoding];
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:key];
	typedef id (*sender)(id obj, SEL selector, id value);
	sender implementation = (sender)[[self superclass] instanceMethodForSelector:_cmd];
	(void)*implementation(self, _cmd, object);
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:key];
	[key release];
}

- (void)KVO_notifying_change_removeKeyObject:(id)object
{
	const char*origName = sel_getName(_cmd);

	int selLen = strlen(origName);
	char *sel = __builtin_alloca(selLen + 1);

	strcpy(sel, origName);
	sel[selLen - 1] = '\0';
	sel += strlen("remove");
	sel[strlen(sel) - strlen("NSObject:") + 1] = '\0';

	char *countSelName = __builtin_alloca(strlen(sel) + strlen("countOf") + 1);
	strcpy(countSelName, "countOf");
	strcat(countSelName, sel);

	unsigned int idx = (unsigned int)[self performSelector:sel_getUid(countSelName)];

	sel[0] = tolower(sel[0]);

	NSString *key = [[NSString alloc] initWithCString:sel encoding:NSASCIIStringEncoding];
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:key];
	typedef id (*sender)(id obj, SEL selector, id value);
	sender implementation = (sender)[[self superclass] instanceMethodForSelector:_cmd];
	(void)*implementation(self, _cmd, object);
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:idx] forKey:key];
	[key release];
}

- (void)KVO_notifying_change_removeObjectFromKeyAtIndex:(int)index
{
	const char*origName = sel_getName(_cmd);
	int selLen = strlen(origName);
	char *sel = __builtin_alloca(selLen + 1);

	strcpy(sel, origName);
	sel[selLen - 1] = '\0';
	sel += strlen("removeObjectFrom");
	sel[strlen(sel) - strlen("AtIndex:") + 1] = '\0';

	sel[0] = tolower(sel[0]);
	NSString *key = [[NSString alloc] initWithCString:sel encoding:NSASCIIStringEncoding];
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:key];
	typedef id (*sender)(id obj, SEL selector, int index);
	sender implementation = (sender)[[self superclass] instanceMethodForSelector:_cmd];
	(void)*implementation(self, _cmd, index);
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:key];
	[key release];
}

- (void)KVO_notifying_change_replaceObjectInKeyAtIndex:(int)index withObject:(id)object
{
	const char*origName = sel_getName(_cmd);
	int selLen = strlen(origName);
	char *sel = __builtin_alloca(selLen + 1);

	strcpy(sel, origName);
	sel[selLen - 1] = '\0';
	sel += strlen("replaceObjectIn");
	sel[strlen(sel) - strlen("AtIndex:WithObject:") + 1] = '\0';
	sel[0] = tolower(sel[0]);

	NSString *key = [[NSString alloc] initWithCString:sel encoding:NSASCIIStringEncoding];
	[self willChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:key];
	typedef id (*sender)(id obj, SEL selector, int index, id object);
	sender implementation = (sender)[[self superclass] instanceMethodForSelector:_cmd];
	(void)*implementation(self, _cmd, index, object);
	[self didChange:NSKeyValueChangeReplacement valuesAtIndexes:[NSIndexSet indexSetWithIndex:index] forKey:key];
	[key release];
}

- (id)_KVO_className
{
	return [NSString stringWithCString:object_getClassName(self) + strlen("KVONotifying_") encoding:[NSString defaultCStringEncoding]];
}

+ (void)_KVO_buildDependencyUnion
{
	/*
	 * This method gathers dependent keys from all superclasses and merges them together
	 */
	NSMutableDictionary*observationInfo = [self observationInfo];

	if(!observationInfo)
	{
		[self setObservationInfo:[NSMutableDictionary new]];
		observationInfo = [self observationInfo];
	}

	NSMutableDictionary *keyPathsByKey = [NSMutableDictionary dictionary];

	id class = self;
	while(class != [NSObject class])
	{
		NSMutableDictionary*classDependents = [(NSMutableDictionary*)[class observationInfo] objectForKey:_KVO_DependentKeysTriggeringChangeNotification];

		id key;
		for (key in [classDependents allKeys])
		{
			id value;
			for (value in [classDependents objectForKey:key])
			{
				NSMutableSet *pathSet = [keyPathsByKey objectForKey:value];
				if(!pathSet)
				{
					pathSet = [NSMutableSet set];
					[keyPathsByKey setObject:pathSet forKey:value];
				}
				[pathSet addObject:key];
			}
		}

		class = [class superclass];
	}
	[observationInfo setObject:keyPathsByKey
	 forKey:_KVO_KeyPathsForValuesAffectingValueForKey];
}

- (void)_KVO_swizzle
{
	NSString*className = [self className];

	if([className hasPrefix:@"KVONotifying_"])
	{
		return; // this class is already swizzled
	}
	[kvoLock lock];
	isa = [self _KVO_swizzledClass];
	[kvoLock unlock];
}

- (Class)_KVO_swizzledClass
{
	// find swizzled class
	char *swizzledName;
	Class swizzledClass;

	asprintf(&swizzledName, "KVONotifying_%s", object_getClassName([self class]));
	swizzledClass = objc_lookUpClass(swizzledName);

	if(swizzledClass)
	{
		return swizzledClass;
	}

	// swizzled class doesn't exist; create
	swizzledClass = objc_allocateClassPair(object_getClass(self), swizzledName, 0);
	if (swizzledClass != Nil)
	{
		objc_registerClassPair(swizzledClass);
	}
	else
	{
		@throw([NSException exceptionWithName:@"ClassCreationException"
		        reason:[NSString stringWithFormat:@"couldn't swizzle class %@ for KVO", [self className]] userInfo:nil]);
	}

	// add KVO-Observing methods
	{
		// override className so it returns the original class name
		Method className = class_getInstanceMethod([self class], @selector(_KVO_className));
		class_addMethod(swizzledClass, @selector(className), method_getImplementation(className), method_getTypeEncoding(className));
	}

	Class currentClass = object_getClass(self);
	while(currentClass)
	{
		int i;
		unsigned int count = 0;
		Method *methods = class_copyMethodList(currentClass, &count);
		for (i = 0; i < count; i++)
		{
			Method method = methods[i];
			NSString*methodName = NSStringFromSelector(method_getName(method));
			NSMethodSignature *methodSig = [self methodSignatureForSelector:method_getName(method)];
			size_t argCount = [methodSig numberOfArguments];
			SEL kvoSelector = 0;

			// current method is a setter?
			if([methodName hasPrefix:@"set"] &&
			   ([methodSig numberOfArguments] == 3) &&
			   [[self class] automaticallyNotifiesObserversForKey:[methodName _KVC_setterKeyNameFromSelectorName]])
			{
				const char*firstParameterType = [methodSig getArgumentTypeAtIndex:2];
				const char*returnType = [methodSig methodReturnType];

				char *cleanFirstParameterType = __builtin_alloca(strlen(firstParameterType) + 1);
				[self _demangleTypeEncoding:firstParameterType to:cleanFirstParameterType];

				/* check for correct type: either perfect match
				 * or primitive signed type matching unsigned type
				 * (i.e. tolower(@encode(unsigned long)[0])==@encode(long)[0])
				 */
#define CHECK_AND_ASSIGN(a) \
	if(!strcmp(cleanFirstParameterType, @encode(a)) || \
	   (strlen(@encode(a)) == 1 && \
	    strlen(cleanFirstParameterType) == 1 && \
	    tolower(cleanFirstParameterType[0]) == @encode(a)[0])) \
	{ \
		kvoSelector = @selector(CHANGE_SELECTOR(a)); \
	}
				// FIX: add more types
				CHECK_AND_ASSIGN(id);
				CHECK_AND_ASSIGN(float);
				CHECK_AND_ASSIGN(double);
				CHECK_AND_ASSIGN(int);
				CHECK_AND_ASSIGN(NSSize);
				CHECK_AND_ASSIGN(NSPoint);
				CHECK_AND_ASSIGN(NSRect);
				CHECK_AND_ASSIGN(NSRange);
				CHECK_AND_ASSIGN(char);
				CHECK_AND_ASSIGN(long);
				CHECK_AND_ASSIGN(SEL);

				if(returnType[0] != _C_VOID)
				{
					kvoSelector = 0;
				}
			}

			// long selectors
			if(kvoSelector == 0)
			{
				id ret = nil;

				if([methodName _KVC_setterKeyName:&ret forSelectorNameStartingWith:@"insertObject:in" endingWith:@"AtIndex:"] &&
				   ret &&
				   argCount == 4)
				{
					kvoSelector = @selector(KVO_notifying_change_insertObject:inKeyAtIndex:);
				}
				else if([methodName _KVC_setterKeyName:&ret forSelectorNameStartingWith:@"removeObjectFrom" endingWith:@"AtIndex:"] &&
				        ret &&
				        argCount == 3)
				{
					kvoSelector = @selector(KVO_notifying_change_removeObjectFromKeyAtIndex:);
				}
				else if([methodName _KVC_setterKeyName:&ret forSelectorNameStartingWith:@"replaceObjectIn" endingWith:@"AtIndex:withObject:"] &&
				        ret &&
				        argCount == 4)
				{
					kvoSelector = @selector(KVO_notifying_change_replaceObjectInKeyAtIndex:withObject:);
				}
				else if([methodName _KVC_setterKeyName:&ret forSelectorNameStartingWith:@"remove" endingWith:@"NSObject:"] &&
				        ret &&
				        argCount == 3)
				{
					kvoSelector = @selector(KVO_notifying_change_removeKeyObject:);
				}
				else if([methodName _KVC_setterKeyName:&ret forSelectorNameStartingWith:@"add" endingWith:@"NSObject:"] &&
				        ret &&
				        argCount == 3)
				{
					kvoSelector = @selector(KVO_notifying_change_addKeyObject:);
				}
			}

			// these are swizzled so e.g. subclasses of NSDictionary get change notifications in setObject:forKey:
			//
			if([methodName isEqualToString:@"setObject:forKey:"])
			{
				kvoSelector = @selector(KVO_notifying_change_setObject:forKey:);
			}
			if([methodName isEqualToString:@"removeObjectForKey:"])
			{
				kvoSelector = @selector(KVO_notifying_change_removeObjectForKey:forKey:);
			}

			// there's a suitable selector for us
			if(kvoSelector != 0)
			{
				class_addMethod(swizzledClass, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method));
			}
		}
		if (methods)
		{
			free(methods);
		}
		currentClass = class_getSuperclass(currentClass);
		if(currentClass == Nil || class_getSuperclass(currentClass) == currentClass)
		{
			break;
		}
	}
#undef CHECK_AND_ASSIGN

	// done
	return swizzledClass;
}

+ (bool)automaticallyNotifiesObserversForKey:(NSString *)key;
{
	return true;
}

/* Default implementation */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
change:(NSDictionary *)change context:(void *)context
{
}

@end

/* The following functions define suitable setters and getters which
 * call willChangeValueForKey: and didChangeValueForKey: on their superclass
 * _KVO_swizzle changes the class of its object to a subclass which overrides
 * each setter with a suitable KVO-Notifying one.
 */

// declaration of change function:
// extracts key from selector called, calls original function
#define CHANGE_DECLARATION(type) CHANGE_DEFINE(type) \
	{ \
		const char*origName = sel_getName(_cmd); \
		int selLen = strlen(origName); \
		char *sel = alloca(selLen + 1); \
		strcpy(sel, origName); \
		sel[selLen - 1] = '\0'; \
		if(sel[0] == '_') {                         \
			sel += 4; }                 \
		else{              \
			sel += 3; }                 \
		sel[0] = tolower(sel[0]); \
		NSString *key = [[NSString alloc] initWithCString:sel encoding:NSASCIIStringEncoding]; \
		[self willChangeValueForKey:key]; \
		typedef id (*sender)(id obj, SEL selector, type value); \
		sender implementation = (sender)[[self superclass] instanceMethodForSelector:_cmd]; \
		(void)*implementation(self, _cmd, value); \
		[self didChangeValueForKey:key]; \
		[key release]; \
	}

@implementation NSObject (KVOSetters)
CHANGE_DECLARATION(float)
CHANGE_DECLARATION(double)
CHANGE_DECLARATION(id)
CHANGE_DECLARATION(int)
CHANGE_DECLARATION(NSSize)
CHANGE_DECLARATION(NSPoint)
CHANGE_DECLARATION(NSRect)
CHANGE_DECLARATION(NSRange)
CHANGE_DECLARATION(char)
CHANGE_DECLARATION(long)
CHANGE_DECLARATION(SEL)
@end

@implementation _ObservationInfo
- (NSString*)keyPath
{
	return [[keyPath retain] autorelease];
}

- (void)setKeyPath:(NSString*)value
{
	if (keyPath != value)
	{
		[keyPath release];
		keyPath = [value copy];
	}
}

- (id)changeDictionary
{
	return [[changeDictionary retain] autorelease];
}

- (void)setChangeDictionary:(id)value
{
	if (changeDictionary != value)
	{
		[changeDictionary release];
		changeDictionary = [value retain];
	}
}

- (id)observer
{
	return observer;
}

- (void)dealloc
{
	[keyPath release];
	[changeDictionary release];
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString*)subKeyPath ofObject:(id)subObject change:(NSDictionary*)changeDict context:(void*)subContext;
{
	[observer observeValueForKeyPath:keyPath
	 ofObject:object
	 change:changeDict
	 context:context];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ %p (%@ -> %@)>", [self className], self, keyPath, observer];
}
@end
