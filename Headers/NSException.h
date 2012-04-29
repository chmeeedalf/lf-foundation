/*
 * Copyright (c) 2004-2012	Justin Hibbits
 * All rights reserved.
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
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
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

@class NSArray, NSString, NSDictionary;

/*!
  @class NSException
  @brief The NSException class is used to create and raise exceptions.
  Additionally the class provides information regarding the thrown exception.
 */
__attribute__((__objc_exception__))
@interface NSException : NSObject <NSCopying>
{
	NSString *name;			/*!< @brief Name of this exception. */
	NSString *reason;			/*!< @brief Reason this exception was thrown. */
	NSDictionary *userInfo;	/*!< @brief Case-specific information for exception handling. */
	NSArray *returnAddresses;	/*!< @brief Call stack as of throwing the exception. */
}
@property(copy) NSString *name;
@property(copy) NSString *reason;
@property(copy) NSDictionary *userInfo;

// Class methods

/*!
 * @brief Creates and returns an exception object.
 * @param name The name of the exception.
 * @param reason The reason of raising the exception.
 * @param userInfo Extra information that may be necessary for the handler.
 * @result Returns an NSException object, which contains all information for
 * handling the exception.
 */
+(NSException *)exceptionWithName:(NSString *)name reason:(NSString *)reason
	userInfo:(NSDictionary *)userInfo;

// Instance methods
/*!
 * @brief Creates and returns an exception object.
 * @param name The name of the exception.
 * @param reason The reason of raising the exception.
 * @param userInfo Extra information that may be necessary for the handler.
 * @result Initializes a NSException object, which contains all information for
 * handling the exception.  You are responsible for releasing this object.
 */
-(id)initWithName:(NSString *)name reason:(NSString *)reason
	userInfo:(NSDictionary *)userInfo;

/*!
 * @brief Returns the name of the exception.
 */
-(NSString *)name;

/*!
 * @brief Returns the exception has been raised.
 */
-(NSString *)reason;

/*!
 * @brief Returns extra information for the exception.
 */
-(NSDictionary *)userInfo;

/*!
 * @brief Returns a string representation of the complete error, including name and reason.
 */
-(NSString *)errorString;

/*!
 * \brief Returns an array of the values corresponding to the call stack.
 */
- (NSArray *) callStackReturnAddresses;

- (NSArray *) callStackSymbols;
@end

/* specific exceptions */
/*!
 * @brief Base class for builtin exceptions.
 * @details All builtin exceptions are subclassed from StandardException.  This
 * provides a simplified interface for throwing exceptions, by using the
 * exception class name as the exception name in
 * +exceptionWithName:reason:userInfo:
 */
@interface NSStandardException : NSException
/*!
 * @brief Create a standard exception with the given parameters.
 * @param _reason NSException reason.
 * @param _info User-defined extra information to be displayed or used when
 * handling the exception.
 */
+ (NSStandardException *)exceptionWithReason:(NSString *)_reason userInfo:(NSDictionary *)_info;
@end

/*!
 * @brief System runtime exception class.
 * @details Exceptions related to the library runtime are subclasses of this
 * class.
 */
@interface NSRuntimeException : NSStandardException
@end

/*!
 * @brief NSException thrown when an assertion fails.  Implies an unexpected condition.
 */
@interface NSInternalInconsistencyException : NSRuntimeException
@end

/*!
 * @brief NSException thrown for the use of a method when not allowed.
 * @details Similar to InternalInconsistencyException and
 * InvalidArgumentException, this is thrown when an internal state does not
 * permit the use of a method.
 */
@interface NSInvalidUseOfMethodException : NSRuntimeException
@end

/*!
 * @brief NSException thrown when you pass an invalid argument to a method, such as a @c nil pointer when a non-@c nil pointer is required.
 */
@interface NSInvalidArgumentException : NSRuntimeException
@end

/*!
 * @brief NSException thrown when an out-of-memory condition is reached.
 */
@interface NSMemoryException : NSStandardException
@end

/*!
 * @brief NSException thrown when attempting to access outside the bounds of data.
 */
@interface NSRangeException : NSStandardException
@end

// Now for Assert stuff

#ifndef NDEBUG
#define NSAssert(cond, descr, ...) \
	do { \
		if (!(cond)) \
			[[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd \
			object:self file:@__FILE__ \
			lineNumber:__LINE__ description:descr,##__VA_ARGS__]; \
	} while (0)
#define NSExceptAssert(cond, except, uinfo, descr, ...) \
	do { \
		if (!(cond)) \
			[[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd \
				object:self exception:[except class] userInfo:uinfo file:@__FILE__ \
				lineNumber:__LINE__ description:descr,##__VA_ARGS__]; \
	} while (0)
#define NSCAssert(cond, descr, ...) \
	do { \
		if (!(cond)) \
			[[NSAssertionHandler currentHandler] handleFailureInFunction:\
				[NSString stringWithUTF8String:__func__] \
				file:[NSString stringWithUTF8String:__FILE__] lineNumber:__LINE__ \
				description:descr,##__VA_ARGS__]; \
	} while (0)
#else
#define NSAssert(cond, descr, ...)
#define NSCAssert(cond, descr, ...)
#endif

#define NSParameterAssert(condition) \
	NSExceptAssert(condition, NSInvalidArgumentException, nil, \
		@"Invalid parameter not satisfying: %@", \
		[NSString stringWithUTF8String:#condition])

#define NSCParameterAssert(condition) \
	NSCAssert(condition, @"Invalid parameter not satisfying: %@", \
		[NSString stringWithCString:#condition encoding:NSASCIIStringEncoding])

/*!
 * @brief Singleton class to handle assertion failures.
 */
@interface NSAssertionHandler : NSObject

/*!
 * @brief Returns the assertion handler for the current thread.
 */
+(NSAssertionHandler *)currentHandler;

/*!
 * @brief Logs an error in a function and raises an InternalconsistencyException.
 * @param functionName Name of the function where the error occured.
 * @param fileName Name of the problem file.
 * @param line Line number in the source code.
 * @param format,... Description of the error.
 */
-(void)handleFailureInFunction:(NSString *)functionName
	file:(NSString *)fileName lineNumber:(int)line
	description:(NSString *)format,...;

/*!
 * @brief Logs an error in a method and raises an InternalConsistencyException.
 * @param selector Selector corresponding to the method.
 * @param object NSObject associated with the failure.
 * @param fileName File the error occured in.
 * @param line Line in the source file.
 * @param format,... Description of the failure.
 */
-(void)handleFailureInMethod:(SEL)selector object:(id)object
	file:(NSString *)fileName lineNumber:(int)line
	description:(NSString *)format, ...;

/*!
 * @brief Logs an error in a method and raises an exception of the specified class.
 * @param selector Selector corresponding to the method.
 * @param object NSObject associated with the failure.
 * @param fileName File the error occured in.
 * @param line Line in the source file.
 * @param format,... Description of the failure.
 */
-(void)handleFailureInMethod:(SEL)selector object:(id)object
	exception:(Class)exceptClass userInfo:(NSDictionary *)userInfo
	file:(NSString *)fileName lineNumber:(int)line
	description:(NSString *)format, ...;

@end

/*
   vim:syntax=objc:
 */
