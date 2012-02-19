/* Imported from EtoileFoundation, NSArray+map.m */

#import <Foundation/NSArray.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSProxy.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>

/* Using one class for both map and filter, because forwardInvocation: is 
 * virtually identical between the two.
 */
@interface ArraySetFunctionalProxy : NSProxy
{
	id collection;
}
- (id) initWithCollection:(id)aCollection;
@end

@interface ArraySetMapProxy : ArraySetFunctionalProxy
@end

@interface ArraySetFilterProxy : ArraySetFunctionalProxy
@end

@implementation ArraySetFunctionalProxy
- (id) initWithCollection:(id)aCollection
{
//	SELFINIT;
	collection = aCollection;
	return self;
}

- (id) methodSignatureForSelector:(SEL)aSelector
{
	for (id object in collection)
	{
		if([object respondsToSelector:aSelector])
		{
			return [object methodSignatureForSelector:aSelector];
		}
	}
	return [super methodSignatureForSelector:aSelector];
}
@end

@implementation ArraySetMapProxy

- (void) forwardInvocation:(NSInvocation*)anInvocation
{
	SEL selector = [anInvocation selector];
	NSMutableArray * mappedArray = [NSMutableArray new];
	id mapped = nil;

	for (id object in collection)
	{
		if([object respondsToSelector:selector])
		{
			[anInvocation invokeWithTarget:object];
			[anInvocation getReturnValue:&mapped];
			[mappedArray addObject:mapped];
		}
	}
	[anInvocation setReturnValue:&mappedArray];
}

@end

@implementation ArraySetFilterProxy

- (void) forwardInvocation:(NSInvocation*)anInvocation
{
	SEL selector = [anInvocation selector];
	NSMutableArray * mappedArray = [NSMutableArray array];

	for (id object in collection)
	{
		if([object respondsToSelector:selector])
		{
			bool works;
			[anInvocation invokeWithTarget:object];
			[anInvocation getReturnValue:&works];
			if (works)
				[mappedArray addObject:object];
		}
	}
	[anInvocation setReturnValue:&mappedArray];
}

@end

@implementation NSArray (Functional)
- (id) map
{
	return [[ArraySetMapProxy alloc] initWithCollection:self];
}

- (id) filter
{
	return [[ArraySetFilterProxy alloc] initWithCollection:self];
}
@end

@implementation NSSet (Functional)
- (id) map
{
	return [[ArraySetMapProxy alloc] initWithCollection:self];
}

- (id) filter
{
	return [[ArraySetFilterProxy alloc] initWithCollection:self];
}
@end
