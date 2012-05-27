/*
   NSArray.m
 * All rights reserved.

   Copyright (C) 2005-2012	Justin Hibbits
   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

   This file is part of the Gold System Framework (from libFoundation).

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

#include <stdlib.h>
#include <string.h>

#import <Foundation/NSArray.h>

#import "NSCoreArray.h"

#import <Foundation/NSCoder.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSIndexSet.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSPropertyList.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSSortDescriptor.h>
#import <Foundation/NSString.h>

#import "internal.h"

/*
 * NSArray Implementation
 *
 * primary methods are
 *     initWithCapacity:
 *     initWithObjects:count:
 *     init
 *     initWithObjects:count:
 *     dealloc
 *     count
 *     objectAtIndex:
 *     addObject:
 *     replaceObjectAtIndex:withObject:
 *     insertObject:atIndex:
 *     removeObjectAtIndex:
 */

@implementation NSArray

static Class ArrayClass;
static Class CoreArrayClass;

+ (void) initialize
{
	CoreArrayClass = [NSCoreArray class];
	ArrayClass = [NSArray class];
}

/* Allocating and Initializing an NSArray */

+ (id)allocWithZone:(NSZone*)zone
{
	return NSAllocateObject((self == ArrayClass)?CoreArrayClass :
		(Class)self, 0, zone);
}

+ (id)array
{
	return [[self alloc] init];
}

+ (id)arrayWithObject:(id)anObject
{
	return [[self alloc] initWithObjects:&anObject count:1];
}

+ (id)arrayWithObjects:(id)firstObj,...
{
	id array;
	id obj;
	va_list list;
	std::vector<id> objects;

	va_start(list, firstObj);
	for (obj = firstObj; obj != nil; obj = va_arg(list,__unsafe_unretained id))
	{
		objects.push_back(obj);
	}
	va_end(list);

	array = [[self alloc] initWithObjects:&objects[0] count:objects.size()];
	return array;
}

+ (id)arrayWithArray:(NSArray*)anotherArray
{
	return [[self alloc] initWithArray:anotherArray];
}

+ (id)arrayWithObjects:(const id[])objects count:(unsigned int)count
{
	return [[self alloc]
			initWithObjects:objects count:count];
}

+ (id) arrayWithContentsOfURL:(NSURL *)url
{
	return [[self alloc] initWithContentsOfURL:url];
}

- (id)init
{
	return self;
}

- (id)initWithArray:(NSArray*)anotherArray
{
	return [self initWithArray:anotherArray copyItems:false];
}

- (id)initWithArray:(NSArray*)anotherArray copyItems:(bool)flag
{
	NSUInteger i;
	std::vector<id> objects;
	NSUInteger count = [anotherArray count];

	for (i = 0; i < count; i++)
	{
		objects.push_back(flag
			? [[anotherArray objectAtIndex:i]
							 copyWithZone:NULL]
			: [anotherArray objectAtIndex:i]);
	}
	self = [self initWithObjects:&objects[0] count:count];

	return self;
}

- (id)initWithObjects:(id)firstObj,...
{
	id obj;
	va_list list;
	std::vector<id> objects;

	va_start(list, firstObj);
	for (obj = firstObj; obj; obj = va_arg(list,__unsafe_unretained id))
	{
		objects.push_back(obj);
	}
	va_end(list);

	self = [self initWithObjects:&objects[0] count:objects.size()];
	return self;
}

- (id)initWithObjects:(const id[])objects count:(unsigned int)count
{
	[self subclassResponsibility:_cmd];
	return self;
}

-(id)initWithContentsOfURL:(NSURL *)url
{
	NSPropertyListFormat fmt;
	return [NSPropertyListSerialization
		propertyListWithData:[NSData dataWithContentsOfURL:url]
		options:0 format:&fmt error:NULL];
}

- (bool) writeToURL:(NSURL *)url atomically:(bool)atomic
{
	NSData *d = [NSPropertyListSerialization dataWithPropertyList:self
		format:NSPropertyListXMLFormat options:0 error:NULL];
	return [d writeToURL:url atomically:atomic];
}

/* Querying the NSArray */

- (bool)containsObject:(id)anObject
{
	return ([self indexOfObject:anObject] == NSNotFound) ? false : true;
}

