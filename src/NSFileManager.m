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
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSURI.h>
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
		[defaultManager release];
	}
	return defaultManager;
}

-(bool)createFileAtURI:(NSURI *)path contents:(NSData *)data
			attributes:(NSDictionary *)attributes
{
	id<NSFilesystem> fsHandler = [path handler];

	return [fsHandler createFileAtURI:path contents:data attributes:attributes error:NULL];
}

-(NSArray *)contentsOfDirectoryAtURI:(NSURI *)path error:(NSError **)err
{
	id<NSFilesystem> fsHandler = [path handler];

	return [fsHandler contentsOfDirectoryAtURI:path error:err];
}

-(bool)createDirectoryAtURI:(NSURI *)path withIntermediateDirectories:(bool)intermediates attributes:(NSDictionary *)attributes error:(NSError **)err
{
	id<NSFilesystem> fsHandler = [path handler];

	return [fsHandler createDirectoryAtURI:path withIntermediateDirectories:intermediates attributes:attributes error:err];
}

-(bool)fileExistsAtURI:(NSURI *)path isDirectory:(bool *)isDirectory
{
	NSDictionary *d = [self attributesOfItemAtURI:path error:NULL];
	if (d == nil)
		return false;

	if (isDirectory != NULL)
		*isDirectory = [[d objectForKey:NSFileType] isEqual:NSDirectoryFileType];

	return (d != nil);
}

-(bool)removeItemAtURI:(NSURI *)path error:(NSError **)err
{
	id<NSFilesystem> fsHandler = [path handler];
	err = (err != NULL) ? err : &(NSError *){nil};

	if([[path path] isEqualToString:@"."] || [[path path] isEqualToString:@".."])
		@throw [NSInvalidArgumentException exceptionWithReason:@"Invalid path"
													userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self,@"NSObject",
			NSStringFromSelector(_cmd),@"Method",
			path,@"Path"]];

	[[self delegate] fileManager:self shouldRemoveItemAtURI:path];

	if (![fsHandler deleteItemAtURI:path error:err])
	{
		return [delegate fileManager:self shouldProceedAfterError:*err removingItemAtURI:path];
	}
	return true;
}


-(bool)moveItemAtURI:(NSURI *)src toURI:(NSURI *)dest error:(NSError **)err
{
	/*
	   It's not this easy...
	   return rename([src fileSystemRepresentation],[dest fileSystemRepresentation])?false:true;
	   */

	bool isDirectory;

	if(![delegate fileManager:self shouldMoveItemAtURI:src toURI:dest])
		return false;

	if ([self fileExistsAtURI:src isDirectory:&isDirectory] == false)
		return false;
	if ([self fileExistsAtURI:dest isDirectory:&isDirectory] == true)
		return false;

	if ([self copyItemAtURI:src toURI:dest error:err] == false)
	{
		[self removeItemAtURI:dest error:err];
		return false;
	}

	// not much we can do if this fails
	[self removeItemAtURI:src error:err];

	return true;
}

