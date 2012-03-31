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

#import <Foundation/NSData.h>
#import <Foundation/NSStream.h>
#import "NSConcreteStream.h"
#include <string.h>

@implementation NSOutputStream_buffer

- (id) initToBuffer:(uint8_t *)buf capacity:(size_t)bufLen
{
	buffer = buf;
	bufferLen = bufLen;
	return self;
}

- (void) open
{
	[[self delegate] stream:self handleEvent:NSStreamEventOpenCompleted];
}

- (size_t) write:(const uint8_t *)buf maxLength:(size_t)maxLen
{
	size_t len = std::min(bufferLen - cursor, maxLen);

	if (len == 0)
	{
		return 0;
	}
	memcpy(buffer, buf, len);
	cursor += len;

	if (cursor == bufferLen)
	{
		[[self delegate] stream:self handleEvent:NSStreamEventEndEncountered];
	}
	return len;
}

- (bool) hasSpaceAvailable
{
	return (cursor < bufferLen);
}
@end
