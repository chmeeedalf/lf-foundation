#include <unistd.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSTask.h>
#import <Foundation/NSURI.h>
#import <Foundation/NSSet.h>
#import <Test/NSTest.h>

@interface TestTask : NSTest
@end

@implementation TestTask

- (void) test_launch
{
	//NSURI *prog = [NSURI URIWithString:@"file:///usr/local/bin/python"];
	NSURI *prog = [NSURI URIWithString:@"file:///bin/cat"];

	NSTask *t = [[NSTask alloc] initWithURI:prog object:nil environment:nil];
	//[t setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"version",nil]];
	[t launch];
	fail_unless([t isRunning], @"NSTask is not running");
	[t terminate];
	sleep(1);
	fail_if([t isRunning], @"NSTask is still running");
}
@end
