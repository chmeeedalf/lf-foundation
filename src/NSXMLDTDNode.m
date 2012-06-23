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

#import <Foundation/NSXMLDTDNode.h>
#import "internal.h"

#define thisNode ((xmlEntity *)nodePtr)
@implementation NSXMLDTDNode

- (id) initWithXMLString:(NSString *)string
{
	TODO; // -[NSXMLDTDNode initWithXMLString:]
	return nil;
}


- (NSXMLDTDNodeKind) DTDKind
{
	TODO;	// -[NSXMLDTDNode DTDKind]
	return 0;
}

- (void) setDTDKind:(NSXMLDTDNodeKind)kind
{
	TODO;	// -[NSXMLDTDNode setDTDKind:]
}


- (bool) isExternal
{
	TODO;	// -[NSXMLDTDNode isExternal]
	return false;
}

- (void) setNotationName:(NSString *)notationName
{
	TODO;	// -[NSXMLDTDNode setNotationName:]
}

- (NSString *) notationName
{
	TODO; // -[NSXMLDTDNode notationName]
	return nil;
}

- (void) setPublicID:(NSString *)publicID
{
	if (thisNode->ExternalID != NULL)
	{
		xmlFree((void *)thisNode->ExternalID);
	}
	thisNode->ExternalID = xmlStrdup([publicID UTF8String]);
}

- (NSString *) publicID
{
	if (thisNode->ExternalID == NULL)
		return nil;
	return [NSString stringWithUTF8String:thisNode->ExternalID];
}

- (void) setSystemID:(NSString *)systemID
{
	if (thisNode->SystemID != NULL)
	{
		xmlFree((void *)thisNode->SystemID);
	}
	thisNode->SystemID = xmlStrdup([systemID UTF8String]);
}

- (NSString *) systemID
{
	if (thisNode->SystemID == NULL)
		return nil;
	return [NSString stringWithUTF8String:thisNode->SystemID];
}


@end
