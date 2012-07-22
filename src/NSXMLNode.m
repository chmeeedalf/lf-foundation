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

#include <libxml/xmlsave.h>

#import <Foundation/NSXMLNode.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
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
	switch (kind)
	{
		case NSXMLInvalidKind:
			nodePtr = xmlNewNode(NULL, NULL);
			break;
		case NSXMLDocumentKind:
			nodePtr = (xmlNodePtr)xmlNewDoc((xmlChar *)"1.0");
			break;
		case NSXMLElementKind:
			nodePtr = xmlNewNode(NULL, NULL);
			break;
		case NSXMLAttributeKind:
			nodePtr = (xmlNodePtr)xmlNewProp(NULL, NULL, NULL);
			break;
		case NSXMLNamespaceKind:
			nodePtr = (xmlNodePtr)xmlNewNs(NULL, NULL, NULL);
			break;
		case NSXMLProcessingInstructionKind:
			nodePtr = (xmlNodePtr)xmlNewPI(NULL, NULL);
			break;
		case NSXMLCommentKind:
			nodePtr = (xmlNodePtr)xmlNewComment(NULL);
			break;
		case NSXMLTextKind:
			nodePtr = xmlNewText("");
			break;
		case NSXMLDTDKind:
			nodePtr = (xmlNodePtr)xmlNewDtd(NULL, NULL, NULL, NULL);
			break;
		case NSXMLEntityDeclarationKind:
			nodePtr = (xmlNodePtr)xmlNewEntity(NULL, NULL, 0, NULL, NULL, NULL);
			break;
		case NSXMLAttributeDeclarationKind:
			nodePtr = xmlMalloc(sizeof(xmlAttribute));
			memset(nodePtr, 0, sizeof(xmlAttribute));
			nodePtr->type = XML_ATTRIBUTE_DECL;
			break;
		case NSXMLElementDeclarationKind:
			nodePtr = xmlMalloc(sizeof(xmlElement));
			memset(nodePtr, 0, sizeof(xmlElement));
			nodePtr->type = XML_ELEMENT_DECL;
			break;
		case NSXMLNotationDeclarationKind:
			nodePtr = xmlNewNode(NULL, NULL);
			nodePtr->type = XML_NOTATION_NODE;
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
	dispatch_once_t predefNSonce;
	static NSDictionary *predefNamespaces;

	dispatch_once(&predefNSonce,^{
			// Namespace prefixes taken from
			// http://services.data.gov/sparql?nsdecl
			predefNamespaces = @{
			@"bif": [NSXMLNode namespaceWithName:@"bif"
				stringValue:@"bif:"],
			@"dawgt": [NSXMLNode namespaceWithName:@"dawgt"
				stringValue:@"http://www.w3.org/2001/sw/DataAccess/tests/test-dawg#"],
			@"dbpedia": [NSXMLNode namespaceWithName:@"dbpedia"
				stringValue:@"http://dbpedia.org/resource/"],
			@"dbpprop": [NSXMLNode namespaceWithName:@"dbpprop"
				stringValue:@"http://dbpedia.org/property/"],
			@"dc": [NSXMLNode namespaceWithName:@"dc"
				stringValue:@"http://purl.org/dc/elements/1.1/"],
			@"fn": [NSXMLNode namespaceWithName:@"fn"
				stringValue:@"http://www.w3.org/2005/xpath-functions/#"],
			@"foaf": [NSXMLNode namespaceWithName:@"foaf"
				stringValue:@"http://xmlns.com/foaf/0.1/"],
			@"geo": [NSXMLNode namespaceWithName:@"geo"
				stringValue:@"http://www.w3.org/2003/01/geo/wgs84_pos#"],
			@"math": [NSXMLNode namespaceWithName:@"math"
				stringValue:@"http://www.w3.org/2000/10/swap/math#"],
			@"mesh": [NSXMLNode namespaceWithName:@"mesh"
				stringValue:@"http://purl.org/commons/record/mesh/"],
			@"mf": [NSXMLNode namespaceWithName:@"mf"
				stringValue:@"http://www.w3.org/2001/sw/dataAccess/tests/test-manifest#"],
			@"nci": [NSXMLNode namespaceWithName:@"nci"
				stringValue:@"http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#"],
			@"obo": [NSXMLNode namespaceWithName:@"obo"
				stringValue:@"http://www.geneontology.org/formats/oboInOwl#"],
			@"owl": [NSXMLNode namespaceWithName:@"owl"
				stringValue:@"http://www.w3.org/2002/07/owl#"],
			@"product": [NSXMLNode namespaceWithName:@"product"
				stringValue:@"http://www.buy.com/rss/module/productV2/"],
			@"protseq": [NSXMLNode namespaceWithName:@"protseq"
				stringValue:@"http://purl.org/science/protein/bysequence/"],
			@"rdf": [NSXMLNode namespaceWithName:@"rdf"
				stringValue:@"http://www.w3.org/1999/02/22-rdf-syntax-ns#"],
			@"rdfa": [NSXMLNode namespaceWithName:@"rdfa"
				stringValue:@"http://www.w3.org/ns/rdfa#"],
			@"rdfdf": [NSXMLNode namespaceWithName:@"rdfdf"
				stringValue:@"http://www.openlinksw.com/virtrdf-data-formats#"],
			@"rdfs": [NSXMLNode namespaceWithName:@"rdfs"
				stringValue:@"http://www.w3.org/2000/01/rdf-schema#"],
			@"sc": [NSXMLNode namespaceWithName:@"sc"
				stringValue:@"http://purl.org/science/owl/sciencecommons/"],
			@"scovo": [NSXMLNode namespaceWithName:@"scovo"
				stringValue:@"http://purl.org/NET/scovo#"],
			@"sioc": [NSXMLNode namespaceWithName:@"sioc"
				stringValue:@"http://rdfs.org/sioc/ns#"],
			@"skos": [NSXMLNode namespaceWithName:@"skos"
				stringValue:@"http://www.w3.org/2004/02/skos/core#"],
			@"sql": [NSXMLNode namespaceWithName:@"sql"
				stringValue:@"sql:"],
			@"vcard": [NSXMLNode namespaceWithName:@"vcard"
				stringValue:@"http://www.w3.org/2001/vcard-rdf/3.0#"],
			@"vcard2006": [NSXMLNode namespaceWithName:@"vcard2006"
				stringValue:@"http://www.w3.org/2006/vcard/ns#"],
			@"virtcxml": [NSXMLNode namespaceWithName:@"virtcxml"
				stringValue:@"http://www.openlinksw.com/schemas/virtcxml#"],
			@"virtrdf": [NSXMLNode namespaceWithName:@"virtrdf"
				stringValue:@"http://www.openlinksw.com/schemas/virtrdf#"],
			@"void": [NSXMLNode namespaceWithName:@"void"
				stringValue:@"http://rdfs.org/ns/void#"],
			@"xf": [NSXMLNode namespaceWithName:@"xf"
				stringValue:@"http://www.w3.org/2004/07/xpath-functions"],
			@"xml": [NSXMLNode namespaceWithName:@"xml"
				stringValue:@"http://www.w3.org/XML/1998/namespace"],
			@"xsd": [NSXMLNode namespaceWithName:@"xsd"
				stringValue:@"http://www.w3.org/2001/XMLSchema#"],
			@"xsl10": [NSXMLNode namespaceWithName:@"xsl10"
				stringValue:@"http://www.w3.org/XSL/Transform/1.0"],
			@"xsl1999": [NSXMLNode namespaceWithName:@"xsl1999"
				stringValue:@"http://www.w3.org/1999/XSL/Transform"],
			@"xslwd": [NSXMLNode namespaceWithName:@"xslwd"
				stringValue:@"http://www.w3.org/TR/WD-xsl"],
			@"yago": [NSXMLNode namespaceWithName:@"yago"
				stringValue:@"http://dbpedia.org/class/yago/"],
			};
	});

	return [predefNamespaces[prefix] copy];
}

