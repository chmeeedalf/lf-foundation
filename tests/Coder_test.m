#include <check.h>
#import <Foundation/NSCoder.h>
START_TEST(i_encodeArrayOfObjCType_count_at_) {
	fail_unless(0,
		"-[NSCoder encodeArrayOfObjCType:count:at:] failed.");
}
END_TEST

START_TEST(i_encodeBycopyObject_) {
	fail_unless(0,
		"-[NSCoder encodeBycopyObject:] failed.");
}
END_TEST

START_TEST(i_encodeConditionalObject_) {
	fail_unless(0,
		"-[NSCoder encodeConditionalObject:] failed.");
}
END_TEST

START_TEST(i_encodeDataObject_) {
	fail_unless(0,
		"-[NSCoder encodeDataObject:] failed.");
}
END_TEST

START_TEST(i_encodeObject_) {
	fail_unless(0,
		"-[NSCoder encodeObject:] failed.");
}
END_TEST

START_TEST(i_encodePropertyList_) {
	fail_unless(0,
		"-[NSCoder encodePropertyList:] failed.");
}
END_TEST

START_TEST(i_encodePoint_) {
	fail_unless(0,
		"-[NSCoder encodePoint:] failed.");
}
END_TEST

START_TEST(i_encodeRect_) {
	fail_unless(0,
		"-[NSCoder encodeRect:] failed.");
}
END_TEST

START_TEST(i_encodeRootObject_) {
	fail_unless(0,
		"-[NSCoder encodeRootObject:] failed.");
}
END_TEST

START_TEST(i_encodeSize_) {
	fail_unless(0,
		"-[NSCoder encodeSize:] failed.");
}
END_TEST

START_TEST(i_encodeValueOfObjCType_at_) {
	fail_unless(0,
		"-[NSCoder encodeValueOfObjCType:at:] failed.");
}
END_TEST

START_TEST(i_encodeValuesOfObjCTypes_) {
	fail_unless(0,
		"-[NSCoder encodeValuesOfObjCTypes:] failed.");
}
END_TEST

START_TEST(i_decodeArrayOfObjCType_count_at_) {
	fail_unless(0,
		"-[NSCoder decodeArrayOfObjCType:count:at:] failed.");
}
END_TEST

START_TEST(i_decodeDataObject) {
	fail_unless(0,
		"-[NSCoder decodeDataObject] failed.");
}
END_TEST

START_TEST(i_decodeObject) {
	fail_unless(0,
		"-[NSCoder decodeObject] failed.");
}
END_TEST

START_TEST(i_decodePropertyList) {
	fail_unless(0,
		"-[NSCoder decodePropertyList] failed.");
}
END_TEST

START_TEST(i_decodePoint) {
	fail_unless(0,
		"-[NSCoder decodePoint] failed.");
}
END_TEST

START_TEST(i_decodeRect) {
	fail_unless(0,
		"-[NSCoder decodeRect] failed.");
}
END_TEST

START_TEST(i_decodeSize) {
	fail_unless(0,
		"-[NSCoder decodeSize] failed.");
}
END_TEST

START_TEST(i_decodeValueOfObjCType_at_) {
	fail_unless(0,
		"-[NSCoder decodeValueOfObjCType:at:] failed.");
}
END_TEST

START_TEST(i_decodeValuesOfObjCTypes_) {
	fail_unless(0,
		"-[NSCoder decodeValuesOfObjCTypes:] failed.");
}
END_TEST

START_TEST(i_objectZone) {
	fail_unless(0,
		"-[NSCoder objectZone] failed.");
}
END_TEST

START_TEST(i_setObjectZone_) {
	fail_unless(0,
		"-[NSCoder setObjectZone:] failed.");
}
END_TEST

START_TEST(i_systemVersion) {
	fail_unless(0,
		"-[NSCoder systemVersion] failed.");
}
END_TEST

START_TEST(i_versionForClassName_) {
	fail_unless(0,
		"-[NSCoder versionForClassName:] failed.");
}
END_TEST

Suite *Coder_suite(void)
{
	Suite *s = suite_create("NSCoder");
	TCase *tc_core = tcase_create("Basic NSTest");
	suite_add_tcase(s, tc_core);

	tcase_add_test(tc_core, i_encodeArrayOfObjCType_count_at_);
	tcase_add_test(tc_core, i_encodeBycopyObject_);
	tcase_add_test(tc_core, i_encodeConditionalObject_);
	tcase_add_test(tc_core, i_encodeDataObject_);
	tcase_add_test(tc_core, i_encodeObject_);
	tcase_add_test(tc_core, i_encodePropertyList_);
	tcase_add_test(tc_core, i_encodePoint_);
	tcase_add_test(tc_core, i_encodeRect_);
	tcase_add_test(tc_core, i_encodeRootObject_);
	tcase_add_test(tc_core, i_encodeSize_);
	tcase_add_test(tc_core, i_encodeValueOfObjCType_at_);
	tcase_add_test(tc_core, i_encodeValuesOfObjCTypes_);
	tcase_add_test(tc_core, i_decodeArrayOfObjCType_count_at_);
	tcase_add_test(tc_core, i_decodeDataObject);
	tcase_add_test(tc_core, i_decodeObject);
	tcase_add_test(tc_core, i_decodePropertyList);
	tcase_add_test(tc_core, i_decodePoint);
	tcase_add_test(tc_core, i_decodeRect);
	tcase_add_test(tc_core, i_decodeSize);
	tcase_add_test(tc_core, i_decodeValueOfObjCType_at_);
	tcase_add_test(tc_core, i_decodeValuesOfObjCTypes_);
	tcase_add_test(tc_core, i_objectZone);
	tcase_add_test(tc_core, i_setObjectZone_);
	tcase_add_test(tc_core, i_systemVersion);
	tcase_add_test(tc_core, i_versionForClassName_);
	return (s);
}
