/* $Gold$	*/
/*
 * Copyright (c) 2009	Gold Project
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

#import <Foundation/NSObject.h>

@class NSData;
@class NSError;
@protocol InputStream;
@protocol OutputStream;

typedef uint32_t NSPropertyListReadOptions;
typedef uint32_t NSPropertyListWriteOptions;

typedef enum
{
	NSPropertyListOpenStepFormat,
	NSPropertyListXMLFormat,
	NSPropertyListBinaryFormat,
} NSPropertyListFormat;

typedef enum
{
	NSPropertyListImmutable,
	NSPropertyListMutableContainers,
	NSPropertyListMutableContainersAndLeaves,
} NSPropertyListMutabilityOptions;

@interface NSPropertyListSerialization	:	NSObject
{
}
+ (NSData *)dataWithPropertyList:(id)plist format:(NSPropertyListFormat)format
	options:(NSPropertyListWriteOptions)opts error:(NSError **)err;
+ (bool)propertyList:(id)list isValidForFormat:(NSPropertyListFormat)format;
+ (id)propertyListWithData:(NSData *)data options:(NSPropertyListReadOptions)opts
	format:(NSPropertyListFormat *)format error:(NSError **)err;
+ (id) propertyListWithStream:(id<InputStream>)stream options:(NSPropertyListReadOptions)opt
	format:(NSPropertyListFormat)format error:(NSError **)err;
+ (void) writePropertyList:(id)plist toStream:(id<OutputStream>)stream
	format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opts
	error:(NSError **)err;

+ (bool) propertyList:(id)plist isValidForFormat:(NSPropertyListFormat)format;
@end