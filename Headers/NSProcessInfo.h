/*
 * Copyright (c) 2004-2011	Gold Project
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
/*!
  @file ProcessInfo.h
 */
#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>

@class NSArray;
@class NSDictionary;

/*!
 \class ProcessInfo
 \brief ProcessInfo provides an interface to the operating system for
 retrieving information on the process itself.
 */
@interface NSProcessInfo	: NSObject

/*!
 \brief Returns the ProcessInfo for the process.
 The object is initialized on the first invocation of this
 method, and that same object is returned each subsequent invocation.
 */
+(NSProcessInfo *)processInfo;

/*!
 \brief Returns the arguments as an array of Strings from the command line.
 */
-(NSArray *)arguments;

/*!
 \brief Returns a dictionary of variables defined in the process's environment.
 */
-(NSDictionary *)environment;

/*!
 \brief Adds a new environment variable to the process's environment.
 \param var Variable name to add or set.
 \param val NSValue to associate with the variable.
 */
-(void)addEnvironmentVariable:(NSString *)var withValue:(NSString *)val;

/*!
 \brief Sets the environment to the given dictionary key-value pairs.
 \param newEnv Replacement environment.
 */
-(void)setEnvironment:(NSDictionary *)newEnv;

/*!
 \brief Returns the name of the process under which this program's user defaults domain is created, and is the name used for error messages.
 */
-(NSString *)processName;

-(pid_t) processIdentifier;

/*!
 \brief Returns a globally unique string to identify the process.
 This method uses the host name, process ID, and timestamp ot
 ensure that the string returned will be globally unique.
 */
-(NSString *)globallyUniqueString;

/*!
  \brief Returns the number of threads in the current process.
  */
- (unsigned int)threadCount;

/*!
 \brief Sets the process name.
 \param newName Name to give the process.
 Warning: Aspects of the environment, such as the user defaults, might
 depend on the process name.
 */
-(void)setProcessName:(NSString *)newName;

- (NSString *) hostName;

- (unsigned long long) physicalMemory;
- (NSUInteger) processorCount;
- (NSTimeInterval) systemUptime;

/* Not yet implemented, don't know when it will. */
- (void) enableSuddenTermination;
- (void) disableSuddenTermination;
@end

/*
   vim:syntax=objc:
 */
