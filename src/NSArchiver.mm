/* 
   NSArchiver.m

   Copyright (C) 1998 MDlink online service center, Helge Hess
   All rights reserved.

   Author: Helge Hess (helge@mdlink.de)

   This file is part of libFoundation.

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

   The code is based on the NSArchiver class done by Ovidiu Predescu which has
   the following Copyright/permission:
   ---
   The basic archiving algorithm is based on libFoundation's NSArchiver by
   Ovidiu Predescu:
   
   NSArchiver.h

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Ovidiu Predescu <ovidiu@bx.logicnet.ro>

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
   ---
*/
// $Id$

#include <boost/serialization/serialization.hpp>
#include <boost/archive/binary_oarchive.hpp>
#include <boost/archive/binary_iarchive.hpp>
#include <boost/mpl/if.hpp>
#if __GNUC_MINOR__ == 2
#include <tr1/type_traits>
using std::tr1::is_const;
#else
#include <type_traits>
using std::is_const;
#endif
#include <Alepha/Objective/Object.h>
#define __ARCHIVER_CLS	boost::archive::binary_oarchive
#define __UNARCHIVER_CLS	boost::archive::binary_iarchive

#import <Foundation/NSData.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSHashTable.h>
#import <Foundation/NSArchiver.h>
#import <Foundation/NSMapTable.h>
#import "internal.h"

#if 0
namespace bs = boost::serialization;
#endif

#define ENCODE_AUTORELEASEPOOL 0

#define FINAL static inline

typedef unsigned char TagType;

#define REFERENCE 128
#define VALUE     127

template<class Archive>
void serialize(Archive &ar, Alepha::Objective::Object<id> &obj, const unsigned int version)
{
	//id o = &obj;
}

FINAL bool isReferenceTag(TagType _tag)
{
	return (_tag & REFERENCE) ? true : false;
}

FINAL TagType tagValue(TagType _tag)
{
	return _tag & VALUE; // mask out bit 8
}

#if 0
template<class Archive>
inline void load_construct_data(Archive &ar, id 
#endif
/* This is more or less a hack class.  I make several assumptions:
 * It's a pointer caster only, and takes 'target types' as arguments, not the
 * pointer types themselves.  This saves some thought.
 */
template <typename D, typename S>
struct const_caster {
	typedef typename boost::mpl::if_<is_const<S>,
			const D,
			D>::type type;
	typename const_caster<D,S>::type *value;

	const_caster(S *s) : value(static_cast<type *>(s)) {}
};

/* _value can be (const void *) or (void *), so just make it a template
 * argument.
 */
template <class Archive, typename T>
static inline void codeValue(Archive &ar, T *_value, const char *_type)
{
#if 0
	if ((_value == NULL) || (_type == NULL))
	{
		return;
	}

	switch (*_type)
	{
		case _C_CHR:
		case _C_UCHR:
			ar & *const_caster<unsigned char,T>(_value).value;
			break;
		case _C_SHT:
		case _C_USHT:
			ar & *const_caster<unsigned short,T>(_value).value;
			break;
		case _C_INT:
		case _C_UINT:
#if ULONG_MAX == UINT_MAX
		case _C_LNG:
		case _C_ULNG:
#endif
			ar & *const_caster<unsigned int,T>(_value).value;
			break;
#if ULONG_MAX == ULLONG_MAX
		case _C_LNG:
		case _C_ULNG:
#endif
		case _C_LNG_LNG:
		case _C_ULNG_LNG:
			ar & *const_caster<unsigned long long,T>(_value).value;
			break;
		case _C_FLT:
			ar & *const_caster<float,T>(_value).value;
			break;
		case _C_DBL:
			ar & *const_caster<double,T>(_value).value;
			break;
	}
#endif
}

template <class Archive, typename T>
static inline void codeArray(Archive &ar, T *_array, const char *_type, size_t _count)
{
#if 0
	switch (*_type)
	{
		case _C_ID:
		case _C_CLASS:
			ar & bs::make_array(const_caster<Alepha::Objective::Object<id>, T>(_array).value, _count);
			break;
		case _C_CHR:
		case _C_UCHR:
			ar & bs::make_array(const_caster<unsigned char, T>(_array).value, _count);
			break;
		case _C_SHT:
		case _C_USHT:
			ar & bs::make_array(const_caster<unsigned short, T>(_array).value, _count);
			break;
		case _C_INT:
		case _C_UINT:
			ar & bs::make_array(const_caster<unsigned int, T>(_array).value, _count);
			break;
		case _C_LNG:
		case _C_ULNG:
			ar & bs::make_array(const_caster<unsigned long, T>(_array).value, _count);
			break;
		case _C_LNG_LNG:
		case _C_ULNG_LNG:
			ar & bs::make_array(const_caster<unsigned long long, T>(_array).value, _count);
			break;
		case _C_FLT:
			ar & bs::make_array(const_caster<float, T>(_array).value, _count);
			break;
		case _C_DBL:
			ar & bs::make_array(const_caster<double, T>(_array).value, _count);
			break;
	}
#endif
}

static const unsigned long NSOpaqueIntegerOptions = NSPointerFunctionsOpaqueMemory | NSPointerFunctionsIntegerPersonality;
static const unsigned long NSStrongObjectsOptions = NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality;

@implementation NSInconsistentArchiveException
@end

@implementation NSArchiver

- (id)initForWritingWithMutableData:(NSMutableData *)_data
{
	if ((self = [super init]))
	{
		outObjects      = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsObjectPersonality|NSPointerFunctionsZeroingWeakMemory capacity:10];
		outConditionals      = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsOpaquePersonality|NSPointerFunctionsZeroingWeakMemory capacity:10];
		outPointers      = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsOpaquePersonality|NSPointerFunctionsZeroingWeakMemory capacity:10];
		replacements    = [[NSMapTable alloc] initWithKeyOptions:NSStrongObjectsOptions valueOptions:NSStrongObjectsOptions capacity:19];
		outClassAlias    = [[NSMapTable alloc] initWithKeyOptions:NSStrongObjectsOptions valueOptions:NSStrongObjectsOptions capacity:19];
		outKeys    = [[NSMapTable alloc] initWithKeyOptions:NSStrongObjectsOptions valueOptions:NSOpaqueIntegerOptions capacity:119];

		archiveAddress = 1;

		data    = RETAIN(_data);
	}
	return self;
}

