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
#import "NSString+SubstringWithUntestedRange.h"


@implementation SYMLTextElement


+ (NSDataDetector *)linkDetector;
{
	static NSDataDetector *dataDetector = nil;
	static dispatch_once_t createDataDetector;
	dispatch_once(&createDataDetector, ^{
		NSTextCheckingTypes typesToDetect = NSTextCheckingTypeLink;
		dataDetector = [NSDataDetector dataDetectorWithTypes:typesToDetect error:nil];
	});
	
	return dataDetector;
}


+ (instancetype)elementForURL:(NSURL *)url withRange:(NSRange)range
{
	if(!url) {
		return nil;
	}
	
	SYMLTextElement *element = [[SYMLTextElement alloc] init];
	element.type = SYMLTextLinkURLElement;
	element.URL = url;
	element.linkURLString = [url absoluteString];
	element.range = range;
	return element;
}


- (id)copyWithZone:(NSZone *)zone
{
	SYMLTextElement *element = [[SYMLTextElement alloc] init];
	element.type = self.type;
	element.URL = self.URL;
	element.content = self.content;
	
	element.linkName = self.linkName;
	element.linkTag = self.linkTag;
	element.linkURLString = self.linkURLString;
	
	element.range = self.range;
	
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


- (void)setLinkURLString:(NSString *)linkURLString
{
	_linkURLString = linkURLString;

	// Try and parse a URL from the link string
	if(linkURLString.length && !self.URL) {
		NSTextCheckingResult *linkResult = [[SYMLTextElement linkDetector] firstMatchInString:linkURLString options:0 range:[linkURLString ajk_range]];
		self.URL =  linkResult.URL;
	}
}


- (NSString *)description
{
	NSMutableString *description = [[super description] mutableCopy];
	[description appendFormat:@" %@ %@", NSStringFromRange(self.range), self.type];
	
	if([self.type isEqualToString:SYMLTextLinkElement]) {
		[description appendFormat:@" {name:'%@', tag:'%@' link:'%@'}", self.linkName ? : @"", self.linkTag ? : @"", self.linkURLString ? : @""];
	} else if(self.URL) {
		[description appendFormat:@" {url:%@}", self.URL];
	} else if(self.content) {
		[description appendFormat:@" {%@}", self.content];
	}
	
	return [description copy];
}


- (SYMLTextElement *)elementWithOffset:(NSInteger)offset
{
	SYMLTextElement *element = [self copy];
	
	NSRange elementRange = self.range;
	elementRange.location += offset;
	element.range = elementRange;
	
	return element;
}

@end
