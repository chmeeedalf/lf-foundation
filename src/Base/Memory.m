/*
 * Copyright (c) 2004,2005	Gold Project
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

// FIXME: Must make this thread-safe!
#include <pthread.h>
#import <Foundation/Memory.h>
#import <Foundation/NSObjCRuntime.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#ifdef __FreeBSD__
#include <sys/mman.h>
#endif


NSZone *NSDefaultAllocZone(void)
{
	return NULL;
}

NSZone *NSZoneOf(const void *ptr)
{
	return NULL;
}

#if 0
#define min_size	16U
/* callbacks.  Customize these, or use the predefined constants */
struct AllocCallbacks
{
	void *(*alloc)(struct NSZone *, size_t);
	void *(*calloc)(struct NSZone *, size_t, size_t);
	void *(*realloc)(struct NSZone *, void *, size_t);
	void (*free)(struct NSZone *, void *);
};

struct NSAllocZonePage
{
	void *start;
	size_t len;
	void *next_block;
	void *pad;
};

struct _page_list
{
	size_t num_pages;
	struct _page_list *next;
};

struct NSZone
{
	// 4 pointers, so just make the whole header 32 bytes (64 on 64-bit systems)
	struct AllocCallbacks callbacks;
	size_t num_extents;
	struct NSZone *next;
	union
	{
		struct
		{
			void *extra_info;
			size_t lock;
		} data;
		void *padding[2];
	} meta;
	struct NSAllocZonePage extents[];
};

struct freeable_page_frame
{
	struct freeable_page_frame *next;
	struct freeable_page_frame *prev;
	size_t num_blocks;
	size_t block_size;
	void *page;
	uint32_t blocks[];
};

struct _FreeableNSZoneData
{
	NSZone *zone;
	size_t num_sizes;
	struct freeable_page_frame *frames[];
};


static NSZone *_NSDefaultZone = NULL;
static struct _page_list *free_pages = NULL;
static pthread_mutex_t memMutex = PTHREAD_MUTEX_INITIALIZER;

static void _NSZoneAddPage(NSZone *z, void *start, size_t count);
static struct NSAllocZonePage *_NSZoneGetExtent(NSZone *z, size_t ind);

#define FREEABLE_DATA	((struct _FreeableNSZoneData *)zone->meta.data.extra_info)

// Internal alloc/free/realloc functions
static void zone_init(NSZone *zone)
{
	// hidden page for doing maintenance work
	void *pg = NSMemGetPages(1, true, NULL);
	unsigned int i = 0, j = 0;
	size_t pgsize = getpagesize();
	zone->meta.data.extra_info = pg;
	FREEABLE_DATA->zone = NSZoneCreate(1, false, false);
	for (i = 0; (1 << i) < pgsize; i++)
	{
		/* Finding the page size */
	}
	j = FREEABLE_DATA->num_sizes = i - 4;
	for (i = 0; i < j; i++)
	{
		FREEABLE_DATA->frames[i] = 0;
	}
	NSMemReleasePages(zone->extents[0].start, zone->extents[0].len);
	zone->num_extents--;
}

// Creates a new freeable page frame, given the size of data you want to chunk.
static struct freeable_page_frame *new_pgframe(NSZone *zone, size_t block_size)
{
	size_t pg_size = getpagesize();
	struct freeable_page_frame *pf;
	int i = 0;
	int j = 0;
	for (i = (block_size - 1)>> 4; i; i >>= 1, j++)
		/*empty, since we're doing everything in the iteration */;
	block_size = 1 << (j + 4);
	pf = NSZoneAlloc(zone,
			sizeof(struct freeable_page_frame) +
			sizeof(uint32_t) * (pg_size / (block_size * 32) + 1));
	pf->block_size = block_size;
	pf->num_blocks = pg_size / pf->block_size;

	if (pf == NULL)
		return NULL;
	pf->prev = NULL;
	pf->next = NULL;
	pf->page = NSMemGetPages(1, true, NULL);
	for (i = 0; i < pg_size / (pf->block_size * 32) +
			(pf->block_size > pg_size / 32);i++)
	{
		pf->blocks[i] = (uint32_t)-1;
	}
	return pf;
}

