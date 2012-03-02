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

#import <Foundation/NSObject.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
//#import <Foundation/DirectoryEnumerator.h>

@class NSData,NSDate,NSError,NSURI;

SYSTEM_EXPORT NSString * const NSFileType;
SYSTEM_EXPORT NSString * const NSRegularFileType;
SYSTEM_EXPORT NSString * const NSDirectoryFileType;
SYSTEM_EXPORT NSString * const NSSymbolicLinkFileType;

SYSTEM_EXPORT NSString * const NSCharacterSpecialFileType;
SYSTEM_EXPORT NSString * const NSBlockSpecialFileType;
SYSTEM_EXPORT NSString * const NSFIFOFileType;

SYSTEM_EXPORT NSString * const NSSocketFileType;

SYSTEM_EXPORT NSString * const NSUnknownFileType;

SYSTEM_EXPORT NSString * const NSFileSize;
SYSTEM_EXPORT NSString * const NSFileModificationDate;
SYSTEM_EXPORT NSString * const NSFileOwnerAccountName;
SYSTEM_EXPORT NSString * const NSFileGroupOwnerAccountName;
SYSTEM_EXPORT NSString * const NSFileAccess;

SYSTEM_EXPORT NSString * const NSFilePosixPermissions;
SYSTEM_EXPORT NSString * const NSFileReferenceCount;
SYSTEM_EXPORT NSString * const NSFileIdentifier;
SYSTEM_EXPORT NSString * const NSFileDeviceIdentifier;

SYSTEM_EXPORT NSString * const NSFileSystemNumber;
SYSTEM_EXPORT NSString * const NSFileSystemSize;
SYSTEM_EXPORT NSString * const NSFileSystemFreeSize;

@protocol NSFileManagerDelegate;

@interface NSFileManager : NSObject
{
	id delegate;
}
@property(retain) id<NSFileManagerDelegate> delegate;

+(NSFileManager *)defaultManager;

-(NSDictionary *)attributesOfFileSystemForURI:(NSURI *)path error:(NSError **)errorp;
-(NSDictionary *)attributesOfItemAtURI:(NSURI *)path error:(NSError **)error;
-(bool)changeCurrentDirectoryURI:(NSURI *)path;
-(bool)contentsEqualAtURI:(NSURI *)path1 andURI:(NSURI *)path2;
-(NSArray *)contentsOfDirectoryAtURI:(NSURI *)path error:(NSError **)error;
-(bool)copyItemAtURI:(NSURI *)fromPath toURI:(NSURI *)toPath error:(NSError **)error;
-(NSString *)destinationOfSymbolicLinkAtURI:(NSURI *)path error:(NSError **)error;

-(bool)isDeletableFileAtURI:(NSURI *)path;

-(bool)linkItemAtURI:(NSURI *)fromPath toURI:(NSURI *)toPath error:(NSError **)error;
-(bool)moveItemAtURI:(NSURI *)fromPath toURI:(NSURI *)toPath error:(NSError **)error;
-(bool)removeItemAtURI:(NSURI *)path error:(NSError **)error;

-(bool)setAttributes:(NSDictionary *)attributes ofItemAtURI:(NSURI *)path error:(NSError **)error;

-(NSString *)stringWithFileSystemRepresentation:(const char *)string length:(NSIndex)length;

-(NSArray *)subpathsOfDirectoryAtURI:(NSURI *)path error:(NSError **)error;

-(NSData *)contentsOfFileAtURI:(NSURI *)path shared:(bool)shared error:(NSError **)error;

-(bool)createFileAtURI:(NSURI *)path contents:(NSData *)data attributes:(NSDictionary *)attributes;

//-(DirectoryEnumerator *)enumeratorAtURI:(NSURI *)path;

-(bool)createDirectoryAtURI:(NSURI *)path withIntermediateDirectories:(bool)intermediates attributes:(NSDictionary *)attributes error:(NSError **)error;

-(bool)createSymbolicLinkAtURI:(NSURI *)path withDestinationURI:(NSURI *)toPath error:(NSError **)error;

-(bool)fileExistsAtURI:(NSURI *)path;
-(bool)fileExistsAtURI:(NSURI *)path isDirectory:(bool *)isDirectory;

-(NSString *)currentDirectoryPath;

-(bool)isReadableFileAtURI:(NSURI *)path;
-(bool)isWritableFileAtURI:(NSURI *)path;
-(bool)isExecutableFileAtURI:(NSURI *)path;

-(const char *)fileSystemRepresentationWithURI:(NSURI *)path;

@end

@protocol NSFileManagerDelegate<NSObject>
@optional
-(bool)fileManager:(NSFileManager *)fileManager shouldCopyItemAtURI:(NSURI *)path toURI:(NSURI *)toPath;
-(bool)fileManager:(NSFileManager *)fileManager shouldLinkItemAtURI:(NSURI *)path toURI:(NSURI *)toPath;
-(bool)fileManager:(NSFileManager *)fileManager shouldMoveItemAtURI:(NSURI *)path toURI:(NSURI *)toPath;
-(bool)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtURI:(NSURI *)path toURI:(NSURI *)toPath;
-(bool)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error linkingItemAtURI:(NSURI *)path toURI:(NSURI *)toPath;
-(bool)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error movingItemAtURI:(NSURI *)path toURI:(NSURI *)toPath;
-(bool)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error removingItemAtURI:(NSURI *)path;

-(bool)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtURI:(NSURI *)path;

@end

@interface NSDictionary(NSFileManager_fileAttributes)
- (NSDate *) fileCreationDate;
-(NSDate *)fileModificationDate;
//-(unsigned long)filePosixPermissions;
-(NSString *)fileOwnerAccountName;
-(NSString *)fileGroupOwnerAccountName;
-(NSString *)fileType;
-(uint64_t)fileSize;
@end

@interface NSString(NSFileManager)
- (const char *)fileSystemRepresentation;
@end
