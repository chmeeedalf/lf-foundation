/*
 * Copyright (c) 2010-2012	Gold Project
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

#import <Foundation/NSPortCoder.h>
#import <Foundation/NSConnection.h>
#import <objc/encoding.h>

@class NSPort,NSConnection,NSArray;

@implementation NSPortCoder

- (id) initWithReceivePort:(NSPort *)receivePort sendPort:(NSPort *)sendPort components:(NSArray *)components
{
	_conn = [[NSConnection alloc] initWithReceivePort:receivePort sendPort:sendPort];
	return self;
}

+ (id) portCoderWithReceivePort:(NSPort *)receivePort sendPort:(NSPort *)sendPort components:(NSArray *)components
{
	return [[self alloc] initWithReceivePort:receivePort sendPort:sendPort components:components];
}

-(NSConnection *)connection
{
	return _conn;
}

-(void)encodePortObject:(NSPort *)port
{
}

-(NSPort *)decodePortObject
{
	return nil;
}

- (void) encodeObject:(id)object
{
}

- (void) encodeValueOfObjCType:(const char *)type at:(const void *)address
{
	type = objc_skip_type_qualifiers(type);
	switch (*type)
	{
		case _C_ID:
			{
				[self encodeObject:(__bridge id)*(void **)address];
			}
	}
}

- (void) encodeBycopyObject:(id)obj
{
	bool savedByref = _byref;
	bool savedBycopy = _bycopy;
	_byref = false;
	_bycopy = true;
	[self encodeObject:obj];
	_byref = savedByref;
	_bycopy = savedBycopy;
}

- (void) encodeByrefObject:(id)obj
{
	bool savedByref = _byref;
	bool savedBycopy = _bycopy;
	_byref = true;
	_bycopy = false;
	[self encodeObject:obj];
	_byref = savedByref;
	_bycopy = savedBycopy;
}

-(bool)isBycopy
{
	return _bycopy;
}

-(bool)isByref
{
	return _byref;
}

-(void)dispatch
{
}

- (void) encodeException:(NSException *)except
{
	[self subclassResponsibility:_cmd];
}

@end
