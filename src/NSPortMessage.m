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

#import <Foundation/NSPort.h>
#import <Foundation/NSPortMessage.h>

@implementation NSPortMessage

- (id) init
{
	[self notImplemented:_cmd];
	[self release];
	return nil;
}

- (id) initWithSendPort:(NSPort *)sender receivePort:(NSPort *)receiver
			 components:(NSArray *)components
{
	_send = [sender retain];
	_receive = [receiver retain];
	_components = [components copy];
	return self;
}

- (void) dealloc
{
	[_send release];
	[_receive release];
	[_components release];
	[super dealloc];
}

- (bool) sendBeforeDate:(NSDate *)date
{
	return [_send sendBeforeDate:date
					  components:_components
							from:_receive
						reserved:0];
}

- (NSArray *) components
{
	return _components;
}

- (NSPort *) sendPort
{
	return _send;
}

- (NSPort *) receivePort
{
	return _receive;
}

- (uint32_t) msgid
{
	return _msgid;
}

- (void) setMsgid:(uint32_t)msgid
{
	_msgid = msgid;
}

@end
