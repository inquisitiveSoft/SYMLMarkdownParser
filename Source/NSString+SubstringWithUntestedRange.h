//
//  NSString+SubstringWithUntestedRange.h
//  Syml
//
//  Created by Harry Jordan on 17/01/2013.
//  Copyright (c) 2013 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>


@interface NSString (AJKSubstringWithUntestedRange)

- (NSRange)ajk_range;
- (NSString *)ajk_substringWithUntestedRange:(NSRange)substringRange;

@end
