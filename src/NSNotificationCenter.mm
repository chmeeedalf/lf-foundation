/* 
   NSNotificationCenter.m

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

   This file is part of libSystem.

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

#import "internal.h"
#import <Foundation/NSHashTable.h>
#import <Foundation/NSMapTable.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#include <stdlib.h>

#define DEFAULT_CAPACITY 32

#define FREE_UNUSED_OBSERVED_OBJECTS 1
/*
 * Objects/selectors pair used in sets
 */

@interface NSNotificationListItem : NSObject
{
	@public
		/* weak */ id  observer;	// observer that will receive selector
	SEL selector;	        // is a postNotification:
	NSNotificationListItem* next; // this is needed for keeping a
	// linked list of items to be removed
}
- (id)initWithObject:(id)anObserver selector:(SEL)aSelector;
- (bool)isEqual:(id)_other;
- (unsigned)hash;
- (void)postNotification:(NSNotification*)notification;
@end

@implementation NSNotificationListItem

- (id)initWithObject:(id)anObserver selector:(SEL)aSelector
{
	self->observer = anObserver;
	self->selector = aSelector;
	return self;
}

- (bool)isEqual:(id)other
{
	if ([other isKindOfClass:[NSNotificationListItem class]])
	{
		NSNotificationListItem *obj;
		obj = other;
		return (observer == obj->observer) && sel_isEqual(selector, obj->selector);
	}

	return false;
}

- (unsigned)hash
{
	return ((long)observer >> 4) + (uintptr_t)selector;
}

- (void)postNotification:(NSNotification*)notification
{
	[self->observer performSelector:self->selector withObject:notification];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ 0x%08X: observer=%@ sel=%@>",
		   NSStringFromClass([self class]), self,
		   self->observer, NSStringFromSelector(self->selector)
			   ];
}

@end /* NSNotificationListItem */

/*
 * Register for objects to observer mapping
 */

@interface NSNotificationObserverRegister : NSObject
{
	NSHashTable *observerItems;
	@public
		void (*addObserver)(id,SEL,id,SEL);
	void (*remObserver)(id,SEL,id);
}
- (id)init;
- (unsigned int)count;
- (void)addObjectsToList:(NSMutableArray*)list;
- (void)addObserver:(id)observer selector:(SEL)selector;
- (void)removeObserver:(id)observer;
@end

@implementation NSNotificationObserverRegister

- (id)init
{
	self->observerItems = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality capacity:DEFAULT_CAPACITY];
	self->addObserver = (void *)
		[self methodForSelector:@selector(addObserver:selector:)];
	self->remObserver = (void *)
		[self methodForSelector:@selector(removeObserver:)];
	return self;
}

- (void)dealloc
{
	[observerItems release];
	[super dealloc];
}

- (unsigned int)count
{
	return [observerItems count];
}

- (void)addObjectsToList:(NSMutableArray *)list
{
	void (*addObj)(id, SEL, id);

	if (list == nil)
		return;

	addObj = (void *)[list methodForSelector:@selector(addObject:)];

	for (id reg in observerItems)
	{
		addObj(list, @selector(addObject:), reg);
	}
}

- (void)addObserver:(id)observer selector:(SEL)selector
{
	NSNotificationListItem *reg;

	reg = [[NSNotificationListItem alloc]
		initWithObject:observer selector:selector];
	[observerItems addObject:reg];
	RELEASE(reg);
}

- (void)removeObserver:(id)observer
{
	NSNotificationListItem *listItem = nil;
	NSNotificationListItem *reg;

	for (reg in observerItems)
	{
		if (reg->observer == observer)
		{
			/* Add 'reg' to the linked list of ListItems. We use this schema here
			   to avoid allocating anything, this can trigger finalization calls
			   in the case of Boehm's GC. */
			reg->next = listItem;
			listItem = reg;
		}
	}
	while (listItem)
	{
		[observerItems removeObject:listItem];
		listItem = listItem->next;
	}
}

@end /* NSNotificationObserverRegister */

/*
 * Register for objects to observer mapping
 */

@interface NSNotificationObjectRegister : NSObject
{
	/* key is the object, value is an NSNotificationObserverRegister */
	NSMapTable                     *objectObservers;
	NSNotificationObserverRegister *nilObjectObservers;
}

- (id)init;
- (NSArray *)listToNotifyForObject:(id)object;
- (void)addObserver:(id)observer selector:(SEL)selector object:(id)object;
- (void)removeObserver:(id)observer object:(id)object;
- (void)removeObserver:(id)observer;

@end

@implementation NSNotificationObjectRegister

