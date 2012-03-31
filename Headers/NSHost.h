/*
 * Copyright (c) 2004-2012	Justin Hibbits
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

/* 
   NSHost.h

   Copyright (C) 1995, 1996, 1997 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Aleksandr Savostyanov <sav@conextions.com>

   This file is part of libFoundation.

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
 */

#import <Foundation/NSObject.h>

@class NSString, NSArray, NSMutableArray;

typedef enum {
	NSIPv4Address,
	NSIPv6Address,
} NSAddressType;

/*!
  @class NSHost
  @brief The Host class is used for resolving hostnames and addresses.
 */
@interface NSHost : NSObject 
{
	NSMutableArray 	*names;		/*!< \brief The names for this host. */
	NSMutableArray 	*addresses;	/*!< \brief The set of addresses for this host. */
	bool	resolved;	/*!< \brief Whether this host has been resolved or not. */
}

/*!
  @brief Returns the current host.
 */
+ (NSHost *)currentHost;

/*!
 * \brief Returns a Host object with a specific name.
 * \param name Host name to look up.
 */
+ (NSHost *)hostWithName:(NSString *)name;

/*!
 * \brief Returns a Host object with the given address.
 * \param address Address to look up.
 */
+ (NSHost *)hostWithAddress:(NSString *)address;

/*!
  @brief Compares this host with another.
  @param aHost The host to compare with.
 */
- (bool)isEqualToHost:(NSHost *)aHost;

/*!
  @brief Returns the primary name of the host.
 */
- (NSString *)name;

/*!
  @brief Returns an array of all names associated with the receiver.
 */
- (NSArray *)names;

/*!
  @brief Returns the primary address of the host.
 */
- (NSString *)address;

/*!
  @brief Returns an array of all addresses associated with the receiver.
 */
- (NSArray *)addresses;

@end

/*
   vim:syntax=objc:
 */
