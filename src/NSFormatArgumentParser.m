/*
 * Copyright (c) 2012	Justin Hibbits
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

#import <Foundation/NSArray.h>
#import <Foundation/NSScanner.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import "NSFormatArgumentParser.h"

@implementation NSFormatArgumentParser
+ (NSArray *) parseArgumentList:(va_list)argList forFormat:(NSString *)format
{
	NSScanner *scan = [NSScanner scannerWithString:format];
	NSMutableArray *outArgs = [NSMutableArray array];

	while ([scan scanUpToString:@"%" intoString:NULL])
	{
		[scan scanString:@"%" intoString:NULL];
		switch ([format characterAtIndex:[scan scanLocation]])
		{
			case 'd':
			case 'i':
				[outArgs addObject:@(va_arg(argList, int))];
				break;
			case 'o':
			case 'u':
			case 'x':
			case 'X':
				[outArgs addObject:@(va_arg(argList, unsigned int))];
				break;
			case 'A':
			case 'e':
			case 'E':
			case 'f':
			case 'F':
			case 'g':
			case 'G':
			case 'a':
				[outArgs addObject:@(va_arg(argList, double))];
				break;
			case 's':
				[outArgs addObject:@(va_arg(argList, char *))];
				break;
			case '%':
			default:
				break;
		}
	}
	return outArgs;
}
@end
