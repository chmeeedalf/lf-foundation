/*
 * Copyright (c) 2006-2012	Gold Project
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
#import <Foundation/NSInvocation.h>
#import <Foundation/MIMEHandler.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSProxy.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSXMLParser.h>

@interface NSXMLMIMECoder : NSProxy <MIMEHandler,NSXMLParserDelegate>
{
	id outputObject;
	NSMutableString *currentText;
}
@end

static NSArray *XMLCodings;

@implementation NSXMLMIMECoder

- (void) initialize
{
	XMLCodings = [[NSArray alloc] initWithObjects:@"text/xml",@"image/svg+xml"];
}

+ (NSArray *)handledMIMEEncodings
{
	return XMLCodings;
}

- (id) initWithData:(NSData *)_data MIMEEncoding:(NSString *)enc
{
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_data];
	[parser setDelegate:self];
	return self;
}

- (NSData *)encodedDataForMIME:(NSString *)encoding outputEncoding:(NSString **)outEnc
{
	TODO;
	return nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURL:(NSString *)namespaceURL qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURL:(NSString *)namespaceURL qualifiedName:(NSString *)qName
{
	currentText = nil;
}

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURL:(NSString *)namespaceURL
{
}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (currentText == nil)
		currentText = [NSMutableString new];
	[currentText appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
}

/*
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
}
*/

/* NSProxy method */

- (void) forwardInvocation:(NSInvocation *)inv
{
	[inv invokeWithTarget:outputObject];
}

@end
