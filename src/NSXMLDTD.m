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

#import <Foundation/NSXMLDTD.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import "internal.h"

#define thisNode ((xmlDtd *)nodePtr)
@implementation NSXMLDTD

- (id) initWithContentsOfURL:(NSURL *)url options:(NSUInteger)options error:(NSError **)errp
{
	return [self initWithData:[NSData dataWithContentsOfURL:url]
					  options:options error:errp];
}

- (id) initWithData:(NSData *)data options:(NSUInteger)options error:(NSError **)errp
{
	TODO; // -[NSXMLDTD initWithData:options:error:]
	return self;
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


+ (NSXMLDTDNode *) predefinedEntityDeclarationForName:(NSString *)name
{
	TODO; // +[NSXMLDTD predefinedEntityDeclarationForName:]
	return nil;
}

- (NSXMLDTDNode *) elementDeclarationForName:(NSString *)name
{
	TODO; // -[NSXMLDTD elementDeclarationForName:]
	return nil;
}

- (NSXMLDTDNode *) attributeDeclarationForName:(NSString *)name elementName:(NSString *)elName
{
	TODO; // -[NSXMLDTD attributeDeclarationForName:elementName:]
	return nil;
}

- (NSXMLDTDNode *) entityDeclarationForName:(NSString *)name
{
	TODO; // -[NSXMLDTD entityDeclarationForName:]
	return nil;
}

- (NSXMLDTDNode *) notationDeclarationForName:(NSString *)name
{
	TODO; // -[NSXMLDTD notationDeclarationForName:]
	return nil;
}


@end
