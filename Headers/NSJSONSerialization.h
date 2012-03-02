/*
 * Copyright (c) 2011-2012	Gold Project
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
/* Copyright (c) 2011 David Chisnall */

#import "Foundation/NSObject.h"

@class NSData;
@class NSError;
@class NSInputStream;
@class NSOutputStream;

enum
{
  /**
   * Collection classes created from reading a JSON stream will be mutable.
   */
  NSJSONReadingMutableContainers = (1UL << 0),
  /**
   * Strings in a JSON tree will be mutable.
   */
  NSJSONReadingMutableLeaves     = (1UL << 1),
  /**
   * The parser will read a single value, not just a 
   */
  NSJSONReadingAllowFragments    = (1UL << 2)
};
enum
{
  /**
   * When writing JSON, produce indented output intended for humans to read.
   * If this is not set, then the writer will not generate any superfluous
   * whitespace, producing space-efficient but not very human-friendly JSON.
   */
  NSJSONWritingPrettyPrinted = (1UL << 0)
};
/**
 * A bitmask containing flags from the NSJSONWriting* set, specifying options
 * to use when writing JSON.
 */
typedef NSUInteger NSJSONWritingOptions;
/**
 * A bitmask containing flags from the NSJSONReading* set, specifying options
 * to use when reading JSON.
 */
typedef NSUInteger NSJSONReadingOptions;


/**
 * NSJSONSerialization implements serializing and deserializing acyclic object
 * graphs in JSON.
 */
@interface NSJSONSerialization : NSObject
 + (NSData *)dataWithJSONObject:(id)obj
                        options:(NSJSONWritingOptions)opt
                          error:(NSError **)error;
+ (bool)isValidJSONObject:(id)obj;
+ (id)JSONObjectWithData:(NSData *)data
                 options:(NSJSONReadingOptions)opt
                   error:(NSError **)error;
+ (id)JSONObjectWithStream:(NSInputStream *)stream
                   options:(NSJSONReadingOptions)opt
                     error:(NSError **)error;
+ (NSInteger)writeJSONObject:(id)obj
                    toStream:(NSOutputStream *)stream
                     options:(NSJSONWritingOptions)opt
                       error:(NSError **)error;
@end
