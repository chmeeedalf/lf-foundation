/*
 * Copyright (c) 2009	Gold Project
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

#import <Foundation/NSArray.h>
#import <Foundation/NSByteOrder.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSProxy.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import <stdlib.h>
#import <string.h>
#import "internal.h"
#import "DBusCoder.h"

__private int dbusTypeInt[] = {
	[_C_ID] = 0,
	[_C_CLASS] = 0,
	[_C_SEL] = 0,
	[_C_CHR] = DBUS_TYPE_BYTE,
	[_C_UCHR] = DBUS_TYPE_BYTE,
	[_C_SHT] = DBUS_TYPE_INT16,
	[_C_USHT] = DBUS_TYPE_UINT16,
	[_C_INT] = DBUS_TYPE_INT32,
	[_C_UINT] = DBUS_TYPE_UINT32,
#if LONG_MAX == INT_MAX
	[_C_LNG] = DBUS_TYPE_INT32,
	[_C_ULNG] = DBUS_TYPE_UINT32,
#else
	[_C_LNG] = DBUS_TYPE_INT64,
	[_C_ULNG] = DBUS_TYPE_UINT64,
#endif
	[_C_LNG_LNG] = DBUS_TYPE_INT64,
	[_C_ULNG_LNG] = DBUS_TYPE_UINT64,
	[_C_FLT] = DBUS_TYPE_DOUBLE,
	[_C_DBL] = DBUS_TYPE_DOUBLE,
	[_C_BOOL] = DBUS_TYPE_BOOLEAN,
	[_C_CHARPTR] = DBUS_TYPE_STRING,
};

static int objcDBusType[] = {
	[DBUS_TYPE_BYTE] = _C_UCHR,
	[DBUS_TYPE_INT16] = _C_SHT,
	[DBUS_TYPE_UINT16] = _C_USHT,
	[DBUS_TYPE_INT32] = _C_INT,
	[DBUS_TYPE_UINT32] = _C_UINT,
	[DBUS_TYPE_INT64] = _C_LNG_LNG,
	[DBUS_TYPE_UINT64] = _C_ULNG_LNG,
	[DBUS_TYPE_DOUBLE] = _C_DBL,
	[DBUS_TYPE_BOOLEAN] = _C_BOOL,
	[DBUS_TYPE_STRING] = _C_CHARPTR,
	[DBUS_TYPE_INVALID] = 0,
};

/*
 * For encoding/decoding DBus messages
 */

static void DecodeFromDBus(DBusMessageIter *iter, const char *type, void *data)
{
	type = objc_skip_type_qualifiers(type);
	switch (*type)
	{
		case _C_ID:
			{
				//id obj = *(id *)data;
			}
			break;
		case _C_STRUCT_B:
			type++;
			// XXX: This line is broken, needs to be really written.
			// dbus_message_iter_open_container(iter, DBUS_TYPE_STRUCT)
			break;
		case _C_ARY_B:
			{
				int i;
				type++;
				i = strtol(type, NULL, 10);
				dbus_message_iter_get_fixed_array(iter, data, &i);
				return;
			}
		case _C_ARY_E:
		case _C_STRUCT_E:
			break;
		case _C_PTR:
			break;
		case _C_CHARPTR:
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
			dbus_message_iter_get_basic(iter, data);
			break;
		case _C_CLASS:
			break;
		case _C_SEL:
			break;
		case _C_UNDEF:
			break;
		case _C_UNION_B:
		case _C_UNION_E:
		case _C_BFLD:
			break;
	}
}

/* Encode objects using XDR. */
@implementation DBusCoder

- initWithReceivePort:(NSPort *)rcvPort sendPort:(NSPort *)sndPort components:(NSMutableArray *)components
{
	NSParameterAssert([rcvPort isKindOfClass:[DBusPort class]]);
	NSParameterAssert([sndPort isKindOfClass:[DBusPort class]]);

	TODO;	// initWithReceivePort:sendPort:components:
	return self;
}

- initWithConnection:(DBusPort *)conn
{
	connection = conn;
	return self;
}

- initWithEncodedBytes:(void *)bytes length:(unsigned long)length
{
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)encodeRootObject:(id)rootObject
{
	NSParameterAssert([rootObject isKindOfClass:[NSInvocation class]]);
	if (![rootObject isKindOfClass:[NSInvocation class]])
	{
		NSLog(@"Root object is not an invocation.");
		return;
	}
	//dbus_message_new();
    [self encodeObject:rootObject];
}

- (void) encodeInvocation:(NSInvocation *)inv
{
	message = dbus_message_new(DBUS_MESSAGE_TYPE_METHOD_CALL);
	dbus_message_iter_init(message, &iter);
}

- (DBusMessage *) encodeInvocationReturn:(NSInvocation *)inv
{
	DBusMessage *mess = dbus_message_new_method_return(message);
	SEL sel = [inv selector];
	union {
		int32_t byte32;
		uint32_t ubyte32;
		int64_t byte64;
		uint64_t ubyte64;
		double doublev;
		id objcId;
	} returnValue;
	NSMethodSignature *sig = [[inv target] methodSignatureForSelector:sel];

	[inv getReturnValue:&returnValue];
	const char *retType = objc_skip_type_qualifiers([sig methodReturnType]);
	int t = *retType;
	switch (t)
	{
		case _C_ID:
			break;
		default:
			dbus_message_append_args(mess, dbusTypeInt[t], &returnValue, DBUS_TYPE_INVALID);
			return mess;
	}

	// XXX: TODO: This is a hack to see if I can correctly return a string.
	if ([returnValue.objcId isKindOfClass:[NSString class]])
	{
		const char *str = [returnValue.objcId UTF8String];
		dbus_message_append_args(mess, DBUS_TYPE_STRING, &str, DBUS_TYPE_INVALID);
	}
	else if ([returnValue.objcId isKindOfClass:[NSValue class]])
	{
		const char *objcType = [returnValue.objcId objCType];
		const int type = dbusTypeInt[(unsigned int)*objc_skip_type_qualifiers(objcType)];
		size_t size = objc_sizeof_type(objcType);
		void *retval = malloc(size);
		memset(retval, 0, size);
		if (type == DBUS_TYPE_STRUCT || type == DBUS_TYPE_ARRAY)
		{
			TODO; // struct and array (encodeInvocationReturn:message:
		}
		else
		{
			[returnValue.objcId getValue:retval];
			dbus_message_append_args(mess, type, retval);
		}
		free(retval);
	}
	return mess;
}

