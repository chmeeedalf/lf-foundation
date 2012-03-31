#import <Foundation/NSProcessInfo.h>
#import <Test/NSTest.h>
 * All rights reserved.

@interface TestProcessInfo	:	NSTest
@end

@implementation TestProcessInfo
- (void) test_processorCount
{
	NSLog(@"Processor count:%u", [[NSProcessInfo processInfo] processorCount]);
}

- (void) test_physicalMemory
{
	unsigned long long x = [[NSProcessInfo processInfo] physicalMemory];
	NSLog(@"Physical memory available: %llu", [[NSProcessInfo processInfo] physicalMemory]);
}
@end