-(bool)copyItemAtURI:(NSURI *)src toURI:(NSURI *)dest error:(NSError **)err
{
	bool isDirectory;

	err = (err != NULL) ? err : &(NSError *){nil};

	if(![self fileExistsAtURI:src isDirectory:&isDirectory])
	{
		return [delegate fileManager:self shouldProceedAfterError:(err ? *err : nil) copyingItemAtURI:src toURI:dest];
	}

	if (![delegate fileManager:self shouldCopyItemAtURI:src toURI:dest])
		return false;

	if (!isDirectory)
	{
		int r, w;
		char buf[4096];
		size_t count;

#if 0
		if ((w = open([dest fileSystemRepresentation], O_WRONLY|O_CREAT, FOUNDATION_FILE_MODE)) == -1) 
			return [self _errorHandler:handler src:src dest:dest operation:@"copyPath: open() for writing"];
#endif
		if ((r = open([[src path] fileSystemRepresentation], O_RDONLY)) == -1)
			return [delegate fileManager:self shouldProceedAfterError:(err ? *err : nil) copyingItemAtURI:src toURI:dest];

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
			return [delegate fileManager:self shouldProceedAfterError:(err ? *err : nil) copyingItemAtURI:src toURI:dest];
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

		files = [self contentsOfDirectoryAtURI:src error:NULL];
		count = [files count];

		for(i=0;i<count;i++)
		{
			NSString *name=[files objectAtIndex:i];
			NSURI *subsrc, *subdst;

			if ([name isEqualToString:@"."] || [name isEqualToString:@".."])
				continue;

			subsrc=[src URIByAppendingPathComponent:name];
			subdst=[dest URIByAppendingPathComponent:name];

			if([self copyItemAtURI:subsrc toURI:subdst error:err] == false) 
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

-(NSDictionary *)attributesOfItemAtURI:(NSURI *)path error:(NSError **)errOut
{
	id<NSFilesystem> fsHandler = [path handler];

	return [fsHandler attributesOfItemAtURI:path error:errOut];
}

-(NSDictionary *)attributesOfFileSystemForURI:(NSURI *)path error:(NSError **)errorp
{
	TODO;	// attributesOfFileSystemForURI:error:
	return nil;
}

-(bool)isReadableFileAtURI:(NSURI *)path
{
	return access([[path path] fileSystemRepresentation], R_OK) ? false : true;
}

-(bool)isWritableFileAtURI:(NSURI *)path
{
	return access([[path path] fileSystemRepresentation], W_OK) ? false : true;
}

-(bool)isExecutableFileAtURI:(NSURI *)path
{
	return access([[path path] fileSystemRepresentation], X_OK) ? false : true;
}

-(bool)isDeletableFileAtURI:(NSURI *)path
{
	TODO;	// isDeletableFileAtURI:
	return access([[path path] fileSystemRepresentation], X_OK) ? false : true;
}

-(bool)fileExistsAtURI:(NSURI *)path
{
	return [self fileExistsAtURI:path isDirectory:NULL];
}

-(bool)createSymbolicLinkAtURI:(NSURI *)path withDestinationURI:(NSURI *)toPath error:(NSError **)error
{
	id<NSFilesystem> fsHandler = [path handler];
	return [fsHandler createSymbolicLinkAtURI:path withDestinationURI:toPath error:error];
}

-(bool)changeFileAttributes:(NSDictionary *)attributes atURI:(NSURI *)path 
{
	id<NSFilesystem> fsHandler = [path handler];

	NSMutableDictionary *oldAttributes = [NSMutableDictionary dictionaryWithDictionary:[fsHandler attributesOfItemAtURI:path error:NULL]];
	[oldAttributes addEntriesFromDictionary:attributes];
	return [fsHandler setAttributes:oldAttributes ofItemAtURI:path error:NULL];
}

-(const char *)fileSystemRepresentationWithURI:(NSURI *)path
{
	return [[path path] cStringUsingEncoding:NSUTF8StringEncoding];
}

-(NSArray *)subpathsOfDirectoryAtURI:(NSURI *)uriDir error:(NSError **)err
{
	TODO;	// subpathsOfDirectoryAtURI:error:
	return nil;
}

- (NSData *)contentsOfFileAtURI:(NSURI *)path shared:(bool)shared error:(NSError **)err
{
	id<NSFilesystem> fsHandler = [path handler];
	return [fsHandler contentsOfFileAtURI:path shared:shared error:err];
}

- (bool) changeCurrentDirectoryURI:(NSURI *)path
{
	TODO;	// changeCurrentDirectoryURI:
	return false;
}

- (NSString *)stringWithFileSystemRepresentation:(const char *)fsRep length:(NSIndex)len
{
	return [[[NSString alloc] initWithBytes:fsRep length:len encoding:NSUTF8StringEncoding] autorelease];
}

-(bool)setAttributes:(NSDictionary *)attributes ofItemAtURI:(NSURI *)path error:(NSError **)error
{
	id<NSFilesystem> fsHandler = [path handler];
	return [fsHandler setAttributes:attributes ofItemAtURI:path error:error];
}

-(bool)linkItemAtURI:(NSURI *)fromPath toURI:(NSURI *)toPath error:(NSError **)error
{
	id<NSFilesystem> fsHandler;
	if (![[fromPath scheme] isEqual:[toPath scheme]])
		return false;
	if (![[fromPath host] isEqual:[toPath host]])
		return false;
	fsHandler = [fromPath handler];
	return [fsHandler linkItemAtURI:fromPath toURI:toPath error:error];
}

-(NSString *)destinationOfSymbolicLinkAtURI:(NSURI *)path error:(NSError **)error
{
	id<NSFilesystem> fsHandler = [path handler];
	return [fsHandler destinationOfSymbolicLinkAtURI:path error:error];
}

-(bool)contentsEqualAtURI:(NSURI *)path1 andURI:(NSURI *)path2
{
	TODO;	// contentsEqualAtURI:andURI:
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
