/* 
   NSPortNameServer.m

   Copyright (C) 1999 Helge Hess.
   All rights reserved.

   Author: Helge Hess <hh@mdlink.de>

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

#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSPortNameServer.h>

@implementation NSPortNameServer

+ (id) systemDefaultPortNameServer
{
	return [NSSocketPortNameServer sharedInstance];
}

/* port registry */

- (bool) registerPort:(NSPort *)aPort name:(NSString *)aPortName
{
    [self notImplemented:_cmd];
    return false;
}
- (void) removePortForName:(NSString *)aPortName
{
    [self notImplemented:_cmd];
}

/* port lookup */

- (NSPort *) portForName:(NSString *)aPortName host:(NSString *)aHostName
{
    return [self notImplemented:_cmd];
}

- (NSPort *) portForName:(NSString *)aPortName
{
    return [self portForName:aPortName host:nil];
}

- (NSPort *) registeredPortForName:(NSString *)aPortName
{
	return [self subclassResponsibility:_cmd];
}

@end /* NSPortNameServer */

/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
*/
