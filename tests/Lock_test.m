#import <Foundation/NSLock.h>
#import <Foundation/NSDate.h>
#import <Test/NSTest.h>

static NSLock *lockTestLock;
static NSLock *lockTestLock2;

@interface LockTestThread : NSThread
@end

@interface TestLock : NSTest
@end

@implementation LockTestThread
- (void) main
{
	[lockTestLock lock];
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	[lockTestLock unlock];
	fail_unless([lockTestLock2 tryLock] == false, @"");
}

@end

@implementation TestLock
+ (void) initialize
{
	lockTestLock = [NSLock new];
	lockTestLock2 = [NSLock new];
}

- (void) test_tryLock
{
	NSThread *testThread = [LockTestThread new];
	[lockTestLock2 lock];
	[testThread start];

	while (![lockTestLock isLocked])
		yield();

	fail_unless([lockTestLock tryLock] == false,
		@"-[NSLock tryLock] failed.");
	while ([lockTestLock isLocked])
		yield();

	[testThread release];
}

@end
