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

#import <Foundation/NSValueTransformer.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

@class NSString, NSArray;

extern NSString * const NSNegateBooleanTransformerName;
extern NSString * const NSIsNilTransformerName;
extern NSString * const NSIsNotNilTransformerName;
extern NSString * const NSUnarchiveFromDataTranformerName;
extern NSString * const NSKeyedUnarchiveFromDataTransformerName;

static NSMutableDictionary *transformers;
static NSLock *transDictLock;

@implementation NSValueTransformer

+ (void) initialize
{
	if (transDictLock != nil)
		return;
	transDictLock = [NSLock new];
}

+ (void) setValueTransformer:(NSValueTransformer *)t forName:(NSString *)name
{
	[transDictLock lock];
	if (transformers == nil)
		transformers = [NSMutableDictionary new];
	[transformers setObject:t forKey:name];
	[transDictLock unlock];
}

+ (id) valueTransformerForName:(NSString *) name
{
	return [transformers objectForKey:name];
}

+ (NSArray *) valueTransformerNames
{
	return [transformers allKeys];
}

+ (bool) allowsReverseTransformation
{
	return false;
}

+ (Class) transformedValueClass
{
	return [self subclassResponsibility:_cmd];
}

- (id) transformedValue:(id)val
{
	return [self subclassResponsibility:_cmd];
}

- (id) reverseTransformedValue:(id)value
{
	if (![[self class] allowsReverseTransformation])
	{
		@throw [NSStandardException exceptionWithReason:[NSString stringWithFormat:@"[%@] is not reversible",NSStringFromClass([self class])] userInfo:nil];
	}
	return [self transformedValue:value];
}
@end
