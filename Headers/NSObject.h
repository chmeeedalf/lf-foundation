/*-
 * Copyright (c) 2004-2012	Gold Project
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

/*!
  \file NSObject.h
 */
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/Memory.h>
/* We're blocking out parts of this that are Objective-C specific for internal
 * reasons.
 */
#ifdef __OBJC__
#import <Foundation/NSRange.h>

__BEGIN_DECLS
#ifndef DOXYGEN_SHOULD_SKIP_THIS
@class NSArray, NSString, NSCoder, NSData, NSInvocation;
@class NSArchiver, NSKeyedArchiver, NSMethodSignature, NSPortCoder, Protocol, NSTimer;
#endif

/*!
 \protocol NSObject
 \brief All root classes should conform to this protocol, to make it easier to send messages.

 \details The NSObject protocol provides a standard interface for all types of
 objects.  All classes should conform to this protocol.
 */
@protocol NSObject

/*!
 \brief Returns a hash value of the object to use in hash tables.

 \details Returns a hash value of the object for use in hash tables.
 Equivalent objects must return the same hash.
 */
-(NSHashCode)hash;

/*!
 \brief Checks if this object is equal to anObject.

 \details Returns true if the object is equal to anObject.
 */
-(bool)isEqual:(id)anObject;

/*!
 \brief Returns the receiver.
 */
-(id)self;

// Identifying class and superclass
/*!
 \brief Returns the class type (meta object) of this object.

 The class meta object is the heart of the Objective-C runtime, providing data
 about the class layout and all messages it responds to.
 */
-(Class)class;

/*!
 \brief Returns the superclass of this object.
 */
-(Class)superclass;

// Determining allocation zones
/*!
 \brief Returns the allocation zone of the object.
 */
-(NSZone *)zone;

// sending messages determined at runtime
/*!
 * \brief Call a method determined at runtime, with no arguments.
 * \param aSelector Selector of method to call.
 */
-(id)performSelector:(SEL)aSelector;

/*!
 * \brief Call a method determined at runtime with a single argument.
 * \param aSelector Selector of method to call.
 * \param anObject NSObject to pass as the argument to the method.
 */
-(id)performSelector:(SEL)aSelector withObject:(id)anObject;

/*!
 * \brief Call a method determined at runtime with two arguments.
 * \param aSelector Selector of method to call.
 * \param anObject NSObject to pass as the first argument to the method.
 * \param anotherObject NSObject to pass as the second argument to the method.
 */
-(id)performSelector:(SEL)aSelector withObject:(id)anObject
	withObject:(id)anotherObject;

// Identifying proxies
/*!
 \brief Returns whether this object is a proxy or descended from NSObject.
 */
-(bool)isProxy;

// Testing inheritance relationships
/*!
 \brief Tests if this object is of the given class or a subclass.
 */
-(bool)isKindOfClass:(Class)aClass;

/*!
 \brief Tests if this object is of the given class (not subclass).
 */
-(bool)isMemberOfClass:(Class)aClass;

// Testing for protocol conformance
/*!
 * \brief Return if the class of the object conforms to a given protocol.
 * \param aProtocol Protocol to check for conformance with.
 * \returns \c true if the object's class conforms to the protocol, else \c
 * false.
 */
-(bool)conformsToProtocol:(Protocol *)aProtocol;

// Testing class functionality
/*!
 * \brief Return if the object responds to a selector.
 * \param aSelector Selector to check.
 * \returns \c true if the object responds to the selector, else \c false.
 */
-(bool)respondsToSelector:(SEL)aSelector;

// Describing the object
/*!
 * \brief Return a string description of the object.
 */
-(NSString *)description;
@end

/*!
  \protocol Copying
  \brief Conform to this protocol if you differentiate between mutable and
  immutable copying.
 */
@protocol NSCopying
/*!
 * \brief Make a copy of the receiver.
 * \param zone Zone into which to create the copy.
 * \returns A copy of the receiver, created in the given zone.
 */
-(id)copyWithZone:(NSZone *)zone;
@end

