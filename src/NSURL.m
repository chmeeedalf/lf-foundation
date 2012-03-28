/*
 * Copyright (c) 2005-2012	Gold Project
 * * Redistribution and use in source and binary forms, with or without
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

#include <unicode/uidna.h>
#include <stdlib.h>
#include <ctype.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSHost.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSPathUtilities.h>

@interface NSURL()
- (NSURL *) _URLWithNewPath:(NSString *)newPath;
@end

@implementation NSURL

static inline bool _reserved(NSUniChar ch)
{
	switch (ch)
	{
		case ';':
		case '/':
		case '?':
		case ':':
		case '@':
		case '&':
		case '=':
		case '+':
		case '$':
		case ',':
			return true;
	}
	return false;
}

static inline bool _numeric(NSUniChar ch)
{
	return (ch >= '0') && (ch <= '9');
}

static inline bool _alpha(NSUniChar ch)
{
	return ((ch >= 'A') && (ch <= 'Z')) || ((ch >= 'a') && (ch <= 'z'));
}

static inline bool _mark(NSUniChar ch)
{
	switch (ch)
	{
		case '-':
		case '_':
		case '.':
		case '!':
		case '~':
		case '*':
		case '\'':
		case '(':
		case ')':
			return true;
	}
	return false;
}

static inline bool _unreserved(NSUniChar ch)
{
	return (_alpha(ch) || _numeric(ch) || _mark(ch));
}

static inline bool _escaped(NSUniChar *ch)
{
	return (*ch == '%' && isxdigit(*(ch+1)) &&
			isxdigit(*(ch + 2)));
}

static inline bool uric(NSUniChar *ch)
{
	return (_reserved(*ch) || _unreserved(*ch) || _escaped(ch));
}

static inline NSString *_fragmentQuery(NSUniChar **str, NSUniChar sep)
{
	NSUniChar *usedStr = *str + 1;
	NSUniChar *start = *str + 1;

	if (**str != sep)
		return nil;

	while (uric(usedStr))
	{
		if (_escaped(usedStr))
			usedStr += 2;
		usedStr++;
	}
	*str = usedStr;
	return (usedStr - start) == 0 ? nil :
		[NSString stringWithCharacters:start length:(usedStr - start)];
}

static NSString *makeScheme(NSUniChar **str)
{
	bool first = true;
	char ch;
	NSIndex i = 0;
	for (;;)
	{
		ch = (*str)[i];
		if (('a' <= ch && ch <= 'z') || ('A' <= ch && ch <= 'Z') ||
				(!first && (('0' <= ch && ch <= '9') || ch == '+' ||
							ch == '-' || ch == '.')))
		{
			i++;
		}
		else
		{
			break;
		}
		first = false;
	}
	if (!first)
	{
		*str += i;
		return [NSString stringWithCharacters:(*str - i) length:i];
	}
	return nil;
}

// TODO: Handle escapes (right now just note that they exist)
static inline bool _regName(NSURL *self, NSUniChar **strp)
{
	NSUniChar *str = *strp;

	for (;;)
	{
		if (_unreserved(*str))
		{
			str++;
			continue;
		}
		if (_escaped(str))
		{
			str += 3;
			continue;
		}
		switch (*str)
		{
			case '$':
			case ',':
			case ';':
			case ':':
			case '@':
			case '&':
			case '=':
			case '+':
				str++;
				continue;
			default:
				return false;
		}
	}
	self->hostName = [[NSString alloc] initWithCharacters:*strp
		length:(str - *strp)];
	*strp = str;
	return true;
}

static inline void _port(NSURL *self, NSUniChar **strp)
{
	uint32_t port = 0;

	for (;;)
	{
		if (_numeric(**strp))
		{
			port *= 10;
			port += (**strp - '0');
			(*strp)++;
		}
		else
		{
			break;
		}
	}
	self->port = [NSNumber numberWithUnsignedInt:port];
}

static inline NSString *_domain_top_label(NSUniChar **strp)
{
	NSUniChar *str = *strp;
	NSUniChar *start = str;

	if (!_alpha(*(str)) && !_numeric(*(str)))
	{
		return nil;
	}

	str++;

	while (_numeric(*str) || _alpha(*str) || (*str == '-'))
	{
		str++;
	}

	if (*(str - 1) == '-')
	{
		return nil;
	}

	*strp = str;
	return [[NSString alloc] initWithCharacters:start length:(str - start)];
}

static inline NSString *_hostname(NSUniChar **strp)
{
	NSUniChar *str = *strp;
	NSString *lastStr, *prevStr = nil;
	NSIndex len;

	while ((lastStr = _domain_top_label(strp)))
	{
		if (**strp != '.')
			break;
		else
		{
			prevStr = lastStr;
		}
		(*strp)++;
	}

	len = [prevStr length];

	if (*strp > str && !_alpha(*(*strp - len)))
	{
		*strp = str;
		return nil;
	}

	if (str != *strp)
	{
		NSString *newStr = [NSString stringWithCharacters:str length:(*strp - str)];
		return newStr;
	}
	*strp = str;
	return nil;
}

static inline NSString *_ipv4AddressInt(NSUniChar **strp)
{
	NSUniChar *str = *strp;
	int i, j;

	for (i = 0; i < 4; i++)
	{
		j = 0;
		while (('0' <= *str && *str <= '9') && j++ < 3)
		{
			str++;
		}

		if (i == 3)
		{
			if (*str && *str != '/' && *str != ':')
				return nil;
			else
			{
				NSUniChar *stro = *strp;
				*strp = str;
				return [[NSString alloc] initWithCharacters:stro
					length:(str - stro)];
			}
		}

		if (*str != '.')
			return nil;
		str++;
	}
	return nil;
}

static inline NSHost *_ipv4Address(NSUniChar **strp, NSString **strIP)
{
	NSString *str = _ipv4AddressInt(strp);
	if (str != nil)
	{
		NSHost *ret = nil; //[NSHost hostWithUnresolvedAddress:str];
		*strIP = str;
		return ret;
	}
	return nil;
}

static inline int _hexDigit(NSUniChar *strp)
{
	NSUniChar *str = strp;
	for (int i = 0; i < 4; i++)
	{
		if (!isxdigit(*str))
			break;
		str++;
	}
	return str - strp;
}

static inline int _ipv6end(NSUniChar *strp)
{
	int n;
	NSString *str;
	int x = _hexDigit(strp);
	if (*(strp + x) == ':')
	{
		n = x + 1 + _hexDigit(strp + x + 1);
		if (n > x + 1)
			return n;
	}
	n = [(str = (_ipv4AddressInt(&strp))) length];
	return n;
}

static inline NSHost *_ipv6Address(NSUniChar **strp, NSString **strIP)
{
	if (**strp != '[')
		return nil;

	NSUniChar *str = *strp;
	bool hasTwoColon = false;
	int x;
	int lhs = 0;
	int rhs = 0;

	str++;

	while ((x = _hexDigit(str)) > 0)
	{
		if (*(str + x) != ':')
			return nil;
		str += x + 1;
		lhs++;
		if (lhs == 6)
		{
			if ((x = _ipv6end(str)) == 0)
				return nil;
			str += x;
			if (*(str++) != ']')
				return nil;
			goto done;
		}
	}

	if (lhs == 0 && *str == ':')
		str++;

	if (*str != ':')
		return nil;
	str++;

	// Terminates with a '::'?
	if (*str == ']')
		goto done;

	for (;;)
	{
		if ((x = _hexDigit(str)) == 0)
		{
			if ((x = _ipv6end(str)) == 0)
				return nil;
			goto done;
		}
		rhs++;
		if (*(str + x) != ':')
		{
			if (*(str + x) == ']')
			{
				str += x + 1;
				goto done;
			}
			else if ((x = _ipv6end(str)) == 0)
				return nil;
			if (*(str + x) == ']')
			{
				str += x + 1;
				goto done;
			}
		}
		str += x + 1;
	}

done:
	if (lhs + rhs + (hasTwoColon == true) > 8)
		return nil;
	if (str > *strp)
	{
#if 0
		NSString *ret = [[NSString alloc] initWithCharacters:(*strp + 1)
			length:((str - 2) - (*strp + 1))];
		NSHost *h = [NSHost hostWithUnresolvedAddress:ret];
#endif
		*strIP = [[NSString alloc] initWithCharacters:*strp
			length:(str - *strp)];
		*strp = str;
		return nil;
		//return h;
	}
	return nil;
}

static inline bool _hostPort(NSURL *self, NSUniChar **strp)
{
	NSHost *h = nil;
	NSString *hostName;

	if (!((hostName = _hostname(strp)) || (h = _ipv4Address(strp, &hostName)) ||
				(h = _ipv6Address(strp, &hostName))))
	{
		return false;
	}

	self->host = h;
	self->hostName = hostName;

	if (**strp == ':')
	{
		(*strp)++;
		_port(self, strp);
	}

	return true;
}

static inline bool _userInfo(NSUniChar **strp)
{
	bool hasInfo = false;
	NSUniChar *str = *strp;

	for (;; str++, hasInfo = true)
	{
		if (_unreserved(*str))
			continue;
		if (_escaped(str))
		{
			str += 2;
			continue;
		}
		switch (*str)
		{
			case ';':
			case ':':
			case '&':
			case '=':
			case '+':
			case '$':
			case ',':
				continue;
		}
		break;
	}
	if (hasInfo)
		*strp = str;

	return hasInfo;
}

static inline bool _server(NSURL *self, NSUniChar **strp)
{
	NSUniChar *str = *strp;

	if (_userInfo(strp) && **strp == '@')
	{
		self->userInfo =
			[[NSString alloc] initWithCharacters:str length:(*strp - str)];
		(*strp)++;
	}
	else
		*strp = str;

	return _hostPort(self, strp);
}

static inline bool parseAuthority(NSURL *self, NSUniChar **strp)
{
	return (_server(self, strp) || _regName(self, strp));
}

static inline bool _pchar(NSUniChar *ch)
{
	if (_unreserved(*ch) || _escaped(ch))
		return true;
	switch (*ch)
	{
		case ':':
		case '@':
		case '&':
		case '=':
		case '+':
		case '$':
		case ',':
			return true;
	}
	return false;
}

static inline void _segment(NSUniChar **strp)
{
	NSUniChar *str = *strp;

	while (_pchar(str) || *str == ';')
	{
		if (_escaped(str))
			str += 2;
		str++;
	}
	*strp = str;
}

static inline NSURL *hostPath(NSURL *self, NSUniChar **strp)
{
	NSUniChar *start = *strp;
	if (**strp != '/')
	{
		return nil;
	}

	(*strp)++;

	for (;;)
	{
		_segment(strp);
		if (**strp != '/')
			break;
		(*strp)++;
	}
	self->path =
		[[NSString alloc] initWithCharacters:start length:(*strp - start)];
	return self;
}

static inline NSURL *netPath(NSURL *self, NSUniChar **strp)
{
	NSUniChar *str = *strp;
	if (*(str) != '/' && *(str + 1) != '/')
	{
		return nil;
	}
	str += 2;
	if (*str != '/')
	{
		if (!parseAuthority(self, &str) && ![self isFileURL])
			return nil;
	}

	*strp = str;
	if (*strp == 0)
		return self;

	return hostPath(self, strp);
}

static inline NSURL *relPath(NSURL *self, NSUniChar **strp)
{
	NSUniChar *str = *strp;

	for (;;str++)
	{
		if (_unreserved(*str))
			continue;
		if (_escaped(str))
		{
			str += 2;
			continue;
		}
		switch (*str)
		{
			case ';':
			case '@':
			case '&':
			case '=':
			case '+':
			case '$':
			case ',':
				continue;
		}
		break;
	}

	self = hostPath(self, &str);
	if (self != nil)
	{
		self->path =
			[[NSString alloc] initWithCharacters:*strp length:(str - *strp)];
	}
	return self;
}

static inline NSURL *relativeURL(NSURL *self, NSUniChar *str)
{
	if ((self = netPath(self, &str)) == nil)
	{
		if ((self = hostPath(self, &str)) == nil)
		{
			if ((self = relPath(self, &str)) == nil)
			{
				return nil;
			}
		}
	}

	self->query = _fragmentQuery(&str, '?');
	return self;
}

static inline bool _opaquePart(NSURL *self, NSUniChar *str)
{
	NSUniChar *start = str;
	if (uric(str) && *str != '/')
	{
		while (uric(str))
		{
			if (_escaped(str))
				str += 2;
			str++;
		}
	}
	if (*str != 0)
		return false;

	self->path =
		[[NSString alloc] initWithCharacters:start length:(str - start)];
	return true;
}

static inline bool _hierPart(NSURL *self, NSUniChar *str)
{
	NSUniChar *strBack = str;
	if (!netPath(self, &str))
	{
		str = strBack;
		if (!hostPath(self, &str))
			return false;
	}
	self->query = _fragmentQuery(&str, '?');
	self->fragment = _fragmentQuery(&str, '#');

	if (*str != 0)
		return false;
	return true;
}

+ (id) URLWithString:(NSString *)string
{
	return [[self alloc] initWithString:string];
}

+ (id) fileURLWithPath:(NSString *)path
{
	return [[self alloc] initFileURLWithPath:path];
}

+ (id) fileURLWithPathComponents:(NSArray *)components
{
	return [self fileURLWithPath:[NSString pathWithComponents:components]];
}

+ (id) fileURLWithPath:(NSString *)path isDirectory:(bool)isDir
{
	return [[self alloc] initFileURLWithPath:path isDirectory:isDir];
}

+ (id) URLWithString:(NSString *)string relativeToURL:(NSURL *)baseURL
{
	return [[self alloc] initWithString:string relativeToURL:baseURL];
}

- (id) initWithString:(NSString *)string
{
	return [self initWithString:string relativeToURL:nil];
}

- (id) initWithString:(NSString *)string relativeToURL:(NSURL *)base
{
	// we can mess with this pointer, it's autoreleased
	NSUniChar *str;
	NSUniChar *strBack;
	NSIndex len = [string length] + 1;
	NSRange range = NSMakeRange(0, len - 1);

	str = malloc(len * sizeof(NSUniChar));
	if (str == NULL)
	{
		return nil;
	}
	[string getCharacters:str range:range];
	str[len - 1] = 0;
	strBack = str;

	scheme = makeScheme(&str);

	if (*(str++) != ':')
	{
		self = relativeURL(self, strBack);
	}
	else
	{
		if (!_hierPart(self, str))
		{
			if (!_opaquePart(self, str))
			{
				self = nil;
			}
			else
			{
				self->type = NSURLOpaqueType;
			}
		}
		else
			self->type = NSURLNetType;
	}
	if (self != nil && scheme != nil)
	{
		baseURL = base;
		srcString = [string copy];
	}

	free(strBack);
	return self;
}

- (id) initWithScheme:(NSString *)s host:(NSString *)h path:(NSString *)p
{
	scheme = [s copy];
	hostName = [h copy];
	path = [p copy];
	return self;
}

- (id) initFileURLWithPath:(NSString *)fPath
{
	return [self initWithScheme:@"file" host:nil path:fPath];
}

- (id) initFileURLWithPath:(NSString *)path isDirectory:(bool)isDir
{
	TODO; // -[NSURL initFileURLWithPath:isDirectory:];
	return nil;
}

- (id) copyWithZone:(NSZone *)zone
{
	return self;
}

- (NSString *) absoluteString
{
	TODO; // -[NSURL absoluteString]
	return nil;
}

- (NSURL *) absoluteURL
{
	TODO; // -[NSURL absoluteURL]
	return nil;
}

- (NSURL *) baseURL
{
	return baseURL;
}

- (NSString *) relativeString
{
	// If this URL was built by -[initWithScheme:host:path:] build the result
	// manually.
	if (srcString == nil)
		srcString = [self description];
	return srcString;
}

- (NSString *) relativePath
{
	TODO; // -[NSURL relativePath]
	return nil;
}

- (NSURL *) standardizedURL
{
	TODO; // -[NSURL standardizedURL]
	return nil;
}

- (NSString *) resourceSpecifier
{
	TODO; // -[NSURL resourceSpecifier]
	return nil;
}

- (NSString *)scheme
{
	return scheme;
}

- (NSString *)path
{
	return path;
}

- (NSString *) parameterString
{
	TODO; // -[NSURL parameterString]
	return nil;
}

- (NSString *) user
{
	TODO; // -[NSURL user]
	return nil;
}

- (NSString *) password
{
	TODO; // -[NSURL password]
	return nil;
}

- (NSHost *) host
{
	return host;
}

- (NSString *) hostname
{
	return hostName;
}

- (NSNumber *) port
{
	return port;
}

- (NSString *) fragment
{
	return fragment;
}

- (NSString *) query
{
	return query;
}

- (NSString *)description
{
	NSMutableString *str = [NSMutableString string];

	if (scheme)
	{
		[str appendFormat:@"%@:",scheme];
		if (hostName)
			[str appendString:@"//"];
	}
	if (hostName)
	{
		if (userInfo)
			[str appendString:userInfo];
		[str appendString:hostName];
		if (port)
		{
			[str appendFormat:@":%d",port];
		}
	}
	if (path)
		[str appendString:path];
	if (query)
	{
		[str appendFormat:@"?%@", query];
	}
	if (fragment)
	{
		[str appendFormat:@"#%@", fragment];
	}
	return str;
}

- (NSURL *) URLByResolvingSymlinksInPath
{
	if ([self isFileURL])
	{
		return [self _URLWithNewPath:[[self path] stringByResolvingSymlinksInPath]];
	}
	return self;
}

- (NSURL *) URLByStandardizingPath
{
	if ([self isFileURL])
	{
		return [self _URLWithNewPath:[[self path] stringByStandardizingPath]];
	}
	return self;
}

- (bool) isFileURL
{
	return [[self scheme] isEqual:@"file"];
}

- (NSURL *) URLByDeletingPathExtension
{
	return [self _URLWithNewPath:[[self path] stringByDeletingPathExtension]];
}

- (NSURL *) URLByDeletingLastPathComponent
{
	return [self _URLWithNewPath:[[self path] stringByDeletingLastPathComponent]];
}

- (NSURL *) URLByAppendingPathExtension:(NSString *)ext
{
	return [self _URLWithNewPath:[[self path] stringByAppendingPathExtension:ext]];
}

- (NSURL *) URLByAppendingPathComponent:(NSString *)comp
{
	return [self _URLWithNewPath:[[self path] stringByAppendingPathComponent:comp]];
}

- (NSURL *) URLByAppendingPathComponent:(NSString *)component isDirectory:(bool)isDir
{
	TODO; // -[NSURL URLByAppendingPathComponent:isDirectory:]
	return nil;
}

- (NSArray *) pathComponents
{
	return [[self path] pathComponents];
}

- (NSString *) pathExtension
{
	return [[self path] pathExtension];
}

- (NSString *) lastPathComponent
{
	return [[self path] lastPathComponent];
}

- (bool) checkResourceIsReachableAndReturnError:(NSError **)error
{
	TODO; // checkResourceIsReachableAndReturnError:
	return false;
}

- (bool) getResourceValue:(id *)val forKey:(NSString *)key error:(NSError **)error
{
	TODO; // getResourceValue:forKey:error:
	return false;
}

- (NSDictionary *)resourceValuesForKeys:(NSArray *)keys error:(NSError **)error
{
	TODO; // resourceValuesForKeys:error:
	return nil;
}

- (bool)setResourceValue:(id)value forKey:(NSString *)key error:(NSError **)error
{
	TODO; // setResourceValue:forKey:error:
	return false;
}

- (bool)setResourceValues:(NSDictionary *)keyedValues error:(NSError **)error
{
	TODO; // setResourceValues:error:
	return false;
}

- (bool) isEqual:(id)other
{
	if (![other isKindOfClass:[NSURL class]])
	{
		return false;
	}
	return [[self absoluteString] isEqualToString:[other absoluteString]];
}

- (NSURL *) _URLWithNewPath:(NSString *)newPath
{
	NSURL *newURL = [[NSURL alloc] initWithScheme:scheme host:hostName path:newPath];
	newURL->fragment = fragment;
	newURL->query = query;
	newURL->port = port;
	newURL->userInfo = userInfo;
	return newURL;
}

- (id) initWithCoder:(NSCoder *)coder
{
	NSURL *base;
	NSString *relString;

	if ([coder allowsKeyedCoding])
	{
		base = [coder decodeObjectForKey:@"base"];
		relString = [coder decodeObjectForKey:@"relative"];
	}
	else
	{
		base = [coder decodeObject];
		relString = [coder decodeObject];
	}
	if (relString == nil)
		relString = @"";

	return [self initWithString:relString relativeToURL:base];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	if ([coder allowsKeyedCoding])
	{
		[coder encodeObject:baseURL forKey:@"base"];
		[coder encodeObject:srcString forKey:@"relative"];
	}
	else
	{
		[coder encodeObject:baseURL];
		[coder encodeObject:srcString];
	}
}

@end

@implementation NSString(IDNA)

static NSString * _convertIDNA(NSString *source, int32_t (*converter)(const UChar
			*src, int32_t srcLength, UChar *dest, int32_t destCapacity, int32_t
			options, UParseError *parseError, UErrorCode *status))
{
	size_t len = [source length];
	NSUniChar *ch = malloc(len * sizeof(NSUniChar));
	NSUniChar *ret = malloc(len * sizeof(NSUniChar));
	NSString *retStr = nil;
	int32_t error = 0;
	NSRange range = NSMakeRange(0, len);
	
	[source getCharacters:ch range:range];
	converter(ch, len, ret, len, UIDNA_DEFAULT, NULL, &error);
	if (error == 0)
		retStr = [NSString stringWithCharacters:ret length:len];
	free(ret);
	free(ch);
	return retStr;
}

- (NSString *) ASCIIString
{
	return _convertIDNA(self, uidna_IDNToASCII);
}

- (NSString *) punycodeString
{
	return _convertIDNA(self, uidna_IDNToUnicode);
}

@end

