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

#include <types.h>
#import <Foundation/primitives.h>
#import <Foundation/NSObject.h>

@class NSMutableArray, NSThread;

/*!
 \class NSApplication
 \brief The process image class.  Holds all data necessary for defining the
 process.

 \details The NSApplication class is the frontend for communicating between
 processes.  Accessing classes in a process requires accessing the process
 first, to validate access to objects.
 */
@interface NSApplication	: NSObject
{
	UUID processID;		/*!< \brief Process ID */
	UUID parentID;		/*!< \brief Parent process ID */
	NSMutableArray *threadList;	/*!< \brief List of registered threads in this process. */
}

/*! 
 *  \brief  Returns the application object.
 *  \return NSApplication object representing the currently running application.
 */
+ (NSApplication *)currentApplication;

/*!
 * \internal
 * \brief Run the application.
 */
- (id) run;

/*! 
 *  \internal 
 *  \brief  Add a thread to the monitored thread pool. 
 *  \param thr NSThread to add to the pool.
 *
 *  \details  This is called at thread creation time.
 */
- (void) addThread:(NSThread *)thr;

/*! 
 *  \internal
 *  \brief  Remove the given thread from the thread pool.
 *  \param  thr NSThread to remove from pool.
 *
 *  \details This is called at thread exit time.
 */
- (void) removeThread:(NSThread *)thr;

/*! 
 *  \internal
 *  \brief  Cleans up the application object's mess.
 */
- (void) cleanup;

/*!
 *  \var app
 *  \brief NSApplication object for the currently running application.
 */
extern NSApplication *App;
@end

/*
   vim:syntax=objc:
 */
