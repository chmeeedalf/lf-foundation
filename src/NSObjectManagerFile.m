/*
 * Copyright (c) 2005-2012	Justin Hibbits
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

/* Some parts of this covered under the following copyright (Cocotron
 * NSFileManager.m): */
/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include <sys/param.h>
#include <sys/mman.h>
#include <sys/mount.h>
#include <sys/stat.h>
#import "internal.h"
#include <math.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <fts.h>
#include <ftw.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pwd.h>
#include <grp.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSError.h>
#import <Foundation/NSFileHandle.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSValue.h>
#import <Foundation/Plugins/Filesystem.h>
#import <Foundation/NSFileManager.h>

/* The actual scheme handler interface. */
@interface SchemeFileHandler : NSObject <NSFilesystem>
@end

@interface _BSDDirectoryEnumerator : NSDirectoryEnumerator
- (id) initWithURL:(NSURL *)uri
		 includingPropertiesForKeys:(NSArray *)keys
							options:(NSDirectoryEnumerationOptions)opts
					   errorHandler:(bool (^)(NSURL *, NSError *))handler;
@end

static NSError *make_error(NSString *descr, NSDictionary *inDict)
{
	char buf[NL_TEXTMAX];
	strerror_r(errno, buf, sizeof(buf));
	return [NSError errorWithDomain:NSPOSIXErrorDomain
							   code:errno
						   userInfo:@{
  NSLocalizedFailureReasonErrorKey : @(buf),
		 NSLocalizedDescriptionKey : @"Unable to set the file modification time"}];
}

static NSDictionary *_NSDictionaryFromStatBuffer(struct stat *sb, NSArray *keys)
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];

	if ((keys == nil) || [keys containsObject:NSFileSize])
	{
		[result setObject:@(sb->st_size)
				   forKey:NSFileSize];
	}
	if ((keys == nil) || [keys containsObject:NSFileModificationDate])
	{
		[result setObject:[NSDate dateWithTimeIntervalSince1970:sb->st_mtime]
				   forKey:NSFileModificationDate];
	}

	// User/group names don't always exist for the IDs in the filesystem.
	// If we don't check for NULLs, we'll segfault.
	if ((keys == nil) || [keys containsObject:NSFileOwnerAccountName])
	{
		struct passwd *pwd;
		pwd = getpwuid(sb->st_uid);
		if (pwd != NULL)
			[result setObject:@(pwd->pw_name)
					   forKey:NSFileOwnerAccountName];
	}

	if ((keys == nil) || [keys containsObject:NSFileGroupOwnerAccountName])
	{
		struct group *grp;
		grp = getgrgid(sb->st_gid);
		if (grp != NULL)
			[result setObject:@(grp->gr_name)
					   forKey:NSFileGroupOwnerAccountName];
	}

	if ((keys == nil) || [keys containsObject:NSFileReferenceCount])
	{
		[result setObject:@(sb->st_nlink)
				   forKey:NSFileReferenceCount];
	}
	if ((keys == nil) || [keys containsObject:NSFileIdentifier])
	{
		[result setObject:@(sb->st_ino)
				   forKey:NSFileIdentifier];
	}
	if ((keys == nil) || [keys containsObject:NSFileDeviceIdentifier])
	{
		[result setObject:@(sb->st_dev)
				   forKey:NSFileDeviceIdentifier];
	}
	if ((keys == nil) || [keys containsObject:NSFilePosixPermissions])
	{
		[result setObject:@(sb->st_mode)
				   forKey:NSFilePosixPermissions];
	}

	if ((keys == nil) || [keys containsObject:NSFileType])
	{
		if (S_ISREG(sb->st_mode))
			[result setObject:NSFileTypeRegular forKey:NSFileType];
		if (S_ISDIR(sb->st_mode))
			[result setObject:NSFileTypeDirectory forKey:NSFileType];
		else if (S_ISCHR(sb->st_mode))
			[result setObject:NSFileTypeCharacterSpecial forKey:NSFileType];
		else if (S_ISBLK(sb->st_mode))
			[result setObject:NSFileTypeBlockSpecial forKey:NSFileType];
		else if (S_ISFIFO(sb->st_mode))
			[result setObject:NSFileTypeFIFO forKey:NSFileType];
		else if (S_ISLNK(sb->st_mode))
			[result setObject:NSFileTypeSymbolicLink forKey:NSFileType];
		else if (S_ISSOCK(sb->st_mode))
			[result setObject:NSFileTypeSocket forKey:NSFileType];
	}

	return result;
}

