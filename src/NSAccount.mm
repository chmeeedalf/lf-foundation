/* 
   NSAccount.m

   Copyright (C) 1995, 1996 Ovidiu Predescu and Mircea Oancea.
   All rights reserved.

   Author: Mircea Oancea <mircea@jupiter.elcom.pub.ro>

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

#include <sys/types.h>

#include <grp.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <vector>

#include <Foundation/NSAccount.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSString.h>
#include <Foundation/NSLock.h>

extern NSRecursiveLock *libFoundationLock;

@implementation NSAccount

// Creating an account

+ (id) currentAccount 
{
	[self subclassResponsibility:_cmd];
	return nil; 
}

+ (id) accountWithName:(NSString*)name
{
	[self subclassResponsibility:_cmd];
	return nil; 
}

+ (id) accountWithNumber:(unsigned int)number
{
	[self subclassResponsibility:_cmd];
	return nil; 
}

// Getting account information

- (NSString*)accountName
{
	[self subclassResponsibility:_cmd];
	return nil; 
}

- (unsigned)accountNumber
{
	[self subclassResponsibility:_cmd];
	return 0; 
}

// Copying Protocol

- (id)copy
{
	return self;
}

- (id)copyWithZone:(NSZone*)zone
{
	return self;
}

@end /* NSAccount */

/*
 *  User Account
 */

@implementation NSUserAccount
{
	NSString     *name;
	unsigned int userNumber;
	NSString     *fullName;
	NSString     *homeDirectory;
}

// Init & dealloc

- (id)initWithPasswordStructure:(struct passwd*)ptr
{
	if (ptr == NULL) {
		fprintf(stderr, "%s: missing password structure ..\n",
				__PRETTY_FUNCTION__);
		self;
		return nil;
	}

	self->name = [NSString stringWithUTF8String:ptr->pw_name];
	self->fullName = [NSString stringWithUTF8String:ptr->pw_gecos];
	self->homeDirectory = [NSString stringWithUTF8String:ptr->pw_dir];

	self->userNumber = ptr->pw_uid;

	return self;
}

// Creating an account

static NSUserAccount* currentUserAccount = nil;

+ (void)initialize
{
	static BOOL initialized = NO;

	if (!initialized)
	{
		[libFoundationLock lock];

		/* Initialize the group account global variable */
		[NSGroupAccount initialize];

		{
			struct passwd *ptr = getpwuid(getuid());

			if (ptr)
				currentUserAccount = [[self alloc] initWithPasswordStructure:ptr];
			else
			{
				fprintf(stderr,
						"WARNING: libFoundation couldn't get passwd structure for "
						"current user (id=%i) !\n", getuid());
				currentUserAccount = nil;
			}
		}
		[libFoundationLock unlock];
		initialized = YES;
	}
}

+ (id)currentAccount 
{
	return currentUserAccount;
}

+ (id)accountWithName:(NSString *)aName
{
	struct passwd *ptr;

	[libFoundationLock lock];
	ptr = getpwnam((char*)[aName UTF8String]);
	[libFoundationLock unlock];
	return ptr ? [[self alloc] initWithPasswordStructure:ptr] : nil;
}

+ (id) accountWithNumber:(unsigned int)number
{
	struct passwd* ptr;

	[libFoundationLock lock];
	ptr = getpwuid(number);
	[libFoundationLock unlock];

	return ptr ? [[self alloc] initWithPasswordStructure:ptr] : nil;
}

// accessors

- (NSString *)accountName
{
	return self->name;
}
- (unsigned)accountNumber
{
	return self->userNumber;
}
- (NSString *)fullName
{
	return self->fullName;
}
- (NSString *)homeDirectory
{
	return self->homeDirectory;
}

@end /* NSUserAccount */

/*
 *  Group Account
 */

@implementation NSGroupAccount
{
	NSString     *name;
	unsigned int groupNumber;
	NSArray      *members;
}

// Init & dealloc

- (id)initWithGroupStructure:(struct group*)ptr
{
	int cnt;

	if ((self = [super init]) == nil)
	{
		return nil;
	}
	name = [NSString stringWithUTF8String:ptr->gr_name];
	groupNumber = ptr->gr_gid;

	// count group members
	for (cnt = 0; ptr->gr_mem[cnt]; cnt++)
		;

	{
		int i;

		std::vector<NSString *> array(cnt);
		for (i = 0; i < cnt; i++)
			array[i] = [NSString stringWithUTF8String:ptr->gr_mem[i]];
		members = [[NSArray alloc] initWithObjects:&array[0] count:cnt];
	}

	return self;
}

// Creating an account

static NSGroupAccount* currentGroupAccount = nil;

+ (void)initialize
{
	static BOOL initialized = NO;

	if (!initialized) {
		[libFoundationLock lock];
		currentGroupAccount = [self accountWithNumber:getgid()];
		[libFoundationLock unlock];
		initialized = YES;
	}
}

+ (id)currentAccount 
{
	return currentGroupAccount;
}

+ (id)accountWithName:(NSString*)aName
{
	struct group* ptr;

	[libFoundationLock lock];
	ptr = getgrnam([aName UTF8String]);
	[libFoundationLock unlock];

	return ptr ? [[self alloc] initWithGroupStructure:ptr] : nil;
}

+ (id)accountWithNumber:(unsigned int)number
{
	struct group* ptr;

	[libFoundationLock lock];
	ptr = getgrgid(number);
	[libFoundationLock unlock];

	return ptr ? [[self alloc] initWithGroupStructure:ptr] : nil;
}

- (NSString*)accountName
{
	return self->name;
}
- (unsigned)accountNumber
{
	return self->groupNumber;
}
- (NSArray*)members
{
	return self->members;
}

@end /* NSGroupAccount */
/*
   Local Variables:
	c-basic-offset: 4
		 tab-width: 8
			   End:
			   */

