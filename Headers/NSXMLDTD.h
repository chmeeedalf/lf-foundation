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

@interface NSXMLDTD	:	NSXMLNode

- (id) initWithContentsOfURL:(NSURL *)url options:(NSUInteger)options error:(NSError **)errp;
- (id) initWithData:(NSData *)data options:(NSUInteger)options error:(NSError **)errp;

- (void) setPublicID:(NSString *)publicID;
- (NSString *) publicID;
- (void) setSystemID:(NSString *)systemID;
- (NSString *) systemID;

- (void) addChild:(NSXMLNode *)child;
- (void) insertChild:(NSXMLNode *)child atIndex:(NSUInteger)index;
- (void) insertChildren:(NSArray *)children atIndex:(NSUInteger)index;
- (void) removeChildAtIndex:(NSUInteger)index;
- (void) replaceChildAtIndex:(NSUInteger)index withNode:(NSXMLNode *)newChild;
- (void) setChildren:(NSArray *)newChildren;

+ (NSXMLDTDNode *) predefinedEntityDeclarationForName:(NSString *)name;
- (NSXMLDTDNode *) elementDeclarationForName:(NSString *)name;
- (NSXMLDTDNode *) attributeDeclarationForName:(NSString *)name elementName:(NSString *)elName;
- (NSXMLDTDNode *) entityDeclarationForName:(NSString *)name;
- (NSXMLDTDNode *) notationDeclarationForName:(NSString *)name;

@end
