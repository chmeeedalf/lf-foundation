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

#import <Foundation/DBusPort.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSString.h>
#import "internal.h"
#import "DBusCoder.h"
#import "DBusProxy.h"
#include <stdlib.h>
#include <string.h>

@interface NSObject(DBusIntrospection)
- (NSString *)_dbusIntrospectObject;
@end

static NSString * const DBusHeaderString = 
	@DBUS_INTROSPECT_1_0_XML_DOCTYPE_DECL_NODE
	@"<node>\n"
	@"  <interface name=\""@DBUS_INTERFACE_INTROSPECTABLE@"\">\n"
	@"    <method name=\"Introspect\">\n"
	@"      <arg name=\"data\" direction=\"out\" type=\""@DBUS_TYPE_STRING_AS_STRING@"\" />\n"
	@"    </method>\n"
	@"  </interface>\n";

@implementation NSObject(DBusIntrospection)

extern __private int dbusTypeInt[];

static NSString *StringForMethodDescription(SEL name, const char *types)
{
	char *meth_name = strdup(sel_getName(name));
	/* Don't export private methods. */
	if (meth_name[0] == '_')
		return nil;

	for (char *s = meth_name; s && *s; s++)
	{
		if (*s == ':') *s = '_';
	}
	NSMutableString *str = [NSMutableString stringWithFormat:@"    <method name=\"%s\">\n",meth_name];
	char type = dbusTypeInt[(unsigned int)*objc_skip_type_qualifiers(types)];
	if (type != 0)
		[str appendFormat:@"      <arg name=\"ret\" type=\"%c\" direction=\"out\" />\n",type];
	/* type length of 3 - return value, self, _cmd */
	if (strlen(types) > 3)
	{
	}
	[str appendFormat:@"    </method>\n"];
	free(meth_name);
	return str;
}

- (NSString *)_dbusIntrospectObject
{
	NSMutableString *str = [NSMutableString string];
	[str appendString:DBusHeaderString];
	for (Class cls = object_getClass(self); cls; cls = class_getSuperclass(cls))
	{
		size_t count;
		Protocol **list = class_copyProtocolList(cls, &count);
		for (int i = 0; i < count; i++)
		{
			size_t mlist_count = 0;
			struct objc_method_description *methods = protocol_copyMethodDescriptionList(list[i], true, true, &mlist_count);
			[str appendFormat:@"  <interface name=\"protocol.%s\">\n",protocol_getName(list[i])];
			for (int j = 0; j < mlist_count; j++)
			{
				[str appendString:StringForMethodDescription(methods[j].name, methods[j].types)];
			}
			[str appendString:@"  </interface>\n"];
			if (methods)
				free(methods);
		}
		if (list)
			free(list);

		Method *methods = class_copyMethodList(cls, &count);
		[str appendFormat:@"  <interface name=\"class.%s\">\n", class_getName(cls)];
		for (int i = 0; i < count; i++)
		{
			[str appendString:StringForMethodDescription(method_getName(methods[i]), method_getTypeEncoding(methods[i]))];
		}
		[str appendString:@"  </interface>\n"];
		if (methods)
			free(methods);
	}
	[str appendString:@"</node>"];
	return str;
}
@end

@interface DBusPort()
- (DBusCoder *)_coder;
- (void) _sendReply:(DBusMessage *)mess;
@end

@implementation DBusProxy
- initWithConnection:(DBusPort *)conn object:(id)obj
{
	connection = [conn retain];
	coder = [[conn _coder] retain];
	target = [obj retain];
	return self;
}

- (void) dealloc
{
	[connection release];
	[target release];
	[coder release];
	[super dealloc];
}

- (DBusHandlerResult) _handleDBus:(DBusMessage *)mess
{
	DBusMessage *reply;
	if (target == nil)
	{
		return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;
	}
	/* First we handle DBus standard messages. */
	const char *interface = dbus_message_get_interface(mess);
	if ((interface != NULL && strcmp(interface, DBUS_INTERFACE_INTROSPECTABLE) == 0) && strcmp(dbus_message_get_member(mess), "Introspect") == 0)
	{
		dbus_message_set_member(mess, "_dbusIntrospectObject");
	}
	/* Handle target-specific messages. */
	NSInvocation *inv = [coder decodeInvocation:mess];
	if (inv == nil)
		return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;

	@try
	{
		[inv invoke];
		if (dbus_message_get_no_reply(mess))
			return DBUS_HANDLER_RESULT_HANDLED;
		reply = [coder encodeInvocationReturn:inv];
	}
	@catch(NSException *except)
	{
		[coder encodeException:except];
	}
	[connection _sendReply:reply];
	dbus_message_unref(reply);
	return DBUS_HANDLER_RESULT_HANDLED;
}

- (id) target
{
	return target;
}

- (NSMethodSignature *) methodSignatureForSelector:(SEL)sel
{
	return [target methodSignatureForSelector:sel];
}
@end
