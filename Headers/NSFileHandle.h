/*
 * Copyright (c) 2012	Justin Hibbits
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

#import <Foundation/NSObject.h>
#import <Foundation/NSException.h>

@class NSArray;
@class NSData;
@class NSError;
@class NSString;
@class NSURL;

extern NSString * const NSFileHandleConnectionAcceptedNotification;
extern NSString * const NSFileHandleDataAvailableNotification;
extern NSString * const NSFileHandleReadCompletionNotification;
extern NSString * const NSFileHandleReadToEndOfFileCompletionNotification;

extern NSString * const NSFileHandleNotificationFileHandleItem;
extern NSString * const NSFileHandleNotificationDataItem;

@interface NSFileHandleOperationException : NSStandardException
@end

@interface NSFileHandle	:	NSObject

@property (copy) void (^readabilityHandler)(NSFileHandle *);
@property (copy) void (^writeadabilityHandler)(NSFileHandle *);

+ (id) fileHandleForReadingFromURL:(NSURL *)url error:(NSError **)errp;
+ (id) fileHandleForWritingToURL:(NSURL *)url error:(NSError **)errp;
+ (id) fileHandleForUpdatingURL:(NSURL *)url error:(NSError **)errp;

+ (id) fileHandleWithStandardError;
+ (id) fileHandleWithStandardInput;
+ (id) fileHandleWithStandardOutput;
+ (id) fileHandleWithNullDevice;

- (id) initWithFileDescriptor:(int)desc;
- (id) initWithFileDescriptor:(int)desc closeOnDealloc:(bool)close;

- (int) fileDescriptor;

- (NSData *) availableData;
- (NSData *) readDataToEndOfFile;
- (NSData *) readDataOfLength:(NSUInteger)length;

- (void) writeData:(NSData *)data;

- (void) acceptConnectionInBackgroundAndNotify;
- (void) acceptConnectionInBackgroundAndNotifyForModes:(NSArray *)modes;
- (void) readInBackgroundAndNotify;
- (void) readInBackgroundAndNotifyForModes:(NSArray *)modes;
- (void) readToEndOfFileInBackgroundAndNotify;
- (void) readToEndOfFileInBackgroundAndNotifyForModes:(NSArray *)modes;
- (void) waitForDataInBackgroundAndNotify;
- (void) waitForDataInBackgroundAndNotifyForModes:(NSArray *)modes;

- (off_t) offsetInFile;
- (void) seekToEndOfFile;
- (void) seekToFileOffset:(off_t)offset;

- (void) closeFile;
- (void) synchronizeFile;
- (void) truncateFileAtOffset:(off_t)offset;
@end

@interface NSPipe	:	NSObject
- (id) init;
+ (id) pipe;

- (NSFileHandle *) fileHandleForReading;
- (NSFileHandle *) fileHandleForWriting;
@end

/*
  vim:syntax=objc:
 */
