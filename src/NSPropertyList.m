/*
 * All rights reserved.
 * Copyright (c) 2012	Justin Hibbits
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

#import <Foundation/NSPropertyList.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import "internal.h"

@implementation NSPropertyListSerialization
{
}
+ (NSData *)dataWithPropertyList:(id)plist format:(NSPropertyListFormat)format
	options:(NSPropertyListWriteOptions)opts error:(NSError **)err
{
	NSOutputStream *output = [NSOutputStream outputStreamToMemory];
	[self writePropertyList:plist toStream:output format:format options:opts error:err];
	return [output propertyForKey:NSStreamDataWrittenToMemmoryStreamKey];
}

+ (void) writePropertyList:(id)plist toStream:(NSOutputStream *)stream
	format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opts
	error:(NSError **)err
{
	TODO;	// -[NSPropertyListSerialization writePropertyList:toStream:format:options:error:]
}


+ (id)propertyListWithData:(NSData *)data options:(NSPropertyListReadOptions)opts
	format:(NSPropertyListFormat *)format error:(NSError **)err
{
	NSInputStream *input = [NSInputStream inputStreamWithData:data];
	return [self propertyListWithStream:input options:opts format:format error:err];
}

+ (id) propertyListWithStream:(NSInputStream *)stream options:(NSPropertyListReadOptions)opt
	format:(NSPropertyListFormat *)format error:(NSError **)err
{
	TODO;	// -[NSPropertyListSerialization propertyListWithStream:options:format:error:]
	return nil;
}


static bool _NSPropertyListCheckTypes(id plist, NSArray *validTypes)
{
	if (![validTypes containsObject:[plist class]])
	{
		return false;
	}
	if ([plist isKindOfClass:[NSDictionary class]])
	{
		for (id obj in plist)
		{
			if (!_NSPropertyListCheckTypes(obj, validTypes))
			{
				return false;
			}
			if (!_NSPropertyListCheckTypes([plist objectForKey:obj], validTypes))
			{
				return false;
			}
		}
	}
	else if ([plist isKindOfClass:[NSArray class]])
	{
		for (id obj in plist)
		{
			if (!_NSPropertyListCheckTypes(obj, validTypes))
			{
				return false;
			}
		}
	}
	else if ([plist isKindOfClass:[NSSet class]])
	{
		for (id obj in plist)
		{
			if (!_NSPropertyListCheckTypes(obj, validTypes))
			{
				return false;
			}
		}
	}
	return true;
}

+ (bool) propertyList:(id)plist isValidForFormat:(NSPropertyListFormat)format
{
	NSArray *validTypes = nil;

	switch (format)
	{
		case NSPropertyListXMLFormat_v1_0:
			validTypes = @[[NSArray class], [NSDictionary class], [NSSet class],
					   [NSNumber class], [NSDate class], [NSData class], [NSString class]];
			break;
		case NSPropertyListBinaryFormat_v1_0:
			validTypes = @[[NSArray class], [NSDictionary class], [NSSet class],
					   [NSNumber class], [NSDate class], [NSData class], [NSString class]];
	 		break;
		case NSPropertyListOpenStepFormat:
			validTypes = @[[NSArray class], [NSDictionary class],
					   [NSData class], [NSString class]];
			break;
	}
	return _NSPropertyListCheckTypes(plist, validTypes);
}

@end
