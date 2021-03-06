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

#import <Foundation/NSXMLElement.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import "internal.h"

@implementation NSXMLElement

- (id) initWithName:(NSString *)name
{
	return [self initWithName:name URI:nil];
}

- (id) initWithName:(NSString *)name stringValue:(NSString *)string
{
	self = [self initWithName:name URI:nil];
	if (self != nil)
	{
		[self setStringValue:string];
	}
	return self;
}

- (id) initWithXMLString:(NSString *)string error:(NSString **)errp
{
	TODO;	// -[NSXMLElement initWithXMLString:error:]
	return self;
}

- (id) initWithName:(NSString *)name URI:(NSString *)URI
{
	if ((self = [self initWithKind:NSXMLElementKind]) != nil)
	{
		[self setName:name];
		if (URI != nil)
		{
			[self setURI:URI];
		}
	}
	return self;
}


- (NSArray *) elementsForName:(NSString *)name
{
	const xmlChar *locName = [name UTF8String];
	xmlChar *splitName;
	xmlChar *prefix;
	NSArray *ret;

	splitName = xmlSplitQName2(locName, &prefix);
	ret = [self elementsForLocalName:[NSString stringWithUTF8String:splitName] URI:[NSString stringWithUTF8String:prefix]];

	xmlFree(splitName);
	xmlFree(prefix);
	return ret;
}

- (NSArray *) elementsForLocalName:(NSString *)name URI:(NSString *)URI
{
	TODO;	// -[NSXMLElement elementsForLocalName:URI:]
	return nil;
}


- (void) addChild:(NSXMLNode *)child
{
	xmlAddChild(nodePtr, child->nodePtr);
}

- (void) insertChild:(NSXMLNode *)child atIndex:(NSUInteger)index
{
	NSParameterAssert(child != nil);
	NSParameterAssert(index <= [self childCount]);
	xmlAddNextSibling([self childAtIndex:index]->nodePtr, child->nodePtr);
}

- (void) insertChildren:(NSArray *)children atIndex:(NSUInteger)index
{
	for (id child in children)
	{
		[self insertChild:child atIndex:index++];
	}
}

- (void) removeChildAtIndex:(NSUInteger)index
{
	NSParameterAssert(index < [self childCount]);
	[[self childAtIndex:index] detach];
}

- (void) replaceChildAtIndex:(NSUInteger)index withNode:(NSXMLNode *)newChild
{
	NSParameterAssert(newChild != nil);
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


- (void) addAttribute:(NSXMLNode *)attribute
{
	NSParameterAssert([attribute kind] == NSXMLAttributeKind);

	if ([self attributeForName:[attribute name]] != nil)
		return;
	[self addChild:attribute];
}

- (NSXMLNode *) attributeForName:(NSString *)name
{
	xmlAttrPtr attr = xmlHasProp(nodePtr, [name UTF8String]);

	if (attr == NULL)
		return nil;

	return (__bridge id)attr->_private;
}

- (NSXMLNode *) attributeForLocalName:(NSString *)name URI:(NSString *)URI
{
	xmlAttrPtr attr = xmlHasNsProp(nodePtr, [name UTF8String], [URI UTF8String]);

	if (attr == NULL)
		return nil;

	return (__bridge id)attr->_private;
}

- (NSArray *) attributes
{
	if (nodePtr->properties != NULL)
	{
		NSMutableArray *attribs = [NSMutableArray new];
		xmlAttrPtr attr = nodePtr->properties;
		while (attr != NULL)
		{
			[attribs addObject:(__bridge id)attr->_private];
		}
		return [attribs copy];
	}
	return nil;
}

- (void) removeAttributeForName:(NSString *)name
{
	[[self attributeForName:name] detach];
}

- (void) setAttributes:(NSArray *)attributes
{
	for (id attrib in [self attributes])
	{
		bool found = false;
		for (id a in attributes)
		{
			if ([[attrib name] isEqualToString:[a name]])
			{
				found = true;
				break;
			}
		}
		if (!found)
		{
			[self removeAttributeForName:[attrib name]];
		}
	}
	for (id attrib in attributes)
	{
		[self addAttribute:attrib];
	}
}

- (void) setAttributesWithDictionary:(NSDictionary *)attributes
{
	NSMutableArray *tmp = [NSMutableArray array];
	[attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, bool *stop)
	{
		NSXMLNode *node = [[NSXMLNode alloc] initWithKind:NSXMLAttributeKind];
		[node setName:key];
		[node setObjectValue:obj];
		[tmp addObject:node];
	}];
	[self setAttributes:tmp];
}


- (void) addNamespace:(NSXMLNode *)namespace
{
	TODO;	// -[NSXMLElement addNamespace:]
}

- (NSArray *) namespaces
{
	TODO;	// -[NSXMLElement namespaces]
	return nil;
}

- (NSXMLNode *) namespaceForPrefix:(NSString *)prefix
{
	TODO;	// -[NSXMLElement namespaceForPrefix:]
	xmlNsPtr ns = xmlSearchNs(nodePtr->doc, nodePtr, [prefix UTF8String]);

	if (ns == NULL)
	{
		return nil;
	}

	return (__bridge id)ns->_private;
}

- (void) removeNamespaceForPrefix:(NSString *)prefix
{
	TODO;	// -[NSXMLElement removeNamespaceForPrefix:]
}

- (NSXMLNode *) resolveNamespaceForName:(NSString *)name
{
	return [self namespaceForPrefix:[[self class] prefixForName:name]];
}

- (NSString *) resolvePrefixForNamespaceURI:(NSString *)namespaceURI
{
	const xmlChar *xmlNs = [namespaceURI UTF8String];

	xmlNsPtr ns = xmlSearchNsByHref(nodePtr->doc, nodePtr, xmlNs);

	if (ns)
	{
		return [NSString stringWithUTF8String:ns->prefix];
	}
	return nil;
}

- (void) setNamespaces:(NSArray *)namespaces
{
	TODO;	// -[NSXMLElement setNamespaces:]
}


@end
