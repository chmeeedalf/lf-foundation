/*
 * Copyright (c) 2009-2012	Justin Hibbits
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

#import <Foundation/NSFormatter.h>
#import <Foundation/NSObject.h>

@class NSString, NSError;

@implementation NSFormatter

- (NSString *)stringForObjectValue:(id)val
{
	return [self subclassResponsibility:_cmd];
}

- (NSString *)editingStringForObjectValue:(id)val
{
	return [self stringForObjectValue:val];
}

- (NSAttributedString *)attributedStringForObjectValue:(id)val withDefaultAttributes:(NSDictionary *)attributes
{
	return nil;
}

- (bool)getObjectValue:(id *)val forString:(NSString *)str range:(NSRange *)range error:(NSError **)err
{
	[self subclassResponsibility:_cmd];
	return false;
}

- (bool)isPartialStringValid:(NSString **)partialPtr proposedSelecttedRange:(NSRange *)propsedRange originalString:(NSString *)orig originalSelectedRange:(NSRange)origSelRange errorDescription:(NSError **)err
{
	[self subclassResponsibility:_cmd];
	return false;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
}

- (id) initWithCoder:(NSCoder *)coder
{
    return [super init];
}

- (id) copyWithZone:(NSZone *)zone
{
	return [[self class] allocWithZone:zone];
}

@end
