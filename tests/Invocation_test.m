#include <check.h>
#import <Foundation/Invocation.h>
 * All rights reserved.
START_TEST(c_invocationWithMethodSignature_) {
	fail_unless(0,
		"+[Invocation invocationWithMethodSignature:] failed.");
}
END_TEST

START_TEST(i_argumentsRetained) {
	fail_unless(0,
		"-[Invocation argumentsRetained] failed.");
}
END_TEST

START_TEST(i_getArgument_atIndex_) {
	fail_unless(0,
		"-[Invocation getArgument:atIndex:] failed.");
}
END_TEST

START_TEST(i_getReturnValue_) {
	fail_unless(0,
		"-[Invocation getReturnValue:] failed.");
}
END_TEST

START_TEST(i_methodSignature) {
	fail_unless(0,
		"-[Invocation methodSignature] failed.");
}
END_TEST

START_TEST(i_retainArguments) {
	fail_unless(0,
		"-[Invocation retainArguments] failed.");
}
END_TEST

START_TEST(i_selector) {
	fail_unless(0,
		"-[Invocation selector] failed.");
}
END_TEST

START_TEST(i_setArgument_atIndex_) {
	fail_unless(0,
		"-[Invocation setArgument:atIndex:] failed.");
}
END_TEST

START_TEST(i_setReturnValue_) {
	fail_unless(0,
		"-[Invocation setReturnValue:] failed.");
}
END_TEST

START_TEST(i_setSelector_) {
	fail_unless(0,
		"-[Invocation setSelector:] failed.");
}
END_TEST

START_TEST(i_setTarget_) {
	fail_unless(0,
		"-[Invocation setTarget:] failed.");
}
END_TEST

START_TEST(i_target) {
	fail_unless(0,
		"-[Invocation target] failed.");
}
END_TEST

START_TEST(i_invoke) {
	fail_unless(0,
		"-[Invocation invoke] failed.");
}
END_TEST

START_TEST(i_invokeWithTarget_) {
	fail_unless(0,
		"-[Invocation invokeWithTarget:] failed.");
}
END_TEST

Suite *Invocation_suite(void)
{
	Suite *s = suite_create("Invocation");
	TCase *tc_core = tcase_create("Basic NSTest");
	suite_add_tcase(s, tc_core);

	tcase_add_test(tc_core, c_invocationWithMethodSignature_);
	tcase_add_test(tc_core, i_argumentsRetained);
	tcase_add_test(tc_core, i_getArgument_atIndex_);
	tcase_add_test(tc_core, i_getReturnValue_);
	tcase_add_test(tc_core, i_methodSignature);
	tcase_add_test(tc_core, i_retainArguments);
	tcase_add_test(tc_core, i_selector);
	tcase_add_test(tc_core, i_setArgument_atIndex_);
	tcase_add_test(tc_core, i_setReturnValue_);
	tcase_add_test(tc_core, i_setSelector_);
	tcase_add_test(tc_core, i_setTarget_);
	tcase_add_test(tc_core, i_target);
	tcase_add_test(tc_core, i_invoke);
	tcase_add_test(tc_core, i_invokeWithTarget_);
	return (s);
}