- (NSUInteger)count
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (NSUInteger)indexOfObject:(id)anObject
{
	return [self indexOfObject:anObject
		inRange:NSRange(0, [self count])];
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject
{
	return [self indexOfObjectIdenticalTo:anObject
		inRange:NSRange(0, [self count])];
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)aRange
{
	NSUInteger index;

	for (index = 0; index < aRange.length; index++)
	{
		if ([anObject isEqual:[self objectAtIndex:aRange.location+index]])
		{
			return aRange.location+index;
		}
	}
	return NSNotFound;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)aRange
{
	NSUInteger index;

	for (index = 0; index < aRange.length; index++)
		if (anObject == [self objectAtIndex:aRange.location+index])
			return index;
	return NSNotFound;
}

- (NSUInteger) indexOfObjectPassingTest:(bool (^)(id obj, NSUInteger idx, bool *stop))predicate
{
	return [self indexOfObjectWithOptions:0 passingTest:predicate];
}

- (NSUInteger) indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(bool (^)(id obj, NSUInteger idx, bool *stop))predicate
{
	return [self indexOfObjectAtIndexes:[NSIndexSet
		indexSetWithIndexesInRange:NSMakeRange(0, [self count])] options:opts
		passingTest:predicate];
}

- (NSUInteger) indexOfObjectAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts passingTest:(bool (^)(id obj, NSUInteger idx, bool *stop))predicate
{
	__block NSUInteger i = NSNotFound;

	[indexSet enumerateIndexesWithOptions:opts usingBlock:^(NSUInteger idx, bool
			*stop){
		if (predicate([self objectAtIndex:idx], idx, stop))
		{
			*stop = true;
			i = idx;
		}
	}
	];
	return i;
}

- (NSIndexSet *) indexesOfObjectsPassingTest:(bool (^)(id obj, NSUInteger idx, bool *stop))predicate
{
	return [self indexesOfObjectsWithOptions:0 passingTest:predicate];
}

- (NSIndexSet *) indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(bool (^)(id obj, NSUInteger idx, bool *stop))predicate
{
	return [self indexesOfObjectsAtIndexes:[NSIndexSet
		indexSetWithIndexesInRange:NSMakeRange(0, [self count])] options:opts
		passingTest:predicate];
}

- (NSIndexSet *) indexesOfObjectsAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts passingTest:(bool (^)(id obj, NSUInteger idx, bool *stop))predicate
{
	NSMutableIndexSet *iset = [NSMutableIndexSet indexSet];

	[indexSet enumerateIndexesWithOptions:opts usingBlock:^(NSUInteger idx, bool
			*stop){
		if (predicate([self objectAtIndex:idx], idx, stop))
		{
			[iset addIndex:idx];
		}
	}
	];
	return iset;
}

- (NSUInteger) indexOfObject:(id)obj inSortedRange:(NSRange)srange
options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp
{
	NSUInteger i = srange.location + (srange.length / 2);
	int delta = srange.length / 4;	// How far to move
	NSComparisonResult result;
	NSUInteger goodFound = NSNotFound;

	while (1)
	{
		result = cmp(obj, [self objectAtIndex:i]);

		if (result == NSOrderedSame)
		{
			goodFound = i;

			/* Treat it as either 'greater than' or 'less than' if a search
			 * specifier is given.
			 */
			if (opts & NSBinarySearchingFirstEqual)
				result = NSOrderedDescending;
			else if (opts & NSBinarySearchingLastEqual)
				result = NSOrderedAscending;
			else
				break;
		}

		if (result == NSOrderedAscending)
		{
			i += delta;
		}
		else
		{
			i -= delta;
		}
		delta /= 2;
	}
	return goodFound;
}

- (id)firstObject
{
	NSUInteger count = [self count];
	return count ? [self objectAtIndex:0] : nil;
}

- (void) getObjects:(id [])objs range:(NSRange)range
{
	if (NSMaxRange(range) > [self count])
	{
		@throw([NSRangeException exceptionWithReason:@"Range arguement beyond length of array" userInfo:nil]);
	}

	for (unsigned int i = range.location; i < NSMaxRange(range); i++)
		objs[i - range.location] = [self objectAtIndex:i];
}

- (id)lastObject
{
	NSUInteger count = [self count];

	return count ? [self objectAtIndex:count - 1] : nil;
}

- (id)objectAtIndex:(unsigned int)index
{
	[self subclassResponsibility:_cmd];
	return self;
}

- (NSEnumerator*)objectEnumerator
{
	__block NSUInteger idx = 0;
	__block NSUInteger count = [self count];
	return [[NSBlockEnumerator alloc]
			initWithBlock:^{
				if (idx == count)
					return nil;
				return [self objectAtIndex:idx++];
			}];
}

- (NSEnumerator*)reverseObjectEnumerator
{
	__block NSUInteger idx = [self count];

	return [[NSBlockEnumerator alloc]
			initWithBlock:^{
				if (idx == 0)
					return nil;
				return [self objectAtIndex:--idx];
			}];
}

/* Sending Messages to Elements */

- (void)makeObjectsPerformSelector:(SEL)aSelector
{
	for (id object in self)
	{
		[object performSelector:aSelector];
	}
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)anObject
{
	for (id object in self)
	{
		[object performSelector:aSelector withObject:anObject];
	}
}

- (void)makeObjectsPerformSelector:(SEL)aSelector
	withObject:(id)anObject1 withObject:(id)anObject2
{
	for (id object in self)
	{
		[object performSelector:aSelector
			withObject:anObject1
			withObject:anObject2];
	}
}

- (void) enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, bool *stop))block
{
	NSUInteger i = 0;
	bool stop = false;

	for (id obj in self)
	{
		block(obj, i, &stop);
		if (stop)
			return;
		i++;
	}
}

