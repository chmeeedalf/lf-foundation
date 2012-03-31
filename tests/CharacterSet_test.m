#include <check.h>
#import <Foundation/NSCharacterSet.h>
 * All rights reserved.
START_TEST(c_alphanumericCharacterSet) {
	fail_unless(0,
		"+[NSCharacterSet alphanumericCharacterSet] failed.");
}
END_TEST

START_TEST(c_controlCharacterSet) {
	fail_unless(0,
		"+[NSCharacterSet controlCharacterSet] failed.");
}
END_TEST

START_TEST(c_decimalDigitCharacterSet) {
	fail_unless(0,
		"+[NSCharacterSet decimalDigitCharacterSet] failed.");
}
END_TEST

START_TEST(c_decomposableCharacterSet) {
	fail_unless(0,
		"+[NSCharacterSet decomposableCharacterSet] failed.");
}
END_TEST

START_TEST(c_illegalCharacterSet) {
	fail_unless(0,
		"+[NSCharacterSet illegalCharacterSet] failed.");
}
END_TEST

START_TEST(c_letterCharacterSet) {
	fail_unless(0,
		"+[NSCharacterSet letterCharacterSet] failed.");
}
END_TEST

START_TEST(c_lowercaseLetterCharacterSet) {
	fail_unless(0,
		"+[NSCharacterSet lowercaseLetterCharacterSet] failed.");
}
END_TEST

START_TEST(c_nonBaseCharacterSet) {
	fail_unless(0,
		"+[NSCharacterSet nonBaseCharacterSet] failed.");
}
END_TEST

START_TEST(c_uppercaseLetterCharacterSet) {
	fail_unless(0,
		"+[NSCharacterSet uppercaseLetterCharacterSet] failed.");
}
END_TEST

START_TEST(c_whitespaceAndNewlineCharacterSet) {
	fail_unless(0,
		"+[NSCharacterSet whitespaceAndNewlineCharacterSet] failed.");
}
END_TEST

START_TEST(c_whitespaceCharacterSet) {
	fail_unless(0,
		"+[NSCharacterSet whitespaceCharacterSet] failed.");
}
END_TEST

START_TEST(c_characterSetWithBitmapRepresentation_) {
	fail_unless(0,
		"+[NSCharacterSet characterSetWithBitmapRepresentation:] failed.");
}
END_TEST

START_TEST(c_characterSetWithCharactersInString_) {
	fail_unless(0,
		"+[NSCharacterSet characterSetWithCharactersInString:] failed.");
}
END_TEST

START_TEST(c_characterSetWithContentsOfFile_) {
	fail_unless(0,
		"+[NSCharacterSet characterSetWithContentsOfFile:] failed.");
}
END_TEST

START_TEST(c_characterSetWithRange_) {
	fail_unless(0,
		"+[NSCharacterSet characterSetWithRange:] failed.");
}
END_TEST

START_TEST(i_bitmapRepresentation) {
	fail_unless(0,
		"-[NSCharacterSet bitmapRepresentation] failed.");
}
END_TEST

START_TEST(i_characterIsMember_) {
	fail_unless(0,
		"-[NSCharacterSet characterIsMember:] failed.");
}
END_TEST

START_TEST(i_invertedSet) {
	fail_unless(0,
		"-[NSCharacterSet invertedSet] failed.");
}
END_TEST

Suite *CharacterSet_suite(void)
{
	Suite *s = suite_create("NSCharacterSet");
	TCase *tc_core = tcase_create("Basic NSTest");
	suite_add_tcase(s, tc_core);

	tcase_add_test(tc_core, c_alphanumericCharacterSet);
	tcase_add_test(tc_core, c_controlCharacterSet);
	tcase_add_test(tc_core, c_decimalDigitCharacterSet);
	tcase_add_test(tc_core, c_decomposableCharacterSet);
	tcase_add_test(tc_core, c_illegalCharacterSet);
	tcase_add_test(tc_core, c_letterCharacterSet);
	tcase_add_test(tc_core, c_lowercaseLetterCharacterSet);
	tcase_add_test(tc_core, c_nonBaseCharacterSet);
	tcase_add_test(tc_core, c_uppercaseLetterCharacterSet);
	tcase_add_test(tc_core, c_whitespaceAndNewlineCharacterSet);
	tcase_add_test(tc_core, c_whitespaceCharacterSet);
	tcase_add_test(tc_core, c_characterSetWithBitmapRepresentation_);
	tcase_add_test(tc_core, c_characterSetWithCharactersInString_);
	tcase_add_test(tc_core, c_characterSetWithContentsOfFile_);
	tcase_add_test(tc_core, c_characterSetWithRange_);
	tcase_add_test(tc_core, i_bitmapRepresentation);
	tcase_add_test(tc_core, i_characterIsMember_);
	tcase_add_test(tc_core, i_invertedSet);
	return (s);
}
