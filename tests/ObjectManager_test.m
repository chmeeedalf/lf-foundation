#import <Test/NSTest.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/ObjectManager.h>
#import <Foundation/NSException.h>
#import <Foundation/NSURI.h>
#import "MIMEManager.h"

@interface TestObjectManager : NSTest
@end

@implementation TestObjectManager

- (void) test_rawObjectWithIdentifier_
{
	id obj = [[ObjectManager sharedObjectManager] rawObjectWithIdentifier:[NSURI URIWithString:@"file:///etc/hosts"] flags:0];
	fail_if(obj == nil, @"/etc/hosts doesn't exist?");
	NSURI *uri = [NSURI URIWithString:@"file:///"];
	obj = [[ObjectManager sharedObjectManager] attributesForObjectWithIdentifier:uri];
	fail_unless([[obj objectForKey:AttributeMIMEType] isEqual:@"application/x-directory"], @"Directory object type isn't normal");
}

@end