static void *zone_alloc(NSZone *zone, size_t block_size)
{
	void *block;
	size_t pg_size = getpagesize();
	size_t i, j, k;
	struct freeable_page_frame *pf;
	struct NSAllocZonePage *ext;
	if (zone->meta.data.extra_info == 0)
	{
		zone_init(zone);
	}
	if (block_size == 0)
	{
		return NULL;
	}
	if (block_size < min_size)
		block_size = min_size;

	if (block_size > (pg_size / 2))
	{
		size_t block_pages = (block_size - 1) / pg_size + 1;
		block = NSMemGetPages(block_pages, true, NULL);
		_NSZoneAddPage(zone, block, block_pages);
		return block;
	}
	else
	{
		block_size--;
		j = 0;
		for (i = block_size >> 4; i; i >>= 1, j++)
		{
			/* Getting block size, do nothing */
		}
		pf = FREEABLE_DATA->frames[j];
		if (pf == NULL)
		{
			pf = FREEABLE_DATA->frames[j] =
				new_pgframe(FREEABLE_DATA->zone, 1 << (j + 4));
			if (pf == NULL)
			{
				return NULL;
			}
			_NSZoneAddPage(zone, pf->page, 1);
			ext = _NSZoneGetExtent(zone, zone->num_extents - 1);
			ext->next_block = (void *)-1;
		}
		// got a valid page frame
		while (pf->num_blocks == 0 && pf->next != NULL)
		{
			pf = pf->next;
		}
		if (pf->num_blocks == 0 && pf->next == NULL)
		{
			pf->next = new_pgframe(FREEABLE_DATA->zone,
					1 << (j + 4));
			pf = pf->next;
			_NSZoneAddPage(zone, pf->page, 1);
			ext = _NSZoneGetExtent(zone, zone->num_extents - 1);
			ext->next_block = (void *)-1;

		}
		for (i = 0; i < (pg_size / (pf->block_size * 32) +
					(pf->block_size > (pg_size / 32))); i++)
		{
			if (pf->blocks[i] == 0)
			{
				continue;
			}
			j = (pg_size / pf->block_size) - (i * 32);
			if (j > 32)
			{
				j = 32;
			}
			k = j;
			for (; j > 0; j--)
			{
				if (pf->blocks[i] & (1 << (k - j)))
				{
					goto alloc_block;
				}
			}
		}
		abort();
		// now we know we have a valid block
alloc_block:
		pf->num_blocks--;
		pf->blocks[i] &= ~ (1 << (k - j));
		block = (char *)pf->page + (32 * i * pf->block_size) +
			(pf->block_size * (k - j));
		return block;
	}
}

static void *zone_calloc(NSZone *zone, size_t numElems, size_t size)
{
	void *p;
	size *= numElems;
	if ( (p = zone_alloc(zone, size)) )
	{
		memset(p, 0, size);
	}
	return p;
}

static struct NSAllocZonePage *zone_extent_ptr(NSZone *z, const void *ptr)
{
	int i = 0;
	struct NSAllocZonePage *ext;
	for (; i < z->num_extents; i++)
	{
		ext = _NSZoneGetExtent(z, i);
		if (ptr >= ext->start &&
				ptr < (void*)((char*)ext->start + ext->len * getpagesize()))
		{
			return ext;
		}
	}
	return NULL;
}

static struct freeable_page_frame *zone_get_frame(NSZone *zone, void *pointer)
{
	struct _FreeableNSZoneData *zone_data = zone->meta.data.extra_info;
	struct freeable_page_frame *pf;
	int i = 0;

	for (; i < zone_data->num_sizes; i++)
	{
		for (pf = zone_data->frames[i]; pf != NULL; pf = pf->next)
		{
			if ((size_t)pf->page <= (size_t)pointer &&
					(size_t)pf->page + getpagesize() > (size_t)pointer)
			{
				return pf;
			}
		}
	}
	return NULL;
}

