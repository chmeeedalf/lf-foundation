#import <Test/NSTest.h>
#import <Foundation/NSData.h>
#include <string.h>

@interface TestDataClass : NSTest
@end

@interface TestData : NSTest
@end

@implementation TestDataClass

- (void) test_allocWithZone_
{
	NSData *d = [NSData allocWithZone:NULL];
	fail_if(d == NULL,
		@"");
	[d dealloc];
}

- (void) test_data
{
	NSData *d = [NSData data];
	fail_unless(d != NULL && [d length] == 0,
		@"");
}

- (void) test_dataWithCapacity_
{
	NSMutableData *d = [NSMutableData dataWithCapacity:10000];
	fail_if(d == NULL,
		@"");
}

- (void) test_dataWithLength_
{
	NSMutableData *d = [NSMutableData dataWithLength:10000];
	fail_unless([d length] == 10000,
		@"");
}

- (void) test_dataWithBytes_length_
{
	char b[] = {0, 1,2, 3, 4, 5, 6, 7,8, 9, 'a', 'b'};
	NSData *d = [NSData dataWithBytes:b length:sizeof(b)];
	fail_unless(d != NULL && [d length] == sizeof(b),
		@"");
}

- (void) test_dataWithBytesNoCopy_length_freeWhenDone_
{
	char b[] = {0, 1,2, 3, 4, 5, 6, 7,8, 9, 'a', 'b'};
	NSData *d = [NSData dataWithBytesNoCopy:b length:sizeof(b) freeWhenDone:false];
	fail_unless(d != NULL && [d length] == sizeof(b),
		@"");
}

@end

@implementation TestData

- (void) test_initWithCapacity_
{
	NSData *d = [[NSData alloc] initWithCapacity:10000];
	fail_if(d == NULL,
		@"");
	[d release];
}

- (void) test_initWithLength_
{
	NSData *d = [[NSData alloc] initWithLength:10000];
	fail_unless([d length] == 10000,
		@"");
	[d release];
}

- (void) test_initWithBytes_length_
{
	char b[] = {0, 1,2, 3, 4, 5, 6, 7,8, 9, 'a', 'b'};
	NSData *d = [[NSData alloc] initWithBytes:b length:sizeof(b)];
	fail_unless(d != NULL && [d length] == sizeof(b),
		@"");
	[d release];
}

- (void) test_initWithBytesNoCopy_length_freeWhenDone_
{
	char b[] = {0, 1,2, 3, 4, 5, 6, 7,8, 9, 'a', 'b'};
	NSData *d = [[NSData alloc] initWithBytesNoCopy:b length:sizeof(b) freeWhenDone:false];
	fail_unless(d != NULL && [d length] == sizeof(b),
		@"");
}

- (void) test_bytes
{
	char b[] = {0, 1,2, 3, 4, 5, 6, 7,8, 9, 'a', 'b'};
	NSData *d = [NSData dataWithBytes:b length:sizeof(b)];
	fail_unless(memcmp([d bytes], b, sizeof(b)) == 0,
		@"");
}

- (void) test_description
{
	fail_unless([[NSData data] description] != nil,
		@"");
}

- (void) test_getBytes_length_
{
	char b[] = {0, 1,2, 3, 4, 5, 6, 7,8, 9, 'a', 'b'};
	char c[sizeof(b) - 5];
	NSData *d = [NSData dataWithBytes:b length:sizeof(b)];
	[d getBytes:c length:sizeof(c)];
	fail_unless(memcmp(c, b, sizeof(c)) == 0,
		@"");
}

- (void) test_getBytes_range_
{
	char b[] = {0, 1,2, 3, 4, 5, 6, 7,8, 9, 'a', 'b'};
	char c[sizeof(b) - 5];
	NSData *d = [NSData dataWithBytes:b length:sizeof(b)];
	[d getBytes:c range:NSMakeRange(3, 5)];
	fail_unless(memcmp(c, b + 3, 5) == 0,
		@"");
}

