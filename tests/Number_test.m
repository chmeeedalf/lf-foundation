#import <Test/NSTest.h>
#import <Foundation/NSValue.h>
 * All rights reserved.
#import <Foundation/NSLocale.h>
#import <limits.h>

@interface TestNumberClass : NSTest
@end
@interface TestNumber : NSTest
@end

@implementation TestNumberClass

- (void) test_numberWithBool_
{
	fail_unless([[NSNumber numberWithBool:false] boolValue] == false,
		@"false boolean is not false");
}

- (void) test_numberWithChar_
{
	fail_unless([[NSNumber numberWithChar:'a'] charValue] == 'a',
		@"Not the right character");
}

- (void) test_numberWithDouble_
{
	fail_unless([[NSNumber numberWithDouble:0.0] doubleValue] == 0.0,
		@"Double extraction failed");
	fail_unless([[NSNumber numberWithDouble:0.0] longValue] == 0,
		@"Long extraction failed");
}

- (void) test_numberWithFloat_
{
	fail_unless([[NSNumber numberWithFloat:0.0f] floatValue] == 0.0f,
		@"Float extraction failed");
	fail_unless([[NSNumber numberWithFloat:0.0f] longValue] == 0,
		@"Long extraction failed");
}

- (void) test_numberWithInt_
{
	fail_unless([[NSNumber numberWithInt:INT_MAX] intValue] == INT_MAX,
		@"");
}

- (void) test_numberWithLong_
{
	fail_unless([[NSNumber numberWithLong:LONG_MAX] longValue] == LONG_MAX,
		@"");
}

- (void) test_numberWithLongLong_
{
	fail_unless([[NSNumber numberWithLongLong:0] longLongValue] == 0,
		@"Can't do 0 min");
	fail_unless([[NSNumber numberWithLongLong:LLONG_MAX] longLongValue] == LLONG_MAX,
		@"LLONG_MAX failed");
}

- (void) test_numberWithShort_
{
	fail_unless([[NSNumber numberWithShort:1234] intValue] == 1234,
		@"");
}

- (void) test_numberWithUnsignedChar_
{
	fail_unless([[NSNumber numberWithUnsignedChar:'a'] charValue] == 'a',
		@"");
}

- (void) test_numberWithUnsignedInt_
{
	fail_unless([[NSNumber numberWithUnsignedInt:UINT_MAX] unsignedIntValue] == UINT_MAX,
		@"");
}

- (void) test_numberWithUnsignedLong_
{
	fail_unless([[NSNumber numberWithUnsignedLong:ULONG_MAX] unsignedLongValue] == ULONG_MAX,
		@"");
}

- (void) test_numberWithUnsignedLongLong_
{
	fail_unless([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] unsignedLongLongValue] == ULLONG_MAX,
		@"");
}

- (void) test_numberWithUnsignedShort_
{
	fail_unless([[NSNumber numberWithUnsignedShort:USHRT_MAX] unsignedShortValue] == USHRT_MAX,
		@"");
}

@end

@implementation TestNumber

- (void) test_boolValue
{
	fail_unless([[NSNumber numberWithBool:false] boolValue] == false,
		@"false boolean is not false");
}

- (void) test_charValue
{
	fail_unless([[NSNumber numberWithChar:'a'] charValue] == 'a',
		@"Character not right");
}

- (void) test_doubleValue
{
	fail_unless([[NSNumber numberWithDouble:0.0] doubleValue] == 0.0,
		@"Double failed");
	fail_unless([[NSNumber numberWithLong:0] doubleValue] == 0.0,
		@"Double extraction from long failed");
}

- (void) test_floatValue
{
	fail_unless([[NSNumber numberWithFloat:0.0f] floatValue] == 0.0f,
		@"Float failed");
	fail_unless([[NSNumber numberWithLong:0] floatValue] == 0.0f,
		@"Float extraction from long failed");
}

- (void) test_intValue
{
	fail_unless([[NSNumber numberWithInt:INT_MAX] intValue] == INT_MAX,
		@"Int to int failed");
	fail_unless([[NSNumber numberWithDouble:0.0] intValue] == 0,
		@"Double to int failed");
}

- (void) test_longLongValue
{
	fail_unless([[NSNumber numberWithLongLong:LLONG_MAX] longLongValue] == LLONG_MAX,
		@"Long Long to Long Long failed");
	fail_unless([[NSNumber numberWithFloat:1.0e10] longLongValue] == 10000000000,
		@"Float to Long Long failed");
}

- (void) test_longValue
{
	fail_unless([[NSNumber numberWithLong:LONG_MAX] longValue] == LONG_MAX,
		@"Long to Long failed");
	fail_unless([[NSNumber numberWithFloat:1.0e5] longLongValue] == 100000,
		@"Float to long failed");
}

- (void) test_shortValue
{
	fail_unless([[NSNumber numberWithShort:1234] shortValue] == 1234,
		@"Short to Short failed");
	fail_unless([[NSNumber numberWithDouble:1.5e2] shortValue] == 150,
		@"Double to Short failed");
}

- (void) test_stringValue
{
	/* TODO: Fix doubles.  WTF is going on with that? */
	NSNumber *n = [NSNumber numberWithInt:0];
	fail_unless([[n stringValue] isEqual:[n descriptionWithLocale:[NSLocale currentLocale]]],
		([NSString stringWithFormat:@"NSString failed: %@, %@", [n stringValue], [n descriptionWithLocale:[NSLocale currentLocale]]]));
}

- (void) test_unsignedCharValue
{
	fail_unless([[NSNumber numberWithChar:'a'] unsignedCharValue] == 'a',
		@"");
	fail_unless([[NSNumber numberWithInt:0x100+'a'] unsignedCharValue] == 'a',
		@"");
}

- (void) test_unsignedIntValue
{
	fail_unless([[NSNumber numberWithChar:'a'] unsignedIntValue] == 'a',
		@"");
	/* NSTest for maximums for truncation */
	fail_unless([[NSNumber numberWithLongLong:LLONG_MAX] unsignedIntValue] == UINT_MAX,
		@"");
}

- (void) test_unsignedLongLongValue
{
	fail_unless([[NSNumber numberWithChar:'a'] unsignedLongLongValue] == 'a',
		@"");
	/* NSTest for maximums for truncation */
	fail_unless([[NSNumber numberWithLongLong:ULLONG_MAX] unsignedLongLongValue] == ULLONG_MAX,
		@"");
}

- (void) test_unsignedLongValue
{
	fail_unless([[NSNumber numberWithChar:'a'] unsignedLongValue] == 'a',
		@"");
	/* NSTest for maximums for truncation */
	fail_unless([[NSNumber numberWithLongLong:LLONG_MAX] unsignedLongValue] == ULONG_MAX,
		@"");
}

- (void) test_unsignedShortValue
{
	fail_unless([[NSNumber numberWithChar:'a'] unsignedShortValue] == 'a',
		@"");
	/* NSTest for maximums for truncation */
	fail_unless([[NSNumber numberWithLongLong:LLONG_MAX] unsignedShortValue] == USHRT_MAX,
		@"");
}

- (void) test_compare_
{
	fail_unless([[NSNumber numberWithInt:INT_MAX] compare:[NSNumber numberWithLongLong:LLONG_MAX]] == NSOrderedAscending,
		@"");
}

- (void) test_descriptionWithLocale_
{
	fail_unless(([[[NSNumber numberWithInt:INT_MAX] descriptionWithLocale:nil] isEqual:[NSString stringWithFormat:@"%d",INT_MAX]]),
		@"");
}

@end