// yes, we allow you to be an idiot with using free.
static void zone_free(NSZone *zone, void *block)
{
	struct NSAllocZonePage *ext;
	// eliminate the free(NULL) problem
	if (block == 0 || ((size_t)block % 4) != 0)
		return;
	// if we're the wrong zone, free from the right one
	ext = zone_extent_ptr(zone, block);
	if (ext == NULL)
	{
		// Prevent infinite recursion for this
		zone = NSZoneOf(block);
		if (zone != NULL)
			NSZoneFree(zone, block);
		return;
	}
	if ( (size_t)block % getpagesize() == 0 && ext->next_block == NULL )
	{
		// we use next_block to denote availability.  NULL means page is completely used by this.
		NSMemReleasePages(ext->start, ext->len);
		*ext = *_NSZoneGetExtent(zone, zone->num_extents - 1);
		zone->num_extents--;
		return;
	}
	else
	{
		struct freeable_page_frame *pf = zone_get_frame(zone, block);
		size_t index;
		// simple checks, don't want to crash&burn
		if (pf == NULL)
		{
			return;
		}

		/* Can't deallocate an unaligned block! */
		if (((intptr_t)block % pf->block_size) != 0)
			return;
		index = (size_t)((char *)block - (char *)pf->page) / pf->block_size;
		if (!(pf->blocks[index / 32] & (1 << index % 32)))
		{
			pf->num_blocks++;
			pf->blocks[index / 32] |= (1 << (index % 32));
		}
	}
}

static void *zone_realloc(NSZone *zone, void *block, size_t block_size)
{
	struct freeable_page_frame *pf;
	void *new_block;
	size_t i;
	if (block == NULL)
	{
		return zone_alloc(zone, block_size);
	}

	if (block_size == 0)
	{
		zone_free(zone, block);
		return NULL;
	}

	pf = zone_get_frame(zone, block);
	if (pf == NULL)
	{
		struct NSAllocZonePage *ext_ptr;
		/* If we have no page frame, maybe we're too large.  Let's find an
		 * extent instead. */
		ext_ptr = zone_extent_ptr(zone, block);
		if (ext_ptr == NULL)
			return NULL;
		if (ext_ptr->len >= block_size)
			return block;
	}
	else
	{
		if (block_size <= pf->block_size)
		{
			return block;
		}
	}

	new_block = zone_alloc(zone, block_size);

	for (i = 0; i < (block_size + 3)/ 4; i++)
	{
		((uint32_t*)new_block)[i] = ((uint32_t*)block)[i];
	}

	zone_free(zone, block);
	return new_block;
}

static void *fast_alloc(NSZone *zone, size_t block_size)
{
	void *block;
	// initialized only to shut the compiler up.
	struct NSAllocZonePage *ext = NULL;
	size_t pg_size = getpagesize();
	size_t i;
	if (block_size >= pg_size)
	{
		size_t block_pages = (block_size - 1) / pg_size + 1;
		block = NSMemGetPages(block_pages, true, NULL);
		_NSZoneAddPage(zone, block, block_pages);
		return block;
	}
	else
	{
		for (i = 0; i < zone->num_extents; i++)
		{
			ext = _NSZoneGetExtent(zone, i);
			if (ext->next_block == NULL)
			{
				continue;
			}
			if ((size_t)(pg_size * ext->len + (char*)ext->start) -
					(size_t)ext->next_block >= block_size)
			{
				break;
			}
		}
		if (i == zone->num_extents)
		{
			block = NSMemGetPages(1, true, NULL);
			_NSZoneAddPage(zone, block, 1);
			ext = _NSZoneGetExtent(zone, i);
			ext->next_block = block;
		}
		block = ext->next_block;
		ext->next_block = (char *)ext->next_block + 4 * ((block_size + 3)/ 4);
		return block;
	}
}

static void *fast_calloc(NSZone *zone, size_t numElems, size_t size)
{
	void *p;
	size *= numElems;

	if ( (p = fast_alloc(zone, size)))
	{
		memset(p, 0, size);
	}
	return p;
}

