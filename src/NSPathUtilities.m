/* 
   PathUtilities.m
 * All rights reserved.

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

   This file is part of libFoundation.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.
 */

#import <Foundation/NSPathUtilities.h>

#include <limits.h>			/* for PATH_MAX */
#include <stdlib.h>

#import <Foundation/NSAccount.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import "internal.h"

/*
 * User Account Functions
 */

NSString *NSUserName(void)
{
	return [[NSUserAccount currentAccount] accountName];
}

NSString *NSHomeDirectory(void)
{
	return [[NSUserAccount currentAccount] homeDirectory];
}

NSString *NSHomeDirectoryForUser(NSString* userName)
{
	return [[NSUserAccount accountWithName:userName] homeDirectory];
}

NSString *NSFullUserName()
{
	return [[NSUserAccount currentAccount] fullName];
}

NSString *NSTemporaryDirectory()
{
	return @"/tmp";
}

/*
 * NSString file naming functions
 */

static NSString *pathSeparator = @"/";
static NSString *extensionSeparator = @".";
static NSString *nullSeparator = @"";
static NSString *homeSeparator = @"~";
static NSString *parentDirName = @"..";
static NSString *selfDirName = @".";

static NSString *rootPath = @"/";

@implementation NSString(NSString_pathUtilities)

+ (NSString *)pathWithComponents:(NSArray *)components
{
	id result;

	result = [NSMutableString new];
	[components enumerateObjectsUsingBlock:^(id str, NSUInteger idx, bool *stop){
		if ([str length] == 0 || [str isEqualToString:pathSeparator])
		{
			return;
		}
		[result appendString:pathSeparator];
		[result appendString:str];
	}];

	if ([result length] == 0)
	{
		result = nullSeparator;
	}

	return result;
}

- (NSArray *)pathComponents
{
	NSMutableArray* components = [[self componentsSeparatedByString:pathSeparator] mutableCopy];
	int i;

	for (i = [components count]-1; i >= 0; i--)
	{
		if ([[components objectAtIndex:i] isEqual:nullSeparator])
		{
			[components removeObjectAtIndex:i];
		}
	}

	if ([self hasPrefix:pathSeparator])
	{
		[components insertObject:pathSeparator atIndex:0];
	}

	if ([self hasSuffix:pathSeparator])
	{
		[components addObject:nullSeparator];
	}

	return components;
}

- (unsigned long)completePathIntoString:(NSString **)outputName
						  caseSensitive:(bool)flag matchesIntoArray:(NSArray **)outputArray
							filterTypes:(NSArray *)filterTypes
{
	NSString *root = [self stringByDeletingLastPathComponent];
	NSString *lastPart = [self lastPathComponent];
	NSDirectoryEnumerator *en = [[NSFileManager defaultManager]
		enumeratorAtURL:[NSURL fileURLWithPath:root]
		includingPropertiesForKeys:nil
						   options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
					  errorHandler:^bool(NSURL *ignore, NSError *errp){ return true;}];
	NSMutableSet *paths = [NSMutableSet new];
	NSString *longest = nil;

	if (flag)
		lastPart = [lastPart uppercaseString];
	for (NSString *item in en)
	{
		NSString *testItem = item;

		if (flag)
		{
			testItem = [item uppercaseString];
		}
		if (![testItem hasPrefix:lastPart])
			continue;

		if (filterTypes == nil || [filterTypes containsObject:[item pathExtension]])
		{
			NSString *thisPath = [root stringByAppendingPathComponent:item];
			[paths addObject:thisPath];
			if ([thisPath length] > [longest length])
				longest = thisPath;
		}
	}
	if (outputName != NULL)
		*outputName = longest;
	if (outputArray != NULL)
		*outputArray = [paths allObjects];
	return [paths count];
}

- (const char *)fileSystemRepresentation
{
	// WIN32
	return [self cStringUsingEncoding:NSUTF8StringEncoding];
}

