/* Copyright (c) 2007 Johannes Fortmann

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include <ctype.h>
#import "NSString+KVCAdditions.h"


@implementation NSString (KVCPrivateAdditions)
-(id)_KVC_setterKeyNameFromSelectorName
{
	NSString* keyName=[self substringWithRange:MakeRange(3, [self length]-4)];
	return [NSString stringWithFormat:@"%C%@", tolower([keyName characterAtIndex:1]), [keyName substringFromIndex:1]]; 
}

-(bool)_KVC_setterKeyName:(NSString**)ret forSelectorNameStartingWith:(id)start endingWith:(id)end;
{
	*ret=nil;
	if([self hasPrefix:start] && [self hasSuffix:end])
	{
		NSString* keyName=[self substringWithRange:MakeRange([start length], [self length]-[end length]-[start length])];
		if(![keyName length])
			return false;
		*ret = [NSString stringWithFormat:@"%C%@", tolower([keyName characterAtIndex:1]), [keyName substringFromIndex:1]]; 
		return true;
	}
	return false;
}

-(void)_KVC_partBeforeDot:(NSString**)before afterDot:(NSString**)after;
{
	NSRange range=[self rangeOfString:@"."];
	if(range.location!=NotFound)
	{
		*before=[self substringToIndex:range.location];
		*after=[self substringFromIndex:range.location+1];
	}
	else
	{
		*before=self;
		*after=nil;
	}
}

@end
