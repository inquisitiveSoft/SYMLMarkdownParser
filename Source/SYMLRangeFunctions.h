//
//  SYMLRangeFunctions.h
//  Syml
//
//  Created by Harry Jordan on 09/05/2014.
//  Copyright (c) 2014 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//

@import Foundation;
@import CoreFoundation;


typedef NS_ENUM(NSUInteger, NSRangeIntersectionMode) {
	NSRangeIntersectionModeEdges,
	NSRangeIntersectionModeOverlap,
};


NSRange NSRangeFromCFRange(CFRange range);
CFRange NSRangeToCFRange(NSRange range);

NSRange NSRangeWithinString(NSString *string, NSRange desiredRange);
BOOL NSRangesIntersect(NSRange firstRange, NSRange secondRange, NSRangeIntersectionMode mode);
NSRange NSRangeWithinEnclosingRange(NSRange interiorRange, NSRange enclosingRange);