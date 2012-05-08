DBUSFLAGS!=pkg-config --cflags dbus-1
LIBXMLFLAGS!=pkg-config --cflags libxml-2.0
CPPFLAGS=	-I$(PWD) -I$(PWD)/../Headers -I/usr/local/include
CPPFLAGS+= -DVERSION=\"1.0\" -DGOLD -DNO_LSDID
CPPFLAGS+= ${DBUSFLAGS}
CPPFLAGS+= ${LIBXMLFLAGS}
LDADD=-L/usr/local/lib -lAlepha -lexecinfo -ldbus-1 -licuio -licuuc -licui18n -licudata -lffi -ldispatch -lxml2 #-lboost_serialization
LIB=	Foundation
SHLIB_MAJOR= 1
SHLIB_MINOR= 0
NO_MAN=true
PICFLAG=-fPIC

CLEANFILES=	ConcreteNumber.m
# Only included for now

CXX=clang++
CC=clang
OBJC=${CC}
OBJCXX=${CXX}
NM=/usr/local/bin/nm
LD=/usr/local/bin/ld
AS=/usr/local/bin/as

SRCS=	NSRange.m \
		NSObjectAllocation.mm \
		NSObject.m \
		NSEnumerator.m \
		NSException.m \
		NSInvocation.m \
		NSProcessInfo.mm \
		NSResourceManager.m \
		NSUtilities.m \
		NSThread.m \
		NSLock.m \
		common.m \
		NSGeometry.m \
		NSNumber.m NSConcreteNumber.m \
		NSValue.m NSConcreteValue.m \
		NSDecimalNumber.m \
		NSDecimal.m \
		NSApplication.m \
		NSCoder.m \
		NSKeyedArchiver.m \
		NSKeyedUnarchiver.m \
		NSArchiver.mm \
		NSMethodSignature.m \
		NSNull.m \
		NSURL.m \
		NSNotificationCenter.mm \
		NSNotification.m \
		NSDistributedNotificationCenter.m \
		NSSettingsManager.m \
		NSLocale.m NSConcreteLocale.mm \
		NSTimer.m \
		NSProxy.m \
		NSDistantObject.m \
		NSProtocolChecker.m \
		NSPortCoder.m \
		NSPort.m \
		NSTask.mm \
		NSKeyValueCoding.mm \
		NSKeyValueObserving.mm \
		NSKVCMutableArray.m \
		NSSocket.m \
		NSNetworkAddress.m \
		NSXMLParser.m \
		NSConnection.m \
		NSSortDescriptor.m \
		NSFileManager.m \
		NSRunLoop.mm \
		NSPointerFunctions.m \
		NSError.m \
		NSCalendar.m \
		NSAttributedString.m \
		NSCoreAttributedString.m \
		NSExpression.m \
		NSValueTransformer.m \
		NSPathUtilities.m \
		NSAccount.mm \
		NSBundle.m \
		NSUserDefaults.mm \
		NSDelegate.m \
		NSPredicate.m \
		NSPredicateParser.mm \
		NSCompoundPredicate.m \
		NSComparisonPredicate.m \
		NSHost.m \
		NSPortMessage.m \
		NSXMLMIMECoder.m \
		NSIndexPath.mm \
		NSCache.mm \
		NSFormatter.m \
		NSNumberFormatter.m \
		NSDateFormatter.m \
		NSOperation.m \
		NSURL+ObjectManager.m \
		NSObjectManagerFile.m \
		PropertyList.m \
		PropertyListSerialization.m \
		NSRegularExpression.m \
		NSJSONSerialization.mm \
		NSTextCheckingResult.m \
		GSICUString.m \

#		DBusPort.mm \
#		DBusCoder.m \
#		DBusProxy.m \

.include "Base/Makefile.inc"
.include "Collections/Makefile.inc"
.include "DateTime/Makefile.inc"
.include "Stream/Makefile.inc"
.include "String/Makefile.inc"
#.include "UndoManager/Makefile.inc"
#.include "unicode/Makefile.inc"
.include "NSURL/Makefile.inc"

NSConcreteNumber.m: NSConcreteNumber.m.sh
	${.CURDIR}/NSConcreteNumber.m.sh > $@

# These have to go after the includes, because they set CPPFLAGS
.ifndef(NDEBUG)
OPTFLAGS+=-O0 -fno-inline -g3
.endif

CCXXFLAGS=$(OPTFLAGS) $(CPPFLAGS) -fblocks  -fexceptions #-Wall -fno-unit-at-a-time 
.if ${CC} == "clang"
CCXXFLAGS+=-Qunused-arguments
.endif

CXXFLAGS+=-std=c++11 -stdlib=libc++
CSTD=gnu99

OBJCCXXFLAGS=-fobjc-exceptions -fobjc-abi-version=3 
OBJCCXXFLAGS+=-fgnu-runtime -fconstant-string-class=NSConstantString
OBJCCXXFLAGS+=-fobjc-arc -fobjc-arc-exceptions -Wno-arc-performSelector-leaks 
#OBJCCXXFLAGS+=-fcolor-diagnostics
WARNS=3
OBJCXXFLAGS=$(CXXFLAGS) $(OBJCCXXFLAGS) -fvisibility=default -fobjc-call-cxx-cdtors
CFLAGS+=$(CCXXFLAGS) -B/usr/local/bin/
OBJCFLAGS=$(CFLAGS) $(OBJCCXXFLAGS)
.include <bsd.lib.mk>
CFLAGS+= -Wno-system-headers
CXXFLAGS+= -Wno-system-headers -Wno-return-type-c-linkage
