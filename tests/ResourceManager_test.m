#include <check.h>
#import <Foundation/ResourceManager.h>
START_TEST(c_allocWithZone_) {
	fail_unless(0,
		"+[ResourceManager allocWithZone:] failed.");
}
END_TEST

START_TEST(i_) {
	fail_unless(0,
		"-[ResourceManager ] failed.");
}
END_TEST

START_TEST(c_) {
	fail_unless(0,
		"+[ResourceManager ] failed.");
}
END_TEST

START_TEST(i_resourceWithName_) {
	fail_unless(0,
		"-[ResourceManager resourceWithName:] failed.");
}
END_TEST

START_TEST(i_addResourceDictionary_) {
	fail_unless(0,
		"-[ResourceManager addResourceDictionary:] failed.");
}
END_TEST

Suite *ResourceManager_suite(void)
{
	Suite *s = suite_create("ResourceManager");
	TCase *tc_core = tcase_create("Basic NSTest");
	suite_add_tcase(s, tc_core);

	tcase_add_test(tc_core, c_allocWithZone_);
	tcase_add_test(tc_core, i_);
	tcase_add_test(tc_core, c_);
	tcase_add_test(tc_core, i_resourceWithName_);
	tcase_add_test(tc_core, i_addResourceDictionary_);
	return (s);
}