@implementation SchemeFileHandler
static SchemeFileHandler *sharedHandler = nil;

+ (id)sharedHandler
{
	if (sharedHandler == nil)
	{
		sharedHandler = [self new];
	}
	return sharedHandler;
}

- (NSFileHandle *) fileHandleForWritingAtURL:(NSURL *)path error:(NSError **)errp
{
	int fd = open([[path path] fileSystemRepresentation], O_RDWR);

	if (fd < 0)
	{
		if (errp != NULL)
			*errp = make_error(@"Unable to open file.", @{ NSFileURLErrorKey : path });
		return nil;
	}

	return [[NSFileHandle alloc] initWithFileDescriptor:fd];
}

- (NSFileHandle *) fileHandleForReadingAtURL:(NSURL *)path error:(NSError **)errp
{
	int fd = open([[path path] fileSystemRepresentation], O_RDONLY);

	if (fd < 0)
	{
		if (errp != NULL)
			*errp = make_error(@"Unable to open file.", @{ NSFileURLErrorKey : path });
		return nil;
	}

	return [[NSFileHandle alloc] initWithFileDescriptor:fd];
}

- (NSDictionary *)attributesOfFileSystemForURL:(NSURL *)path error:(NSError **)errOut
{
	struct statfs sfsb;

	if (statfs([[path path] fileSystemRepresentation], &sfsb) < 0)
	{
		if (errOut != NULL)
		{
			*errOut = make_error(@"Unable to open file.", @{ NSFileURLErrorKey : path });
		}
		return nil;
	}

	return @{
		NSFileSystemSize : @(sfsb.f_blocks * sfsb.f_bsize),
		NSFileSystemFreeSize : @(sfsb.f_bfree * sfsb.f_bsize),
		   NSFileSystemNodes : @(sfsb.f_files),
	   NSFileSystemFreeNodes : @(sfsb.f_ffree)
	};
}

- (NSDictionary *)attributesOfItemAtURL:(NSURL *)uri error:(NSError **)errOut
{
	struct stat statBuf;
	NSString *path = [uri path];

	if (lstat([path fileSystemRepresentation], &statBuf) != 0) 
		return nil;

	return _NSDictionaryFromStatBuffer(&statBuf, nil);
}

- (bool)setAttributes:(NSDictionary *)dict ofItemAtURL:(NSURL *)path error:(NSError **)errOut
{
	for (NSString *key in dict)
	{
		if ([key isEqualToString:NSFileModificationDate])
		{
			NSDate *d = [dict objectForKey:key];
			NSTimeInterval t = [d timeIntervalSinceReferenceDate];

			struct timeval spec[2];
			spec[0].tv_sec = trunc(t);
			spec[0].tv_usec = trunc(fmod(t, 1) * 1000000);
			spec[0].tv_sec = trunc(t);
			spec[0].tv_usec = trunc(fmod(t, 1) * 1000000);
			if (lutimes([[path path] cStringUsingEncoding:NSUTF8StringEncoding], spec) < 0)
			{
				if (errOut)
				{
					*errOut = make_error(@"Unable to set the file modification time", nil);
				}
			}
		}
		else if ([key isEqualToString:NSFileAccess])
		{
		}
	}
	return true;
}

static int delete_item(const char *path, const struct stat *sb, int flag, struct FTW *ftwb)
{
	return remove(path);
}

- (bool)deleteItemAtURL:(NSURL *)uri error:(NSError **)errOut
{
	const char *path = [[uri path] fileSystemRepresentation];

	struct stat sb;
	
	if (stat(path[0], &sb) < 0)
	{
		return false;
	}

	/* If it's a directory, remove its contents. */
	if (S_ISDIR(sb.st_mode))
	{
		if (nftw(path, delete_item, 1, FTW_PHYS | FTW_DEPTH) != 0)
		{
			if (errOut != NULL)
			{
				*errOut = make_error(@"Unable to delete file", nil);
			}
		}
	}

	/* Now remove the file */
	if (remove(path[0]) == 0)
		return true;
	return false;
}

