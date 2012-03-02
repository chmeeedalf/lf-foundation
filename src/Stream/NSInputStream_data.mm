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

#import <Foundation/NSStream.h>
#import "NSConcreteStream.h"

@implementation NSInputStream_data
/* In order to support appending data to NSMutableData objects as input, we don't
 * optimize away the [d length] calls into a constant.
 */

- (id) initWithData:(NSData *)inData
{
	d = inData;
	return self;
}

- (void) open
{
	[[self delegate] stream:self handleEvent:NSStreamEventOpenCompleted];
}

- (size_t) read:(uint8_t *)buffer maxLength:(size_t)maxLen
{
	size_t len = std::min([d length] - cursor, maxLen);

	if (len > 0)
	{
		[d getBytes:buffer range:NSRange(cursor, len)];
	}
	cursor += len;
	return len;
}

- (bool) hasBytesAvailable
{
	return (cursor < [d length]);
}

- (bool) getBuffer:(uint8_t **)buf length:(size_t *)len
{
	if (buf != NULL)
		*buf = (uint8_t *)[d bytes] + cursor;
	if (len != NULL)
		*len = [d length] - cursor;
	return true;
}
@end
