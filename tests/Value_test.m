#include <string.h>
#import <Test/NSTest.h>
#import <Foundation/NSValue.h>

@interface TestValueClass : NSTest
@end
@interface TestValue : NSTest
@end

@implementation TestValueClass
-(void) test_valueWithBytes_objCType_
{
	NSPoint p = {0.0, 0.0};
	NSPoint q;
	NSValue *v = [NSValue valueWithBytes:&p objCType:@encode(NSPoint)];
	q = [v pointValue];
	fail_unless(memcmp(&p, &q, sizeof(p)) == 0,
		@"");
}

-(void) test_valueWithNonretainedObject_
{
	NSObject *o = [NSObject new];
#if 0
	unsigned long rc = [o retainCount];
	NSValue *v = [NSValue valueWithNonretainedObject:o];
	fail_unless(v != nil && [o retainCount] == rc,
		@"");
#endif
	[o release];
}

-(void) test_valueWithPointer_
{
	void *pointerTest = [self class];
	fail_unless([NSValue valueWithPointer:pointerTest] != nil,
		@"");
}

-(void) test_valueWithPoint_
{
	NSPoint p = {0.0, 0.0};
	fail_unless([NSValue valueWithPoint:p] != nil,
		@"");
}

-(void) test_valueWithRect_
{
	NSRect r = {0.0,0.0,1.0,1.0};
	NSValue *v = [NSValue valueWithRect:r];
	fail_unless(v != nil,
		@"");
}

-(void) test_valueWithSize_
{
	NSSize s = {0.0,0.0};
	NSValue *v = [NSValue valueWithSize:s];
	fail_unless(v != nil,
		@"");
}
@end

@implementation TestValue
-(void) test_getValue_
{
	NSObject *o = [NSObject new];
	NSValue *v = [NSValue valueWithNonretainedObject:o];
	NSObject *o2;
	[v getValue:&o2];
	fail_unless(o2 == o,
		@"");
}

-(void) test_nonretainedObjectValue
{
	NSObject *o = [NSObject new];
	NSValue *v = [NSValue valueWithNonretainedObject:o];
	fail_unless([v nonretainedObjectValue] == o,
		@"");
}

-(void) test_objCType
{
	void *pointerTest = [self class];
	NSValue *v = [NSValue valueWithPointer:pointerTest];
	fail_unless(strcmp([v objCType],"^v") == 0,
		@"");
}

-(void) test_pointerValue
{
	void *pointerTest = [self class];
	NSValue *v = [NSValue valueWithPointer:pointerTest];
	fail_unless([v pointerValue] == pointerTest,
		@"");
}

-(void) test_pointValue
{
	NSPoint p = {0.0, 0.0};
	NSPoint q = [[NSValue valueWithPoint:p] pointValue];
	fail_unless(memcmp(&q, &p, sizeof(q)) == 0,
		@"");
}

-(void) test_rectValue
{
	NSRect r = {0.0,0.0,1.0,1.0};
	NSRect n;
	NSValue *v = [NSValue valueWithRect:r];
	n = [v rectValue];
	fail_unless(memcmp(&r, &n, sizeof(r)) == 0,
		@"");
}

-(void) test_sizeValue
{
	NSSize s = {0.0,0.0};
	NSValue *v = [NSValue valueWithSize:s];
	NSSize ts = [v sizeValue];
	fail_unless(memcmp(&s, &ts, sizeof(s)) == 0,
		@"");
}

-(void) test_isEqualToValue_
{
	fail_unless([[NSValue valueWithPointer:NULL] isEqualToValue:[NSValue valueWithPointer:NULL]],
		@"Equality failed");
	fail_if([[NSValue valueWithPointer:NULL] isEqualToValue:[NSValue valueWithPointer:[NSValue class]]],
		@"Inequality failed");
}

-(void) test_valueBytes
{
	NSSize s = {0.0,0.0};
	NSValue *v = [NSValue valueWithSize:s];
	NSSize *ts;
	ts = [v valueBytes];
	fail_unless(memcmp(&s, ts, sizeof(s)) == 0,
		@"");
}
@end
