/*
 * Copyright (c) 2004-2012	Gold Project
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the Project nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE PROJECT ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSDistantObject.h>
#import <Foundation/NSException.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSString.h>
#import <Foundation/NSPortCoder.h>
#import "internal.h"

@implementation NSDistantObject
+(NSDistantObject *)proxyWithLocal:(id)target 
	connection:(NSConnection *)connection
{
	return [[NSDistantObject alloc] initWithLocal:target connection:connection];
}

+(NSDistantObject *)proxyWithTarget:(id)target 
	connection:(NSConnection *)connection
{
	return [[NSDistantObject alloc] initWithTarget:target connection:connection];
}

// Initializing a proxy
-(id)initWithLocal:(id)target connection:(NSConnection *)connection
{
	NSDistantObject *proxy = [connection proxyForLocal:target];
	if (proxy != nil)
	{
		return proxy;
	}
	else
	{
		_connection = connection;
		_trueObject = target;
	}
	return self;
}

-(id)initWithTarget:(id)target connection:(NSConnection *)connection
{
	TODO;	// -initWithTarget:connection:
	return self;
}

// Specifying a protocol
-(void)setProtocolForProxy:(Protocol *)proto
{
	_protocol = proto;
}

// Returning the proxy's connection
-(NSConnection *)connectionForProxy
{
	return _connection;
}

- (NSMethodSignature *) methodSignatureForSelector:(SEL)sel
{
	if (_trueObject != nil)
		return [_trueObject methodSignatureForSelector:sel];
	else
	{
		static const char *msfsTypes = "@@::";
		if (sel_isEqual(sel, @selector(methodSignatureForSelector:)))
		{
			return [NSMethodSignature signatureWithObjCTypes:msfsTypes];
		}
		if (_protocol != nil)
		{
			struct objc_method_description *desc = [_protocol descriptionForInstanceMethod:sel];
			if (desc == NULL)
				desc = [_protocol descriptionForClassMethod:sel];
			if (desc != NULL)
				return [NSMethodSignature signatureWithObjCTypes:desc->types];
		}
		
	}
	return nil;
}

- (void) forwardInvocation:(NSInvocation *)inv
{
	NSParameterAssert([_connection isValid]);

	[_connection forwardInvocation:inv forProxy:self];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	NSParameterAssert([coder isKindOfClass:[NSPortCoder class]]);

}

- (id) initWithCoder:(NSCoder *)coder
{
	return self;
}
@end
