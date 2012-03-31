#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSArray.h>
 * All rights reserved.
#import <Foundation/NSString.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSException.h>
#import <Test/NSTest.h>

@interface TestArrayClass : NSTest
@end

@interface TestArray : NSTest
@end

@implementation TestArrayClass

-(void) test_allocWithZone_
{
	NSArray *a = [NSArray allocWithZone:NSDefaultAllocZone()];
	fail_if(a == NULL,
		@"");
}

-(void) test_array
{
	fail_unless([[NSArray array] count] == 0,
		@"");
}

-(void) test_arrayWithCapacity_
{
	NSMutableArray *a = [NSMutableArray arrayWithCapacity:1000];
	fail_if(a == NULL,
		@"");
}

-(void) test_arrayWithObject_
{
	NSObject *o = [NSObject new];
	NSArray *a = [NSArray arrayWithObject:o];
	fail_unless([a count] == 1 && [a objectAtIndex:0] == o,
		@"");
	[o release];
}

-(void) test_arrayWithObjects_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	fail_unless([a count] == 2,
		@"");
	[o release];
	[p release];
}

-(void) test_arrayWithObjects_count_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	id ia[] = {o, p};
	NSArray *a = [NSArray arrayWithObjects:ia count:2];
	fail_unless([a count] == 2,
		@"");
	[o release];
	[p release];
}

@end

@implementation TestArray
-(void) test_initWithArray_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	NSArray *b = [[NSArray alloc] initWithArray:a];
	fail_unless([b count] == [a count],
		@"");
}

-(void) test_initWithArray_copyItems_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	NSArray *b = [[NSArray alloc] initWithArray:a copyItems:false];
	fail_unless([b count] == [a count],
		@"");
}

-(void) test_initWithCapacity_
{
	NSArray *a = [[NSMutableArray alloc] initWithCapacity:(1 << 20)];
	fail_if(a == NULL,
		@"");
	[a release];
}

-(void) test_initWithObjects_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	fail_unless([a count] == 2,
		@"");
	[o release];
	[p release];
}

-(void) test_initWithObjects_count_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	id ia[] = {o, p};
	NSArray *a = [NSArray arrayWithObjects:ia count:2];
	fail_unless([a count] == 2,
		@"");
	[o release];
	[p release];
}

-(void) test_containsObject_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	fail_unless([a containsObject:o] == true,
		@"returned false for a contained object.");
	fail_if([a containsObject:@"foo"] == true,
		@"true for a bogus object.");
}

-(void) test_count
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	fail_unless([a count] == 2,
		@"");
}

-(void) test_indexOfObject_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	fail_unless([a indexOfObject:o] == 0 && [a indexOfObject:p] == 1,
		@"");
	fail_unless([a indexOfObject:@"foo"] == NSNotFound,
			@"found a bogus entry");
}

-(void) test_indexOfObject_inRange_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	fail_unless([a indexOfObject:o inRange:NSMakeRange(0,1)] == 0,
		@"");
	fail_unless([a indexOfObject:o inRange:NSMakeRange(1,1)] == NSNotFound,
		@"");
}

-(void) test_indexOfObjectIdenticalTo_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	fail_unless([a indexOfObjectIdenticalTo:o] == 0 && [a indexOfObject:p] == 1,
		@"");
	fail_unless([a indexOfObjectIdenticalTo:@"foo"] == NSNotFound,
			@"found a bogus entry");
}

-(void) test_indexOfObjectIdenticalTo_inRange_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	fail_unless([a indexOfObjectIdenticalTo:o inRange:NSMakeRange(0,1)] == 0,
		@"");
	fail_unless([a indexOfObjectIdenticalTo:o inRange:NSMakeRange(1,1)] == NSNotFound,
		@"");
}

-(void) test_lastObject
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	fail_unless([a lastObject] == p,
		@"");
}

-(void) test_objectAtIndex_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	fail_unless([a objectAtIndex:0] == o && [a objectAtIndex:1] == p,
		@"");
	[o release];
	[p release];
}

-(void) test_objectEnumerator
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	fail_unless([[a objectEnumerator] isKindOfClass:[NSEnumerator class]],
		@"");
	[o release];
	[p release];
}

-(void) test_reverseObjectEnumerator
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	NSEnumerator *e = [a reverseObjectEnumerator];
	fail_unless([e isKindOfClass:[NSEnumerator class]] &&
			[e nextObject] == p,
		@"");
	[o release];
	[p release];
}

-(void) test_makeObjectsPerformSelector_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
#if 0
	unsigned int i = [o retainCount], j = [p retainCount];
	i++, j++;
	[a makeObjectsPerformSelector:@selector(retain)];
	fail_unless([o retainCount] == i && [p retainCount] == j,
		@"");
