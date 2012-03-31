#import <Foundation/NSHost.h>
#import <Test/NSTest.h>
 * All rights reserved.

@interface TestHostClass	:	NSTest
@end
@interface TestHost	:	NSTest
@end

@implementation TestHostClass

- (void) test_currentHost
{
	fail_unless(0,
		@"+[Host currentHost] failed.");
}

- (void) test_hostWithName_
{
	fail_unless(0,
		@"+[Host hostWithName:] failed.");
}

- (void) test_hostWithAddress_
{
	fail_unless(0,
		@"+[Host hostWithAddress:] failed.");
}
@end


@implementation TestHost

- (void) test_isEqualToHost_
{
	fail_unless(0,
		@"-[Host isEqualToHost:] failed.");
}

- (void) test_name
{
	fail_unless(0,
		@"-[Host name] failed.");
}

- (void) test_names
{
	fail_unless(0,
		@"-[Host names] failed.");
}

- (void) test_address
{
	fail_unless(0,
		@"-[Host address] failed.");
}

- (void) test_addresses
{
	fail_unless(0,
		@"-[Host addresses] failed.");
}
@end
