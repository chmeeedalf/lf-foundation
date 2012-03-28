/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSURLProtocol.h>
#import <Foundation/NSArray.h>
#import "NSURLProtocol_http.h"

@implementation NSURLProtocol

static NSMutableArray *_registeredClasses=nil;
static Class _selfClass;

+(void)initialize
{
	if(self==[NSURLProtocol class])
	{
		_selfClass = [self class];
		_registeredClasses=[NSMutableArray new];
		// [_registeredClasses addObject:[NSURLProtocol_http class]];
	}
}

+(NSArray *)_registeredClasses
{
	return _registeredClasses;
}

+(bool)registerClass:(Class)cls
{
	if (!class_isKindOfClass(cls, _selfClass))
		return false;
	[_registeredClasses addObject:cls];
	return true;
}

+(Class)_URLProtocolClassForRequest:(NSURLRequest *)request
{
	NSArray  *classes=[NSURLProtocol _registeredClasses];
	long count=[classes count];

	while(--count>=0)
	{
		Class check=[classes objectAtIndex:count];

		if([check canInitWithRequest:request])
			return check;
	}
	return nil;
}

+(void)unregisterClass:(Class)cls
{
	[_registeredClasses removeObjectIdenticalTo:cls];
}

+(id)propertyForKey:(NSString *)key inRequest:(NSURLRequest *)request
{
	[self notImplemented:_cmd];
	return 0;
}

+(void)removePropertyForKey:(NSString *)key inRequest:(NSMutableURLRequest *)request
{
	[self notImplemented:_cmd];
}

+(void)setProperty:value forKey:(NSString *)key inRequest:(NSMutableURLRequest *)request
{
	[self notImplemented:_cmd];
}

+(bool)canInitWithRequest:(NSURLRequest *)request
{
	[self subclassResponsibility:_cmd];
	return 0;
}

+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
	return [self subclassResponsibility:_cmd];
}

+(bool)requestIsCacheEquivalent:(NSURLRequest *)request toRequest:(NSURLRequest *)other
{
	[self notImplemented:_cmd];
	return 0;
}

-(id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)response client:(id <NSURLProtocolClient>)client
{
	return self;
}

-(NSURLRequest *)request
{
	[self notImplemented:_cmd];
	return 0;
}

-(NSCachedURLResponse *)cachedResponse
{
	return [self subclassResponsibility:_cmd];
}

-(id <NSURLProtocolClient>)client
{
	[self notImplemented:_cmd];
	return 0;
}

-(void)startLoading
{
	[self subclassResponsibility:_cmd];
}

-(void)stopLoading
{
	[self subclassResponsibility:_cmd];
}

@end
