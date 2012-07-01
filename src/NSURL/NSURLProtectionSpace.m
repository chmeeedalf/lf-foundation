/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Foundation/NSURLProtectionSpace.h>
#import <Foundation/NSString.h>
#import "internal.h"

@implementation NSURLProtectionSpace
{
	NSString *hostName;
	NSString *proxyType;
	NSString *protocol;
	NSString *realm;
	NSString *authMethod;
	NSInteger port;
}

NSMakeSymbol(NSURLProtectionSpaceHTTPProxy);
NSMakeSymbol(NSURLProtectionSpaceHTTPSProxy);
NSMakeSymbol(NSURLProtectionSpaceFTPProxy);
NSMakeSymbol(NSURLProtectionSpaceSOCKSProxy);

NSMakeSymbol(NSURLAuthenticationMethodDefault);
NSMakeSymbol(NSURLAuthenticationMethodHTTPBasic);
NSMakeSymbol(NSURLAuthenticationMethodHTTPDigest);
NSMakeSymbol(NSURLAuthenticationMethodHTMLForm);
NSMakeSymbol(NSURLAuthenticationMethodNegotiate);
NSMakeSymbol(NSURLAuthenticationMethodClientCertificate);
NSMakeSymbol(NSURLAuthenticationMethodServerTrust);

-(id)initWithHost:(NSString *)host port:(NSInteger)p protocol:(NSString *)proto realm:(NSString *)inRealm authenticationMethod:(NSString *)authenticationMethod
{
	hostName = [host copy];
	port = p;
	protocol = [proto copy];
	realm = [inRealm copy];
	
	if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodDefault])
		authMethod = NSURLAuthenticationMethodDefault;
	else if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic])
		authMethod = NSURLAuthenticationMethodHTTPBasic;
	else if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest])
		authMethod = NSURLAuthenticationMethodHTTPDigest;
	else if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodHTMLForm])
		authMethod = NSURLAuthenticationMethodHTMLForm;
	else if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodNegotiate])
		authMethod = NSURLAuthenticationMethodNegotiate;
	else if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
		authMethod = NSURLAuthenticationMethodClientCertificate;
	else if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
		authMethod = NSURLAuthenticationMethodServerTrust;

	return self;
}

-(id)initWithProxyHost:(NSString *)host port:(NSInteger)p type:(NSString *)type realm:(NSString *)inRealm authenticationMethod:(NSString *)authenticationMethod
{
	self = [self initWithHost:host port:p protocol:nil realm:inRealm authenticationMethod:authenticationMethod];

	if (self != nil)
	{
		if ([type isEqualToString:NSURLProtectionSpaceHTTPProxy])
			proxyType = NSURLProtectionSpaceHTTPProxy;
		else if ([type isEqualToString:NSURLProtectionSpaceHTTPSProxy])
			proxyType = NSURLProtectionSpaceHTTPSProxy;
		else if ([type isEqualToString:NSURLProtectionSpaceFTPProxy])
			proxyType = NSURLProtectionSpaceFTPProxy;
		else if ([type isEqualToString:NSURLProtectionSpaceSOCKSProxy])
			proxyType = NSURLProtectionSpaceSOCKSProxy;
		else
			self = nil;
	}
	return self;
}

-(id)copyWithZone:(NSZone *)zone
{
	NSURLProtectionSpace *other = [[NSURLProtectionSpace alloc] initWithHost:hostName port:port protocol:protocol realm:realm authenticationMethod:authMethod];
	other->proxyType = proxyType;
	return other;
}

-(NSString *)host
{
	return hostName;
}

-(NSInteger)port
{
	return port;
}

-(NSString *)protocol
{
	return protocol;
}

-(NSString *)realm
{
	return realm;
}

-(NSString *)authenticationMethod
{
	return authMethod;
}

-(NSString *)proxyType
{
	return proxyType;
}

-(bool)receivesCredentialsSecurely
{
	if ([protocol isEqualToString:@"https"])
		return true;
	if (proxyType == NSURLProtectionSpaceHTTPProxy)
		return true;
	if (authMethod == NSURLAuthenticationMethodHTTPDigest)
		return true;
	if (authMethod == NSURLAuthenticationMethodClientCertificate)
		return true;
	return false;
}

-(bool)isProxy
{
	return (proxyType != nil);
}

- (NSArray *) distinguishedNames
{
	TODO; // -[NSURLProtectionSpace distinguishedNames]
	return nil;
}

@end
