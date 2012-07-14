#include <string.h>
#import <Test/NSTest.h>
#import <Foundation/NSData.h>
#import <Foundation/NSString.h>
#import <Foundation/NSXMLParser.h>

@interface TestXMLParser	: NSTest<NSXMLParserDelegate>
{
	bool found_begin;
	bool found_end;
	bool found_begin2;
	bool found_end2;
	bool complex_test;
}
@end

@implementation TestXMLParser

static const char * const xmlData = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
	"<test>foo</test>";
static const char * const xmlComplexData = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
	"<test><test2>foo</test2></test>";
- (void) test_initWithData_
{
	NSData *d = [NSData dataWithBytes:xmlData length:strlen(xmlData)];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:d];
	fail_if(parser == nil, @"");
}

- (void) test_setDelegate_
{
	NSData *d = [NSData dataWithBytes:xmlData length:strlen(xmlData)];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:d];

	[parser setDelegate:self];
	fail_unless([parser delegate] == self, @"");
}

- (void) test_parse
{
	NSData *d = [NSData dataWithBytes:xmlData length:strlen(xmlData)];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:d];

	[parser setDelegate:self];
	[parser parse];
	fail_unless(found_begin && found_end, @"");

	d = [NSData dataWithBytes:xmlComplexData length:strlen(xmlComplexData)];
	parser = [[NSXMLParser alloc] initWithData:d];

	complex_test = true;
	[parser setDelegate:self];
	[parser parse];
	fail_unless(found_begin && found_end && found_begin2 && found_end2, @"");
}

/*******************************************************************
 *
 * Delegate functions we care about.
 *
 */

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if (found_begin)
	{
		if ([elementName isEqual:@"test2"])
			found_begin2 = true;
	}
	else {
		if ([elementName isEqual:@"test"])
			found_begin = true;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if (found_begin2 && !found_end2)
	{
		if ([elementName isEqual:@"test2"])
			found_end2 = true;
	}
	else
	{
		if ([elementName isEqual:@"test"])
			found_end = true;
	}
}
@end