- (id)init
{
	self->objectObservers =
		[[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsZeroingWeakMemory|NSPointerFunctionsOpaquePersonality valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality capacity:DEFAULT_CAPACITY];

	self->nilObjectObservers =
		[[NSNotificationObserverRegister allocWithZone:[self zone]] init];
	return self;
}

- (void)dealloc
{
	[objectObservers release];
	RELEASE(self->nilObjectObservers);
	[super dealloc];
}

- (NSArray *)listToNotifyForObject:(id)object
{
	NSNotificationObserverRegister *reg = nil;
	int count;
	id  list;

	if (object)
		reg = (id)[self->objectObservers objectForKey:object];

	count = [reg count] + [nilObjectObservers count];
	list  = [[NSMutableArray alloc] initWithCapacity:count];

	[reg addObjectsToList:list];
	[nilObjectObservers addObjectsToList:list];

	return AUTORELEASE(list);
}

- (void)addObserver:(id)observer selector:(SEL)selector object:(id)object
{
	NSNotificationObserverRegister *reg;

	if (object)
	{
		reg = [objectObservers objectForKey:object];
		if (reg == nil)
		{
			reg = [[NSNotificationObserverRegister alloc] init];
			[objectObservers setObject:reg forKey:object];
			RELEASE(reg);
		}
	}
	else
		reg = nilObjectObservers;

	reg->addObserver(reg, @selector(addObserver:selector:),
			observer, selector);
}

- (void)removeObserver:(id)observer object:(id)object
{
	NSNotificationObserverRegister *reg;

	reg = (object)
		? [objectObservers objectForKey:object]
		: nilObjectObservers;

	if (reg) reg->remObserver(reg, @selector(removeObserver:), observer);

	if ([reg count] == 0)
	{
		[objectObservers removeObjectForKey:object];
	}
}

- (void)removeObserver:(id)observer
{
	NSNotificationObserverRegister *reg;
	id  *obj2Rm;
	int obj2RmCnt;

	obj2Rm    = calloc([objectObservers count], sizeof(id));
	obj2RmCnt = 0;

	for (id obj in objectObservers)
	{
		reg = [objectObservers objectForKey:obj];
		reg->remObserver(reg, @selector(removeObserver:),observer);
		if (![reg count])
		{
			obj2Rm[obj2RmCnt++] = obj;
		}
	}

	while (obj2RmCnt)
	{
		[objectObservers removeObjectForKey:obj2Rm[--obj2RmCnt]];
	}
	free(obj2Rm); obj2Rm = NULL;

	nilObjectObservers->remObserver(nilObjectObservers,
			@selector(removeObserver:), observer);
}

@end /* NSNotificationObjectRegister */

/*
 * NSNotificationCenter	
 */

static NSString * const NSNotificationCenterThreadKey = @"NSNotificationCenterThreadKey";
static NSNotificationCenter *defaultCenter = nil;

@implementation NSNotificationCenter 

/* Class methods */

+ (void)initialize
{
	static bool initialized = false;

	if (!initialized)
	{
		initialized = true;
		defaultCenter = [self alloc];
		[defaultCenter init];
	}
}

+ (NSNotificationCenter*)defaultCenter
{
	if (defaultCenter == nil)
	{
		defaultCenter = [NSNotificationCenter new];
		[[NSThread currentThread] setPrivateThreadData:defaultCenter
			forKey:NSNotificationCenterThreadKey];

		// The loop will persist until removed from the dictionary, which won't
		// happen until the thread exits
		[defaultCenter release];
	}

	return defaultCenter;
}

/* Init/dealloc */

- (id)init
{
	nameToObjects = [[NSMapTable mapTableWithStrongToStrongObjects] retain];
	nullNameToObjects = [NSNotificationObjectRegister new];
	return self;
}

- (void)dealloc
{
	[nameToObjects release];
	RELEASE(nullNameToObjects);
	[super dealloc];
}

/* Register && post notifications */

- (void)postNotification:(NSNotification *)notification
{
	NSArray *fromName;
	NSArray *fromNull;
	NSNotificationObjectRegister* reg;
	id name, object;

	name   = [notification name];
	object = [notification object];

	if (name == nil)
	{
		@throw [NSInvalidArgumentException exceptionWithReason:@"`nil' notification name in postNotification:" userInfo:nil];
	}

	// get objects to notify with registered notification name
	reg      = [nameToObjects objectForKey:name];
	fromName = [reg listToNotifyForObject:object];

	// get objects to notify with no notification name
	fromNull = [nullNameToObjects listToNotifyForObject:object];

	// send notifications
	[fromName makeObjectsPerformSelector:@selector(postNotification:)
					  withObject:notification];
	[fromNull makeObjectsPerformSelector:@selector(postNotification:)
					  withObject:notification];
}

- (void)addObserver:(id)observer selector:(SEL)selector 
			   name:(NSString *)notificationName object:(id)object
{
	NSNotificationObjectRegister* reg;

	if (notificationName == nil)
		reg = nullNameToObjects;
	else
	{
		notificationName
			= AUTORELEASE([notificationName
					copyWithZone:[notificationName zone]]);
		reg = [nameToObjects objectForKey:notificationName];
		if (!reg)
		{
			reg = AUTORELEASE([[NSNotificationObjectRegister alloc] init]);
			[nameToObjects setObject:reg forKey:notificationName];
		}
	}
	[reg addObserver:observer selector:selector object:object];
}

- (void)removeObserver:(id)observer 
				  name:(NSString*)notificationName object:(id)object
{
	NSNotificationObjectRegister *reg;

	reg = (notificationName == nil)
		? nullNameToObjects
		: [nameToObjects objectForKey:notificationName];

	[reg removeObserver:observer object:object];

}

- (void)removeObserver:(id)observer
{
	NSNotificationObjectRegister *reg;

	for (reg in [nameToObjects objectEnumerator])
		[reg removeObserver:observer];

	[nullNameToObjects removeObserver:observer];
}

- (void)postNotificationName:(NSString*)notificationName object:object
{
	id notification;

	notification = [[NSNotification alloc] initWithName:notificationName
											   object:object
											 userInfo:nil];
	[self postNotification:notification];
	RELEASE(notification);
}

- (void)postNotificationName:(NSString*)notificationName object:object
					userInfo:(NSDictionary*)userInfo;
{
	id notification;

	notification = [[NSNotification alloc] initWithName:notificationName
											   object:object
											 userInfo:userInfo];
	[self postNotification:notification];
	RELEASE(notification);
}

@end /* NSNotificationCenter */

/*
   Local Variables:
	c-basic-offset: 4
		 tab-width: 8
			   End:
			   */
