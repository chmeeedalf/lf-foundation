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
/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include <sys/param.h>
#include <sys/ucred.h>
#include <sys/mount.h>

#include <fcntl.h>
#include <unistd.h>

#import "internal.h"
#import <Foundation/NSFileManager.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDelegate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSHost.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSValue.h>
#import <Foundation/Plugins/Filesystem.h>

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
	id defaultManager = [[[NSThread currentThread] threadDictionary] objectForKey:NSDefaultFileManager];
	if (defaultManager == nil)
	{
		defaultManager = [NSFileManager new];
		[[[NSThread currentThread] threadDictionary] setObject:defaultManager forKey:NSDefaultFileManager];
	}
	return defaultManager;
}

- (id) init
{
	return self;
}

-(bool)createFileAtURL:(NSURL *)path contents:(NSData *)data
			attributes:(NSDictionary *)attributes
{
	id<NSFilesystem> fsHandler = [path handler];

	return [fsHandler createFileAtURL:path contents:data attributes:attributes error:NULL];
}

- (NSDirectoryEnumerator *) enumeratorAtURL:(NSURL *)url
{
	return [self enumeratorAtURL:url
	  includingPropertiesForKeys:nil
						 options:0
					errorHandler:nil];
}

-(NSDirectoryEnumerator *)enumeratorAtURL:(NSURL *)url
			   includingPropertiesForKeys:(NSArray *)keys
			   					  options:(NSDirectoryEnumerationOptions)mask
			   				 errorHandler:(bool (^)(NSURL *, NSError *))handler
{
	id<NSFilesystem> fsHandler = [url handler];

	return [fsHandler enumeratorAtURL:url
		   includingPropertiesForKeys:nil
							  options:0
						 errorHandler:handler];
}

-(NSArray *)contentsOfDirectoryAtURL:(NSURL *)path error:(NSError **)err
{
	id<NSFilesystem> fsHandler = [path handler];

	return [fsHandler contentsOfDirectoryAtURL:path error:err];
}

-(NSArray *)contentsOfDirectoryAtURL:(NSURL *)path
		  includingPropertiesForKeys:(NSArray *)keys
		  					 options:(NSDirectoryEnumerationOptions)mask
		  					   error:(NSError **)error
{
	NSString *dirent;
	NSMutableArray *result = [NSMutableArray new];
	NSDirectoryEnumerator *en = [self enumeratorAtURL:path];
	[en skipDescendants];

	for (dirent in [self enumeratorAtURL:path
			  includingPropertiesForKeys:keys
								 options:(mask | NSDirectoryEnumerationSkipsSubdirectoryDescendants)
								   errorHandler:^bool(NSURL *url, NSError *err){
								   *error = err;
								   return true;
								   } ])
	{
		[result addObject:dirent];
	}
	return [result copy];
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
		*isDirectory = [[d objectForKey:NSFileType] isEqual:NSFileTypeDirectory];

	return (d != nil);
}

-(bool)removeItemAtURL:(NSURL *)path error:(NSError **)errp
{
	id<NSFilesystem> fsHandler = [path handler];
	
	if([[path path] isEqualToString:@"."] || [[path path] isEqualToString:@".."])
		@throw [NSInvalidArgumentException exceptionWithReason:@"Invalid path"
													userInfo:@{
												   @"Object": self,
												   @"Method": NSStringFromSelector(_cmd),
													 @"Path": path}];

	[[self delegate] fileManager:self shouldRemoveItemAtURL:path];

	if (![fsHandler deleteItemAtURL:path error:errp])
	{
		return [delegate fileManager:self shouldProceedAfterError:(errp?*errp:nil) removingItemAtURL:path];
	}
	return true;
}

