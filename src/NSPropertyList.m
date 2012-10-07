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

#include <string.h>

#import <Foundation/NSPropertyList.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSByteOrder.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDateFormatter.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import "internal.h"

static NSUInteger writeOpenStepPropertyList(id plist, NSOutputStream *outStream,
		NSPropertyListWriteOptions opts, NSUInteger indent, NSError **err);

static NSUInteger writeXMLPropertyList(id plist, NSOutputStream *outStream,
		NSPropertyListWriteOptions opts, NSUInteger indent, NSError **err);

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

+ (NSUInteger) writePropertyList:(id)plist toStream:(NSOutputStream *)stream
	format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opts
	error:(NSError **)err
{
	TODO;	// -[NSPropertyListSerialization writePropertyList:toStream:format:options:error:]

	if (![self propertyList:plist isValidForFormat:format])
	{
		if (err != NULL)
		{
			*err = [NSError errorWithDomain:NSCocoaErrorDomain code:0
								   userInfo:@{
				 NSLocalizedDescriptionKey : @"Property list not valid for format"
								   }];
		}
		return 0;
	}
	switch (format)
	{
		case NSPropertyListXMLFormat_v1_0:
			return writeXMLPropertyList(plist, stream, opts, 0, err);
			break;
		case NSPropertyListBinaryFormat_v1_0:
			TODO; // NSPropertyListBinaryFormat create -- finish
			break;
		case NSPropertyListOpenStepFormat:
			return writeOpenStepPropertyList(plist, stream, opts, 0, err);
			break;
		default:
			break;
	}
	return 0;
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
			validTypes = @[[NSArray class], [NSDictionary class],
					   [NSNumber class], [NSDate class], [NSData class], [NSString class]];
			break;
		case NSPropertyListBinaryFormat_v1_0:
			validTypes = @[[NSArray class], [NSDictionary class], [NSSet class],
					   [NSNumber class], [NSDate class], [NSData class], [NSString class],
					   [NSNull class]];
	 		break;
		case NSPropertyListOpenStepFormat:
			validTypes = @[[NSArray class], [NSDictionary class],
					   [NSData class], [NSString class]];
			break;
	}
	return _NSPropertyListCheckTypes(plist, validTypes);
}

@end

