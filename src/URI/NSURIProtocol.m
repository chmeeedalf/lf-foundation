/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <Foundation/NSURIProtocol.h>
#import <Foundation/NSArray.h>
#import "NSURIProtocol_http.h"

@implementation NSURIProtocol

static NSMutableArray *_registeredClasses=nil;
static Class _selfClass;

+(void)initialize
{
	if(self==[NSURIProtocol class])
	{
		_selfClass = [self class];
		_registeredClasses=[NSMutableArray new];
		// [_registeredClasses addObject:[NSURIProtocol_http class]];
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

+(Class)_URIProtocolClassForRequest:(NSURIRequest *)request
{
	NSArray  *classes=[NSURIProtocol _registeredClasses];
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

+(id)propertyForKey:(NSString *)key inRequest:(NSURIRequest *)request
{
	[self notImplemented:_cmd];
	return 0;
}

+(void)removePropertyForKey:(NSString *)key inRequest:(NSMutableURIRequest *)request
{
	[self notImplemented:_cmd];
}

+(void)setProperty:value forKey:(NSString *)key inRequest:(NSMutableURIRequest *)request
{
	[self notImplemented:_cmd];
}

+(bool)canInitWithRequest:(NSURIRequest *)request
{
	[self subclassResponsibility:_cmd];
	return 0;
}

+(NSURIRequest *)canonicalRequestForRequest:(NSURIRequest *)request
{
	return [self subclassResponsibility:_cmd];
}

+(bool)requestIsCacheEquivalent:(NSURIRequest *)request toRequest:(NSURIRequest *)other
{
	[self notImplemented:_cmd];
	return 0;
}

-(id)initWithRequest:(NSURIRequest *)request cachedResponse:(NSCachedURIResponse *)response client:(id <NSURIProtocolClient>)client
{
	return self;
}

-(NSURIRequest *)request
{
	[self notImplemented:_cmd];
	return 0;
}

-(NSCachedURIResponse *)cachedResponse
{
	return [self subclassResponsibility:_cmd];
}

-(id <NSURIProtocolClient>)client
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