- (NSString *)destinationOfSymbolicLinkAtURL:(NSURL *)path error:(NSError **)errOut
{
	const char *slpath = [[path path] fileSystemRepresentation];
	char sldest[PATH_MAX + 1];
	ssize_t path_len = readlink(slpath, sldest, sizeof(sldest) - 1);

	if (path_len < 0)
	{
		if (errOut)
		{
			*errOut = make_error(@"Unable to read the link target", nil);
		}
		return nil;
	}
	sldest[path_len] = 0;
	return [NSString stringWithCString:sldest encoding:NSUTF8StringEncoding];
}

- (bool)createSymbolicLinkAtURL:(NSURL *)path withDestinationURL:(NSURL *)destPath error:(NSError **)errOut
{
	NSString *dest;

	if ([[destPath scheme] isEqualToString:@"file"])
		dest = [destPath path];
	else
		dest = [destPath description];

	if (symlink([dest fileSystemRepresentation], [[path path] fileSystemRepresentation]))
		return false;

	return true;
}

- (NSArray *)contentsOfDirectoryAtURL:(NSURL *)path error:(NSError **)errOut
{
	NSMutableArray *result=[NSMutableArray array];
	DIR *dirp = opendir([[path path] fileSystemRepresentation]);
	struct dirent *dire;

	if (dirp == NULL)
	{
		if (errOut)
		{
			char buf[NL_TEXTMAX];
			strerror_r(errno, buf, sizeof(buf));
			*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain
										  code:errno
									  userInfo:@{
			 NSLocalizedFailureReasonErrorKey : @(buf),
						NSLocalizedDescriptionKey : @"Unable to open directory"}];
		}
	}

	while ((dire = readdir(dirp)))
	{
		if(strcmp(".",dire->d_name)==0)
			continue;
		if(strcmp("..",dire->d_name)==0)
			continue;
		[result addObject:[NSString stringWithCString:dire->d_name encoding:[NSString defaultCStringEncoding]]];
	}

	closedir(dirp);

	if (errno != 0 && errOut != NULL)
	{
		char buf[NL_TEXTMAX];
		strerror_r(errno, buf, sizeof(buf));
		*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain
									  code:errno
								  userInfo:@{
		 NSLocalizedFailureReasonErrorKey : @(buf),
					NSLocalizedDescriptionKey : @"Error reading directory."}];
	}
	return result;
}

-(bool)createDirectoryAtURL:(NSURL *)path withIntermediateDirectories:(bool)intermediates attributes:(NSDictionary *)attributes error:(NSError **)error
{
	// you can set all these, but we don't respect 'em all yet
	/*
	   NSDate *date = [attributes objectForKey:FileModificationDate];
	   NSString *owner = [attributes objectForKey:FileOwnerAccountName];
	   NSString *group = [attributes objectForKey:FileGroupOwnerAccountName];
	   */
	int mode = [[attributes objectForKey:NSFilePosixPermissions] intValue];

	if (mode == 0)
		mode = 0750;

	return (mkdir([[path path] fileSystemRepresentation], mode) == 0);
}

- (NSData *)contentsOfFileAtURL:(NSURL *)uri shared:(bool)shared error:(NSError **)errOut
{
	void *buffer;
	struct stat sb;
	const char *path = [[uri path] fileSystemRepresentation];
	NSString *errMess;
	int fd;

	if (stat(path, &sb) < 0)
	{
		errMess = @"Unable to stat file";
		goto err_out;
	}

	if ((fd = open(path, O_RDONLY)) < 0)
	{
		errMess = @"Error opening file.";
		goto err_out;
	}

	/* If it won't fit in the buffer anyway, fail */
	if (sb.st_size > SIZE_MAX)
	{
		TODO; // Add support for mapped data files.
		errMess = @"File size too big for buffer.";
		goto err_out;
	}

	buffer = malloc(sb.st_size);

	if (buffer == NULL)
	{
		errMess = @"File size too big for buffer.";
		goto err_out;
	}

	if (read(fd, buffer, sb.st_size) < 0)
	{
		free(buffer);
		errMess = @"Error reading file.";
		goto err_out;
	}
	return [NSData dataWithBytesNoCopy:buffer length:sb.st_size freeWhenDone:true];

err_out:

	if (errOut != NULL)
	{
		char buf[NL_TEXTMAX];
		strerror_r(errno, buf, sizeof(buf));
		*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain
									  code:errno
								  userInfo:@{
		 NSLocalizedFailureReasonErrorKey : @(buf),
				NSLocalizedDescriptionKey : errMess}];
	}
	return nil;
}