- (void) enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, bool *stop))block
{
	[self enumerateObjectsAtIndexes:[NSIndexSet
		indexSetWithIndexesInRange:NSMakeRange(0, [self count])] options:opts
		usingBlock:block];
}

- (void) enumerateObjectsAtIndexes:(NSIndexSet *)indexSet options:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, bool *stop))block
{
	[indexSet enumerateIndexesWithOptions:opts usingBlock:
		^(NSUInteger idx, bool *stop){
			block([self objectAtIndex:idx], idx, stop);
		}];
}


/* Comparing Arrays */

- (id)firstObjectCommonWithArray:(NSArray*)otherArray
{
	for (id obj in self)
	{
		if ([otherArray containsObject:obj])
		{
			return obj;
		}
	}
	return nil;
}

- (bool)isEqualToArray:(NSArray*)otherArray
{
	NSUInteger index;
	NSUInteger count;

	if( otherArray == self )
	{
		return true;
	}
	if ([otherArray count] != (count = [self count]))
	{
		return false;
	}
	for (index = 0; index < count; index++)
	{
		if (![[self objectAtIndex:index] isEqual:
				[otherArray objectAtIndex:index]])
		{
			return false;
		}
	}
	return true;
}

- (bool) isEqual:(id)other
{
	return ([other isKindOfClass:[self class]] && [self isEqualToArray:other]);
}

/* Deriving New Arrays */
- (NSArray*)subarrayWithRange:(NSRange)range
{
	id array;
	unsigned int index;
	std::vector<id> objects;

	if (NSMaxRange(range) > [self count])
	{
		@throw [NSRangeException exceptionWithReason:nil
			userInfo:nil];
	}

	for (index = 0; index < range.length; index++)
	{
		objects.push_back([self objectAtIndex:range.location+index]);
	}

	array = [[NSArray alloc] initWithObjects:&objects[0] count:range.length];
	return array;
}

/* Joining NSString Elements */

- (NSString*)componentsJoinedByString:(NSString*)separator
{
	NSUInteger count = [self count];

	if(!separator)
	{
		separator = @"";
	}

	if(count)
	{
		NSMutableString* string = [NSMutableString new];
		NSString *retString;
		SEL sel;
		IMP imp;
		bool first = true;

		sel = @selector(appendString:);
		imp = [string methodForSelector:sel];

		for (id elem in self)
		{
			if (!first)
			{
				[string appendString:separator];
			}
			[string appendString:[elem description]];
			(*imp)(string, sel, elem);
			first = false;
		}
		retString = [string copy];
		return retString;
	}

	return nil;
}

/* Creating a NSString Description of the NSArray */

