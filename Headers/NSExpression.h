/*
 * Copyright (c) 2010	Gold Project
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the Project nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE PROJECT ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSObject.h>

/*!
 * \file NSExpression.h
 */
@class NSArray, NSMutableDictionary, NSPredicate, NSSet, NSString;

typedef enum
{
	NSConstantValueExpressionType,
	NSEvaluatedObjectExpressionType,
	NSVariableExpressionType,
	NSKeyPathExpressionType,
	NSFunctionExpressionType,
	NSAggregateExpressionType,
	NSSubqueryExpressionType,
	NSUnionSetExpressionType,
	NSIntersectSetExpressionType,
	NSMinusSetExpressionType,
} NSExpressionType;

@interface NSExpression	:	NSObject
{
	NSExpressionType expressionType;
}
+ (NSExpression *)expressionForConstantValue:value;
+ (NSExpression *)expressionForEvaluatedObject;
+ (NSExpression *)expressionForKeyPath:(NSString *)keyPath;
+ (NSExpression *)expressionForVariable:(NSString *)variable;
+ (NSExpression *)expressionForAggregate:(NSArray *)aggregate;
+ (NSExpression *)expressionForUnionSet:(NSExpression *)left with:(NSExpression *)right;
+ (NSExpression *)expressionForIntersectSet:(NSExpression *)left with:(NSExpression *)right;
+ (NSExpression *)expressionForMinusSet:(NSExpression *)left with:(NSExpression *)right;
+ (NSExpression *)expressionForSubquery:(NSExpression *)expr usingIteratorVariable:(NSString *)var predicate:(id)pred;
+ (NSExpression *)expressionForFunction:(NSString *)func arguments:(NSArray *)args;
+ (NSExpression *)expressionForFunction:(NSExpression *)func selectorName:(NSString *)sel arguments:(NSArray *)args;
+ (NSExpression *)expressionForBlock:(id (^)(id, NSArray *, NSMutableDictionary *))block arguments:(NSArray *)args;
+ (NSExpression *)expressionWithFormat:(NSString *)_format,...;
+ (NSExpression *)expressionWithFormat:(NSString *)format arguments:(va_list)argList;
+ (NSExpression *)expressionWithFormat:(NSString *)_format 
  argumentArray:(NSArray *)_arguments;

- (id) initWithExpressionType:(NSExpressionType)type;
- (NSArray *)arguments;
- (id (^)(id, NSArray *, NSMutableDictionary *))expressionBlock;
- (id)collection;
- (id) constantValue;
- (NSExpressionType) expressionType;
- (id) expressionValueWithObject:(id)object context:(NSMutableDictionary *)context;
- (NSString *)function;
- (NSString *)keyPath;
- (NSExpression *)leftExpression;
- (NSExpression *)operand;
- (NSPredicate *)predicate;
- (NSExpression *)rightExpression;
- (NSString *) variable;
@end
