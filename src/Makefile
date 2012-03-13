TOPDIR=${.CURDIR}/../../../../../
CONTRIB= ${TOPDIR}/contrib
DBUSFLAGS!=pkg-config --cflags dbus-1
LIBXMLFLAGS!=pkg-config --cflags libxml-2.0
CPPFLAGS=	-I$(PWD) -I${TOPDIR}/system/include
CPPFLAGS+= -DVERSION=\"1.0\" -DSTRUCT_ALIGNMENT=4 -DGOLD -DNO_LSDID #-nostdinc
CPPFLAGS+= ${DBUSFLAGS} -I/usr/local/include #-I${CONTRIB}/lib/icu/source/common ${DBUSFLAGS}
CPPFLAGS+= ${LIBXMLFLAGS}
CPPFLAGS+= -DU_USING_ICU_NAMESPACE=0
LDADD=-L/GoldRoot/obj -L/system/lib -L/usr/local/lib -lAlepha -lexecinfo -ldbus-1 -licuio -licuuc -licui18n -licudata -lffi -ldispatch -lxml2#-lboost_serialization
LIB=	System
SHLIB_MAJOR= 1
SHLIB_MINOR= 0
NO_MAN=true
LIBDIR=	/system/lib/libs
PICFLAG=-fPIC

CLEANFILES=	ConcreteNumber.m
# Only included for now

.include "${TOPDIR}/contrib/Rules.mk"

#CC=${GOLD_ROOT}/bin/gcc
#CXX=${GOLD_ROOT}/bin/g++
#CC=/system/cmds/gcc
#CXX=/system/cmds/g++
CXX:=powerpc-unknown-freebsd9.0-g++
CC:=powerpc-unknown-freebsd9.0-gcc
OBJC=${CC}
OBJCXX=${CXX}
#NM=${GOLD_ROOT}/bin/nm
#LD=${GOLD_ROOT}/bin/ld

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
		NSApplication.m \
		NSCoder.m \
		NSKeyedArchiver.m \
		NSKeyedUnarchiver.m \
		NSArchiver.mm \
		NSMethodSignature.m \
		NSNull.m \
		NSURI.m \
		NSNotificationCenter.m \
		NSNotification.m \
		NSSettingsManager.m \
		NSLocale.m NSConcreteLocale.mm \
		NSTimer.m \
		NSProxy.m \
		NSDistantObject.m \
		NSProtocolChecker.m \
		NSPortCoder.m \
		NSPort.m \
		NSTask.m \
		NSKeyValueCoding.m \
		NSKeyValueObserving.m \
		NSKVCMutableArray.m \
		NSKeyValueObserving.m \
		NSSocket.m \
		NSNetworkAddress.m \
		NSXMLParser.m \
		NSConnection.m \
		DBusPort.mm \
		DBusCoder.m \
		DBusProxy.m \
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
		NSCompoundPredicate.m \
		NSComparisonPredicate.m \
		NSPredicateParser.mm \
		NSHost.m \
		NSPortMessage.m \
		NSXMLMIMECoder.m \
		NSIndexPath.mm \
		NSCache.mm \
		NSFormatter.m \
		NSNumberFormatter.m \
		NSDateFormatter.m \
		NSOperation.m \
		NSURI+ObjectManager.m \
		NSObjectManagerFile.m \
		PropertyList.m \
		PropertyListSerialization.m \
		NSRegularExpression.m \
		NSJSONSerialization.m \
		NSTextCheckingResult.m \
		GSICUString.m \

.include "Base/Makefile.inc"
.include "Collections/Makefile.inc"
.include "DateTime/Makefile.inc"
.include "Stream/Makefile.inc"
.include "String/Makefile.inc"
#.include "UndoManager/Makefile.inc"
#.include "unicode/Makefile.inc"
.include "URI/Makefile.inc"

NSConcreteNumber.m: NSConcreteNumber.m.sh
	${.CURDIR}/NSConcreteNumber.m.sh > $@

# These have to go after the includes, because they set CPPFLAGS
.ifndef(NDEBUG)
OPTFLAGS+=-O0 -fno-inline -g3
.else
OPTFLAGS+=-O2 -fno-strict-aliasing
.endif

CCXXFLAGS=$(OPTFLAGS) $(CPPFLAGS) -fexceptions -Wall #-fno-unit-at-a-time 
.if ${CC} == "clang"
CCXXFLAGS+=-Qunused-arguments
.endif

CXXFLAGS+=-std=gnu++0x
OBJCCXXFLAGS=-fobjc-exceptions -Wno-selector -fconstant-string-class=NSConstantString -fobjc-abi-version=2 #-fnext-runtime -fno-objc-sjlj-exceptions #-fobjc-zerocost-exceptions -fno-objc-sjlj-exceptions -fnext-runtime 
#.ifdef(CLANG)
OBJCCXXFLAGS+=-fgnu-runtime -fobjc-abi-version=3
#.endif
OBJCXXFLAGS=$(CXXFLAGS) $(OBJCCXXFLAGS) -fvisibility=default -fobjc-call-cxx-cdtors
CFLAGS+=$(CCXXFLAGS)
CSTD=gnu99
OBJCFLAGS=$(CFLAGS) $(OBJCCXXFLAGS)
OBJCXXFLAGS+=-I/usr/local/include -mno-altivec -Wno-deprecated-declarations
.include <bsd.lib.mk>
