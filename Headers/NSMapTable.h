/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSObjCRuntime.h>
#import <Foundation/Memory.h>
#import <Foundation/NSPointerFunctions.h>
#import <Foundation/NSEnumerator.h>

/*!
 * \file NSMapTable.h
 */
@class NSArray, NSDictionary, NSString, NSEnumerator;

typedef NSUInteger NSMapTableOptions;
enum {
	NSMapTableStrongMemory = 0,
	NSMapTableZeroingWeakMemory = NSPointerFunctionsZeroingWeakMemory,
	NSMapTableCopyIn = NSPointerFunctionsCopyIn,
	NSMapTableObjectPointerPersonality = NSPointerFunctionsObjectPointerPersonality,
};

@interface NSMapTable	:	NSObject<NSCoding,NSCopying,NSFastEnumeration>
{
}
+ mapTableWithKeyOptions:(NSPointerFunctionsOptions)keyOpts valueOptions:(NSPointerFunctionsOptions)valOpts;
+ mapTableWithStrongToStrongObjects;
+ mapTableWithWeakToStrongObjects;
+ mapTableWithStrongToWeakObjects;
+ mapTableWithWeakToWeakObjects;

- initWithKeyOptions:(NSPointerFunctionsOptions)keyOpts valueOptions:(NSPointerFunctionsOptions)valOpts capacity:(size_t)cap;
- initWithKeyPointerFunctions:(NSPointerFunctions *)keyFuncts valuePointerFunctions:(NSPointerFunctions *)valFuncts capacity:(size_t)cap;

- (id)objectForKey:(id)key;
- (const void *) pointerForKey:(const void *)key;
- (NSEnumerator *)keyEnumerator;
- (NSEnumerator *)objectEnumerator;
- (size_t)count;

- (void)setObject:(id)obj forKey:(id)key;
- (void)setPointer:(const void *)ptr forKey:(const void *)key;
- (void)removeObjectForKey:(id)key;
- (void)removeAllObjects;

- (NSDictionary *)dictionaryRepresentation;

- (NSPointerFunctions *)keyPointerFunctions;
- (NSPointerFunctions *)valuePointerFunctions;
@end