- (bool)getFileSystemRepresentation:(char *)buffer
						  maxLength:(unsigned int)maxLength
{
	return [self getCString:buffer maxLength:maxLength
			encoding:NSUTF8StringEncoding];
}

- (bool)isAbsolutePath
{
	if (![self length])
		return false;

	if ([self hasPrefix:rootPath] || [self hasPrefix:@"~"])
		return true;

	return false;
}

- (NSString *)lastPathComponent
{
	NSRange sepRange;
	NSRange lastRange = { 0, 0 };

	lastRange.length = [self length];
	if ([self hasSuffix:pathSeparator])
	{
		if (lastRange.length == [pathSeparator length])
			return nullSeparator;

		lastRange.length--;
	}

	sepRange = [self rangeOfString:pathSeparator
						   options:NSBackwardsSearch range:lastRange];
	if (sepRange.length == 0)
		return [self copyWithZone:[self zone]];

	lastRange.location = sepRange.location + sepRange.length;
	lastRange.length   = lastRange.length - lastRange.location;

	if (lastRange.location == 0)
		return [self copyWithZone:[self zone]];
	else
		return lastRange.length ? 
			[self substringWithRange:lastRange] : nullSeparator;
}

- (NSString *)pathExtension
{
	NSRange  sepRange, lastRange;
	NSString *lastComponent;
	int      length;

	lastComponent = [self lastPathComponent];
	length        = [lastComponent length];

	sepRange = [lastComponent rangeOfString:extensionSeparator 
									options:NSBackwardsSearch];
	if (sepRange.length == 0)
		return @"";

	lastRange.location = sepRange.location + sepRange.length;
	lastRange.length   = length - lastRange.location;

	return lastRange.length && sepRange.length ? 
		[lastComponent substringWithRange:lastRange] : nullSeparator;
}

- (NSString *)stringByAppendingPathComponent:(NSString *)aString
{
	NSString *str;

	str = [self hasSuffix:pathSeparator] ? nullSeparator : pathSeparator;

	return [aString length]
		? [self stringByAppendingString:
		([self length]
		 ? [str stringByAppendingString:aString] 
									   : aString)]
									   : [self copyWithZone:[self zone]];
}

- (NSArray *)stringsByAppendingPaths:(NSArray *)paths
{
	NSMutableArray *array;
	int i, n;

	array = [NSMutableArray array];

	for (i = 0, n = [paths count]; i < n; i++)
	{
		[array addObject:[self stringByAppendingPathComponent:[paths objectAtIndex:i]]];
	}
	return array;
}

- (NSString *)stringByAppendingPathExtension:(NSString *)aString
{
	return [aString length] ?
		[self stringByAppendingString:
			[extensionSeparator stringByAppendingString:aString]] :
		[self copyWithZone:[self zone]];
}

- (NSString *)stringByDeletingLastPathComponent
{
	NSRange range = {0, [self length]};

	if (range.length == 0)
		return nullSeparator;

	if ([self isEqualToString:pathSeparator])
		return pathSeparator;

	range.length--;
	range = [self rangeOfString:pathSeparator
						options:NSBackwardsSearch range:range];

	if (range.length == 0)
		return nullSeparator;
	if (range.location == 0)
		return pathSeparator;

	return [self substringWithRange:NSMakeRange(0, range.location)];
}

- (NSString *)stringByDeletingPathExtension
{
	NSRange range = {0, [self length]};
	NSRange extSep, patSep;

	if (range.length == 0)
		return nullSeparator;

	if ([self hasSuffix:pathSeparator])
	{
		if (range.length == 1)
			return [self copyWithZone:[self zone]];
		else
			range.length--;
	}

	extSep = [self rangeOfString:extensionSeparator
						 options:NSBackwardsSearch range:range];

	if (extSep.length != 0)
	{
		patSep = [self rangeOfString:pathSeparator
							 options:NSBackwardsSearch range:range];
		if (patSep.length != 0)
		{
			if (extSep.location > patSep.location + 1)
			{
				range.length = extSep.location;
			}
			/* else the filename begins with a dot so don't consider it as
			   being an extension; do nothing */
		}
		else
		{
			range.length = extSep.location;
		}
	}

	return [self substringWithRange:range];
}

