/*	$Id$	*/
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
 \file Geometry.h
 \brief Defines some useful functions and structures for basic geometry.
 */

#ifndef GEOMETRY_H
#define GEOMETRY_H
#include <Foundation/NSObjCRuntime.h>
#include <math.h>

#ifdef __OBJC__
@class NSString;
#else
typedef struct NSString NSString;
#endif

#ifndef MIN
/* A couple convenience macros/inline functions */
static inline double MIN(double a, double b)
{
	return (a < b) ? a : b;
}
#endif
#ifndef MAX
static inline double MAX(double a, double b)
{
	return (a > b) ? a : b;
}
#endif

/*!
 * \brief Represents a point in the Cartesian coordinate system.
 */
typedef struct NSPoint {
	double x; /*!< \brief The x coordinate. */
	double y; /*!< \brief The y coordinate. */
} NSPoint;

/*!
  \brief Describes a line between two points.
 */
typedef struct NSLine {
	NSPoint p1;	/*!< \brief The starting point. */
	NSPoint p2;	/*!< \brief The ending point. */
} NSLine;

/*!
  \brief Describes the size of a region.
 */
typedef struct NSSize {
	double width;	/*!< \brief The width. */
	double height;	/*!< \brief The height. */
} NSSize;

/*!
 * \brief Describes a rectangle -- origin and size.
 */
typedef struct NSRect {
	NSPoint origin;	/*!< \brief The origin (starting point) of the rectangle. */
	NSSize size;		/*!< \brief The width and height of the rectangle, from the origin. */
} NSRect;

/*!
  \enum NSRectEdge
  \brief Identifiers used by DivideRect to specify the edge of the rectangle from which the division is measured.
 */
typedef enum NSRectEdge {
	NSMinXEdge,	/*!< \brief Measure from the left edge of the rectangle. */
	NSMinYEdge,	/*!< \brief Measure from the bottom edge of the rectangle. */
	NSMaxXEdge,	/*!< \brief Measure from the right edge of the rectangle. */
	NSMaxYEdge	/*!< \brief Measure from the top edge of the rectangle. */
} NSRectEdge;

enum : unsigned long long {
	NSAlignMinXInward = 1ULL << 0,
	NSAlignMinYInward = 1ULL << 1,
	NSAlignMaxXInward = 1ULL << 2,
	NSAlignMaxYInward = 1ULL << 3,
	NSAlignWidthInward = 1ULL << 4,
	NSAlignHeightInward = 1ULL << 5,
	NSAlignMinXOutward = 1ULL << 8,
	NSAlignMinYOutward = 1ULL << 9,
	NSAlignMaxXOutward = 1ULL << 10,
	NSAlignMaxYOutward = 1ULL << 11,
	NSAlignWidthOutward = 1ULL << 12,
	NSAlignHeightOutward = 1ULL << 13,
	NSAlignMinXNearest = 1ULL << 16,
	NSAlignMinYNearest = 1ULL << 17,
	NSAlignMaxXNearest = 1ULL << 18,
	NSAlignMaxYNearest = 1ULL << 19,
	NSAlignWidthNearest = 1ULL << 20,
	NSAlignHeightNearest = 1ULL << 21,
	NSAlignRectFlipped = 1ULL << 63,

	NSAlignAllEdgesInward = NSAlignMinXInward|NSAlignMinYInward|NSAlignMaxXInward|NSAlignMaxYInward,
	NSAlignAllEdgesOutward = NSAlignMinXOutward|NSAlignMinYOutward|NSAlignMaxXOutward|NSAlignMaxYOutward,
	NSAlignAllEdgesNearest = NSAlignMinXNearest|NSAlignMinYNearest|NSAlignMaxXNearest|NSAlignMaxYNearest,
};

typedef unsigned long long NSAlignmentOptions;

/*!
 *  Predefined NSPoint at (0.0,0.0).
 */
SYSTEM_EXPORT const NSPoint NSZeroPoint;

/*!
 *  \brief Predefined rectangle with origin at (0.0,0.0) and size of 0.0x0.0
 */
SYSTEM_EXPORT const NSRect NSZeroRect;

/*!
 *  \brief Predefined NSSize of width and height both 0.0
 */
SYSTEM_EXPORT const NSSize NSZeroSize;

