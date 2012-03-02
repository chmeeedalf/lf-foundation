/*
   Notification.m

   Copyright (C) 2005-2012 Gold Project
   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

   This file is part of the Gold System Framework, from libFoundation.
   This file is part of libFoundation.

   Permission to use, copy, modify, and distribute this software and its
   documentation for any purpose and without fee is hereby granted, provided
   that the above copyright notice appear in all copies and that both that
   copyright notice and this permission notice appear in supporting
   documentation.

   We disclaim all warranties with regard to this software, including all
   implied warranties of merchantability and fitness, in no event shall
   we be liable for any special, indirect or consequential damages or any
   damages whatsoever resulting from loss of use, data or profits, whether in
   an action of contract, negligence or other tortious action, arising out of
   or in connection with the use or performance of this software.
*/

#import <Foundation/NSNotification.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSCoder.h>

/*
 * Concrete notification
 */

@interface NSConcreteNotification : NSNotification
{
    NSString* name;
    id object;
    NSDictionary* userInfo;
}
- (id)initWithName:(NSString*)aName object:(id)anObject
  userInfo:(NSDictionary*)anUserInfo;
- (NSString *)name;
- (id) object;
- (NSDictionary *)userInfo;
@end

@implementation NSConcreteNotification

- (id)initWithName:(NSString*)aName object:(id)anObject
	userInfo:(NSDictionary*)anUserInfo
{
	NSZone* zone = [self zone];

	name = [aName copyWithZone:zone];
	userInfo = [anUserInfo copyWithZone:zone];
	object = anObject;
	return self;
}

- (NSString *)name { return name; }

- (id) object { return object; }

- (NSDictionary *)userInfo
{
	return userInfo;
}

// Copying

- (id) copyWithZone:(NSZone*)zone
{
	if (NSShouldRetainWithZone(self, zone))
	{
		return self;
	} else {
		return [[[self class] alloc]
			initWithName:name object:object userInfo:userInfo];
	}
}

@end

/*
 * Notification
 */

@implementation NSNotification

/* Methods */

+ (id) allocWithZone:(NSZone *)zone
{
	return NSAllocateObject( (self == [NSNotification class]) ?
			[NSConcreteNotification class] : (Class)self, 0, zone);
}

+ (NSNotification *)notificationWithName:(NSString *)name object:object
{
	return [[self alloc]
			initWithName:(NSString*)name
			object:object
			userInfo:nil];
}

+ (NSNotification *)notificationWithName:(NSString *)aName
  object:(id)anObject userInfo:(NSDictionary *)anUserInfo
{
	return [[self alloc]
			initWithName:(NSString*)aName
			object:anObject
			userInfo:anUserInfo];
}

- (id)initWithName:(NSString*)_name object:(id)_object
	userInfo:(NSDictionary*)anUserInfo
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (NSString *)name
{
	return [self subclassResponsibility:_cmd];
}

- (id) object
{
	return [self subclassResponsibility:_cmd];
}

- (NSDictionary *)userInfo
{
	return [self subclassResponsibility:_cmd];
}

/* Copying protocol */

- (id)copyWithZone:(NSZone*)zone
{
	[self subclassResponsibility:_cmd];
	return nil;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<Notification:\n  name = %@\n"
		@"  object = %@\n  userInfo = %@\n>",
		[self name],
		[self object],
		[self userInfo]];
}

- (id) initWithCoder:(NSCoder *)coder
{
	NSString *name;
	id object;
	NSDictionary *userInfo;

	name = [coder decodeObject];
	object = [coder decodeObject];
	userInfo = [coder decodeObject];

	self = [[NSNotification alloc] initWithName:name object:object userInfo:userInfo];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self name]];
	[coder encodeObject:[self object]];
	[coder encodeObject:[self userInfo]];
}

@end /* Notification */
/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
*/

