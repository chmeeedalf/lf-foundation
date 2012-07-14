#import <Test/NSTest.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSString.h>

@interface TestSetClass : NSTest
@end
@interface TestSet : NSTest
@end

@implementation TestSetClass

- (void) test_allocWithZone_
{
	NSSet *s = [NSSet allocWithZone:NULL];
	fail_if(s == NULL,
		@"+[NSSet allocWithZone:] failed.");
}

- (void) test_set
{
	NSSet *s = [NSSet set];
	fail_unless(s != NULL && [s count] == 0,
		@"+[NSSet set] failed.");
}

- (void) test_setWithArray_
{
	NSArray *a = [NSArray arrayWithObjects:@"foo",@"bar",@"baz",nil];
	NSSet *s = [NSSet setWithArray:a];
	fail_unless([s count] == [a count],
		@"+[NSSet setWithArray:] failed.");
}

- (void) test_setWithCapacity_
{
	NSMutableSet *s = [NSMutableSet setWithCapacity:100000];
	fail_if(s == NULL,
		@"+[NSSet setWithCapacity:] failed.");
}

- (void) test_setWithObject_
{
	NSSet *s = [NSSet setWithObject:@"foo"];
	fail_unless([s count] == 1 && [s containsObject:@"foo"],
		@"+[NSSet setWithObject:] failed.");
}

- (void) test_setWithObjects_
{
	NSSet *s = [NSSet setWithObjects:@"foo",@"bar",@"baz",nil];
	fail_unless([s count] == 3,
		@"+[NSSet setWithObjects:] failed.");
}

@end

@implementation TestSet

- (void) test_initWithArray_
{
	NSArray *a = [NSArray arrayWithObjects:@"foo",@"bar",@"baz",nil];
	NSSet *s = [[NSSet alloc] initWithArray:a];
	fail_unless([s count] == [a count],
		@"-[NSSet initWithArray:] failed.");
}

- (void) test_initWithCapacity_
{
	NSMutableSet *s = [[NSMutableSet alloc] initWithCapacity:100000];
	fail_if(s == NULL,
		@"-[NSSet initWithCapacity:] failed.");
}

- (void) test_initWithObjects_
{
	NSSet *s = [[NSSet alloc] initWithObjects:@"foo",@"bar",@"baz",nil];
	fail_unless([s count] == 3,
		@"-[NSSet initWithObjects:] failed.");
}

- (void) test_initWithObjects_count_
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSSet *s = [[NSSet alloc] initWithObjects:o,p,NULL];
	fail_unless([s count] == 2,
		@"-[NSSet initWithObjects:count:] failed.");
}

- (void) test_initWithSet_
{
	NSSet *s = [NSSet setWithObjects:@"foo",@"bar",@"baz",nil];
	NSSet *t = [[NSSet alloc] initWithSet:s];
	fail_unless([t isEqualToSet:s],
		@"-[NSSet initWithSet:] failed.");
}

- (void) test_initWithSet_copyItems_
{
	NSSet *s = [NSSet setWithObjects:@"foo",@"bar",@"baz",nil];
	NSSet *t = [[NSSet alloc] initWithSet:s copyItems:true];
	fail_unless([t isEqualToSet:s],
		@"-[NSSet initWithSet:copyItems:] failed.");
}

- (void) test_allObjects
{
	NSSet *s = [NSSet setWithObjects:@"foo",@"bar",@"baz",nil];
	NSArray *a = [s allObjects];
	fail_unless([s count] == [a count],
		@"-[NSSet allObjects] failed.");
}

- (void) test_anyObject
{
	NSSet *s = [NSSet setWithObjects:@"foo",@"bar",@"baz",nil];
	fail_unless([s containsObject:[s anyObject]],
		@"-[NSSet anyObject] failed.");
}

- (void) test_containsObject_
{
	NSSet *s = [NSSet setWithObjects:@"foo",@"bar",@"baz",nil];
	fail_unless([s containsObject:@"foo"],
		@"-[NSSet containsObject:] doesn't have what it should.");
	fail_unless(![s containsObject:@"BLAH!"],
		@"-[NSSet containsObject:] has something it shouldn't.");
}

- (void) test_count
{
	NSSet *s = [NSSet setWithObjects:@"foo",@"bar",@"baz",nil];
	fail_unless([s count] == 3 && [[NSSet set] count] == 0,
		@"-[NSSet count] failed.");
}

- (void) test_member_
{
	NSSet *s = [NSSet setWithObjects:@"foo",@"bar",@"baz",nil];
	fail_unless([s member:@"foo"] != NULL && [s member:[NSObject new]] == NULL,
		@"-[NSSet member:] failed.");
}

- (void) test_objectEnumerator
{
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSSet *s = [NSSet setWithObjects:o,p,NULL];
	fail_unless([[s objectEnumerator] isKindOfClass:[NSEnumerator class]],
		@"-[NSSet objectEnumerator] failed.");
}

