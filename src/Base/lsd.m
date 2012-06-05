/*
 * Copyright (c) 2005-2012	Justin Hibbits
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

/*
   This is the kernel-specific portion of the System framework, for LSD.
 */

#include <sys/cdefs.h>
#include <sys/param.h>
//#include <SysCall.h>
//#include <Event.h>
#import <Foundation/NSApplication.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#include <stdlib.h>
#include <string.h>


// Status flags
#define BLOCK_TAKEN			0x80
#define BLOCK_SET_KERNEL	0x01

void eventHandler (Event_t *_eventPage);

struct sysReqPageHead
{
	pthread_mutex_t	mtx;
	uint64_t		currentUID;
	uint8_t		flags[PAGE_SIZE / sizeof(Event_t)];
};

#ifndef __FreeBSD__
static int processID;
#endif

/* Shared among all threads now */
__private Event_t *sysReqPage;
__private Event_t eventPage[PAGE_SIZE/sizeof(Event_t)];


// argument must point to the head of the page
static int __unused reserveSystemRequestBlock(void *sysReqPage)
{
	struct sysReqPageHead	*sysReqPageRoot = sysReqPage;
	int		i = 1;
	int		maxIndex = PAGE_SIZE / sizeof(Event_t);

	pthread_mutex_lock(&sysReqPageRoot->mtx);

	// Search forever for an item.
	while (1)
	{
		for (; i < maxIndex; i++)
		{
			if (!(sysReqPageRoot->flags[i] & BLOCK_TAKEN) &&
					!(sysReqPageRoot->flags[i] & BLOCK_SET_KERNEL))
			{
				break;
			}
		}

		if (i != maxIndex)
		{
			break;
		}
		pthread_mutex_unlock(&sysReqPageRoot->mtx);
		yield();
		pthread_mutex_lock(&sysReqPageRoot->mtx);
	}
	sysReqPageRoot->flags[i] |= BLOCK_TAKEN;
	pthread_mutex_unlock(&sysReqPageRoot->mtx);
	return i;
}

@interface _LSDPrivateInvocation : NSInvocation
@end

/* We don't verify the signature for our invocation because it's intentionally
 * different.
 */
@implementation _LSDPrivateInvocation
- (void) _verifySignature
{
}
@end

/*
   The purpose of the event handler is to farm out events through proxies into
   this process.  Since the application is the real proxy, deserialize the
   message, and forward it to the application.  This will most likely have to be
   done with assembly code, to populate the registers appropriately.
 */
void eventHandler (Event_t *_eventPage)
{
	void *data_ptr = (unsigned char *)_eventPage->payload;
	Method m;
	_LSDPrivateInvocation *appInvocation;
	const char *types;
	char *types_out;
	SEL messageSel = (SEL)_eventPage->message;

	@autoreleasepool {

		if (NSApp == nil)
			NSApp = [NSApplication new];

		// If the message selector is NULL, the message is a NUL-terminated string
		// at the start of the payload.
		if (messageSel == 0)
		{
			messageSel = sel_getUid((char *)_eventPage->payload);
			/* Re-point the start of the data payload to the first aligned word
			 * after the selector string.
			 */
			data_ptr = (_eventPage->payload +
					((strlen((char *)_eventPage->payload) +
					  sizeof(unsigned long) - 1) & ~(sizeof(unsigned long) - 1)));
		}
		m = class_getInstanceMethod([NSApp class], (SEL)_eventPage->message);

		if (m == NULL)
			return;

		types = method_getTypeEncoding(m);
		/* We're not adding any because, although we need to append a ^v to it, we
		 * are also removing multiple numbers from it (3 or more).
		 */
		types_out = calloc(sizeof(char), strlen(types) + 1);
		if (types_out == NULL)
			abort();

		/* This block needs some explaining:  Count the number of arguments in the
		 * real message, while simultaneously adding a final, hidden argument, a
		 * pointer to the raw event buffer.
		 */
		{
			unsigned long numArgs = method_getNumberOfArguments(m);
			size_t len = strlen(types);

			char *types2;
			method_getReturnType(m, types_out, len);
			types2 = types_out + strlen(types_out);
			len -= strlen(types_out);
			for (unsigned long i = 0; i < numArgs; i++)
			{
				method_getArgumentType(m, i, types2, len);
				len -= strlen(types2);
				types2 += strlen(types2);
			}
			strcat(types_out, "^v");

			appInvocation = [[_LSDPrivateInvocation alloc]
				initWithMethodSignature:[NSMethodSignature
				 signatureWithObjCTypes:types_out]];

			free(types_out);

			[appInvocation setTarget:NSApp];
			[appInvocation setSelector:messageSel];
			for (unsigned long i = 2; i < numArgs; i++)
			{
				char types[len];
				method_getArgumentType(m, i, types, sizeof(types));
				if (*types == _C_ARY_B)
					[appInvocation setArgument:&data_ptr atIndex:i];
				else
					[appInvocation setArgument:data_ptr atIndex:i];
			}
			data_ptr = _eventPage;
			[appInvocation setArgument:&data_ptr atIndex:numArgs];
		}
		{
			[appInvocation invoke];
		}
	}
}

// This will take 2 system requests
#if 0
int spawn(void (*func)(void*), void *data)
{
	return 0;
}
#endif

#ifndef __FreeBSD__
int getpid(void)
{
    return processID;
}

void __noreturn abort(void)
{
	__builtin_trap();
	terminate();
}
#endif
