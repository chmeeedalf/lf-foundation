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

#include <sys/cdefs.h>
#include <sys/param.h>
#include <stdlib.h>

#ifdef __cplusplus
#include <functional>
#endif
#include <SysCall.h>
#include <Foundation/NSObjCRuntime.h>
#include <objc/encoding.h>
#include <Foundation/primitives.h>
#ifdef __OBJC__
#import <Foundation/NSCalendar.h>
#import <Foundation/NSConnection.h>
#import <Foundation/NSExpression.h>
#import <Foundation/NSPointerFunctions.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSSocket.h>
#import <Foundation/NSString.h>
#import <Foundation/NSTask.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSURLProtocol.h>
#include <unicode/ucal.h>
#endif

#ifdef __cplusplus
namespace
{
	/* This will go away when Adam commits the Alepha threading mutex code. */
	class spin_lock
	{
		pthread_spinlock_t spinlock;
		public:
		spin_lock()
		{ 
			pthread_spin_init(&spinlock, PTHREAD_PROCESS_PRIVATE);
		}
		~spin_lock()
		{
			pthread_spin_destroy(&spinlock);
		}
		void lock() { pthread_spin_lock(&spinlock); }
		void unlock() { pthread_spin_unlock(&spinlock); }
	};

	/*
	 * A singleton class:  Wrap this around any type to make accesses global and
	 * locked, as so:
	 * 
	 * typedef Singleton<std::unordered_map> foo;
	 * foo::type foo::value;
	 *
	 * It gets treated as a singleton pointer.
	 *
	 * To access it, create an instance of the Singleton, and all access for the
	 * current scope is locked behind the spinlock.
	 */
	template < class T >
	class Singleton
	{
		public:
		class type : public T
		{
			public:
			spin_lock spinlock;
		};
		private:
		static type value;
		public:
		Singleton() { value.spinlock.lock(); }
		~Singleton() { value.spinlock.unlock(); }
		T *operator->() { return &value; }
		T &operator*() { return value; }
	};
}
namespace std
{
	template<>
	struct equal_to<id>
	{
		bool operator()(id other, id obj) const
		{
			return [obj isEqual:other];
		}
	};
}

namespace std
{
	template<>
	struct hash<id>
	{
		size_t operator()(id obj) const
		{
			return [obj hash];
		}
	};
}
#endif

__BEGIN_DECLS

#define structSizeof(str, member) \
	sizeof(((str *)0)->member)

/* Fast log10(x)
 * Rationale:  assuming that a byte is 8 bits,
 * sizeof(x) - __builtin_clz(x) yields the most significant 1 bit.
 * Adding 2 rounds it to the next multiple of 3, unless it's already a
 * multiple of 3.  Dividing by 3 yields log_10(x), because 10 is greater
 * than 2^3 and less than 2^4.
 */
#define fast_log10(x)	(((sizeof(x) * 8) - __builtin_clz(x) + 2)/3 + 2)

NSHashCode hashjb(const char* name, int len) __private;

extern unsigned int numThreads __private;

typedef int		 (*cmp_t)(const void *, const void *);
void *runThread(void *thr) __private;
void class_insert_class (Class class_ptr) __private;

#ifdef __OBJC__
@class NSProxy;
@class NSDictionary;

@interface NSThread()
- (pthread_t) _pthreadId;
@end

@interface NSCalendar(Private)
+ (NSCalendar *) _calendarWithUCalendar:(UCalendar *)cal;
- (UCalendar *) _ucalendar;
@end

@interface NSPointerFunctions ()
- (void) _fixupEmptyFunctions;
@end

@class NSDictionary;

@interface NSObject(GoldPrivate)
-(void)release:(bool)autorelease;
@end

struct sockaddr_storage;
@interface NSNetworkAddress(FreeBSD)
- (void)_sockaddrRepresentation:(struct sockaddr_storage *)repr;
- (id)initWithSockaddrRepresentation:(struct sockaddr_storage *)repr;
@end

@interface NSURL(URL_ObjectManager)
- (id)handler;
@end

@interface NSConnection()
- (NSDistantObject *) proxyForLocal:(id)local;
- (void) setProxy:(NSDistantObject *)proxy forLocal:(id)local;
- (void) forwardInvocation:(NSInvocation *)inv forProxy:(NSProxy *)proxy;
@end

@interface NSSocket(FreeBSD)
- (void) _sockaddrRepresentation:(struct sockaddr_storage *)saddr;
@end

@interface NSProcessInfo()
- (void) _initArgc:(size_t)argc argv:(const char **)argv;
@end

@interface NSExpression()
- (id)_expressionWithSubstitutionVariables:(NSDictionary *)substVars;
@end

@interface NSURLProtocol()<NSStreamDelegate>
@end

@interface NSTask(PrivateBookkeeping)
+ (void) _dispatchExitToPid:(UUID)child status:(int) status exitedNormally:(bool)normalExit;
@end
bool spawnProcessWithURL(NSURL *, id, NSDictionary *, UUID *);

static inline bool object_isInstance(id obj)
{
	return !(class_isMetaClass(object_getClass(obj)));
}
#endif

// 1MB stacks should be plenty big
#define THR_STACK_SIZE	(1024 * 1024)

#ifdef __FreeBSD__
#ifdef __OBJC__
@class NSArray;
#else
typedef struct NSArray NSArray;
#endif
void threadedSignalHandler(int sig, NSArray *thrArray, SEL sel, SEL handler, bool exclusive);

extern void _AsyncWatchDescriptor(int fd, id target, SEL action, bool writing);
extern void _AsyncUnwatchDescriptor(int fd, bool writing);

#endif

static inline void cleanup_pointer(void *ptr)
{
	free(*(void **)ptr);
}

#define __cleanup(x)	__attribute__((cleanup(x)))

#ifdef __clang__
#define NS_RETURNS_RETAINED	__attribute__((ns_returns_retained))
#else
#define NS_RETURNS_RETAINED
#endif

__END_DECLS