/*!
 * \brief Returns a NSPoint object of coordinates x and y.
 * \param x The X coordinate of the point.
 * \param y The Y coordinate of the point.
 * \return The point at the given coordinates.
 */
NS_INLINE NSPoint NSMakePoint(double x, double y) {
	NSPoint pt;
	pt.x = x;
	pt.y = y;
	return pt;
}

/*!
 * \brief Returns a NSSize object of width w, and height h.
 * \param w Width
 * \param h Height.
 * \return The size object of width w, and height h.
 */
NS_INLINE NSSize NSMakeSize(double w, double h) {
	NSSize pt;
	pt.width = w;
	pt.height = h;
	return pt;
}

/*!
 * \brief Returns a rectangle of given dimensions.
 * \param x X coordinate of the origin.
 * \param y Y coordinate of the origin.
 * \param w Width of the rectangle.
 * \param h Height of the rectangl.
 * \return Rectangle of given dimensions.
 */
NS_INLINE NSRect NSMakeRect(double x, double y, double w, double h) {
	NSRect pt;
	pt.origin.x = x;
	pt.origin.y = y;
	pt.size.width = w;
	pt.size.height = h;
	return pt;
}

/*!
 * \brief Returns the maximum X coordinate of the given rectangle.
 * \param aRect Rectangle to get the max X coordinate of.
 * \return NSMax X coordinate of the rectangle.
 */
NS_INLINE double NSMaxX(NSRect aRect)
{
	return aRect.origin.x + aRect.size.width;
}

/*!
 * \brief Returns the maximum Y coordinate of the given rectangle.
 * \param aRect Rectangle to get the max Y coordinate of.
 * \return NSMax Y coordinate of the rectangle.
 */
NS_INLINE double NSMaxY(NSRect aRect)
{
	return aRect.origin.y + aRect.size.height;
}

/*!
 * \brief Returns the middle X coordinate of the given rectangle.
 * \param aRect Rectangle to get the mid X coordinate of.
 * \return Mid X coordinate of the rectangle.
 */
NS_INLINE double NSMidX(NSRect aRect)
{
	return aRect.origin.x + aRect.size.width / 2.0;
}

/*!
 * \brief Returns the middle Y coordinate of the given rectangle.
 * \param aRect Rectangle to get the mid Y coordinate of.
 * \return Mid Y coordinate of the rectangle.
 */
NS_INLINE double NSMidY(NSRect aRect)
{
	return aRect.origin.y + aRect.size.height / 2.0;
}

/*!
 * \brief Returns the minimum X coordinate of the given rectangle.
 * \param aRect Rectangle to get the min X coordinate of.
 * \return Min X coordinate of the rectangle.
 */
NS_INLINE double NSMinX(NSRect aRect)
{
	return aRect.origin.x;
}

/*!
 * \brief Returns the minimum Y coordinate of the given rectangle.
 * \param aRect Rectangle to get the min Y coordinate of.
 * \return Min Y coordinate of the rectangle.
 */
NS_INLINE double NSMinY(NSRect aRect)
{
	return aRect.origin.y;
}

/*!
 * \brief Returns the width of a rectangle.
 * \param aRect rectangle to get the width of.
 * \return Width of the rectangle.
 */
NS_INLINE double NSWidth(NSRect aRect)
{
	return aRect.size.width;
}

/*!
 * \brief Returns the height of a rectangle.
 * \param aRect rectangle to get the height of.
 * \return Height of the rectangle.
 */
NS_INLINE double NSHeight(NSRect aRect)
{
	return aRect.size.height;
}

/*!
 * \brief cut the size of the rectangle by dX and dY, and offset it such.
 * \param aRect Rectangle to inset.
 * \param dX NSValue on X axis to decrease size by.
 * \param dY NSValue on Y axis to decrease size by.
 * \return Smaller rectangle, inset of aRect by dX and dY.
 */
NS_INLINE NSRect NSInsetRect(NSRect aRect, double dX, double dY)
{
	NSRect rect = aRect;
	rect.origin.x += dX;
	rect.origin.y += dY;
	rect.size.width -= dX * 2.0;
	rect.size.height -= dY * 2.0;
	return rect;
}

/*!
 * \brief Moves the rectangle over by dX and dY, and returns translation.
 * \param aRect Rectangle to translate.
 * \param dX X offset.
 * \param dY Y offset.
 * \return Rectangle of same size as aRect, translated (+dX,+dY).
 */
