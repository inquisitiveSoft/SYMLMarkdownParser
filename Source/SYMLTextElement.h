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


@interface SYMLTextElement : NSObject <NSCopying>

+ (instancetype)elementForURL:(NSURL *)url withRange:(NSRange)range;

@property (strong, nonatomic) NSString *type;
@property (assign, nonatomic) NSRange range;

@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSURL *URL;

// Link specific attributes
@property (strong, nonatomic) NSString *linkName, *linkTag, *linkURLString;


- (SYMLTextElement *)elementWithOffset:(NSInteger)offset;

@end
