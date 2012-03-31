#import <Foundation/NSSocket.h>
#import <Foundation/NSData.h>
 * All rights reserved.
#import <Foundation/NSDate.h>
#import <Test/NSTest.h>
#ifdef __FreeBSD__
#include <bsd.h>
#endif

@interface TestSocketClass : NSTest
@end

@interface TestSocket : NSTest
@end

@interface SocketTestDelegate : NSObject
{
@public
	NSData *sentData;
	bool serverAccepted;
	bool clientSane;
}
@end

@implementation SocketTestDelegate
- (void) socket:(NSSocket *)sock didReceiveData:(NSData *)dataBlock
{
	if ([dataBlock isEqual:sentData])
		clientSane = true;
	NSLog(@"client sane");
}

- (bool) socket:(NSSocket *)sock shouldAcceptConnection:(NSSocket *)newSock;
{
	const char sendChars[] = "Hello, World!";
	NSLog(@"socket accepting");
	NSData *d = [[NSData alloc] initWithBytes:sendChars length:sizeof(sendChars) - 1];
	sentData = d;
	[newSock sendData:sentData];
	NSLog(@"NSSocket sent data");
	serverAccepted = true;
	return true;
}

- (void) dealloc
{
	[sentData release];
	[super dealloc];
}
@end

@implementation TestSocketClass
@end

@implementation TestSocket

- (void) test_initWithAddress_socketType_protocol_
{
	NSNetworkAddress *na;
	NSSocket *sock;
	na = [NSInetAddress inetAddressWithString:@"127.0.0.1"];
	sock = [[NSSocket alloc] initWithAddress:na socketType:NSStreamSocketType protocol:0];
	fail_if(sock == nil, @"NSSocket couldn't be created!");
	[sock release];
}

#if 0
- (void) test_sendData_
{
	NetworkAddress *na;
	NSSocket *sock;
	NSSocket *sock2;
	NSData *d = [NSData dataWithBytes:"12345" length:5];
	
	na = [InetAddress inetAddressWithString:@"127.0.0.1"];
	sock = [[TCPSocket alloc] initWithAddress:na port:12345];
	sock2 = [[TCPSocket alloc] initWithAddress:na port:12345];
	[sock setPort:12345];
	[sock listen];
	[sock2 sendData:d];
	[sock2 release];
	[sock release];
}

- (void) test_functional
{
	NetworkAddress *na;
	NSSocket *sock;
	NSSocket *sock2;
	SocketTestDelegate *delegate = [SocketTestDelegate new];
	
	NSLog(@"Got here!");
	na = [InetAddress inetAddressWithString:@"127.0.0.1"];
	sock = [[TCPSocket alloc] initWithAddress:na port:12345];
	sock2 = [[TCPSocket alloc] initWithAddress:na port:12345];
	NSLog(@"Got sockets");
	[sock setDelegate:delegate];
	[sock2 setDelegate:delegate];
	NSLog(@"NSSet delegates");
	[sock listen];
	NSLog(@"Listening");

	[sock2 connect];
	NSLog(@"Connected");
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
	[sock release];
	[sock2 release];
	NSLog(@"Done");
	fail_unless(delegate->clientSane && delegate->serverAccepted, @"NSSocket failed!");
	[delegate release];
}
#endif
@end
