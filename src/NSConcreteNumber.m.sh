#!/bin/sh

template ()
{
NAME=$1
C=$2
METHOD=$3
FORMAT=$4
GENERALITY=$5

cat <<EOF

/*
 *  DO NOT EDIT! GENERATED AUTOMATICALLY FROM ConcreteNumber.m.sh.
 *  NS${NAME} concrete number
 */

@implementation NS${NAME}Number

+ (id)allocWithZone:(NSZone*)zone
{
	return NSAllocateObject (self, 0, zone);
}

- initValue:(const void*)value withObjCType:(const char*)type;
{
	[super init];
	data = *(${C}*)value;
	return self;
}

- (bool)boolValue
{
	return data;
}

- (char)charValue
{
	return data;
}

- (unsigned char)unsignedCharValue
{
	return data;
}

- (short)shortValue
{
	return data;
}

- (unsigned short)unsignedShortValue
{
	return data;
}

- (int)intValue
{
	return data;
}

- (unsigned int)unsignedIntValue
{
	return data;
}

- (long)longValue
{
	return data;
}

- (unsigned long)unsignedLongValue
{
	return data;
}

- (long long)longLongValue
{
	return data;
}

- (unsigned long long)unsignedLongLongValue
{
	return data;
}

- (float)floatValue
{
	return data;
}

- (double)doubleValue
{
	return data;
}

- (NSInteger) integerValue
{
	return data;
}

- (NSUInteger) unsignedIntegerValue
{
	return data;
}

- (NSString*)descriptionWithLocale:(NSLocale*)locale
{
	return [NSString stringWithFormat:@${FORMAT}, data];
}

- (int)generality
{
	return ${GENERALITY};
}

- (NSComparisonResult)compare:(NSNumber*)otherNumber
{
	if([self generality] >= [otherNumber generality])
	{
		${C} other_data = [otherNumber ${METHOD}Value];

		if (data == other_data)
		{
			return NSOrderedSame;
		} else {
			return (data < other_data) ?
				NSOrderedAscending
				: NSOrderedDescending;
		}
	}
	else
		/* -1, 0, 1 -- OrderedDescending, OrderedSame, OrderedAscending */
		return -[otherNumber compare:self];
}

// Override these from Value

- (void)getValue:(void*)value
{
	if (!value)
	{
		@throw [NSInvalidArgumentException
			exceptionWithReason:@"NULL buffer in -getValue" userInfo:nil];
	} else {
		*(${C}*)value = data;
	}
}

- (const char*)objCType
{
	return @encode(${C});
}

// Copying

- (id)copyWithZone:(NSZone*)zone
{
	if ([self zone] == zone)
	{
		return RETAIN(self);
	} else {
		return [[[NS${NAME}Number class] alloc]
			initValue:&data withObjCType:@encode(${C})];
	}
}
@end /* NS${NAME}Number */

EOF
}

#
# Generate common part
#

cat <<EOF
/*
 * Author: mircea
 */

#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#import <Foundation/NSCoder.h>
#import "NSConcreteNumber.h"

@interface NSNumber (Generality)
-(int)generality;
@end
EOF

template Bool	"bool"		bool		'"%d"'		1
template Char	"char"		char		'"%d"'		2
template UnsignedChar	"unsigned char"	unsignedChar	'"%d"'		3
template Short	"short"		short		'"%hd"'		4
template UnsignedShort	"unsigned short" unsignedShort	'"%hu"'		5
template Int	"int"		int		'"%d"'		6
template UnsignedInt	"unsigned int"	unsignedInt	'"%u"'		7
template Long	"long"		long		'"%ld"'		8
template UnsignedLong	"unsigned long"	unsignedLong	'"%lu"'		9
template LongLong "long long"	longLong	'"%lld"'	10
template UnsignedLongLong "unsigned long long"	unsignedLongLong '"%llu"' 11
template Integer	"NSInteger"		integer		'"%ld"'		12
template UnsignedInteger	"NSUInteger"		unsignedInteger		'"%lu"'		13
template Float	"float"		float		'"%0.7g"'	14
template Double	"double"	double		'"%0.16g"'	15