- (id)init
{
	return [self initForWritingWithMutableData:[NSMutableData data]];
}

+ (NSData *)archivedDataWithRootObject:(id)_root
{
	NSArchiver *archiver = AUTORELEASE([self new]);
	NSData     *rdata    = nil;

	[archiver encodeRootObject:_root];
	rdata = [archiver->data copy];
	return AUTORELEASE(rdata);
}

+ (bool)archiveRootObject:(id)_root toURI:(NSURI *)uri
{
	NSData *rdata = [self archivedDataWithRootObject:_root];

	if (rdata == nil)
	{
		return false;
	}

	return [[NSFileManager defaultManager] createFileAtURI:uri contents:rdata attributes:nil];
}

- (void)dealloc
{
	[data release];
	[outKeys release];
	[outObjects release];
	[outConditionals release];
	[outPointers release];
	[replacements release];
	[outClassAlias release];

	[super dealloc];
}

// ******************** Getting NSData from the NSArchiver ******

- (NSMutableData *)archiverData
{
	return data;
}

// ******************** archive id's **************************

FINAL int _archiveIdOfObject(NSArchiver *self, id _object)
{
	if (_object == nil)
		return 0;
#if 1
	else
		return (int)_object;
#else
	else
	{
		int archiveId;

		archiveId = (int)[outKeys objectForKey:_object];
		if (archiveId == 0)
		{
			archiveId = archiveAddress;
			[outKeys setPointer:(void*)archiveId forKey:_object];
			archiveAddress++;
		}

		return archiveId;
	}
#endif
}

- (void)encodeObjectsWithRoot:(id)_root
{
	// encoding pass 2
	[self encodeObject:_root];
}

- (void)encodeRootObject:(id)_object
{
#if ENCODE_AUTORELEASEPOOL
	NSAutoreleasePool *pool =
		[[NSAutoreleasePool allocWithZone:[self zone]] init];
#endif

	/*
	 * Prepare for writing the graph objects for which `rootObject' is the root
	 * node. The algorithm consists from two passes. In the first pass it
	 * determines the nodes so-called 'conditionals' - the nodes encoded *only*
	 * with -encodeConditionalObject:. They represent nodes that are not
	 * related directly to the graph. In the second pass objects are encoded
	 * normally, except for the conditional objects which are encoded as nil.
	 */

	// pass1: start tracing for conditionals
	// TODO: First create a dummy archive

	// pass2: start writing
	[self encodeObjectsWithRoot:_object];

#if ENCODE_AUTORELEASEPOOL
	RELEASE(pool);
#endif
}

