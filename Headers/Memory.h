/*
 * Copyright (c) 2004,2005	Justin Hibbits
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

/*
 @file Memory.h
 @author Justin Hibbits
 */
#ifndef __MEMORY_H
#define __MEMORY_H

#include <Foundation/primitives.h>
__BEGIN_DECLS

/*
 malloc zone structure, defines all about the malloc zones.
 */
/*!
 @class Zone
 @brief Opaque structure for an allocation zone.
 */
typedef struct NSZone NSZone;


/* Zone creation... */
/*!
 @brief Creates a new zone for allocations.
 @param start Starting size of the zone.
 @param allowFree Allow freeing in this zone.
 @param shared This zone can be shared with other programs.
 @result Pointer to the newly allocated zone, or NULL (0) on error.
 This creates and returns a new zone object.  If NULL is
 returned, memory is exhausted, or another system error occured.
 */
NSZone *NSZoneCreate(size_t start, bool allowFree, bool shared);

/*!
 @brief Destroys a zone.
 @param z Zone to destroy.
 @param addDefZone Append released memory pages to the default zone.
 This function destroys the given zone, optionally giving all its
 memory pages to the default zone, or returning them to the memory pool.
 */
void NSZoneDestroy(NSZone *z, bool addDefZone);

/*!
 @brief Allocates a block of memory in the given zone.
 @param zone Allocation zone to use.
 @param bytes NSNumber of bytes to allocate.
 @result Pointer to the newly allocated memory (uninitialized), or NULL on error.
 This function allocates a specified block of memory in the given
 zone.  It returns a pointer on success, NULL if unable to allocate the
 requested block size.
 */
void *NSZoneAlloc(NSZone *zone, size_t bytes);

/*!
 @brief Allocates a block of memory in the given zone.
 @param zone Allocation zone to use.
 @param numElems NSNumber of elements to allocate.
 @param size Size of each element.
 @result Pointer to the newly allocated memory (uninitialized), or NULL on error.
 This function allocates a specified number of elements of a
 given size in the given
 zone.  It returns a pointer on success, NULL if unable to allocate the
 requested block size.
 */
void *NSZoneCalloc(NSZone *zone, size_t numElems, size_t size);

/*!
 @brief Frees a pointer in a zone.
 @param zone Zone containing the pointer.
 @param addr Pointer to the memory block to free.
 If the address is invalid, behavior is undefined.  Reasoning
 being that it should be fast.  If you want to prevent this behavior, use
 Objects and reference counting (inherent to all objects in the System
 framework).
 */
void NSZoneFree(NSZone *zone, void *addr);

/*!
 @brief Returns the default allocation zone for the program.
 */
NSZone *NSDefaultAllocZone(void);

/*!
 @brief Resizes a pointer, moving it if necessary.
 @param zone Zone containing the pointer to resize.
 @param addr Address block to resize.
 @param newsize New size of the address block.
 @result Pointer to the new block, or NULL if no such block is available.
 If this function moves the block, it will copy the data.
 */
void *NSZoneRealloc(NSZone *zone, void *addr, size_t newsize);

/*!
 @param pointer Pointer to find the containing zone for.
 @result Pointer to the zone containing the given pointer.
 */
NSZone *NSZoneOf(const void *pointer);

/*
 @brief Get a number of contiguous pages, blocking if necessary.
 */
void *NSMemGetPages(size_t numPages, bool block, void (*callback)());

/*
 @brief Return a number of pages to the operating system.
 */
void NSMemReleasePages(void *, size_t);

#ifdef DEBUG
#define NSZoneFree(zone, foo) \
	do { \
		NSZoneFree(zone, foo); \
		foo = 0; \
	} while (0)
#endif

__END_DECLS

#endif /* __MEMORY_H */
