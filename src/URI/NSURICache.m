/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSURICache.h>

@implementation NSURICache

+(NSURICache *)sharedURICache
{
	[self notImplemented:_cmd];
	return nil;
}

+(void)setSharedURICache:(NSURICache *)cache
{
	[self notImplemented:_cmd];
}

-initWithMemoryCapacity:(unsigned long)memoryCapacity diskCapacity:(unsigned long)diskCapacity diskPath:(NSString *)diskPath
{
	[self notImplemented:_cmd];
	return nil;
}

-(unsigned long)memoryCapacity
{
	return _memoryCapacity;
}

-(unsigned long)diskCapacity
{
	return _diskCapacity;
}

-(unsigned long)currentDiskUsage
{
	[self notImplemented:_cmd];
	return 0;
}

-(unsigned long)currentMemoryUsage
{
	[self notImplemented:_cmd];
	return 0;
}

-(NSCachedURIResponse *)cachedResponseForRequest:(NSURIRequest *)request
{
	[self notImplemented:_cmd];
	return nil;
}

-(void)setMemoryCapacity:(unsigned long)memoryCapacity
{
	[self notImplemented:_cmd];
}

-(void)setDiskCapacity:(unsigned long)diskCapacity
{
	[self notImplemented:_cmd];
}

-(void)storeCachedResponse:(NSCachedURIResponse *)response forRequest:(NSURIRequest *)request
{
	[self notImplemented:_cmd];
}

-(void)removeAllCachedResponses
{
	[self notImplemented:_cmd];
}

-(void)removeCachedResponseForRequest:(NSURIRequest *)request
{
	[self notImplemented:_cmd];
}

@end
