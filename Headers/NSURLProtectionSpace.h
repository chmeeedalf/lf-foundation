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

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURLCredential.h>

SYSTEM_EXPORT NSSymbol NSURLProtectionSpaceHTTP;
SYSTEM_EXPORT NSSymbol NSURLProtectionSpaceHTTPS;
SYSTEM_EXPORT NSSymbol NSURLProtectionSpaceFTP;

SYSTEM_EXPORT NSSymbol NSURLProtectionSpaceHTTPProxy;
SYSTEM_EXPORT NSSymbol NSURLProtectionSpaceHTTPSProxy;
SYSTEM_EXPORT NSSymbol NSURLProtectionSpaceFTPProxy;
SYSTEM_EXPORT NSSymbol NSURLProtectionSpaceSOCKSProxy;

SYSTEM_EXPORT NSSymbol NSURLAuthenticationMethodDefault;
SYSTEM_EXPORT NSSymbol NSURLAuthenticationMethodHTTPBasic;
SYSTEM_EXPORT NSSymbol NSURLAuthenticationMethodHTTPDigest;
SYSTEM_EXPORT NSSymbol NSURLAuthenticationMethodHTMLForm;
SYSTEM_EXPORT NSSymbol NSURLAuthenticationMethodNegotiate;
SYSTEM_EXPORT NSSymbol NSURLAuthenticationMethodNTLM;
SYSTEM_EXPORT NSSymbol NSURLAuthenticationMethodClientCertificate;
SYSTEM_EXPORT NSSymbol NSURLAuthenticationMethodServerTrust;

@interface NSURLProtectionSpace : NSObject <NSCopying>

-(id)initWithHost:(NSString *)host port:(NSInteger)port protocol:(NSString *)protocol realm:(NSString *)realm authenticationMethod:(NSString *)authenticationMethod;
-(id)initWithProxyHost:(NSString *)host port:(NSInteger)port type:(NSString *)proxyType realm:(NSString *)realm authenticationMethod:(NSString *)authenticationMethod;

-(NSString *)authenticationMethod;
- (NSArray *) distinguishedNames;
-(NSString *)host;
-(bool)isProxy;
-(NSInteger)port;
-(NSString *)protocol;
-(NSString *)proxyType;
-(NSString *)realm;
-(bool)receivesCredentialsSecurely;

@end

@interface NSURLProtectionSpace(NSMacOSXExtension)
- (SecTrustRef) serverTrust;
@end
