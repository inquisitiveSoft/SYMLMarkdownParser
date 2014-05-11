//
//  SYMLTextElement.m
//  Syml
//
//  Created by Harry Jordan on 17/01/2013.
//  Copyright (c) 2013 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//

#import "SYMLTextElement.h"
#import "SYMLMarkdownParserAttributes.h"


@implementation SYMLTextElement


+ (instancetype)elementForURL:(NSURL *)url withRange:(NSRange)range
{
	if(!url)
		return nil;
	
	SYMLTextElement *element = [[SYMLTextElement alloc] init];
	element.type = SYMLTextLinkURLElement;
	element.URL = url;
	element.linkURLString = [url absoluteString];
	element.range = range;
	return element;
}

- (void)setContent:(id)content
{
	if([content isKindOfClass:[NSURL class]]) {
		[self willChangeValueForKey:@"URL"];
		_URL = content;
		[self didChangeValueForKey:@"URL"];
		
		content = [_URL absoluteString];
	}
	
	_content = content;
}


- (NSString *)description
{
	NSMutableString *description = [[super description] mutableCopy];
	[description appendFormat:@" %@ %@", NSStringFromRange(self.range), self.type];
	
	if([self.type isEqualToString:SYMLTextLinkElement])
		[description appendFormat:@" {name:'%@', tag:'%@' link:'%@'}", self.linkName ? : @"", self.linkTag ? : @"", self.linkURLString ? : @""];
	else if(self.URL)
		[description appendFormat:@" {url:%@}", self.URL];
	else if(self.content)
		[description appendFormat:@" {%@}", self.content];
	
	return [description copy];
}


@end
