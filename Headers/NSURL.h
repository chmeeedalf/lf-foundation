/*
 * Copyright (c) 2005-2012	Justin Hibbits
 * All rights reserved.
 * * Redistribution and use in source and binary forms, with or without
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

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

/*!
 * \file NSURL.h
 */

@class NSHost;
@class NSNumber;
@class NSString;

SYSTEM_EXPORT NSString * const NSURLFileScheme;

SYSTEM_EXPORT NSString * const NSURLNameKey;
SYSTEM_EXPORT NSString * const NSURLLocalizedNameKey;
SYSTEM_EXPORT NSString * const NSURLIsRegularFileKey;
SYSTEM_EXPORT NSString * const NSURLIsDirectoryKey;
SYSTEM_EXPORT NSString * const NSURLIsSymbolicLinkKey;
SYSTEM_EXPORT NSString * const NSURLIsVolumeKey;
SYSTEM_EXPORT NSString * const NSURLIsPackageKey;
SYSTEM_EXPORT NSString * const NSURLIsSystemImmutableKey;
SYSTEM_EXPORT NSString * const NSURLIsUserImmutableKey;
SYSTEM_EXPORT NSString * const NSURLIsHiddenKey;
SYSTEM_EXPORT NSString * const NSURLHasHiddenExtensionKey;
SYSTEM_EXPORT NSString * const NSURLCreationDateKey;
SYSTEM_EXPORT NSString * const NSURLContentAccessDateKey;
SYSTEM_EXPORT NSString * const NSURLContentModificationDateKey;
SYSTEM_EXPORT NSString * const NSURLAttributeModificationDateKey;
SYSTEM_EXPORT NSString * const NSURLLinkCountKey;
SYSTEM_EXPORT NSString * const NSURLParentDirectoryURLKey;
SYSTEM_EXPORT NSString * const NSURLVolumeURLKey;
SYSTEM_EXPORT NSString * const NSURLTypeIdentifierKey;
SYSTEM_EXPORT NSString * const NSURLLocalizedTypeDescriptionKey;
SYSTEM_EXPORT NSString * const NSURLLabelNumberKey;
SYSTEM_EXPORT NSString * const NSURLLabelColorKey;
SYSTEM_EXPORT NSString * const NSURLLocalizedLabelKey;
SYSTEM_EXPORT NSString * const NSURLEffectiveIconKey;
SYSTEM_EXPORT NSString * const NSURLCustomIconKey;

SYSTEM_EXPORT NSString * const NSURLVolumeLocalizedFormatDescriptionKey;
SYSTEM_EXPORT NSString * const NSURLVolumeTotalCapacityKey;
SYSTEM_EXPORT NSString * const NSURLVolumeAvailableCapacityKey;
SYSTEM_EXPORT NSString * const NSURLVolumeResourceCountKey;
SYSTEM_EXPORT NSString * const NSURLVolumeSupportsPersistentIDsKey;
SYSTEM_EXPORT NSString * const NSURLVolumeSupportsSymbolicLinksKey;
SYSTEM_EXPORT NSString * const NSURLVolumeSupportsHardLinksKey;
SYSTEM_EXPORT NSString * const NSURLVolumeSupportsJournalingKey;
SYSTEM_EXPORT NSString * const NSURLVolumeIsJournalingKey;
SYSTEM_EXPORT NSString * const NSURLVolumeSupportsSparseFilesKey;
SYSTEM_EXPORT NSString * const NSURLVolumeSupportsZeroRunsKey;
SYSTEM_EXPORT NSString * const NSURLVolumeSupportsCaseSensitiveNamesKey;
SYSTEM_EXPORT NSString * const NSURLVolumeSupportsCasePreservedNamesKey;

SYSTEM_EXPORT NSString * const NSURLFileSizeKey;
SYSTEM_EXPORT NSString * const NSURLFileAllocatedSizeKey;
SYSTEM_EXPORT NSString * const NSURLIsAliasFileKey;

/*!
 * \brief NSURL type.
 */
typedef enum NSURLType {
	NSURLNetType = 1,	/*!< \brief Network type (has network component). */
	NSURLOpaqueType,	/*!< \brief Opaque type (no network component). */
} NSURLType;

