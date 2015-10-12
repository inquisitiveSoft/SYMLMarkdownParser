//
//  SYMLMarkdownParser-Internals.h
//  Syml
//
//  Created by Harry Jordan on 17/01/2013.
//  Copyright (c) 2013 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//

#import "SYMLMarkdownParserAttributes.h"
#import "SYMLAttributedObjectCollection.h"


typedef NS_ENUM(NSInteger, SYMLMarkdownParserLineType) {
	SYMLMarkdownParserLineTypeNormal,
	SYMLMarkdownParserLineTypeBlockquote,
	SYMLMarkdownParserLineTypeBlockcode,
	SYMLMarkdownParserLineTypeList,
	SYMLMarkdownParserLineTypeLink
};


struct SYMLMarkdownParserState {
	// Parse options
	NSInteger maximumRecursionDepth;
	BOOL shouldParseMarkdown;
	
	// Block elements
	BOOL shouldParseHeadings;
	BOOL shouldParseBlockquotes;
	BOOL shouldParseBlockcode;
	BOOL shouldParseHorizontalRule;
	BOOL shouldParseLists;
	
	// Inline elements
	BOOL shouldParseLinks;
	BOOL shouldParseEmphasisAndStrongTags;
	BOOL shouldParseHTMLTags;
	
	// Used internally to keep track of the parsing
	NSInteger textLength;
	NSRange searchRange;
	NSInteger currentRecursionDepth;
	
	// Cache respondToSelector: queries
	BOOL hasHeadingAttributes;
	BOOL hasHorizontalRuleAttributes;
	BOOL hasBlockquoteAttributes;
	BOOL hasListElementAttributes;
	BOOL hasListLineAttributes;
	BOOL hasEmphasisAttributes;
	BOOL hasStrongAttributes;
	BOOL hasLinkAttributes;
	BOOL hasLinkTitleAttributes;
	BOOL hasLinkTagAttributes;
	BOOL hasLinkURLAttributes;
	BOOL hasInvalidLinkAttributes;
	
	// The state that is passed on from state to state
	SYMLMarkdownParserLineType previousLineType;
};

typedef struct SYMLMarkdownParserState SYMLMarkdownParserState;


SYMLMarkdownParserState SYMLDefaultMarkdownParserState();
BOOL SYMLMarkdownParserStateInitialConditionsAreEqual(SYMLMarkdownParserState firstState, SYMLMarkdownParserState secondState);

// Returns the state after parsing has completed
SYMLMarkdownParserState SYMLParseMarkdown(NSString *inputString, id <SYMLAttributedObjectCollection> *result, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes);


