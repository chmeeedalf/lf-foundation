/* 
   PredicateParser.m
 * All rights reserved.

   Copyright (C) 2000-2005 SKYRIX Software AG
   All rights reserved.
   
   Author: Helge Hess <helge.hess@opengroupware.org>

   This file is part of libSystem.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.
 */

#define BOOST_SPIRIT_DEBUG
#include <functional>
#include <vector>
#include <boost/spirit/include/qi.hpp>
#include <boost/spirit/include/phoenix.hpp>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSPredicate.h>
#import <Foundation/NSComparisonPredicate.h>
#import <Foundation/NSCompoundPredicate.h>
#import <Foundation/NSExpression.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSException.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSMapTable.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDate.h>
#import <Alepha/Objective/Object.h>

typedef Alepha::Objective::Object<id> AlephaId;

/* parsing functions */

static NSPredicate *_parsePredicates(id _ctx, const char *_buf,
                                     unsigned _bufLen, unsigned *_predLen);
static inline unsigned _countWhiteSpaces(const char *_buf, unsigned _bufLen);

@interface PredicateParserContext : NSObject
{
	NSMapTable *predicateCache;
}
@end

@interface PredicateVAParserContext : PredicateParserContext
{
	va_list    *va;  
}
+ (id)contextWithVaList:(va_list)_va;
@end

@interface PredicateEnumeratorParserContext : PredicateParserContext
{
	NSEnumerator *enumerator;
}
+ (id)contextWithEnumerator:(NSEnumerator *)_enumerator;
@end

@implementation PredicateVAParserContext

+ (id)contextWithVaList:(va_list)_va
{
	return nil;
}

@end /* PredicateVAParserContext */

@implementation PredicateEnumeratorParserContext

+ (id)contextWithEnumerator:(NSEnumerator *)_enumerator
{
	return nil;
}

@end /* PredicateEnumeratorParserContext */

@implementation PredicateParserContext
@end /* PredicateParserContext */

@implementation NSPredicate(Parsing)

+ (NSPredicate *)predicateWithFormat:(NSString *)_format,...
{
	va_list     va;
	va_start(va, _format);
	return [self predicateWithFormat:_format arguments:va];
	va_end(va);

}

+ (NSPredicate *)predicateWithFormat:(NSString *)_format 
  argumentArray:(NSArray *)_arguments
{
	NSPredicate *qual  = nil;
	unsigned    length = 0;
	const char  *buf   = NULL;
	unsigned    bufLen = 0;
	PredicateEnumeratorParserContext *ctx;

	ctx = [PredicateEnumeratorParserContext contextWithEnumerator:
		[_arguments objectEnumerator]];

	//NSLog(@"qclass: %@", [_format class]);
	buf    = [_format UTF8String];
	bufLen = strlen(buf);
	qual   = _parsePredicates(ctx, buf, bufLen, &length);

	if (qual != nil) { /* check whether the rest of the string is OK */
		if (length < bufLen) {
			length += _countWhiteSpaces(buf + length, bufLen - length);
		}
		if (length != bufLen) {
			NSLog(@"WARNING(%s): unexpected chars at the end of the string '%@'",
					__func__, _format);
			qual = nil;
		}
	}
	return qual;
}
 
+ (NSPredicate *) predicateWithFormat:(NSString *)_format arguments:(va_list)args
{
	NSPredicate *qualifier;
	unsigned    length = 0;
	const char  *buf;
	unsigned    bufLen;
	char        *cbuf;

	cbuf = strdup([_format UTF8String]);
	bufLen = strlen(cbuf);
	buf = cbuf;

	qualifier =
		_parsePredicates([PredicateVAParserContext contextWithVaList:args],
				buf, bufLen, &length);
	free(cbuf);
	return qualifier;
}

@end /* NSPredicate(Parsing) */

using namespace boost::spirit;

static inline void null_func() {}

static inline AlephaId makeComparisonPredicate(NSPredicateOperatorType type, id lhs,
		id rhs)
{
	return [NSComparisonPredicate predicateWithLeftExpression:lhs
		rightExpression:rhs modifier:NSDirectPredicateModifier type:type options:0];
}

