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

#import <Foundation/NSXMLDocument.h>

#import <Foundation/NSData.h>
#import "internal.h"

@implementation NSXMLDocument
- (id) initWithContentsOfURL:(NSURL *)url options:(NSUInteger)mask error:(NSError **)errp
{
	return [self initWithData:[NSData dataWithContentsOfURL:url] options:mask error:errp];
}

- (id) initWithData:(NSData *)data options:(NSUInteger)mask error:(NSError **)errp
{
	TODO;	// -[NSXMLDocument initWithData:options:error:]
	return self;
}

- (id) initWithRootElement:(NSXMLElement *)root
{
	TODO;	// -[NSXMLDocument initWithRootElement:]
	return self;
}

- (id) initWithXMLString:(NSString *)string options:(NSUInteger)mask error:(NSError **)errp
{
	TODO;	// -[NSXMLDocument initWithXMLString:options:error:]
	return self;
}

+ (Class) replacementClassForClass:(Class)cls
{
	TODO;	// -[NSXMLDocument replacementClassForClass:]
	return Nil;
}


- (NSString *) characterEncoding
{
	TODO;	// -[NSXMLDocument characterEncoding]
	return nil;
}

- (void) setCharacterEncoding:(NSString *)encoding
{
	TODO;	// -[NSXMLDocument setCharacterEncoding:]
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
	TODO;	// -[NSXMLDocument DTD]
	return nil;
}

- (void) setDTD:(NSXMLDTD *)dtd
{
	TODO;	// -[NSXMLDocument setDTD:]
}

- (bool) isStandalone
{
	TODO;	// -[NSXMLDocument isStandalone]
	return false;
}

- (void) setStandalone:(bool)standalone
{
	TODO;	// -[NSXMLDocument setStandalone:]
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
	TODO; 	// -[NSXMLDocument URI]
	return nil;
}

- (void) setURI:(NSString *)newURI
{
	TODO; 	// -[NSXMLDocument setURI:]
}

- (NSString *) version
{
	TODO; 	// -[NSXMLDocument version]
	return nil;
}

- (void) setVersion:(NSString *)newVers
{
	TODO; 	// -[NSXMLDocument setVersion:]
}


- (NSXMLElement *) rootElement
{
	TODO; 	// -[NSXMLDocument rootElement]
	return nil;
}

- (void) setRootElement:(NSXMLElement *)newRoot
{
	TODO; 	// -[NSXMLDocument setRootElement:]
}


- (void) addChild:(NSXMLNode *)child
{
	TODO; 	// -[NSXMLDocument addChild:]
}

- (void) insertChild:(NSXMLNode *)child atIndex:(NSUInteger)index
{
	TODO; 	// -[NSXMLDocument insertChild:atIndex:]
}

- (void) insertChildren:(NSArray *)children atIndex:(NSUInteger)index
{
	TODO; 	// -[NSXMLDocument insertChildren:atIndex:]
}

- (void) removeChildAtIndex:(NSUInteger)index
{
	TODO; 	// -[NSXMLDocument removeChildAtIndex:]
}

- (void) replaceChildAtIndex:(NSUInteger)index withNode:(NSXMLNode *)newChild
{
	TODO; 	// -[NSXMLDocument replaceChildAtIndex:withNode:]
}

- (void) setChildren:(NSArray *)newChildren
{
	TODO; 	// -[NSXMLDocument setChildren:]
}


- (id) objectByApplyingXSLT:(NSData *)xslt arguments:(NSDictionary *)args error:(NSError **)errp
{
	TODO; 	// -[NSXMLDocument objectByApplyingXSLT:arguments:error:]
	return nil;
}

- (id) objectByApplyingXSLTString:(NSString *)xslt arguments:(NSDictionary *)args error:(NSError **)errp
{
	TODO; 	// -[NSXMLDocument objectByApplyingXSLTString:arguments:error:]
	return nil;
}

- (id) objectByApplyingXSLTAtURL:(NSURL *)xsltURL arguments:(NSDictionary *)args error:(NSError **)errp
{
	TODO; 	// -[NSXMLDocument objectByApplyingXSLTAtURL:arguments:error:]
	return nil;
}


- (NSData *) XMLData
{
	TODO; 	// -[NSXMLDocument XMLData]
	return nil;
}

- (NSData *) XMLDataWithOptions:(NSUInteger)options
{
	TODO; 	// -[NSXMLDocument XMLDataWithOptions:]
	return nil;
}


- (bool) validateAndReturnError:(NSError **)errp
{
	TODO; 	// -[NSXMLDocument validateAndReturnError:]
	return false;
}


@end
