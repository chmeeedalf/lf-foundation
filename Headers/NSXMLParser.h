/*
 * Copyright (c) 2009	Gold Project
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

#import <Foundation/NSObject.h>

@class NSString;
@class NSURI;
@class NSDictionary;
@class NSData;
@class NSError;
@class NSStream;

extern NSString * const NSXMLParserErrorDomain;

enum {
	NSXMLParserInternalError = 1,
	NSXMLParserOutOfMemoryError,
	NSXMLParserDocumentStartError,
	NSXMLParserEmptyDocumentError,
	NSXMLParserPrematureDocumentEndError,
	NSXMLParserInvalidHexCharacterRefError,
	NSXMLParserInvalidDecimalCharacterRefError,
	NSXMLParserInvalidCharacterRefError,
	NSXMLParserInvalidCharacterError,
	NSXMLParserCharacterRefAtEOFError,
	NSXMLParserCharacterRefInPrologError,
	NSXMLParserCharacterRefInEpilogError,
	NSXMLParserCharacterRefInDTDError,
	NSXMLParserEntityRefAtEOFError,
	NSXMLParserEntityRefInPrologError,
	NSXMLParserEntityRefInEpilogError,
	NSXMLParserEntityRefInDTDError,
	NSXMLParserParsedEntityRefAtEOFError,
	NSXMLParserParsedEntityRefInPrologError,
	NSXMLParserParsedEntityRefInEpilogError,
	NSXMLParserParsedEntityRefInInternalSubsetError,
	NSXMLParserEntityReferenceWithoutNameError,
	NSXMLParserEntityReferenceMissingSemiError,
	NSXMLParserParsedEntityReferenceNoNameError,
	NSXMLParserParsedEntityReferenceMissingSemiError,
	NSXMLParserUndeclaredEntityError,
	NSXMLParserUnparsedEntityError = 28,
	NSXMLParserEntityIsExternalError,
	NSXMLParserEntityIsParameterError,
	NSXMLParserUnknownEncodingError,
	NSXMLParserEncodingNotSupportedError,
	NSXMLParserStringNotStartedError,
	NSXMLParserStringNotClosedError,
	NSXMLParserNamespaceDeclarationError,
	NSXMLParserEntityNotStartedError,
	NSXMLParserEntityNotFinishedError,
	NSXMLParserLessThanSymbolInAttributeError,
	NSXMLParserAttributeNotStartedError,
	NSXMLParserAttributeNotFinishedError,
	NSXMLParserAttributHasNoValueError,
	NSXMLParserAttributeRedefinedError,
	NSXMLParserLiteralNotStartedError,
	NSXMLParserLiteralNotFinishedError,
	NSXMLParserCommentNotFinishedError,
	NSXMLParserProcessingInstructionNotStartedError,
	NSXMLParserProcessingInstructionNotFinishedError,
	NSXMLParserNotationNotStartedError,
	NSXMLParserNotationNotFinishedError,
	NSXMLParserAttributeListNotStartedError,
	NSXMLParserAttributeListNotFinishedError,
	NSXMLParserMixedContentDeclNotStartedError,
	NSXMLParserMixedContentDeclNotFinishedError,
	NSXMLParserElementContentDeclNotStartedError,
	NSXMLParserElementContentDeclNotFinishedError,
	NSXMLParserXMLDeclNotStartedError,
	NSXMLParserXMLDeclNotFinishedError,
	NSXMLParserConditionalSectionNotStartedError,
	NSXMLParserConditionalSectionNotFinishedError,
	NSXMLParserExternalSubsetNotFinishedError,
	NSXMLParserDOCTYPEDeclNotFinishedError,
	NSXMLParserMisplacedCDATAEndStringError,
	NSXMLParserCDATANotFinishedError,
	NSXMLParserMisplacedXMLDeclarationError,
	NSXMLParserSpaceRequiredError,
	NSXMLParserSeparatorRequiredError,
	NSXMLParserNMTOKENRequiredError,
	NSXMLParserNAMERequiredError,
	NSXMLParserPCDATARequiredError,
	NSXMLParserURIRequiredError,
	NSXMLParserPublicIdentifierRequiredError,
	NSXMLParserLTRequiredError,
	NSXMLParserGTRequiredError,
	NSXMLParserLTSlashRequiredError,
	NSXMLParserEqualExpectedError,
	NSXMLParserTagNameMismatchError,
	NSXMLParserUnfinishedTagError,
	NSXMLParserStandaloneValueError,
	NSXMLParserInvalidEncodingNameError,
	NSXMLParserCommentContainsDoubleHyphensError,
	NSXMLParserInvalidEncodingError,
	NSXMLParserExternalStandaloneEntityError,
	NSXMLParserInvalidConditionalSectionError,
	NSXMLParserEntityValueRequiredError,
	NSXMLParserNotWellBalancedError,
	NSXMLParserExtraContentError,
	NSXMLParserInvalidCharacterInEntityError,
	NSXMLParserParsedEntityRefInInternalError,
	NSXMLParserEntityRefLoopError,
	NSXMLParserEntityBoundaryError,
	NSXMLParserInvalidURIError,
	NSXMLParserURIFragmentError,
	NSXMLParserNoDTDError = 94,
	NSXMLParserDelegateAbortedParseError = 512,
};
typedef NSInteger NSXMLParserError;

	
@protocol NSXMLParserDelegate;
/*!
 * \brief A SAX-compatible XML parser.
 */
