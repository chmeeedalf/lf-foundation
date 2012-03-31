#import <Foundation/NSNotification.h>
#import <Foundation/NSDictionary.h>
 * All rights reserved.
#import <Test/NSTest.h>

@interface TestNotificationClass : NSTest
@end

@interface TestNotification : NSTest
{
	NSNotification *testNot;
}
@end

@implementation TestNotificationClass
- (void) test_notificationWithName_object_
{
	fail_unless([NSNotification notificationWithName:@"TestNotification" object:self] != nil,
		@"");
}

- (void) test_notificationWithName_object_userInfo_
{
	fail_unless([NSNotification notificationWithName:@"TestNotification" object:self userInfo:nil] != nil,
		@"");
}
@end

@implementation TestNotification

- init
{
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:@"abc",@"def",@"ghi",@"jkl",nil];
	testNot = [NSNotification notificationWithName:@"TestNotification" object:self userInfo:d];
	return self;
}

- (void) test_initWithName_object_userInfo_
{
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:@"abc",@"def",@"ghi",@"jkl",nil];
	NSNotification *n = [[NSNotification alloc] initWithName:@"TestNotification" object:self userInfo:d];
	fail_unless([n object] == self && [n userInfo] == d,
		@"");
}

- (void) test_name
{
	fail_unless([[testNot name] isEqual:@"TestNotification"],
		@"");
}

- (void) test_object
{
	fail_unless([testNot object] == self,
		@"");
}

- (void) test_userInfo
{
	fail_unless([[testNot userInfo] objectForKey:@"def"] != nil,
		@"");
}
@end
