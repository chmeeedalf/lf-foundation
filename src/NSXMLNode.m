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

#import <Foundation/NSXMLNode.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSXMLDocument.h>
#import <Foundation/NSXMLDTDNode.h>
#import <Foundation/NSXMLElement.h>
#import <Foundation/NSXMLNodeOptions.h>
#import "internal.h"

@implementation NSXMLNode
{
	NSUInteger nodeKind;
}

- (id) init
{
	return [self initWithKind:NSXMLInvalidKind];
}

- (id) initWithKind:(NSXMLNodeKind)kind
{
	return [self initWithKind:kind options:NSXMLNodeOptionsNone];
}

- (id) initWithKind:(NSXMLNodeKind)kind options:(NSUInteger)options
{
	TODO; // -[NSXMLNode initWithKind:options:]
	switch (kind)
	{
		case NSXMLInvalidKind:
			break;
		case NSXMLDocumentKind:
			break;
		case NSXMLElementKind:
			break;
		case NSXMLAttributeKind:
			nodePtr = (xmlNodePtr)xmlNewProp(NULL, "", "");
			break;
		case NSXMLNamespaceKind:
			break;
		case NSXMLProcessingInstructionKind:
			break;
		case NSXMLCommentKind:
			break;
		case NSXMLTextKind:
			break;
		case NSXMLDTDKind:
			break;
		case NSXMLEntityDeclarationKind:
			break;
		case NSXMLAttributeDeclarationKind:
			break;
		case NSXMLElementDeclarationKind:
			break;
		case NSXMLNotationDeclarationKind:
			break;
	};
	
	// Weakly reference self
	nodePtr->_private = (__bridge void *)self;
	nodeKind = kind;
	return self;
}

- (void) dealloc
{
	xmlFreeNode(nodePtr);
}

+ (id) document
{
	return [[NSXMLDocument alloc] initWithData:nil options:NSXMLNodeOptionsNone error:NULL];
}

+ (id) documentWithRootElement:(NSXMLElement *)root
{
	return [[NSXMLDocument alloc] initWithRootElement:root];
}

+ (id) elementWithName:(NSString *)name
{
	return [[NSXMLElement alloc] initWithName:name];
}

+ (id) elementWithName:(NSString *)name children:(NSArray *)children attributes:(NSArray *)attributes
{
	id element = [[NSXMLElement alloc] initWithName:name];
	[element setAttributes:attributes];
	[element setChildren:children];

	return element;
}

+ (id) elementWithName:(NSString *)name stringValue:(NSString *)string
{
	id ret = [[self alloc] initWithKind:NSXMLElementKind];
	[ret setName:name];
	[ret setStringValue:string];
	return ret;
}

+ (id) elementWithName:(NSString *)name URI:(NSString *)URI
{
	id ret = [[self alloc] initWithKind:NSXMLElementKind];
	[ret setName:name];
	[ret setURI:URI];
	return ret;
}

+ (id) attributeWithName:(NSString *)name stringValue:(NSString *)value
{
	id ret = [[self alloc] initWithKind:NSXMLAttributeKind];
	[ret setName:name];
	[ret setStringValue:value];
	return ret;
}

+ (id) attributeWithName:(NSString *)name URI:(NSString *)URI stringValue:(NSString *)value
{
	id ret = [[self alloc] initWithKind:NSXMLAttributeKind];
	[ret setName:name];
	[ret setURI:URI];
	[ret setStringValue:value];
	return ret;
}

+ (id) textWithStringValue:(NSString *)string
{
	id ret = [[self alloc] initWithKind:NSXMLTextKind];
	[ret setStringValue:string];
	return ret;
}

+ (id) commentWithStringValue:(NSString *)string
{
	id ret = [[self alloc] initWithKind:NSXMLCommentKind];
	[ret setStringValue:string];
	return ret;
}

+ (id) namespaceWithName:(NSString *)name stringValue:(NSString *)string
{
	id ret = [[self alloc] initWithKind:NSXMLNamespaceKind];
	[ret setName:name];
	[ret setStringValue:string];
	return ret;
}

+ (id) DTDNodeWithXMLString:(NSString *)string
{
	return [[NSXMLDTDNode alloc] initWithXMLString:string];
}

+ (id) predefinedNamespaceForPrefix:(NSString *)prefix
{
	TODO; // +[NSXMLNode predefinedNamespaceForPrefix:]
	return nil;
}

+ (id) processingInstructionWithName:(NSString *)name stringValue:(NSString *)string
{
	TODO; // +[NSXMLNode processingInstructionWithName:stringValue:]
	return nil;
}


- (NSUInteger) index
{
	NSUInteger i = 0;
	xmlNodePtr ptr = nodePtr;

	if (nodePtr == NULL)
		return 0;

	while (ptr->prev != NULL)
	{
		i++;
		ptr = ptr->prev;
	}
	return i;
}

- (NSXMLNodeKind) kind
{
	return nodeKind;
}

- (NSUInteger) level
{
	xmlNodePtr ptr = nodePtr;
	NSUInteger level = 0;

	while (ptr->parent != NULL)
	{
		level++;
		ptr = ptr->parent;
	}
	return level;
}

- (void) setName:(NSString *)name
{
	xmlNodeSetName(nodePtr, [name UTF8String]);
}

- (NSString *) name
{
	return [NSString stringWithUTF8String:nodePtr->name];
}

- (void) setObjectValue:(id)value
{
	TODO; // -[NSXMLNode setObjectValue:]
}

