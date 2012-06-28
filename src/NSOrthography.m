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

#import <Foundation/NSOrthography.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import "internal.h"

@interface NSOrthography()
@property(readwrite) NSString *dominantScript;
@property(readwrite) NSDictionary *languageMap;
@end
@implementation NSOrthography
@synthesize dominantScript;
@synthesize languageMap;

+ (id) orthographyWithDominantScript:(NSString *)domScript languageMap:(NSDictionary *)langMap
{
	return [[NSOrthography alloc] initWithDominantScript:domScript languageMap:langMap];
}

- (id) initWithDominantScript:(NSString *)domScript languageMap:(NSDictionary *)langMap
{
	self.dominantScript = domScript;
	self.languageMap = langMap;
	return self;
}


- (NSArray *) languagesForScript:(NSString *)script
{
	static NSArray *safeLangs;
	NSArray *langs = [[self languageMap] objectForKey:script];

	if (langs == nil)
	{
		if (safeLangs == nil)
		{
			@synchronized([NSOrthography class])
			{
				if (safeLangs == nil)
					safeLangs = @[@"und"];
			}
		}
		langs = safeLangs;
	}
	return langs;
}

- (NSString *) dominantLanguageForScript:(NSString *)script
{
	return [self languagesForScript:script][0];
}

// NSCoding protocol

- (id) initWithCoder:(NSCoder *)coder
{
	NSString *domScript;
	NSDictionary *langMap;
	if ([coder allowsKeyedCoding])
	{
		domScript = [coder decodeObjectForKey:@"NSOrthography.domScript"];
		langMap = [coder decodeObjectForKey:@"NSOrthography.langMap"];
	}
	else
	{
		domScript = [coder decodeObject];
		langMap = [coder decodeObject];
	}
	return [self initWithDominantScript:domScript languageMap:langMap];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		[coder encodeObject:[self dominantScript] forKey:@"NSOrthography.domScript"];
		[coder encodeObject:[self languageMap] forKey:@"NSOrthography.langMap"];
	}
	else
	{
		[coder encodeObject:[self dominantScript]];
		[coder encodeObject:[self languageMap]];
	}
}

- (id) copyWithZone:(NSZone *)zone
{
	return [[[self class] alloc]
		initWithDominantScript:[self dominantScript]
				   languageMap:[self languageMap]];
}

- (NSArray *) allScripts
{
	return [[self languageMap] allKeys];
}

- (NSArray *) allLanguages
{
	return [[self languageMap] allValues];
}

- (NSString *) dominantLanguage
{
	NSArray *domLang = [self languagesForScript:[self dominantScript]];
	if (domLang == nil)
		return @"und";
	return domLang[0];
}

- (NSUInteger) hash
{
	return [[self dominantScript] hash];
}

- (bool) isEqual:(id)other
{
	if (![other isKindOfClass:[NSOrthography class]])
		return false;

	return [[self dominantScript] isEqual:[other dominantScript]] &&
			  [[self languageMap] isEqual:[other languageMap]];
}

@end
