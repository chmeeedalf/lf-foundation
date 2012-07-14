#import <Test/NSTest.h>
#import <Foundation/NSString.h>

@interface TestStringClass : NSTest
@end
@interface TestString : NSTest
@end

@implementation TestStringClass

/*
- (void) test_localizedStringWithFormat_
{
	fail_unless(0,
		@"+[NSString localizedStringWithFormat:] failed.");
}
 */

- (void) test_stringWithCharacters_length_
{
	NSUniChar chars[] = {'f', 'o', 'o'};
	NSString *str = [NSString stringWithCharacters:chars length:3];
	fail_unless([str length] == 3 && [str isEqualToString:@"foo"],
		@"+[NSString stringWithCharacters:length:] failed.");
}

- (void) test_stringWithFormat_
{
	NSString *str = [NSString stringWithFormat:@"%#x",0xff];
	fail_unless([str isEqualToString:@"0xff"],
		@"+[NSString stringWithFormat:] failed.");
}

- (void) test_stringWithString_
{
}

/*
- (void) test_availableStringEncodings
{
	fail_unless(0,
		@"+[NSString availableStringEncodings] failed.");
}

- (void) test_defaultCStringEncoding
{
	fail_unless(0,
		@"+[NSString defaultCStringEncoding] failed.");
}

- (void) test_localizedNameOfStringEncoding_
{
	fail_unless(0,
		@"+[NSString localizedNameOfStringEncoding:] failed.");
}
 */

@end

@implementation TestString

- (void) test_length
{
	NSString *str = [NSString stringWithUTF8String:"foo"];
	fail_unless([str length] == 3,
		@"-[NSString length] failed.");
	fail_unless([@"" length] == 0,
		@"-[NSString length] failed.");
}

- (void) test_characterAtIndex_
{
	fail_unless([@"foo" characterAtIndex:2] == 'o',
		@"-[NSString characterAtIndex:] failed.");
}

- (void) test_getCharacters_
{
	NSUniChar chars[3];
	[@"foo" getCharacters:chars range:NSMakeRange(0, 3)];
	fail_unless(chars[0] == 'f' && chars[1] == 'o' && chars[2] == 'o',
		@"-[NSString getCharacters:] failed.");
}

/*
- (void) test_getCharacters_range_
{
	fail_unless(0,
		@"-[NSString getCharacters:range:] failed.");
}

- (void) test_stringByAppendingString_
{
	fail_unless(0,
		@"-[NSString stringByAppendingString:] failed.");
}

- (void) test_componentsSeparatedByString_
{
	fail_unless(0,
		@"-[NSString componentsSeparatedByString:] failed.");
}

- (void) test_substringFromIndex_
{
	fail_unless(0,
		@"-[NSString substringFromIndex:] failed.");
}

- (void) test_substringWithRange_
{
	fail_unless(0,
		@"-[NSString substringWithRange:] failed.");
}

- (void) test_substringToIndex_
{
	fail_unless(0,
		@"-[NSString substringToIndex:] failed.");
}

- (void) test_rangeOfCharacterFromSet_
{
	fail_unless(0,
		@"-[NSString rangeOfCharacterFromSet:] failed.");
}

- (void) test_rangeOfCharacterFromSet_options_
{
	fail_unless(0,
		@"-[NSString rangeOfCharacterFromSet:options:] failed.");
}

- (void) test_rangeOfCharacterFromSet_options_range_
{
	fail_unless(0,
		@"-[NSString rangeOfCharacterFromSet:options:range:] failed.");
}

- (void) test_rangeOfString_
{
	fail_unless(0,
		@"-[NSString rangeOfString:] failed.");
}

- (void) test_rangeOfString_options_
{
	fail_unless(0,
		@"-[NSString rangeOfString:options:] failed.");
}

- (void) test_rangeOfString_options_range_
{
	fail_unless(0,
		@"-[NSString rangeOfString:options:range:] failed.");
}

- (void) test_rangeOfComposedCharacterSequenceAtIndex_
{
	fail_unless(0,
		@"-[NSString rangeOfComposedCharacterSequenceAtIndex:] failed.");
}

- (void) test_caseInsensitiveCompare_
{
	fail_unless(0,
		@"-[NSString caseInsensitiveCompare:] failed.");
}

- (void) test_compare_
{
	fail_unless(0,
		@"-[NSString compare:] failed.");
}

- (void) test_compare_options_
{
	fail_unless(0,
		@"-[NSString compare:options:] failed.");
}

- (void) test_compare_options_range_
{
	fail_unless(0,
		@"-[NSString compare:options:range:] failed.");
}
 */

- (void) test_hasPrefix_
{
	fail_unless([@"foo bar baz" hasPrefix:@"foo"],
		@"-[NSString hasPrefix:] failed with good suffix.");
	fail_if([@"foo bar baz" hasPrefix:@"bar"],
		@"-[NSString hasPrefix:] succeeded with bad suffix.");
}

