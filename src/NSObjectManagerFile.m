/*
 * Copyright (c) 2005-2012	Gold Project
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

/* Some parts of this covered under the following copyright (Cocotron
 * NSFileManager.m): */
/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "internal.h"
#include <math.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <fts.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <pwd.h>
#include <grp.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSError.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSValue.h>
#import <Foundation/Plugins/Filesystem.h>
#import <Foundation/NSFileManager.h>

/* The actual scheme handler interface. */
@interface SchemeFileHandler : NSObject <NSFilesystem>
@end

@interface _BSDDirectoryEnumerator : NSEnumerator
{
	DIR *dir;
}
@end

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

- (NSFileHandle *) fileHandleForWritingAtURL:(NSURL *)path
{
	TODO;	// -fileHandleForWritingAtURL:
	return nil;
}

- (NSFileHandle *) fileHandleForReadingAtURL:(NSURL *)path
{
	TODO;	// -fileHandleForReadingAtURL:
	return nil;
}

- (NSDictionary *)attributesOfItemAtURL:(NSURL *)uri error:(NSError **)errOut
{
	NSMutableDictionary *result=[NSMutableDictionary dictionary];
	struct stat statBuf;
	struct passwd *pwd;
	struct group *grp;
	NSString *path = [uri path];

	if (lstat([path fileSystemRepresentation], &statBuf) != 0) 
		return nil;

	[result setObject:[NSNumber numberWithUnsignedLongLong:statBuf.st_size]
			   forKey:NSFileSize];
	[result setObject:[NSDate dateWithTimeIntervalSince1970:statBuf.st_mtime]
			   forKey:NSFileModificationDate];

	// User/group names don't always exist for the IDs in the filesystem.
	// If we don't check for NULLs, we'll segfault.
	pwd = getpwuid(statBuf.st_uid);
	if (pwd != NULL)
		[result setObject:[NSString stringWithCString:pwd->pw_name encoding:[NSString defaultCStringEncoding]]
				   forKey:NSFileOwnerAccountName];

	grp = getgrgid(statBuf.st_gid);
	if (grp != NULL)
		[result setObject:[NSString stringWithCString:grp->gr_name encoding:[NSString defaultCStringEncoding]]
				   forKey:NSFileGroupOwnerAccountName];

	[result setObject:[NSNumber numberWithUnsignedLong:statBuf.st_nlink]
			   forKey:NSFileReferenceCount];
	[result setObject:[NSNumber numberWithUnsignedLong:statBuf.st_ino]
			   forKey:NSFileIdentifier];
	[result setObject:[NSNumber numberWithUnsignedLong:statBuf.st_dev]
			   forKey:NSFileDeviceIdentifier];
	[result setObject:[NSNumber numberWithUnsignedLong:statBuf.st_mode]
			   forKey:NSFilePosixPermissions];

	if (S_ISREG(statBuf.st_mode))
		[result setObject:NSRegularFileType forKey:NSFileType];
	if (S_ISDIR(statBuf.st_mode))
		[result setObject:NSDirectoryFileType forKey:NSFileType];
	else if (S_ISCHR(statBuf.st_mode))
		[result setObject:NSCharacterSpecialFileType forKey:NSFileType];
	else if (S_ISBLK(statBuf.st_mode))
		[result setObject:NSBlockSpecialFileType forKey:NSFileType];
	else if (S_ISFIFO(statBuf.st_mode))
		[result setObject:NSFIFOFileType forKey:NSFileType];
	else if (S_ISLNK(statBuf.st_mode))
		[result setObject:NSSymbolicLinkFileType forKey:NSFileType];
	else if (S_ISSOCK(statBuf.st_mode))
		[result setObject:NSSocketFileType forKey:NSFileType];

	return result;
}

- (bool)setAttributes:(NSDictionary *)dict ofItemAtURL:(NSURL *)path error:(NSError **)errOut
{
	errOut = errOut ? errOut : &(NSError *){nil};
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
				*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:strerror(errno) encoding:NSUTF8StringEncoding],NSLocalizedFailureReasonErrorKey,@"Unable to set the file modification time.",NSLocalizedDescriptionKey,nil]];
			}
		}
		else if ([key isEqualToString:NSFileAccess])
		{
		}
	}
	return true;
}

