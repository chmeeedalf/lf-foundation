/*
 * Copyright (c) 2004,2005,2011	Gold Project
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
 * THIS SOFTWARE IS PROVIDED BY THE PROJECT ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#include <stdint.h>
#include <sys/endian.h>
#include <netinet/in.h>

enum NSByteOrder {
	NS_UnknownByteOrder,
    NS_LittleEndian,
    NS_BigEndian
};

typedef struct
{
	unsigned long long v;
} NSSwappedDouble;

typedef struct
{
	unsigned int v;
} NSSwappedFloat;

static inline NSSwappedDouble NSConvertHostDoubleToSwapped(double x)
{
	union {
		double dbl;
		NSSwappedDouble sdbl;
	} y;
	y.dbl = x;
	return y.sdbl;
}

static inline NSSwappedFloat NSConvertHostFloatToSwapped(float x)
{
	union {
		float flt;
		NSSwappedFloat sflt;
	} y;
	y.flt = x;
	return y.sflt;
}

static inline double NSConvertSwappedDoubleToHost(NSSwappedDouble sdbl)
{
	union {
		double dbl;
		NSSwappedDouble sdbl;
	} y;
	y.sdbl = sdbl;
	return y.dbl;
}

static inline float NSConvertSwappedFloatToHost(NSSwappedFloat x)
{
	union {
		float flt;
		NSSwappedFloat sflt;
	} y;
	y.sflt = x;
	return y.flt;
}

static inline unsigned int NSHostByteOrder(void)
{
#if WORDS_BIGENDIAN
	return NS_BigEndian;
#else
	return NS_LittleEndian;
#endif
}

static inline unsigned int NSSwapBigIntToHost(unsigned int x)
{
	return be32toh(x);
}

static inline unsigned long long NSSwapBigLongLongToHost(unsigned long long x)
{
	return be64toh(x);
}

static inline unsigned long NSSwapBigLongToHost(unsigned long x)
{
	return ntohl(x);
}

static inline unsigned short NSSwapBigShortToHost(unsigned short x)
{
	return be16toh(x);
}

static inline NSSwappedDouble NSSwapDouble(NSSwappedDouble x)
{
	return (NSSwappedDouble){htole64(be64toh(x.v))};
}

static inline NSSwappedFloat NSSwapFloat(NSSwappedFloat x)
{
	return (NSSwappedFloat){htole32(be32toh(x.v))};
}

static inline unsigned int NSSwapHostIntToBig(unsigned int x)
{
	return htobe32(x);
}

static inline unsigned int NSSwapHostIntToLittle(unsigned int x)
{
	return htole32(x);
}

static inline unsigned long long NSSwapHostLongLongToBig(unsigned long long x)
{
	return htobe64(x);
}

static inline unsigned long long NSSwapHostLongLongToLittle(unsigned long long x)
{
	return htole64(x);
}

static inline unsigned long NSSwapHostLongToBig(unsigned long x)
{
	return htonl(x);
}

static inline unsigned long NSSwapHostLongToLittle(unsigned long x)
{
	return htole32(x);
}

static inline unsigned int NSSwapLittleIntToHost(unsigned int x)
{
	return le32toh(x);
}

static inline unsigned long long NSSwapLittleLongLongToHost(unsigned long long x)
{
	return le64toh(x);
}

static inline unsigned long NSSwapLittleLongToHost(unsigned long x)
{
#if ULONG_MAX == UINT_MAX
	return le32toh(x);
#else
	return le64toh(x);
#endif
}

static inline unsigned short NSSwapLittleShortToHost(unsigned short x)
{
	return le16toh(x);
}

static inline unsigned int NSSwapInt(unsigned int x)
{
	return htobe32(le32toh(x));
}

static inline unsigned long NSSwapLong(unsigned long x)
{
#if ULONG_MAX == UINT_MAX
	return htobe32(le32toh(x));
#else
	return htobe64(le64toh(x));
#endif
}

static inline unsigned long long NSSwapLongLong(unsigned long long x)
{
	return htobe64(le64toh(x));
}

static inline unsigned short NSSwapShort(unsigned short x)
{
	return htobe16(le16toh(x));
}

static inline double NSSwapBigDoubleToHost(NSSwappedDouble x)
{
	x.v = be64toh(x.v);
	return *(double*)&x.v;
}

static inline float NSSwapLittleDoubleToHost(NSSwappedDouble x)
{
	x.v = le64toh(x.v);
	return *(double*)&x.v;
}

static inline NSSwappedDouble NSSwapHostDoubleToBig(double x)
{
	return (NSSwappedDouble){htobe64(*(unsigned long long *)&x)};
}

static inline NSSwappedDouble NSSwapHostDoubleToLittle(double x)
{
	return (NSSwappedDouble){htole64(*(unsigned long long *)&x)};
}

static inline float NSSwapBigFloatToHost(NSSwappedFloat x)
{
	x.v = be32toh(x.v);
	return *(float*)&x.v;
}

static inline float NSSwapLittleFloatToHost(NSSwappedFloat x)
{
	x.v = le32toh(x.v);
	return *(float*)&x.v;
}

static inline NSSwappedFloat NSSwapHostFloatToBig(float x)
{
	return (NSSwappedFloat){htobe32(*(unsigned int *)&x)};
}

static inline NSSwappedFloat NSSwapHostFloatToLittle(float x)
{
	return (NSSwappedFloat){htole32(*(unsigned int *)&x)};
}

/*
   vim:syntax=objc:
 */
