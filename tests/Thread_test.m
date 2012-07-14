#include <unistd.h>
#import <Test/NSTest.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSProcessInfo.h>

@interface TestThreadClass : NSTest
@end

@interface ThreadTester : NSThread
@end

@implementation ThreadTester

- (void) main
{
	//[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:3LL*TICKS_PER_SECOND]];
	sleep(3);
}
@end

@implementation TestThreadClass

- (void) test_currentThread
{
	fail_if([NSThread currentThread] == nil, @"");
}

- (void) test_sleepUntilDate_
{
	NSDate *now = [NSDate date];
	NSDate *future;

	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
	future = [NSDate date];

	fail_unless(([future timeIntervalSinceReferenceDate] - [now timeIntervalSinceReferenceDate]) >= 2 ,
		@"+[NSThread sleepUntilDate:] failed.");
}

- (void) test_exit
{
	//TODO;
	fail_unless(1,
		@"");
}

- (void) test_run
{
	NSThread *t = [ThreadTester new];
	[t start];
	sleep(1);
	fail_unless([[NSProcessInfo processInfo] threadCount] == 2, ([NSString stringWithFormat:@"Bad thread count: %d", [[NSProcessInfo processInfo] threadCount]]));
	sleep(2);
}

- (void) test_callStackReturnAddresses
{
	NSLog(@"%@", [NSThread callStackReturnAddresses]);
}

- (void) test_callStackSymbols
{
	NSLog(@"%@", [NSThread callStackSymbols]);
}

@end