- (bool)createFileAtURL:(NSURL *)uri contents:(NSData *)data attributes:(NSDictionary *)attributes error:(NSError **)errOut
{
	const char *path = [[uri path] fileSystemRepresentation];
	int fd;
	mode_t mode = [[attributes objectForKey:NSFilePosixPermissions] longValue];
	NSString *errMess;

	if ((fd = open(path, O_WRONLY | O_TRUNC | O_CREAT, mode ? mode : 0640)) < 0)
	{
		errMess = @"Unable to create the target file.";
		return false;
	}
	if (![self setAttributes:attributes ofItemAtURL:uri error:errOut])
		return false;

	ssize_t len = [data length];
	ssize_t written = 0;

	if ((written = write(fd, [data bytes], len)) < 0)
	{
		errMess = @"Unable to completely write the target file.";
		goto err_out;
		return false;
	}
	return (written == len);
err_out:
	if (errOut != NULL)
	{
		char buf[NL_TEXTMAX];
		strerror_r(errno, buf, sizeof(buf));
		*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain
									  code:errno
								  userInfo:@{
		 NSLocalizedFailureReasonErrorKey : @(buf),
				NSLocalizedDescriptionKey : errMess}];
	}
	return false;
}

- (bool) linkItemAtURL:(NSURL *)from toURL:(NSURL *)to error:(NSError **)errp
{
	if (link([[from path] fileSystemRepresentation], [[to path] fileSystemRepresentation]) < 0)
	{
		NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
		if (errp != NULL)
			*errp = error;
		return false;
	}
	return true;
}

-(NSDirectoryEnumerator *)enumeratorAtURL:(NSURL *)url
			   includingPropertiesForKeys:(NSArray *)keys
			   					  options:(NSDirectoryEnumerationOptions)mask
			   				 errorHandler:(bool (^)(NSURL *, NSError *))handler
{
	return [[_BSDDirectoryEnumerator alloc] initWithURL:url
							 includingPropertiesForKeys:keys
												options:mask
										   errorHandler:handler];
}

@end

@implementation _BSDDirectoryEnumerator
{
	NSArray *keys;
	FTS *fts;
	FTSENT *ftsent;
	NSString *path;
	bool (^errorHandler)(NSURL *, NSError *);
	bool skipSubdirs;
	bool skipHidden;
}

- (id) initWithURL:(NSURL *)uri
			   includingPropertiesForKeys:(NSArray *)keys
								  options:(NSDirectoryEnumerationOptions)opts
							 errorHandler:(bool (^)(NSURL *, NSError *))handler
{
	NSString *internalName;
	const char *pathName;
	char *args[2] = {0, 0};

	internalName = [uri path];
	path = internalName;
	pathName = [internalName UTF8String];
	args[0] = strdup(pathName);
	fts = fts_open(args, FTS_PHYSICAL | FTS_NOCHDIR, NULL);

	if (fts == NULL)
		return nil;
	return self;
}

- (void) dealloc
{
	char *p = fts->fts_path;
	fts_close(fts);
	free(p);
}

- (id) nextObject
{
	ftsent = fts_read(fts);

	while ((skipHidden && ftsent->fts_name[0] == '.') ||
			(ftsent->fts_info == FTS_DOT) ||
			(ftsent->fts_info == FTS_DP))
	{
		ftsent = fts_read(fts);
	}

	if (ftsent->fts_info == FTS_ERR && errorHandler != NULL)
	{
		errno = ftsent->fts_errno;
		NSError *err = make_error(@"Failure accessing file", nil);
		if (errorHandler([NSURL fileURLWithPath:@(ftsent->fts_path)], err))
			return [self nextObject];
		else
			return nil;
	}
	else if (ftsent->fts_info == FTS_D)
	{
		if (skipSubdirs)
		{
			fts_set(fts, ftsent, FTS_SKIP);
		}
	}
	return @(ftsent->fts_path);
}

- (void) skipDescendants
{
	skipSubdirs = true;
}

- (NSUInteger) level
{
	return ftsent->fts_level;
}

- (NSDictionary *) fileAttributes
{
	if (ftsent->fts_info == FTS_D)
		return nil;

	return _NSDictionaryFromStatBuffer(ftsent->fts_statp, keys);
}

- (NSDictionary *) directoryAttributes
{
	struct stat sb;

	stat([path fileSystemRepresentation], &sb);
	return _NSDictionaryFromStatBuffer(&sb, keys);
}
@end
