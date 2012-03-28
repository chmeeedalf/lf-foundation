/*
 * Copyright (c) 2009-2012	Gold Project
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
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR COEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */
/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "internal.h"
#import <Foundation/NSFileManager.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDelegate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSHost.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSURL.h>
#import <Foundation/Plugins/Filesystem.h>

#include <unistd.h>
#include <fcntl.h>

static NSString *NSDefaultFileManager = @"NSDefaultFileManager";

@class NSData;

@implementation NSString(NSFileManager)
- (const char *)fileSystemRepresentation
{
	return [self cStringUsingEncoding:[NSString defaultCStringEncoding]];
}
@end

@implementation NSFileManager
- (void) setDelegate:(id<NSFileManagerDelegate>)newDel
{
	if (delegate == nil)
		delegate = [[NSDelegate alloc] initWithProtocol:@protocol(NSFileManagerDelegate)];

	[delegate setDelegate:newDel];
}

- (id<NSFileManagerDelegate>) delegate
{
	return [delegate delegate];
}

+ (NSFileManager *) defaultManager
{
	id defaultManager = [[NSThread currentThread] privateThreadDataForKey:NSDefaultFileManager];
	if (defaultManager == nil)
	{
		defaultManager = [NSFileManager new];
		[[NSThread currentThread] setPrivateThreadData:defaultManager forKey:NSDefaultFileManager];
	}
	return defaultManager;
}

-(bool)createFileAtURL:(NSURL *)path contents:(NSData *)data
			attributes:(NSDictionary *)attributes
{
	id<NSFilesystem> fsHandler = [path handler];

	return [fsHandler createFileAtURL:path contents:data attributes:attributes error:NULL];
}

-(NSArray *)contentsOfDirectoryAtURL:(NSURL *)path error:(NSError **)err
{
	id<NSFilesystem> fsHandler = [path handler];

	return [fsHandler contentsOfDirectoryAtURL:path error:err];
}

-(bool)createDirectoryAtURL:(NSURL *)path withIntermediateDirectories:(bool)intermediates attributes:(NSDictionary *)attributes error:(NSError **)err
{
	id<NSFilesystem> fsHandler = [path handler];

	return [fsHandler createDirectoryAtURL:path withIntermediateDirectories:intermediates attributes:attributes error:err];
}

-(bool)fileExistsAtURL:(NSURL *)path isDirectory:(bool *)isDirectory
{
	NSDictionary *d = [self attributesOfItemAtURL:path error:NULL];
	if (d == nil)
		return false;

	if (isDirectory != NULL)
		*isDirectory = [[d objectForKey:NSFileType] isEqual:NSDirectoryFileType];

	return (d != nil);
}

-(bool)removeItemAtURL:(NSURL *)path error:(NSError **)err
{
	id<NSFilesystem> fsHandler = [path handler];
	err = (err != NULL) ? err : &(NSError *){nil};

	if([[path path] isEqualToString:@"."] || [[path path] isEqualToString:@".."])
		@throw [NSInvalidArgumentException exceptionWithReason:@"Invalid path"
													userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self,@"NSObject",
			NSStringFromSelector(_cmd),@"Method",
			path,@"Path"]];

	[[self delegate] fileManager:self shouldRemoveItemAtURL:path];

	if (![fsHandler deleteItemAtURL:path error:err])
	{
		return [delegate fileManager:self shouldProceedAfterError:*err removingItemAtURL:path];
	}
	return true;
}


-(bool)moveItemAtURL:(NSURL *)src toURL:(NSURL *)dest error:(NSError **)err
{
	/*
	   It's not this easy...
	   return rename([src fileSystemRepresentation],[dest fileSystemRepresentation])?false:true;
	   */

	bool isDirectory;

	if(![delegate fileManager:self shouldMoveItemAtURL:src toURL:dest])
		return false;

	if ([self fileExistsAtURL:src isDirectory:&isDirectory] == false)
		return false;
	if ([self fileExistsAtURL:dest isDirectory:&isDirectory] == true)
		return false;

	if ([[src scheme] isEqualToString:[dest scheme]] && [[src handler] respondsToSelector:@selector(moveItemAtURL:toURL:error:)])
	{
		return [[src handler] moveItemAtURL:src toURL:dest error:err];
	}

	if ([self copyItemAtURL:src toURL:dest error:err] == false)
	{
		[self removeItemAtURL:dest error:err];
		return false;
	}

	// not much we can do if this fails
	[self removeItemAtURL:src error:err];

	return true;
}

