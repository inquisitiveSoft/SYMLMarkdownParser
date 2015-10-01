//
//  SYMLTextElementsCollection.m
//  Syml
//
//  Created by Harry Jordan on 17/01/2013.
//  Copyright (c) 2013 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//


#import "SYMLTextElementsCollection.h"

#import "SYMLMarkdownParser.h"
#import "SYMLTextElement.h"
#import "SYMLRangeFunctions.h"



@interface SYMLTextElementsCollection () {
	NSInteger elementIndex;
}

@property (readonly, nonatomic) NSString *textContent;
@property (strong, nonatomic) NSMutableArray *elements;
@property (strong, nonatomic) NSMutableAttributedString *mutableAttributedString;

@end



@implementation SYMLTextElementsCollection


- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	
	if(self) {
		_textContent = string;
		
		self.elements = [[NSMutableArray alloc] init];
	}
	
	return self;
}


- (instancetype)initWithAttributedString:(NSString *)string withAttributes:(NSDictionary *)attributes
{
	self = [super init];
	
	if(self) {
		_textContent = string;
		_mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
		
		self.elements = [[NSMutableArray alloc] init];
	}
	
	return self;
}


- (NSAttributedString *)attributedString
{
	return _mutableAttributedString;
}


- (void)addAttributes:(NSDictionary *)attributes range:(NSRange)range
{
	[_mutableAttributedString addAttributes:attributes range:range];
}


- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)range
{
	[_mutableAttributedString addAttribute:name value:value range:range];
}


- (void)markSectionAsElement:(NSString *)elementKey withContent:(id)content range:(NSRange)range
{
	if(![elementKey length]) {
		NSLog(@"-markSectionAsElement:withContent:range: requires an elementKey");
		return;
	}
	
	// Handle url sub-elements
	BOOL isLinkNameElement = [elementKey isEqualToString:SYMLTextLinkNameElement];
	BOOL isLinkTagElement = [elementKey isEqualToString:SYMLTextLinkTagElement];
	BOOL isLinkURLElement = [elementKey isEqualToString:SYMLTextLinkURLElement];
	
	if(isLinkNameElement || isLinkTagElement || isLinkURLElement) {
		BOOL foundExistingLink = FALSE;
		
		for(SYMLTextElement *element in [self.elements reverseObjectEnumerator]) {
			if([element.type isEqualToString:SYMLTextLinkElement] && NSIntersectionRange(element.range, range).length != 0) {
				
				if([content isKindOfClass:[NSString class]]) {
					if(isLinkNameElement) {
						element.linkName = content;
					} else if(isLinkTagElement) {
						element.linkTag = content;
					} else {
						element.linkURLString = content;
					}
				} else if(isLinkURLElement && [content isKindOfClass:[NSURL class]]) {
					element.URL = content;
				}
				
				// Expand the range of the element
				element.range = NSUnionRange(element.range, range);
				
				foundExistingLink = TRUE;
				break;
			}
		}
		
		if(!foundExistingLink && isLinkURLElement) {
			SYMLTextElement *element = [SYMLTextElement elementForURL:content withRange:range];
			
			if(element) {
				[self.elements addObject:element];
			}
		}
	} else {
		// Add the element to the array
		SYMLTextElement *element = [[SYMLTextElement alloc] init];
		element.type = elementKey;
		element.range = range;
		element.content = content;
		
		elementIndex = element.range.location;
		[self.elements addObject:element];
	}
}


- (NSArray *)allElements
{
	NSMutableArray *allElements = [[NSMutableArray alloc] initWithCapacity:[self.elements count]];
	
	for(SYMLTextElement *element in self.elements) {
		SYMLTextElement *adjustedElement = [element elementWithOffset:self.offset];
		[allElements addObject:adjustedElement];
	}
	
	[allElements sortUsingComparator:^NSComparisonResult(id firstObject, id secondObject) {
		SYMLTextElement *firstElement = firstObject;
		SYMLTextElement *secondElement = secondObject;
		
		if(firstElement.range.location == secondElement.range.location) {
			return NSOrderedSame;
		} else if(firstElement.range.location < secondElement.range.location) {
			return NSOrderedAscending;
		}
		
		return NSOrderedDescending;
	}];
	
	return allElements;
}


- (NSArray *)elementsMatchingTypes:(NSArray *)types
{
	if(!types || [types count] == 0) {
		return nil;
	}
	
	NSArray *elements = self.elements;
	NSMutableArray *matchingElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
	
	for(SYMLTextElement *element in elements) {
		for(NSString *elementType in types) {
			if([element.type isEqualToString:elementType]) {
				SYMLTextElement *adjustedElement = [element elementWithOffset:self.offset];
				[matchingElements addObject:adjustedElement];
				break;
			}
		}
	}
	
	
	[matchingElements sortUsingComparator:^NSComparisonResult(id firstObject, id secondObject) {
		SYMLTextElement *firstElement = firstObject;
		SYMLTextElement *secondElement = secondObject;
		
		if(firstElement.range.location == secondElement.range.location) {
			return NSOrderedSame;
		} else if(firstElement.range.location < secondElement.range.location) {
			return NSOrderedAscending;
		}
		
		return NSOrderedDescending;
	}];
	
	return [matchingElements copy];
}


- (NSArray *)elementsForRange:(NSRange)rangeToMatch
{
	// Adjust position to be relative to the start of the textSection's range
	rangeToMatch.location = MAX(0, rangeToMatch.location - self.offset);
	
	NSArray *elements = self.elements;
	NSMutableArray *matchingElements = [[NSMutableArray alloc] initWithCapacity:[elements count]];
	
	
	NSRangeIntersectionMode matchMode = rangeToMatch.length > 0 ? NSRangeIntersectionModeOverlap : NSRangeIntersectionModeEdges;
	
	for(SYMLTextElement *relativeElement in elements) {
		if(NSRangesIntersect(rangeToMatch, [relativeElement range], matchMode)) {
			SYMLTextElement *adjustedElement = [relativeElement elementWithOffset:self.offset];
			[matchingElements addObject:adjustedElement];
		}
	}
	
	[matchingElements sortUsingComparator:^NSComparisonResult(id firstObject, id secondObject) {
		SYMLTextElement *firstElement = firstObject;
		SYMLTextElement *secondElement = secondObject;
		
		if(firstElement.range.location == secondElement.range.location) {
			return NSOrderedSame;
		} else if(firstElement.range.location < secondElement.range.location) {
			return NSOrderedAscending;
		}
		
		return NSOrderedDescending;
	}];
	
	return [matchingElements copy];
}


@end