- (void)encodeConditionalObject:(id)_object
{
	if (traceMode)
	{ // pass 1
		/*
		 * This is the first pass of the determining the conditionals
		 * algorithm. We traverse the graph and insert into the `conditionals'
		 * set. In the second pass all objects that are still in this set will
		 * be encoded as nil when they receive -encodeConditionalObject:. An
	   * object is removed from this set when it receives -encodeObject:.
	   */

		if (_object)
		{
			if (![outObjects containsObject:_object])
				[outConditionals addObject:_object];
		}
	}
	else
	{ // pass 2
		bool isConditional;

		isConditional = [outConditionals containsObject:_object];

		// If anObject is still in the `conditionals' set, it is encoded as nil.
		[self encodeObject:isConditional ? nil : _object];
	}
}

- (void)_traceObject:(id)_object
{
	if (_object == nil) // don't trace nil objects ..
		return;

	if (![outObjects containsObject:_object])
	{
		// object wasn't traced yet
		// Look-up the object in the `conditionals' set. If the object is
		// there, then remove it because it is no longer a conditional one.
		if ([outConditionals containsObject:_object])
		{
			// object was marked conditional ..
			[outConditionals removeObject:_object];
		}

		// mark object as traced
		[outObjects addObject:_object];

		if (object_isInstance(_object))
		{
			Class archiveClass = Nil;
			id    replacement  = nil;

			replacement = [_object replacementObjectForArchiver:self];

			if (replacement != _object)
			{
				[replacements setObject:replacement forKey:_object];
				_object = replacement;
			}

			if (object_isInstance(_object))
			{
				archiveClass = [_object classForCoder];
			}

			[self encodeObject:archiveClass];
			[_object encodeWithCoder:self];
		}
		else
		{
			// there are no class-variables ..
		}
	}
}

- (void)_encodeObject:(id)_object
{
#if 0
	TagType tag;
	int       archiveId = _archiveIdOfObject(self, _object);

	if (_object == nil)
	{ // nil object or class
		tag = _C_ID | REFERENCE;
		(*backend) << tag;
		(*backend) << archiveId;
		return;
	}

	tag = object_isInstance(_object) ? _C_ID : _C_CLASS;

	if ([outObjects containsObject:_object])
	{ // object was already written
		tag = _C_ID | REFERENCE;
		(*backend) << tag;
		(*backend) << archiveId;
	}
	else
	{
		std::string strVal;
		// mark object as written
		[outObjects addObject:_object];

		(*backend) << tag;
		(*backend) << archiveId;

		if (tag == _C_CLASS)
		{ // a class object
			strVal = object_getClassName(_object);
			(*backend) << strVal;
			unsigned int ver = [_object version];
			(*backend) << ver;
		}
		else
		{
			Class archiveClass = Nil;
			id    replacement  = nil;

			replacement = [replacements objectForKey:_object];
			if (replacement) _object = replacement;

			archiveClass = [_object classForCoder];

			NSAssert(archiveClass, @"no archive class found ..");

			[self encodeObject:archiveClass];
			[_object encodeWithCoder:self];
		}
	}
#endif
}

- (void)encodeObject:(id)_object
{
	char type = (object_isInstance(_object) ? '@' : '#');
	[self encodeValueOfObjCType:&type at:&_object];
}

- (void)_traceValueOfObjCType:(const char *)_type at:(const void *)_value
{
	switch (*_type)
	{
		case _C_ID:
		case _C_CLASS:
			[self _traceObject:*(id *)_value];
			break;

		case _C_ARY_B:
			{
				int        count     = atoi(_type + 1); // eg '[15I' => count = 15
				const char *itemType = _type;
				while(isdigit((int)*(++itemType))) ; // skip dimension
				[self encodeArrayOfObjCType:itemType count:count at:_value];
				break;
			}

		case _C_STRUCT_B:
			{ // C-structure begin '{'
				int offset = 0;

				while ((*_type != _C_STRUCT_E) && (*_type++ != '=')); // skip "<name>="

				while (true)
				{
					[self encodeValueOfObjCType:_type at:((char *)_value) + offset];

					offset += objc_sizeof_type(_type);
					_type  =  objc_skip_typespec(_type);

					if(*_type != _C_STRUCT_E)
					{ // C-structure end '}'
						int align, remainder;

						align = objc_alignof_type(_type);
						if((remainder = offset % align))
							offset += (align - remainder);
					}
					else
						break;
				}
				break;
			}
	}
}