static inline AlephaId makeCompoundPredicate(NSCompoundPredicateType type,
		NSArray *subs)
{
	if ([subs count] == 1)
		return [subs firstObject];
	NSCompoundPredicate *outPred = [[NSCompoundPredicate alloc]
		initWithType:type subpredicates:subs];
	return outPred;
}

static inline AlephaId makeNotPredicate(id pred)
{
	return [NSCompoundPredicate notPredicateWithSubpredicate:pred];
}

static inline AlephaId makeBinExpr(id expr1, NSString *binOp, id expr2)
{
	return [NSNull null];
}

static inline AlephaId makeExpr(SEL sel, id val)
{
	return ([NSExpression methodForSelector:sel])([NSExpression class], sel, val);
}

static inline void addObject(id arr, id obj)
{
	[arr addObject:obj];
}

static inline AlephaId makeArray()
{
	return [NSMutableArray new];
}

static inline id makeString(std::string utf8String)
{
	return [NSString stringWithUTF8String:utf8String.c_str()];
}

#if 0
static inline id makeStringFromVec(std::vector<char> input)
{
	return makeString(std::string(input.begin(), input.end()));
}
#endif

static inline AlephaId makeStringFromRange(boost::iterator_range<std::string::const_iterator> input)
{
	return makeString(std::string(input.begin(), input.end()));
}

static inline AlephaId makeFuncExpressionNoArg(std::string name, id arg)
{
	NSLog(@"%s(%@)", name.c_str(), arg);
	return [NSExpression expressionForFunction:makeString(name)
		arguments:[NSArray arrayWithObject:arg]];
}

static inline AlephaId makeFuncExpression(std::string name,
		std::vector<AlephaId > args)
{
	std::vector<id> argvec;

	std::copy(args.begin(), args.end(), argvec.begin());
	return [NSExpression expressionForFunction:makeString(name)
		arguments:[NSArray arrayWithObjects:&argvec[0] count:argvec.size()]];
}

#define MakeNum(type, numType, suffix) \
	static inline AlephaId makeNumber##suffix(type x) { return [NSNumber numberWith##numType:x]; } \
	struct hack

MakeNum(float, Float, F);
MakeNum(double, Double, D);
MakeNum(int, Int, I);
MakeNum(unsigned, UnsignedInt, U);
MakeNum(unsigned short, UnsignedShort, US);
MakeNum(unsigned long, UnsignedLong, UL);
MakeNum(unsigned long long, UnsignedLongLong, ULL);
MakeNum(short, Short, S);
MakeNum(long, Long, L);
MakeNum(long long, LongLong, LL);

template <typename Iterator>
struct predicateGrammar	:	qi::grammar<Iterator, AlephaId(), ascii::space_type>
{
	struct operators_	:	boost::spirit::qi::symbols<char, NSPredicateOperatorType>
	{
		operators_()
		{
			add("=", NSEqualToPredicateOperatorType)
				("==", NSEqualToPredicateOperatorType)
				("!=", NSNotEqualToPredicateOperatorType)
				("<>", NSNotEqualToPredicateOperatorType)
				("<", NSLessThanPredicateOperatorType)
				("<=", NSLessThanOrEqualToPredicateOperatorType)
				(">", NSGreaterThanPredicateOperatorType)
				(">=", NSGreaterThanOrEqualToPredicateOperatorType)
				("BETWEEN", NSBetweenPredicateOperatorType);
		}
	} operators;

	struct comparison_modifier_	:
		boost::spirit::qi::symbols<char, int>
	{
		comparison_modifier_()
		{
			add("ANY", NSAnyPredicateModifier)
				("ALL", NSAllPredicateModifier)
				// TODO: SOME and NONE
				("NONE", -NSAnyPredicateModifier)
				("SOME", NSAnyPredicateModifier);
		}
	} comparison_modifier;

	struct and_operators_	:	boost::spirit::qi::symbols<char, NSCompoundPredicateType>
	{
		and_operators_()
		{
			add("AND", NSAndPredicateType)
				("&&", NSAndPredicateType);
		}
	} and_operators;

