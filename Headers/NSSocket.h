/*
 * Copyright (c) 2008-2012	Justin Hibbits
 * All rights reserved.
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
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

/*!
 * \file NSSocket.h
 */
#import <Foundation/NSObject.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSRunLoop.h>
//#import <Event.h>

/* Gold only supports the IP family, not UNIX domain sockets, even though for
 * now it's based on FreeBSD.
 */
/*!
 *  \brief Berkeley socket address family identifier.
 *
 *  \details Address family identifiers are standardized from the Berkeley
 *  socket API, and define the address type of a socket.  Only the Internet
 *  Protocol address family is currently supported, as either IPv4 or IPv6.
 */
typedef enum NSAddressFamily
{
	NSUnspecifiedAddressFamily, /*!< Unknown address family */
	NSInternetAddressFamily = 2, /*!< IPv4 address type */
	NSInternet6AddressFamily = 28, /*!< IPv6 address type */
} NSAddressFamily;

/*!
 *  \brief Berkeley socket protocol family identifier.
 *
 *  \details Protocol family identifiers are standardized from the Berkeley
 *  socket API, and define the protocol type of a socket.  Only the Internet
 *  Protocol protocol family is currently supported, as either IPv4 or IPv6.
 */
typedef enum NSProtocolFamily
{
	NSUnspecifiedProtocolFamily,
	NSInternetProtocolFamily = 2,
	NSInternet6ProtocolFamily = 28,
} NSProtocolFamily;

/*!
 *  \brief The type of socket to create.
 *
 *  \details  There is more than one type of socket that can be created.  The
 *  most common types are datagram and stream.
 */
typedef enum NSSocketType
{
    NSStreamSocketType = 1,               /*!< Stream type, like TCP. */
    NSDatagramSocketType,                 /*!< Datagram type, like UDP. */
    NSRawSocketType,                      /*!< Raw socket, used for constructing packets manually. */
    NSSequencedPacketSocketType = 5,      /*!< Sequenced packet type. */
} NSSocketType;

@class NSHost;
@class _NSSocketPrivate;
@class NSSocket;

/*!
 *  \class NSNetworkAddress
 *  \brief Abstract class for a network address.
 *
 *  \details Subclasses of NSNetworkAddress are used to hold an address when
 *  creating a NSSocket instance.  The NSNetworkAddress class is never instantiated
 *  on its own, only subclasses are instantiated.
 */
@interface NSNetworkAddress	:	NSObject

/*! 
 *  \brief  Returns the protocol family for this socket.
 *  \return The protocol family related to this address type.
 *
 *  \details This is primarily for internal use.
 *  \sa #ProtocolFamily
 */
- (enum NSProtocolFamily) protocolFamily;
@end

/*!
 *  \class InetAddress
 *  \brief Internet address.
 *
 *  \details Subclasses of InetAddress are the standardized IP address types
 *  (IPv4 and IPv6).
 */
@interface NSInetAddress	:	NSNetworkAddress
{
}
/*!
 * \brief Create an InetAddress subclass from the string.
 * \details This will return whichever subclass (IPv4 or IPv6) is necessary to
 * parse the given string.  Calls -initWithString:.
 */
+ (id) inetAddressWithString:(NSString *)addr;

/*!
 * \brief Create an InetAddress subclass from the string.
 * \details This will return whichever subclass (IPv4 or IPv6) is necessary to
 * parse the given string.
 */
- (id) initWithString:(NSString *)addr;
@end

/*!
 * \brief IPv4 Address class.
 * \details This class is for IPv4 addresses, and can parse and generate any
 * IPv4 address string.
 */
@interface NSInet4Address :	NSInetAddress
{
	uint32_t addr; /*!< \brief Internal encoding of the address, in network-endian. */
}
/*!
 * \brief The "any" IPv4 address (0.0.0.0).
 */
+ (id) anyInet4Address;

/*!
 * \brief The "localhost" address, usually (127.0.0.1).
 */
+ (id) localhostInet4Address;

/*!
 * \brief Initialize the object with the given encoded address.
 * \param _addr NSInteger encoding of the IPv4 address.
 *
 * \details The address must be in network-endian byte order.
 */
- (id) initWithAddress:(uint8_t *)_addr;

/*!
 * \brief Initialize the object with the given string encoded IPv4 address.
 * \param _addr NSString encoding of the IPv4 address.
 *
 * \details This will fail if the address is not IPv4.
 */
- (id) initWithString:(NSString *)_addr;
@end

/*!
 * \brief IPv6 Address class.
 *
 * \details This class is for IPv6 addresses, and can parse and generate any
 * IPv6 address string.
 */
@interface NSInet6Address	:	NSInetAddress
{
	uint8_t	addr[16]; /*!< Internal byte-encoding of the address, in network-endian. */
}

/*!
 * \brief The "any" IPv6 address (::).
 */
+ (id) anyInet6Address;

/*!
 * \brief The "localhost" IPv6 address (::1).
 */
+ (id) localhostInet6Address;

/*!
 * \brief Initialize the object with the given encoded address.
 * \param addrBytes Byte encoding of the IPv6 address.
 *
 * \details The address must be in network-endian byte order.
 */
- (id) initWithAddress:(uint8_t *)addrBytes;

/*!
 * \brief Initialize the object with the given string encoded IPv6 address.
 * \param addrString NSString encoding of the IPv6 address.
 *
 * \details This will fail if the address is not IPv6.
 */
- (id) initWithString:(NSString *)addrString;
@end

