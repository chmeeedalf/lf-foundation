/*
 * Copyright (c) 2010-2012	Justin Hibbits
 * All rights reserved.
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
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSCoder.h>

@class NSPort,NSConnection,NSArray,NSException;

@interface NSPortCoder : NSCoder
{
	NSArray		*_components;
	NSConnection	*_conn;
	bool		 _bycopy;
	bool		 _byref;
}

- (id) initWithReceivePort:(NSPort *)receivePort sendPort:(NSPort *)sendPort components:(NSArray *)components;

+ (id) portCoderWithReceivePort:(NSPort *)receivePort sendPort:(NSPort *)sendPort components:(NSArray *)components;

-(NSConnection *)connection;

-(void)encodePortObject:(NSPort *)port;

-(NSPort *)decodePortObject;

-(bool)isBycopy;

-(bool)isByref;

-(void)dispatch;

/* This allows the port-specific coder to encode an error return. */
- (void) encodeException:(NSException *)except;
@end
