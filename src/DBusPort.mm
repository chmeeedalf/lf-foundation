/* $Gold$	*/
/*
 * Copyright (c) 2009-2011	Gold Project
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

#import "internal.h"
#import <Alepha/RunLoop.h>
#import <Foundation/DBusPort.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMapTable.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import "DBusCoder.h"
#import "DBusProxy.h"
#include <cstdlib>
#include <string.h>
#include <sys/event.h>
#include <dbus/dbus.h>

@interface DBusPortPrivate
{
	@public
	DBusConnection *dbusConnection;
	DBusCoder *coder;
	/* Only one watch for now */
	DBusWatch *watch;
	NSString *name;
	bool listening;
	RunLoop *runLoop;
}
@end

#define _private	(*((DBusPortPrivate **)&self->_private))

#if 0
Brain dump 2009-12-14 22:22 --

Replace the method interface code with a DBusProxy so we can dole out proxies and handle methods more appropriately, rather than sending them all to the single connection.

Use a DBusMessage as an invocation object or coder object.  This will split it out to more closely follow the DBus API.

DBusPort will be relegated to managing the actual connection and event loop interaction.

---- 2011-04-03 21:25 EDT ----

As a distributed objects medium, DBusPort and DBusCoder are the only necessary
classes.  DBusProxy will stick around for a while longer to handle DBus-specific
messages, but anything beyond that goes straight to the NSDistantObject proxy.  I
may instead merge the DBusProxy in with the DBusPort, as the Port is supposed to
handle all messages by default anyway (typically simply passing them up to the
NSConnection class).
#endif

@interface DBusPort(_GoldPrivate)
- (void) _dbusListen;
@end

@implementation DBusPort
@synthesize name;

#if 0
static DBusHandlerResult handleDBus(DBusConnection *, DBusMessage *, void *);
static void freeDBus(DBusConnection *, void *);
static const DBusObjectPathVTable _dbusDispatcher = {freeDBus, handleDBus};
static DBusPort *sessionBus;
static DBusPort *systemBus;

static DBusHandlerResult handleDBus(DBusConnection *conn, DBusMessage *mess, void *obj)
{
	return [(DBusProxy *)obj _handleDBus:mess];
}

static void freeDBus(DBusConnection *conn, void *obj)
{
	[(DBusProxy *)obj release];
}

static dbus_bool_t DBusAddWatch(DBusWatch *watch, void *data)
{
	DBusPort *self = reinterpret_cast<DBusPort *>(data);

	/* Only register one watch. */
	if (_private->watch != NULL)
		return true;

	Alepha::RunLoop::File *f = new
		Alepha::RunLoop::File(dbus_watch_get_unix_fd(watch));

	[[self runLoop] addRunLoopSource:f target:self
		selector:@selector(handleEvent:forLoop:) mode:DefaultRunLoopMode];
	_private->watch = watch;
	return true;
}

static void DBusRemoveWatch(DBusWatch *watch, void *data)
{
	DBusPort *d = reinterpret_cast<DBusPort *>(data);
	[[d runLoop] removeRunLoopTarget:d];
}

+(void) initialize
{
	dbus_threads_init_default();
}

+ sessionBus
{
	@synchronized(self)
	{
		if (sessionBus == nil)
			sessionBus = [[DBusPort alloc] initWithBusType:DBUS_BUS_SESSION];
	}
	return sessionBus;
}

+ systemBus
{
	@synchronized(self)
	{
		if (systemBus == nil)
			systemBus = [[DBusPort alloc] initWithBusType:DBUS_BUS_SYSTEM];
	}
	return systemBus;
}

- initWithBusType:(DBusBusType) busType
{
	DBusError err;

	if ((self = [super init]) == nil)
	{
		return nil;
	}
	_private = [[DBusPortPrivate alloc] init];
	memset(&err, 0, sizeof(err));
	_private->dbusConnection = dbus_bus_get(busType, &err);
	if (dbusConnection == 0)
	{
		NSLog(@"DBus connection failed: %s: %s\n", err.name, err.message);
		[self release];
		return nil;
	}
	coder = [[DBusCoder alloc] initWithConnection:self];
	return self;
}

- (DBusCoder *) _coder
{
	return coder;
}

- (void) dealloc
{
	if (dbusConnection != NULL)
		dbus_connection_unref(dbusConnection);
	[coder release];
	[super dealloc];
}

- (void) setName:(NSString *)newName
{
	DBusError err;
	NSString *oldName = _private->name;

	memset(&err, 0, sizeof(err));
	if (newName != nil)
	{
		if (dbus_bus_request_name(dbusConnection, [newName UTF8String], 0, &err) < 0)
		{
			NSLog(@"%s: %s\n", err.name, err.message);
			return;
		}
	}
	_private->name = [newName copy];
	[oldName release];
}

- (void) _dbusListen
{
	do
	{
		dbus_connection_read_write_dispatch(dbusConnection, 0);
	}
	while (dbus_connection_get_dispatch_status(dbusConnection) == DBUS_DISPATCH_DATA_REMAINS);
}

- (void) registerObject:(id)obj withPath:(NSString *)path
{
	DBusProxy *proxy = [[DBusProxy alloc] initWithConnection:self object:obj];
	if (!dbus_connection_register_object_path(dbusConnection, [path UTF8String], &_dbusDispatcher, proxy))
	{
		[proxy release];
	}
}

- (void) setRootObject:(id)object
{
	[self registerObject:object withPath:@"/"];
}

- (void) unregisterObjectPath:(NSString *)path
{
	dbus_connection_unregister_object_path(dbusConnection, [path UTF8String]);
	[served removeObjectForKey:path];
}

- (id) objectForPath:(NSString *)path
{
	id object;
	if (dbus_connection_get_object_path_data(dbusConnection, [path UTF8String], (void **)&object))
		return object;
	return nil;
}

- (void) addToRunLoop:(RunLoop *)loop
{
	runLoop = [loop retain];

	if (!dbus_connection_set_watch_functions(dbusConnection, DBusAddWatch,
				DBusRemoveWatch, NULL, self, NULL))
	{
		NSLog(@"NSError setting dbus watch functions");
		[loop release];
		runLoop = nil;
	}
}

- (void) getEventRegistry:(struct kevent **)events count:(size_t *)num forLoop:(RunLoop *)_loop
{
}

- (void)handleEvent:(struct kevent *)event forLoop:(RunLoop *)runLoop
{
	if (!dbus_watch_get_enabled(watch))
		NSLog(@"Oops!");
	else
		NSLog(@"Clear!");
	[self _dbusListen];
}

- (void) _sendReply:(DBusMessage *)reply
{
	dbus_connection_send(dbusConnection, reply, NULL);
	dbus_connection_read_write(dbusConnection, 0);
}

+ (Class) portCoderClass
{
	return [DBusCoder class];
}

- (bool) sendBeforeDate:(NSDate *)date msgid:(uint32_t)msgid components:(NSArray *)comp from:(Port *)from reserved:(size_t)reserved
{
	return false;
}
#endif

@end
