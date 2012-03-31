/* $Id$	*/
/*
 * All rights reserved.
 * Copyright (c) 2008	Justin Hibbits
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

@class NSArray, NSData, NSString;

/*!
  \protocol MIMEHandler
  \brief Classes that conform to the MIMEHandler protocol are proxy-type
  classes, for handling foreign MIME-encoded datatypes.
 */
@protocol MIMEHandler
/*!
 * \brief Returns a list of MIME types handled by this class.
 * \details A MIME handler can potentially handle multiple encodings.
 */
+ (NSArray *)handledMIMEEncodings;

/*!
 * \brief Initialize the MIME handler object with data of a given encoding.
 * \param _data MIME encoded source data.
 * \param enc MIME format of the encoded data.
 */
- (id) initWithData:(NSData *)_data MIMEEncoding:(NSString *)enc;

/*!
 * \brief Encode the receiver to a given MIME type, returning the actual encoding.
 * \param encoding MIME-formatted encoding target.
 * \retval outEnc MIME type for output data.
 * \returns NSObject encoded as the given MIME type.
 * \details Pass nil for the encoding to let the handler choose.
 * \e outEnc can be \c nil unless \e encoding is \c nil, in which \e outenc cannot be \c nil.
 */
- (NSData *)encodedDataForMIME:(NSString *)encoding outputEncoding:(NSString **)outEnc;
@end

/*
   vim:syntax=objc:
 */