+ (id) processingInstructionWithName:(NSString *)name stringValue:(NSString *)string
{
	id ret = [[self alloc] initWithKind:NSXMLProcessingInstructionKind];
	[ret setName:name];
	[ret setStringValue:string];
	return ret;
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
	xmlChar *content = xmlNodeGetContent(nodePtr);
	NSString *ret;

	if (content == NULL)
		return nil;

	ret = [NSString stringWithUTF8String:content];
	xmlFree(content);
	return ret;
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
	return xmlChildElementCount(nodePtr);
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
	int saveOpts = XML_SAVE_AS_XML;
	xmlBufferPtr buf = xmlBufferCreate();
	xmlSaveCtxtPtr saveCtx;
	NSString *ret = nil;

	if (options & NSXMLNodePrettyPrint)
		saveOpts |= XML_SAVE_FORMAT;
	if (options & NSXMLNodeCompactEmptyElement)
		saveOpts |= XML_SAVE_NO_EMPTY;
	if (options & NSXMLNodePreserveWhitespace)
		saveOpts |= XML_SAVE_WSNONSIG;
	saveCtx = xmlSaveToBuffer(buf, "utf-8", saveOpts);

	if (saveCtx != NULL)
	{
		long len = xmlSaveTree(saveCtx, nodePtr);
		if (len >= 0)
		{
			ret = [NSString stringWithUTF8String:xmlBufferContent(buf)];
		}
	}
	xmlBufferFree(buf);
	return ret;
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
	return [self objectsForXQuery:xpath constants:nil error:errp];
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
	if (nodePtr->name == NULL)
		return nil;
	return [NSString stringWithUTF8String:nodePtr->name];
}

+ (NSString *) localNameForName:(NSString *)name
{
	const xmlChar *locName = [name UTF8String];
	int len;

	locName = xmlSplitQName3(locName, &len);
	return [NSString stringWithUTF8String:locName];
}

- (NSString *) prefix
{
	if (nodePtr == NULL || nodePtr->ns == NULL || nodePtr->ns->prefix == NULL)
		return nil;
	return [NSString stringWithUTF8String:nodePtr->ns->prefix];
}

+ (NSString *) prefixForName:(NSString *)name
{
	const xmlChar *locName = [name UTF8String];
	xmlChar *splitName;
	xmlChar *prefix;
	NSString *ret;

	splitName = xmlSplitQName2(locName, &prefix);
	ret = [NSString stringWithUTF8String:prefix];

	xmlFree(splitName);
	xmlFree(prefix);
	return ret;
}

- (id) copyWithZone:(NSZone *)zone
{
	TODO; // -[NSXMLNode copyWithZone:]
	return nil;
}

@end