	struct or_operators_	:	boost::spirit::qi::symbols<char, NSCompoundPredicateType>
	{
		or_operators_()
		{
			add("OR", NSOrPredicateType)
				("||", NSOrPredicateType);
		}
	} or_operators;

	struct binary_operators_	:	boost::spirit::qi::symbols<char, NSString *>
	{
		binary_operators_()
		{
			add("+", @"_add")
				("-", @"_sub")
				("*", @"_mult")
				("/", @"_div")
				("**", @"_pow");
		}
	} binary_operators;

	struct aggregate_operator_	:	boost::spirit::qi::symbols<char, NSPredicateOperatorType>
	{
		aggregate_operator_()
		{
			add("BEGINSWITH", NSBeginsWithPredicateOperatorType)
				("ENDSWITH", NSEndsWithPredicateOperatorType)
				("CONTAINS", NSContainsPredicateOperatorType)
				("IN", NSInPredicateOperatorType)
				("LIKE", NSLikePredicateOperatorType)
				("MATCHES", NSMatchesPredicateOperatorType);
		}
	} aggregate_operator;

	predicateGrammar()	:	predicateGrammar::base_type(predicate)
	{
		using qi::lexeme;
		using qi::lit;
		using ascii::char_;
		using ascii::string;
		using ascii::alpha;
		using ascii::alnum;
		using qi::_val;
		using qi::_1;
		using qi::_2;
		using qi::_3;
		using qi::no_case;
		using boost::phoenix::bind;
		using qi::debug;

		predicate %= compoundPredicate
			| lit("TRUEPREDICATE") [_val =
			AlephaId([NSPredicate predicateWithValue:true])]
			| lit("FALSEPREDICATE") [_val = 
			AlephaId([NSPredicate predicateWithValue:false])]
			;
		compoundPredicate = andPredicate
			;
		andPredicate %= qi::eps[_a = bind(makeArray)] >> (
				orPredicate[bind(addObject, _a, _1)] % and_operators )
				[_val = bind(makeCompoundPredicate, NSAndPredicateType, _a)]
			;
		orPredicate %= qi::eps[_a = bind(makeArray)] >> (
				notPredicate[bind(addObject, _a, _1)] % or_operators )
				[_val = bind(makeCompoundPredicate, NSOrPredicateType, _a)]
			;
		notPredicate %= ("(" >> predicate > ")")
			| (lit("NOT")|'!') >> predicate
				[_val = bind(makeNotPredicate, _1)]
			| comparisonPredicate
			;
		comparisonPredicate %= (-comparison_modifier >> expression >> operators >> expression)
				[_val = bind(makeComparisonPredicate, _3, _2, _4)]
			| (expression >> aggregate_operator >> -(lit("[") >> (lit("c") | "d" | "cd") >> "]") >> expression)
				[_val = bind(makeComparisonPredicate, _2, _1, _3)]
			;
		expression %= assignment_expression;
		assignment_expression %= binary_expression
			| predicate_variable >> ":=" >> binary_expression;
		binary_expression %= function_expression
			| (expression >> binary_operators >> expression)
				[_val = bind(makeBinExpr, _1, _2, _3)]
			| "-" >> expression
				[_val = bind(makeFuncExpressionNoArg, "_negate", _1)]
			;
		function_expression %= (function_name >> "(" >> expression % ',' > ")")
			[_val = bind(makeFuncExpression, _1, _2)]
			| index_expression
			;
		index_expression %= (keypath_expression >> '[' >> "FIRST" >> ']')
				[_val = bind(makeFuncExpressionNoArg, "_first", _1)]
			| (keypath_expression >> '[' >> "LAST" >> ']')
				[_val = bind(makeFuncExpressionNoArg, "_last", _1)]
			| (keypath_expression >> '[' >> "SIZE" >> ']')
				[_val = bind(makeFuncExpressionNoArg, "_size", _1)]
			| (keypath_expression >> '[' >> expression >> ']')
				[_val = bind(makeFuncExpressionNoArg, "_second", _1)]
			| keypath_expression
			;
		keypath_expression %= simple_expression >> -(lit('.') >> simple_expression)
			;
		simple_expression %= value_expression
			| (-lit('@') >> identifier) [_val = bind(makeExpr, @selector(expressionForKeyPath:), _1)]
			;
		value_expression %= literal_value | literal_aggregate
			| ("(" >> expression > ")");

		literal_value %= string_value [_val = bind(makeExpr, @selector(expressionForConstantValue:), _1)]
			| numeric_value [_val = bind(makeExpr, @selector(expressionForConstantValue:), _1)]
			| predicate_argument
				[_val = AlephaId([NSNull null])]
			| predicate_variable [_val = bind(makeExpr, @selector(expressionForVariable:), _1)]
			| lit("NULL") [_val = AlephaId([NSExpression expressionForConstantValue:nil])]
			| lit("TRUE") [_val = AlephaId([NSExpression expressionForConstantValue:[NSNumber numberWithBool:true]])]
			| lit("FALSE") [_val = AlephaId([NSExpression expressionForConstantValue:[NSNumber numberWithBool:false]])]
			| lit("SELF") [_val = AlephaId([NSExpression expressionForEvaluatedObject])]
			;
#if 0
		string_value %= ('"' >> no_skip[+(char_ - '"')] >> '"')
				//[_val = bind(makeStringFromVec, _1)]
			| ('\'' >> no_skip[+(char_ - '\'')] >> '\'')
				//[_val = bind(makeStringFromVec, _1)]
			;
#endif
		numeric_value %= float_ [_val = bind(makeNumberF, _1)]
			| double_ [_val = bind(makeNumberD, _1)]
			| bin [_val = bind(makeNumberU, _1)]
			| oct [_val = bind(makeNumberU, _1)]
			| lit("0x") >> hex [_val = bind(makeNumberU, _1)]
			| ushort_ [_val = bind(makeNumberUS, _1)]
			| ulong_ [_val = bind(makeNumberUL, _1)]
			| uint_ [_val = bind(makeNumberU, _1)]
			| ulong_long [_val = bind(makeNumberULL, _1)]
			| short_ [_val = bind(makeNumberS, _1)]
			| long_ [_val = bind(makeNumberL, _1)]
			| int_ [_val = bind(makeNumberI, _1)]
			| long_long [_val = bind(makeNumberLL, _1)]
			;
		predicate_argument %= '%' > format_argument;
		format_argument %= lit("@") | "%" | "K";
		predicate_variable %= (lit('$') > identifier);
		literal_aggregate %= ('{' >> (expression % ',') >> '}') [_val =
			AlephaId(nil)];
		aggregate_expression %= array_expression
			| dictionary_expression
			;
		function_name %= string("sum") | string("count") | string("min") | string("max")
			| string("average") | string("median") | string("mode") | string("stddev")
			| string("sqrt") | string("log") | string("ln") | string("expr")
			| string("floor") | string("ceiling") | string("abs") | string("trunc")
			| string("random") | string("randomn") | string("now")
			;
		array_expression %= expression;
		dictionary_expression %= expression;
		integer_expression %= expression;
		identifier %= (raw[(alpha | '_') >> *(alnum | '_')])
				[_val = bind(makeStringFromRange, _1)]
			;
		qi::on_error<qi::fail>(notPredicate, bind(null_func));
		qi::on_error<qi::fail>(function_expression, bind(null_func));
		predicate.name("predicate");
		function_name.name("function_name");
		function_expression.name("function_expression");
		binary_expression.name("binary_expression");
		assignment_expression.name("assignment_expression");
		array_expression.name("array_expression");
		dictionary_expression.name("dictionary_expression");
		index_expression.name("index_expression");
		keypath_expression.name("keypath_expression");
		expression.name("expression");
		compoundPredicate.name("compoundPredicate");
		comparisonPredicate.name("comparisonPredicate");
		aggregate_expression.name("aggregate_expression");
		integer_expression.name("integer_expression");
		value_expression.name("value_expression");
		string_value.name("string_value");
		numeric_value.name("numeric_value");
		literal_value.name("literal_value");
		literal_aggregate.name("literal_aggregate");
		identifier.name("identifier");
		predicate_variable.name("predicate_variable");
		predicate_argument.name("predicate_argument");
		format_argument.name("format_argument");
#if 0
		debug(predicate);
		debug(function_name);
		debug(function_expression);
		debug(binary_expression);
		debug(assignment_expression);
		debug(array_expression);
		debug(dictionary_expression);
		debug(index_expression);
		debug(keypath_expression);
		debug(expression);
		debug(compoundPredicate);
		debug(comparisonPredicate);
		debug(aggregate_expression);
		debug(integer_expression);
		debug(value_expression);
		debug(string_value);
		debug(numeric_value);
		debug(literal_value);
		debug(literal_aggregate);
		debug(identifier);
		debug(predicate_variable);
		debug(predicate_argument);
		debug(format_argument);
#endif
	}