- (id) objectValue
{
	TODO; // -[NSXMLNode objectValue]
	return nil;
}

- (void) setStringValue:(NSString *)string
{
	[self setStringValue:string resolvingEntities:false];
}

- (void) setStringValue:(NSString *)string resolvingEntities:(bool)resolve
{
	TODO; // -[NSXMLNode setStringValue:resolvingEntities:]
}

- (NSString *) stringValue
{
	TODO; // -[NSXMLNode stringValue]
	return nil;
}

- (void) setURI:(NSString *)URI
{
	xmlNodeSetBase(nodePtr, [URI UTF8String]);
}

- (NSString *) URI
{
	xmlChar *base = xmlNodeGetBase(NULL, nodePtr);

	if (base != NULL)
	{
		NSString *ret;

		ret = [NSString stringWithUTF8String:base];
		xmlFree(base);

		return ret;
	}
	return nil;
}


- (NSXMLDocument *) rootDocument
{
	xmlDocPtr doc = nodePtr->doc;

	if (doc == NULL)
		return nil;

	return (__bridge id)doc->_private;
}

- (NSXMLNode *) parent
{
	xmlNodePtr parent = nodePtr->parent;

	if (parent == NULL)
		return nil;

	return (__bridge id)parent->_private;
}

- (NSXMLNode *) childAtIndex:(NSUInteger)index
{
	xmlNodePtr child = nodePtr->children;

	while (child != NULL)
	{
		--index;
		child = child->next;
	}
	if (index != 0)
	{
		@throw [NSRangeException exceptionWithReason:@"Index out of bounds" userInfo:nil];
	}
	return (__bridge id)child->_private;
}

- (NSUInteger) childCount
{
	NSUInteger childCount = 0;
	xmlNodePtr child = nodePtr->children;

	while (child != NULL)
	{
		childCount++;
		child = child->next;
	}

	return childCount;
}

- (NSArray *) children
{
	NSMutableArray *children = [NSMutableArray new];
	xmlNodePtr child = nodePtr->children;

	while (child != NULL)
	{
		[children addObject:(__bridge id)child->_private];
		child = child->next;
	}

	return [children copy];
}

- (NSXMLNode *) nextNode
{
	if (nodePtr->children != NULL)
	{
		return (__bridge id)nodePtr->children->_private;
	}
	else if (nodePtr->next != NULL)
	{
		return (__bridge id)nodePtr->next->_private;
	}
	else if (nodePtr->parent != NULL && nodePtr->parent->next != NULL)
	{
		return (__bridge id)nodePtr->parent->next->_private;
	}
	return nil;
}

- (NSXMLNode *) nextSibling
{
	if (nodePtr->next == NULL)
		return nil;

	return (__bridge id)nodePtr->next->_private;
}

- (NSXMLNode *) previousNode
{
	if (nodePtr->last != NULL)
	{
		return (__bridge id)nodePtr->last->_private;
	}
	else if (nodePtr->prev != NULL)
	{
		return (__bridge id)nodePtr->prev->_private;
	}
	else if (nodePtr->parent != NULL && nodePtr->parent->prev != NULL)
	{
		return (__bridge id)nodePtr->parent->prev->_private;
	}
	return nil;
}

- (NSXMLNode *) previousSibling
{
	if (nodePtr->next == NULL)
		return nil;

	return (__bridge id)nodePtr->next->_private;
}

- (void) detach
{
	xmlUnlinkNode(nodePtr);
}


- (NSString *) XMLString
{
	return [self XMLStringWithOptions:NSXMLNodeOptionsNone];
}

- (NSString *) XMLStringWithOptions:(NSUInteger)options
{
	TODO; // -[NSXMLNode XMLStringWithOptions:]
	return nil;
}

- (NSString *) canonicalXMLStringPreservingComments:(bool)comments
{
	TODO; // -[NSXMLNode canonicalXMLStringPreservingComments:]
	return nil;
}

- (NSString *) description
{
	TODO; // -[NSXMLNode description]
	return nil;
}


- (NSArray *) nodesForXPath:(NSString *)xpath error:(NSError **)errp
{
	TODO; // -[NSXMLNode nodesForXPath:error:]
	return nil;
}

- (NSArray *) objectsForXQuery:(NSString *)xpath error:(NSError **)errp
{
	TODO; // -[NSXMLNode objectsForXQuery:error:]
	return nil;
}

- (NSArray *) objectsForXQuery:(NSString *)xpath constants:(NSDictionary *)constants error:(NSError **)errp
{
	TODO; // -[NSXMLNode objectsForXQuery:constants:error:]
	return nil;
}

- (NSString *) XPath
{
	xmlChar *path = xmlGetNodePath(nodePtr);

	if (path == NULL)
		return nil;
	
	NSString *ret = [NSString stringWithUTF8String:path];
	xmlFree(path);
	return ret;
}


- (NSString *) localName
{
	TODO; // -[NSXMLNode localName]
	return nil;
}

+ (NSString *) localNameForName:(NSString *)name
{
	TODO; // +[NSXMLNode localNameForName]
	return nil;
}

- (NSString *) prefix
{
	TODO; // -[NSXMLNode prefix]
	return nil;
}

+ (NSString *) prefixForName:(NSString *)name
{
	TODO; // -[NSXMLNode prefixForName:]
	return nil;
}

- (id) copyWithZone:(NSZone *)zone
{
	TODO; // -[NSXMLNode copyWithZone:]
	return nil;
}

@end