/*!
  \protocol MutableCopying
  \brief Conform to this protocol if you differentiate between mutable and
  immutable copying.
 */
@protocol NSMutableCopying
/*!
 * \brief Make a mutable copy of the receiver.
 * \param zone Zone into which to create the copy.
 * \returns A copy of the receiver, created in the given zone.
 */
-(id)mutableCopyWithZone:(NSZone *)zone;
@end

@class NSCoder;
@protocol NSCoding
- (id)initWithCoder:(NSCoder *)coder;
- (void) encodeWithCoder:(NSCoder *)coder;
@end

/*!
 \brief Root class of most of the System framework.

 \details NSObject is the root class for most of the System framework.  All
 classes are therefore derived from this class, and implicitly inherit the
 NSObject protocol (Identical to NSObject, with some extensions).  This class
 provides the basic functions for most objects, such as creation, comparison,
 typing, copying, describing, and gathering information.
 */
@interface NSObject <NSObject>
{
	Class isa;	/*!< \brief Pointer to the class definition. */
	// New for Gold!
	// Doesn't work yet, so commented out
	// NSString *comment;
}

+ (void) initialize;
+ (void) load;

// creating and destroying instances
/*!
 \brief allocate an object using the default zone.

 \details Allocate an object using the default zone.  Returns only
 allocated memory, so you must call an init method.
 */
+(id)alloc;

/*!
 \brief allocate an object using the given zone.
 \param zone Zone to create object from.

 \details Allocate an object using the given zone.  Returns only
 allocated memory, so you must call an init method.
 */
+(id)allocWithZone:(NSZone*)zone;

/*!
 \brief Initialize an object.

 \details Initializes the memory of an object.
 */
-(id)init;

/*!
 \brief Clones this object.

 \details Creates a copy of this object.  Actual copy depends on class,
 since immutable objects may decide to just copy the reference, while mutable
 objects copy the referenced memory.
 */
-(id)copy;

/*!
 \brief Returns self.
 \param zone Zone into which to copy.

 \details Included so class objects can be used in situations where you need
 an object conforming to the Copying protocol.
 */
+(id)copyWithZone:(NSZone *)zone;

/*!
 \brief Clones this object for modification.

 \details Creates a copy of this object.  Actual copy depends on class,
 since immutable objects may decide to just copy the reference, while mutable
 objects copy the referenced memory.
 */
-(id) mutableCopy;
+(id) mutableCopyWithZone:(NSZone *)zone;

/*!
 \brief Deallocates an object and cleans up its instance variables.
 */
-(void)dealloc;

/*!
 \brief Allocate a new object.

 \details Allocates a new object and initializes it.  Shorthand for
 [[NSObject alloc] init].
 */
+(id)new;


// ideintifying classes
/*!
 * \brief Returns the class pointer of the receiver.
 */
+(Class)class;

/*!
 * \brief Returns the parent class of the receiver.
 */
+(Class)superclass;

+(bool) isSubclassOfClass:(Class)superclass;

// Testing class functionality
/*!
 \brief Checks if instances of this class respond to the given selector.
 */
+(bool)instancesRespondToSelector:(SEL)aSelector;

// Testing protocol conformance
/*!
 \brief Check if the class conforms to a given protocol.
 \param aProtocol Protocol to check for.
 */
+(bool)conformsToProtocol:(Protocol *)aProtocol;

// Obtaining method information
/*!
 \brief Returns the method for the given selector.
 \param aSelector Selector to get the method of.

 Returns the method for the given selector, or NULL if it doesn't
 exist.
 */
-(IMP)methodForSelector:(SEL)aSelector;

/*!
 \brief Returns the method for the given selector.
 \param aSelector Selector to get the method for.

 \details Returns the method for the given selector, or NULL if it doesn't
 exist.
 */
+(IMP)instanceMethodForSelector:(SEL)aSelector;

/*!
 \brief Returns a description of the aSelector method, or nil if it
 doesn't exist.
 \param aSelector Selector to get the signature for.
 */
+ (NSMethodSignature*)instanceMethodSignatureForSelector:(SEL)aSelector;

