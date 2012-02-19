
/*
 * Copyright (c) 2012	Gold Project
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

#import <objc/runtime.h>
#import <Foundation/NSClassDescription.h>
#import <Foundation/NSDictionary.h>

extern NSString *NSClassDescriptionNeededForClassNotification;

static NSMutableDictionary *classDescriptionTable;

@implementation NSClassDescription
+ (NSClassDescription *) classDescriptionForClass:(Class)cls
{
	@synchronized(self)
	{
		id ret;

		for (;cls != nil;cls = class_getSuperclass(cls))
		{
			ret = [classDescriptionTable objectForKey:cls];
			if (ret != nil)
			{
				break;
			}
		}
		return [ret new];
	}
}

+ (void) invalidateClassDescriptionCache
{
}

+ (void) registerClassDescription:(NSClassDescription *)desc forClass:(Class)cls
{
	@synchronized(self)
	{
		if (classDescriptionTable == nil)
		{
			classDescriptionTable = [NSMutableDictionary new];
		}
		[classDescriptionTable setObject:desc forKey:cls];
	}
}


- (NSArray *) attributeKeys
{
	return nil;
}

- (NSString *) inverseForRelationshipKey:(NSString *)key
{
	return nil;
}

- (NSArray *) toManyRelationshipKeys
{
	return nil;
}

- (NSArray *) toOneRelationshipKeys
{
	return nil;
}

@end


@implementation NSObject(NSClassDescription)
- (NSArray *) attributeKeys
{
	return [[self classDescription] attributeKeys];
}

- (NSClassDescription *) classDescription
{
	return [NSClassDescription classDescriptionForClass:[self class]];
}

- (NSString *) inverseForRelationshipKey:(NSString *)key
{
	return [[self classDescription] inverseForRelationshipKey:key];
}

- (NSArray *) toManyRelationshipKeys
{
	return [[self classDescription] toManyRelationshipKeys];
}

- (NSArray *) toOneRelationshipKeys
{
	return [[self classDescription] toOneRelationshipKeys];
}
@end

/*
   vim:syntax=objc:
 */