#endif
	[o release];
	[p release];
}

-(void) test_map
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	NSArray *b;
#if 0
	unsigned int i = [o retainCount], j = [p retainCount];
	b = (NSArray *)[[a map] description];
	fail_unless([b count] == [a count] && [[b:0] isEqualToString:[o
			description]],
		@"operation not performed");
#endif
	[o release];
	[p release];
}

/*
-(void) test_makeObjectsPerformSelector_withObject_
{
	fail_unless(0,
		@"");
}
 */

-(void) test_firstObjectCommonWithArray_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	NSArray *b = [NSArray arrayWithObjects:o,p,NULL];
	fail_unless([a firstObjectCommonWithArray:b] == o,
		@"");
	b = [NSArray arrayWithObjects:p,NULL];
	fail_unless([a firstObjectCommonWithArray:b] == p,
		@"");
	[o release];
	[p release];
}

-(void) test_isEqualToArray_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSArray *a = [NSArray arrayWithObjects:o,p,NULL];
	NSArray *b = [NSArray arrayWithObjects:o,p,NULL];
	fail_unless([a isEqualToArray:a] && [a isEqualToArray:b],
		@"");
	[o release];
	[p release];
}
/*
-(void) test_sortUsingFunction_context_
{
	fail_unless(0,
		@"");
}

-(void) test_sortUsingSelector_
{
	fail_unless(0,
		@"");
}
 */

-(void) test_subarrayWithRange_
{
	NSMutableArray *a = [NSMutableArray array];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	NSArray *b = [NSArray array];
	[a addObject:@"baz"];
	[a addObject:@"bla"];
	[a addObjectsFromArray:b];
	fail_unless([[a subarrayWithRange:NSMakeRange(0, 2)] count] == 2,
		@"");
}

-(void) test_componentsJoinedByString_
{
	NSString *foo = @"Foo";
	NSString *bar = @"Bar";
	NSArray *a = [NSArray arrayWithObjects:foo,bar,NULL];
	NSString *s = [a componentsJoinedByString:@" "];
	fail_unless([s isEqualToString:@"Foo Bar"],
		@"");
}

/*
-(void) test_description
	fail_unless(0,
		@"-[NSArray description] failed.");
}

-(void) test_descriptionWithLocale_
	fail_unless(0,
		@"-[NSArray descriptionWithLocale:] failed.");
}

-(void) test_descriptionWithLocale_indent_
	fail_unless(0,
		@"-[NSArray descriptionWithLocale:indent:] failed.");
}
 */

-(void) test_addObject_
{
	NSMutableArray *a = [NSMutableArray array];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	fail_unless([a count] == 2,
		@"");
}

-(void) test_addObjectsFromArray_
{
	NSMutableArray *a = [NSMutableArray array];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	NSMutableArray *b = [NSArray array];
	[b addObject:@"baz"];
	[b addObject:@"bla"];
	[a addObjectsFromArray:b];
	fail_unless([a count] == 4,
		@"");
}

-(void) test_insertObject_atIndex_
{
	NSMutableArray *a = [NSMutableArray arrayWithObjects:@"blah",
		 [[NSObject new] autorelease],nil];
	NSObject *o = [NSObject new];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	[a addObject:@"blahhhhh"];
	[a insertObject:o atIndex:2];
	fail_unless([a indexOfObject:o] == 2,
		@"");
	[o release];
}

-(void) test_removeAllObjects
{
	NSMutableArray *a = [NSMutableArray arrayWithObjects:@"blah",
		 [[NSObject new] autorelease],nil];
	NSObject *o = [NSObject new];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	[a addObject:@"blahhhhh"];
	[a insertObject:o atIndex:2];
	[a removeAllObjects];
	fail_unless([a count] == 0,
		@"");
	[o release];
}

-(void) test_removeLastObject
{
	NSMutableArray *a = [NSMutableArray arrayWithObjects:@"blah",
		 [[NSObject new] autorelease],nil];
	NSObject *o = [NSObject new];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	[a addObject:@"blahhhhh"];
	[a insertObject:o atIndex:2];
	[a removeLastObject];
	fail_unless([[a lastObject] isEqual:@"bar"],
		@"");
	[o release];
}

-(void) test_removeObject_
{
	NSMutableArray *a = [NSMutableArray arrayWithObjects:@"blah",
		 [[NSObject new] autorelease],nil];
	unsigned int i;
	NSObject *o = [NSObject new];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	[a addObject:@"blahhhhh"];
	[a insertObject:o atIndex:2];
	i = [a count];
	[a removeObject:o];
	fail_unless([a count] == (i - 1),
		@"");
	[o release];
}