/*!
 \brief Returns a description of the aSelector method, or nil if it
 doesn't exist.
 \param aSelector Selector to find the method signature for.
 */
-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;

// Describing Objects
/*!
 \brief Returns a description of the object.

 Returns a description of the object.  By default, NSObject
 returns the class name and the address of the object.
 */
+(NSString *)description;

// Discardable Content Proxy Support

- (id) autoContentAccessingProxy;

// Error handling
/*!
 \brief Handle selectors the object does not respond to.
 \param aSelector Selector the class does not respond to.
 \throws InternalInconsistencyException
 */
-(void)doesNotRecognizeSelector:(SEL)aSelector;

// Forwarding messages
/*!
 \brief Forwards an invocation that's not recognized as a selector.
 \param anInvocation Invocation to forward through the target.

 Forwards an invocation not recognized as a selector.  By default
 it just calls -doesNotRecognizeSelector:
 */
-(void)forwardInvocation:(NSInvocation *)anInvocation;
- (id) forwardingTargetForSelector:(SEL)sel;

// Dynamically Resolving Methods
+ (bool) resolveClassMethod:(SEL)selector;
+ (bool) resolveInstanceMethod:(SEL)selector;

// Archiving
- (id) awakeAfterUsingCoder:(NSCoder *)coder;
- (Class) classForArchiver;
- (Class) classForCoder;
- (Class) classForKeyedArchiver;
+ (NSArray *) classFallbacksForKeyedArchiver;
+ (Class) classForKeyedUnarchiver;
- (Class) classForPortCoder;
- (id) replacementObjectForArchiver:(NSArchiver *)archiver;
- (id) replacementObjectForCoder:(NSCoder *)coder;
- (id) replacementObjectForKeyedArchiver:(NSKeyedArchiver *)archiver;
- (id) replacementObjectForPortCoder:(NSPortCoder *)coder;

/*!
 \brief NSSet the current version of the class.
 \param version New class version.
 */
+(void)setVersion:(int)version;

/*!
 \brief Get the current version of the class.
 */
+(int)version;

// Scripting support
/*!
 * \brief Return a string representation of the receiver's class name.
 */
-(NSString *)className;

@end

/*!
 \category NSObject(GNU)
 \brief GNU extensions to the NSObject class.  Compatibility only.
 */
@interface NSObject (GNU)
/*!
 * \brief Throw an exception when a method is called whose implementation is the
 * responsibility of a concrete subclass.
 * \param aSel Selector that should be implemented by the subclass.
 * \throw InternalInconsistencyException
 */
- (id) subclassResponsibility:(SEL)aSel;

/*!
 * \brief Throw an exception when a method is called which never should be.
 * \param aSel Selector for method that should never be called.
 * \throw InternalInconsistencyException
 */
- (id) shouldNotImplement:(SEL)aSel;

/*!
 * \brief Throw an exception when a method is called which is not (yet)
 * implemented.
 * \param aSel Selector for method that is not implemented.
 * \throw InternalInconsistencyException
 */
- (id) notImplemented:(SEL)aSel;
@end

@interface NSObject (ComparisonMethods)
- (bool) isLessThan:other;
- (bool) isGreaterThan:other;
- (bool) isEqualTo:other;
- (bool) isGreaterthanOrEqualto:other;
- (bool) isLessThanOrEqualTo:other;
- (bool) isNotEqualTo:other;
- (bool) doesContain:other;
@end

@interface NSObject(Gold)
- (void)log;
@end

/*!
 * \category NSObject(Introspection)
 * \brief Introspection extensions for the NSObject class.  Lets you inspect a
 * class's instance variables for debugging.
 */
@interface NSObject(Introspection)
/*!
 * \brief Return a string representation of the exact contents of the receiver.
 *
 * \details Unlike [NSObject description] this method iterates over the receiver's
 * instance variables and creates a string representation of the exact contents
 * of the receiver.  Should not be overridden by subclasses.
 */
- (NSString *) inspect;
@end

