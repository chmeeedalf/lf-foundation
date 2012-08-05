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
   ---
*/
// $Id$

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#import <Foundation/NSArchiver.h>

#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSHashTable.h>
#import <Foundation/NSMapTable.h>
#import <Foundation/NSString.h>

#import "internal.h"

#define ARCHIVE_DEBUGGING      0

#define FINAL static inline

typedef unsigned char NSTagType;

#define REFERENCE 128
#define VALUE     127

FINAL bool isBaseType(const char *_type)
{
    switch (*_type) {
        case _C_CHR: case _C_UCHR:
        case _C_SHT: case _C_USHT:
        case _C_INT: case _C_UINT:
        case _C_LNG: case _C_ULNG:
        case _C_FLT: case _C_DBL:
            return true;

        default:
            return false;
    }
}

FINAL bool isReferenceTag(NSTagType _tag)
{
    return (_tag & REFERENCE) ? true : false;
}

FINAL NSTagType tagValue(NSTagType _tag) {
    return _tag & VALUE; // mask out bit 8
}

static const char *NSCoderSignature = "libFoundation NSArchiver";
static NSUInteger NSCoderVersion    = 1100;

@implementation NSArchiver
{
	NSHashTable *outObjects;
	NSHashTable *outConditionals;
	NSHashTable *outPointers;
	NSMapTable  *outClassAlias;       // class name -> archive name
	NSMapTable  *replacements;        // src-object to replacement
	id outKeys;
	bool        traceMode;            // true if finding conditionals
	bool        didWriteHeader;
	bool        encodingRoot;
	int         archiveAddress;

	// destination
	NSMutableData *data;
	__ARCHIVER_CLS *backend;
}

- (id)initForWritingWithMutableData:(NSMutableData *)_data
{
    if ((self = [super init])) {
		outObjects      = [NSHashTable hashTableWithOptions:(NSPointerFunctionsOpaqueMemory|NSPointerFunctionsObjectPointerPersonality)];
		outConditionals = [NSHashTable hashTableWithOptions:(NSPointerFunctionsOpaqueMemory|NSPointerFunctionsObjectPointerPersonality)];
		outPointers     = [NSHashTable hashTableWithOptions:(NSPointerFunctionsOpaqueMemory|NSPointerFunctionsObjectPointerPersonality)];
		replacements    = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsObjectPointerPersonality|NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality];
        outClassAlias   = [NSMapTable mapTableWithStrongToStrongObjects];
        outClassAlias   = [NSMapTable mapTableWithStrongToStrongObjects];
		outKeys         = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality
												valueOptions:NSPointerFunctionsIntegerPersonality|NSPointerFunctionsOpaqueMemory];

        self->archiveAddress = 1;

        self->data    = _data;
    }
    return self;
}

- (id)init
{
    return [self initForWritingWithMutableData:[NSMutableData data]];
}

+ (NSData *)archivedDataWithRootObject:(id)_root
{
    NSArchiver *archiver = [self new];
    NSData     *rdata    = nil;
    
    [archiver encodeRootObject:_root];
    rdata = [archiver->data copy];
    return rdata;
}
+ (bool)archiveRootObject:(id)_root toURL:(NSURL *)_path
{
    NSData *rdata = [self archivedDataWithRootObject:_root];
    return [rdata writeToURL:_path atomically:true];
}

// ******************** Getting Data from the NSArchiver ******

- (NSMutableData *)archiverData
{
    return self->data;
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
    else {
        int archiveId;

        archiveId = (int)[self->outKeys objectForKey:_object];
        if (archiveId == 0) {
            archiveId = self->archiveAddress;
            [self->outKeys setObject:(__bridge id)(void*)archiveId forKey:_object];
#if ARCHIVE_DEBUGGING
            NSLog(@"mapped 0x%08X => %i", _object, archiveId);
#endif
            self->archiveAddress++;
        }

        return archiveId;
    }
#endif
}
FINAL int _archiveIdOfClass(NSArchiver *self, Class _class)
{
    return _archiveIdOfObject(self, _class);
}

// ******************** primitive encoding ********************

FINAL void _writeBytes(NSArchiver *self, const void *_bytes, unsigned _len);

FINAL void _writeTag  (NSArchiver *self, NSTagType _tag);

FINAL void _writeInt  (NSArchiver *self, int _value);

FINAL void _writeCString(NSArchiver *self, const char *_value);
FINAL void _writeObjC(NSArchiver *self, const void *_value, const char *_type);

// ******************** complex encoding **********************

