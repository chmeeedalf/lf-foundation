/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSURLProtectionSpace.h>
#import <Foundation/NSString.h>

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
	_host=[host copy];
	_port=port;
	_protocol=[protocol copy];
	_realm=[realm copy];
	_authenticationMethod=[authenticationMethod copy];
	_isProxy=false;
	return self;
}

-(id)initWithProxyHost:(NSString *)host port:(int)port type:(NSString *)type realm:(NSString *)realm authenticationMethod:(NSString *)authenticationMethod
{
	_host=[host copy];
	_port=port;
	_protocol=[type copy];
	_realm=[realm copy];
	_authenticationMethod=[authenticationMethod copy];
	_isProxy=true;
	return self;
}

-(id)copyWithZone:(NSZone *)zone
{
	return self;
}

-(NSString *)host
{
	return _host;
}

-(int)port
{
	return _port;
}

-(NSString *)protocol
{
	return _protocol;
}

-(NSString *)realm
{
	return _realm;
}

-(NSString *)authenticationMethod
{
	return _authenticationMethod;
}

-(NSString *)proxyType
{
	if ([self isProxy])
		return _protocol;
	return nil;
}

-(bool)receivesCredentialsSecurely
{
	[self notImplemented:_cmd];
	return false;
}

-(bool)isProxy
{
	return _isProxy;
}

- (NSArray *) distinguishedNames
{
	TODO;
	return [self notImplemented:_cmd];
}

@end
