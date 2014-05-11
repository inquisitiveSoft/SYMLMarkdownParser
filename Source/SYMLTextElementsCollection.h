//
//  SYMLTextElementsCollection.h
//  Syml
//
//  Created by Harry Jordan on 17/01/2013.
//  Copyright (c) 2013 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//


#import "SYMLAttributedObjectCollection.h"


@interface SYMLTextElementsCollection : NSObject <SYMLAttributedObjectCollection>

- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithAttributedString:(NSString *)string withAttributes:(NSDictionary *)attributes;

- (NSAttributedString *)attributedString;

- (void)addAttributes:(NSDictionary *)attributes range:(NSRange)range;
- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)range;

- (void)markSectionAsElement:(NSString *)elementKey withContent:(id)content range:(NSRange)range;

- (NSArray *)allElements;
- (NSArray *)elementsMatchingTypes:(NSArray *)types;
- (NSArray *)elementsForRange:(NSRange)range;

@end
