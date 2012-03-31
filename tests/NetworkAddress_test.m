#import <Foundation/NSSocket.h>
#import <Test/NSTest.h>
 * All rights reserved.

@interface TestNetworkAddressClass	: NSTest
@end

@interface TestNetworkAddress	: NSTest
@end

@implementation TestNetworkAddressClass
- (void) test_addressWithString_
{
	fail_unless([NSInetAddress inetAddressWithString:@"999.999.999.999"] == nil, @"Failed to recognize bad IPv4");
	fail_if([NSInetAddress inetAddressWithString:@"127.0.0.1"] == nil, @"Failed to recognize good IPv4");
	fail_if([NSInetAddress inetAddressWithString:@"::1"] == nil, @"Failed to recognize good IPv6");
	fail_if([NSInetAddress inetAddressWithString:@"::127.0.0.1"] == nil, @"failed to recognize good IPv6 with IPv4 end");
	fail_unless([NSInetAddress inetAddressWithString:@"::999.0.0.1"] == nil, @"failed to recognize bad IPv6 with IPv4 end");
	fail_unless([NSInetAddress inetAddressWithString:@"::fffff"] == nil, @"failed to recognize bad IPv6");
	fail_unless([NSInetAddress inetAddressWithString:@":::"] == nil, @"failed to recognize malformed IPv6");
}
@end