@interface NSXMLParser : NSObject
{
	id delegate;						/*!< \brief The parser delegate. */
	bool shouldProcessNamespaces;		/*!< \brief Whether or not to perform namespace processing. */
	bool shouldReportNamespacePrefixes;	/*!< \brief Whether or not to report namespace prefixes. */
	bool shouldResolveExternalEntities;	/*!< \brief Whether or not the parser should resolve external entities. */
	
	id data;
	id error;
	void *parser;	/*!< \brief Opaque XML parser object. */
}
@property(assign) id<NSXMLParserDelegate> delegate;
@property bool shouldProcessNamespaces;
@property bool shouldReportNamespacePrefixes;
@property bool shouldResolveExternalEntities;

/*!
 * \brief Initialize the parser with the contents of a given NSURI.
 * \param url NSURI whose contents to retrieve into the XML parser.
 */
- (id)initWithContentsOfURI:(NSURI *)url;

/*!
 * \brief Initialize the parser with a raw XML data.
 * \param data Raw XML data.
 */
- (id)initWithData:(NSData *)data;

- (id)initWithStream:(NSStream *)stream;

/*!
 * \brief Begin parsing the XML data.
 */
- (bool)parse;

/*!
 * \brief Abort parsing the XML data.
 */
- (void)abortParsing;

/*!
 * \brief Returns the current column in the data the parser is at.
 */
- (NSInteger)columnNumber;

/*!
 * \brief Returns the current line number in the data the parser is on.
 */
- (NSInteger)lineNumber;

/*!
 * \brief Returns the public identifier of the external entity referenced in the
 * XML document.
 */
- (NSString *)publicID;

/*!
 * \brief Returns the system identifier of the external entity referenced in the
 * XML document.
 */
- (NSString *)systemID;

@end


// Delegate Methods
/*!
 * \brief Informal protocol for XMLParser delegate methods.
 */
@protocol NSXMLParserDelegate<NSObject>

@optional
/*!
 * \brief Called when the parser begins parsing a document.
 * \brief parser The XMLParser object.
 */
- (void)parserDidStartDocument:(NSXMLParser *)parser;

/*!
 * \brief Called when the parser finishes parsing a document.
 * \brief parser The NSXMLParser object.
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser;

/*!
 * \brief Called when the parser encounters a start tag for an element.
 * \param parser The parser object.
 * \param elementName The name of the element.
 * \param namespaceURI If namespace processing is turned on, contains the NSURI
 * for the current namespace.
 * \param qualifiedName If namespace processing is turned on, contains the
 * qualified name of the current namespace.
 * \param attributeDict A dictionary that contains any attributes associated
 * with the element.
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;

/*!
 * \brief Called when the parser encounters an end tag for an element.
 * \param parser The parser object.
 * \param elementName The name of the element.
 * \param namespaceURI If namespace processing is turned on, contains the NSURI
 * for the current namespace.
 * \param qualifiedName If namespace processing is turned on, contains the
 * qualified name of the current namespace.
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName;

/*!
 * \brief Called when the parser first encounters a given namespace prefix,
 * which is mapped to a NSURI.
 * \param parser The parser object.
 * \param prefix The namespace prefix.
 * \param namespaceURI The namespace NSURI.
 *
 * \details The parser object sends this message only when namespace-prefix
 * reporting is turned on.
 */
- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI;

/*!
 * \brief Called by the parser when the given namespace prefix goes out of scope.
 * \param parser The parser object.
 * \param prefix The namespace prefix.
 *
 * \details The parser object sends this message only when namespace-prefix
 * reporting is turned on.
 */
- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix;

/*!
 * \brief Called to provide the delegate with some or all of the characters of
 * the current element.
 * \param parser The parser object.
 * \param string The (possibly partial) character string found.
 * 
 * \details The string may be incomplete, and the method may be called multiple
 * times for a single element, each time with another part of the character
 * string.
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

/*!
 * \brief Called when the parser finds a comment in the XML.
 * \param parser The parser object.
 * \param comment The contents of the XML comment.
 */
- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment;

/*!
 * \brief Called when the parser finds a processing instruction.
 * \param parser The parser object.
 * \param target The target of the processing instruction.
 * \param data The processing instruction.
 */
- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data;

/*!
 * \brief Called when a fatal parsing error occurs.
 * \param parser The parser object.
 * \param parseError The object describing the error.
 */
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError;

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)entityName systemID:(NSString *)systemID;

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError;

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)comment;
- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString;
- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue;
- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model;
- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)entityName publicID:(NSString *)publicID systemID:(NSString *)systemID;
- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value;
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;
- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName;


@end

/*
   vim:syntax=objc:
 */
