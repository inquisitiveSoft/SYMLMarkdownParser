//
//  SYMLTextElement.h
//  Syml
//
//  Created by Harry Jordan on 17/01/2013.
//  Copyright (c) 2013 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "SYMLMarkdownParserAttributes.h"


@interface SYMLTextElement : NSObject

+ (instancetype)elementForURL:(NSURL *)url withRange:(NSRange)range;

@property (strong) NSString *type;
@property (assign) NSRange range;

@property (strong, nonatomic) NSString *content;
@property (strong) NSURL *URL;

// Link specific attributes
@property (strong) NSString *linkName, *linkTag, *linkURLString;


@end