- (void)_encodeValueOfObjCType:(const char *)_type at:(const void *)_value
{
#if 0
	std::string strVal;
	switch (*_type)
	{
		case _C_ID:
		case _C_CLASS:
			// ?? Write another tag just to be possible to read using the
			// ?? decodeObject method. (Otherwise a lookahead would be required)
			[self _encodeObject:*(id *)_value];
			break;

		case _C_ARY_B:
			{
				char *itemType;
				int   count     = strtol(_type + 1, &itemType, 0); // eg '[15I' => count = 15

				[self encodeArrayOfObjCType:itemType count:count at:_value];
				break;
			}

		case _C_STRUCT_B:
			{ // C-structure begin '{'
				int offset = 0;

				(*backend) << *_type;

				while ((*_type != _C_STRUCT_E) && (*_type++ != '=')); // skip "<name>="

				while (true)
				{
					[self encodeValueOfObjCType:_type at:((const char *)_value) + offset];

					offset += objc_sizeof_type(_type);
					_type  =  objc_skip_typespec(_type);

					if(*_type != _C_STRUCT_E)
					{ // C-structure end '}'
						int align, remainder;

						align = objc_alignof_type(_type);
						if((remainder = offset % align))
							offset += (align - remainder);
					}
					else
						break;
				}
				break;
			}

		case _C_SEL:
			strVal = std::string(sel_getName(*(SEL *)_value));
			(*backend) << strVal;
			break;

		case _C_PTR:
			(*backend) << *_type;
			[self encodeValueOfObjCType:_type+1 at:*(char **)_value];
			break;
		case _C_CHARPTR:
			strVal = std::string(static_cast<const char *>(_value));
			(*backend) << strVal;
			break;

		case _C_CHR:    case _C_UCHR:
		case _C_SHT:    case _C_USHT:
		case _C_INT:    case _C_UINT:
		case _C_LNG:    case _C_ULNG:
		case _C_FLT:    case _C_DBL:
			codeValue(*backend, _value, _type);
			break;

		default:
			NSLog(@"unsupported C type %s ..", _type);
			break;
	}
#endif
}

- (void)encodeValueOfObjCType:(const char *)_type
						   at:(const void *)_value
{
	if (traceMode)
	{
		//Log(@"trace value at 0x%08X of type %s", _value, _type);
		[self _traceValueOfObjCType:_type at:_value];
	}
	else
	{
		[self _encodeValueOfObjCType:_type at:_value];
	}
}

- (void)encodeArrayOfObjCType:(const char *)_type
						count:(unsigned int)_count
						   at:(const void *)_array
{
#if 0
	// Optimize writing arrays of elementary types. If such an array has to
	// be written, write the type and then the elements of array.

	switch (*_type)
	{
		case _C_ID:
		case _C_CLASS:
		case _C_CHR:
		case _C_UCHR:
		case _C_SHT:
		case _C_USHT:
		case _C_INT:
		case _C_UINT:
		case _C_LNG:
		case _C_ULNG:
		case _C_LNG_LNG:
		case _C_ULNG_LNG:
		case _C_FLT:
		case _C_DBL:
			codeArray(*backend, _array, _type, _count);
			break;
		default:
			IMP      encodeValue = NULL;
			unsigned offset, itemSize = objc_sizeof_type(_type);
			size_t   i;

			encodeValue = [self methodForSelector:@selector(encodeValueOfObjCType:at:)];

			for (i = offset = 0; i < _count; i++, offset += itemSize)
			{
				encodeValue(self, @selector(encodeValueOfObjCType:at:),
						(char *)_array + offset, _type);
			}
	}
#endif
}

// Substituting One Class for Another

- (NSString *)classNameEncodedForTrueClassName:(NSString *)_trueName
{
	NSString *name = [outClassAlias objectForKey:_trueName];
	return name ? name : _trueName;
}
- (void)encodeClassName:(NSString *)_name intoClassName:(NSString *)_archiveName
{
	[outClassAlias setObject:_archiveName forKey:_name];
}

// ******************** primitive encoding ********************

