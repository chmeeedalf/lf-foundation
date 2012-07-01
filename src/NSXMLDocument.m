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

#include <string.h>

#import <Foundation/NSXMLDocument.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSXMLElement.h>
#import <Foundation/NSXMLNode.h>
#import <Foundation/NSXMLNodeOptions.h>
#import "internal.h"

#define thisNode ((xmlDoc *)nodePtr)
@implementation NSXMLDocument
- (id) initWithContentsOfURL:(NSURL *)url options:(NSUInteger)mask error:(NSError **)errp
{
	self = [self initWithData:[NSData dataWithContentsOfURL:url] options:mask error:errp];
	[self setURI:[url absoluteString]];
	return self;
}

- (id) initWithData:(NSData *)data options:(NSUInteger)mask error:(NSError **)errp
{
	TODO;	// -[NSXMLDocument initWithData:options:error:]
	NSParameterAssert(data != nil);
	return self;
}

- (id) initWithRootElement:(NSXMLElement *)root
{
	self = [self initWithKind:NSXMLDocumentKind options:0];
	[self setRootElement:root];
	return self;
}

- (id) initWithXMLString:(NSString *)string options:(NSUInteger)mask error:(NSError **)errp
{
	return [self initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
					  options:mask
						error:errp];
}

+ (Class) replacementClassForClass:(Class)cls
{
	return cls;
}


- (NSString *) characterEncoding
{
	if (thisNode->encoding == NULL)
		return nil;
	return [NSString stringWithUTF8String:thisNode->encoding];
}

- (void) setCharacterEncoding:(NSString *)encoding
{
	if (thisNode->encoding != NULL)
	{
		xmlFree((void *)thisNode->encoding);
	}
	thisNode->encoding = xmlStrdup([encoding UTF8String]);
}

- (NSXMLDocumentContentKind) documentContentKind
{
	TODO;	// -[NSXMLDocument documentContentKind]
	return 0;
}

- (void) setDocumentContentKind:(NSXMLDocumentContentKind)kind
{
	TODO;	// -[NSXMLDocument setDocumentContentKind:]
}

- (NSXMLDTD *) DTD
{
	if (thisNode->intSubset == NULL)
		return nil;
	return (__bridge id)thisNode->intSubset->_private;
}

- (void) setDTD:(NSXMLDTD *)dtd
{
	TODO;	// -[NSXMLDocument setDTD:]
}

- (bool) isStandalone
{
	return thisNode->standalone;
}

- (void) setStandalone:(bool)standalone
{
	thisNode->standalone = standalone;
}

- (NSString *)MIMEType
{
	TODO; 	// -[NSXMLDocument MIMEType]
	return nil;
}

- (void) setMIMEType:(NSString *)type
{
	TODO; 	// -[NSXMLDocument setMIMEType:]
}

- (NSString *) URI
{
	if (thisNode->URL == NULL)
		return nil;

	return [NSString stringWithUTF8String:thisNode->URL];
}

- (void) setURI:(NSString *)newURI
{
	if (thisNode->URL != NULL)
	{
		xmlFree((void *)thisNode->URL);
	}
	thisNode->URL = xmlStrdup([newURI UTF8String]);
}

- (NSString *) version
{
	if (thisNode->version == NULL)
		return nil;

	return [NSString stringWithUTF8String:thisNode->version];
}

- (void) setVersion:(NSString *)newVers
{
	if (thisNode->version != NULL)
	{
		xmlFree((void *)thisNode->version);
	}
	thisNode->version = xmlStrdup([newVers UTF8String]);
}


- (NSXMLElement *) rootElement
{
	xmlNodePtr root = xmlDocGetRootElement(thisNode);
	if (root != NULL)
		return (__bridge id)root->_private;
	return nil;
}

- (void) setRootElement:(NSXMLElement *)newRoot
{
	xmlDocSetRootElement(thisNode, newRoot->nodePtr);
}


- (void) addChild:(NSXMLNode *)child
{
	[self insertChild:child atIndex:[self childCount]];
}

- (void) insertChild:(NSXMLNode *)child atIndex:(NSUInteger)index
{
	NSParameterAssert(index < [self childCount]);
	[child detach];
	xmlAddNextSibling([self childAtIndex:index]->nodePtr, child->nodePtr);
}

- (void) insertChildren:(NSArray *)children atIndex:(NSUInteger)index
{
	__block NSUInteger idx = index;

	[children enumerateObjectsUsingBlock:^(id child, NSUInteger indx, bool *stop){
		[self insertChild:child atIndex:idx++];
	}];
}

- (void) removeChildAtIndex:(NSUInteger)index
{
	NSParameterAssert(index < [self childCount]);

	NSXMLNode *child = [self childAtIndex:index];
	[child detach];
}

- (void) replaceChildAtIndex:(NSUInteger)index withNode:(NSXMLNode *)newChild
{
	NSParameterAssert(index < [self childCount]);
	xmlReplaceNode([self childAtIndex:index]->nodePtr, newChild->nodePtr);
}

- (void) setChildren:(NSArray *)newChildren
{
	NSUInteger newCount = [newChildren count];
	if ([newChildren count] > [self childCount])
	{
		for (NSUInteger i = [self childCount]; i < newCount; i++)
		{
			[self addChild:[newChildren objectAtIndex:i]];
		}
	}
	else
	{
		for (NSUInteger i = [self childCount] - newCount; i > 0; --i)
		{
			[self removeChildAtIndex:newCount];
		}
	}
	for (NSUInteger i = 0; i < newCount; i++)
	{
		[self replaceChildAtIndex:i withNode:[newChildren objectAtIndex:i]];
	}
}


- (id) objectByApplyingXSLT:(NSData *)xslt arguments:(NSDictionary *)args error:(NSError **)errp
{
	TODO; 	// -[NSXMLDocument objectByApplyingXSLT:arguments:error:]
	return nil;
}

- (id) objectByApplyingXSLTString:(NSString *)xslt arguments:(NSDictionary *)args error:(NSError **)errp
{
	return [self objectByApplyingXSLT:[xslt dataUsingEncoding:NSUTF8StringEncoding] arguments:args error:errp];
}

- (id) objectByApplyingXSLTAtURL:(NSURL *)xsltURL arguments:(NSDictionary *)args error:(NSError **)errp
{
	return [self objectByApplyingXSLT:[NSData dataWithContentsOfURL:xsltURL] arguments:args error:errp];
}


- (NSData *) XMLData
{
	return [self XMLDataWithOptions:NSXMLNodeOptionsNone];
}

- (NSData *) XMLDataWithOptions:(NSUInteger)options
{
	return [[self XMLStringWithOptions:options] dataUsingEncoding:NSUTF8StringEncoding
				  allowLossyConversion:false];
}


- (bool) validateAndReturnError:(NSError **)errp
{
	TODO; 	// -[NSXMLDocument validateAndReturnError:]
	return false;
}


@end
