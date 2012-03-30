/*
 * Copyright (c) 2004-2012	Gold Project
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

/*!
  \file NSRange.h
  \author Justin Hibbits
 */
#ifndef RANGE_H
#define RANGE_H

#import <Foundation/NSObjCRuntime.h>


#ifdef __cplusplus
// External operators should live in a namespace with their class
namespace RangeNamespace
{
#endif

/*!
 * \brief Specifies a range of items in arrays, strings, etc.
 */
typedef struct NSRange {
#ifdef __cplusplus
	// In C++, for safety, ranges will be set to "0" if default constructed.
	explicit inline NSRange() : location(), length() {}
	explicit inline NSRange(const unsigned int loc, const unsigned int len)
	: location(loc), length(len) {}
#endif
	unsigned int location;	/*!< \brief Starting location of the range. */
	unsigned int length;	/*!< \brief Length of the range. */
} NSRange;

#ifdef __cplusplus
inline bool operator==(const NSRange &lhs, const NSRange &rhs);
inline bool operator!=(const NSRange &lhs, const NSRange &rhs);
}
typedef RangeNamespace::NSRange NSRange;
#endif

#ifdef __cplusplus
typedef const NSRange & ConstRangeArg;
#else
typedef const NSRange ConstRangeArg;
#endif
typedef NSRange *NSRangePointer;

__BEGIN_DECLS

/*!
 * \brief Returns a NSRange object of given location and length.
 * \param location Location of range beginning.
 * \param length Length of range.
 * \result NSRange object of given location and length.
 */
NS_INLINE NSRange NSMakeRange(unsigned int location, unsigned int length)
{
	NSRange r;
	r.location = location;
	r.length = length;
	return r;
}

/*!
 * \brief Returns true if ranges are equal, false if they are not.
 * \param range1 First range to compare.
 * \param range2 NSRange to compare with range1.
 * \result true if they are equal, false if they are not.
 */
NS_INLINE bool NSEqualRanges(ConstRangeArg range1, ConstRangeArg range2)
{
	return (range1.location == range2.location && 
		range1.length == range2.length);
}

/*!
 * \brief Returns the sum of the range location and length (max value + 1).
 * \param range NSRange to get the max value of.
 * \result Maximum range of the range (1 + Maximum value).
 */
NS_INLINE unsigned int NSMaxRange(ConstRangeArg range)
{
	return range.location + range.length;
}

/*!
 * \brief Returns whether the location is inside the range.
 * \param location Location to check.
 * \param range NSRange to check in.
 * \result true if location is in the range, false otherwise.
 */
NS_INLINE bool NSLocationInRange(unsigned int location, ConstRangeArg range)
{
	return (location >= range.location) &&
			(location - range.location < range.length);
}

/*!
 * \brief Returns the union of two ranges.
 * \param range1 One range of the union.
 * \param range2 The other range of the union.
 * \result The lowest location, and the maximum range of the two ranges.
 */
NS_INLINE NSRange NSUnionRange(ConstRangeArg range1, ConstRangeArg range2)
{
	NSRange range = range1;
	if ( range1.location > range2.location )
		range.location = range2.location;

	if ( NSMaxRange(range) < NSMaxRange(range2) )
		range.length = NSMaxRange(range2) - range.location;

	return range;
}

/*!
 * \brief Returns the intersect range of two ranges.
 * \param range1 The first range to intersect.
 * \param range2 The range to intersect with range1.
 * \result The intersection range of the two ranges.
 */
NS_INLINE NSRange NSIntersectionRange(ConstRangeArg range1, ConstRangeArg range2)
{
	NSRange range;
	
#ifndef __cplusplus
	range = (NSRange){0, 0};
#endif

	if ( range2.location > NSMaxRange(range1) || 
			range1.location > NSMaxRange(range2) )
		return range;
	
	range = range1;

	if (range2.location > range.location)
		range.location = range2.location;
	
	if ( NSMaxRange(range2) < NSMaxRange(range) )
		range.length = NSMaxRange(range2) - range.location;
	
	return range;
}

@class NSString;
/*!
 * \brief Returns a string representation of the range.
 * \param range NSRange to stringify.
 * \return NSString representation of the range, in the format {location, length}.
 */
SYSTEM_EXPORT NSString *NSStringFromRange(NSRange range);

__END_DECLS

/*
 * This section of functions will let the user of a C++ STL compatible container (Alepha
 * containers are STL compatible) create iterators from his specified range objects.
 *
 * The user can also create NSRange objects from std::pair< iter, iter > objects, to let him
 * build ranges for libsystem.
 */
#ifdef __cplusplus
#include <utility>
#include <iterator>
#include <algorithm>
template<typename Container>
inline const typename Container::iterator
container_range_begin(Container &container, const NSRange &range)
{
	typename Container::iterator rv= container.begin();
	std::advance(rv, range.location);
	return rv;
}

template<typename Container>
inline const typename Container::iterator
container_range_end(Container &container, const NSRange &range)
{
	typename Container::iterator rv= container.begin();
	std::advance(rv, range.location + range.length);
	return rv;
}

template<typename Container>
inline const typename Container::const_iterator
container_range_begin(const Container &container, const NSRange &range)
{
	typename Container::const_iterator rv= container.begin();
	std::advance(rv, range.location);
	return rv;
}

template<typename Container>
inline const typename Container::const_iterator
container_range_end(const Container &container, const NSRange &range)
{
	typename Container::const_iterator rv= container.begin();
	std::advance(rv, range.location + range.length);
	return rv;
}

template<typename Container>
inline const std::pair<typename Container::iterator, typename Container::iterator>
container_range(Container &container, const NSRange &range)
{
	return std::make_pair(container_range_begin(container, range),
			container_range_end(container,range));
}

template<typename Container>
inline const std::pair<typename Container::const_iterator, typename Container::const_iterator>
container_range(const Container &container, const NSRange &range)
{
	return std::make_pair(container_range_begin(container, range),
			container_range_end(container,range));
}

template<typename Container, typename Iterator>
inline const NSRange
make_range(Container &container, const std::pair<Iterator, Iterator> &r)
{
	return NSRange(std::distance(container.begin(), r.first),std::distance(r.first,r.second));
}

template<typename Container, typename Iterator>
inline const NSRange
make_range(const Container &container, const std::pair<Iterator, Iterator> &r)
{
	return NSRange(std::distance(container.begin(), r.first),std::distance(r.first,r.second));
}

inline bool RangeNamespace::operator==(const NSRange &lhs, const NSRange &rhs)
{
	return NSEqualRanges(lhs, rhs);
}

inline bool RangeNamespace::operator!=(const NSRange &lhs, const NSRange &rhs)
{
	return !(lhs == rhs);
}

#endif

#endif

/*
   vim:syntax=objc:
 */