- (void) test_subdataWithRange_
{
	char b[] = {0, 1,2, 3, 4, 5, 6, 7,8, 9, 'a', 'b'};
	NSData *d = [NSData dataWithBytes:b length:sizeof(b)];
	NSData *d2 = [d subdataWithRange:NSMakeRange(3, 5)];
	fail_unless(memcmp([d2 bytes], b + 3, 5) == 0,
		@"");
}

- (void) test_isEqualToData_
{
	char b[] = {0, 1,2, 3, 4, 5, 6, 7,8, 9, 'a', 'b'};
	NSData *d = [NSData dataWithBytes:b length:sizeof(b)];
	NSData *d2 = [d copy];

	fail_unless([d isEqualToData:d2] && ![d isEqualToData:[NSData data]],
		@"");
}

- (void) test_length
{
	char b[] = {0, 1,2, 3, 4, 5, 6, 7,8, 9, 'a', 'b'};
	NSData *d = [NSData dataWithBytes:b length:sizeof(b)];
	fail_unless([d length] == sizeof(b),
		@"");
}

- (void) test_increaseLengthBy_
{
	char b[] = {0, 5, 3, 24, 6, 'a', 'c', 'q', '.', 2, 5, 0};
	NSMutableData *d = [NSMutableData dataWithBytes:b length:sizeof(b)];
	[d increaseLengthBy:50];
	fail_unless([d length] == sizeof(b) + 50,
		@"");
}

- (void) test_setLength_
{
	char b[] = {0, 5, 3, 24, 6, 'a', 'c', 'q', '.', 2, 5, 0};
	NSMutableData *d = [NSMutableData dataWithBytes:b length:sizeof(b)];
	[d setLength:5];
	fail_unless([d length] == 5,
		@"");
}

- (void) test_appendBytes_length_
{
	char b[] = {0, 5, 3, 24, 6, 'a', 'c', 'q', '.', 2, 5, 0};
	NSMutableData *d = [NSMutableData dataWithBytes:b length:sizeof(b)];
	[d appendBytes:b length:sizeof(b)];
	fail_unless(memcmp([d bytes] + sizeof(b), b, sizeof(b)) == 0,
		@"");
}

- (void) test_appendData_
{
	char b[] = {0, 5, 3, 24, 6, 'a', 'c', 'q', '.', 2, 5, 0};
	NSMutableData *d = [NSMutableData dataWithBytes:b length:sizeof(b)];
	fail_unless([d length] == sizeof(b), ([NSString stringWithFormat:@"Bad data length! Length: %u, should be: %u",[d length], sizeof(b)]));
	[d appendData:d];
	// since d == b[]+ b[]...
	fail_unless(memcmp([d bytes] + sizeof(b), b, sizeof(b)) == 0,
		@"");
}

- (void) test_replaceBytesInRange_withBytes_
{
	char b[] = {0, 5, 3, 24, 6, 'a', 'c', 'q', '.', 2, 5, 0};
	NSMutableData *d = [NSMutableData dataWithBytes:b length:sizeof(b)];
	[d replaceBytesInRange:NSMakeRange(5, 5) withBytes:b];
	fail_unless(memcmp([d bytes], b, 5) == 0,
		@"");
}

- (void) test_resetBytesInRange_
{
	char b[] = {0, 5, 3, 24, 6, 'a', 'c', 'q', '.', 2, 5, 0};
	NSMutableData *d = [NSMutableData dataWithBytes:b length:sizeof(b)];
	[d resetBytesInRange:NSMakeRange(0, 5)];
	fail_unless(((char *)[d bytes])[4] == 0,
		@"");
}

- (void) test_setData_
{
	char b[] = {0, 5, 3, 24, 6, 'a', 'c', 'q', '.', 2, 5, 0};
	char c[] = {0, 1,2, 3, 4, 5, 6, 7,8, 9, 'a', 'b'};
	NSMutableData *d = [NSMutableData dataWithBytes:b length:sizeof(b)];
	[d setData:[NSData dataWithBytes:c length:sizeof(c)]];
	fail_unless(memcmp([d bytes], c, sizeof(c)) == 0,
		@"");
}

@end
