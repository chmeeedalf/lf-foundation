#include <unistd.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSTask.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSSet.h>
#import <Test/NSTest.h>

@interface TestTask : NSTest
@end

@implementation TestTask

- (void) test_launch
{
	//NSURL *prog = [NSURL URLWithString:@"file:///usr/local/bin/python"];
	NSURL *prog = [NSURL URLWithString:@"file:///bin/cat"];

	NSTask *t = [[NSTask alloc] initWithURL:prog object:nil environment:nil];
	//[t setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"version",nil]];
	[t launch];
	fail_unless([t isRunning], @"NSTask is not running");
	[t terminate];
	sleep(1);
	fail_if([t isRunning], @"NSTask is still running");
}
@end
