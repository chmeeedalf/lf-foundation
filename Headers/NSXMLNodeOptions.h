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

#ifndef NSXMLNODEOPTIONS_H
#define NSXMLNODEOPTIONS_H

enum
{
	NSXMLNodeOptionsNone = 0,
	NSXMLNodeIsCDATA = 1 << 0,
	NSXMLNodeExpandEmptyElement = 1 << 1, // <a></a>
	NSXMLNodeCompactEmptyElement = 1 << 2, // <a/>
	NSXMLNodeUseSingleQuotes = 1 << 3,
	NSXMLNodeUseDoubleQuotes = 1 << 4,
	NSXMLDocumentTidyHTML = 1 << 9,
	NSXMLDocumentTidyXML = 1 << 10,
	NSXMLDocumentValidate = 1 << 13,
	NSXMLNodeLoadExternalEntitiesAlways = 1 << 14,
	NSXMLNodeLoadExternalEntitiesSameOriginOnly = 1 << 14,
	NSXMLNodeLoadExternalEntitiesNever = 1 << 19,
	NSXMLDocumentXInclude = 1 << 16,
	NSXMLNodePrettyPrint = 1 << 17,
	NSXMLDocumentIncludeContentTypeDeclaration = 1 << 18,
	NSXMLNodePreserveNamespaceOrder = 1 << 20,
	NSXMLNodePreserveAttributeOrder = 1 << 21,
	NSXMLNodePreserveEntities = 1 << 22,
	NSXMLNodePreservePrefixes = 1 << 23,
	NSXMLNodePreserveCDATA = 1 << 24,
	NSXMLNodePreserveWhitespace = 1 << 25,
	NSXMLNodePreserveDTD = 1 << 26,
	NSXMLNodePreserveCharacterReferences = 1 << 27,
	NSXMLNodePreserveEmptyElements = 
		(NSXMLNodeExpandEmptyElement | NSXMLNodeCompactEmptyElement),
	NSXMLNodePreserveQuotes =
		(NSXMLNodeUseSingleQuotes | NSXMLNodeUseDoubleQuotes),
	NSXMLNodePreserveAll = 
		(
		 NSXMLNodePreserveNamespaceOrder |
		 NSXMLNodePreserveAttributeOrder |
		 NSXMLNodePreserveEntities |
		 NSXMLNodePreservePrefixes |
		 NSXMLNodePreserveCDATA |
		 NSXMLNodePreserveEmptyElements |
		 NSXMLNodePreserveQuotes |
		 NSXMLNodePreserveWhitespace |
		 NSXMLNodePreserveDTD |
		 NSXMLNodePreserveCharacterReferences |
		 0xFFF00000)
};

#endif
