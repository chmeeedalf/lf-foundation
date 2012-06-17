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

#import <Foundation/NSObject.h>

enum
{
	NSXMLInvalidKind = 0,
	NSXMLDocumentKind,
	NSXMLElementKind,
	NSXMLAttributeKind,
	NSXMLNamespaceKind,
	NSXMLProcessingInstructionKind,
	NSXMLCommentKind,
	NSXMLTextKind,
	NSXMLDTDKind,
	NSXMLEntityDeclarationKind,
	NSXMLAttributeDeclarationKind,
	NSXMLElementDeclarationKind,
	NSXMLNotationDeclarationKind,
};
typedef NSUInteger NSXMLNodeKind;

@class NSArray, NSDictionary;
@class NSError;
@class NSXMLDocument, NSXMLElement;

@interface NSXMLNode	:	NSObject<NSCopying>
- (id) initWithKind:(NSXMLNodeKind)kind;
- (id) initWithKind:(NSXMLNodeKind)kind options:(NSUInteger)options;
+ (id) document;
+ (id) documentWithRootElement:(NSXMLElement *)root;
+ (id) elementWithName:(NSString *)name;
+ (id) elementWithName:(NSString *)name children:(NSArray *)children attributes:(NSArray *)attributes;
+ (id) elementWithName:(NSString *)name stringValue:(NSString *)string;
+ (id) elementWithName:(NSString *)name URI:(NSString *)URI;
+ (id) attributeWithName:(NSString *)name stringValue:(NSString *)value;
+ (id) attributeWithName:(NSString *)name URI:(NSString *)URI stringValue:(NSString *)value;
+ (id) textWithStringValue:(NSString *)string;
+ (id) commentWithStringValue:(NSString *)string;
+ (id) namespaceWithName:(NSString *)name stringValue:(NSString *)string;
+ (id) DTDNodeWithXMLString:(NSString *)string;
+ (id) predefinedNamespaceForPrefix:(NSString *)prefix;
+ (id) processingInstructionWithName:(NSString *)name stringValue:(NSString *)string;

- (NSUInteger) index;
- (NSXMLNodeKind) kind;
- (NSUInteger) level;
- (void) setName:(NSString *)name;
- (NSString *) name;
- (void) setObjectValue:(id)value;
- (id) objectValue;
- (void) setStringValue:(NSString *)string;
- (void) setStringValue:(NSString *)string resolvingEntities:(bool)resolve;
- (NSString *) stringValue;
- (void) setURI:(NSString *)URI;
- (NSString *) URI;

- (NSXMLDocument *) rootDocument;
- (NSXMLNode *) parent;
- (NSXMLNode *) childAtIndex:(NSUInteger)index;
- (NSUInteger) childCount;
- (NSArray *) children;
- (NSXMLNode *) nextNode;
- (NSXMLNode *) nextSibling;
- (NSXMLNode *) previousNode;
- (NSXMLNode *) previousSibling;
- (void) detach;

- (NSString *) XMLString;
- (NSString *) XMLStringWithOptions:(NSUInteger)options;
- (NSString *) canonicalXMLStringPreservingComments:(bool)comments;
- (NSString *) description;

- (NSArray *) nodesForXPath:(NSString *)xpath error:(NSError **)errp;
- (NSArray *) objectsForXQuery:(NSString *)xpath error:(NSError **)errp;
- (NSArray *) objectsForXQuery:(NSString *)xpath constants:(NSDictionary *)constants error:(NSError **)errp;
- (NSString *) XPath;

- (NSString *) localName;
+ (NSString *) localNameForName:(NSString *)name;
- (NSString *) prefix;
+ (NSString *) prefixForName:(NSString *)name;

@end
