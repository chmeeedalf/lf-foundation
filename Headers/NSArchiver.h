/* 
   NSArchiver.h
 * All rights reserved.

   Copyright (C) 1998 MDlink online service center, Helge Hess
   All rights reserved.

   Author: Helge Hess (helge@mdlink.de)

   This file is part of libSystem.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.

   The code is based on the NSArchiver class done by Ovidiu Predescu which has
   the following Copyright/permission:
   ---
   The basic archiving algorithm is based on libFoundation's NSArchiver by
   Ovidiu Predescu:
   
   NSArchiver.h

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Ovidiu Predescu <ovidiu@bx.logicnet.ro>

   This file is part of libSystem.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.
   ---
 */
// $Id$

#ifndef __Archiver_H__
#define __Archiver_H__

#import <Foundation/NSCoder.h>
#import <Foundation/NSException.h>

#ifndef __ARCHIVER_CLS
#define __ARCHIVER_CLS void *
#endif

@class NSHashTable, NSMapTable, NSMutableData, NSURL;

@interface NSInconsistentArchiveException	:	NSStandardException
@end

@interface NSArchiver : NSCoder

- (id)initForWritingWithMutableData:(NSMutableData*)mdata;

/* Archiving NSData */
+ (NSData*)archivedDataWithRootObject:(id)rootObject;
+ (bool)archiveRootObject:(id)rootObject toURL:(NSURL *)path;

/* Getting NSData from the NSArchiver */
- (NSMutableData *)archiverData;

/* encoding */

- (void)encodeConditionalObject:(id)_object;
- (void)encodeRootObject:(id)_object;

/* Substituting One Class for Another */

- (NSString *)classNameEncodedForTrueClassName:(NSString *)_trueName;
- (void)encodeClassName:(NSString *)_trueName intoClassName:(NSString *)_archiveName;
- (void) replaceObject:(id)obj withObject:(id)newObj;

@end

#ifndef __UNARCHIVER_CLS
#define __UNARCHIVER_CLS void *
#endif

@interface NSUnarchiver : NSCoder

- (id)initForReadingWithData:(NSData*)data;

/* Decoding Objects */
+ (id)unarchiveObjectWithData:(NSData*)data;
+ (id)unarchiveObjectWithURL:(NSURL*)path;

/* Managing an NSUnarchiver */

- (bool)isAtEnd;
- (NSZone *)objectZone;
- (void)setObjectZone:(NSZone *)_zone;
- (unsigned int)systemVersion;

// decoding

- (id)decodeObject;

/* Substituting One Class for Another */

+ (NSString *)classNameDecodedForArchiveClassName:(NSString *)nameInArchive;
+ (void)decodeClassName:(NSString *)nameInArchive asClassName:(NSString *)trueName;
- (NSString *)classNameDecodedForArchiveClassName:(NSString *)nameInArchive;
- (void)decodeClassName:(NSString *)nameInArchive asClassName:(NSString *)trueName;
- (void) replaceObject:(id)obj withObject:(id)newObj;

@end

#endif /* __Archiver_H__ */
/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
 */
