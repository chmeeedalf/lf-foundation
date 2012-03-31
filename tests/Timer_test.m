#include <check.h>
#import <Foundation/NSTimer.h>
 * All rights reserved.
START_TEST(c_scheduledTimerWithTimeInterval_invocation_repeats_) {
	fail_unless(0,
		"+[NSTimer scheduledTimerWithTimeInterval:invocation:repeats:] failed.");
}
END_TEST

START_TEST(c_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_) {
	fail_unless(0,
		"+[NSTimer scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:] failed.");
}
END_TEST

START_TEST(c_timerWithTimeInterval_invocation_repeats_) {
	fail_unless(0,
		"+[NSTimer timerWithTimeInterval:invocation:repeats:] failed.");
}
END_TEST

START_TEST(c_timerWithTimeInterval_target_selector_userInfo_repeats_) {
	fail_unless(0,
		"+[NSTimer timerWithTimeInterval:target:selector:userInfo:repeats:] failed.");
}
END_TEST

START_TEST(i_fire) {
	fail_unless(0,
		"-[NSTimer fire] failed.");
}
END_TEST

START_TEST(i_invalidate) {
	fail_unless(0,
		"-[NSTimer invalidate] failed.");
}
END_TEST

START_TEST(i_fireDate) {
	fail_unless(0,
		"-[NSTimer fireDate] failed.");
}
END_TEST

START_TEST(i_isValid) {
	fail_unless(0,
		"-[NSTimer isValid] failed.");
}
END_TEST

START_TEST(i_repeats) {
	fail_unless(0,
		"-[NSTimer repeats] failed.");
}
END_TEST

START_TEST(i_userInfo) {
	fail_unless(0,
		"-[NSTimer userInfo] failed.");
}
END_TEST

Suite *Timer_suite(void)
{
	Suite *s = suite_create("NSTimer");
	TCase *tc_core = tcase_create("Basic NSTest");
	suite_add_tcase(s, tc_core);

	tcase_add_test(tc_core, c_scheduledTimerWithTimeInterval_invocation_repeats_);
	tcase_add_test(tc_core, c_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_);
	tcase_add_test(tc_core, c_timerWithTimeInterval_invocation_repeats_);
	tcase_add_test(tc_core, c_timerWithTimeInterval_target_selector_userInfo_repeats_);
	tcase_add_test(tc_core, i_fire);
	tcase_add_test(tc_core, i_invalidate);
	tcase_add_test(tc_core, i_fireDate);
	tcase_add_test(tc_core, i_isValid);
	tcase_add_test(tc_core, i_repeats);
	tcase_add_test(tc_core, i_userInfo);
	return (s);
}
