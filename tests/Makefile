CPPFLAGS=-I${PWD}/../Headers -I${PWD} -D_FreeBSD_ -I${PWD}/../../../../include
CPPFLAGS+= -I${PWD}/../src
CPPFLAGS+= -I/usr/local/include
CFLAGS=$(CPPFLAGS) -std=gnu99 -g -O0 -fexceptions
OBJCFLAGS=${CFLAGS} -fobjc-abi-version=2 -fobjc-exceptions -fconstant-string-class=NSConstantString #-fno-objc-sjlj-exceptions -fobjc-zerocost-exceptions -fnext-runtime -fconstant-string-class=NXConstantString
LDFLAGS=-L../src -L${PWD} -L/GoldRoot/obj -L/usr/local/lib
LDADD=-lTest -lSystem -lobjcxx -lobjc #-licuuc -licudata -licuio -ldispatch -lffi -lxml2 -ldbus-1 -lexecinfo -lAlepha
OBJCLIBS=
PROG=test
SRCS= Array_test.m \
	  Object_test.m \
	  Data_test.m \
	  Dictionary_test.m \
	  String_test.m \
	  Set_test.m \
	  Date_test.m \
	  Scanner_test.m \
	  Number_test.m \
	  Notification_test.m \
	  NotificationCenter_test.m \
	  Value_test.m \
	  Task_test.m \
	  Thread_test.m \
	  Lock_test.m \
	  XMLParser_test.m \
	  NetworkAddress_test.m \
	  Socket_test.m \
	  FileManager_test.m \
	  Regex_test.m \
	  ProcessInfo_test.m \
	  URI_test.m \
	  Misc_test.m \
	  NSPredicate_test.m \
#	AssertionHandler_test.m \
#	CharacterSet_test.m \
#	Host_test.m \
#	Invocation_test.m \
#	MethodSignature_test.m \
#	ProcessInfo_test.m \
#	Proxy_test.m \
#	ResourceManager_test.m \
#	ObjectManager_test.m \
#	Exception_test.m \

#CC=/system/cmds/gcc
#CXX=/system/cmds/g++
CXX=powerpc-unknown-freebsd9.0-g++
CC=powerpc-unknown-freebsd9.0-gcc
OBJC=${CC}
OBJCXXFLAGS=${OBJCFLAGS}
OBJCXX=/system/cmds/g++

.include <bsd.prog.mk>
