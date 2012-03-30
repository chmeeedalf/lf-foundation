/*
 * Copyright (c) 2005-2012	Gold Project
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

typedef enum NSResourceDomain {
	NSApplicationResourceDomain = 1,
	NSGlobalResourceDomain = 2,
	NSSystemResourceDomain = 8,
	NSInnermostResourceDomain = 0xFFFF,
} NSResourceDomain;

@class NSDictionary, NSMutableDictionary, NSString;

/*!
 * \brief Class to manage all resources for the current process.
 */
@interface NSResourceManager : NSObject

/*!
 \brief Returns the resource manager for the entire process.
 */
+ (NSResourceManager *)sharedManager;

/*!
  \brief Return the resource associated with the given name.
  \param name Name of resource to retrieve.
  \return Returns the resource associated with the given name, or nil if there
  is none.
  The name parameter can contain "/"s to separate the 'path'
  components of the resource.  Each level of the path must respond to the
  -objectForKey: message.
 */
- (id)resourceWithName:(NSString *)name;

/*!
  \brief Return the resource associated with the given name in the given domain.
  \param name Name of resource to retrieve.
  \param domain Resource domain list to check in.
  \return Returns the resource associated with the given name, or nil if there
  is none.
  The name parameter can contain "/"s to separate the 'path'
  components of the resource.  Each level of the path must respond to the
  -objectForKey: message.
 */
- (id)resourceWithName:(NSString *)name inDomain:(NSResourceDomain)domain;

/*!
 * \brief Add a resource dictionary to the runtime resource list.
 * \param dict New resource dictionary to add to the runtime resources.
 */
- (void) addResourceDictionary:(NSDictionary *)dict;

@end

/*
   vim:syntax=objc:
 */
