#import <Test/NSTest.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSException.h>
#import <Foundation/NSURL.h>
#include <unistd.h>
#include <sys/stat.h>

@interface TestFileManager : NSTest
@end

@implementation TestFileManager

- (void) test_destinationOfSymbolicLinkAtURL_error_
{
	//NSString *obj = [[NSFileManager defaultManager] destinationOfSymbolicLinkAtURL:[NSURL URLWithString:@"file:///tmp/test_symlink"] error:NULL];
	bool test = [[NSFileManager defaultManager] createSymbolicLinkAtURL:[NSURL URLWithString:@"file:///tmp/test_buildlink"] withDestinationURL:[NSURL URLWithString:@"file:///home/chmeee"] error:NULL];
	unlink("/tmp/test_buildlink");

	fail_unless(test, @"Couldn't make symlink");
}

- (void) test_createFileAtURL_contents_attributes_error_
{
	NSData *d = [NSData dataWithBytes:"1234567890" length:10];

	bool test = [[NSFileManager defaultManager] createFileAtURL:[NSURL URLWithString:@"file:///tmp/test_buildfile"] contents:d attributes:nil];
	unlink("/tmp/test_buildfile");

	fail_unless(test, @"Couldn't create a file");
}

- (void) test_contentsOfDirectoryAtURL_error_
{
	NSArray *contentsOfRoot = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:@"/"] error:NULL];

	fail_if([contentsOfRoot indexOfObject:@"usr"] == NSNotFound, @"/usr not found in listing of /");
}

- (void) test_removeItemAtURL_error_
{
	mkdir("/tmp/test_directory_deletion", 0666);
	bool success = [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:@"file:///tmp/test_directory_deletion"] error:NULL];
	fail_unless(success, @"");
}

@end