/* normal malloc functions apply (freeable, normal rules apply) */
static const struct AllocCallbacks AllocNormalCallbacks =
{
	zone_alloc,
	zone_calloc,
	zone_realloc,
	zone_free
};

static const struct AllocCallbacks AllocNoFreeCallbacks =
{
	fast_alloc,
	fast_calloc,
	NULL,
	NULL
};


// THE GUTS!!!!
static struct NSAllocZonePage *_NSZoneGetExtent(NSZone *z, size_t ind)
{
	size_t pg_size = getpagesize();
	size_t end_index = pg_size / sizeof(struct NSAllocZonePage);
	size_t end_m1 = end_index - 1;
	struct NSAllocZonePage *cur_extent_pg = (struct NSAllocZonePage *)z, *next_extent;
	if (ind >= end_m1)
	{
		ind -= end_m1 - 2;
		cur_extent_pg = cur_extent_pg[end_m1].start;
		while (ind > end_m1)
		{
			ind -= end_m1;
			if (cur_extent_pg[end_m1].len != 0)
			{
				next_extent = NSMemGetPages(1, true, NULL);
				if (next_extent == NULL)	// shouldn't be this way, but test anyway
				{
					return NULL;
				}
				next_extent[0] = cur_extent_pg[end_m1];
				cur_extent_pg[end_m1].len = 0;
				cur_extent_pg[end_m1].start = next_extent;
			}
			cur_extent_pg = cur_extent_pg[end_m1].start;
		}
	}
	else if (ind == end_m1 - 1)
	{
		if (cur_extent_pg[end_m1].len == 0)
		{
			cur_extent_pg = cur_extent_pg[end_m1].start;
		} else {
			next_extent = NSMemGetPages(1, true, NULL);
			if (next_extent == NULL)	// shouldn't be this way, but test anyway
			{
				return NULL;
			}
			next_extent[0] = cur_extent_pg[end_m1];
			cur_extent_pg[end_m1].start = next_extent;
			cur_extent_pg[end_m1].len = 0;
			cur_extent_pg = cur_extent_pg[end_m1].start;
		}
	}
	else
	{
		return &z->extents[ind];
	}
	return &cur_extent_pg[ind];
}

static void _NSZoneAddPage(NSZone *z, void *start, size_t num_pages)
{
	struct NSAllocZonePage *next_extent;

	next_extent = _NSZoneGetExtent(z, z->num_extents);
	if (next_extent == NULL)
	{
		return;
	}
	z->num_extents++;
	next_extent->start = start;
	next_extent->len = num_pages;
	next_extent->next_block = NULL;
}

static void _NSZoneInit(NSZone *z, size_t start_pages)
{
	void *page_start = NSMemGetPages(start_pages, true, NULL);

	z->num_extents = 0;
	z->meta.padding[0] = 0;
	z->meta.padding[1] = 0;

	if (page_start == NULL)
	{
		return;
	}

	_NSZoneAddPage(z, page_start, start_pages);
}

NSZone *NSZoneCreate(size_t start, bool allowFree,
		bool shared __attribute__((unused)))
{
	return NULL;
	NSZone *zone = NSDefaultAllocZone();		// Implicitly create the default zone

	while (zone->next != NULL)
		zone = zone->next;

	zone->next = NSMemGetPages(1, true, NULL);
	if (zone->next == NULL)
	{
		return NULL;
	}
	zone = zone->next;
	if (allowFree)
	{
		zone->callbacks = AllocNormalCallbacks;
	} else {
		zone->callbacks = AllocNoFreeCallbacks;
	}
	_NSZoneInit(zone, start);
	return zone;
}

void NSZoneDestroy(NSZone *z, bool addDefNSZone)
{
	return;
	unsigned int i = 0;
	// Don't delete the default zone!
	if (z == NULL)
		return;
	if (z == _NSDefaultZone)
		return;

	if (addDefNSZone)
	{
		for (; i < z->num_extents; i++)
		{
			_NSZoneAddPage(_NSDefaultZone, z->extents[i].start, z->extents[i].len);
		}
	}
	else
	{
		for (; i < z->num_extents; i++)
		{
			NSMemReleasePages(z->extents[i].start, z->extents[i].len);
		}
	}
}

