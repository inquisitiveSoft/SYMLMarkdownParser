//
//  SYMLRangeFunctions.m
//  Syml
//
//  Created by Harry Jordan on 09/05/2014.
//  Copyright (c) 2014 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//
#import "SYMLRangeFunctions.h"


#define NSINTEGER_TO_CFINDEX(x) ((CFIndex)(x == NSNotFound ? kCFNotFound : x))
#define CFINDEX_TO_NSINTEGER(x) ((NSInteger)(x == kCFNotFound ? NSNotFound : x))


NSRange NSRangeFromCFRange(CFRange range)
{
	return NSMakeRange(CFINDEX_TO_NSINTEGER(range.location), CFINDEX_TO_NSINTEGER(range.length));
}


CFRange NSRangeToCFRange(NSRange range)
{
	return CFRangeMake(NSINTEGER_TO_CFINDEX(range.location), NSINTEGER_TO_CFINDEX(range.length));
}



NSRange NSRangeWithinString(NSString *string, NSRange desiredRange) {
		// Returns a range that lies within the given string
	return NSRangeWithinEnclosingRange(desiredRange, NSMakeRange(0, [string length]));
}


BOOL NSRangesIntersect(NSRange firstRange, NSRange secondRange, NSRangeIntersectionMode mode) {
	if(mode == NSRangeIntersectionModeEdges) {
		return firstRange.location + firstRange.length >= secondRange.location
		&& firstRange.location <= secondRange.location + secondRange.length;
	}
	
		// NSRangeIntersectionModeOverlap
	return firstRange.location + firstRange.length > secondRange.location
	&& firstRange.location < secondRange.location + secondRange.length;
}


NSRange NSRangeWithinEnclosingRange(NSRange interiorRange, NSRange enclosingRange)
{
	if(!NSRangesIntersect(interiorRange, enclosingRange, NSRangeIntersectionModeEdges) || interiorRange.location == NSNotFound || enclosingRange.location == NSNotFound)
		return NSMakeRange(NSNotFound, 0);
	
	if(interiorRange.location < enclosingRange.location) {
		interiorRange.length = MAX(0, interiorRange.length - (interiorRange.location - enclosingRange.location));
		interiorRange.location = enclosingRange.location;
	}
	
	interiorRange.length = MIN(NSMaxRange(interiorRange), NSMaxRange(enclosingRange)) - interiorRange.location;
	return interiorRange;
}
