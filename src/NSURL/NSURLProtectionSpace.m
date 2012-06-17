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

NSMakeSymbol(NSURLProtectionSpaceHTTPProxy);
NSMakeSymbol(NSURLProtectionSpaceHTTPSProxy);
NSMakeSymbol(NSURLProtectionSpaceFTPProxy);
NSMakeSymbol(NSURLProtectionSpaceSOCKSProxy);

NSMakeSymbol(NSAuthenticationMethodDefault);
NSMakeSymbol(NSAuthenticationMethodHTTPBasic);
NSMakeSymbol(NSAuthenticationMethodHTTPDigest);
NSMakeSymbol(NSAuthenticationMethodHTMLForm);
NSMakeSymbol(NSAuthenticationMethodNegotiate);
NSMakeSymbol(NSAuthenticationMethodClientCertificate);
NSMakeSymbol(NSAuthenticationMethodServerTrust);

-(id)initWithHost:(NSString *)host port:(int)port protocol:(NSString *)protocol realm:(NSString *)realm authenticationMethod:(NSString *)authenticationMethod
{
	TODO; // -[NSURLProtectionSpace initWithHost:port:protocol:realm:authenticationMethod:]
	return self;
}

-(id)initWithProxyHost:(NSString *)host port:(int)port type:(NSString *)type realm:(NSString *)realm authenticationMethod:(NSString *)authenticationMethod
{
	TODO; // -[NSURLProtectionSpace initWithProxyHost:port:protocol:realm:authenticationMethod:]
	return self;
}

-(id)copyWithZone:(NSZone *)zone
{
	TODO; //-[NSURLProtectionSpace copyWithZone:]
	return self;
}

-(NSString *)host
{
	TODO; // -[NSURLProtectionSpace host]
	return nil;
}

-(int)port
{
	TODO; // -[NSURLProtectionSpace port]
	return 0;
}

-(NSString *)protocol
{
	TODO; // -[NSURLProtectionSpace protocol]
	return nil;
}

-(NSString *)realm
{
	TODO; // -[NSURLProtectionSpace realm]
	return nil;
}

-(NSString *)authenticationMethod
{
	TODO; // -[NSURLProtectionSpace proxyType]
	return nil;
}

-(NSString *)proxyType
{
	TODO; // -[NSURLProtectionSpace proxyType]
	return nil;
}

-(bool)receivesCredentialsSecurely
{
	TODO; // -[NSURLProtectionSpace receivesCredentialsSecurely]
	return false;
}

-(bool)isProxy
{
	TODO; // -[NSURLProtectionSpace isProxy]
	return false;
}

- (NSArray *) distinguishedNames
{
	TODO; // -[NSURLProtectionSpace distinguishedNames]
	return nil;
}

@end