void *NSZoneAlloc(NSZone *zone, size_t bytes)
{
	return malloc(bytes);
	if (zone == NULL)
		zone = NSDefaultAllocZone();
	if (zone->callbacks.alloc != NULL)
	{
		return zone->callbacks.alloc(zone, bytes);
	}
	return NULL;
}

void *NSZoneCalloc(NSZone *zone, size_t numElems, size_t size)
{
	return calloc(numElems, size);
	if (zone == NULL)
	{
		zone = NSDefaultAllocZone();
	}
	if (zone->callbacks.calloc != NULL)
	{
		return zone->callbacks.calloc(zone, numElems, size);
	}
	return NULL;
}

void *NSZoneRealloc(NSZone *zone, void *addr, size_t newsize)
{
	return realloc(addr, newsize);
	if (zone == NULL)
	{
		zone = NSDefaultAllocZone();
	}
	if (zone->callbacks.realloc != NULL)
	{
		return zone->callbacks.realloc(zone, addr, newsize);
	}
	// Standard behavior is return NULL on failure, since we can't do anything, we fail.
	return NULL;
}

#undef NSZoneFree

void NSZoneFree(NSZone *zone, void *addr)
{
	free(addr);
	return;
	if (zone == NULL)
	{
		zone = NSDefaultAllocZone();
	}
	if (zone->callbacks.free != NULL)
	{
		zone->callbacks.free(zone, addr);
	}
}

NSZone *NSZoneOf(const void *pointer)
{
	return NULL;
	NSZone *z = NSDefaultAllocZone();
	struct NSAllocZonePage *pg;

	while (z != NULL)
	{
		pg = z->extents;
		if (zone_extent_ptr(z, pointer) != NULL)
		{
			return z;
		}
		z = z->next;
	}
	// No zone? bah!
	return NULL;
}

void *NSMemGetPages(size_t numPages, bool block, void (*callback)())
{
	return mmap(NULL, numPages * getpagesize(), PROT_READ | PROT_WRITE, MAP_ANON, -1, 0);
	struct _page_list *prev_pages = NULL;
	struct _page_list *pages = free_pages;
	size_t num_pages;
	if (numPages == 0)
		return NULL;

	pthread_mutex_lock(&memMutex);
	while (pages != NULL)
	{
		num_pages = pages->num_pages;
		if (pages->num_pages > numPages)
		{
		    struct _page_list *p = (struct _page_list *)((char *)free_pages +
		    	    numPages * getpagesize());
		    p->next = pages->next;
		    p->num_pages = pages->num_pages - numPages;

		    if (prev_pages == NULL)
		    {
		    	free_pages = p;
		    }
		    else
		    {
			prev_pages->next = p;
		    }
		    pthread_mutex_unlock(&memMutex);
		    return pages;
		}
		if (pages->num_pages == numPages)
		{
			if (prev_pages == NULL)
			{
				free_pages = pages->next;
			}
			else
			{
				prev_pages->next = pages->next;
			}
			pthread_mutex_unlock(&memMutex);
			return pages;
		}
		prev_pages = pages;
		pages = pages->next;
	}
	pthread_mutex_unlock(&memMutex);
#ifdef __FreeBSD__
	return mmap(NULL, numPages * getpagesize(), PROT_READ | PROT_WRITE,
		MAP_ANON, -1, 0);
#else
	return NULL;
#endif
}

void NSMemReleasePages(void *pages, size_t num_pages)
{
	munmap(pages, num_pages * getpagesize());
	return;
	pthread_mutex_lock(&memMutex);
	((struct _page_list *)pages)->next = free_pages;
	free_pages = pages;
	free_pages->num_pages = num_pages;
	pthread_mutex_unlock(&memMutex);
}
#endif