- (void) test_hasSuffix_
{
	fail_unless([@"foo bar baz" hasSuffix:@"baz"],
		@"-[NSString hasSuffix:] failed with good suffix.");
	fail_if([@"foo bar baz" hasSuffix:@"bar"],
		@"-[NSString hasSuffix:] succeeded with bad suffix.");
}

- (void) test_isEqualToString_
{
	fail_unless([@"foo" isEqualToString:@"foo"],
		@"-[NSString isEqualToString:] returned NO for equal strings.");
	fail_if([@"foo" isEqualToString:@"bar"],
		@"-[NSString isEqualToString:] returned true for inequal strings.");
}

- (void) test_description
{
	fail_unless([[@"foo" description] isEqual:@"foo"],
		@"-[NSString description] failed.");
}

/*
- (void) test_commonPrefixWithString_options_
{
	fail_unless(0,
		@"-[NSString commonPrefixWithString:options:] failed.");
}

- (void) test_capitalizedString
{
	fail_unless(0,
		@"-[NSString capitalizedString] failed.");
}
 */

- (void) test_lowercaseString
{
	fail_unless([[@"FOOBAR BAZ" lowercaseString] isEqual:@"foobar baz"],
		@"-[NSString lowercaseString] failed.");
}

- (void) test_uppercaseString
{
	fail_unless([[@"foobar baz" uppercaseString] isEqual:@"FOOBAR BAZ"],
		@"-[NSString uppercaseString] failed.");
}

/*
- (void) test_getCString_
{
	fail_unless(0,
		@"-[NSString getCString:] failed.");
}

- (void) test_getCString_maxLength_
{
	fail_unless(0,
		@"-[NSString getCString:maxLength:] failed.");
}

- (void) test_getCString_maxLength_range_remainingRange_
{
	fail_unless(0,
		@"-[NSString getCString:maxLength:range:remainingRange:] failed.");
}

- (void) test_doubleValue
{
	fail_unless(0,
		@"-[NSString doubleValue] failed.");
}

- (void) test_floatValue
{
	fail_unless(0,
		@"-[NSString floatValue] failed.");
}
 */

- (void) test_intValue
{
	fail_unless([@"1234" intValue] == 1234,
		@"-[NSString intValue] failed.");
}

/*
- (void) test_canBeConvertedToEncoding_
{
	fail_unless(0,
		@"-[NSString canBeConvertedToEncoding:] failed.");
}

- (void) test_dataUsingEncoding_
{
	fail_unless(0,
		@"-[NSString dataUsingEncoding:] failed.");
}

- (void) test_dataUsingEncoding_allowLossyConversion_
{
	fail_unless(0,
		@"-[NSString dataUsingEncoding:allowLossyConversion:] failed.");
}
 */

- (void) test_fastestEncoding
{
	fail_unless([@"XYZ" fastestEncoding] == NSUnicodeStringEncoding,
		@"-[NSString fastestEncoding] failed.");
}

/*
- (void) test_smallestEncoding
{
	fail_unless(0,
		@"-[NSString smallestEncoding] failed.");
}
 */

- (void) test_indexOfString_fromIndex_
{
	NSString *str = @"Foo barBaz";
	fail_unless([str indexOfString:@"Foo" fromIndex:4] == NSNotFound,
			@"-[NSString indexOfString:] failed test (found string)");
}

- (void) test_indexOfString_
{
	NSString *str = @"Foo barBaz";
	fail_unless([str indexOfString:@"Foo"] == 0,
			@"-[NSString indexOfString:] didn't find first string");
	fail_unless([str indexOfString:@"bar"] == 4,
			@"-[NSString indexOfString:] didn't find second string at 4");
	fail_unless([str indexOfString:@"quux"] == NSNotFound,
		@"-[NSString indexOfString:] found a string that doesn't exist.");
}

- (void) test_init
{
	NSString *str = [[NSString alloc] init];
	fail_unless([str isEqualToString:@""],
		@"-[NSString init] failed.");
}

/*
- (void) test_initWithBytes_length_encoding_
{
	fail_unless(0,
		@"-[NSString initWithBytes:length:encoding:] failed.");
}

- (void) test_initWithBytesNoCopy_length_encoding_freeWhenDone_
{
	fail_unless(0,
		@"-[NSString initWithBytesNoCopy:length:encoding:freeWhenDone:] failed.");
}

- (void) test_initWithCStringNoCopy_length_freeWhenDone_
{
	fail_unless(0,
		@"-[NSString initWithCStringNoCopy:length:freeWhenDone:] failed.");
}

- (void) test_initWithCharactersNoCopy_length_freeWhenDone_
{
	fail_unless(0,
		@"-[NSString initWithCharactersNoCopy:length:freeWhenDone:] failed.");
}

- (void) test_initWithData_encoding_
{
	fail_unless(0,
		@"-[NSString initWithData:encoding:] failed.");
}

- (void) test_initWithFormat_locale_
{
	fail_unless(0,
		@"-[NSString initWithFormat:locale:] failed.");
}

- (void) test_initWithFormat_locale_arguments_
{
	fail_unless(0,
		@"-[NSString initWithFormat:locale:arguments:] failed.");
}
 */

@end