- (NSString*)descriptionWithLocale:(NSLocale*)locale
	indent:(unsigned int)indent
{
	unsigned int indent1 = indent + 4;
	NSString* indentation = [NSString stringWithFormat:
		[NSString stringWithFormat:@"%%%dc", indent1], ' '];
	unsigned int count = [self count];

	if(count)
	{
		id stringRepresentation;
		NSMutableString* description = [NSMutableString stringWithString:@"(\n"];
		NSMutableArray *descrArray = [NSArray array];

		for (id object in self)
		{
			if ([object respondsToSelector:
					@selector(descriptionWithLocale:indent:)])
			{
				stringRepresentation = [object descriptionWithLocale:locale
					indent:indent1];
			}
			else if ([object
					respondsToSelector:@selector(descriptionWithLocale:)])
			{
				stringRepresentation = [object descriptionWithLocale:locale];
			}
			else
			{
				stringRepresentation = [object description];
			}
			[descrArray addObject:[indentation stringByAppendingString:stringRepresentation]];
		}
		[description appendString:[descrArray componentsJoinedByString:@",\n"]];
		[description appendString:@"\n"];
		if (indent)
			[description appendString:[NSString stringWithFormat:[NSString stringWithFormat:@"%%%dc",indent],' ']];
		[description appendString:@")"];
		return description;
	}
	return [indentation stringByAppendingString:@"()"];
}

- (NSString*)descriptionWithLocale:(NSLocale*)locale
{
	return [self descriptionWithLocale:locale indent:0];
}

- (NSString*)description
{
	return [self descriptionWithLocale:nil indent:0];
}

/* From adopted/inherited protocols */

- (NSHashCode)hash
{
	return [self count];
}

/* Copying */

- (id)copyWithZone:(NSZone*)zone
{
	return [[NSArray allocWithZone:zone] initWithArray:self copyItems:false];
}

- (id)mutableCopyWithZone:(NSZone*)zone
{
	return [[NSMutableArray allocWithZone:zone] initWithArray:self copyItems:false];
}

/* Deriving New Arrays */

- (NSArray*)map:(SEL)aSelector
{
	NSUInteger index;
	NSUInteger count = [self count];
	id array = [NSMutableArray arrayWithCapacity:count];

	for (index = 0; index < count; index++)
	{
		[array insertObject:[[self objectAtIndex:index]
			performSelector:aSelector]
			atIndex:index];
	}
	return array;
}

- (NSArray*)map:(SEL)aSelector with:anObject
{
	NSUInteger index;
	NSUInteger count = [self count];
	id array = [NSMutableArray arrayWithCapacity:count];

	for (index = 0; index < count; index++)
	{
		[array insertObject:[[self objectAtIndex:index]
			performSelector:aSelector withObject:anObject]
			atIndex:index];
	}
	return array;
}

- (NSArray*)map:(SEL)aSelector with:anObject with:otherObject
{
	NSUInteger index;
	NSUInteger count = [self count];
	id array = [NSMutableArray arrayWithCapacity:count];

	for (index = 0; index < count; index++)
	{
		[array insertObject:[[self objectAtIndex:index]
			performSelector:aSelector withObject:anObject withObject:otherObject]
			atIndex:index];
	}
	return array;
}

- (NSArray*)arrayWithObjectsThat:(bool(*)(id anObject))comparator
// Returns an array listing the receiver's elements for that comparator
// function returns true
{
	unsigned i;
	NSUInteger m;
	NSUInteger n = [self count];
	std::vector<id> objects;
	id array;

	for (i = m = 0; i < n; i++)
	{
		id obj = [self objectAtIndex:i];
		if (comparator(obj))
		{
			objects.push_back(obj);
		}
	}

	array = [[[self class] alloc] initWithObjects:&objects[0] count:m];
	return array;
}

- (NSArray *)arrayByAddingObject:(id)newObj
{
	unsigned long total = [self count] + 1;
	NSArray *arrayOut;
	std::vector<id> objList;

	for (id obj in self)
	{
		objList.push_back(obj);
	}
	objList.push_back(newObj);

	arrayOut = [NSArray arrayWithObjects:&objList[0] count:total];
	return arrayOut;
}

- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)anotherArray
{
	unsigned long total = [self count] + [anotherArray count];
	NSArray *arrayOut;
	std::vector<id> objList;

	for (id obj in self)
	{
		objList.push_back(obj);
	}

	for (id obj in anotherArray)
	{
		objList.push_back(obj);
	}

	arrayOut = [NSArray arrayWithObjects:&objList[0] count:total];
	return arrayOut;
}

- (NSArray*)map:(id(*)(id anObject))function
	objectsThat:(bool(*)(id anObject))comparator
