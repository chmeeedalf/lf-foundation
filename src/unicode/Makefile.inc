#.PATH: ${CONTRIB}/lib/icu/source/common
#.PATH: ${CONTRIB}/lib/icu/source/i18n
.PATH: ${CONTRIB}/lib/icu/source/io
#.PATH: ${CONTRIB}/lib/icu/source/layout
#.PATH: ${CONTRIB}/lib/icu/source/layoutex
.PATH: ${.CURDIR}/unicode
#.PATH: ${CONTRIB}/lib/icu/source/stubdata

#CPPFLAGS += -I${CONTRIB}/lib/icu/source/common
#CPPFLAGS += -I${CONTRIB}/lib/icu/source/i18n
#CPPFLAGS += -I${CONTRIB}/lib/icu/source/io
CFLAGS += -Wno-sign-compare

SRCS += locbund.c \
		sprintf.c \
		ucln_io.c \
		ufmt_cmn.c \
		uprntf_p.c \
