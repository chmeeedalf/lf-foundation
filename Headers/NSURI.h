/*
 * Copyright (c) 2005	Gold Project
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
#import <Foundation/NSString.h>

/*!
 * \file NSURI.h
 */

@class NSHost;
@class NSNumber;
@class NSString;

SYSTEM_EXPORT NSString * const NSURIFileScheme;

SYSTEM_EXPORT NSString * const NSURINameKey;
SYSTEM_EXPORT NSString * const NSURILocalizedNameKey;
SYSTEM_EXPORT NSString * const NSURIIsRegularFileKey;
SYSTEM_EXPORT NSString * const NSURIIsDirectoryKey;
SYSTEM_EXPORT NSString * const NSURIIsSymbolicLinkKey;
SYSTEM_EXPORT NSString * const NSURIIsVolumeKey;
SYSTEM_EXPORT NSString * const NSURIIsPackageKey;
SYSTEM_EXPORT NSString * const NSURIIsSystemImmutableKey;
SYSTEM_EXPORT NSString * const NSURIIsUserImmutableKey;
SYSTEM_EXPORT NSString * const NSURIIsHiddenKey;
SYSTEM_EXPORT NSString * const NSURIHasHiddenExtensionKey;
SYSTEM_EXPORT NSString * const NSURICreationDateKey;
SYSTEM_EXPORT NSString * const NSURIContentAccessDateKey;
SYSTEM_EXPORT NSString * const NSURIContentModificationDateKey;
SYSTEM_EXPORT NSString * const NSURIAttributeModificationDateKey;
SYSTEM_EXPORT NSString * const NSURILinkCountKey;
SYSTEM_EXPORT NSString * const NSURIParentDirectoryURIKey;
SYSTEM_EXPORT NSString * const NSURIVolumeURIKey;
SYSTEM_EXPORT NSString * const NSURITypeIdentifierKey;
SYSTEM_EXPORT NSString * const NSURILocalizedTypeDescriptionKey;
SYSTEM_EXPORT NSString * const NSURILabelNumberKey;
SYSTEM_EXPORT NSString * const NSURILabelColorKey;
SYSTEM_EXPORT NSString * const NSURILocalizedLabelKey;
SYSTEM_EXPORT NSString * const NSURIEffectiveIconKey;
SYSTEM_EXPORT NSString * const NSURICustomIconKey;

SYSTEM_EXPORT NSString * const NSURIVolumeLocalizedFormatDescriptionKey;
SYSTEM_EXPORT NSString * const NSURIVolumeTotalCapacityKey;
SYSTEM_EXPORT NSString * const NSURIVolumeAvailableCapacityKey;
SYSTEM_EXPORT NSString * const NSURIVolumeResourceCountKey;
SYSTEM_EXPORT NSString * const NSURIVolumeSupportsPersistentIDsKey;
SYSTEM_EXPORT NSString * const NSURIVolumeSupportsSymbolicLinksKey;
SYSTEM_EXPORT NSString * const NSURIVolumeSupportsHardLinksKey;
SYSTEM_EXPORT NSString * const NSURIVolumeSupportsJournalingKey;
SYSTEM_EXPORT NSString * const NSURIVolumeIsJournalingKey;
SYSTEM_EXPORT NSString * const NSURIVolumeSupportsSparseFilesKey;
SYSTEM_EXPORT NSString * const NSURIVolumeSupportsZeroRunsKey;
SYSTEM_EXPORT NSString * const NSURIVolumeSupportsCaseSensitiveNamesKey;
SYSTEM_EXPORT NSString * const NSURIVolumeSupportsCasePreservedNamesKey;

SYSTEM_EXPORT NSString * const NSURIFileSizeKey;
SYSTEM_EXPORT NSString * const NSURIFileAllocatedSizeKey;
SYSTEM_EXPORT NSString * const NSURIIsAliasFileKey;

/*!
 * \brief NSURI type.
 */
typedef enum NSURIType {
	NSURINetType = 1,	/*!< \brief Network type (has network component). */
	NSURIOpaqueType,	/*!< \brief Opaque type (no network component). */
} NSURIType;

// RFC 2396 compliant
/*!
 * \brief RFC 2396-compliant NSURI class.
 */
@interface NSURI	: NSObject<NSCoding, NSCopying>
{
	NSURIType type;	/*!< \brief Type of the NSURI. */
	NSURI *baseURI;
	NSString *srcString;
	NSString *scheme;	/*!< \brief NSURI Scheme (http, ftp, telnet, etc). */
	NSString *hostName;	/*!< \brief Hostname part of the NSURI. */
	NSHost *host;		/*!< \brief Host named by the hostName. */
	NSNumber * port;	/*!< \brief Port component. */
	NSString *query;	/*!< \brief Query component ( ...?foo ) */
	NSString *fragment;	/*!< \brief Fragment component (example: index.html#foo) */
	NSString *path;	/*!< \brief Path component. */
	NSString *userInfo;	/*!< \brief User info -- username and password. */
}

/*!
 * \brief Create a NSURI from a valid string.
 * \returns The NSURI, or \c nil if the string is invalid.
 */
+ URIWithString:(NSString *)string;
+ URIWithString:(NSString *)string relativeToURI:(NSURI *)parent;

+ fileURIWithPath:(NSString *)path;
+ fileURIWithPath:(NSString *)path isDirectory:(bool)isDir;
+ fileURIWithPathComponents:(NSArray *)components;


/*!
 * \brief Initialize the NSURI with a valid string.
 * \returns The NSURI, or \c nil if the string is invalid.
 */
- initWithString:(NSString *)string;
- initFileURIWithPath:(NSString *)path;
- initFileURIWithPath:(NSString *)path isDirectory:(bool)isDir;
- initWithString:(NSString *)string relativeToURI:(NSURI *)parent;
- initWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path;

/*!
 * \brief Returns the NSURI's scheme (http, ftp, telnet, ...)
 */
- (NSString *)scheme;

/*!
 * \brief Returns the NSURI's path.
 */
- (NSString *)path;

/*!
 * \brief Returns the NSURI's host data.
 */
- (NSHost *) host;
- (NSString *) hostname;

/*!
 * \brief Returns the NSURI's port, if it exists.
 */
- (NSNumber *) port;

- (bool) isEqual:(id)other;
- (bool) isFileURI;
- (NSString *) absoluteString;
- (NSURI *) absoluteURI;
- (NSURI *) baseURI;
- (NSURI *) standardizedURI;

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

- (NSURI *) URIByAppendingPathComponent:(NSString *)component;
- (NSURI *) URIByAppendingPathComponent:(NSString *)component isDirectory:(bool)isDir;
- (NSURI *) URIByAppendingPathExtension:(NSString *)extension;
- (NSURI *) URIByDeletingLastPathComponent;
- (NSURI *) URIByDeletingPathExtension;
- (NSURI *) URIByResolvingSymlinksInPath;
- (NSURI *) URIByStandardizingPath;

- (bool) getResourceValue:(id *)value forKey:(NSString *)key error:(NSError **)errp;
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
- ASCIIString;

/*!
 * \brief Returns the Unicode representation of a Punycode string.
 */
- PunycodeString;
@end
/*
   vim:syntax=objc:
 */
