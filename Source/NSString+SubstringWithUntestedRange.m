//
//  NSString+SubstringWithUntestedRange.m
//  Syml
//
//  Created by Harry Jordan on 17/01/2013.
//  Copyright (c) 2013 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//

#import "NSString+SubstringWithUntestedRange.h"
#import "SYMLRangeFunctions.h"


@implementation NSString (AJKSubstringWithUntestedRange)


- (NSRange)ajk_range
{
	return NSMakeRange(0, [self length]);
}


- (NSString *)ajk_substringWithUntestedRange:(NSRange)substringRange
{
	NSRange validRange = NSRangeWithinString(self, substringRange);
	if(validRange.location != NSNotFound) {
		return [self substringWithRange:validRange];
	}
	
	return @"";
}


@end