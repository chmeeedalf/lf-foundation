#import <Test/NSTest.h>
#import <Foundation/NSDictionary.h>
 * All rights reserved.
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSEnumerator.h>

@interface TestDictionaryClass : NSTest
@end
@interface TestDictionary : NSTest
@end

@implementation TestDictionaryClass

- (void) test_allocWithZone_
{
	NSDictionary *dic = [NSDictionary allocWithZone:NSDefaultAllocZone()];
	fail_if(dic == NULL,
		@"+[NSDictionary allocWithZone:] failed.");
	[dic dealloc];
}

- (void) test_dictionary
{
	fail_unless([[NSDictionary dictionary] count] == 0,
		@"+[NSDictionary dictionary] failed.");
}

// NSTest a small array, then a larger one
- (void) test_dictionaryWithObjects_forKeys_count_
{
	id objs[] = {@"foo", @"bar", @"baz"};
	id keys[] = {@"FOO", @"BAR", @"BAAAAA"};
	NSDictionary *d = [NSDictionary dictionaryWithObjects:objs forKeys:keys
		count:3];
	id objs2[] = {@"foo", @"bar", @"baz", @"tty", @"ftc", @"bbb", @"ttz", @"ttp",
		@"mark", @"john"};
	id keys2[] = {@"foo", @"bar", @"baz", @"tty", @"ftc", @"bbb", @"ttz", @"ttp",
		@"mark", @"john"};
	NSDictionary *d2 = [NSDictionary dictionaryWithObjects:objs2 forKeys:keys2
		count:10];
	fail_unless(d != NULL && [d count] == 3,
		@"+[NSDictionary dictionaryWithObjects:forKeys:count:] failed on small dictionary.");
	fail_unless(d2 != NULL && [d2 count] == 10,
		@"+[NSDictionary dictionaryWithObjects:forKeys:count:] failed on larger dictionary.");
}

- (void) test_dictionaryWithObjectsAndKeys_
{
	NSString *s = @"foo";
	NSString *t = @"bar";
	NSObject *o = [NSObject new];
	NSString *q = @"blah";
	NSObject *r = [NSObject new];
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:o,s,r,t,o,q,nil];
	fail_unless([d count] == 3,
		@"+[NSDictionary dictionaryWithObjectsAndKeys:] failed.");
	[o release];
	[r release];
}

@end

@implementation TestDictionary

- (void) test_initWithDictionary_
{
	NSDictionary *d = [NSDictionary
		dictionaryWithObjectsAndKeys:@"foo",@"bar",nil];
	NSDictionary *d2 = [[NSDictionary alloc] initWithDictionary:d];
	fail_unless([d2 isEqualToDictionary:d],
		@"-[NSDictionary initWithDictionary:] failed.");
}

- (void) test_initWithObjectsAndKeys_
{
	NSString *s = @"foo";
	NSString *t = @"bar";
	NSObject *o = [NSObject new];
	NSString *q = @"blah";
	NSObject *r = [NSObject new];
	NSDictionary *d = [[NSDictionary alloc] initWithObjectsAndKeys:o,s,r,t,o,q,nil];
	fail_unless([d count] == 3,
		@"-[NSDictionary initWithObjectsAndKeys:] failed.");
	[d release];
	[o release];
	[r release];
}

- (void) test_initWithObjects_forKeys_
{
	NSArray *obj = [NSArray arrayWithObjects:@"foo",@"bar",@"baz",nil];
	NSArray *key = [NSArray arrayWithObjects:@"one",@"two",@"three",nil];
	NSDictionary *d = [[NSDictionary alloc] initWithObjects:obj forKeys:key];
	fail_unless([d count] == 3,
		@"-[NSDictionary initWithObjects:forKeys:] failed.");
	[d release];
}

