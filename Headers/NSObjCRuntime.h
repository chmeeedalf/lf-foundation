/*
 * Copyright (c) 2004-2006	Gold Project
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
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR COEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#ifndef _OBJC_RUNTIME_
#define _OBJC_RUNTIME_
#include <debug.h>
#include <limits.h>
#include <Foundation/primitives.h>
#include <stddef.h>

__BEGIN_DECLS
/*!
 * \file NSObjCRuntime.h
 * \brief Core Objective-C header.
 */

#include <objc/runtime.h>
#include <objc/encoding.h>
#ifndef DOXYGEN_SHOULD_SKIP_THIS
#ifndef __BUILD__
#define STATIC_INLINE static inline
#else
#define STATIC_INLINE
#endif
#endif

/*!
 * \brief Generic return value container.
 */
typedef void *retval_t;

/*!
 * \brief Argument frame for message forwarding.
 */
typedef union {
  char *arg_ptr;					/*!< \brief Pointer to stack arguments in this frame. */
  char arg_regs[sizeof (char*)];	/*!< \brief Register arguments in this frame. */
} *arglist_t;			/* argument frame */

Class *class_copySubclassList(Class cls, size_t *count);
// Included from other headers, matches the Apple runtime...

#if 0
/*!
 \typedef id
 \brief A pointer to an instance of a class.
 */
typedef struct objc_object *id;

typedef const struct objc_selector *SEL;
typedef struct objc_class *Class;
typedef struct ivar_t *Ivar;
typedef struct method_t *Method;
typedef struct category_t *Category;
typedef struct objc_property *Property;
typedef id (*IMP)(id, SEL, ...);

struct objc_object
{
	Class isa;
};

/*!
 \brief Specifies the superclass of an instance.
 */
typedef struct objc_super {
	id receiver;		/*!< \brief Receiver object, the instance. */
	Class current_class;		/*!< \brief Current class, whose super class to use. */
} Super;

struct objc_method_description
{
	SEL name;
	const char *types;
};

/*!
 * \brief The \c id type of a null instance.
 */
#define nil ((id)0)

/*!
 * \brief The \c id type of a null class.
 */
#define Nil ((Class)0)

#ifndef DOXYGEN_SHOULD_SKIP_THIS
enum {
	_C_ID		= '@',
	_C_CHARPTR	= '*',
	_C_ARY_B	= '[',
	_C_ARY_E	= ']',
	_C_STRUCT_B	= '{',
	_C_STRUCT_E	= '}',
	_C_PTR		= '^',
	_C_CHR		= 'c',
	_C_UCHR		= 'C',
	_C_SHT		= 's',
	_C_USHT		= 'S',
	_C_INT		= 'i',
	_C_UINT		= 'I',
	_C_LNG		= 'l',
	_C_ULNG		= 'L',
	_C_LNG_LNG	= 'q',
	_C_ULNG_LNG	= 'Q',
	_C_FLT		= 'f',
	_C_DBL		= 'd',
	_C_VOID		= 'v',
	_C_CLS		= '#',
	_C_CLASS	= '#',
	_C_SEL		= ':',
	_C_UNDEF	= '?',
	_C_UNION_B	= '(',
	_C_UNION_E	= ')',
	_C_BFLD		= 'b',
	_C_BOOL		= 'B',
	_C_CONST	= 'r',
	_C_IN		= 'n',
	_C_INOUT	= 'N',
	_C_OUT		= 'o',
	_C_BYCOPY	= 'O',
	_C_ONEWAY	= 'V',
};
#endif

enum
{
	_F_CONST = 1,
	_F_IN = 1,
	_F_INOUT = 2,
	_F_OUT = 3,
	_F_BYCOPY = 4,
	_F_ONEWAY = 5,
};

#ifndef __OBJC__
typedef struct Protocol Protocol;
#else
@class Protocol;
#endif	// __OBJC__

/*!
 \brief Returns the name of the method specified by the given selector.
 */
const char *sel_getName(SEL aSelector);