NS_INLINE NSRect NSOffsetRect(NSRect aRect, double dX, double dY)
{
	NSRect rect = aRect;
	rect.origin.x += dX;
	rect.origin.y += dY;
	return rect;
}

/*!
 * \brief Create two rectangles from one, by dividing.
 * \param inRect Rectangle to divide.
 * \param slice One resulting rectangle.
 * \param remainder The other resulting rectangle.
 * \param amount NSSize that slice should be.
 * \param edge Edge from which to measure the cut.
 */
SYSTEM_EXPORT void NSDivideRect(NSRect inRect,
	NSRect *slice,
	NSRect *remainder,
	double amount,
	NSRectEdge edge);

/*!
 * \brief Returns the smallest rectangle large enough with integer values.
 * \param aRect Rectangle to integrate.
 * \return Rectangle with integer size and origin, just large enough to hold aRect.
 */
NS_INLINE NSRect NSIntegralRect(NSRect aRect)
{
	return NSMakeRect(floor(NSMinX(aRect)),floor(NSMinY(aRect)),
		ceil(NSWidth(aRect)), ceil(NSHeight(aRect)));
}

extern NSRect NSIntegralRectWithOptions(NSRect rect, NSAlignmentOptions options);

/*!
 * \brief Returns true if a rectangle is empty.
 * \param aRect Rectangle to check.
 * \return true if the rectangle is empty, false if it is not.
 */
NS_INLINE bool NSIsEmptyRect(NSRect aRect)
{
	if (aRect.size.width <= 0.0 || aRect.size.height <= 0.0)
		return true;
	return false;
}

/*!
 * \brief Returns a rectangle large enough to hold both rectangles.
 * \param aRect First rectangle to hold.
 * \param bRect Second rectangle to fit in the result.
 * \return Rectangle large enough to hold both rectangles.
 */
NS_INLINE NSRect NSUnionRect(NSRect aRect, NSRect bRect)
{
	NSRect rect;

	if (NSIsEmptyRect(aRect) && NSIsEmptyRect(bRect))
		return NSZeroRect;
	if (NSIsEmptyRect(aRect))
		return bRect;
	if (NSIsEmptyRect(bRect))
		return aRect;
	
	rect = NSMakeRect(MIN(NSMinX(aRect), NSMinX(bRect)),
		MIN(NSMinY(aRect), NSMinY(bRect)), 0.0, 0.0);
	return NSMakeRect(NSMinX(rect), NSMinY(rect),
		MAX(NSMaxX(aRect), NSMaxX(bRect) - NSMinX(rect)),
		MAX(NSMaxY(aRect), NSMaxY(bRect) - NSMinX(rect)));
}

/*!
 * \brief Returns the intersection rectangle of 2 rectangles.
 * \param aRect One rectangle.
 * \param bRect The other rectangle.
 * \return Intersection rectangle of aRect and bRect.
 */
NS_INLINE NSRect NSIntersectionRect(NSRect aRect, NSRect bRect)
{
	NSRect rect;

	if (NSMaxX(aRect) <= NSMinX(bRect) || NSMaxX(bRect) <= NSMinX(aRect) ||
			NSMaxY(aRect) <= NSMinY(bRect) || NSMaxY(bRect) <= NSMinY(aRect))
		return NSZeroRect;
	if (NSMinX(aRect) <= NSMinX(bRect))
		rect.origin.x = bRect.origin.x;
	else
		rect.origin.x = aRect.origin.x;

	if (NSMinY(aRect) <= NSMinY(bRect))
		rect.origin.y = bRect.origin.y;
	else
		rect.origin.y = aRect.origin.y;

	if (NSMaxX(aRect) <= NSMaxX(bRect))
		rect.size.width = NSMaxX(aRect) - rect.origin.x;
	else
		rect.size.width = NSMaxX(bRect) - rect.origin.x;

	if (NSMaxY(aRect) <= NSMaxY(bRect))
		rect.size.height = NSMaxY(aRect) - rect.origin.y;
	else
		rect.size.height = NSMaxY(bRect) - rect.origin.y;
	
	return rect;
}

/*!
 * \brief Returns true if two sizes are equal, false otherwise.
 * \param aSize One size.
 * \param bSize NSSize to compare with.
 * \return true if they are equal, false if they are not.
 */
