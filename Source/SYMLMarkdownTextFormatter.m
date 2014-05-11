//
//  SYMLMarkdownTextFormatter.m
//  Syml
//
//  Created by Harry Jordan on 17/01/2013.
//  Copyright (c) 2013 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//


#import "SYMLMarkdownTextFormatter.h"
#import "SYMLMarkdownParser.h"

#import "SYMLAttributedObjectCollection.h"
#import "SYMLTextElementsCollection.h"

#import "NSMutableAttributedString+RangeForAttributedString.h"

#include "TargetConditionals.h"
@import CoreText;



@implementation SYMLMarkdownTextFormatter


- (instancetype)init
{
	self = [super init];
	
	if(self) {
		NSFont *baseFont = [NSFont fontWithName:@"Menlo" size:14.0];
		NSFont *headingFont = [NSFont fontWithName:@"Menlo Bold" size:18.0];
		NSFont *boldFont = [NSFont fontWithName:@"Menlo Bold" size:14.0];

		NSMutableParagraphStyle *baseParagraphStyle = [[NSMutableParagraphStyle alloc] init];
		baseParagraphStyle.lineHeightMultiple = 1.25;
	
		NSMutableParagraphStyle *headingParagraphStyle = [[NSMutableParagraphStyle alloc] init];
		headingParagraphStyle.lineHeightMultiple = 1.6;
		headingParagraphStyle.lineSpacing = 8.0;
	
		
		_baseAttributes = @{
			NSFontAttributeName							: baseFont,
			NSForegroundColorAttributeName				: [NSColor colorWithCalibratedRed:0.3 green:0.3 blue:0.3 alpha:1],
			NSParagraphStyleAttributeName				: baseParagraphStyle
		};
	
		_headingAttributes = @{
			NSFontAttributeName							: headingFont,
			NSForegroundColorAttributeName				: [NSColor colorWithCalibratedRed:0.089 green:0.547 blue:0.695 alpha:1.0],
			NSParagraphStyleAttributeName				: headingParagraphStyle
		};
	
		_horizontalRuleAttributes = @{
			NSFontAttributeName							: baseFont,
			NSForegroundColorAttributeName				: [NSColor colorWithCalibratedRed:0.010 green:0.157 blue:0.430 alpha:1.0]
		};
	
		_blockquoteAttributes = @{
			NSFontAttributeName							: baseFont,
			NSForegroundColorAttributeName				: [NSColor colorWithCalibratedRed:0.537 green:0.275 blue:0.140 alpha:1.0]
		};
	
		_listAttributes = @{
			NSFontAttributeName							: baseFont,
			NSForegroundColorAttributeName				: [NSColor colorWithCalibratedRed:0.207 green:0.549 blue:0.69 alpha:1.0]
		};
	
		_linkAttributes = @{
			NSFontAttributeName							: baseFont,
			NSForegroundColorAttributeName				: [NSColor colorWithCalibratedRed:0.010 green:0.157 blue:0.430 alpha:1.0]
		};
		
		_urlAttributes = @{
		   NSFontAttributeName							: baseFont,
		   NSForegroundColorAttributeName				: [NSColor colorWithCalibratedRed:0.55 green:0.55 blue:0.3 alpha:1.0],
		   NSUnderlineStyleAttributeName				: @(NSUnderlineStyleSingle)
		};
	
		_emphasisAttributes = @{
			NSFontAttributeName							: baseFont,
			NSForegroundColorAttributeName				: [NSColor colorWithCalibratedRed:0.227 green:0.381 blue:0.063 alpha:1.0]
		};

		_strongAttributes = @{
			NSFontAttributeName							: boldFont,
			NSForegroundColorAttributeName				: [NSColor colorWithCalibratedRed:0.227 green:0.381 blue:0.063 alpha:1.0]
		};
	}
	
	return self;
}


#pragma mark -

- (NSAttributedString *)formatString:(NSString *)inputString
{
	NSMutableAttributedString *formattedText = [[NSMutableAttributedString alloc] initWithString:inputString attributes:[self baseAttributes]];
	[self parseString:inputString intoAttributedCollection:&formattedText];
	
	return formattedText;
}


- (NSAttributedString *)formatString:(NSString *)inputString elements:(SYMLTextElementsCollection **)textElements
{
	SYMLTextElementsCollection *attributesCollection = [[SYMLTextElementsCollection alloc] initWithAttributedString:inputString withAttributes:[self baseAttributes]];
	[self parseString:inputString intoAttributedCollection:&attributesCollection];
	
	if(textElements != NULL) {
		*textElements = attributesCollection;
	}
	
	return [attributesCollection attributedString];
}



- (SYMLTextElementsCollection *)elementsFromString:(NSString *)inputString
{
	SYMLTextElementsCollection *attributesCollection = [[SYMLTextElementsCollection alloc] initWithString:inputString];
	[self parseString:inputString intoAttributedCollection:&attributesCollection];
	
	return attributesCollection;
}



#pragma mark - Parsing the markdown


- (BOOL)parseString:(NSString *)inputString intoAttributedCollection:(id <SYMLAttributedObjectCollection> *)attributesCollection
{
	if(!attributesCollection || !inputString || [inputString length] == 0)
		return FALSE;
	
	
	SYMLMarkdownParserState parseState = SYMLDefaultMarkdownParserState();
	
	// Set any custom parser options here
	
	SYMLParseMarkdown(inputString, attributesCollection, parseState, self);
	
	return TRUE;
}


@end


