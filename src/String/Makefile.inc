.PATH: ${.CURDIR}/String

CPPFLAGS += -I${CONTRIB}/lib/icu/source/io
SRCS+=	NSConcreteScanner.m \
		NSCoreString.mm \
		NSScanner.m \
		NSString.m \
		NSRegex.mm \
		unicodectype.c \
