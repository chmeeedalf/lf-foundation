#import <Test/NSTest.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>

@protocol TestProtocol
- (void) protocolTest;
@end

@interface DummyObjectTest : NSObject <TestProtocol>
-(void)testSelector;
@end

@interface DummyObjectTestSubclass : DummyObjectTest
@end

@interface SuperclassTest : NSObject
@end

@implementation SuperclassTest
@end

@implementation DummyObjectTest
-(void)testSelector {}
-(void) protocolTest {}
@end

@implementation DummyObjectTestSubclass
@end

@interface NSObject(Failures)
- doesSomethingUnknown;
@end

@interface TestObjectClass : NSTest
@end

@interface TestObject : NSTest
@end

@implementation TestObjectClass
- (void) test_alloc
{
	NSObject *o = [NSObject alloc];
	fail_if(o == NULL,
		@"+[NSObject alloc] failed.");
	[o dealloc];
}

- (void) test_allocWithZone_
{
	NSObject *o = [NSObject allocWithZone:NSDefaultAllocZone()];

	fail_if(o == NULL,
		@"+[NSObject allocWithZone:] failed.");
	[o dealloc];
}

- (void) test_new
{
	NSObject *o = [NSObject new];
	fail_if(o == NULL,
		@"+[NSObject new] failed.");
	[o release];
}

- (void) test_copyWithZone_
{
	id obj = [NSObject copyWithZone:NULL];
	id cls = objc_getClass("NSObject");

	fail_unless(obj == cls,
		@"+[NSObject copyWithZone:] failed to return self.");
}

- (void) test_conformsTo_
{
	NSObject *obj = [NSObject new];
	DummyObjectTest *tst = [DummyObjectTest new];

	fail_unless([obj conformsToProtocol:@protocol(NSObject)],
		@"+[NSObject conformsToProtocol:NSObject] failed to conform to itself.");
	fail_if([obj conformsToProtocol:@protocol(TestProtocol)],
		@"+[NSObject conformsToProtocol:TestProtocol] falsely conforms to a protocol.");
	fail_unless([tst conformsToProtocol:@protocol(TestProtocol)],
		@"+[NSObject conformsToProtocol:TestProtocol] failed to conform to a protocol.");

	[obj release];
	[tst release];
}

@end

@implementation TestObject

- (void) test_init
{
	NSObject *o = [[NSObject alloc] init];

	fail_if(o == nil,
		@"-[NSObject init] failed.");
}

- (void) test_retain
{
	NSObject *o = [NSObject new];
#if 0
	unsigned int rc = [o retainCount];
	rc++;
	[o retain];
	fail_unless(rc == [o retainCount], @"-[NSObject retain] failed.");
	[o release];
#endif
	[o release];
}

- (void) test_release
{
	NSObject *o = [NSObject new];
#if 0
	unsigned int i, refcnt;

	refcnt = [o retainCount];

	for (i = 0; i < 10; i++)
		[o retain];
	for (i; i > 0; i--)
		[o release];
	fail_unless([o retainCount] == refcnt, @"");
#endif
	[o release];
}

- (void) test_class
{
	NSObject *o = [NSObject new];
	fail_unless([o class] == objc_getClass("NSObject"),
		@"");
}

- (void) test_superclass
{
	fail_unless([SuperclassTest superclass] == [NSObject class],
		@"Dummy superclass isn't root");
	fail_unless([NSObject superclass] == Nil,
		@"Root object superclass isn't Nil");
}

- (void) test_instancesRespondToSelector_
{
	fail_if([NSObject instancesRespondToSelector:@selector(alloc)],
		@"returned true.");
	fail_unless([NSObject instancesRespondToSelector:@selector(init)],
		@"");
	fail_if([DummyObjectTest instancesRespondToSelector:@selector(alloc)],
		@"returned true.");
	fail_unless([DummyObjectTest instancesRespondToSelector:@selector(testSelector)],
		@"");
}

- (void) test_respondsToSelector_
{
	NSObject *obj = [NSObject new];
	DummyObjectTest *tst = [DummyObjectTest new];

	fail_if([obj respondsToSelector:@selector(alloc)],
		@"returned true.");
	fail_unless([obj respondsToSelector:@selector(init)],
		@"");
	fail_if([tst respondsToSelector:@selector(alloc)],
		@"returned true.");
	fail_unless([tst respondsToSelector:@selector(testSelector)],
		@"");

	[obj release];
	[tst release];
}

- (void) test_conformsTo_
{
	fail_unless([NSObject conformsToProtocol:@protocol(NSObject)],
		@"failed to conform to itself.");
	fail_if([NSObject conformsToProtocol:@protocol(TestProtocol)],
		@"falsely conforms to another protocol.");
	fail_unless([DummyObjectTest conformsToProtocol:@protocol(TestProtocol)],
		@"failed to conform to a protocol.");
}

- (void) test_instanceMethodForSelector_
{
	fail_unless([NSObject instanceMethodForSelector:@selector(init)] ==
			method_getImplementation(class_getInstanceMethod([NSObject class], @selector(init))),
		@"");
}

- (void) test_methodForSelector_
{
	NSObject *o = [NSObject new];
	fail_unless([o methodForSelector:@selector(init)] ==
			method_getImplementation(class_getInstanceMethod([NSObject class], @selector(init))),
		@"");
	[o release];
}

#if 0
- (void) test_doesNotRecognizeSelector_
{
	@try {
		[[[NSObject new] autorelease] doesSomethingUnknown];
		fail( @"did not throw an exception.");
	}
	@catch (NSException *foo) {
		fail_if([foo class] != [InternalInconsistencyException class], @"");
	}
}
#endif

- (void) test_setVersion_
{
	[NSObject setVersion:2];
	fail_unless([NSObject version] == 2,
		@"");
}

- (void) test_version
{
	[NSObject setVersion:3];
	fail_unless([NSObject version] == 3,
		@"");
}

#if 0
- (void) test_subclassResponsibility_
{
	@try {
		[[[NSObject new] autorelease] subclassResponsibility:@selector(foo)];
		fail( @"-[NSObject subclassResponsibility:] did not throw an exception.");
	}
	@catch (NSException *foo) {
		fail_if(0, @"-[NSObject subclassResponsibility:] failed.");
	}
}

- (void) test_shouldNotImplement_
{
	@try {
		[[[NSObject new] autorelease] shouldNotImplement:@selector(foo)];
		fail( @"-[NSObject shouldNotImplement:] did not throw an exception.");
	}
	@catch (NSException *foo) {
		fail_if(0, @"-[NSObject shouldNotImplement:] failed.");
	}
}

- (void) test_notImplemented_
{
	@try {
		[[[NSObject new] autorelease] notImplemented:@selector(foo)];
		fail( @"-[NSObject notImplemented:] did not throw an exception.");
	}
	@catch (NSException *foo) {
		fail_if(0, @"-[NSObject notImplemented:] failed.");
	}
}
#endif

@end
