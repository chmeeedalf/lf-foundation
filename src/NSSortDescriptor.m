/*-
 * Copyright (c) 2009	Gold Project
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

#import <Foundation/NSSortDescriptor.h>

#import <Foundation/NSKeyValueCoding.h>

@implementation NSSortDescriptor

+ sortDescriptorWithKey:(NSString *)key ascending:(bool)ascending selector:(SEL)selector
{
	return [[[self alloc] initWithKey:key ascending:ascending selector:selector] autorelease];
}

+ sortDescriptorWithKey:(NSString *)key ascending:(bool)ascending
{
	return [[[self alloc] initWithKey:key ascending:ascending] autorelease];
}

- initWithKey:(NSString *)key ascending:(bool)ascending
{
	return [self initWithKey:key ascending:ascending selector:@selector(compare:)];
}

- initWithKey:(NSString *)key ascending:(bool)ascending selector:(SEL)selector
{
	_key = [key copy];
	_ascending = ascending;
	_selector = selector;
	return self;
}

- (bool)ascending
{
	return _ascending;
}

- (NSString *)key
{
	return _key;
}

- (SEL)selector
{
	return _selector;
}

- (NSComparisonResult)compareObject:(id)object toObject:(id)other
{
	id first = [object valueForKeyPath:_key];
	id second = [other valueForKeyPath:_key];
	
	if (_ascending)
		return (NSComparisonResult)[first performSelector:_selector withObject:second];
	else
		return (NSComparisonResult)[second performSelector:_selector withObject:first];
}

- (id)reversedSortDescriptor
{
	return [[[[self class] alloc] initWithKey:_key ascending:(!_ascending) selector:_selector] autorelease];
}
@end
