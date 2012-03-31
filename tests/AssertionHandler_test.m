#include <check.h>
#import <Foundation/NSException.h>
 * All rights reserved.

START_TEST(i_handleFailureInFunction_file_lineNumber_description_) {
	fail_unless(0,
		"-[AssertionHandler handleFailureInFunction:file:lineNumber:description:] failed.");
}
END_TEST

START_TEST(i_handleFailureInMethod_object_file_lineNumber_description_) {
	fail_unless(0,
		"-[AssertionHandler handleFailureInMethod:object:file:lineNumber:description:] failed.");
}
END_TEST

Suite *AssertionHandler_suite(void)
{
	Suite *s = suite_create("AssertionHandler");
	TCase *tc_core = tcase_create("Basic NSTest");
	suite_add_tcase(s, tc_core);

	tcase_add_test(tc_core, i_handleFailureInFunction_file_lineNumber_description_);
	tcase_add_test(tc_core, i_handleFailureInMethod_object_file_lineNumber_description_);
	return (s);
}
