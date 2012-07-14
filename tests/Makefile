CPPFLAGS=-I${PWD}/../Headers -I${PWD}
CPPFLAGS+= -I${PWD}/../src
CPPFLAGS+= -I/usr/local/include
CPPFLAGS+= -I${HOME}/include
CFLAGS=$(CPPFLAGS) -std=gnu99 -g -O0 -fexceptions
LDFLAGS=-L../src -L${PWD} -L/GoldRoot/obj -L/usr/local/lib -L${HOME}/gold_build
LDADD=-lTest -lFoundation -licuuc -licudata -licuio -ldispatch -lffi -lxml2 -ldbus-1 -lexecinfo -lBlocksRuntime #-lobjc -lAlepha
OBJCLIBS=
PROG_CXX=test
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
	  ProcessInfo_test.m \
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
CXX=clang++
CC=clang
OBJC=${CC}
OBJCXX=${CXX}

CXXFLAGS+=-std=c++11 #-stdlib=libc++
CSTD=gnu99

CCXXFLAGS=$(OPTFLAGS) $(CPPFLAGS) -fblocks  -fexceptions #-Wall -fno-unit-at-a-time
OBJCCXXFLAGS=-fobjc-exceptions -fobjc-abi-version=3
OBJCCXXFLAGS+=-fgnu-runtime -fconstant-string-class=NSConstantString
OBJCCXXFLAGS+=-fobjc-arc -fobjc-arc-exceptions -Wno-arc-performSelector-leaks
#OBJCCXXFLAGS+=-fcolor-diagnostics
WARNS=3
OBJCXXFLAGS=$(CXXFLAGS) $(OBJCCXXFLAGS) -fvisibility=default -fobjc-call-cxx-cdtors
CFLAGS+=$(CCXXFLAGS) -B/usr/local/bin/
OBJCFLAGS=$(CFLAGS) $(OBJCCXXFLAGS)
.include <bsd.lib.mk>
CFLAGS+= -Wno-system-headers -Wno-unused-parameter
CXXFLAGS+= -Wno-system-headers -Wno-return-type-c-linkage -Wno-unused-parameter
OBJCFLAGS+= -Wno-system-headers -Wno-unused-parameter
OBJCXXFLAGS+= -Wno-system-headers -Wno-return-type-c-linkage -Wno-unused-parameter
.include <bsd.prog.mk>