NS_INLINE bool NSEqualSizes(NSSize aSize, NSSize bSize)
{
	if (aSize.width == bSize.width && aSize.height == bSize.height)
		return true;
	return false;
}

/*!
 * \brief Returns true if two points are equal, false otherwise.
 * \param aPoint One point.
 * \param bPoint NSPoint to compare with.
 * \return true if they are equal, false if they are not.
 */
NS_INLINE bool NSEqualPoints(NSPoint aPoint, NSPoint bPoint)
{
	if (aPoint.x == bPoint.x && aPoint.y == bPoint.y)
		return true;
	return false;
}

/*!
 * \brief Returns true if the 2 rectangles are equal.
 * \param aRect One rectangle.
 * \param bRect The rectangle to compare with.
 * \return true if they are equal, false if they are not.
 */
NS_INLINE bool NSEqualRects(NSRect aRect, NSRect bRect)
{
	if (NSEqualPoints(aRect.origin, bRect.origin) &&
			NSEqualSizes(aRect.size, bRect.size))
		return true;

	return false;
}

/*!
 */
NS_INLINE bool NSIntersectsRect(NSRect aRect, NSRect bRect)
{
	return (!NSEqualRects(NSIntersectionRect(aRect, bRect), NSZeroRect));
}

/*!
 * \brief Returns true if a point is inside a rectangle's bounds.
 * \param aPoint The point to check.
 * \param aRect The enclosing rectangle.
 * \param flipped Whether to flip the Y-axis so that positive goes 'down'.
 * \return true if aPoint is in aRect, false otherwise.
 */
NS_INLINE bool NSMouseInRect(NSPoint aPoint, NSRect aRect, bool flipped)
{
	if (flipped)
		return (aPoint.x >= NSMinX(aRect) &&
			aPoint.y >= NSMinY(aRect) &&
			aPoint.x < NSMaxX(aRect) &&
			aPoint.y < NSMaxY(aRect));
	else
		return (aPoint.x >= NSMinX(aRect) &&
			aPoint.y > NSMinY(aRect) &&
			aPoint.x < NSMaxX(aRect) &&
			aPoint.y <= NSMaxY(aRect));
}

/*!
 * \brief Like MouseInRect but uses the flipped Y-axis.
 * \param aPoint NSPoint to check.
 * \param aRect Enclosing rectangle.
 * \return true if aPoint is in aRect, false otherwise.
 */
NS_INLINE bool NSPointInRect(NSPoint aPoint, NSRect aRect)
{
	return NSMouseInRect(aPoint, aRect, true);
}

/*!
 * \brief Returns true if bRect is completely contained in aRect.
 * \param aRect Enclosing rectangle.
 * \param bRect Enclosed rectangle.
 * \return true if bRect is completely contained in aRect, not touching any edge, false otherwise.
 */
NS_INLINE bool NSContainsRect(NSRect aRect, NSRect bRect)
{
	if (NSIsEmptyRect(bRect) || NSIsEmptyRect(aRect) ||
		(NSMinX(bRect) <= NSMinX(aRect)) || (NSMinY(bRect) <= NSMinY(aRect)) ||
		(NSMaxX(bRect) >= NSMaxX(aRect)) || (NSMaxY(bRect) >= NSMaxY(aRect)))
		return false;
	return true;
}

/*!
 * \brief Returns a NSString description of a point.
 * \param aPoint NSPoint to get the description of.
 * \return Description as a NSString *.
 */
SYSTEM_EXPORT NSString *NSStringFromPoint(NSPoint aPoint);

/*!
 * \brief Returns a NSString description of a rectangle.
 * \param aRect Rectangle to get the description of.
 * \return Description as a NSString *.
 */
SYSTEM_EXPORT NSString *NSStringFromRect(NSRect aRect);

/*!
 * \brief Returns a NSString description of a size structure.
 * \param aSize NSSize to get the description of.
 * \return Description as a NSString *.
 */
SYSTEM_EXPORT NSString *NSStringFromSize(NSSize aSize);

SYSTEM_EXPORT NSRect NSRectFromString(NSString *);
SYSTEM_EXPORT NSPoint NSPointFromString(NSString *);
SYSTEM_EXPORT NSSize NSSizeFromString(NSString *);

#endif /* Geometry.h */

/*
   vim:syntax=objc:
 */