// RFC 2396 compliant
/*!
 * \brief RFC 2396-compliant NSURL class.
 */
@interface NSURL	: NSObject<NSCoding, NSCopying>
{
	NSURLType type;	/*!< \brief Type of the NSURL. */
	NSURL *baseURL;
	NSString *srcString;
	NSString *scheme;	/*!< \brief NSURL Scheme (http, ftp, telnet, etc). */
	NSString *hostName;	/*!< \brief Hostname part of the NSURL. */
	NSHost *host;		/*!< \brief Host named by the hostName. */
	NSNumber * port;	/*!< \brief Port component. */
	NSString *query;	/*!< \brief Query component ( ...?foo ) */
	NSString *fragment;	/*!< \brief Fragment component (example: index.html#foo) */
	NSString *path;	/*!< \brief Path component. */
	NSString *userInfo;	/*!< \brief User info -- username and password. */
}

/*!
 * \brief Create a NSURL from a valid string.
 * \returns The NSURL, or \c nil if the string is invalid.
 */
+ (id) URLWithString:(NSString *)string;
+ (id) URLWithString:(NSString *)string relativeToURL:(NSURL *)parent;

+ (id) fileURLWithPath:(NSString *)path;
+ (id) fileURLWithPath:(NSString *)path isDirectory:(bool)isDir;
+ (id) fileURLWithPathComponents:(NSArray *)components;


/*!
 * \brief Initialize the NSURL with a valid string.
 * \returns The NSURL, or \c nil if the string is invalid.
 */
- (id) initWithString:(NSString *)string;
- (id) initFileURLWithPath:(NSString *)path;
- (id) initFileURLWithPath:(NSString *)path isDirectory:(bool)isDir;
- (id) initWithString:(NSString *)string relativeToURL:(NSURL *)parent;
- (id) initWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path;

/*!
 * \brief Returns the NSURL's scheme (http, ftp, telnet, ...)
 */
- (NSString *)scheme;

/*!
 * \brief Returns the NSURL's path.
 */
- (NSString *)path;

/*!
 * \brief Returns the NSURL's host data.
 */
- (NSHost *) host;
- (NSString *) hostname;

/*!
 * \brief Returns the NSURL's port, if it exists.
 */
- (NSNumber *) port;

- (bool) isEqual:(id)other;
- (bool) isFileURL;
- (NSString *) absoluteString;
- (NSURL *) absoluteURL;
- (NSURL *) baseURL;
- (NSURL *) standardizedURL;

-(NSString *)parameterString;

-(NSString *)user;
-(NSString *)password;
-(NSString *)fragment;
-(NSString *)lastPathComponent;
-(NSArray *)pathComponents;
-(NSString *)pathExtension;
-(NSString *)query;
-(NSString *)relativePath;
-(NSString *)relativeString;
-(NSString *)resourceSpecifier;

- (NSURL *) URLByAppendingPathComponent:(NSString *)component;
- (NSURL *) URLByAppendingPathComponent:(NSString *)component isDirectory:(bool)isDir;
- (NSURL *) URLByAppendingPathExtension:(NSString *)extension;
- (NSURL *) URLByDeletingLastPathComponent;
- (NSURL *) URLByDeletingPathExtension;
- (NSURL *) URLByResolvingSymlinksInPath;
- (NSURL *) URLByStandardizingPath;

- (bool) getResourceValue:(out id *)value forKey:(NSString *)key error:(out NSError **)errp;
- (NSDictionary *) resourceValuesForKeys:(NSArray *)keys error:(NSError **)errp;
- (bool) setResourceValue:(id)value forKey:(NSString *)key error:(NSError **)errp;
- (bool) setResourceValues:(NSDictionary *)keyedValues error:(NSError **)errp;

@end

/*!
 * \brief Extensions to the NSString class to handle IDNA formats.
 */
@interface NSString(IDNA)

/*!
 * \brief Returns the ASCII representation of the string.
 * \returns The ASCII representation of the string, or \c nil if it cannot be
 * represented as ASCII.
 */
- (id) ASCIIString;

/*!
 * \brief Returns the Unicode representation of a Punycode string.
 */
- (id) punycodeString;
@end
/*
   vim:syntax=objc:
 */