static NSUInteger writeOpenStepPropertyList(id plist, NSOutputStream *outStream,
		NSPropertyListWriteOptions opts, NSUInteger indent, NSError **err)
{
	__block NSUInteger total = 0;

	/*
	 * We use an array 2-larger than the indent so we can modify for collections
	 */
	unsigned char *indentchars __cleanup(cleanup_pointer) = malloc(indent + 2);
	memset(indentchars, '\t', indent + 1);
	indentchars[indent+1] = 0;

	if ([plist isKindOfClass:[NSDictionary class]])
	{
		__block NSInteger sub;

		sub = [outStream write:"{\n" maxLength:strlen("{\n")];
		if (sub < 0)
			return total;
		total += sub;
		sub = [outStream write:indentchars maxLength:indent];
		if (sub < 0)
			return total;
		total += sub;
		[plist enumerateKeysAndObjectsUsingBlock:^(id key, id val, bool *stop){
			sub = [outStream write:indentchars maxLength:indent + 1];
			if (sub < 0)
			{
				*stop = true;
				return;
			}
			total += sub;
			sub = writeOpenStepPropertyList(key, outStream, opts, indent + 1, err);
			if (sub < 0)
			{
				*stop = true;
				return;
			}
			total += sub;
			sub = [outStream write:" = " maxLength:strlen(" = ")];
			if (sub < 0)
			{
				*stop = true;
				return;
			}
			total += sub;
			sub = writeOpenStepPropertyList(val, outStream, opts, indent + 1, err);
			if (sub < 0)
			{
				*stop = true;
				return;
			}
			total += sub;
			sub = [outStream write:";\n" maxLength:strlen(";\n")];
			if (sub < 0)
			{
				*stop = true;
				return;
			}
		}];
		if (sub < 0)
			return total;
		indentchars[indent] = 0;
		sub = [outStream write:"}" maxLength:1];
		if (sub < 0)
			return total;
		total += sub;
	}
	else if ([plist isKindOfClass:[NSArray class]])
	{
		NSUInteger count = [plist count];
		__block NSInteger sub;

		sub = [outStream write:"(\n" maxLength:strlen("(\n")];
		if (sub < 0)
			return total;
		total += sub;
		[plist enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, bool *stop)
		{
			sub = [outStream write:indentchars maxLength:indent + 1];
			if (sub < 0)
			{
				*stop = true;
				return;
			}
			total += sub;
			sub = writeOpenStepPropertyList(obj, outStream, opts, indent + 1, err);
			if (sub < 0)
			{
				*stop = true;
				return;
			}
			total += sub;
			if (idx < (count - 1))
			{
				sub = [outStream write:"," maxLength:1];
				if (sub < 0)
				{
					*stop = true;
					return;
				}
			}
			sub = [outStream write:"\n" maxLength:1];
			if (sub < 0)
			{
				*stop = true;
				return;
			}
		}];
		if (sub < 0)
			return total;
		indentchars[indent] = 0;
		sub = [outStream write:")" maxLength:1];
		if (sub < 0)
			return total;
		total += sub;
	}
	else if ([plist isKindOfClass:[NSString class]])
	{
		const char *plStr = [plist UTF8String];
		NSCharacterSet *sepSet = [NSCharacterSet characterSetWithCharactersInString:@"\"\\\b\n\r\t"];
		if ([plist rangeOfCharacterFromSet:sepSet].location != NSNotFound)
		{
			plStr = [[NSString stringWithFormat:@"\"%@\"",[[plist componentsSeparatedByCharactersInSet:sepSet] componentsJoinedByString:@"\\"]] UTF8String];
		}
		NSInteger sub = [outStream write:plStr maxLength:strlen(plStr)];
		if (sub <= 0)
			return 0;
		return sub;
	}
	else if ([plist isKindOfClass:[NSData class]])
	{
		NSInteger sub;
		sub = [outStream write:"< " maxLength:sizeof("< ")];
		if (sub <= 0)
			return 0;
		const uint8_t *bytes = [plist bytes];
		static const char hexBytes[] = "0123456789ABCDEF";
		NSUInteger size = [plist length];

		for (NSUInteger i = 0; i < size; i++)
		{
			char byteInHex[2] = { hexBytes[bytes[i] >> 4], hexBytes[bytes[i] & 0xF] };
			sub = [outStream write:byteInHex maxLength:2];
			if (sub <= 0)
				return 0;
		}
		sub = [outStream write:" >" maxLength:sizeof(" >")];
		if (sub <= 0)
			return 0;
	}
	return total;
}

static NSUInteger writeBinaryPropertyList(id plist, NSOutputStream *outStream,
		NSPropertyListWriteOptions opts, NSUInteger indent, NSError **err)
{
	//NSMutableArray *offsets = [NSMutableArray array];

	NSInteger sub;
	NSUInteger total = 0;

	sub = [outStream write:"bplist01" maxLength:strlen("bplist01")];
	if (sub < 0)
		return 0;

	total += sub;


	return total;
}

