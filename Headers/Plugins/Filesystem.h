/*
 * Copyright (c) 2005	Gold Project
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

#import <Foundation/NSObject.h>

/*!
 * \file Plugins/Filesystem.h
 * \brief Interface header for ObjectManager plugins.
 */
@class NSString;
@class NSDictionary;
@class NSError;
@class NSFileHandle;

/* Manage 'schemes' a'la NSURL RFC */
/*!
  \protocol Filesystem
 */
@protocol NSFilesystem
/*!
 * \brief Returns the shared handler for this NSURL scheme.
 */
+ (id)sharedHandler;

/*!
 * \brief Returns the contents of the directory at the given path.
 */
- (NSArray *)contentsOfDirectoryAtURL:(NSURL *)path error:(NSError **)errOut;

/*!
 * \brief Returns the contents of the file at the given path, traversing
 * symlinks, either shared or private.
 */
- (NSData *)contentsOfFileAtURL:(NSURL *)path shared:(bool)shared error:(NSError **)errOut;

-(bool)createDirectoryAtURL:(NSURL *)path withIntermediateDirectories:(bool)intermediates attributes:(NSDictionary *)attributes error:(NSError **)err;

- (bool)createFileAtURL:(NSURL *)path contents:(NSData *)data attributes:(NSDictionary *)attributes error:(NSError **)errOut;

- (bool)createSymbolicLinkAtURL:(NSURL *)path withDestinationURL:(NSURL *)destPath error:(NSError **)errOut;
- (bool) linkItemAtURL:(NSURL *)from toURL:(NSURL *)to error:(NSError **)errP;

/*!
 * \brief Delete an object from storage.
 * \param name Identifier to delete.
 */
- (bool)deleteItemAtURL:(NSURL *)path error:(NSError **)errOut;

/*!
 * \brief Returns the destination of the symbolic link.
 */
- (NSString *)destinationOfSymbolicLinkAtURL:(NSURL *)path error:(NSError **)errOut;

/*!
 * \brief NSSet the attribute dictionary for the named object.
 * \param dict New attribute dictionary.
 * \param name Identifier to modify.
 */
- (bool)setAttributes:(NSDictionary *)dict ofItemAtURL:(NSURL *)path error:(NSError **)errOut;

/*!
 * \brief Retrieve the attribute dictionary for the object with the given name.
 * \param name NSObject identifier to retrieve attributes for.
 */
- (NSDictionary *)attributesOfItemAtURL:(NSURL *)path error:(NSError **)errOut;

/*!
 */
- (NSFileHandle *) fileHandleForWritingAtURL:(NSURL *)path;
- (NSFileHandle *) fileHandleForReadingAtURL:(NSURL *)path;
@end

/*! \defgroup objattr Managed object attributes */
/* @{ */
SYSTEM_EXPORT NSString *const NSAttributeMIMEType;	/*!< \brief MIME Type attribute. */
SYSTEM_EXPORT NSString *const NSAttributeObjectSize;	/*!< \brief NSObject size attribute. */
SYSTEM_EXPORT NSString *const NSAttributeIdentifier;	/*!< \brief NSObject identifier. */
SYSTEM_EXPORT NSString *const NSAttributeCreatedTime;	/*!< \brief Creation time. */
SYSTEM_EXPORT NSString *const NSAttributeModifiedTime;	/*!< \brief Last modified time. */
SYSTEM_EXPORT NSString *const NSAttributeMetadataChangedTime;	/*!< \brief Last metadata change time. */
/* @} */

/*
   vim:syntax=objc:
 */
