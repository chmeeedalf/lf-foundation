.PATH: ${.CURDIR}/DateTime

CPPFLAGS+= -I${.CURDIR}/NSString
SRCS+= NSConcreteDate.m \
	   NSConcreteTimeZone.mm \
	   NSDate.m \
	   NSTimeZone.m \