- (void)beginEncoding
{
    self->traceMode    = false;
    self->encodingRoot = true;
}
- (void)endEncoding
{
#if 0
    NSResetHashTable(self->outObjects);
    NSResetHashTable(self->outConditionals);
    NSResetHashTable(self->outPointers);
    NSResetMapTable(self->outClassAlias);
    NSResetMapTable(self->replacements);
    NSResetMapTable(self->outKeys);
#endif

    self->traceMode      = false;
    self->encodingRoot   = false;
}

- (void)writeArchiveHeader
{
    if (self->didWriteHeader == false) {
        _writeCString(self, NSCoderSignature);
        _writeInt(self, NSCoderVersion);
        self->didWriteHeader = true;
    }
}
- (void)writeArchiveTrailer
{
}

- (void)traceObjectsWithRoot:(id)_root
{
    // encoding pass 1
    @try {
        self->traceMode = true;
        [self encodeObject:_root];
    }
    @finally {
        self->traceMode = false;
        [self->outObjects removeAllObjects];
    }
}

- (void)encodeObjectsWithRoot:(id)_root
{
    // encoding pass 2
    [self encodeObject:_root];
}

- (void)encodeRootObject:(id)_object
{
	@autoreleasepool
	{
		[self beginEncoding];

		@try {
			/*
			 * Prepare for writing the graph objects for which `rootObject' is the root
			 * node. The algorithm consists from two passes. In the first pass it
			 * determines the nodes so-called 'conditionals' - the nodes encoded *only*
			 * with -encodeConditionalObject:. They represent nodes that are not
			 * related directly to the graph. In the second pass objects are encoded
			 * normally, except for the conditional objects which are encoded as nil.
			 */

			// pass1: start tracing for conditionals
		[self traceObjectsWithRoot:_object];

		// pass2: start writing
		[self writeArchiveHeader];
		[self encodeObjectsWithRoot:_object];
		[self writeArchiveTrailer];
		}
		@finally {
			[self endEncoding]; // release resources
		}
	}
}

- (void)encodeConditionalObject:(id)_object
{
    if (self->traceMode) { // pass 1
        /*
         * This is the first pass of the determining the conditionals
         * algorithm. We traverse the graph and insert into the `conditionals'
         * set. In the second pass all objects that are still in this set will
         * be encoded as nil when they receive -encodeConditionalObject:. An
         * object is removed from this set when it receives -encodeObject:.
         */

        if (_object) {
			if ([outObjects containsObject:_object])
                // object isn't conditional any more .. (was stored using encodeObject:)
                ;
            else if ([self->outConditionals containsObject:_object])
                // object is already stored as conditional
                ;
            else
                // insert object in conditionals set
                [self->outConditionals addObject:_object];
        }
    }
    else { // pass 2
        bool isConditional;

		isConditional = [self->outConditionals containsObject:_object];

        // If anObject is still in the `conditionals' set, it is encoded as nil.
        [self encodeObject:isConditional ? nil : _object];
    }
}

- (void)_traceObject:(id)_object
{
    if (_object == nil) // don't trace nil objects ..
        return;

    //NSLog(@"lookup 0x%08X in outObjs=0x%08X", _object, self->outObjects);
    
	if ([self->outObjects containsObject:_object]) {
        //NSLog(@"lookup failed, object wasn't traced yet !");
        
        // object wasn't traced yet
        // Look-up the object in the `conditionals' set. If the object is
        // there, then remove it because it is no longer a conditional one.
		if ([self->outConditionals containsObject:_object]) {
            // object was marked conditional ..
			[self->outConditionals removeObject:_object];
        }
        
        // mark object as traced
        [self->outObjects addObject:_object];
        
        if (object_isInstance(_object)) {
            Class archiveClass = Nil;
            id    replacement  = nil;
            
			replacement = [_object replacementObjectForCoder:self];
            
            if (replacement != _object) {
                [self->replacements setObject:replacement forKey:_object];
                _object = replacement;
            }
            
            if (object_isInstance(_object)) {
                archiveClass = [_object classForCoder];
            }
            
            [self encodeObject:archiveClass];
            [_object encodeWithCoder:self];
        }
        else {
            // there are no class-variables ..
        }
    }
}
- (void)_encodeObject:(id)_object
{
    NSTagType tag;
    int       archiveId = _archiveIdOfObject(self, _object);

    if (_object == nil) { // nil object or class
        _writeTag(self, _C_ID | REFERENCE);
        _writeInt(self, archiveId);
        return;
    }
    
    tag = object_isInstance(_object) ? _C_ID : _C_CLASS;
    
	if ([self->outObjects containsObject:_object]) { // object was already written
        _writeTag(self, tag | REFERENCE);
        _writeInt(self, archiveId);
    }
    else {
        // mark object as written
        [self->outObjects addObject:_object];

        /*
          if (tag == _C_CLASS) { // a class object
          NGLogT(@"encoder", @"encoding class %s:%i ..",
          class_get_class_name(_object), [_object version]);
          }
          else {
          NGLogT(@"encoder", @"encoding object 0x%08X<%s> ..",
          _object, class_get_class_name(*(Class *)_object));
          }
        */
    
        _writeTag(self, tag);
        _writeInt(self, archiveId);

        if (tag == _C_CLASS) { // a class object
            NSString *className;
            char *buf;
            
            className = NSStringFromClass(_object);
            className = [self classNameEncodedForTrueClassName:className];
            buf = strdup([className UTF8String]);
            
            _writeCString(self, buf);
            _writeInt(self, [_object version]);
            if (buf) free(buf);
        }
        else {
            Class archiveClass = Nil;
            id    replacement  = nil;

            replacement = [self->replacements objectForKey:_object];
            if (replacement) _object = replacement;

            /*
			   _object = [_object replacementObjectForCoder:self];
            */
            archiveClass = [_object classForCoder];
            
            NSAssert(archiveClass, @"no archive class found ..");

            [self encodeObject:archiveClass];
            [_object encodeWithCoder:self];
        }
    }
}

