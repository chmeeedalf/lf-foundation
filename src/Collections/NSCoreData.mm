/*
 * Copyright (c) 2004	Gold Project
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

#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#import "NSCoreData.h"

/*
 * Mutable data
 */

@implementation NSCoreData

- (id)init
{
	return self;
}

- (id)initWithCapacity:(unsigned int)_capacity
{
	bytes.reserve(_capacity);
	return self;
}

- (id)initWithBytes:(const void*)_bytes length:(unsigned int)_length
{
	bytes.assign((const char *)_bytes, (const char *)_bytes+_length);
	return self;
}

- (id)initWithBytesNoCopy:(void*)_bytes
	length:(unsigned int)_length
	freeWhenDone:(bool)flag
{
	bytes.assign((const char *)_bytes, (const char *)_bytes + _length);
	if (flag)
	{
		free(_bytes);
	}
	return self;
}

- (id)copyWithZone:(NSZone*)zone
{
	return [[[self class] allocWithZone:zone]
		initWithBytes:&bytes[0] length:bytes.size()];
}

- (const void*)bytes
{
	return &bytes[0];
}

- (char*)mutableBytes
{
	return &bytes[0];
}

- (unsigned int)length
{
	return bytes.size();
}

- (void)dealloc
{
	[super dealloc];
}

- (void)setLength:(unsigned int)_length
{
	bytes.resize(_length);
}

@end /* ConcreteMutableData */
