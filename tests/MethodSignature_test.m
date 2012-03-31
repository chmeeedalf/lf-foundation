#include <check.h>
#import <Foundation/MethodSignature.h>
 * All rights reserved.
START_TEST(c_signatureWithObjCTypes_) {
	fail_unless(0,
		"+[MethodSignature signatureWithObjCTypes:] failed.");
}
END_TEST

START_TEST(i_argumentInfoAtIndex_) {
	fail_unless(0,
		"-[MethodSignature argumentInfoAtIndex:] failed.");
}
END_TEST

START_TEST(i_frameLength) {
	fail_unless(0,
		"-[MethodSignature frameLength] failed.");
}
END_TEST

START_TEST(i_isOneway) {
	fail_unless(0,
		"-[MethodSignature isOneway] failed.");
}
END_TEST

START_TEST(i_methodReturnLength) {
	fail_unless(0,
		"-[MethodSignature methodReturnLength] failed.");
}
END_TEST

START_TEST(i_methodReturnType) {
	fail_unless(0,
		"-[MethodSignature methodReturnType] failed.");
}
END_TEST

START_TEST(i_numberOfArguments) {
	fail_unless(0,
		"-[MethodSignature numberOfArguments] failed.");
}
END_TEST

Suite *MethodSignature_suite(void)
{
	Suite *s = suite_create("MethodSignature");
	TCase *tc_core = tcase_create("Basic NSTest");
	suite_add_tcase(s, tc_core);

	tcase_add_test(tc_core, c_signatureWithObjCTypes_);
	tcase_add_test(tc_core, i_argumentInfoAtIndex_);
	tcase_add_test(tc_core, i_frameLength);
	tcase_add_test(tc_core, i_isOneway);
	tcase_add_test(tc_core, i_methodReturnLength);
	tcase_add_test(tc_core, i_methodReturnType);
	tcase_add_test(tc_core, i_numberOfArguments);
	return (s);
}