-(void) test_removeObjectAtIndex_
{
	NSMutableArray *a = [NSMutableArray arrayWithObjects:@"blah",
		 [[NSObject new] autorelease],nil];
	unsigned int i;
	NSObject *o = [NSObject new];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	[a addObject:@"blahhhhh"];
	[a insertObject:o atIndex:2];
	i = [a count];
	[a removeObjectAtIndex:1];
	fail_unless([a count] == (i - 1) && [a objectAtIndex:1] == o,
		@"");
}

-(void) test_removeObjectIdenticalTo_
{
	NSMutableArray *a = [NSMutableArray arrayWithObjects:@"blah",
		 [[NSObject new] autorelease],nil];
	unsigned int i;
	NSObject *o = [NSObject new];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	[a addObject:@"blahhhhh"];
	[a insertObject:o atIndex:2];
	i = [a count];
	[a removeObjectIdenticalTo:o];
	fail_unless([a count] == (i - 1) && [a containsObject:o] == false,
		@"");
}

-(void) test_removeObjectsFromIndices_numIndices_
{
	NSMutableArray *a = [NSMutableArray arrayWithObjects:@"blah",
		 [[NSObject new] autorelease],nil];
	unsigned int i;
	unsigned int is[] = {0, 1, 3, 4};
	NSObject *o = [NSObject new];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	[a addObject:@"blahhhhh"];
	[a insertObject:o atIndex:2];
	i = [a count];
	[a removeObjectsFromIndices:is numIndices:4];
	fail_unless([a count] == 2 && [a containsObject:o] &&
			[a containsObject:@"blahhhhh"],
		@"");
}

-(void) test_removeObjectsInArray_
{
	NSMutableArray *a = [NSMutableArray arrayWithObjects:@"blah",
		 [[NSObject new] autorelease],nil];
	unsigned int i;
	NSObject *o = [NSObject new];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	[a addObject:@"blahhhhh"];
	[a insertObject:o atIndex:2];
	i = [a count];
	[a removeObjectsInArray:[NSArray arrayWithObjects:o,@"blah",nil]];
	fail_unless([a count] == (i - 2),
		@"");
}

-(void) test_replaceObjectAtIndex_withObject_
{
	NSMutableArray *a = [NSMutableArray arrayWithObjects:@"blah",
		 [[NSObject new] autorelease],nil];
	unsigned int i;
	NSObject *o = [NSObject new];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	[a addObject:@"blahhhhh"];
	[a insertObject:o atIndex:2];
	[a replaceObjectAtIndex:0 withObject:@"bbbbb"];
	fail_unless([[a objectAtIndex:0] isEqual:@"bbbbb"],
		@"");
}

-(void) test_replaceObjectsInRange_withObjectsFromArray_
{
	NSMutableArray *a = [[NSMutableArray alloc] initWithObjects:@"blah",
		 [[NSObject new] autorelease],nil];
	NSMutableArray *b = [[NSMutableArray alloc] 
		initWithObjects:@"blah",@"bbbbb",@"bbbbbbbb",nil];
	unsigned int i;
	NSObject *o = [NSObject new];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	[a addObject:@"blahhhhh"];
	[a insertObject:o atIndex:2];
	i = [a count];
	[a replaceObjectsInRange:NSMakeRange(1, 2)
		withObjectsFromArray:b];
	fail_unless([a count] == (i + 1),
		@"");
	[a release];
	[o release];
	[b release];
}

-(void) test_replaceObjectsInRange_withObjectsFromArray_range_
{
	NSMutableArray *a = [NSMutableArray arrayWithObjects:@"blah",
		 [[NSObject new] autorelease],nil];
	unsigned int i;
	NSObject *o = [NSObject new];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	[a addObject:@"blahhhhh"];
	[a insertObject:o atIndex:2];
	i = [a count];
	[a replaceObjectsInRange:NSMakeRange(0,2) withObjectsFromArray:[NSMutableArray
		arrayWithObjects:o,o,nil] range:NSMakeRange(0,1)];
	fail_unless([[a objectAtIndex:0] isEqual:o] && [a count] == (i - 1),
		@"");
}

-(void) test_setArray_
{
	NSMutableArray *a = [NSMutableArray array];
	[a addObject:@"foo"];
	[a addObject:@"bar"];
	NSMutableArray *b = [NSMutableArray array];
	[a addObject:@"baz"];
	[a addObject:@"bla"];
	[a addObjectsFromArray:b];
	[a setArray:b];
	fail_unless([a isEqual:b],
		@"");
}

@end