- (void)encodeObject:(id)_object
{
    if (self->encodingRoot) {
        [self encodeValueOfObjCType:
                object_isInstance(_object) ? "@" : "#"
              at:&_object];
    }
    else {
        [self encodeRootObject:_object];
    }
}

- (void)_traceValueOfObjCType:(const char *)_type at:(const void *)_value
{
    //NSLog(@"_tracing value at 0x%08X of type %s", _value, _type);
    
    switch (*_type) {
        case _C_ID:
        case _C_CLASS:
            //NSLog(@"_traceObject 0x%08X", *(id *)_value);
			{
				id val = (__bridge id)*(void **)_value;
				[self _traceObject:val];
			}
            break;
        
        case _C_ARY_B: {
            int        count     = atoi(_type + 1); // eg '[15I' => count = 15
            const char *itemType = _type;
            while(isdigit((int)*(++itemType))) ; // skip dimension
            [self encodeArrayOfObjCType:itemType count:count at:_value];
            break;
        }

        case _C_STRUCT_B: { // C-structure begin '{'
            int offset = 0;

            while ((*_type != _C_STRUCT_E) && (*_type++ != '=')); // skip "<name>="
        
            while (true) {
				[self encodeValueOfObjCType:_type at:((const char *)_value) + offset];

				NSUInteger skip, align;
				_type = NSGetSizeAndAlignment(_type, &skip, &align);
				offset += skip;

				if(*_type != _C_STRUCT_E)
				{ // C-structure end '}'
					int remainder;

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
    //NGLogT(@"encoder", @"encoding value of ObjC-type '%s' at %i",
    //       _type, [self->data length]);
  
    switch (*_type) {
        case _C_ID:
        case _C_CLASS:
            // ?? Write another tag just to be possible to read using the
            // ?? decodeObject method. (Otherwise a lookahead would be required)
            // ?? _writeTag(self, *_type);
            [self _encodeObject:*(const id *)_value];
            break;

        case _C_ARY_B: {
            int        count     = atoi(_type + 1); // eg '[15I' => count = 15
            const char *itemType = _type;

            while(isdigit((int)*(++itemType))) ; // skip dimension

            // Write another tag just to be possible to read using the
            // decodeArrayOfObjCType:count:at: method.
            _writeTag(self, _C_ARY_B);
            [self encodeArrayOfObjCType:itemType count:count at:_value];
            break;
        }

        case _C_STRUCT_B: { // C-structure begin '{'
            int offset = 0;

            _writeTag(self, '{');

            while ((*_type != _C_STRUCT_E) && (*_type++ != '=')); // skip "<name>="
        
			while (true) {
				[self encodeValueOfObjCType:_type at:((const char *)_value) + offset];

				NSUInteger skip, align;
				_type = NSGetSizeAndAlignment(_type, &skip, &align);
				offset += skip;

				if(*_type != _C_STRUCT_E)
				{ // C-structure end '}'
					int remainder;

					if((remainder = offset % align))
						offset += (align - remainder);
				}
				else
					break;

			}
            break;
        }

        case _C_SEL:
            _writeTag(self, _C_SEL);
            _writeCString(self, (*(SEL *)_value) ? sel_getName(*(SEL *)_value) : NULL);
            break;
      
        case _C_PTR:
            _writeTag(self, *_type);
            _writeObjC(self, *(char **)_value, _type + 1);
            break;
        case _C_CHARPTR:
            _writeTag(self, *_type);
            _writeObjC(self, _value, _type);
            break;
      
        case _C_CHR:    case _C_UCHR:
        case _C_SHT:    case _C_USHT:
        case _C_INT:    case _C_UINT:
        case _C_LNG:    case _C_ULNG:
        case _C_FLT:    case _C_DBL:
            _writeTag(self, *_type);
            _writeObjC(self, _value, _type);
            break;
      
        default:
            NSLog(@"unsupported C type %s ..", _type);
            break;
    }
}

- (void)encodeValueOfObjCType:(const char *)_type
                           at:(const void *)_value
{
    if (self->traceMode) {
        //NSLog(@"trace value at 0x%08X of type %s", _value, _type);
        [self _traceValueOfObjCType:_type at:_value];
    }
    else {
        if (self->didWriteHeader == false)
            [self writeArchiveHeader];
  
        [self _encodeValueOfObjCType:_type at:_value];
    }
}

- (void)encodeArrayOfObjCType:(const char *)_type
                        count:(unsigned int)_count
                           at:(const void *)_array
{

    if ((self->didWriteHeader == false) && (self->traceMode == false))
        [self writeArchiveHeader];

    //NGLogT(@"encoder", @"%s array[%i] of ObjC-type '%s'",
    //       self->traceMode ? "tracing" : "encoding", _count, _type);
  
    // array header
    if (self->traceMode == false) { // nothing is written during trace-mode
        _writeTag(self, _C_ARY_B);
        _writeInt(self, _count);
    }

    // Optimize writing arrays of elementary types. If such an array has to
    // be written, write the type and then the elements of array.

    if ((*_type == _C_ID) || (*_type == _C_CLASS)) { // object array
        unsigned int i;

        if (self->traceMode == false)
            _writeTag(self, *_type); // object array

        for (i = 0; i < _count; i++)
            [self encodeObject:((const id *)_array)[i]];
    }
    else if ((*_type == _C_CHR) || (*_type == _C_UCHR)) { // byte array
        if (self->traceMode == false) {
            //NGLogT(@"encoder", @"encode byte-array (base='%c', count=%i)", *_type, _count);

            // write base type tag
            _writeTag(self, *_type);

            // write buffer
            _writeBytes(self, _array, _count);
        }
    }
    else if (isBaseType(_type)) {
        if (self->traceMode == false) {
            unsigned offset, itemSize = objc_sizeof_type(_type);
            unsigned i;

            /*
              NGLogT(@"encoder",
              @"encode basetype-array (base='%c', itemSize=%i, count=%i)",
              *_type, itemSize, _count);
              */

            // write base type tag
            _writeTag(self, *_type);

            // write contents
            for (i = offset = 0; i < _count; i++, offset += itemSize)
                _writeObjC(self, (char *)_array + offset, _type);
        }
    }
    else { // encoded using normal method
        IMP      encodeValue = NULL;
        unsigned offset, itemSize = objc_sizeof_type(_type);
        unsigned i;

        encodeValue = [self methodForSelector:@selector(encodeValueOfObjCType:at:)];

        for (i = offset = 0; i < _count; i++, offset += itemSize) {
            encodeValue(self, @selector(encodeValueOfObjCType:at:),
                        (char *)_array + offset, _type);
        }
    }
}

// Substituting One Class for Another

- (NSString *)classNameEncodedForTrueClassName:(NSString *)_trueName
{
    NSString *name = [self->outClassAlias objectForKey:_trueName];
    return name ? name : _trueName;
}
- (void)encodeClassName:(NSString *)_name intoClassName:(NSString *)_archiveName
{
    [self->outClassAlias setObject:_archiveName forKey:_name];
}

// ******************** primitive encoding ********************

FINAL void _writeBytes(NSArchiver *self, const void *bytes, unsigned len)
{
    NSCAssert(self->traceMode == false, @"nothing can be written during trace-mode ..");
	[self->data appendBytes:bytes length:len];
}
FINAL void _writeTag(NSArchiver *self, NSTagType _tag)
{
    unsigned char t = _tag;
    NSCAssert(self, @"invalid self ..");
    _writeBytes(self, &t, sizeof(t));
}

FINAL void _writeInt(NSArchiver *self, int _value)
{
	[self serializeDataAt:&_value ofObjCType:@encode(int) context:self];
}

FINAL void _writeCString(NSArchiver *self, const char *_value)
{
	[self serializeDataAt:&_value ofObjCType:@encode(char *) context:self];
}

FINAL void _writeObjC(NSArchiver *self, const void *_value, const char *_type)
{
    if ((_value == NULL) || (_type == NULL))
        return;

    if (self->traceMode) {
        // no need to track base-types in trace-mode
    
        switch (*_type) {
            case _C_ID:
            case _C_CLASS:
            case _C_CHARPTR:
            case _C_ARY_B:
            case _C_STRUCT_B:
            case _C_PTR:
				{
					[self serializeDataAt:_value ofObjCType:_type context:self];
				}
                break;

            default:
                break;
        }
    }
    else {
		[self serializeDataAt:_value ofObjCType:_type context:self];
    }
}

// NSObjCTypeSerializationCallBack

- (void)serializeObjectAt:(id *)_object
               ofObjCType:(const char *)_type
                 intoData:(NSMutableData *)_data
{
    NSAssert(((*_type == _C_ID) || (*_type == _C_CLASS)), @"unexpected type ..");

    if (self->traceMode)
        [self _traceObject:*_object];
    else
        [self _encodeObject:*_object];
}
- (void)deserializeObjectAt:(id *)_object
        ofObjCType:(const char *)_type
        fromData:(NSData *)_data
        atCursor:(unsigned int *)_cursor
{
    [self doesNotRecognizeSelector:_cmd];
}

@end /* NSArchiver */

@implementation NSUnarchiver
{
	NSData     *data;
	NSZone     *objectZone;

	NSMapTable *inObjects;
	NSMapTable *inClasses;
	NSMapTable *inPointers;
	NSMapTable *inClassAlias;
	NSMapTable *inClassVersions;

	NSUInteger cursor;

	NSUInteger inArchiverVersion;
	bool decodingRoot;
	bool didReadHeader;
}

static NSMapTable *classToAliasMappings = NULL; // archive name => decoded name

+ (void)initialize
{
    static bool isInitialized = false;
    if (!isInitialized) {
        isInitialized = true;

		classToAliasMappings = [NSMapTable mapTableWithStrongToStrongObjects];
    }
}
  
- (id)initForReadingWithData:(NSData*)_data
{
    if ((self = [super init])) {
		inObjects       = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsIntegerPersonality|NSPointerFunctionsOpaqueMemory valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality];
		inClasses       = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsIntegerPersonality|NSPointerFunctionsOpaqueMemory valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality];
		inPointers      = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsIntegerPersonality|NSPointerFunctionsOpaqueMemory valueOptions:NSPointerFunctionsIntegerPersonality|NSPointerFunctionsOpaqueMemory];
		inClassAlias    = [NSMapTable mapTableWithStrongToStrongObjects];
		inClassVersions = [NSMapTable mapTableWithStrongToStrongObjects];
        self->data = _data;
    }
    return self;
}

/* Decoding Objects */

+ (id)unarchiveObjectWithData:(NSData*)_data
{
    NSUnarchiver *unarchiver = [[self alloc] initForReadingWithData:_data];
    id           object      = [unarchiver decodeObject];

    unarchiver = nil;
  
    return object;
}
+ (id)unarchiveObjectWithURL:(NSURL*)path
{
    NSData *rdata = [NSData dataWithContentsOfURL:path];
    if (!rdata) return nil;
    return [self unarchiveObjectWithData:rdata];
}


/* Managing an NSUnarchiver */

- (bool)isAtEnd
{
    return ([self->data length] <= self->cursor) ? true : false;
}

- (void)setObjectZone:(NSZone *)_zone
{
    self->objectZone = _zone;
}
- (NSZone *)objectZone
{
    return self->objectZone;
}

- (unsigned int)systemVersion
{
    return self->inArchiverVersion;
}

// ******************** primitive decoding ********************

FINAL void _readBytes(NSUnarchiver *self, void *_bytes, unsigned _len);

FINAL NSTagType _readTag(NSUnarchiver *self);

FINAL int   _readInt  (NSUnarchiver *self);

FINAL char *_readCString(NSUnarchiver *self);
FINAL void _readObjC(NSUnarchiver *self, void *_value, const char *_type);

// ******************** complex decoding **********************

- (void)decodeArchiveHeader
{
    if (self->didReadHeader == false) {
        char *archiver = _readCString(self);

        self->inArchiverVersion = _readInt(self);

        //NGLogT(@"decoder", @"decoding archive archived using '%s':%i ..",
        //       archiver, archiverVersion);

        if (strcmp(archiver, NSCoderSignature)) {
            NSLog(@"WARNING: used a different archiver (signature %s:%i)",
                  archiver, [self systemVersion]);
        }
        else if ([self systemVersion] != NSCoderVersion) {
            NSLog(@"WARNING: used a different archiver version "
                  @"(archiver=%i, unarchiver=%i)",
                  [self systemVersion], NSCoderVersion);
        }

        if (archiver) {
            free(archiver);
            archiver = NULL;
        }
        self->didReadHeader = true;
    }
}

- (void)beginDecoding
{
    //self->cursor = 0;
    [self decodeArchiveHeader];
}
- (void)endDecoding
{
#if 0
    NSResetMapTable(self->inObjects);
    NSResetMapTable(self->inClasses);
    NSResetMapTable(self->inPointers);
    NSResetMapTable(self->inClassAlias);
    NSResetMapTable(self->inClassVersions);
#endif

    self->decodingRoot = false;
}

- (Class)_decodeClass:(bool)_isReference
{
    int   archiveId = _readInt(self);
    Class result    = Nil;

    if (archiveId == 0) // Nil class or unused conditional class
        return nil;
    
    if (_isReference) {
        NSAssert(archiveId, @"archive id is 0 !");
        
		result = (Class)[self->inClasses objectForKey:(__bridge id)(void *)archiveId];
        if (result == nil)
            result = (id)[self->inObjects objectForKey:(__bridge id)(void *)archiveId];
        if (result == nil) {
			@throw [NSInconsistentArchiveException exceptionWithReason:[NSString stringWithFormat:@"did not find referenced class %i.", archiveId] userInfo:nil];
        }
    }
    else {
        NSString *name   = NULL;
        int      version = 0;
        char     *cname  = _readCString(self);

        if (cname == NULL) {
			@throw [NSInconsistentArchiveException exceptionWithReason:@"could not decode class name." userInfo:nil];
        }
        
        name    = [NSString stringWithUTF8String:cname];
        version = _readInt(self);
        free(cname); cname = NULL;
        
        if ([name length] == 0) {
			@throw [NSInconsistentArchiveException exceptionWithReason:@"could not allocate memory for class name." userInfo:nil];
        }

        { // check whether the class is to be replaced
			NSString *newName = [inClassAlias objectForKey:name];
      
            if (newName)
                name = newName;
            else {
				newName = [classToAliasMappings objectForKey:name];
                if (newName)
                    name = newName;
            }
        }
    
        result = NSClassFromString(name);

        if (result == Nil) {
			@throw [NSInconsistentArchiveException exceptionWithReason:@"class doesn't exist in this runtime." userInfo:nil];
        }
        name = nil;

        if ([result version] != version) {
            @throw [NSInconsistentArchiveException exceptionWithReason:@"class versions do not match." userInfo:nil];
        }

        [self->inClasses setObject:result forKey:(__bridge id)(void *)archiveId];
#if ARCHIVE_DEBUGGING
        NSLog(@"read class %i => 0x%08X", archiveId, result);
#endif
    }
  
    NSAssert(result, @"Invalid state, class is Nil.");
  
    return result;
}

- (id)_decodeObject:(bool)_isReference
{
    // this method returns a retained object !
    int archiveId = _readInt(self);
    id  result    = nil;

    if (archiveId == 0) // nil object or unused conditional object
        return nil;

    if (_isReference) {
        NSAssert(archiveId, @"archive id is 0 !");
        
        result = (id)[self->inObjects objectForKey:(__bridge id)(void *)archiveId];
        if (result == nil)
            result = (id)[self->inClasses objectForKey:(__bridge id)(void *)archiveId];
        
        if (result == nil) {
			@throw [NSInconsistentArchiveException exceptionWithReason:[NSString stringWithFormat:@"did not find referenced object %i.", archiveId] userInfo:nil];
        }
    }
    else {
        Class class       = Nil;
        id    replacement = nil;

        // decode class info
        [self decodeValueOfObjCType:"#" at:&class];
        NSAssert(class, @"could not decode class for object.");
    
        result = [class allocWithZone:self->objectZone];
        [self->inObjects setObject:result forKey:(__bridge id)(void *)archiveId];
        
#if ARCHIVE_DEBUGGING
        NSLog(@"read object %i => 0x%08X", archiveId, result);
#endif

        replacement = [result initWithCoder:self];
        if (replacement != result) {
            /*
              NGLogT(@"decoder",
              @"object 0x%08X<%s> replaced by 0x%08X<%s> in initWithCoder:",
              result, class_get_class_name(*(Class *)result),
              replacement, class_get_class_name(*(Class *)replacement));
            */

			[self->inObjects removeObjectForKey:(__bridge id)(void*)archiveId];
            result = replacement;
			[self->inObjects setObject:result forKey:(__bridge id)(void *)archiveId];
        }

        replacement = [result awakeAfterUsingCoder:self];
        if (replacement != result) {
            /*
              NGLogT(@"decoder",
              @"object 0x%08X<%s> replaced by 0x%08X<%s> in awakeAfterUsingCoder:",
              result, class_get_class_name(*(Class *)class),
              replacement, class_get_class_name(*(Class *)replacement));
            */
      
            [self->inObjects removeObjectForKey:(__bridge id)(void*)archiveId];
            result = replacement;
            [self->inObjects setObject:result forKey:(__bridge id)(void *)archiveId];
        }

        //NGLogT(@"decoder", @"decoded object 0x%08X<%@>",
        //       (unsigned)result, NSStringFromClass([result class]));
    }
    
    return result;
}

- (id)decodeObject
{
    id result = nil;

    [self decodeValueOfObjCType:"@" at:&result];
  
    // result is retained
    return result;
}

FINAL void _checkType(char _code, char _reqCode)
{
    if (_code != _reqCode) {
		@throw [NSInconsistentArchiveException exceptionWithReason:@"expected different typecode"
														  userInfo:nil];
    }
}
FINAL void _checkType2(char _code, char _reqCode1, char _reqCode2)
{
    if ((_code != _reqCode1) && (_code != _reqCode2)) {
		@throw [NSInconsistentArchiveException exceptionWithReason:@"expected different typecode"
														  userInfo:nil];
    }
}

- (void)decodeValueOfObjCType:(const char *)_type
  at:(void *)_value
{
    bool      startedDecoding = false;
    NSTagType tag             = 0;
    bool      isReference     = false;

    if (self->decodingRoot == false) {
        self->decodingRoot = true;
        startedDecoding = true;
        [self beginDecoding];
    }

    //NGLogT(@"decoder", @"cursor is now %i", self->cursor);
  
    tag         = _readTag(self);
    isReference = isReferenceTag(tag);
    tag         = tagValue(tag);

#if ARCHIVE_DEBUGGING
    NSLog(@"decoder: decoding tag '%s%c' type '%s'",
           isReference ? "&" : "", tag, _type);
#endif

    switch (tag) {
        case _C_ID:
            _checkType2(*_type, _C_ID, _C_CLASS);
            *(void **)_value = (__bridge_retained void *)[self _decodeObject:isReference];
            break;
        case _C_CLASS:
            _checkType2(*_type, _C_ID, _C_CLASS);
            *(Class *)_value = [self _decodeClass:isReference];
            break;

        case _C_ARY_B: {
            int        count     = atoi(_type + 1); // eg '[15I' => count = 15
            const char *itemType = _type;

            _checkType(*_type, _C_ARY_B);

            while(isdigit((int)*(++itemType))) ; // skip dimension

            [self decodeArrayOfObjCType:itemType count:count at:_value];
            break;
        }

        case _C_STRUCT_B: {
            int offset = 0;

            _checkType(*_type, _C_STRUCT_B);
      
            while ((*_type != _C_STRUCT_E) && (*_type++ != '=')); // skip "<name>="
        
            while (true) {
                [self decodeValueOfObjCType:_type at:((char *)_value) + offset];
            
                offset += objc_sizeof_type(_type);
                _type  =  objc_skip_typespec(_type);
            
                if(*_type != _C_STRUCT_E) { // C-structure end '}'
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

        case _C_SEL: {
            char *name = NULL;
      
            _checkType(*_type, tag);

            _readObjC(self, &name, @encode(char *));
            *(SEL *)_value = name ? sel_getUid(name) : NULL;
            free(name); name = NULL;
        }

        case _C_PTR:
            _readObjC(self, *(char **)_value, _type + 1); // skip '^'
            break;
      
        case _C_CHARPTR:
        case _C_CHR:    case _C_UCHR:
        case _C_SHT:    case _C_USHT:
        case _C_INT:    case _C_UINT:
        case _C_LNG:    case _C_ULNG:
        case _C_FLT:    case _C_DBL:
            _checkType(*_type, tag);
            _readObjC(self, _value, _type);
            break;
      
        default:
			@throw [NSInconsistentArchiveException exceptionWithReason:[NSString stringWithFormat:@"unsupported typecode %i found.", tag] userInfo:nil];
            break;
    }

    if (startedDecoding) {
        [self endDecoding];
        self->decodingRoot = false;
    }
}

- (void)decodeArrayOfObjCType:(const char *)_type
  count:(unsigned int)_count
  at:(void *)_array
{
    bool      startedDecoding = false;
    NSTagType tag   = _readTag(self);
    unsigned  count = _readInt(self);

    if (self->decodingRoot == false) {
        self->decodingRoot = true;
        startedDecoding = true;
        [self beginDecoding];
    }
  
    //NGLogT(@"decoder", @"decoding array[%i/%i] of ObjC-type '%s' array-tag='%c'",
    //       _count, count, _type, tag);
  
    NSAssert(tag == _C_ARY_B, @"invalid type ..");
    NSAssert(count == _count, @"invalid array size ..");

    // Arrays of elementary types are written optimized: the type is written
    // then the elements of array follow.
    if ((*_type == _C_ID) || (*_type == _C_CLASS)) { // object array
        NSUInteger i;

        //NGLogT(@"decoder", @"decoding object-array[%i] type='%s'", _count, _type);
    
        tag = _readTag(self); // object array
        NSAssert(tag == *_type, @"invalid array element type ..");
      
        for (i = 0; i < _count; i++)
            ((void **)_array)[i] = (__bridge void *)[self decodeObject];
    }
    else if ((*_type == _C_CHR) || (*_type == _C_UCHR)) { // byte array
        tag = _readTag(self);
        NSAssert((tag == _C_CHR) || (tag == _C_UCHR), @"invalid byte array type ..");

        //NGLogT(@"decoder", @"decoding byte-array[%i] type='%s' tag='%c'",
        //       _count, _type, tag);
    
        // read buffer
        _readBytes(self, _array, _count);
    }
    else if (isBaseType(_type)) {
        unsigned offset, itemSize = objc_sizeof_type(_type);
        unsigned i;
      
        tag = _readTag(self);
        NSAssert(tag == *_type, @"invalid array base type ..");

        for (i = offset = 0; i < _count; i++, offset += itemSize)
            _readObjC(self, (char *)_array + offset, _type);
    }
    else {
        IMP      decodeValue = NULL;
        unsigned offset, itemSize = objc_sizeof_type(_type);
        unsigned i;

        decodeValue = [self methodForSelector:@selector(decodeValueOfObjCType:at:)];
    
        for (i = offset = 0; i < count; i++, offset += itemSize) {
            decodeValue(self, @selector(decodeValueOfObjCType:at:),
                        (char *)_array + offset, _type);
        }
    }

    if (startedDecoding) {
        [self endDecoding];
        self->decodingRoot = false;
    }
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
	NSString *className = [self->inClassAlias objectForKey:_nameInArchive];
    return className ? className : _nameInArchive;
}
- (void)decodeClassName:(NSString *)nameInArchive asClassName:(NSString *)trueName
{
	[inClassAlias setObject:nameInArchive forKey:trueName];
}

// ******************** primitive decoding ********************

FINAL void _readBytes(NSUnarchiver *self, void *_bytes, unsigned _len)
{
    [self->data deserializeBytes:_bytes length:_len atCursor:&(self->cursor)];
}

FINAL NSTagType _readTag(NSUnarchiver *self)
{
    unsigned char c;
    NSCAssert(self, @"invalid self ..");

    _readBytes(self, &c, sizeof(c));
    if (c == 0) {
		@throw [NSInconsistentArchiveException exceptionWithReason:@"found invalid type tag (0)" userInfo:nil];
    }
    return (NSTagType)c;
}

FINAL int _readInt(NSUnarchiver *self)
{
    int value;
    [self->data deserializeDataAt:&value
    				   ofObjCType:@encode(int)
    				   	 atCursor:&self->cursor
    				   	  context:self];
    return value;
}

FINAL char *_readCString(NSUnarchiver *self)
{
    char *value = NULL;
    [self->data deserializeDataAt:&value
    				   ofObjCType:@encode(char *)
    				   	 atCursor:&self->cursor
    				   	  context:self];
    return value;
}

FINAL void _readObjC(NSUnarchiver *self, void *value, const char *type)
{
    [self->data deserializeDataAt:value
    				   ofObjCType:type
    				   	 atCursor:&self->cursor
    				   	  context:self];
}

// NSObjCTypeSerializationCallBack

- (void)serializeObjectAt:(id *)_object
  ofObjCType:(const char *)_type
  intoData:(NSMutableData *)_data
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)deserializeObjectAt:(id *)_object
  ofObjCType:(const char *)_type
  fromData:(NSData *)_data
  atCursor:(unsigned int *)_cursor
{
    NSTagType tag             = 0;
    bool      isReference     = false;

    tag         = _readTag(self);
    isReference = isReferenceTag(tag);
    tag         = tagValue(tag);

    NSCAssert(((*_type == _C_ID) || (*_type == _C_CLASS)),
              @"unexpected type ..");
  
    switch (*_type) {
        case _C_ID:
            NSAssert((*_type == _C_ID) || (*_type == _C_CLASS), @"invalid type ..");
            break;
            *_object = [self _decodeObject:isReference];
            break;
        case _C_CLASS:
            NSAssert((*_type == _C_ID) || (*_type == _C_CLASS), @"invalid type ..");
            *_object = [self _decodeClass:isReference];
            break;
      
        default:
			@throw [NSInconsistentArchiveException exceptionWithReason:[NSString stringWithFormat:@"encountered type '%s' in object context", _type] userInfo:nil];
            break;
    }
}

@end /* NSUnarchiver */

/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
*/