static NSUInteger writeBinaryPropertyListInt(id plist, NSOutputStream *outStream,
		NSPropertyListWriteOptions opts, NSUInteger indent, NSError **err)
{
	NSInteger sub = 0;
	if ([plist isKindOfClass:[NSNull class]])
	{
		sub = [outStream write:&(uint8_t){0} maxLength:1];
		return (sub >= 0 ? sub : 0);
	}
	else if ([plist isKindOfClass:[NSNumber class]])
	{
		if (strcmp([plist objCType], @encode(bool)) == 0)
		{
			sub = [outStream write:&(uint8_t){0x08 | [plist boolValue]} maxLength:1];
			return (sub >= 0 ? sub : 0);
		}
	}
	else if ([plist isKindOfClass:[NSString class]])
	{
		NSData *d;
		uint8_t prefix;
		if ([plist canBeConvertedToEncoding:NSASCIIStringEncoding])
		{
			prefix = 0x50;
			d = [plist dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:false];
		}
		else
		{
			prefix = 0x60;
			d = [plist dataUsingEncoding:NSUTF16BigEndianStringEncoding allowLossyConversion:false];
		}
		if ([d length] > 15)
		{
			prefix |= 0xF;
			uint32_t len = [d length];
			sub = [outStream write:&(uint8_t){prefix} maxLength:1];
			if (sub < 0)
				return 0;
			len = NSSwapHostIntToBig(len);
			sub = [outStream write:(uint8_t *)&len maxLength:sizeof(len)];
			if (sub < 0)
				return 0;
		}
	}
	else if ([plist isKindOfClass:[NSData class]])
	{
		if ([plist length] > 15)
		{
			uint32_t i = [plist length];

			sub = [outStream write:&(uint8_t){0x4F} maxLength:1];
			if (sub < 0)
				return 0;
			i = NSSwapHostIntToBig(i);
			sub = [outStream write:(uint8_t *)&i maxLength:sizeof(i)];
			if (sub < 0)
				return 0;
		}
		else
		{
			sub = [outStream write:&(uint8_t){0x40 | [plist length]} maxLength:1];
			if (sub < 0)
				return 0;
		}
		sub = [outStream write:[plist bytes] maxLength:[plist length]];
		return (sub > 0 ? sub : 0);
	}
	else if ([plist isKindOfClass:[NSDate class]])
	{
		unsigned long long date = NSSwapHostDoubleToBig([plist timeIntervalSinceReferenceDate]).v;
		sub = [outStream write:&(uint8_t){0x33} maxLength:1];
		if (sub < 0 )
			return 0;
		sub = [outStream write:(uint8_t *)&date maxLength:8];
		return (sub >= 0 ? sub : 0);
	}
	else if ([plist isKindOfClass:[NSSet class]])
	{
	}
	else if ([plist isKindOfClass:[NSArray class]])
	{
	}
	else if ([plist isKindOfClass:[NSDictionary class]])
	{
	}
	return sub;
}

static NSUInteger writeXMLPropertyListInt(id plist, NSOutputStream *outStream,
		NSPropertyListWriteOptions opts, NSUInteger indent, NSError **err);

static NSUInteger writeXMLPropertyList(id plist, NSOutputStream *outStream,
		NSPropertyListWriteOptions opts, NSUInteger indent, NSError **err)
{
	NSUInteger total = 0;
	const char prefix[] = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
		"<!DOCTYPE plist PUBLIC \"-//libFoundation/DTD plist 0.9//EN\">\n"
		"<plist>\n";
	NSInteger sub;

	sub = [outStream write:prefix maxLength:strlen(prefix)];
	if (sub < 0)
		return total;
	total += sub;
	total += writeXMLPropertyListInt(plist, outStream, opts, indent + 1, err);
	sub = [outStream write:"</plist>" maxLength:strlen("</plist>")];
	if (sub < 0)
		return total;
	total += sub;
	return total;
}