- (void) test_initWithObjects_forKeys_count_
{
	id objs[] = {@"foo", @"bar", @"baz"};
	id keys[] = {@"FOO", @"BAR", @"BAAAAA"};
	NSDictionary *d = [[NSDictionary alloc] initWithObjects:objs forKeys:keys
		count:3];
	id objs2[] = {@"foo", @"bar", @"baz", @"tty", @"ftc", @"bbb", @"ttz", @"ttp",
		@"mark", @"john"};
	id keys2[] = {@"foo", @"bar", @"baz", @"tty", @"ftc", @"bbb", @"ttz", @"ttp",
		@"mark", @"john"};
	NSDictionary *d2 = [[NSDictionary alloc] initWithObjects:objs2 forKeys:keys2
		count:10];
	fail_unless(d != NULL && [d count] == 3,
		@"+[NSDictionary dictionaryWithObjects:forKeys:count:] failed on small dictionary.");
	fail_unless(d2 != NULL && [d2 count] == 10,
		@"+[NSDictionary dictionaryWithObjects:forKeys:count:] failed on larger dictionary.");
	[d autorelease];
	[d2 autorelease];
}

- (void) test_allKeys
{
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
		@"foo",@"bar",[[NSObject new] autorelease],@"blah",nil];
	fail_unless([[d allKeys] count] == 2,
		@"-[NSDictionary allKeys] failed.");
}

- (void) test_allValues
{
	NSString *s = @"foo";
	NSString *t = @"bar";
	NSObject *o = [NSObject new];
	NSString *q = @"blah";
	NSObject *r = [NSObject new];
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:o,s,r,t,o,q,nil];
	NSArray *a = [d allValues];
	fail_unless([a count] == 3 && [a containsObject:o] && [a containsObject:r],
		@"-[NSDictionary allValues] failed.");
	[o release];
	[r release];
}

- (void) test_enumerator
{
	NSString *s = @"foo";
	NSString *t = @"bar";
	NSObject *o = [NSObject new];
	NSString *q = @"blah";
	NSObject *r = [NSObject new];
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:o,s,r,t,o,q,nil];
	NSEnumerator *e = [d enumerator];
	fail_unless([e isKindOfClass:[NSEnumerator class]],
		@"-[NSDictionary enumerator] failed.");
}

- (void) test_objectForKey_
{
	NSString *s = @"foo";
	NSString *t = @"bar";
	NSObject *o = [NSObject new];
	NSString *q = @"blah";
	NSObject *r = [NSObject new];
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:o,s,r,t,o,q,nil];
	fail_unless([d objectForKey:s] == o && [d objectForKey:t] == r,
		@"-[NSDictionary objectForKey:] failed.");
	[o release];
	[r release];
}

- (void) test_count
{
	NSString *s = @"foo";
	NSString *t = @"bar";
	NSObject *o = [NSObject new];
	NSString *q = @"blah";
	NSObject *r = [NSObject new];
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:o,s,r,t,o,q,nil];
	fail_unless([d count] == 3,
		@"-[NSDictionary count] failed.");
	[o release];
	[r release];
}

- (void) test_isEqualToDictionary_
{
	NSDictionary *d = [NSDictionary dictionary];
	NSDictionary *d2 = [NSDictionary dictionary];
	NSDictionary *d3 = [NSDictionary
		dictionaryWithObjectsAndKeys:@"foo",@"bar",nil];
	fail_unless([d isEqualToDictionary:d2],
		@"-[NSDictionary isEqualToDictionary:] gave NO negative.");
	fail_if([d isEqualToDictionary:d3],
			@"-NSDictionary isEqualToDictionary:] gave NO positive.");
}

- (void) test_setObject_forKey_
{
	NSMutableDictionary *d = [NSMutableDictionary dictionary];
	[d setObject:@"foo" forKey:@"bar"];
	fail_unless([d objectForKey:@"bar"] == @"foo", @"");
}

/*
- (void) test_description
{
	fail_unless(0,
		@"-[NSDictionary description] failed.");
}

- (void) test_descriptionInStringsFileFormat
{
	fail_unless(0,
		@"-[NSDictionary descriptionInStringsFileFormat] failed.");
}

- (void) test_descriptionWithLocale_
{
	fail_unless(0,
		@"-[NSDictionary descriptionWithLocale:] failed.");
}

- (void) test_descriptionWithLocale_indent_
{
	fail_unless(0,
		@"-[NSDictionary descriptionWithLocale:indent:] failed.");
}
 */

@end
