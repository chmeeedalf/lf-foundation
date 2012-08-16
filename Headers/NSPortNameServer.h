/* 
   NSPortNameServer.h

   Copyright (C) 2012 Justin Hibbits.
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

#ifndef __NSPortNameServer_H__
#define __NSPortNameServer_H__

#import <Foundation/NSObject.h>

@class NSPort, NSString;

@interface NSPortNameServer : NSObject

+ (id) systemDefaultPortNameServer;

/* port registry */

- (bool) registerPort:(NSPort *)aPort name:(NSString *)aPortName;
- (void) removePortForName:(NSString *)aPortName;

/* port lookup */

- (NSPort *) portForName:(NSString *)aPortName host:(NSString *)aHostName;
- (NSPort *) portForName:(NSString *)aPortName;

/* Port creation */
- (NSPort *) registeredPortForName:(NSString *)aPortName;

@end

@interface NSSocketPortNameServer	:	NSPortNameServer
+ (id) sharedInstance;

- (NSPort *) portForName:(NSString *)portName;
- (NSPort *) portForName:(NSString *)portName host:(NSString *)hostName;
- (NSPort *) portForName:(NSString *)portName host:(NSString *)hostName nameServerPortNumber:(uint16_t)portNumber;

- (void) registerPort:(NSPort *)port name:(NSString *)name;
- (void) registerPort:(NSPort *)port name:(NSString *)name nameServerPortNumber:(uint16_t)portNumber;
- (void) removePortForName:(NSString *)name;

- (uint16_t) defaultNameServerPortNumber;
- (void) setDefaultNameServerPortNumber:(uint16_t)defaultNumber;

@end

#endif /* __NSPortNameServer_H__ */

/*
  Local Variables:
  c-basic-offset: 4
  tab-width: 8
  End:
*/
