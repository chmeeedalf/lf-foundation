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

#import <Foundation/NSObject.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSString.h>

@class NSData,NSDate,NSDirectoryEnumerator,NSError,NSFileHandle,NSNumber,NSURL;

SYSTEM_EXPORT NSString * const NSFileDisplayName;
SYSTEM_EXPORT NSString * const NSFileType;
  SYSTEM_EXPORT NSString * const NSFileTypeRegular;
  SYSTEM_EXPORT NSString * const NSFileTypeDirectory;
  SYSTEM_EXPORT NSString * const NSFileTypeSymbolicLink;

  SYSTEM_EXPORT NSString * const NSFileTypeCharacterSpecial;
  SYSTEM_EXPORT NSString * const NSFileTypeBlockSpecial;

  SYSTEM_EXPORT NSString * const NSFileTypeSocket;
  SYSTEM_EXPORT NSString * const NSFileTypeFIFO;

  SYSTEM_EXPORT NSString * const NSFileTypeUnknown;

SYSTEM_EXPORT NSString * const NSFileSize;
SYSTEM_EXPORT NSString * const NSFileModificationDate;
SYSTEM_EXPORT NSString * const NSFileReferenceCount;
SYSTEM_EXPORT NSString * const NSFileDeviceIdentifier;
SYSTEM_EXPORT NSString * const NSFileOwnerAccountName;
SYSTEM_EXPORT NSString * const NSFileGroupOwnerAccountName;
SYSTEM_EXPORT NSString * const NSFilePosixPermissions;
SYSTEM_EXPORT NSString * const NSFileSystemNumber;
SYSTEM_EXPORT NSString * const NSFileSystemFileNumber;
SYSTEM_EXPORT NSString * const NSFileExtensionHidden;
SYSTEM_EXPORT NSString * const NSFileImmutable;
SYSTEM_EXPORT NSString * const NSFileAppendOnly;
SYSTEM_EXPORT NSString * const NSFileCreationDate;
SYSTEM_EXPORT NSString * const NSFileOwnerAccountID;
SYSTEM_EXPORT NSString * const NSFileGroupOwnerAccountID;
SYSTEM_EXPORT NSString * const NSFileBusy;
SYSTEM_EXPORT NSString * const NSFileAccess;

SYSTEM_EXPORT NSString * const NSFileIdentifier;

SYSTEM_EXPORT NSString * const NSFileSystemSize;
SYSTEM_EXPORT NSString * const NSFileSystemFreeSize;
SYSTEM_EXPORT NSString * const NSFileSystemNodes;
SYSTEM_EXPORT NSString * const NSFileSystemFreeNodes;

enum
{
	NSVolumeEnumerationSkipHiddenVolumes	= 1UL << 1,
	NSVolumeEnumerationProduceFileReferenceURLs	= 1UL << 2,
};
typedef NSUInteger NSVolumeEnumerationOptions;

enum
{
	NSDirectoryEnumerationSkipsSubdirectoryDescendants = 1UL << 0,
	NSDirectoryEnumerationSkipsPackageDescendants = 1UL << 1,
	NSDirectoryEnumerationSkipsHiddenFiles = 1UL << 2,
};
typedef NSUInteger NSDirectoryEnumerationOptions;

enum
{
	NSFileManagerItemReplacementUsingNewMetadataOnly = 1UL << 0,
	NSFileManagerItemReplacementWithoutDeletingBackupItem = 1UL << 1,
};
typedef NSUInteger NSFileManagerItemReplacementOptions;

@protocol NSFileManagerDelegate;

@interface NSFileManager : NSObject
{
	id delegate;
}
@property(weak) id<NSFileManagerDelegate> delegate;

- (id) init;
+(NSFileManager *)defaultManager;

- (NSURL *) URLForDirectory:(NSSearchPathDirectory)dir inDomain:(NSSearchPathDomainMask)domain appropriateForURL:(NSURL *)url create:(bool)shouldCreate error:(NSError **)errp;
- (NSArray *) URLsForDirectory:(NSSearchPathDirectory)dir inDomains:(NSSearchPathDomainMask)domains;

-(NSArray *)contentsOfDirectoryAtURL:(NSURL *)path includingPropertiesForKeys:(NSArray *)keys options:(NSDirectoryEnumerationOptions)mask error:(NSError **)error;
-(NSArray *)contentsOfDirectoryAtURL:(NSURL *)path error:(NSError **)error;
-(NSDirectoryEnumerator *)enumeratorAtURL:(NSURL *)url includingPropertiesForKeys:(NSArray *)keys options:(NSDirectoryEnumerationOptions)mask errorHandler:(bool (^)(NSURL *, NSError *))handler;
-(NSDirectoryEnumerator *)enumeratorAtURL:(NSURL *)path;
-(NSArray *)mountedVolumeURLsIncludingResourceValuesForKeys:(NSArray *)propertyKeys options:(NSVolumeEnumerationOptions)options;
-(NSArray *)subpathsOfDirectoryAtURL:(NSURL *)path error:(NSError **)error;

