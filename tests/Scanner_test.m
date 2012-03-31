#import <Test/NSTest.h>
#import <Foundation/NSCharacterSet.h>
 * All rights reserved.
#import <Foundation/NSLocale.h>
#import <Foundation/NSScanner.h>

@interface TestScannerClass : NSTest
@end
@interface TestScanner : NSTest
@end

@implementation TestScannerClass

- (void) test_localizedScannerWithString_
{
	fail_unless([NSScanner localizedScannerWithString:@"abcd"], @"");
}

- (void) test_scannerWithString_
{
	fail_if([NSScanner scannerWithString:@"abcd"] == nil, @"");
}
@end

@implementation TestScanner

- (void) test_initWithString_
{
	NSString *str = @"abcde";
	NSScanner *scan = [[NSScanner alloc] initWithString:str];
	bool eq = ([scan string] == str);
	[scan release];
	fail_unless(eq,@"");
}

- (void) test_string
{
	NSString *str = @"abcde";
	NSScanner *scan = [[NSScanner alloc] initWithString:str];
	bool eq = ([scan string] == str);
	[scan release];
	fail_unless(eq,@"");
}

- (void) test_caseSensitive
{
	NSScanner *s = [NSScanner scannerWithString:@"abcde"];
	NSScanner *t = [NSScanner scannerWithString:@"abcde"];
	[t setCaseSensitive:true];
	fail_unless([s caseSensitive] == false && [t caseSensitive] == true, @"");
}

- (void) test_charactersToBeSkipped
{
	fail_unless([[NSScanner scannerWithString:@"abcde fghij"] charactersToBeSkipped] == [NSCharacterSet whitespaceAndNewlineCharacterSet],
		@"");
}

- (void) test_locale
{
	fail_unless([[NSScanner scannerWithString:@"abcd"] locale] == nil,
		@"");
}

- (void) test_scanLocation
{
	NSString *s = @"abcd";
	NSScanner *scan = [NSScanner scannerWithString:s];
	[scan scanUpToString:@"d" intoString:NULL];

	fail_unless([scan scanLocation] == 3, @"");
}

- (void) test_setCaseSensitive_
{
	NSScanner *s = [NSScanner scannerWithString:@"abcde"];
	NSScanner *t = [NSScanner scannerWithString:@"abcde"];
	[t setCaseSensitive:true];
	fail_unless([s caseSensitive] == false && [t caseSensitive] == true, @"");
}

- (void) test_setCharactersToBeSkipped_
{
	NSScanner *s = [NSScanner scannerWithString:@"abcd1234"];
	int i = 0;
	[s setCharactersToBeSkipped:[NSCharacterSet letterCharacterSet]];
	[s scanInt:&i];
	fail_unless(i == 1234,
		@"");
}

- (void) test_setLocale_
{
	NSScanner *s = [NSScanner scannerWithString:@"foo"];
	[s setLocale:[NSLocale currentLocale]];
	fail_unless([s locale] == [NSLocale currentLocale],
		@"");
}

- (void) test_setScanLocation_
{
	NSString *s = @"abcd";
	NSScanner *scan = [NSScanner scannerWithString:s];
	[scan scanUpToString:@"d" intoString:NULL];
	[scan setScanLocation:1];
	fail_unless([scan scanLocation] == 1, @"");
}

- (void) test_scanCharactersFromSet_intoString_
{
	NSScanner *s = [NSScanner scannerWithString:@"abcdefg1234567"];
	[s scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:NULL];
	fail_unless([s scanLocation] == 7,
		@"");
}

- (void) test_scanDouble_
{
	double f = 0;
	double g = 3.14159e250;
	NSScanner *s = [NSScanner scannerWithString:@"3.14159E250"];
	[s scanDouble:&f];
	fail_unless(f == g,
		@"");
}

- (void) test_scanFloat_
{
	float f = 0;
	float g = 3.14159;
	NSScanner *s = [NSScanner scannerWithString:@"3.14159"];
	[s scanFloat:&f];
	fail_unless(f == g,
		@"");
}

- (void) test_scanInt_
{
	NSString *s = @"1234";
	NSScanner *scan = [NSScanner scannerWithString:s];
	int test;
	[scan scanInt:&test];
	fail_unless(test == 1234,
		@"");
}

- (void) test_scanLongLong_
{
	NSString *s = @"1234567890123";
	NSScanner *scan = [NSScanner scannerWithString:s];
	long long test;
	[scan scanLongLong:&test];
	fail_unless(test == 1234567890123,
		@"");
}

- (void) test_scanString_intoString_
{
	NSString *s = @"1234567890123";
	NSScanner *scan = [NSScanner scannerWithString:s];
	NSString *t;
	fail_unless([scan scanString:@"5678" intoString:&t] == false, @"");
	[scan setScanLocation:4];
	fail_unless([scan scanString:@"5678" intoString:&t] == true && [t isEqual:@"5678"], @"");
}

- (void) test_scanUpToCharactersFromSet_intoString_
{
	NSScanner *s = [NSScanner scannerWithString:@"abcd efgh ijkl"];
	NSString *scanStr;
	bool didScan = [s scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&scanStr];
	fail_unless(didScan == true, @"Failed to scan");
	fail_unless([s scanLocation] == 4 && [scanStr isEqual:@"abcd"],
		@"");
}

- (void) test_scanUpToString_intoString_
{
	NSString *s = @"abcd1234567efghijklm";
	NSScanner *scan = [NSScanner scannerWithString:s];
	NSString *t;
	[scan scanUpToString:@"efghij" intoString:&t];
	fail_unless([scan scanLocation] == 11 && [t isEqual:@"abcd1234567"], @"");
}

- (void) test_isAtEnd
{
	NSString *s = @"1234";
	NSScanner *scan = [NSScanner scannerWithString:s];
	[scan scanString:@"1234" intoString:NULL];
	fail_unless([scan isAtEnd],
		@"");
}
@end
