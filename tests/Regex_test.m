#import <Foundation/NSRegex.h>
#import <Foundation/NSString.h>
#import <Test/NSTest.h>

@interface TestStringRegexExtension : NSTest
@end

@implementation TestStringRegexExtension
- (void) test_matchesRegularExpression_
{
	[NSRegexPattern alloc];
	fail_unless([@"abcdefg" matchesRegularExpression:[NSRegexPattern compiledPatternWithString:@"abc.*"]], @"");
}
@end