-(bool)createDirectoryAtURL:(NSURL *)path withIntermediateDirectories:(bool)intermediates attributes:(NSDictionary *)attributes error:(NSError **)error;
-(bool)createFileAtURL:(NSURL *)path contents:(NSData *)data attributes:(NSDictionary *)attributes;
-(bool)removeItemAtURL:(NSURL *)path error:(NSError **)error;
-(bool)replaceItemAtURL:(NSURL *)original withItemAtURL:(NSURL *)newURL backupItemName:(NSString *)backupName options:(NSFileManagerItemReplacementOptions)options resultingItemURL:(NSURL **)result error:(NSError **)errp;

-(bool)copyItemAtURL:(NSURL *)fromPath toURL:(NSURL *)toPath error:(NSError **)error;
-(bool)moveItemAtURL:(NSURL *)fromPath toURL:(NSURL *)toPath error:(NSError **)error;
- (bool) trashItemAtURL:(NSURL *)url resultingItemURL:(NSURL **)outURL error:(NSError **)error;

-(bool)createSymbolicLinkAtURL:(NSURL *)path withDestinationURL:(NSURL *)toPath error:(NSError **)error;
-(bool)linkItemAtURL:(NSURL *)fromPath toURL:(NSURL *)toPath error:(NSError **)error;
-(NSString *)destinationOfSymbolicLinkAtURL:(NSURL *)path error:(NSError **)error;

-(bool)fileExistsAtURL:(NSURL *)path;
-(bool)fileExistsAtURL:(NSURL *)path isDirectory:(bool *)isDirectory;
-(bool)isReadableFileAtURL:(NSURL *)path;
-(bool)isWritableFileAtURL:(NSURL *)path;
-(bool)isExecutableFileAtURL:(NSURL *)path;
-(bool)isDeletableFileAtURL:(NSURL *)path;

- (NSArray *) componentsToDisplayForURL:(NSURL *)url;
- (NSString *) displayNameAtURL:(NSURL *)url;
-(NSDictionary *)attributesOfItemAtURL:(NSURL *)path error:(NSError **)error;
-(NSDictionary *)attributesOfFileSystemForURL:(NSURL *)path error:(NSError **)errorp;
-(bool)setAttributes:(NSDictionary *)attributes ofItemAtURL:(NSURL *)path error:(NSError **)error;

-(NSData *)contentsOfFileAtURL:(NSURL *)path shared:(bool)shared error:(NSError **)error;
-(bool)contentsEqualAtURL:(NSURL *)path1 andURL:(NSURL *)path2;

-(const char *)fileSystemRepresentationWithURL:(NSURL *)path;
-(NSString *)stringWithFileSystemRepresentation:(const char *)string length:(NSUInteger)length;

-(bool)changeCurrentDirectoryURL:(NSURL *)path;
-(NSString *)currentDirectoryPath;

/* Gold extensions */
- (NSFileHandle *) fileHandleForWritingAtURL:(NSURL *)path error:(NSError **)errp;
- (NSFileHandle *) fileHandleForReadingAtURL:(NSURL *)path error:(NSError **)errp;
- (NSFileHandle *) fileHandleForUpdatingAtURL:(NSURL *)path error:(NSError **)errp;
@end

@protocol NSFileManagerDelegate<NSObject>
@optional
-(bool)fileManager:(NSFileManager *)fileManager shouldCopyItemAtURL:(NSURL *)path toURL:(NSURL *)toPath;
-(bool)fileManager:(NSFileManager *)fileManager shouldLinkItemAtURL:(NSURL *)path toURL:(NSURL *)toPath;
-(bool)fileManager:(NSFileManager *)fileManager shouldMoveItemAtURL:(NSURL *)path toURL:(NSURL *)toPath;
-(bool)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtURL:(NSURL *)path;

-(bool)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtURL:(NSURL *)path toURL:(NSURL *)toPath;
-(bool)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error linkingItemAtURL:(NSURL *)path toURL:(NSURL *)toPath;
-(bool)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error movingItemAtURL:(NSURL *)path toURL:(NSURL *)toPath;
-(bool)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error removingItemAtURL:(NSURL *)path;

@end

@interface NSDictionary(NSFileManager_fileAttributes)
- (NSDate *) fileCreationDate;
- (bool) fileExtensionHidden;
- (NSNumber *) fileGroupOwnerAccountID;
-(NSString *)fileGroupOwnerAccountName;
- (bool) fileIsAppendOnly;
- (bool) fileIsImmutable;
-(NSDate *)fileModificationDate;
- (NSNumber *) fileOwnerAccountID;
-(NSString *)fileOwnerAccountName;
-(NSUInteger)filePosixPermissions;
-(off_t)fileSize;
- (NSUInteger) fileSystemFileNumber;
- (NSInteger) fileSystemNumber;
-(NSString *)fileType;
@end

@interface NSString(NSFileManager)
- (const char *)fileSystemRepresentation;
@end

@interface NSDirectoryEnumerator	:	NSEnumerator
- (NSDictionary *) directoryAttributes;
- (NSDictionary *) fileAttributes;
- (NSUInteger) level;
- (void) skipDescendants;
@end