- (void) replaceObject:(id)obj withObject:(id)otherObj
{
	[self notImplemented:_cmd];
}

@end /* NSArchiver */

@implementation NSUnarchiver

static NSMapTable *classToAliasMappings = NULL; // archive name => decoded name

+ (void)initialize
{
	static bool isInitialized = false;
	if (!isInitialized)
	{
		isInitialized = true;

		classToAliasMappings = [[NSMapTable alloc] initWithKeyOptions:NSStrongObjectsOptions valueOptions:NSStrongObjectsOptions capacity:19];
	}
}

- (id)initForReadingWithData:(NSData*)_data
{
	if ((self = [super init]))
	{
		inClassAlias    = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality valueOptions:NSStrongObjectsOptions capacity:19];
		inObjects    = [[NSMapTable alloc] initWithKeyOptions:NSOpaqueIntegerOptions valueOptions:NSStrongObjectsOptions capacity:119];
		inClasses    = [[NSMapTable alloc] initWithKeyOptions:NSOpaqueIntegerOptions valueOptions:NSStrongObjectsOptions capacity:19];
		inClassVersions    = [[NSMapTable alloc] initWithKeyOptions:NSOpaqueIntegerOptions valueOptions:NSStrongObjectsOptions capacity:19];
		inPointers    = [[NSMapTable alloc] initWithKeyOptions:NSOpaqueIntegerOptions valueOptions:NSOpaqueIntegerOptions capacity:19];

		data = RETAIN(_data);
	}
	return self;
}

/* Decoding Objects */

+ (id)unarchiveObjectWithData:(NSData*)_data
{
	NSUnarchiver *unarchiver = [[self alloc] initForReadingWithData:_data];
	id           object      = [unarchiver decodeObject];

	RELEASE(unarchiver);

	return object;
}
+ (id)unarchiveObjectWithURI:(NSURI *)path
{
	NSData *rdata = [NSData dataWithContentsOfURI:path];
	if (!rdata) return nil;
	return [self unarchiveObjectWithData:rdata];
}

- (void)dealloc
{
	[data release];

	[inObjects release];
	[inClasses release];
	[inPointers release];
	[inClassAlias release];
	[inClassVersions release];
	[super dealloc];
}

/* Managing an NSUnarchiver */

- (bool)isAtEnd
{
	return ([data length] <= cursor) ? true : false;
}

- (void)setObjectZone:(NSZone *)_zone
{
	objectZone = _zone;
}
- (NSZone *)objectZone
{
	return objectZone;
}

- (unsigned int)systemVersion
{
	return inArchiverVersion;
}

// ******************** primitive decoding ********************

FINAL TagType _readTag(NSUnarchiver *self);

FINAL int   _readInt  (NSUnarchiver *self);

// ******************** complex decoding **********************

- (void)beginDecoding
{
	//cursor = 0;
	// TODO: Create the Boost unarchiver here.
}

- (void)endDecoding
{
#if 0
	ResetMapTable(inObjects);
	ResetMapTable(inClasses);
	ResetMapTable(inPointers);
	ResetMapTable(inClassAlias);
	ResetMapTable(inClassVersions);
#endif
}

- (Class)_decodeClass:(bool)_isReference
{
	int   archiveId = _readInt(self);
	Class result    = Nil;
#if 0

	if (archiveId == 0) // Nil class or unused conditional class
		return nil;

	if (_isReference)
	{
		NSAssert(archiveId, @"archive id is 0 !");

		result = (Class)[inClasses pointerForKey:(void *)archiveId];
		if (result == nil)
			result = (id)[inObjects pointerForKey:(void *)archiveId];
		if (result == nil)
		{
			@throw [NSInconsistentArchiveException exceptionWithReason:[NSString stringWithFormat:@"did not find referenced class %i.", archiveId] userInfo:nil];
		}
	}
	else
	{
		NSString *name   = NULL;
		int      version = 0;
		std::string cname;

		(*backend) >> cname;

		name    = [NSString stringWithCString:cname.c_str() encoding:[NSString defaultCStringEncoding]];
		version = _readInt(self);

		if ([name length] == 0)
		{
			@throw [NSInconsistentArchiveException exceptionWithReason:@"could not allocate memory for class name." userInfo:nil];
		}


		{ // check whether the class is to be replaced
			NSString *newName = [inClassAlias objectForKey:name];

			if (newName)
				name = newName;
			else
			{
				newName = [classToAliasMappings objectForKey:name];
				if (newName)
					name = newName;
			}
		}

		result = NSClassFromString(name);

		if (result == Nil)
		{
			@throw [NSInconsistentArchiveException exceptionWithReason:@"class doesn't exist in this runtime." userInfo:nil];
		}
		name = nil;

		if ([result version] != version)
		{
			@throw [NSInconsistentArchiveException exceptionWithReason:@"class versions do not match." userInfo:nil];
		}

		[inClasses setPointer:result forKey:(void *)archiveId];
	}

	NSAssert(result, @"Invalid state, class is Nil.");

#endif
	return result;
}