/*!
 * \brief Compares the two selectors and returns equality.
 */
bool sel_isEqual(SEL sel1, SEL sel2);

/*!
 \brief Registers a method with the objective-C runtime system, maps the method name to a selector, and returns the selector value.
 */
SEL sel_registerName(const char *str);

/*!
 \brief Same as sel_registerName.
 */
SEL sel_getUid(const char *str);

/*!
 * \brief Initializes a class given a block of memory.
 */
id class_createInstanceInPlace(id p, Class aClass);

/*!
 * \brief Returns a (malloc()d) list of instance variables.
 */
Ivar *class_copyIvarList(Class cls, unsigned int *count);

/*!
 \brief Sets the class version, for archiving purposes.
 \param aClass Class to set the version of.
 \param version New version number for the class.
 */
void class_setVersion(Class aClass, int version);

/*!
 \brief Returns the version number of the given class.
 \param aClass Class to get the version of.
 */
int class_getVersion(Class aClass);

// Accessing methods....
/*!
 \brief Returns a pointer to the data structure describing the specified instance method.
 \param aClass Pointer to an  objc_class definition of the class.
 \param aSelector Selector of the method to return.
 \result A pointer to an objc_method structure describing the method, or NULL if the method doesn't exist.
 */
Method class_getInstanceMethod(Class aClass, SEL aSelector);

/*!
 \brief Returns a pointer to the data structure describing the specified class method.
 \param aClass Pointer to an  objc_class definition of the class.
 \param aSelector Selector of the method to return.
 \result A pointer to an objc_method structure describing the method, or NULL if the method doesn't exist.
 */
Method class_getClassMethod(Class aClass, SEL aSelector);

/*!
 * \brief Returns the method implementation for a given selector.
 *
 * \details It may return a runtime-internal function instead of an actual
 * method.
 */
IMP class_getMethodImplementation(Class aClass, SEL aSelector);

/*!
 \brief Returns the list of all methods implemented by a given class.
 \param theClass Pointer to the class definition, an objc_class structure.
 \param iterator On input, pointer to an opaque type.  Pass 0 as the value of the pointed to variable to return the first method list of the class.  On output, points to an iteration value which can be passed to the next call to this function to get the next method list.
 \result An array of all instance methods for the given class.

 Does not include methods from superclasses.
 */
Method *class_copyMethodList(Class theClass, unsigned int *iterator);

/*!
 \brief Adds a method to the class definition.
 \param aClass Pointer to the class definition to which to add the method list.
 \param name Selector for the method to add.
 \param imp Pointer to function implementing the selector.
 \param types Type string of method arguments.

 Use sel_registerName() to get a valid selector for the method.
 */
bool class_addMethod(Class aClass, SEL name, IMP imp, const char *types);

/*!
 * \brief Returns whether the class responds to the selector.
 */
bool class_respondsToSelector(Class cls, SEL sel);

/*!
 * \brief Returns the name of the given class.
 */
const char *class_getName(Class cls);

/*!
 * \brief Returns the size of an instance of the given class.
 */
size_t class_getInstanceSize(Class cls);

/*!
 * \brief Returns the super class of the given class.
 */
Class class_getSuperclass(Class cls);

/*!
 * \brief Returns a list of subclasses of the given class.
 *
 * \details You must free() the result when done.
 */
Class *class_copySubclassList(Class cls, size_t *count);
Protocol **class_copyProtocolList(Class cls, size_t *count);

/*!
 * \brief Returns whether the given class is a meta-class.
 */
bool class_isMetaClass(Class cls);

/*!
 * \brief Returns whether or not the class conforms to a given protocol.
 * \param cls Class to check.
 * \param protocol Protocol to check for in \e cls.
 * \returns \c true if the class conforms to the protocol.
 */
bool class_conformsToProtocol(Class cls, Protocol *protocol);

// Accessing instance variable definitions
/*!
 \brief Obtains information about the instance variables defined for a specified class.
 \param aClass Pointer to the class definition.
 \param aVariableName Pointer to a C string containing the name of the instance variable definition to obtain.
 \result Pointer to an objc_ivar structure containing information about the instance variable specified by the given name.
 */
