/* $Gold$	*/
/*
 * Copyright (c) 2011	Gold Project
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
 * THIS SOFTWARE IS PROVIDED BY THE PROJECT ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDelegate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURI.h>
#import <Foundation/NSXMLParser.h>
#include <libxml/parser.h>

/* TODO:
 * - Doesn't enforce the shouldResolveExternalEntities, shouldProcessNamespaces,
 *   or shouldReportNamespacePrefixes settings.
 */

static const int BUFFER_SIZE = 8192;	// 8KB buffer size should be sufficient most of the time.
NSMakeSymbol(NSXMLParserErrorDomain);

@implementation NSXMLParser

static void startDocumentHandler(void *ctx)
{
	NSXMLParser *parserObj = ctx;
	[parserObj->delegate parserDidStartDocument:parserObj];
}

static void endDocumentHandler(void *ctx)
{
	NSXMLParser *parserObj = ctx;
	[parserObj->delegate parserDidEndDocument:parserObj];
}

static void startElementNsHandler(void *ctx, const xmlChar *name, const xmlChar *prefix, const xmlChar *URI, int nb_namespace, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes)
{
	NSXMLParser *parser = ctx;
	NSString *ocName = [[NSString alloc] initWithUTF8String:(const char *)name];
	NSString *ocPrefix = [[NSString alloc] initWithUTF8String:(const char *)prefix];
	NSString *ocURI = [[NSString alloc] initWithUTF8String:(const char *)URI];
	NSMutableDictionary *ocAttribs = [NSMutableDictionary new];

	if ([parser shouldReportNamespacePrefixes])
	{
		for (int i = 0; i < nb_namespace; i += 2)
		{
			NSString *ocNSPrefix = [[NSString alloc] initWithUTF8String:(const char *)namespaces[i]];
			NSString *ocNS = [[NSString alloc] initWithUTF8String:(const char *)namespaces[i + 1]];
			[parser->delegate parser:parser didStartMappingPrefix:ocNSPrefix toURI:ocNS];
			[ocNS release];
			[ocNSPrefix release];
		}
	}

	for (int i = 0; i < nb_attributes; i+=5)
	{
		NSString *key = [[NSString alloc] initWithUTF8String:(const char *)attributes[i]];
		NSString *value = [[NSString alloc] initWithBytes:attributes[i+3] length:((size_t)(attributes[i+4] - attributes[i+3])) encoding:NSUTF8StringEncoding];
		[ocAttribs setObject:value forKey:key];
		[value release];
		[key release];
	}
	[parser->delegate parser:parser didStartElement:ocName namespaceURI:ocURI qualifiedName:ocPrefix attributes:ocAttribs];
	[ocAttribs release];
	[ocURI release];
	[ocPrefix release];
	[ocName release];
}

static void endElementNsHandler(void *ctx, const xmlChar *name, const xmlChar *prefix, const xmlChar *URI)
{
	NSXMLParser *parser = ctx;
	NSString *ocName = [[NSString alloc] initWithUTF8String:(const char *)name];
	NSString *ocPrefix = [[NSString alloc] initWithUTF8String:(const char *)prefix];
	NSString *ocURI = [[NSString alloc] initWithUTF8String:(const char *)URI];

	[parser->delegate parser:parser didEndElement:ocName namespaceURI:ocURI qualifiedName:ocPrefix];

	[ocURI release];
	[ocPrefix release];
	[ocName release];
}

static void foundCharactersHandler(void *ctx, const xmlChar *chars, int len)
{
	NSXMLParser *parser = (NSXMLParser *)ctx;
	NSString *nsChars = [[NSString alloc] initWithBytes:chars length:len encoding:NSUTF8StringEncoding];
	[parser->delegate parser:parser foundCharacters:nsChars];
	[nsChars release];
}

