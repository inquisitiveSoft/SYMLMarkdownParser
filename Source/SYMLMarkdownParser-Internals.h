//
//  SYMLMarkdownParser-Internals.h
//  Markdown Parser Example
//
//  Created by Harry Jordan on 17/01/2013.
//  Copyright (c) 2013 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//


// Element keys
NSString * const SYMLTextStyleAttribute = @"SYMLTextStyleAttribute";

// Attributes to mark specific content
NSString * const SYMLTextHeaderElement = @"SYMLTextHeaderElement";
NSString * const SYMLTextHorizontalRuleElement = @"SYMLTextHorizontalRuleElement";
NSString * const SYMLTextBlockquoteElement = @"SYMLTextBlockquoteElement";
NSString * const SYMLTextListElement = @"SYMLTextListElement";

NSString * const SYMLTextLinkElement = @"SYMLTextLinkElement";
NSString * const SYMLTextLinkNameElement = @"SYMLTextLinkNameElement";
NSString * const SYMLTextLinkTagElement = @"SYMLTextLinkTagElement";
NSString * const SYMLTextLinkURLElement = @"SYMLTextLinkURLElement";

NSString * const SYMLTextEmailElement = @"SYMLTextEmailElement";
NSString * const SYMLTextDateElement = @"SYMLTextDateElement";
NSString * const SYMLTextAddressElement = @"SYMLTextAddressElement";
NSString * const SYMLTextPhoneNumberElement = @"SYMLTextPhoneNumberElement";

// Attributes that markdown parser uses to tag specific elements
NSString * const SYMLLinkTagAttribute = @"SYMLLinkTagAttribute";
NSString * const SYMLEmailAttribute = @"SYMLEmailAttribute";


// Only to be used internally
NSString * const SYMLMarkdownParserInlineStateAttribute = @"SYMLMarkdownParserInlineStateAttribute";


struct SYMLMarkdownParserInlineState {
	NSRange linkLabel;					//	the [link] label
	NSRange linkDefinition;				//	the trailing : [] or ()
	unichar linkDefinitionCharacter;	//	either '[' or '('
	
	NSRange linkURL;					//	the url section
	NSRange linkTitle;					//	any "title text" inside the () brackets or after the : label
	
	NSRange emphasis;
	unichar emphasisCharacter;			// either * or _
	
	NSRange strong;
	unichar strongCharacter;			// either * or _
	
	NSRange htmlElement;				// <html> style tags
	
	unichar precedingCharacter;
	BOOL characterBeforePrecedingCharacterIsWhitespace;
};


typedef struct SYMLMarkdownParserInlineState SYMLMarkdownParserInlineState;



#pragma mark - Define internal functions

SYMLMarkdownParserState parseMarkdownBlockRecursively(NSString *inputString, id <SYMLAttributedObjectCollection> *formattedText, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment);

	// Each of the following parse… functions are expected to increment the current position to the start of the following line
BOOL SYMLParseMarkdownHeading(NSString *inputString, id <SYMLAttributedObjectCollection> *formattedText, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType);
BOOL SYMLParseMarkdownHorizontalRule(NSString *inputString, id <SYMLAttributedObjectCollection> *formattedText, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType);
//BOOL SYMLParseMarkdownFencedCode(NSString *inputString, id <SYMLAttributedObjectCollection> *formattedText, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType);
BOOL SYMLParseMarkdownTable(NSString *inputString, id <SYMLAttributedObjectCollection> *formattedText, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType);
BOOL SYMLParseMarkdownBlockquotes(NSString *inputString, id <SYMLAttributedObjectCollection> *formattedText, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType);
BOOL SYMLParseMarkdownBlockcode(NSString *inputString, id <SYMLAttributedObjectCollection> *formattedText, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType);
BOOL SYMLParseMarkdownList(NSString *inputString, id <SYMLAttributedObjectCollection> *formattedText, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType);
BOOL SYMLParseParagraph(NSString *inputString, id <SYMLAttributedObjectCollection> *formattedText, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType);

// The following functions handle styles which might bleed over from the previous line
void SYMLParseContinuingBlockquote(NSString *inputString, id <SYMLAttributedObjectCollection> *formattedText, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType);
void SYMLParseTrailingLinkTitle(NSString *inputString, id <SYMLAttributedObjectCollection> *formattedText, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType);

SYMLMarkdownParserInlineState SYMLInitialParserInlineState();