/*!
  \class Protocol
  \brief Definition for a specific protocol.

  \details  The Protocol class describes an Objective-C protocol.  This can be
  passed to \c -conformsTo:, as well as being usable as any other Objective-C
  object.
 */
@interface Protocol : NSObject
{
@private
	char *name;
	struct objc_protocol_list *protocols;
}

/*!
 \brief Check if the protocol conforms to a given protocol.
 \param proto Protocol to check for.
 */
- (bool) conformsToProtocol:(Protocol *)proto;

/*!
 * \brief Return the description of the instance method with the given selector.
 * \param sel Sel of method to describe.
 */
- (struct objc_method_description *)descriptionForInstanceMethod:(SEL)sel;

/*!
 * \brief Return the description of the class method with the given selector.
 * \param sel Sel of method to describe.
 */
- (struct objc_method_description *)descriptionForClassMethod:(SEL)sel;
@end

@protocol NSDiscardableContent<NSObject>
- (bool) beginContentAccess;
- (void) endContentAccess;

- (void) discardContentIfPossible;
- (bool) isContentDiscarded;
@end

// Now for extra functions....

/*!
 \brief Allocates and returns a pointer for a class instance.
 \param aClass Class object to create an instance of.
 \param extraBytes Extra byte count to allocate for the object.
 \param zone Zone from which to allocate the object, or NULL.
 \return Allocated object.

 \details Allocates and returns a pointer for a class instance object.  If
 zone is NULL it will allocate from DefaultZone().
 */
id NSAllocateObject(Class aClass, size_t extraBytes, NSZone *zone);

/*!
 \brief Copies an object.
 \param anObject NSObject which to copy.
 \param extraBytes Extra byte count to allocate for the object.
 \param zone Zone from which to allocate the object, or NULL.
 \return Allocated object.

 \details Creates an exact copy of an NSObject instance  If
 zone is NULL it will allocate from DefaultZone().
 */
id NSCopyObject(id<NSObject> anObject, size_t extraBytes, NSZone *zone);

/*!
 \brief Deallocates an object created with AllocateObject.
 \param anObject NSObject to deallocate.  It must have been allocated with AllocateObject.
 */
void NSDeallocateObject(id<NSObject> anObject);

/*!
 \brief Returns true if the object can be retained in this zone.
 \param anObject NSObject to check for retainability.
 \param requestedZone Zone to check.
 \return true if requestedZone is NULL, the default zone, or anObject's zone.
 */
bool NSShouldRetainWithZone(id<NSObject> anObject, NSZone *requestedZone);
#endif

/*!
 \brief Returns the class object given by the specified name, or nil if none exists.
 \param aClassName Name of the class to return.
 */
Class NSClassFromString(NSString *aClassName);

/*!
 \brief Returns the selector named by the specified name, or zero if none exists.
 \param aSelectorName Name of the selector to return.
 */
SEL NSSelectorFromString(NSString *aSelectorName);

/*!
 \brief Returns an NSString containing the name of the given class.
 \param aClass Class to name.
 */
NSString *NSStringFromClass(Class aClass);

/*!
 \brief Returns an NSString containing the name of the given selector.
 \param aSelector Selector to name.
 */
NSString *NSStringFromSelector(SEL aSelector);

// Forwarding messages...

#ifdef __OBJC__
@class NSString;
#else
typedef struct NSString NSString;
#endif

/*!
 \brief Log a message to <b>stderr</b>, using a <b>printf()</b> style argument list.
 \param format Format and associated arguments to log to the console.
 */
SYSTEM_EXPORT void NSLog(NSString *format, ...);

/*!
 \brief Log a message to <b>stderr</b>, using a <b>printf()</b> style argument list.
 \param format Format and associated arguments to log to the console.
 \param args  Variable length argument list frame, generally retrieved from
 va_start() and va_copy().
 */
SYSTEM_EXPORT void NSLogv(NSString *format, va_list args);

/*!
 \brief Log a message to <b>stderr</b>, NUL-terminated.
 \param message Raw C-string message to log.
 */
SYSTEM_EXPORT void NSLogRaw(const char *message);

__END_DECLS

/*
  vim:syntax=objc:
 */
