/*
 * Copyright (c) 2010	Gold Project
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

#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSProtocolChecker.h>
#import <Foundation/NSString.h>

@implementation NSProtocolChecker
+ protocolCheckerWithTarget:(id)target protocol:(Protocol *)protocol
{
	return [[[self alloc] initWithTarget:target protocol:protocol] autorelease];
}

- initWithTarget:(id)target protocol:(Protocol *)protocol
{
	_target = [target retain];
	_protocol = protocol;
	return self;
}

- (bool) conformsToProtocol:(Protocol *)protocol
{
	return [_protocol conformsToProtocol:protocol];
}

- target
{
	return _target;
}

- (Protocol *)protocol
{
	return _protocol;
}

- (NSMethodSignature *) methodSignatureForSelector:(SEL)sel
{
	if ([_protocol descriptionForInstanceMethod:sel] != NULL)
	{
		return [_target methodSignatureForSelector:sel];
	}
	return nil;
}

- (id) forwardingTargetForSelector:(SEL)sel
{
	if ([_protocol descriptionForInstanceMethod:sel] != NULL)
		return _target;
	return nil;
}

- (void) forwardInvocation:(NSInvocation *)inv
{
	if ([_protocol descriptionForInstanceMethod:[inv selector]] == NULL)
		@throw [NSInvalidArgumentException exceptionWithReason:@"Target protocol does not respond to selector" userInfo:nil];
	[inv invokeWithTarget:_target];
	if (*[[inv methodSignature] methodReturnType] == _C_ID)
	{
		id ret;
		[inv getReturnValue:&ret];
		if (ret == _target)
			[inv setReturnValue:&self];
	}
}
@end
