//
//  SYMLMarkdownParserAttributes.h
//  Syml
//
//  Created by Harry Jordan on 17/01/2013.
//  Copyright (c) 2013 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//

// Element keys
extern NSString * const SYMLTextElementContent;

// Attributes to mark specific content
extern NSString * const SYMLTextHeaderElement;
extern NSString * const SYMLTextHorizontalRuleElement;
extern NSString * const SYMLTextBlockquoteElement;
extern NSString * const SYMLTextListElement;

extern NSString * const SYMLTextLinkElement;
extern NSString * const SYMLTextLinkNameElement;
extern NSString * const SYMLTextLinkTagElement;
extern NSString * const SYMLTextLinkURLElement;

extern NSString * const SYMLTextEmailElement;
extern NSString * const SYMLTextDateElement;
extern NSString * const SYMLTextAddressElement;
extern NSString * const SYMLTextPhoneNumberElement;
extern NSString * const SYMLTextEmailElement;


@protocol SYMLMarkdownParserAttributes <NSObject>
@optional
@property (readonly) NSDictionary *headingAttributes, *horizontalRuleAttributes, *blockquoteAttributes, *listAttributes, *emphasisAttributes, *strongAttributes, *linkAttributes, *linkTitleAttributes, *invalidLinkAttributes, *urlAttributes;

@end