static NSUInteger writeXMLPropertyListInt(id plist, NSOutputStream *outStream,
		NSPropertyListWriteOptions opts, NSUInteger indent, NSError **err)
{
	NSInteger sub;
	__block NSUInteger total = 0;

	/*
	 * We use an array 2-larger than the indent so we can modify for collections
	 */
	unsigned char *indentchars __cleanup(cleanup_pointer) = malloc(indent + 2);
	memset(indentchars, '\t', indent + 1);
	indentchars[indent+1] = 0;

	if ([plist isKindOfClass:[NSArray class]])
	{
		__block NSInteger sub;

		sub = [outStream write:"<array>\n" maxLength:strlen("<array>\n")];
		if (sub < 0)
			return total;
		total += sub;
		[plist enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, bool *stop)
		{
			sub = [outStream write:indentchars maxLength:indent + 1];
			if (sub < 0)
			{
				*stop = true;
				return;
			}
			total += sub;
			sub = writeXMLPropertyList(obj, outStream, opts, indent + 1, err);
			if (sub < 0)
			{
				*stop = true;
				return;
			}
			total += sub;
			sub = [outStream write:"\n" maxLength:1];
			if (sub < 0)
			{
				*stop = true;
				return;
			}
		}];
		if (sub < 0)
			return total;
		indentchars[indent] = 0;
		sub = [outStream write:"</array>" maxLength:strlen("</array>")];
		if (sub < 0)
			return total;
		total += sub;
	}
	else if ([plist isKindOfClass:[NSDictionary class]])
	{
		__block NSInteger sub;

		sub = [outStream write:"<dict>\n" maxLength:strlen("<dict>\n")];
		if (sub < 0)
			return total;
		total += sub;
		sub = [outStream write:indentchars maxLength:indent];
		if (sub < 0)
			return total;
		total += sub;
		[plist enumerateKeysAndObjectsUsingBlock:^(id key, id val, bool *stop){
			sub = [outStream write:indentchars maxLength:indent + 1];
			if (sub < 0)
			{
				*stop = true;
				return;
			}
			total += sub;
			sub = writeXMLPropertyList(key, outStream, opts, indent + 1, err);
			if (sub < 0)
			{
				*stop = true;
				return;
			}
			total += sub;
			sub = [outStream write:"\n" maxLength:1];
			if (sub < 0)
			{
				*stop = true;
				return;
			}
			sub = [outStream write:indentchars maxLength:indent];
			if (sub < 0)
				return;
			total += sub;
			total += sub;
			sub = writeXMLPropertyList(val, outStream, opts, indent + 1, err);
			if (sub < 0)
			{
				*stop = true;
				return;
			}
			total += sub;
			sub = [outStream write:"\n" maxLength:strlen("\n")];
			if (sub < 0)
			{
				*stop = true;
				return;
			}
		}];
		if (sub < 0)
			return total;
		indentchars[indent] = 0;
		sub = [outStream write:indentchars maxLength:indent];
		if (sub < 0)
			return total;
		total += sub;
		sub = [outStream write:"</dict>" maxLength:strlen("</dict>")];
		if (sub < 0)
			return total;
		total += sub;
	}
	else if ([plist isKindOfClass:[NSNumber class]])
	{
		switch (*[plist objCType])
		{
			case _C_BOOL:
				{
					if ([plist boolValue])
					{
						sub = [outStream write:"<true />" maxLength:8];
					}
					else
					{
						sub = [outStream write:"<false />" maxLength:9];
					}
					return (sub > 0) ? sub : 0;
				}
				break;
			case _C_FLT:
			case _C_DBL:
				{
					NSString *dblStr = [NSString stringWithFormat:@"<real>%g</real>",[plist doubleValue]];
					sub = [outStream write:[dblStr UTF8String] maxLength:[dblStr length]];
				}
				break;
			case _C_UCHR:
			case _C_USHT:
			case _C_UINT:
			case _C_ULNG:
			case _C_ULNG_LNG:
				{
					NSString *dblStr = [NSString stringWithFormat:@"<integer>%llu</integer>",[plist unsignedLongLongValue]];
					sub = [outStream write:[dblStr UTF8String] maxLength:[dblStr length]];
				}
				break;
			default:
				{
					NSString *dblStr = [NSString stringWithFormat:@"<integer>%lld</integer>",[plist longLongValue]];
					sub = [outStream write:[dblStr UTF8String] maxLength:[dblStr length]];
				}
				break;
		}
		return (sub <= 0) ? 0 : sub;
	}
	else if ([plist isKindOfClass:[NSDate class]])
	{
		NSDateFormatter *fmt = [NSDateFormatter new];
		[fmt setDateFormat:@"'<date>'yyyy-MM-dd'T'HH:mm:ssZ'</date>'"];
		NSString *s = [fmt stringFromDate:plist];
		sub = [outStream write:[s UTF8String] maxLength:[s length]];
		return (sub <= 0) ? 0 : sub;
	}
	else if ([plist isKindOfClass:[NSData class]])
	{
		NSString *encStr = [plist encodedBase64String];
		sub = [outStream write:"<data>" maxLength:6];
		if (sub < 0)
			return 0;
		total += sub;
		sub = [outStream write:[encStr UTF8String] maxLength:[encStr length]];
		if (sub < 0)
			return 0;
		total += sub;
		sub = [outStream write:"</data>" maxLength:7];
		if (sub < 0)
			return 0;
		total += sub;
	}
	else if ([plist isKindOfClass:[NSString class]])
	{
		NSUInteger size = [plist lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

		sub = [outStream write:"<string>" maxLength:8];
		if (sub < 0)
			return 0;
		total += sub;
		sub = [outStream write:[plist UTF8String] maxLength:size];
		if (sub < 0)
			return 0;
		total += sub;
		sub = [outStream write:"</string>" maxLength:9];
		if (sub < 0)
			return 0;
		total += sub;
	}
	return total;
}
