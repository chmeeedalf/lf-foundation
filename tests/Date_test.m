#import <Foundation/NSDate.h>
#import <Foundation/NSLocale.h>
 * All rights reserved.
#import <Test/NSTest.h>

@interface TestDateClass : NSTest
@end
@interface TestDate : NSTest
@end

@implementation TestDateClass
- (void) test_date
{
	fail_if([NSDate date] == nil,
		@"");
}

- (void) test_dateWithTimeIntervalSinceNow_
{
	fail_unless([[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSinceNow] <= 0,
		@"");
}

- (void) test_dateWithTimeIntervalSince1970_
{
	fail_unless([[NSDate dateWithTimeIntervalSince1970:1000] timeIntervalSince1970] == 1000,
		@"");
}

- (void) test_dateWithTimeIntervalSinceReferenceDate_
{
	fail_unless([[NSDate dateWithTimeIntervalSinceReferenceDate:1000] timeIntervalSinceReferenceDate] == 1000,
		@"");
}

- (void) test_distantFuture
{
	NSDate *d = [NSDate date];
	fail_unless([[NSDate distantFuture] earlierDate:d] == d,
		@"");
}

- (void) test_distantPast
{
	NSDate *d = [NSDate date];
	fail_unless([[NSDate distantPast] laterDate:d] == d,
		@"");
}

- (void) test_timeIntervalSinceReferenceDate
{
	fail_unless([NSDate timeIntervalSinceReferenceDate] != 0,
		@"");
}

@end

@implementation TestDate
- (void) test_initWithString_
{
	TODO;
	/*
	NSDate *d = [NSDate distantFuture];
	NSDate *newDate = [[NSDate alloc] initWithString:[d description]];
	Log(@"%@, %@", d, newDate);
	Log(@"%lld, %lld", [d timeIntervalSinceReferenceDate], [newDate timeIntervalSinceReferenceDate]);
	fail_unless([newDate timeIntervalSinceReferenceDate] == [d timeIntervalSinceReferenceDate],
		@"");
	*/
}

- (void) test_initWithTimeInterval_sinceDate_
{
	NSDate *d = [[NSDate alloc] initWithTimeInterval:10000 sinceDate:[NSDate distantPast]];
	NSTimeInterval t = [d timeIntervalSince1970];
	NSTimeInterval past = [[NSDate distantPast] timeIntervalSince1970];
	[d release];
	fail_unless((t - past) >= 10000,
		@"");
}

- (void) test_initWithTimeIntervalSinceNow_
{
	NSDate *now = [[NSDate alloc] initWithTimeIntervalSinceNow:1000];
	NSTimeInterval t = [now timeIntervalSinceReferenceDate];
	[now release];
	fail_unless(t > 0 && t < [[NSDate distantFuture] timeIntervalSinceReferenceDate],
		@"");
}

- (void) test_initWithTimeIntervalSinceReferenceDate_
{
	NSDate *now = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:1000];
	NSTimeInterval t = [now timeIntervalSinceReferenceDate];
	[now release];
	fail_unless(t == 1000,
		@"");
}

- (void) test_initWithTimeIntervalSince1970_
{
	NSDate *d = [[NSDate alloc] initWithTimeIntervalSince1970:0];
	NSTimeInterval diff = [d timeIntervalSince1970];
	fail_unless(diff == 0,
		@"");

	[d release];
	d = [[NSDate alloc] initWithTimeIntervalSince1970:1234567890];
	diff = [d timeIntervalSince1970];
	fail_unless(diff == 1234567890,
		@"");

}

- (void) test_description
{
	fail_unless([[NSDate distantFuture] description] != nil,
		@"");
}

- (void) test_descriptionWithCalendarFormat_timeZone_locale_
{
	TODO;
	fail_unless([[NSDate distantFuture] descriptionWithCalendarFormat:nil timeZone:nil locale:nil] != nil,
		@"");
}

- (void) test_descriptionWithLocale_
{
	TODO;
	fail_unless([[NSDate distantFuture] descriptionWithLocale:[NSLocale currentLocale]] != nil,
		@"");
}

- (void) test_timeIntervalSince1970
{
	fail_unless([[NSDate date] timeIntervalSinceReferenceDate] < [[NSDate date] timeIntervalSince1970] &&
			[[NSDate distantPast] timeIntervalSince1970] < 0, @"");
}

- (void) test_timeIntervalSinceDate_
{
	fail_unless([[NSDate distantFuture] timeIntervalSinceDate:[NSDate date]] > 0,
		@"");
}

- (void) test_timeIntervalSinceNow
{
	fail_unless([[NSDate distantFuture] timeIntervalSinceNow] > 0,
		@"");
}

- (void) test_timeIntervalSinceReferenceDate
{
	fail_unless([[NSDate distantFuture] timeIntervalSinceReferenceDate] > 0,
		@"");
}

- (void) test_compare_
{
	fail_unless([[NSDate distantFuture] compare:[NSDate distantPast]] == NSOrderedDescending,
		@"");
}

- (void) test_earlierDate_
{
	NSDate *d1 = [NSDate distantPast];
	NSDate *d2 = [NSDate date];
	fail_unless([d1 earlierDate:d2] == d1,
		@"-[NSDate earlierDate:] failed.");
}

- (void) test_isEqual_
{
	fail_if([[NSDate distantPast] isEqual:[NSObject new]],
		@"NSDate is equal to a different object.");
}

- (void) test_isEqualToDate_
{
	fail_if([[NSDate distantPast] isEqualToDate:[NSDate distantFuture]],
		@"Distant past is equal to distant future?");
}

- (void) test_laterDate_
{
	NSDate *d1 = [NSDate distantPast];
	NSDate *d2 = [NSDate date];
	fail_unless([d1 laterDate:d2] == d2,
		@"-[NSDate laterDate:] failed.");
}
@end