// Returns an array listing the objects returned by function applied to
// objects for that comparator returns true
{
	unsigned i, m, n = [self count];
	std::vector<id> objects;
	id array;

	for (i = m = 0; i < n; i++)
	{
		id obj = [self objectAtIndex:i];
		if (comparator(obj))
		{
			objects.push_back(function(obj));
		}
	}

	array = [[[self class] alloc] initWithObjects:&objects[0] count:m];
	return array;
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indices
{
	size_t count = [self count];
	if ([indices lastIndex] > count)
		@throw [NSRangeException exceptionWithReason:@"Maximum index in index set out of range of array count." userInfo:nil];

	std::vector<id> objects(count);
	std::vector<NSUInteger> indexes(count);

	[indices getIndexes:&indexes[0] maxCount:count inIndexRange:NULL];

	for (NSUInteger i = 0; i < count; i++)
	{
		objects[i] = [self objectAtIndex:indexes[count]];
	}
	return [NSArray arrayWithObjects:&objects[0] count:count];
}

- (id):(NSUInteger)idx
{
	return [self objectAtIndex:idx];
}

- (void) setValue:(id)val forKey:(NSString *)key
{
	for (id obj in self)
	{
		[obj setValue:val forKey:key];
	}
}

- (id) valueForKey:(NSString *)key
{
	NSMutableArray *a = [NSMutableArray new];

	for (id obj in self)
	{
		id val = [obj valueForKey:key];
		if (val != nil)
			[a addObject:val];
		else
			[a addObject:[NSNull null]];
	}
	return a;
}

- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *)state
	objects:(__unsafe_unretained id [])stackBuf count:(unsigned long)len
{
	NSUInteger i = 0;
	NSUInteger j = 0;
	NSUInteger count = [self count];

	if (state->state == 0)
	{
		state->state = 1;
	}
	else
	{
		i = state->extra[0];
	}
	state->itemsPtr = stackBuf;

	for (j = 0; j < len && i < count; j++, i++)
	{
		stackBuf[i] = [self objectAtIndex:i];
	}
	state->extra[0] = i;
	return j;
}

- (NSData *) sortedArrayHint
{
	TODO; // -[NSArray sortedArrayHint]
	return nil;
}

- (NSArray *) sortedArrayUsingFunction:(NSComparisonResult (*)(id, id, void *))comparator
	context:(void *)ctx hint:(NSData *)hint
{
	NSMutableArray *ret;
	(void)hint;

	ret = [NSMutableArray arrayWithArray:self];

	[ret sortUsingFunction:comparator context:ctx];
	return ret;
}

- (NSArray *) sortedArrayUsingComparator:(NSComparator)cmp
{
	NSMutableArray *a = [NSMutableArray arrayWithArray:self];
	[a sortUsingComparator:cmp];
	return a;
}

- (NSArray *) sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmp
{
	NSMutableArray *a = [NSMutableArray arrayWithArray:self];
	[a sortWithOptions:opts usingComparator:cmp];
	return a;
}

- (NSArray *) sortedArrayUsingDescriptors:(NSArray *)descriptors
{
	NSMutableArray *a = [NSMutableArray arrayWithArray:self];
	[a sortUsingDescriptors:descriptors];
	return a;
}

- (NSArray *) sortedArrayUsingSelector:(SEL)selector
{
	NSMutableArray *a = [NSMutableArray arrayWithArray:self];
	[a sortUsingSelector:selector];
	return a;
}

- (NSArray *) sortedArrayUsingFunction:(NSComparisonResult(*)(id element1, id element2, void *userData))function
	context:(void *)ctx
{
	NSMutableArray *a = [NSMutableArray arrayWithArray:self];
	[a sortUsingFunction:function context:ctx];
	return a;
}

- (id) objectAtIndexedSubscript:(NSUInteger)index
{
	return [self objectAtIndex:index];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	size_t count = [self count];
	[coder encodeValueOfObjCType:@encode(size_t) at:&count];

	for (id obj in self)
	{
		[coder encodeObject:obj];
	}
}

- (id) initWithCoder:(NSCoder *)coder
{
	size_t count = [self count];
	std::vector<id> objs;
	[coder encodeValueOfObjCType:@encode(size_t) at:&count];

	for (size_t i = 0; i < count; i++)
	{
		objs.push_back([coder decodeObject]);
	}
	self = [self initWithObjects:&objs[0] count:count];

	return self;
}

@end

@implementation NSMutableArray

static Class MutableArrayClass;

