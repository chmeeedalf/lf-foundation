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
#import "internal.h"

@implementation NSXMLElement

- (id) initWithName:(NSString *)name
{
	TODO;	// -[NSXMLElement initWithName:]
	return self;
}

- (id) initWithName:(NSString *)name stringValue:(NSString *)string
{
	TODO;	// -[NSXMLElement initWithName:stringValue:]
	return self;
}

- (id) initWithXMLString:(NSString *)string error:(NSString **)errp
{
	TODO;	// -[NSXMLElement initWithXMLString:error:]
	return self;
}

- (id) initWithName:(NSString *)name URI:(NSString *)URI
{
	TODO;	// -[NSXMLElement initWithName:URI:]
	return self;
}


- (NSArray *) elementsForName:(NSString *)name
{
	TODO;	// -[NSXMLElement elementsForName]
	return nil;
}

- (NSArray *) elementsForLocalName:(NSString *)name URI:(NSString *)URI
{
	TODO;	// -[NSXMLElement elementsForLocalName:URI:]
	return nil;
}


- (void) addChild:(NSXMLNode *)child
{
	TODO;	// -[NSXMLElement addChild:]
}

- (void) insertChild:(NSXMLNode *)child atIndex:(NSUInteger)index
{
	TODO;	// -[NSXMLElement insertChild:atIndex:]
}

- (void) insertChildren:(NSArray *)children atIndex:(NSUInteger)index
{
	TODO;	// -[NSXMLElement insertChildren:atIndex:]
}

- (void) removeChildAtIndex:(NSUInteger)index
{
	TODO;	// -[NSXMLElement removeChildAtIndex:]
}

- (void) replaceChildAtIndex:(NSUInteger)index withNode:(NSXMLNode *)newChild
{
	TODO;	// -[NSXMLElement replaceChildAtIndex:withNode:]
}

- (void) setChildren:(NSArray *)newChildren
{
	TODO;	// -[NSXMLElement setChildren:]
}


- (void) addAttribute:(NSXMLNode *)attribute
{
	TODO;	// -[NSXMLElement addAttribute:]
}

- (NSXMLNode *) attributeForName:(NSString *)name
{
	TODO;	// -[NSXMLElement attributeForName:]
	return nil;
}

- (NSXMLNode *) attributeForLocalName:(NSString *)name URI:(NSString *)URI
{
	TODO;	// -[NSXMLElement attributeForLocalName:URI:]
	return nil;
}

- (NSArray *) attributes
{
	TODO;	// -[NSXMLElement attributes]
	return nil;
}

- (void) removeAttributeForName:(NSString *)name
{
	TODO;	// -[NSXMLElement removeAttributeForName:]
}

- (void) setAttributes:(NSArray *)attributes
{
	TODO;	// -[NSXMLElement setAttributes:]
}

- (void) setAttributesWithDictionary:(NSDictionary *)attributes
{
	TODO;	// -[NSXMLElement setAttributesWithDictionary:]
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
	return nil;
}

- (void) removeNamespaceForPrefix:(NSString *)prefix
{
	TODO;	// -[NSXMLElement removeNamespaceForPrefix:]
}

- (NSXMLNode *) resolveNamespaceForName:(NSString *)name
{
	TODO;	// -[NSXMLElement resolveNamespaceForName:]
	return nil;
}

- (NSString *) resolvePrefixForNamespaceURI:(NSString *)namespaceURI
{
	TODO;	// -[NSXMLElement resolvePrefixForNamespaceURI:]
	return nil;
}

- (void) setNamespaces:(NSArray *)namespaces
{
	TODO;	// -[NSXMLElement setNamespaces:]
}


@end