Ivar class_getInstanceVariable(Class aClass, const char *aVariableName);

// Accessing instance variables...
/*!
 \brief Changes the value of an instance variable of a class instance.
 \param object A pointer to the instance of a class.
 \param name A C string with the name of the instance variable to change.
 \param value A pointer to the new value for the instance variable.
 \result A pointer to the objc_ivar data structure that defines the type and name of the instance variable specified by the given name.
 */
Ivar object_setInstanceVariable(id object, const char *name, void *value);

/*!
 \brief Returns the name of the class of the given object.
 \param obj NSObject to name.
 \result Name of the class.
 */
const char *object_getClassName(id obj);

/*!
 * \brief Returns the class of the given object.
 */
Class object_getClass(id obj);

/*!
 * \brief Sets the class for the given object.
 * \result The previous class, or \c Nil if the object is \c nil.
 */
Class object_setClass(id obj, Class cls);

/*!
 \brief Obtains the value of an instance variable of a class instance.
 \param object A pointer to the instance of a class.
 \param name A C string with the name of the instance variable.
 \param value A pointer to a pointer to a value.  On output, contains a pointer to the value of the instance variable.
 \result A pointer to the objc_ivar data structure that defines the type and name of the instance variable specified by the given name.
 */
Ivar object_getInstanceVariable(id object, const char *name, void **value);

// PROTOCOL
/*!
 * \brief Returns whether the protocol conforms to another protocol.
 */
bool protocol_conformsToProtocol(Protocol *aProtocol, Protocol *another);

struct objc_method_description *protocol_copyMethodDescriptionList(Protocol *proto, bool isRequired, bool isInstance, size_t *count);

const char *protocol_getName(Protocol *proto);

/*!
 * \brief Returns the description of a method in the protocol.
 */
struct objc_method_description protocol_getMethodDescription(Protocol *proto, SEL name, bool isRequired, bool isInstance);

/*!
 * \brief Returns the name of the given instance variable.
 */
const char *ivar_getName(Ivar ivar);

/*!
 * \brief Returns the offset of the given instance variable.
 */
ptrdiff_t ivar_getOffset(Ivar ivar);

/*!
 * \brief Returns the encoded type of the instance variable.
 */
const char *ivar_getTypeEncoding(Ivar ivar);

/*!
 \brief Returns the number of arguments accepted by a method.
 \param method Pointer to the method in question, an objc_method structure.
 \result An integer containing the number of arguments accepted by the given method.
 */
unsigned int method_getNumberOfArguments(Method method);

/*!
 * XXX
 */
IMP method_getImplementation(Method meth);

/*!
 * XXX
 */
const char *method_getArgumentTypes(Method meth);

/*!
 * XXX
 */
SEL method_getName(Method meth);

/*!
 \brief Returns the total size of the stack frame occupied by a method's arguments.
 \param method Pointer to the method in question, an objc_method structure.
 \result An integer containing the size of the section of the stack frame occupied by the given method's arguments.
 */
unsigned int method_getSizeOfArguments(Method method);

/*!
 \brief Returns information about one of a method's arguments.
 \param method Pointer to the method in question, an objc_method structure.
 \param argIndex zero-based index of the argument in question.
 \param type On output, a pointer to a C-style string containing the type encoding for the argument.
 \param offset On output, a pointer to an integer indicating the location of the artgument within the memory allocated for the method implementation.  The offset is from the start of the implementation memory to the location of the method.
 \result An integer containing the size of the section of the stack frame occupied by the given argument.
 */
unsigned int method_getArgumentInfo(Method method, int argIndex,
	const char **type, int *offset);
const char *method_copyArgumentType(Method method, unsigned int index);
void method_getArgumentType(Method method, unsigned int index, char *dest, size_t dest_len);
void method_getReturnType(Method method, char *dest, size_t dest_len);
IMP method_setImplementation(Method m, IMP imp);