-(bool)replaceItemAtURL:(NSURL *)original
		  withItemAtURL:(NSURL *)newURL
		 backupItemName:(NSString *)backupName
		 		options:(NSFileManagerItemReplacementOptions)options
	   resultingItemURL:(NSURL **)result
	   			  error:(NSError **)errp
{
	TODO; //-[NSFileManager replaceItemAtURL:withItemAtURL:backupItemName:options:resultingItemURL:error:]
	return nil;
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

-(bool)copyItemAtURL:(NSURL *)src toURL:(NSURL *)dest error:(NSError **)errp
{
	bool isDirectory;

	if(![self fileExistsAtURL:src isDirectory:&isDirectory])
	{
		return [delegate fileManager:self shouldProceedAfterError:(errp ? *errp : nil) copyingItemAtURL:src toURL:dest];
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
			return [delegate fileManager:self shouldProceedAfterError:(errp ? *errp : nil) copyingItemAtURL:src toURL:dest];

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
			return [delegate fileManager:self shouldProceedAfterError:(errp ? *errp : nil) copyingItemAtURL:src toURL:dest];
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

			if([self copyItemAtURL:subsrc toURL:subdst error:errp] == false) 
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

- (NSArray *) componentsToDisplayForURL:(NSURL *)url
{
	return [[url path] pathComponents];
}

- (NSString *) displayNameAtURL:(NSURL *)url
{
	return [[self attributesOfItemAtURL:url error:NULL] objectForKey:NSFileDisplayName];
}

-(NSDictionary *)attributesOfItemAtURL:(NSURL *)path error:(NSError **)errOut
{
	id<NSFilesystem> fsHandler = [path handler];

	return [fsHandler attributesOfItemAtURL:path error:errOut];
}

-(NSDictionary *)attributesOfFileSystemForURL:(NSURL *)path error:(NSError **)errorp
{
	id<NSFilesystem> fsHandler = [path handler];

	return [fsHandler attributesOfFileSystemForURL:path error:errorp];
}

-(bool)isReadableFileAtURL:(NSURL *)path
{
	NSDictionary *attribs = [self attributesOfItemAtURL:path error:NULL];
	if (attribs == nil)
		return false;

	return ([attribs filePosixPermissions] & 0444) && ([[attribs fileType] isEqual:NSFileTypeRegular]);
}

-(bool)isWritableFileAtURL:(NSURL *)path
{
	NSDictionary *attribs = [self attributesOfItemAtURL:path error:NULL];
	if (attribs == nil)
		return false;

	return ([attribs filePosixPermissions] & 0222) && ([[attribs fileType] isEqual:NSFileTypeRegular]);
}

-(bool)isExecutableFileAtURL:(NSURL *)path
{
	NSDictionary *attribs = [self attributesOfItemAtURL:path error:NULL];
	if (attribs == nil)
		return false;

	return ([attribs filePosixPermissions] & 0111) && ([[attribs fileType] isEqual:NSFileTypeRegular]);
}

-(bool)isDeletableFileAtURL:(NSURL *)path
{
	NSDictionary *attribs = [self attributesOfItemAtURL:path error:NULL];
	if (attribs == nil)
		return false;

	if (!(([attribs filePosixPermissions] & 0222) && ([[attribs fileType] isEqual:NSFileTypeRegular])))
		return false;
	attribs = [self attributesOfItemAtURL:[path URLByDeletingLastPathComponent] error:NULL];
	if (!(([attribs filePosixPermissions] & 0222) && ([[attribs fileType] isEqual:NSFileTypeDirectory])))
		return false;
	return true;
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

-(NSArray *)subpathsOfDirectoryAtURL:(NSURL *)urlDir error:(NSError **)errp
{
	NSMutableArray *retval = [NSMutableArray new];
	NSDirectoryEnumerator *enumerator = [self enumeratorAtURL:urlDir
								   includingPropertiesForKeys:nil
													  options:0
												 errorHandler:^bool(NSURL *url, NSError *err){
												 	 if (errp != NULL)
												 	 	 *errp = err;
												 	 return true;
												 }];
	for (id path in enumerator)
	{
		[retval addObject:path];
	}
	return [retval copy];
}

- (NSData *)contentsOfFileAtURL:(NSURL *)path shared:(bool)shared error:(NSError **)err
{
	id<NSFilesystem> fsHandler = [path handler];
	return [fsHandler contentsOfFileAtURL:path shared:shared error:err];
}

- (bool) changeCurrentDirectoryURL:(NSURL *)path
{
	if (![path isFileURL])
		return false;

	return (chdir([[path path] fileSystemRepresentation]) == 0);
}

- (NSString *)stringWithFileSystemRepresentation:(const char *)fsRep length:(NSUInteger)len
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

- (NSFileHandle *) fileHandleForWritingAtURL:(NSURL *)path error:(NSError **)errp
{
	id<NSFilesystem> fsHandler = [path handler];
	return [fsHandler fileHandleForWritingAtURL:path error:errp];
}

- (NSFileHandle *) fileHandleForReadingAtURL:(NSURL *)path error:(NSError **)errp
{
	id<NSFilesystem> fsHandler = [path handler];
	return [fsHandler fileHandleForWritingAtURL:path error:errp];
}

- (NSFileHandle *) fileHandleForUpdatingAtURL:(NSURL *)path error:(NSError **)errp
{
	id<NSFilesystem> fsHandler = [path handler];
	return [fsHandler fileHandleForWritingAtURL:path error:errp];
}

- (NSURL *) URLForDirectory:(NSSearchPathDirectory)dir
				   inDomain:(NSSearchPathDomainMask)domain
		  appropriateForURL:(NSURL *)url
		  			 create:(bool)shouldCreate
		  			  error:(NSError **)errp
{
	TODO; // -[NSFileManager URLForDirectory:inDomain:appropriateForURL:create:error:]
	return nil;
}

- (NSArray *) URLsForDirectory:(NSSearchPathDirectory)dir
					 inDomains:(NSSearchPathDomainMask)domains
{
	NSMutableArray *retval = [NSMutableArray new];

	for (int i = 0; (domains & ((1 << i) - 1)) != 0; i++)
	{
		NSURL *val = [self URLForDirectory:dir
								  inDomain:(1 << i)
						 appropriateForURL:nil
									create:false
									 error:NULL];
		if (val != nil)
		{
			[retval addObject:val];
		}
	}
	return retval;
}

-(NSArray *)mountedVolumeURLsIncludingResourceValuesForKeys:(NSArray *)propertyKeys options:(NSVolumeEnumerationOptions)options
{
	NSMutableArray *retval = [NSMutableArray new];
	NSInteger fsCount = getfsstat(NULL, 0, MNT_WAIT);
	/* Cache the array in a Set for O(1) access. */
	NSSet *intPropertyKeys = [NSSet setWithArray:propertyKeys];

	if (fsCount <= 0)
		return nil;

	struct statfs fsBuf[fsCount];
	getfsstat(fsBuf, fsCount * sizeof(struct statfs), MNT_WAIT);

	for (int i = 0; i < fsCount; i++)
	{
		NSURL *url = [NSURL fileURLWithPath:@(fsBuf[i].f_mntonname) isDirectory:true];

		if ([intPropertyKeys member:NSURLVolumeLocalizedFormatDescriptionKey])
		{
			[url _cacheResourceValue:@(fsBuf[i].f_fstypename)
							  forKey:NSURLVolumeLocalizedFormatDescriptionKey];
		}
		if ([intPropertyKeys member:NSURLVolumeTotalCapacityKey])
		{
			[url _cacheResourceValue:@(fsBuf[i].f_blocks * fsBuf[i].f_bsize)
							  forKey:NSURLVolumeTotalCapacityKey];
		}
		if ([intPropertyKeys member:NSURLVolumeAvailableCapacityKey])
		{
			[url _cacheResourceValue:@(fsBuf[i].f_bfree * fsBuf[i].f_bsize)
							  forKey:NSURLVolumeTotalCapacityKey];
		}
		if ([intPropertyKeys member:NSURLVolumeResourceCountKey])
		{
			[url _cacheResourceValue:@(fsBuf[i].f_files)
							  forKey:NSURLVolumeResourceCountKey];
		}
		// TODO: More volume keys
		[retval addObject:url];
	}
	return [retval copy];
}
@end

@implementation NSDictionary(NSFileManager_fileAttributes)
- (NSDate *) fileCreationDate
{
	return [self objectForKey:NSFileCreationDate];
}

- (bool) fileExtensionHidden
{
	return [[self objectForKey:NSFileExtensionHidden] boolValue];
}

- (NSNumber *) fileGroupOwnerAccountID
{
	return [self objectForKey:NSFileGroupOwnerAccountID];
}

-(NSString *)fileGroupOwnerAccountName
{
	return [self objectForKey:NSFileGroupOwnerAccountName];
}

- (bool) fileIsAppendOnly
{
	return [[self objectForKey:NSFileAppendOnly] boolValue];
}

- (bool) fileIsImmutable
{
	return [[self objectForKey:NSFileImmutable] boolValue];
}

-(NSDate *)fileModificationDate
{
	return [self objectForKey:NSFileModificationDate];
}

- (NSNumber *) fileOwnerAccountID
{
	return [self objectForKey:NSFileOwnerAccountID];
}

-(NSString *)fileOwnerAccountName
{
	return [self objectForKey:NSFileOwnerAccountName];
}

-(NSUInteger)filePosixPermissions
{
	return [[self objectForKey:NSFilePosixPermissions] unsignedIntegerValue];
}

-(off_t)fileSize
{
	return [[self objectForKey:NSFileSize] unsignedLongLongValue];
}

- (NSUInteger) fileSystemFileNumber
{
	return [[self objectForKey:NSFileSystemFileNumber] unsignedIntegerValue];
}

- (NSInteger) fileSystemNumber
{
	return [[self objectForKey:NSFileSystemNumber] unsignedIntegerValue];
}

-(NSString *)fileType
{
	return [self objectForKey:NSFileType];
}

@end

@implementation NSDirectoryEnumerator
- (NSDictionary *) directoryAttributes
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (NSDictionary *) fileAttributes
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (NSUInteger) level
{
	[self subclassResponsibility:_cmd];
	return 0;
}

- (void) skipDescendants
{
	[self subclassResponsibility:_cmd];
}

@end

NSString * const NSFileDisplayName = @"NSFileDisplayName";

NSString * const NSFileType = @"NSFileType";
 NSString * const NSFileTypeRegular = @"NSFileTypeRegular";
 NSString * const NSFileTypeDirectory = @"NSFileTypeDirectory";
 NSString * const NSFileTypeSymbolicLink = @"NSFileTypeSymbolicLink";

 NSString * const NSFileTypeCharacterSpecial = @"NSFileTypeCharacterSpecial";
 NSString * const NSFileTypeBlockSpecial = @"NSFileTypeBlockSpecial";

 NSString * const NSFileTypeSocket = @"NSFileTypeSocket";

 NSString * const NSFileTypeUnknown = @"NSFileTypeUnknown";

NSString * const NSFileSize = @"NSFileSize";
NSString * const NSFileModificationDate = @"NSFileModificationDate";
NSString * const NSFileReferenceCount = @"NSFileReferenceCount";
NSString * const NSFileDeviceIdentifier = @"NSFileDeviceIdentifier";
NSString * const NSFileOwnerAccountName = @"NSFileOwnerAccountName";
NSString * const NSFileGroupOwnerAccountName = @"NSFileGroupOwnerAccountName";
NSString * const NSFilePosixPermissions = @"NSFilePosixPermissions";
NSString * const NSFileSystemNumber = @"NSFileSystemNumber";
NSString * const NSFileSystemFileNumber = @"NSFileSystemFileNumber";
NSString * const NSFileExtensionHidden = @"NSFileExtensionHidden";
NSString * const NSFileImmutable = @"NSFileImmutable";
NSString * const NSFileAppendOnly = @"NSFileAppendOnly";
NSString * const NSFileCreationDate = @"NSFileCreationDate";
NSString * const NSFileOwnerAccountID = @"NSFileOwnerAccountID";
NSString * const NSFileGroupOwnerAccountID = @"NSFileGroupOwnerAccountID";
NSString * const NSFileBusy = @"NSFileBusy";
NSString * const NSFileAccess = @"NSFileAccess";

NSString * const NSFileIdentifier = @"NSFileIdentifier";

NSString * const NSFileSystemSize = @"NSFileSystemSize";
NSString * const NSFileSystemFreeSize = @"NSFileSystemFreeSize";
NSString * const NSFileSystemNodes = @"NSFileSystemNodes";
NSString * const NSFileSystemFreeNodes = @"NSFileSystemFreeNodes";