- (NSString *)stringByAbbreviatingWithTildeInPath
{
	NSString *home;
	int      homeLength;

	home       = NSHomeDirectory();
	homeLength = [home length];

	if (![self hasPrefix:home])
		return self;

	home = [self substringWithRange:
		NSMakeRange(homeLength, [self length] - homeLength)];

	return [homeSeparator stringByAppendingString:
					   ([home length] > 0 ? home : pathSeparator)];
}

- (NSString *)stringByExpandingTildeInPath
{
	NSString *rest;
	NSString *home;
	unsigned int index;
	unsigned int hlen;

	if (![self hasPrefix:homeSeparator])
		return self;

	index = [self indexOfString:pathSeparator];
	hlen  = [homeSeparator length];

	if (index == hlen)
		home = NSHomeDirectory();
	else
	{
		home = NSHomeDirectoryForUser([self substringWithRange:
				NSMakeRange(hlen, (index == NSNotFound) ?  
					[self length] - hlen : index - hlen)]);
	}

	if (index == NSNotFound)
		rest = nullSeparator;
	else
		rest = [self substringWithRange:
			NSMakeRange(index + 1, [self length] - index - 1)];

	return [home stringByAppendingPathComponent:rest];
}

- (NSString *)stringByResolvingSymlinksInPath
{
	unsigned char resolved[PATH_MAX];
	const char *source;

	source = [self cStringUsingEncoding:NSUTF8StringEncoding];

	if (!realpath(source, (char *)resolved))
	{
		return self;
	}
	return [NSString stringWithCString:(char *)resolved encoding:NSUTF8StringEncoding];
}

- (NSString *)stringByStandardizingPath
{
	if ([self isAbsolutePath])
		return [self stringByResolvingSymlinksInPath];

	{
		NSString       *path;
		NSMutableArray *components;
		int            i, n;

		components = [[self pathComponents] mutableCopy];
		n = [components count];
		/* remove "//" and "/./" components */
		for (i = n - 1; i >= 0; i--)
		{
			NSString *comp;

			comp = [components objectAtIndex:i];

			if ([comp length] == 0 || [comp isEqualToString:selfDirName])
			{
				[components removeObjectAtIndex:i];
				continue;
			}
		}

		/* compact ".../dir1/../dir2/..." into ".../dir2/..." */
		n = [components count];
		for (i = 1; i < n; i++)
		{
			if ([[components objectAtIndex:i] isEqualToString:parentDirName] 
					&& i > 0 &&
					![[components objectAtIndex:i-1] isEqualToString:parentDirName])
			{
				i -= 1;
				[components removeObjectAtIndex:i];
				[components removeObjectAtIndex:i];
			}
		}

		path = [NSString pathWithComponents:components];

		return path ? path : self;
	}
}

@end /* NSString(FilePathMethods) */

@implementation NSArray(FilePathMethods)

- (NSArray *)pathsMatchingExtensions:(NSArray *)_exts
{
	/* new in MacOSX */
	NSSet          *exts;
	NSMutableArray *ma;

	exts = [[NSSet alloc] initWithArray:_exts];
	ma   = [[NSMutableArray alloc] init];

	for (NSString *path in self)
	{
		if ([exts containsObject:[path pathExtension]])
		{
			[ma addObject:path];
		}
	}

	return [ma copy];
}

@end /* NSArray(FilePathMethods) */

/*
 * Used for forcing linking of this category
 */
void __dummyStringFilePathfile(void);
void __dummyStringFilePathfile ()
{
	__dummyStringFilePathfile();
}
/*
   Local Variables:
	c-basic-offset: 4
		 tab-width: 8
			   End:
			   */
