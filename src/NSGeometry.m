/*
 * Copyright (c) 2004-2006	Gold Project
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

#import <Foundation/NSGeometry.h>
#import <Foundation/NSString.h>
#include <stdio.h>

const NSPoint NSZeroPoint = { 0.0, 0.0 };
const NSSize NSZeroSize = { 0.0, 0.0 };
const NSRect NSZeroRect = { {0.0, 0.0}, {0.0, 0.0} };

void NSDivideRect(NSRect inRect, NSRect *slice, NSRect *remainder, double amount, NSRectEdge edge)
{
	*remainder = NSZeroRect;
	*slice = inRect;

	switch (edge)
	{
		case NSMinXEdge:
			if (amount > NSWidth(inRect))
			{
				return;
			}
			slice->size.width = amount;
			*remainder = NSMakeRect(NSMaxX(*slice), NSMinY(inRect),
				NSWidth(inRect) - amount, NSHeight(inRect));
			return;
		case NSMinYEdge:
			if (amount > NSHeight(inRect))
			{
				return;
			}
			slice->size.height = amount;
			*remainder = NSMakeRect(NSMinX(inRect), NSMaxY(*slice),
				NSWidth(inRect), NSHeight(inRect) - amount);
			return;
		case NSMaxXEdge:
			if (amount > NSWidth(inRect))
			{
				return;
			}
			slice->origin.x = NSMaxX(inRect) - amount;
			slice->size.width = amount;
			*remainder = NSMakeRect(NSMinX(inRect), NSMinY(inRect),
				NSWidth(inRect) - amount, NSHeight(inRect));
			return;
		case NSMaxYEdge:
			if (amount > NSHeight(inRect))
			{
				return;
			}
			slice->origin.y = NSMaxY(inRect) - amount;
			slice->size.height = amount;
			*remainder = NSMakeRect(NSMinX(inRect), NSMinY(inRect),
				NSWidth(inRect), NSHeight(inRect) - amount);
			return;
	}
}

NSString *NSStringFromPoint(NSPoint aPoint)
{
	return [NSString stringWithFormat:@"{x=%g, y=%g}",aPoint.x,aPoint.y];
}

NSString *NSStringFromRect(NSRect aRect)
{
	return [NSString stringWithFormat:@"{x=%g, y=%g, width=%g, height=%g}",
		aRect.origin.x,aRect.origin.y,aRect.size.width,aRect.size.height];
}

NSString *NSStringFromSize(NSSize aSize)
{
	return [NSString stringWithFormat:@"{width=%g, height=%g}",aSize.width,aSize.height];
}

NSRect NSRectFromString(NSString* string)
{
    NSRect rect = NSZeroRect;
    const char *str = [string UTF8String];

    if (str == NULL)
		return rect;

	sscanf(str, "{x=%lg, y=%lg, width=%lg, height=%lg}", &rect.origin.x, &rect.origin.y, &rect.size.width, &rect.size.height);
	return rect;
}
