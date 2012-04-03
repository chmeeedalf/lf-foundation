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

typedef NSUInteger NSXMLDTDNodeKind;
enum
{
	NSXMLEntityGeneralKind = 1,
	NSXMLEntityParserKind,
	NSXMLEntityUnparsedKind,
	NSXMLEntityParameterKind,
	NSXMLEntityPredefinedKind,

	NSXMLAttributeCDATAKind,
	NSXMLAttributeIDKind,
	NSXMLAttributeIDRefKind,
	NSXMLAttributeIDRefsKind,
	NSXMLAttributeEntityKind,
	NSXMLAttributeEntitiesKind,
	NSXMLAttributeNMTokenKind,
	NSXMLAttributeNMTokensKind,
	NSXMLAttributeEnumerationKind,
	NSXMLAttributeNotationKind,

	NSXMLElementDeclarationUndefinedKind,
	NSXMLElementDeclarationEmptyKind,
	NSXMLElementDeclarationAnyKind,
	NSXMLElementDeclarationMixedKind,
	NSXMLElementDeclarationElementKind,
};

@interface NSXMLDTDNode	:	NSXMLNode

- (id) initWithXMLString:(NSString *)string;

- (NSXMLDTDNodeKind) DTDKind;
- (void) setDTDKind:(NSXMLDTDNodeKind)kind;

- (bool) isExternal;
- (void) setNotationName:(NSString *)notationName;
- (NSString *) notationName;
- (void) setPublicID:(NSString *)publicID;
- (NSString *) publicID;
- (void) setSystemID:(NSString *)systemID;
- (NSString *) systemID;

@end
