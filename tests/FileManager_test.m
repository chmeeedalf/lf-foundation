#import <Test/NSTest.h>
#import <Foundation/NSArray.h>
 * All rights reserved.
#import <Foundation/NSData.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSException.h>
#import <Foundation/NSURI.h>
#include <unistd.h>
#include <sys/stat.h>

@interface TestFileManager : NSTest
@end

@implementation TestFileManager

- (void) test_destinationOfSymbolicLinkAtURI_error_
{
	NSString *obj = [[NSFileManager defaultManager] destinationOfSymbolicLinkAtURI:[NSURI URIWithString:@"file:///tmp/test_symlink"] error:NULL];
	bool test = [[NSFileManager defaultManager] createSymbolicLinkAtURI:[NSURI URIWithString:@"file:///tmp/test_buildlink"] withDestinationURI:[NSURI URIWithString:@"file:///home/chmeee"] error:NULL];
	unlink("/tmp/test_buildlink");

	fail_unless(test, @"Couldn't make symlink");
}

- (void) test_createFileAtURI_contents_attributes_error_
{
	NSData *d = [NSData dataWithBytes:"1234567890" length:10];

	bool test = [[NSFileManager defaultManager] createFileAtURI:[NSURI URIWithString:@"file:///tmp/test_buildfile"] contents:d attributes:nil];
	unlink("/tmp/test_buildfile");

	fail_unless(test, @"Couldn't create a file");
}

- (void) test_contentsOfDirectoryAtURI_error_
{
	NSArray *contentsOfRoot = [[NSFileManager defaultManager] contentsOfDirectoryAtURI:[NSURI fileURIWithPath:@"/"] error:NULL];

	fail_if([contentsOfRoot indexOfObject:@"usr"] == NSNotFound, @"/usr not found in listing of /");
}

- (void) test_removeItemAtURI_error_
{
	mkdir("/tmp/test_directory_deletion", 0666);
	bool success = [[NSFileManager defaultManager] removeItemAtURI:[NSURI URIWithString:@"file:///tmp/test_directory_deletion"] error:NULL];
	fail_unless(success, @"");
}

@end
