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

/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>

@interface NSString(NSString_pathUtilities)

+(NSString *)pathWithComponents:(NSArray *)components;
-(NSArray *)pathComponents;

-(NSString *)lastPathComponent;

-(NSString *)pathExtension;

-(NSString *)stringByAppendingPathComponent:(NSString *)string;
-(NSString *)stringByAppendingPathExtension:(NSString *)string;
-(NSArray *)stringsByAppendingPaths:(NSArray *)paths;

-(NSString *)stringByDeletingLastPathComponent;
-(NSString *)stringByDeletingPathExtension;

-(NSString *)stringByExpandingTildeInPath;
-(NSString *)stringByAbbreviatingWithTildeInPath;

-(NSString *)stringByStandardizingPath;
-(NSString *)stringByResolvingSymlinksInPath;

-(bool)isAbsolutePath;

-(const char *)fileSystemRepresentation;
-(bool)getFileSystemRepresentation:(char *)bytes maxLength:(NSUInteger)maxLength;

-(NSUInteger)completePathIntoString:(NSString **)string caseSensitive:(bool)caseSensitive matchesIntoArray:(NSArray **)array filterTypes:(NSArray *)types;

@end

@interface NSArray(NSPathUtilities)
- (NSArray *) pathsMatchingExtensions:(NSArray *)types;
@end

enum {
	NSApplicationDirectory = 1,
	NSDemoApplicationDirectory,
	NSDeveloperApplicationDirectory,
	NSAdminApplicationDirectory,
	NSLibraryDirectory,
	NSDeveloperDirectory,
	NSUserDirectory,
	NSDocumentationDirectory,
	NSDocumentDirectory,
	NSAutosavedInformationDirectory	= 11,
	NSDesktopDirectory	= 12,
	NSCachesDirectory	= 13,
	NSApplicationSupportDirectory	= 14,
	NSDownloadsDirectory	= 15,
	NSMoviesDirectory	= 17,
	NSMusicDirectory	= 18,
	NSPicturesDirectory	= 19,
	NSPrinterDescriptionDirectory	= 20,
	NSSharedPublicDirectory	= 21,
	NSItemReplacementDirectory	= 99,
	NSAllApplicationsDirectory	= 100,
	NSAllLibrariesDirectory	= 101,
	NSTrashDirectory = 102
};

typedef NSUInteger NSSearchPathDirectory;

enum {
   NSUserDomainMask   = 0x0001,
   NSLocalDomainMask  = 0x0002,
   NSNetworkDomainMask= 0x0004,
   NSSystemDomainMask = 0x0008,
   NSAllDomainsMask   = 0xffff,
};

typedef NSUInteger NSSearchPathDomainMask;

SYSTEM_EXPORT NSArray  *NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory d,NSSearchPathDomainMask mask,bool expand);

SYSTEM_EXPORT NSString *NSHomeDirectory(void);
SYSTEM_EXPORT NSString *NSHomeDirectoryForUser(NSString *user);

SYSTEM_EXPORT NSString *NSTemporaryDirectory(void);

SYSTEM_EXPORT NSString *NSUserName(void);
SYSTEM_EXPORT NSString *NSFullUserName(void);