+ (void) initialize
{
	MutableArrayClass = [NSMutableArray class];
	CoreArrayClass = [NSCoreArray class];
}

+ (id)allocWithZone:(NSZone*)zone
{
	return NSAllocateObject((self == MutableArrayClass)?CoreArrayClass :
		(Class)self, 0, zone);
}

+ (id)arrayWithCapacity:(unsigned int)aNumItems
{
	return [[self alloc] initWithCapacity:aNumItems];
}

- (id)init
{
	return [self initWithCapacity:0];
}

- (id)initWithCapacity:(unsigned int)aNumItems
{
	self = [self init];
	return self;
}

/* Adding Objects */

- (void)addObject:(id)anObject
{
	[self subclassResponsibility:_cmd];
}

- (void)addObjectsFromArray:(NSArray*)anotherArray
{
	for (id obj in anotherArray)
	{
		[self addObject:obj];
	}
}

- (void)insertObject:(id)anObject atIndex:(unsigned int)index
{
	[self subclassResponsibility:_cmd];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
	unsigned long index = [indexes lastIndex];
	for (id obj in objects)
	{
		[self insertObject:obj atIndex:index];
		index = [indexes indexLessThanIndex:index];
		if (index == NSNotFound)
			break;
	}
}

/* Removing Objects */

- (void)removeAllObjects
{
	int count = [self count];
	while (--count >= 0)
		[self removeObjectAtIndex:count];
}

- (void)removeLastObject
{
	[self removeObjectAtIndex:[self count]-1];
}

- (void)removeObject:(id)anObject
{
	unsigned int i, n;
	n = [self count];
	for (i = 0; i < n; i++)
	{
		id obj = [self objectAtIndex:i];
		if ([obj isEqual:anObject])
		{
			[self removeObjectAtIndex:i];
			n--; i--;
		}
	}
}

- (void)removeObjectAtIndex:(unsigned int)index
{
	[self subclassResponsibility:_cmd];
}

- (void)removeObjectIdenticalTo:(id)anObject
{
	NSMutableIndexSet *indices = [NSMutableIndexSet new];
	NSInteger i = 0;
	for (id obj in self)
	{
		if (obj == anObject)
		{
			[indices addIndex:i];
		}
		i++;
	}
	[self removeObjectsAtIndexes:indices];
}

- (void)removeObjectsFromIndices:(unsigned int*)indices
	numIndices:(unsigned int)count
{
	std::vector<NSUInteger> indexes(count);

	if (!count)
		return;

	std::copy(indices, indices + count, indexes.begin());
	std::sort(indexes.begin(), indexes.end());

	for (auto i: {indexes.rbegin(), indexes.rend()})
	{
		[self removeObjectAtIndex:*i];
	}
}

- (void)removeObjectsInArray:(NSArray*)otherArray
{
	unsigned int i, n = [otherArray count];
	for (i = 0; i < n; i++)
	{
		[self removeObject:[otherArray objectAtIndex:i]];
	}
}

- (void)removeObject:(id)anObject inRange:(NSRange)aRange
{
	unsigned int index;
	for (index = aRange.location-1; index >= aRange.location; index--)
	{
		if ([anObject isEqual:[self objectAtIndex:index+aRange.location]])
		{
			[self removeObjectAtIndex:index+aRange.location];
		}
	}
}

- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)aRange
{
	unsigned int index;
	index = [self indexOfObjectIdenticalTo:anObject inRange:aRange];

	if (index != NSNotFound)
	{
		[self removeObjectAtIndex:index];
	}
}

- (void)removeObjectsInRange:(NSRange)aRange
{
	[self removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:aRange]];
}

/* Replacing Objects */

- (void)replaceObjectAtIndex:(unsigned int)index  withObject:(id)anObject
{
	[self subclassResponsibility:_cmd];
}

- (void)replaceObjectsInRange:(NSRange)rRange
	withObjectsFromArray:(NSArray*)anArray
{
	[self replaceObjectsInRange:rRange
		withObjectsFromArray:anArray
		range:NSRange(0, [anArray count])];
}