static void ignorableWhitespaceHandler(void *ctx, const xmlChar *ch, int len)
{
	NSXMLParser *parser = (NSXMLParser *)ctx;
	NSString *wsChars = [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
	[parser->delegate parser:parser foundIgnorableWhitespace:wsChars];
	[wsChars release];
}

static void processingInstructionHandler(void *ctx, const xmlChar *target, const xmlChar *data)
{
	NSString *nsTarget = [[NSString alloc] initWithUTF8String:(const char *)target];
	NSString *nsData = [[NSString alloc] initWithUTF8String:(const char *)data];
	NSXMLParser *parser = ctx;

	[parser->delegate parser:parser foundProcessingInstructionWithTarget:nsTarget data:nsData];
	[nsTarget release];
	[nsData release];
}

static void commentHandler(void *ctx, const xmlChar *value)
{
	NSXMLParser *parser = ctx;
	NSString *comment = [[NSString alloc] initWithUTF8String:(const char *)value];
	[parser->delegate parser:parser foundComment:comment];
	[comment release];
}

static void cdataHandler(void *ctx, const xmlChar *value, int len)
{
	NSXMLParser *parser = (NSXMLParser *)ctx;
	NSString *wsCDATA = [[NSString alloc] initWithBytes:value length:len encoding:NSUTF8StringEncoding];
	[parser->delegate parser:parser foundIgnorableWhitespace:wsCDATA];
	[wsCDATA release];
}

static void errorHandler(void *ctx, const char *msg, ...)
{
	va_list args;
	NSXMLParser *parser;
	NSString *fmt;
	NSString *errstr;
	xmlError *lastErr;

	parser = ctx;
	lastErr = xmlCtxtGetLastError(parser->parser);
	va_start(args, msg);
	fmt = [[NSString alloc] initWithUTF8String:msg];
	errstr = [[NSString alloc] initWithFormat:fmt arguments:args];
	[fmt release];
	va_end(args);

	parser->error = [[NSError alloc] initWithDomain:NSXMLParserErrorDomain code:lastErr->code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errstr,NSLocalizedDescriptionKey]];

	[parser->delegate parser:parser parseErrorOccurred:parser->error];
	[errstr release];
}

- (id)initWithContentsOfURI:(NSURI *)url
{
	return [self initWithStream:[NSInputStream inputStreamWithURI:url]];
}

- (id) initWithStream:(NSStream *)stream
{
	self = [super init];
	if(self != nil)
	{
		shouldProcessNamespaces = false;
		shouldReportNamespacePrefixes = false;
		
		data = [stream retain];
	}
	return self;
}

- (id)initWithData:(NSData *)new_data
{
	return [self initWithStream:[NSInputStream inputStreamWithData:new_data]];
}

-(void)dealloc
{
	xmlFreeParserCtxt(parser);
	[data release];
	[delegate release];
	//[error release];
	[super dealloc];
}

- (void)setShouldProcessNamespaces:(bool)flag
{
	shouldProcessNamespaces = flag;
}

- (bool)shouldProcessNamespaces
{
	return shouldProcessNamespaces;
}

- (void)setShouldReportNamespacePrefixes:(bool)flag
{
	shouldReportNamespacePrefixes = flag;
}

- (bool)shouldReportNamespacePrefixes
{
	return shouldReportNamespacePrefixes;
}

- (void)setShouldResolveExternalEntities:(bool)flag
{
	shouldResolveExternalEntities = flag;
}

- (bool)shouldResolveExternalEntities
{
	return shouldResolveExternalEntities;
}

- (bool)parse
{
	char buffer[BUFFER_SIZE];
	xmlSAXHandler handler;

	xmlSAXVersion(&handler, 2);

	handler.startDocument = startDocumentHandler;
	handler.endDocument = endDocumentHandler;
	handler.ignorableWhitespace = ignorableWhitespaceHandler;
	handler.cdataBlock = cdataHandler;
	handler.startElementNs = startElementNsHandler;
	handler.endElementNs = endElementNsHandler;
	handler.characters = foundCharactersHandler;
	handler.comment = commentHandler;
	handler.processingInstruction = processingInstructionHandler;
	handler.error = errorHandler;
	
	parser = xmlCreatePushParserCtxt(&handler, self, NULL, 0, NULL);

	while ([data hasBytesAvailable])
	{
		size_t len = [data read:(uint8_t *)buffer maxLength:sizeof(buffer)];

		xmlParseChunk(parser, buffer, len, ![data hasBytesAvailable]);
	}
	
	return (error == nil);
}

- (void)abortParsing
{
	xmlStopParser(parser);
}

- (NSInteger)columnNumber
{
	return xmlSAX2GetColumnNumber(parser);
}

- (NSInteger)lineNumber
{
	return xmlSAX2GetLineNumber(parser);
}

- (NSString *)publicID
{
	// An explicit cast is necessary because libxml2 uses an explicit unsigned
	// char, and NSString expects a char *.
	return [NSString stringWithUTF8String:(const char *)xmlSAX2GetPublicId(parser)];
}

- (NSString *)systemID
{
	// An explicit cast is necessary because libxml2 uses an explicit unsigned
	// char, and NSString expects a char *.
	return [NSString stringWithUTF8String:(const char *)xmlSAX2GetSystemId(parser)];
}

- (void) setDelegate:(id<NSXMLParserDelegate>)newDel
{
	if (delegate == nil)
	{
		delegate = [[NSDelegate alloc] initWithProtocol:@protocol(NSXMLParserDelegate)];
	}
	[(id)delegate setDelegate:newDel];
}

- (id<NSXMLParserDelegate>) delegate
{
	return [(id)delegate delegate];
}

@end
