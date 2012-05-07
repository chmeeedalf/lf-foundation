/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


#import <Foundation/NSString.h>

@interface NSString(String_pathUtilities)

+(NSString *)pathWithComponents:(NSArray *)components;
-(NSArray *)pathComponents;

-(NSString *)lastPathComponent;

-(NSString *)pathExtension;

-(NSString *)stringByAppendingPathComponent:(NSString *)string;
-(NSString *)stringByAppendingPathExtension:(NSString *)string;
-(NSArray *)stringsByAppendingPaths:(NSArray *)paths;

-(NSString *)stringByDeletingLastPathComponent;
-(NSString *)stringByDeletingPathExtension;

-(NSString *)stringByExpandingTildeInPath;
-(NSString *)stringByAbbreviatingWithTildeInPath;

-(NSString *)stringByStandardizingPath;
-(NSString *)stringByResolvingSymlinksInPath;

-(bool)isAbsolutePath;

-(const char *)fileSystemRepresentation;
-(const uint16_t *)fileSystemRepresentationW;
-(bool)getFileSystemRepresentation:(char *)bytes maxLength:(size_t)maxLength;

-(unsigned long)completePathIntoString:(NSString **)string caseSensitive:(bool)caseSensitive matchesIntoArray:(NSArray **)array filterTypes:(NSArray *)types;

@end

enum {
   NSLibraryDirectory=5,
};

typedef unsigned long NSSearchPathDirectory;

enum {
   NSUserDomainMask   = 0x0001,
   NSLocalDomainMask  = 0x0002,
   NSNetworkDomainMask= 0x0004,
   NSSystemDomainMask = 0x0008,
   NSAllDomainsMask   = 0xffff,
};

typedef unsigned long NSSearchPathDomainMask;

SYSTEM_EXPORT NSArray  *NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory d,NSSearchPathDomainMask mask,bool expand);

SYSTEM_EXPORT NSString *NSHomeDirectory(void);
SYSTEM_EXPORT NSString *NSHomeDirectoryForUser(NSString *user);

SYSTEM_EXPORT NSString *NSTemporaryDirectory(void);

SYSTEM_EXPORT NSString *NSUserName(void);
SYSTEM_EXPORT NSString *NSFullUserName(void);
