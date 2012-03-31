#import <Test/NSTest.h>
#import <Foundation/NSArray.h>
 * All rights reserved.
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/MIMEHandler.h>
#import "MIMEManager.h"
#import <Foundation/NSException.h>
#import <Foundation/NSURI.h>

@interface MIMETest : NSObject <MIMEHandler>
@end

@implementation MIMETest

static NSArray *types;
+ (void) initialize
{
	types = [NSArray arrayWithObjects:@"text/plain",@"text/html",@"text/*",nil];
}

+ handledMIMEEncodings
{
	return types;
}

@end

@interface TestMIMEManager : NSTest
@end

@implementation TestMIMEManager

- (void) test_findHandlerClassForMIMEType_
{
	fail_unless([[MIMEManager sharedManager] findHandlerClassForMIMEType:@"text/plain"] == [MIMETest class], @"");
	fail_unless([[MIMEManager sharedManager] findHandlerClassForMIMEType:@"text/foo"] == [MIMETest class], @"");
	fail_if([[MIMEManager sharedManager] findHandlerClassForMIMEType:@"application/foo"] == [MIMETest class], @"");
}

@end