-(bool)copyItemAtURL:(NSURL *)src toURL:(NSURL *)dest error:(NSError **)err
{
	bool isDirectory;

	err = (err != NULL) ? err : &(NSError *){nil};

	if(![self fileExistsAtURL:src isDirectory:&isDirectory])
	{
		return [delegate fileManager:self shouldProceedAfterError:(err ? *err : nil) copyingItemAtURL:src toURL:dest];
	}

	if (![delegate fileManager:self shouldCopyItemAtURL:src toURL:dest])
		return false;

	if (!isDirectory)
	{
		int r, w;
		char buf[4096];
		ssize_t count;

#if 0
		if ((w = open([dest fileSystemRepresentation], O_WRONLY|O_CREAT, FOUNDATION_FILE_MODE)) == -1) 
			return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: open() for writing"];
#endif
		if ((r = open([[src path] fileSystemRepresentation], O_RDONLY)) == -1)
			return [delegate fileManager:self shouldProceedAfterError:(err ? *err : nil) copyingItemAtURL:src toURL:dest];

		while ((count = read(r, &buf, sizeof(buf))) > 0)
		{
			if (count == -1) 
				break;

			if (write(w, &buf, count) != count)
			{
				count = -1;
				break;
			}
		}

		close(w);
		close(r);

		if (count == -1)
			return [delegate fileManager:self shouldProceedAfterError:(err ? *err : nil) copyingItemAtURL:src toURL:dest];
		else
			return true;
	}
	else
	{
		NSArray *files;
		long      i,count;

#if 0
		if (mkdir([dest fileSystemRepresentation], FOUNDATION_DIR_MODE) != 0)
			return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: mkdir(subdir)"];
#endif

		//if (chdir([dest fileSystemRepresentation]) != 0)
		//    return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: chdir(subdir)"];

		files = [self contentsOfDirectoryAtURL:src error:NULL];
		count = [files count];

		for(i=0;i<count;i++)
		{
			NSString *name=[files objectAtIndex:i];
			NSURL *subsrc, *subdst;

			if ([name isEqualToString:@"."] || [name isEqualToString:@".."])
				continue;

			subsrc=[src URLByAppendingPathComponent:name];
			subdst=[dest URLByAppendingPathComponent:name];

			if([self copyItemAtURL:subsrc toURL:subdst error:err] == false) 
				return false;
		}

		//if (chdir("..") != 0)
		//    return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: chdir(..)"];
	}

	return true;
}

-(NSString *)currentDirectoryPath
{
	char  path[MAXPATHLEN+1];

	if (getcwd(path, sizeof(path)) != NULL)
		return [NSString stringWithCString:path encoding:[NSString defaultCStringEncoding]];

	return nil;
}

-(NSDictionary *)attributesOfItemAtURL:(NSURL *)path error:(NSError **)errOut
{
	id<NSFilesystem> fsHandler = [path handler];

	return [fsHandler attributesOfItemAtURL:path error:errOut];
}

-(NSDictionary *)attributesOfFileSystemForURL:(NSURL *)path error:(NSError **)errorp
{
	TODO;	// attributesOfFileSystemForURL:error:
	return nil;
}

-(bool)isReadableFileAtURL:(NSURL *)path
{
	return access([[path path] fileSystemRepresentation], R_OK) ? false : true;
}

-(bool)isWritableFileAtURL:(NSURL *)path
{
	return access([[path path] fileSystemRepresentation], W_OK) ? false : true;
}

-(bool)isExecutableFileAtURL:(NSURL *)path
{
	return access([[path path] fileSystemRepresentation], X_OK) ? false : true;
}

-(bool)isDeletableFileAtURL:(NSURL *)path
{
	TODO;	// isDeletableFileAtURL:
	return access([[path path] fileSystemRepresentation], X_OK) ? false : true;
}

-(bool)fileExistsAtURL:(NSURL *)path
{
	return [self fileExistsAtURL:path isDirectory:NULL];
}

-(bool)createSymbolicLinkAtURL:(NSURL *)path withDestinationURL:(NSURL *)toPath error:(NSError **)error
{
	id<NSFilesystem> fsHandler = [path handler];
	return [fsHandler createSymbolicLinkAtURL:path withDestinationURL:toPath error:error];
}