// Obtaining class definitions....
/*!
 \brief Obtains the list of registered class definitions.
 \param buffer NSArray of class definitions.  Pass NULL to just get a count of the total number of registered classes, otherwise pass a valid buffer.
 \param bufferLen Length of the class buffer.  Pass the number of pointers
 allocated in the buffer.
 \result An integer value indicating the number of registered classes.

 The Objective-C runtime library automatically registers all
 classes defined in your source code.  To register a class manually, use the
 objc_addClass function.
 */
int objc_getClassList(Class *buffer, int bufferLen);

/*!
 \brief Returns a pointer to the class definition with the specified name.
 \param aClassName Name of the class to return the definition of.
 \result Pointer to the class definition, or Nil if not found.

 This method is different from objc_lookupClass in that if the
 class is not registered, objc_getClass calls the class handler callback and
 then checks a second time to see whether the class is registered.
 */
Class objc_getClass(const char *aClassName);

/*!
 \brief Lookup and return a method corresponding to a SEL for an object.
 \param receiver Receiver object.
 \param op Selector to search for.
 */
IMP objc_msgLookup(id receiver, SEL op);

/*!
 \brief Registers a class definition with the Objective-C runtime.
 \param myClass Class to register.  It must be defined correctly and completely.
 */
void objc_registerClassPair(Class myClass);

/*!
 * XXX
 */
Class objc_allocateClassPair(Class superclass_gen, const char *name, size_t extraBytes);

/*!
 \brief Returns a pointer to the class definition with the specified name.
 \param aClassName Name of the class to return the definition of.
 */
Class objc_lookUpClass(const char *aClassName);

/*!
 \brief Sets a custom error-handling callback function called from objc_getClass and objc_getMetaClass.
 \param callback New class handler callback.
 */
void objc_setClassHandler(int (*callback)(const char *));

/*!
 * \brief Return the size of a type, represented by an encoded string.
 */
extern size_t objc_getSizeOfType(const char *);

/*!
 * \brief Return the alignment of a type, given as an encoded string.
 */
size_t objc_getAlignmentOfType(const char *type);

#ifndef __OBJC__
id objc_msgSend(id, SEL, ...);
#endif
#endif

/*!
 \brief Returns true if aClass is kindClass or subclassed from it.
 */
bool class_isKindOfClass(Class aClass, Class kindClass);

/*!
 * @brief Adds methods from \c behavior to \c targetClass.
 */
void class_addBehavior(Class targetClass, Class behavior);

extern const char *objc_skip_argspec(const char *);

unsigned int encoding_getNumberOfArguments(const char *typedesc);
#if 0
{
	unsigned int count = 0;
	if (typedesc == NULL)
		return 0;

	while (*typedesc != 0)
	{
		typedesc = objc_skip_argspec(typedesc);
		count++;
	}
	return (count - 1);
}
#endif

unsigned int encoding_getSizeOfArguments(const char *typedesc);
unsigned int encoding_getArgumentInfo(const char *typedesc, int arg, const char **type, int *offset);
void encoding_getReturnType(const char *t, char *dst, size_t dst_len);
char *encoding_copyReturnType(const char *t);
void encoding_getArgumentType(const char *t, unsigned int index, char *dst, size_t dst_len);
char *encoding_copyArgumentType(const char *t, unsigned int index);

#if __has_feature(blocks)
typedef NSComparisonResult (^NSComparator)(id obj1, id obj2);
#else
typedef NSComparisonResult (*NSComparator)(id obj1, id obj2);
#endif

typedef NSUInteger NSEnumerationOptions;
enum
{
	NSEnumerationConcurrent = (1UL << 0),
	NSEnumerationReverse = (1UL << 1),
};

typedef NSUInteger NSSortOptions;
enum
{
	NSSortConcurrent = (1UL << 0),
	NSSortStable = (1UL << 4),
};

enum {NSNotFound = LONG_MAX};
__END_DECLS

#endif

/*
   vim:syntax=objc:
 */
