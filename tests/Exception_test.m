#import <Test/NSTest.h>
#import <Foundation/NSDictionary.h>
 * All rights reserved.
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>

@interface TestExceptionClass : NSTest
@end
@interface TestException : NSTest
@end

NSException *exc = nil;
NSDictionary *dict = nil;

@implementation TestExceptionClass

- init
{
	dict = [NSDictionary new];
	exc = [[NSException alloc] initWithName:@"DefaultException"
		reason:@"None given"
		userInfo:dict];
}

// exceptionWithName:reason:userInfo: just calls
// initWithName:reason:userInfo:
- (void) test_exceptionWithName_reason_userInfo_
{
	fail_if(exc == nil,
		@"+[NSException exceptionWithName:reason:userInfo:] failed.");
}

@end

@implementation TestException

- init
{
	dict = [NSDictionary new];
	exc = [[NSException alloc] initWithName:@"DefaultException"
		reason:@"None given"
		userInfo:dict];
}

- (void) test_initWithName_reason_userInfo_
{
	fail_if(exc == nil,
		@"-[NSException initWithName:reason:userInfo:] failed.");
}

- (void) test_name
{
	fail_unless([[exc name] isEqual:@"DefaultException"],
		@"-[NSException name] failed.");
}

- (void) test_reason
{
	fail_unless([[exc reason] isEqual:@"None given"],
		@"-[NSException reason] failed.");
}

- (void) test_userInfo
{
	fail_unless([[exc userInfo] isEqual:dict],
		@"-[NSException userInfo] failed.");
}

- (void) test_errorString
{
	fail_unless([[exc errorString] isEqual:@"exceptionName DefaultException\n"
			@"Reason: None given\n"],
		@"-[NSException errorString] failed.");
}

@end