-(bool)changeFileAttributes:(NSDictionary *)attributes atURL:(NSURL *)path 
{
	id<NSFilesystem> fsHandler = [path handler];

	NSMutableDictionary *oldAttributes = [NSMutableDictionary dictionaryWithDictionary:[fsHandler attributesOfItemAtURL:path error:NULL]];
	[oldAttributes addEntriesFromDictionary:attributes];
	return [fsHandler setAttributes:oldAttributes ofItemAtURL:path error:NULL];
}

-(const char *)fileSystemRepresentationWithURL:(NSURL *)path
{
	return [[path path] cStringUsingEncoding:NSUTF8StringEncoding];
}

-(NSArray *)subpathsOfDirectoryAtURL:(NSURL *)uriDir error:(NSError **)err
{
	TODO;	// subpathsOfDirectoryAtURL:error:
	return nil;
}

- (NSData *)contentsOfFileAtURL:(NSURL *)path shared:(bool)shared error:(NSError **)err
{
	id<NSFilesystem> fsHandler = [path handler];
	return [fsHandler contentsOfFileAtURL:path shared:shared error:err];
}

- (bool) changeCurrentDirectoryURL:(NSURL *)path
{
	TODO;	// changeCurrentDirectoryURL:
	return false;
}

- (NSString *)stringWithFileSystemRepresentation:(const char *)fsRep length:(NSIndex)len
{
	return [[NSString alloc] initWithBytes:fsRep length:len encoding:NSUTF8StringEncoding];
}

-(bool)setAttributes:(NSDictionary *)attributes ofItemAtURL:(NSURL *)path error:(NSError **)error
{
	id<NSFilesystem> fsHandler = [path handler];
	return [fsHandler setAttributes:attributes ofItemAtURL:path error:error];
}

-(bool)linkItemAtURL:(NSURL *)fromPath toURL:(NSURL *)toPath error:(NSError **)error
{
	id<NSFilesystem> fsHandler;
	if (![[fromPath scheme] isEqual:[toPath scheme]])
		return false;
	if (![[fromPath host] isEqual:[toPath host]])
		return false;
	fsHandler = [fromPath handler];
	return [fsHandler linkItemAtURL:fromPath toURL:toPath error:error];
}

-(NSString *)destinationOfSymbolicLinkAtURL:(NSURL *)path error:(NSError **)error
{
	id<NSFilesystem> fsHandler = [path handler];
	return [fsHandler destinationOfSymbolicLinkAtURL:path error:error];
}

-(bool)contentsEqualAtURL:(NSURL *)path1 andURL:(NSURL *)path2
{
	TODO;	// contentsEqualAtURL:andURL:
	return false;
}

@end

NSString * const NSRegularFileType = @"NSFileTypeRegular";
NSString * const NSDirectoryFileType = @"NSFileTypeDirectory";
NSString * const NSSymbolicLinkFileType = @"NSFileTypeSymbolicLink";
NSString * const NSCharacterSpecialFileType = @"NSFileTypeCharacterSpecial";
NSString * const NSBlockSpecialFileType = @"NSFileTypeBlockSpecial";
NSString * const NSSocketFileType = @"NSFileTypeSocket";
NSString * const NSUnknownFileType = @"NSFileTypeUnknown";
NSString * const NSFIFOFileType = @"NSFIFOFileType";

NSString * const NSFileType = @"NSFileType";
NSString * const NSFileSize = @"NSFileSize";
NSString * const NSFileModificationDate = @"NSFileModificationDate";
NSString * const NSFileOwnerAccountName = @"NSFileOwnerAccountName";
NSString * const NSFileGroupOwnerAccountName = @"NSFileGroupOwnerAccountName";
NSString * const NSFilePosixPermissions = @"NSFilePosixPermissions";
NSString * const NSFileAccess = @"NSFileAccess";
NSString * const NSFileReferenceCount = @"NSFileReferenceCount";
NSString * const NSFileIdentifier = @"NSFileIdentifier";
NSString * const NSFileDeviceIdentifier = @"NSFileDeviceIdentifier";

NSString * const NSFileSystemNumber = @"NSFileSystemNumber";
NSString * const NSFileSystemSize = @"NSFileSystemSize";
NSString * const NSFileSystemFreeSize = @"NSFileSystemFreeSize";