/*!
 * \brief NSObject extensions for socket delegates.
 *
 * \details Any or all of these methods can be implemented.
 */
@protocol NSSocketDelegate<NSObject>
/*!
 * \brief Called when a socket received data.
 * \param socket NSSocket on which data was received.
 * \param dataBlock NSData received on the socket.
 */
- (void) socket:(NSSocket *)socket didReceiveData:(NSData *)dataBlock;
/* A new socket is created in this case, for the accepted connection. */

/*!
 * \brief Called to determine if a socket should be accepted from a given
 * address.
 * \param sock NSSocket which was being listened on.
 * \param newSock NSSocket created by the accept.
 * \returns \c true if the socket should be accepted, \c false otherwise.
 *
 * \details Internally, the socket has already been accepted, this is to
 * determine whether or not to keep it.  NSData can therefore be written on the
 * socket even if you return \c false, to return an error message to the remote
 * host.
 */
- (bool) socket:(NSSocket *)sock shouldAcceptConnection:(NSSocket *)newSock;

/*!
 * \brief Called when a socket is connected.
 * \param socket NSSocket on which the connect succeeded.
 *
 * \details Implement this to be notified when the socket has connected.
 */
- (void) socketDidConnect:(NSSocket *)socket;

@optional
- (void) socketHasDataAvailable:(NSSocket *)socket;
@end

/*!
 * \brief Base class for sockets.
 *
 * \details Normally you would want to instantiate one of the subclasses, like
 * TCPSocket or UDPSocket, instead of instantiating a NSSocket base class object.
 * Some cases do call for creating a NSSocket instance, such as ICMP, and other
 * low-level protocols.
 */
@interface NSSocket	:	NSStream <NSEventSource>
{
	_NSSocketPrivate *_private;	/*!< \brief Private socket data. */
	__weak id<NSSocketDelegate>	_delegate;
	bool isAsynchronous;
}

@property(weak) id<NSSocketDelegate> delegate;
@property bool isAsynchronous;

/*!
 * \brief Initialize the socket to connect to or listen on the given address,
 * with the given socket type and protocol.
 * \param addr Address to listen on or connect to.
 * \param type Type of socket to create (raw, datagram, stream, etc).
 * \param protocol Protocol to create with.  Some address types support multiple
 * protocols.
 */
- (id) initWithAddress:(NSNetworkAddress*)addr socketType:(NSSocketType)type protocol:(int)protocol;

/*!
 * \brief Initialize the socket to connect to a host with a set protocol and
 * type.
 * \param host Host to connect to.
 * \param family Address family to connect on.  This affects the type of address
 * retrieved from the host object.
 * \param type Type of socket to create (raw, datagram, stream, etc).
 * \param protocol Protocol to create with.  Some address types support multiple
 * protocols.
 */
- (id) initRemoteWithHost:(NSHost *)host family:(NSAddressFamily)family type:(NSSocketType)type protocol:(int)protocol;

/*!
 * \brief Create a NSSocket using a connected BSD socket.
 */
- (id) initWithConnectedSocket:(int)sockfd;

/*!
 * \brief Send raw data over this socket.
 * \param data NSData to send.
 *
 * \details NSData is sent asynchronously, so may not be completed when this
 * method returns.
 */
- (void) sendData:(NSData *)data;

/*!
 * \brief Listen for incoming connections on this socket.
 *
 * \details Asynchronous method.  Accepts and connects will be done in the
 * background, and the method will return immediately.
 */
- (void) listen;

/*!
 * \brief Returns the end point of this socket.
 */
- (NSHost *) remoteTarget;

/*!
 * \brief Asynchronously connect to the remote target.
 */
- (void) connect;

@end

/*!
 * \brief A TCP socket.
 */
@interface NSTCPSocket : NSSocket
{
}

/*!
 * \brief Initialize the socket with a specific address and TCP port.
 * \param addr Remote address of this socket.
 * \param port TCP port of this socket.
 */
- (id) initWithAddress:(NSNetworkAddress *)addr port:(int)port;

/*!
 * \brief Initialize the socket with a specific host and TCP port.
 * \param host Remote host of this socket.  Will use any address from the host.
 * \param port TCP port of this socket.
 */
- (id) initWithHost:(NSHost *)host port:(int)port;

/*!
 * \brief Initialize the socket to listen on any address and the given port.
 * \param port Port to listen on.
 */
- (id) initForListeningWithPort:(int)port;

/*!
 * \brief Change the port this socket is on.
 * \param port The new port
 *
 * \details The socket must not be connected or listening.
 */
- (void) setPort:(int) port;
@end

/*!
 * \brief A UDP socket.
 */
@interface NSUDPSocket : NSSocket
{
}

/*!
 * \brief Initialize the socket with a specific address and UDP port.
 * \param addr Remote address of this socket.
 * \param port UDP port of this socket.
 */
- (id) initWithAddress:(NSNetworkAddress *)addr port:(int)port;

/*!
 * \brief Initialize the socket with a specific host and UDP port.
 * \param host Remote host of this socket.  Will use any address from the host.
 * \param port UDP port of this socket.
 */
- (id) initWithHost:(NSHost *)host port:(int)port;

/*!
 * \brief Initialize the socket to listen on any address and the given port.
 * \param port Port to listen on.
 */
- (id) initForListeningWithPort:(int)port;

/*!
 * \brief Change the port this socket is on.
 * \param port The new port
 *
 * \details The socket must not be connected or listening.
 */
- (void) setPort:(int) port;
@end
