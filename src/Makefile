#DBUSFLAGS!=pkg-config --cflags dbus-1
LIBXMLFLAGS!=pkg-config --cflags libxml-2.0
CPPFLAGS=	-I$(PWD) -I$(PWD)/../Headers -I/usr/local/include
#CPPFLAGS+= ${DBUSFLAGS}
CPPFLAGS+= ${LIBXMLFLAGS}
LDADD=-L/usr/local/lib -lexecinfo -licuio -licuuc -licui18n -licudata -lffi -ldispatch -lxml2
#-lboost_serialization -ldbus-1
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
		NSRecursiveLock.m \
		NSConditionLock.m \
		NSCondition.m \
		common.m \
		NSGeometry.m \
		NSNumber.m NSConcreteNumber.m \
		NSValue.m NSConcreteValue.m \
		NSDecimalNumber.m \
		NSDecimal.m \
		NSApplication.m \
		NSCoder.m \
		NSKeyedArchiver.m \
		NSArchiver.mm \
		NSMethodSignature.m \
		NSNull.m \
		NSURL.m \
		NSNotificationCenter.mm \
		NSNotification.m \
		NSNotificationQueue.m \
		NSDistributedNotificationCenter.m \
		NSLocale.m NSConcreteLocale.mm \
		NSTimer.m \
		NSProxy.m \
		NSDistantObject.m \
		NSProtocolChecker.m \
		NSPortCoder.m \
		NSPort.m \
		NSSocketPort.m \
		NSPortNameServer.m \
		NSSocketPortNameServer.m \
		NSNetServices.m \
		NSTask.mm \
		NSKeyValueCoding.mm \
		NSKeyValueObserving.mm \
		NSKVCMutableArray.m \
		NSKVCMutableOrderedSet.m \
		NSKVCMutableSet.m \
		NSSocket.m \
		NSNetworkAddress.m \
		NSConnection.m \
		NSSortDescriptor.m \
		NSFileManager.m \
		NSFileHandle.mm \
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
		NSHost.m \
		NSPortMessage.m \
		NSIndexPath.mm \
		NSCache.mm \
		NSFormatArgumentParser.m \
		NSFormatter.m \
		NSNumberFormatter.m \
		NSDateFormatter.m \
		NSOperation.m \
		NSURL+ObjectManager.m \
		NSObjectManagerFile.m \
		NSPropertyList.m \
		NSRegularExpression.m \
		NSJSONSerialization.mm \
		NSTextCheckingResult.m \
		NSSpellServer.m \
		NSLinguisticTagger.m \
		NSOrthography.m \
		NSUndoManager.m \
		GSICUString.m \
		NSXMLParser.m \
		NSXMLMIMECoder.m \
		NSXMLDTD.m \
		NSXMLDTDNode.m \
		NSXMLDocument.m \
		NSXMLElement.m \
		NSXMLMIMECoder.m \
		NSXMLNode.m \
		NSXMLParser.m \

#		NSPredicateParser.mm \
#		DBusPort.mm \
#		DBusCoder.m \
#		DBusProxy.m \

.include "Base/Makefile.inc"
.include "Collections/Makefile.inc"
.include "DateTime/Makefile.inc"
.include "Stream/Makefile.inc"
.include "String/Makefile.inc"
.include "NSURL/Makefile.inc"

NSConcreteNumber.m: NSConcreteNumber.m.sh
	${.CURDIR}/NSConcreteNumber.m.sh > $@

# These have to go after the includes, because they set CPPFLAGS
.ifndef(NDEBUG)
OPTFLAGS+=-O0 -fno-inline -g3
.endif

CCXXFLAGS=$(OPTFLAGS) $(CPPFLAGS) -fblocks  -fexceptions
#.if ${CC} == "clang"
.ifdef(ANALYZE)
CCXXFLAGS+=--analyze -Xanalyzer -analyzer-checker=osx.API -Xanalyzer -analyzer-checker=osx.cocoa.Loops -Xanalyzer -analyzer-checker=osx.cocoa.NilArg -Xanalyzer -analyzer-checker=osx.cocoa.SelfInit -Xanalyzer
#.endif
.endif

CXXFLAGS+=-std=c++11
CSTD=gnu99

OBJCCXXFLAGS=-fobjc-exceptions -fobjc-abi-version=3 
OBJCCXXFLAGS+=-fgnu-runtime -fconstant-string-class=NSConstantString
OBJCCXXFLAGS+=-fobjc-arc -fobjc-arc-exceptions -Wno-arc-performSelector-leaks 
#OBJCCXXFLAGS+=-fcolor-diagnostics
WARNS=3
OBJCXXFLAGS=$(CXXFLAGS) $(OBJCCXXFLAGS) -fvisibility=default -fobjc-call-cxx-cdtors
CFLAGS+=$(CCXXFLAGS) #-B/usr/local/bin/
OBJCFLAGS=$(CFLAGS) $(OBJCCXXFLAGS)
.include <bsd.lib.mk>
CFLAGS+= -Wno-system-headers -Wno-unused-parameter
CXXFLAGS+= -Wno-system-headers -Wno-return-type-c-linkage -Wno-unused-parameter
OBJCFLAGS+= -Wno-system-headers -Wno-unused-parameter
OBJCXXFLAGS+= -Wno-system-headers -Wno-return-type-c-linkage -Wno-unused-parameter

.SUFFIXES: .m .mm 

.m.o:
	${OBJC} ${OBJCFLAGS} -c ${.IMPSRC}
	${CTFCONVERT_CMD}

.mm.o:
	${OBJCXX} ${OBJCXXFLAGS} -c ${.IMPSRC}
	${CTFCONVERT_CMD}

.m.po:
	${OBJC} ${OBJCFLAGS} -pg -c ${.IMPSRC} -o ${.TARGET}
	${CTFCONVERT_CMD}

.m.So:
	${OBJC} ${PICFLAG} -DPIC ${OBJCFLAGS} -c ${.IMPSRC} -o ${.TARGET}
	${CTFCONVERT_CMD}

.mm.po:
	${OBJCXX} ${OBJCXXFLAGS} -pg -c ${.IMPSRC} -o ${.TARGET}
	${CTFCONVERT_CMD}

.mm.So:
	${OBJCXX} ${PICFLAG} -DPIC ${OBJCXXFLAGS} -c ${.IMPSRC} -o ${.TARGET}
	${CTFCONVERT_CMD}

