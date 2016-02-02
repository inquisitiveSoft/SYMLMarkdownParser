//
//  SYMLMarkdownTextFormatter-Mac.h
//  Syml
//
//  Created by Harry Jordan on 17/01/2013.
//  Copyright (c) 2013 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//

#import "SYMLMarkdownParserAttributes.h"
#import "SYMLTextElementsCollection.h"


@interface SYMLMarkdownTextFormatter : NSObject <SYMLMarkdownParserAttributes>

- (NSAttributedString *)formatString:(NSString *)inputString;
- (NSAttributedString *)formatString:(NSString *)inputString elements:(SYMLTextElementsCollection **)textElements;

- (SYMLTextElementsCollection *)elementsFromString:(NSString *)inputString;


@property (strong, readonly) NSDictionary *baseAttributes, *emphasisAttributes, *strongAttributes, *linkAttributes, *urlAttributes, *headingAttributes, *horizontalRuleAttributes, *blockquoteAttributes, *listAttributes;

@end
