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
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR COEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * 
 */

#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>

#ifdef __cplusplus
#include <algorithm>
#endif

/*!
 * \brief Matches NSFastEnumerationState per Apple's Objective-C 2.0 documents.
 */

struct NSFastEnumerationState;
typedef struct NSFastEnumerationState NSFastEnumerationState;
struct NSFastEnumerationState
{
	unsigned long state;
	id *itemsPtr;
	unsigned long *mutationsPtr;
	unsigned long extra[ 5 ];

#ifdef __cplusplus
	explicit inline
	NSFastEnumerationState()
			: state(), itemsPtr(), mutationsPtr(), extra() {}
#endif
};

#if defined(__cplusplus) && __GNUC_PREREQ__(4,6)
namespace std
{
	const size_t OBJC_ENUMERATION_AMOUNT= 16;

	template< typename ObjCIterable,
			size_t enumCount= OBJC_ENUMERATION_AMOUNT >
	class ObjCFastEnumerableIterator
	{
		private:
			ObjCIterable iterableObject;
			unsigned long partialIdx;
			NSFastEnumerationState state;
			id objects[ enumCount ];
			unsigned long partialCount;

			void
			nextBlock()
			{
				//this->partialCount= [ this->iterableObject
				ObjCIterable iobj= this->iterableObject;
				NSFastEnumerationState *const st= &this->state;
				id *const objs= this->objects;
				const unsigned long ct= enumCount;
				this->partialCount = [ iobj countByEnumeratingWithState: st
						objects: objs
						count: ct ];
			}

			void
			advance()
			{
				if( !( ++( this->partialIdx ) < this->partialCount ) )
				{
					this->nextBlock();
				}
			}

		public:
			explicit inline
			ObjCFastEnumerableIterator()
					: iterableObject(), partialIdx(), state(), objects(),
					partialCount() {}

			explicit inline
			ObjCFastEnumerableIterator( const ObjCIterable obj )
					: iterableObject( obj ), partialIdx(), state(), objects(),
					partialCount()
			{
				this->nextBlock();
			}

			ObjCFastEnumerableIterator &
			operator ++()
			{
				this->advance();
				return *this;
			}

			ObjCFastEnumerableIterator
			operator++ ( int )
			{
				const ObjCFastEnumerableIterator tmp( *this );
				this->advance();
				return tmp;
			}

			const id &
			operator *() const
			{
				return this->state.itemsPtr[ this->partialIdx ];
			}

			friend inline bool
			operator == ( const ObjCFastEnumerableIterator &lhs,
					const ObjCFastEnumerableIterator &rhs )
			{
				return !lhs.partialCount && !rhs.partialCount;
			}

			friend inline bool
			operator != ( const ObjCFastEnumerableIterator &lhs,
					const ObjCFastEnumerableIterator &rhs )
			{
				return !( lhs == rhs );
			}
	};

	inline ObjCFastEnumerableIterator< id >
	begin( id objcContainer )
	{
		return ObjCFastEnumerableIterator< id >( objcContainer );
	}

	inline ObjCFastEnumerableIterator< id >
	end( id /* objcContainer */ )
	{
		return ObjCFastEnumerableIterator< id >();
	}

	class __objchookforiteration {};

	template< typename ObjC_Class >
	inline id
	operator << ( const __objchookforiteration &, ObjC_Class *const item )
	{
		return static_cast< id >( item );
	}
}

#define in : std::__objchookforiteration() <<
#endif
@class NSArray;

@protocol NSFastEnumeration
- (unsigned long) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackBuf count:(unsigned long)len;
@end

/*!
 \class NSEnumerator
 \brief Base class for enumerators.

 \details This is an abstract base class for all enumerators.  Classes that can
 be enumerated over must provide an -enumerator method, and subclass this
 NSEnumerator class.
 */
@interface NSEnumerator	: NSObject <NSFastEnumeration>
{
	id nextObject; /*!< */
}

/*!
 * \brief Returns the next object in the collection being enumerated.  Returns nil when the collection has been traversed.
 */
-(id)nextObject;

- (NSArray *) allObjects;
@end

/*
   vim:syntax=objc:
 */