- (bool)deleteItemAtURL:(NSURL *)uri error:(NSError **)errOut
{
	FTS *fts;
	FTSENT *ftsent;
	int fts_flags = FTS_PHYSICAL;
	char *path[2] = {(char *)[[uri path] fileSystemRepresentation], 0};

	if ((fts = fts_open(path, fts_flags, NULL)) == NULL)
		return false;
	
	struct stat sb;
	
	if (stat(path[0], &sb) < 0)
	{
		return false;
	}

	/* If it's a directory, remove its contents. */
	if (S_ISDIR(sb.st_mode))
	{
		while ((ftsent = fts_read(fts)) != NULL)
		{
			switch (ftsent->fts_info)
			{
				case FTS_D:
				   // TODO: delegate for this.
					continue;
				case FTS_DNR:
			   case FTS_NSOK:
				case FTS_ERR:
				 case FTS_NS:
					 // TODO: delegate for this.
					continue;
				 case FTS_DP:
					rmdir(ftsent->fts_name);
					continue;
				 default:
					unlink(ftsent->fts_name);
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

	errOut = errOut ? errOut : &(NSError *){nil};

	if (path_len < 0)
	{
		*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:strerror(errno) encoding:NSUTF8StringEncoding],NSLocalizedFailureReasonErrorKey,@"Unable to read the link target.",NSLocalizedDescriptionKey,nil]];
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

	errOut = errOut ? errOut : &(NSError *){nil};

	if (dirp == NULL)
	{
		*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:strerror(errno) encoding:NSUTF8StringEncoding],NSLocalizedFailureReasonErrorKey,@"Unable to open directory.",NSLocalizedDescriptionKey,nil]];
		return nil;
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

	if (errno != 0)
		*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:strerror(errno) encoding:NSUTF8StringEncoding],NSLocalizedFailureReasonErrorKey,@"NSError reading directory.",NSLocalizedDescriptionKey,nil]];

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
	int fd;
	errOut = errOut ? errOut : &(NSError *){nil};

	if (stat(path, &sb) < 0)
	{
		*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:strerror(errno) encoding:NSUTF8StringEncoding],NSLocalizedFailureReasonErrorKey,@"Unable to stat file.",NSLocalizedDescriptionKey,nil]];
		return nil;
	}

	if ((fd = open(path, O_RDONLY)) < 0)
	{
		*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:strerror(errno) encoding:NSUTF8StringEncoding],NSLocalizedFailureReasonErrorKey,@"NSError opening file.",NSLocalizedDescriptionKey,nil]];
		return nil;
	}

	/* If it won't fit in the buffer anyway, fail */
	if (sb.st_size > SIZE_MAX)
	{
		TODO; // Add support for mapped data files.
		*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:strerror(errno) encoding:NSUTF8StringEncoding],NSLocalizedFailureReasonErrorKey,@"File size too big for buffer.",NSLocalizedDescriptionKey,nil]];
		return nil;
	}

	buffer = malloc(sb.st_size);

	if (buffer == NULL)
	{
		*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:strerror(errno) encoding:NSUTF8StringEncoding],NSLocalizedFailureReasonErrorKey,@"File size too big for buffer.",NSLocalizedDescriptionKey,nil]];
		return nil;
	}

	if (read(fd, buffer, sb.st_size) < 0)
	{
		*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:strerror(errno) encoding:NSUTF8StringEncoding],NSLocalizedFailureReasonErrorKey,@"NSError reading file.",NSLocalizedDescriptionKey,nil]];
		free(buffer);
		return nil;
	}
	NSData *d = [NSData dataWithBytesNoCopy:buffer length:sb.st_size freeWhenDone:true];
	return d;
}

- (bool)createFileAtURL:(NSURL *)uri contents:(NSData *)data attributes:(NSDictionary *)attributes error:(NSError **)errOut
{
	const char *path = [[uri path] fileSystemRepresentation];
	int fd;
	mode_t mode = [[attributes objectForKey:NSFilePosixPermissions] longValue];

	errOut = errOut ? errOut : &(NSError *){nil};

	if ((fd = open(path, O_WRONLY | O_TRUNC | O_CREAT, mode ? mode : 0640)) < 0)
	{
		*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:strerror(errno) encoding:NSUTF8StringEncoding],NSLocalizedFailureReasonErrorKey,@"Unable to create the target file.",NSLocalizedDescriptionKey,nil]];
		return false;
	}
	if (![self setAttributes:attributes ofItemAtURL:uri error:errOut])
		return false;

	ssize_t len = [data length];
	ssize_t written = 0;

	if ((written = write(fd, [data bytes], len)) < 0)
	{
		*errOut = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:strerror(errno) encoding:NSUTF8StringEncoding],NSLocalizedFailureReasonErrorKey,@"Unable to completely write the target file.  Output may be truncated.",NSLocalizedDescriptionKey,nil]];
		return false;
	}
	return (written == len);
}

- (bool) linkItemAtURL:(NSURL *)from toURL:(NSURL *)to error:(NSError **)errp
{
	errp = errp ? errp : &(NSError *){nil};

	if (link([[from path] fileSystemRepresentation], [[to path] fileSystemRepresentation]) < 0)
	{
		NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
		*errp = error;
		return false;
	}
	return true;
}

@end

@implementation _BSDDirectoryEnumerator

- (id) initWithURL:(NSURL *)uri
{
	NSString *internalName;
	const char *pathName;

	internalName = [uri path];
	pathName = [internalName UTF8String];
	dir = opendir(pathName);
	if (dir == NULL)
	{
		self = nil;
	}
	return self;
}

- (void) dealloc
{
	if (dir != NULL)
	{
		closedir(dir);
	}
}

- (id) nextObject
{
	struct dirent *dent = readdir(dir);

	if (dent == NULL)
	{
		return nil;
	}
	return [NSString stringWithCString:dent->d_name encoding:[NSString defaultCStringEncoding]];
}
@end