	qi::rule<Iterator, AlephaId(), ascii::space_type> predicate;
	qi::rule<Iterator, std::string(), ascii::space_type> function_name;
	qi::rule<Iterator, AlephaId(), ascii::space_type> function_expression;
	qi::rule<Iterator, AlephaId(), ascii::space_type> binary_expression;
	qi::rule<Iterator, AlephaId(), ascii::space_type> assignment_expression;
	qi::rule<Iterator, AlephaId(), ascii::space_type> array_expression;
	qi::rule<Iterator, AlephaId(), ascii::space_type> dictionary_expression;
	qi::rule<Iterator, AlephaId(), ascii::space_type> index_expression;
	qi::rule<Iterator, AlephaId(), ascii::space_type> keypath_expression;
	qi::rule<Iterator, AlephaId(), ascii::space_type> simple_expression;
	qi::rule<Iterator, AlephaId(), ascii::space_type> expression;
	qi::rule<Iterator, AlephaId(), ascii::space_type> compoundPredicate;
	qi::rule<Iterator, AlephaId(), ascii::space_type> comparisonPredicate;
	qi::rule<Iterator, AlephaId(), ascii::space_type> aggregate_expression;
	qi::rule<Iterator, AlephaId(), ascii::space_type> integer_expression;
	qi::rule<Iterator, AlephaId(), ascii::space_type> value_expression;
	qi::rule<Iterator, AlephaId(), ascii::space_type> string_value;
	qi::rule<Iterator, AlephaId(), ascii::space_type> numeric_value;
	qi::rule<Iterator, AlephaId(), ascii::space_type> literal_value;
	qi::rule<Iterator, AlephaId(), ascii::space_type> literal_aggregate;
	qi::rule<Iterator, AlephaId(), ascii::space_type> identifier;
	qi::rule<Iterator, AlephaId(), ascii::space_type> predicate_variable;
	qi::rule<Iterator, AlephaId(), qi::locals<id>, ascii::space_type> andPredicate;
	qi::rule<Iterator, AlephaId(), qi::locals<id>, ascii::space_type> orPredicate;
	qi::rule<Iterator, AlephaId(), ascii::space_type> notPredicate;
	qi::rule<Iterator, ascii::space_type> predicate_argument;
	qi::rule<Iterator> format_argument;
};

static NSPredicate *_parsePredicates(id _ctx, const char *_buf, unsigned _bufLen,
                                     unsigned *_predLen)
{
	predicateGrammar<std::string::const_iterator> p;
	const std::string s(_buf, _bufLen);
	id predicate;

	try
	{
		if (phrase_parse(s.begin(), s.end(), ascii::no_case[p], ascii::space, predicate))
			return predicate;
	}
	catch (qi::expectation_failure<const char*>)
	{
	}
	return nil;
}

static inline unsigned _countWhiteSpaces(const char *_buf, unsigned _bufLen)
{
	unsigned cnt = 0;

	if (_bufLen == 0) {
		return 0;
	}

	while (_buf[cnt] == ' ' || _buf[cnt] == '\t' || 
			_buf[cnt] == '\n' || _buf[cnt] == '\r') {
		cnt++;
		if (cnt == _bufLen)
			break;
	}
	return cnt;
}