- (NSInvocation *) decodeInvocation:(DBusMessage *)mess
{
	int type;
	char *methodName __cleanup(cleanup_pointer) = strdup(dbus_message_get_member(mess));
	char *s = methodName;
	SEL methodSel;
	Method method;
	NSInvocation *inv;

	id object = [[connection objectForPath:[NSString stringWithCString:dbus_message_get_path(mess) encoding:NSUTF8StringEncoding]] target];

	if (methodName == NULL)
	{
		NSLog(@"%s: Out of memory retrieving DBus method information.", __func__);
		return nil;
	}
	if (s && *s == '_')
	{
		if (strcmp(s, "_dbusIntrospectObject") != 0)
			return nil;
	}
	else
	{
		while (s && *s)
		{
			if (*s == '_')
				*s = ':';
			s++;
		}
	}
	methodSel = sel_getUid(methodName);
	method = class_getInstanceMethod(object_getClass(object), methodSel);
	unsigned int argCount = method_getNumberOfArguments(method);
	if (method == NULL)
	{
		NSLog(@"Warning: NSObject of type %@ does not respond to message %s.", [object className], methodName);
		return nil;
	}
	inv = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)]];
	int i = 2;	/* Start counting at 2, to skip the target and selector. */
	[inv setSelector:method_getName(method)];
	[inv setTarget:object];

	dbus_message_iter_init(mess, &iter);
	while (((type = dbus_message_iter_get_arg_type(&iter)) != DBUS_TYPE_INVALID) && i < argCount)
	{
		/* Fill out the arguments.  Goes as follows:
		 * - Basic types that match in both signatures, or are compatible, are
		 *   converted directly.
		 * - Struct is extracted appropriately.  Basic structs are extracted
		 *   directly into memory.  If the struct begins with an object path
		 *   of '/classes/' it's treated as an object, so the object path would
		 *   be similar to '/classes/NSDate', and the struct format would be an
		 *   encoding of a NSDate object.
		 * - If the DBus type is an NSObject path, it's extracted as a
		 *   NSDistantObject instance, to proxy back to the other side of the
		 *   connection.
		 * - If the DBus type is a string and the method type argument is an
		 *   object, the string is extracted into a NSString * object.
		 * - If the DBus type is an array, and the method type argument is an
		 *   object, the array is extracted into an NSArray, and all items in the
		 *   array are converted to appropriate objects, converting to NSValue
		 *   types as appropriate.
		 * - All other types are extracted to NSValue * objects if the
		 *   corresponding method argument type is an object.
		 */

		union {
			uint32_t	bit32;
			uint64_t	bit64;
			double		floating;
			const char	*str;
		} val;
		switch (type)
		{
			default:
				{
					char objcType = objcDBusType[type];
					DecodeFromDBus(&iter, &objcType, &val);
				}
		}
		i++;
	}
	return inv;
}

- (void)encodeValueOfObjCType:(const char*)type
	at:(const void*)address
{
	int dbType;
	type = objc_skip_type_qualifiers(type);
	dbType = dbusTypeInt[(unsigned int)*type];
	if (dbType != 0)
	{
		if (dbType == DBUS_TYPE_STRING)
			address = &address;
		dbus_message_iter_append_basic(&iter, dbType, address);
		return;
	}
	switch (*type)
	{
		case _C_ID:
			{
				address = [(id)address replacementObjectForPortCoder:self];
			}
			break;
		case _C_STRUCT_B:
			type++;
			// XXX: This line is broken, needs to be really written.
			// dbus_message_iter_open_container(iter, DBUS_TYPE_STRUCT)
			break;
		case _C_ARY_B:
			{
				NSIndex i;
				type++;
				i = strtol(type, NULL, 10);
				dbus_message_iter_append_fixed_array(&iter, dbType, address, i);
				return;
			}
		case _C_ARY_E:
		case _C_STRUCT_E:
			break;
		case _C_PTR:
			break;
		case _C_CLASS:
			break;
		case _C_SEL:
			break;
		case _C_UNDEF:
			break;
		case _C_UNION_B:
		case _C_UNION_E:
		case _C_BFLD:
			break;
	}
}

- (void)decodeValueOfObjCType:(const char*)type
	at:(void*)address
{
	DecodeFromDBus(&iter, type, address);
}

- (unsigned int)systemVersion
{
    return 0;
}

- (unsigned int)versionForClassName:(NSString*)className
{
    return 0;
}

- (void) encodeException:(NSException *)except
{
	const char *except_name = [[@"NSException." stringByAppendingString:[except name]] UTF8String];
	const char *reason = [[except reason] UTF8String];
	message = dbus_message_new_error(message, except_name, reason);
}

@end /* DBusCoder */