- (void) test_makeObjectsPerform_
{
#if 0
	NSObject *o = [NSObject new];
	NSObject *p = [NSObject new];
	NSSet *a = [NSSet setWithObjects:o,p,NULL];
	unsigned int i = [o retainCount], j = [p retainCount];
	i++, j++;
	[a makeObjectsPerformSelector:@selector(retain)];
	fail_unless([o retainCount] == i && [p retainCount] == j,
		@"-[NSSet makeObjectsPerform:] failed.");
#endif
}

- (void) test_intersectsSet_
{
	NSSet *s = [NSSet setWithObjects:@"foo",@"bar",@"baz",nil];
	NSSet *t = [NSSet setWithObjects:@"foo",@"bar",@"baz",nil];
	NSSet *u = [NSSet setWithObjects:@"BTA",@"Car",@"taz",nil];
	fail_unless([s intersectsSet:t],
		@"-[NSSet intersectsSet:] failed.");
	fail_if([s intersectsSet:u],
		@"-[NSSet intersectsSet:] returns true when it doesn't.");
}

- (void) test_isEqualToSet_
{
	NSSet *s = [NSSet setWithObjects:@"foo",@"bar",@"baz",nil];
	NSSet *t = [NSSet setWithObjects:@"foo",@"bar",@"baz",nil];
	NSSet *u = [NSSet setWithObjects:@"BTA",@"Car",@"taz",nil];
	fail_unless([s isEqualToSet:t] && ![s isEqualToSet:u],
		@"-[NSSet isEqualToSet:] failed.");
}

- (void) test_isSubsetOfSet_
{
	NSSet *s = [NSSet setWithObjects:@"foo",@"bar",@"baz",nil];
	NSSet *u = [NSSet setWithObjects:@"foo",@"bar",@"baz",@"bbb",nil];
	NSSet *t = [NSSet setWithObjects:@"too",@"bar",@"baz",nil];
	fail_unless([s isSubsetOfSet:u],
		@"-[NSSet isSubsetOfSet:] is not subset of itself.");
	fail_if([s isSubsetOfSet:t],
		@"-[NSSet isSubsetOfSet:] is subset when it shouldn't be.");
}

/*
- (void) test_description
{
	fail_unless(0,
		@"-[NSSet description] failed.");
}

- (void) test_descriptionWithLocale_
{
	fail_unless(0,
		@"-[NSSet descriptionWithLocale:] failed.");
}

- (void) test_descriptionWithLocale_indent_
{
	fail_unless(0,
		@"-[NSSet descriptionWithLocale:indent:] failed.");
}
 */

- (void) test_addObject_
{
	NSMutableSet *s = [NSMutableSet setWithObjects:@"foo",@"bar",@"baz",nil];
	unsigned int i = [s count];
	[s addObject:@"bbb"];
	fail_unless([s count] == i + 1,
		@"-[NSSet addObject:] failed.");
}

- (void) test_addObjectsFromArray_
{
	NSMutableSet *s = [NSMutableSet setWithObjects:@"foo",@"bar",@"baz",nil];
	NSArray *a = [NSArray arrayWithObjects:@"too",@"tar",@"taz",nil];
	unsigned int i = [s count];
	[s addObjectsFromArray:a];
	fail_unless([s count] == i + [a count],
		@"-[NSSet addObjectsFromArray:] failed.");
}

- (void) test_unionSet_
{
	NSMutableSet *s = [NSMutableSet setWithObjects:@"foo",@"bar",@"baz",nil];
	NSSet *t = [NSSet setWithObjects:@"foo",@"tar",@"faz",nil];
	[s unionSet:t];
	fail_unless([s count] == 5,
		@"-[NSSet unionSet:] failed.");
}

- (void) test_intersectSet_
{
	NSMutableSet *s = [NSMutableSet setWithObjects:@"foo",@"bar",@"baz",nil];
	NSSet *t = [NSSet setWithObjects:@"foo",@"tar",@"faz",nil];
	[s intersectSet:t];
	fail_unless([s count] == 1,
		@"-[NSSet intersectSet:] failed.");
}

- (void) test_minusSet_
{
	NSMutableSet *s = [NSMutableSet setWithObjects:@"foo",@"bar",@"baz",nil];
	NSSet *t = [NSSet setWithObjects:@"foo",@"tar",@"faz",nil];
	[s minusSet:t];
	fail_unless([s count] == 2,
		@"-[NSSet minusSet:] failed.");
}

- (void) test_removeAllObjects
{
	NSMutableSet *s = [NSMutableSet setWithObjects:@"foo",@"bar",@"baz",nil];
	[s removeAllObjects];
	fail_unless([s count] == 0,
		@"-[NSSet removeAllObjects] failed.");
}

- (void) test_removeObject_
{
	NSMutableSet *s = [NSMutableSet setWithObjects:@"foo",@"bar",@"baz",nil];
	[s removeObject:@"foo"];
	fail_unless([s count] == 2,
		@"-[NSSet removeObject:] failed.");
}

@end
