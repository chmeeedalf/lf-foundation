#include <check.h>
#import <Foundation/NSProxy.h>
 * All rights reserved.
START_TEST(c_alloc) {
	fail_unless(0,
		"+[NSProxy alloc] failed.");
}
END_TEST

START_TEST(c_allocWithZone_) {
	fail_unless(0,
		"+[NSProxy allocWithZone:] failed.");
}
END_TEST

START_TEST(i_dealloc) {
	fail_unless(0,
		"-[NSProxy dealloc] failed.");
}
END_TEST

START_TEST(c_class) {
	fail_unless(0,
		"+[NSProxy class] failed.");
}
END_TEST

START_TEST(i_methodSignatureForSelector_) {
	fail_unless(0,
		"-[NSProxy methodSignatureForSelector:] failed.");
}
END_TEST

START_TEST(i_description) {
	fail_unless(0,
		"-[NSProxy description] failed.");
}
END_TEST

START_TEST(i_forwardInvocation_) {
	fail_unless(0,
		"-[NSProxy forwardInvocation:] failed.");
}
END_TEST

Suite *Proxy_suite(void)
{
	Suite *s = suite_create("NSProxy");
	TCase *tc_core = tcase_create("Basic NSTest");
	suite_add_tcase(s, tc_core);

	tcase_add_test(tc_core, c_alloc);
	tcase_add_test(tc_core, c_allocWithZone_);
	tcase_add_test(tc_core, i_dealloc);
	tcase_add_test(tc_core, c_class);
	tcase_add_test(tc_core, i_methodSignatureForSelector_);
	tcase_add_test(tc_core, i_description);
	tcase_add_test(tc_core, i_forwardInvocation_);
	return (s);
}