- (id)_decodeObject:(bool)_isReference
{
	// this method returns a retained object !
	int archiveId = _readInt(self);
	id  result    = nil;
#if 0

	if (archiveId == 0) // nil object or unused conditional object
		return nil;

	if (_isReference)
	{
		NSAssert(archiveId, @"archive id is 0 !");

		result = (id)[inObjects pointerForKey:(void *)archiveId];
		if (result == nil)
			result = (id)[inClasses pointerForKey:(void *)archiveId];

		if (result == nil)
		{
			@throw [NSInconsistentArchiveException exceptionWithReason:[NSString stringWithFormat:@"did not find referenced object %i.", archiveId] userInfo:nil];
		}
		result = RETAIN(result);
	}
	else
	{
		Class cls       = Nil;
		id    replacement = nil;

		// decode cls info
		[self decodeValueOfObjCType:"#" at:&cls];
		NSAssert(cls, @"could not decode cls for object.");

		result = [cls allocWithZone:objectZone];
		[inObjects setPointer:result forKey:(void *)archiveId];

		replacement = [result initWithCoder:self];
		if (replacement != result)
		{
			replacement = RETAIN(replacement);
			[inObjects removeObjectForKey:(id)(void*)archiveId];
			result = replacement;
			[inObjects setPointer:result forKey:(void *)archiveId];
			RELEASE(replacement);
		}

		replacement = [result awakeAfterUsingCoder:self];
		if (replacement != result)
		{
			replacement = RETAIN(replacement);
			[inObjects removeObjectForKey:(id)(void*)archiveId];
			result = replacement;
			[inObjects setPointer:result forKey:(void*)archiveId];
			RELEASE(replacement);
		}
	}

	if (object_isInstance(result))
	{
		NSAssert([result retainCount] > 0,
				@"invalid retain count %i for id=%i (%@) ..",
				[result retainCount],
				archiveId,
				NSStringFromClass([result class]));
	}
#endif
	return result;
}

- (id)decodeObject
{
	id result = nil;

	[self decodeValueOfObjCType:"@" at:&result];

	// result is retained
	return AUTORELEASE(result);
}

FINAL void _checkType(char _code, char _reqCode)
{
	if (_code != _reqCode)
	{
		@throw [NSInconsistentArchiveException exceptionWithReason:@"expected different typecode" userInfo:nil];
	}
}
FINAL void _checkType2(char _code, char _reqCode1, char _reqCode2)
{
	if ((_code != _reqCode1) && (_code != _reqCode2))
	{
		@throw [NSInconsistentArchiveException exceptionWithReason:@"expected different typecode" userInfo:nil];
	}
}