- (void)replaceObjectsInRange:(NSRange)rRange
	withObjectsFromArray:(NSArray*)anArray range:(NSRange)aRange
{
	unsigned int index;

	if (rRange.length > aRange.length)
	{
		[self removeObjectsInRange:NSRange(rRange.location + aRange.length,
				rRange.length - aRange.length)];
	}
	for (index = 0; index < rRange.length; index++)
	{
		[self replaceObjectAtIndex:(rRange.location + index)
			withObject:[anArray objectAtIndex:(aRange.location + index)]];
	}
	if (aRange.length > rRange.length)
	{
		for (; index < aRange.length; index++)
		{
			[self insertObject:[anArray objectAtIndex:(aRange.location + index)]
				atIndex:(rRange.location + index)];
		}
	}
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)newObjects
{
	unsigned long index = [indexes firstIndex];
	for (id obj in newObjects)
	{
		[self replaceObjectAtIndex:index withObject:obj];
		index = [indexes indexGreaterThanIndex:index];
		if (index == NSNotFound)
			break;
	}
}

- (void)setArray:(NSArray*)otherArray
{
	[self removeAllObjects];
	[self addObjectsFromArray:otherArray];
}

- (void)sortUsingFunction:
	(NSComparisonResult(*)(id element1, id element2, void *userData))comparator
	context:(void*)context
{
	/* Shell sort algorithm taken from SortingInAction - a NeXT example */
#define STRIDE_FACTOR 3	// good value for stride factor is not well-understood
	// 3 is a fairly good choice (Sedgewick)
	int c,d, stride;
	bool found;
	int count = [self count];

	stride = 1;
	while (stride <= count)
	{
		stride = stride * STRIDE_FACTOR + 1;
	}

	while(stride > (STRIDE_FACTOR - 1))
	{
		// loop to sort for each value of stride
		stride = stride / STRIDE_FACTOR;
		for (c = stride; c < count; c++)
		{
			found = false;
			d = c - stride;
			while ((d >= 0) && !found)
			{
				// move to left until correct place
				id a = [self objectAtIndex:d + stride];
				id b = [self objectAtIndex:d];
				if ((*comparator)(a, b, context) == NSOrderedAscending)
				{
					[self replaceObjectAtIndex:d + stride withObject:b];
					[self replaceObjectAtIndex:d withObject:a];
					d -= stride;		// jump by stride factor
				}
				else found = true;
			}
		}
	}
}

static NSComparisonResult selector_compare(id elem1, id elem2, void* comparator)
{
	return (NSComparisonResult)(long)[elem1 performSelector:(SEL)comparator withObject:elem2];
}

static NSComparisonResult descriptor_compare(id elem1, id elem2, void *comparator)
{
	NSArray *descriptors = (__bridge NSArray *)comparator;
	int len = [descriptors count];
	for (int i = 0; i < len; i++)
	{
		NSComparisonResult r = [[descriptors objectAtIndex:i] compareObject:elem1 toObject:elem2];
		if (r != NSOrderedSame)
			return r;
	}
	return NSOrderedSame;
}

- (void)sortUsingSelector:(SEL)comparator
{
	[self sortUsingFunction:selector_compare context:(void*)comparator];
}

- (void)removeObjectsThat:(bool(*)(id anObject))comparator
{
	NSUInteger index;
	NSUInteger count = [self count];
	NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];

	for (index = 0; index < count; index++)
	{
		if (comparator([self objectAtIndex:index]))
		{
			[indexes addIndex:index];
		}
	}
	[self removeObjectsAtIndexes:indexes];
}

- (void) sortUsingDescriptors:(NSArray *)descriptors
{
	[self sortUsingFunction:descriptor_compare context:(__bridge void*)descriptors];
}

- (void) sortUsingComparator:(NSComparator)cmp
{
	return [self sortWithOptions:0 usingComparator:cmp];
}

- (void) sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmp
{
	NSSortRangeUsingOptionsAndComparator(self, NSMakeRange(0,[self count]),
				opts, cmp);
}

- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
	id obj1 = [self objectAtIndex:idx1];

	[self replaceObjectAtIndex:idx1 withObject:[self objectAtIndex:idx2]];
	[self replaceObjectAtIndex:idx2 withObject:obj1];
}

- (void) removeObjectsAtIndexes:(NSIndexSet *)indexes
{
	for (NSUInteger i = [indexes lastIndex]; i != NSNotFound; i = [indexes indexLessThanIndex:i])
	{
		[self removeObjectAtIndex:i];
	}
}

- (void) setObject:(id)newObject atIndexedSubscript:(NSUInteger)index
{
	if (index == [self count])
	{
		[self addObject:newObject];
	}
	else
	{
		[self replaceObjectAtIndex:index withObject:newObject];
	}
}
@end