- (void)decodeValueOfObjCType:(const char *)_type
						   at:(void *)_value
{
	TagType tag             = 0;
	bool      isReference     = false;

#if 0
	(*backend) >> tag;
	isReference = isReferenceTag(tag);
	tag         = tagValue(tag);

	switch (tag)
	{
		case _C_ID:
			_checkType2(*_type, _C_ID, _C_CLASS);
			*(id *)_value = [self _decodeObject:isReference];
			break;
		case _C_CLASS:
			_checkType2(*_type, _C_ID, _C_CLASS);
			*(Class *)_value = [self _decodeClass:isReference];
			break;

		case _C_ARY_B:
			{
				int        count     = atoi(_type + 1); // eg '[15I' => count = 15
				const char *itemType = _type;

				_checkType(*_type, _C_ARY_B);

				while(isdigit((int)*(++itemType))) ; // skip dimension

				[self decodeArrayOfObjCType:itemType count:count at:_value];
				break;
			}

		case _C_STRUCT_B:
			{
				int offset = 0;

				_checkType(*_type, _C_STRUCT_B);

				while ((*_type != _C_STRUCT_E) && (*_type++ != '=')); // skip "<name>="

				while (true)
				{
					[self decodeValueOfObjCType:_type at:((char *)_value) + offset];

					offset += objc_sizeof_type(_type);
					_type  =  objc_skip_typespec(_type);

					if(*_type != _C_STRUCT_E)
					{ // C-structure end '}'
						int align, remainder;

						align = objc_alignof_type(_type);
						if((remainder = offset % align))
							offset += (align - remainder);
					}
					else
						break;
				}
				break;
			}

		case _C_SEL:
			{
				std::string name;

				(*backend) >> name;
				*(SEL *)_value = !name.empty() ? sel_getUid(name.c_str()) : NULL;
			}

		case _C_PTR:
			*(char **)_value = static_cast<char *>(malloc(objc_sizeof_type(_type+1)));
			[self decodeValueOfObjCType:_type+1 at:*(char **)_value];
			break;
		case _C_CHARPTR:
		case _C_CHR:    case _C_UCHR:
		case _C_SHT:    case _C_USHT:
		case _C_INT:    case _C_UINT:
		case _C_LNG:    case _C_ULNG:
		case _C_FLT:    case _C_DBL:
			_checkType(*_type, tag);
			codeValue(*backend, _value, _type);
			break;

		default:
			@throw [NSInconsistentArchiveException exceptionWithReason:[NSString stringWithFormat:@"unsupported typecode %i found.", tag] userInfo:nil];
			break;
	}
#endif
}

- (void)decodeArrayOfObjCType:(const char *)_type
						count:(unsigned int)_count
						   at:(void *)_array
{
#if 0
	TagType tag;
	(*backend) >> tag;
	unsigned int count = _readInt(self);

	NSAssert(tag == _C_ARY_B, @"invalid type ..");
	NSAssert(count == _count, @"invalid array size ..");

	switch (*_type)
	{
		case _C_ID:
		case _C_CLASS:
		case _C_CHR:
		case _C_UCHR:
		case _C_SHT:
		case _C_USHT:
		case _C_INT:
		case _C_UINT:
		case _C_LNG:
		case _C_ULNG:
		case _C_LNG_LNG:
		case _C_ULNG_LNG:
		case _C_FLT:
		case _C_DBL:
			codeArray(*backend, _array, _type, _count);
			break;
		default:
			IMP      decodeValue = NULL;
			unsigned offset, itemSize = objc_sizeof_type(_type);
			size_t   i;

			decodeValue = [self methodForSelector:@selector(decodeValueOfObjCType:at:)];

			for (i = offset = 0; i < _count; i++, offset += itemSize)
			{
				decodeValue(self, @selector(decodeValueOfObjCType:at:),
						(char *)_array + offset, _type);
			}
	}
#endif
}

/* Substituting One Class for Another */

+ (NSString *)classNameDecodedForArchiveClassName:(NSString *)nameInArchive
{
	NSString *className = [classToAliasMappings objectForKey:nameInArchive];
	return className ? className : nameInArchive;
}

+ (void)decodeClassName:(NSString *)nameInArchive
			asClassName:(NSString *)trueName
{
	[classToAliasMappings setObject:trueName forKey:nameInArchive];
}

- (NSString *)classNameDecodedForArchiveClassName:(NSString *)_nameInArchive
{
	NSString *className = [inClassAlias objectForKey:_nameInArchive];
	return className ? className : _nameInArchive;
}

- (void)decodeClassName:(NSString *)nameInArchive asClassName:(NSString *)trueName
{
	[inClassAlias setObject:trueName forKey:nameInArchive];
}

// ******************** primitive decoding ********************

FINAL TagType _readTag(NSUnarchiver *self)
{
	unsigned char c;
#if 0
	NSCAssert(self, @"invalid self ..");

	(*self->backend) >> c;
	if (c == 0)
	{
		@throw [NSInconsistentArchiveException exceptionWithReason:@"found invalid type tag (0)" userInfo:nil];
	}
#endif
	return (TagType)c;
}

FINAL int _readInt(NSUnarchiver *self)
{
	int value;
#if 0
	(*self->backend) & value;
#endif
	return value;
}

- (void) replaceObject:(id)obj withObject:(id)otherObj
{
	[self notImplemented:_cmd];
}

@end /* NSUnarchiver */

/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
*/
