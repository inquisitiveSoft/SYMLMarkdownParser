//
//  SYMLMarkdownParser-Internals.m
//  Syml
//
//  Created by Harry Jordan on 17/01/2013.
//  Copyright (c) 2013 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//

#import "SYMLMarkdownParser.h"
#import "SYMLMarkdownParser-Internals.h"

#import "RegexKitLite.h"
#import "NSString+SubstringWithUntestedRange.h"



SYMLMarkdownParserState SYMLDefaultMarkdownParserState()
{
	// Returns an SYMLMarkdownParserState struct set to the default state
	SYMLMarkdownParserState parseState = {0};
	parseState.shouldParseMarkdown = TRUE;
	parseState.maximumRecursionDepth = 7;
	
	// Block elements
	parseState.shouldParseHeadings = TRUE;
	parseState.shouldParseBlockquotes = TRUE;
	parseState.shouldParseBlockcode = TRUE;
	parseState.shouldParseHorizontalRule = TRUE;
	parseState.shouldParseLists = TRUE;
	
	// Inline elements
	parseState.shouldParseLinks = TRUE;
	parseState.shouldParseEmphasisAndStrongTags = TRUE;
	parseState.shouldParseHTMLTags = TRUE;
	
	return parseState;
}


BOOL SYMLMarkdownParserStateInitialConditionsAreEqual(SYMLMarkdownParserState firstState, SYMLMarkdownParserState secondState)
{
	BOOL isEqual =	firstState.shouldParseMarkdown == secondState.shouldParseMarkdown &&
					firstState.maximumRecursionDepth == secondState.maximumRecursionDepth &&
					
					// Block elements
					firstState.shouldParseHeadings == secondState.shouldParseHeadings &&
					firstState.shouldParseBlockquotes == secondState.shouldParseBlockquotes &&
					firstState.shouldParseBlockcode == secondState.shouldParseBlockcode &&
					firstState.shouldParseHorizontalRule == secondState.shouldParseHorizontalRule &&
					firstState.shouldParseLists == secondState.shouldParseLists &&
					
					// Inline elements
					firstState.shouldParseLinks == secondState.shouldParseLinks &&
					firstState.shouldParseEmphasisAndStrongTags == secondState.shouldParseEmphasisAndStrongTags &&
					firstState.shouldParseHTMLTags == secondState.shouldParseHTMLTags &&
					
					firstState.previousLineType == secondState.previousLineType;
	
	return isEqual;
}


SYMLMarkdownParserInlineState SYMLInitialParserInlineState()
{
	NSRange notFoundRange = NSMakeRange(NSNotFound, 0);
	
	SYMLMarkdownParserInlineState inlineState = {0};
	inlineState.linkLabel = notFoundRange;
	inlineState.linkDefinition = notFoundRange;
	inlineState.linkURL = notFoundRange;
	inlineState.linkTitle = notFoundRange;
	
	inlineState.emphasis = notFoundRange;
	inlineState.strong = notFoundRange;
	inlineState.htmlElement = notFoundRange;
	
	inlineState.precedingCharacter = 0;
	inlineState.characterBeforePrecedingCharacterIsWhitespace = FALSE;

	return inlineState;
}



#pragma mark - The exposed function


SYMLMarkdownParserState SYMLParseMarkdown(NSString *inputString,
									  id <SYMLAttributedObjectCollection> *outResult,
									  SYMLMarkdownParserState parseState,
									  id <SYMLMarkdownParserAttributes> attributes) {
	
	if(!inputString || [inputString length] == 0 || outResult == NULL || !parseState.shouldParseMarkdown) {
	   return parseState;
	}
	
	NSInteger increment = 0;
	
	// Set the initial internal parser state
	parseState.textLength = [inputString length];
	parseState.currentRecursionDepth = 0;
	
	// Cache which properties the attributes object provides
	parseState.hasHeadingAttributes = [attributes respondsToSelector:@selector(headingAttributes)];
	parseState.hasHorizontalRuleAttributes = [attributes respondsToSelector:@selector(horizontalRuleAttributes)];
	parseState.hasBlockquoteAttributes = [attributes respondsToSelector:@selector(blockquoteAttributes)];
	parseState.hasListAttributes = [attributes respondsToSelector:@selector(listAttributes)];
	parseState.hasEmphasisAttributes = [attributes respondsToSelector:@selector(emphasisAttributes)];
	parseState.hasStrongAttributes = [attributes respondsToSelector:@selector(strongAttributes)];
	parseState.hasLinkAttributes = [attributes respondsToSelector:@selector(linkAttributes)];
	parseState.hasLinkTitleAttributes = [attributes respondsToSelector:@selector(linkTitleAttributes)];
	parseState.hasLinkTagAttributes = [attributes respondsToSelector:@selector(linkTagAttributes)];
	parseState.hasLinkURLAttributes = [attributes respondsToSelector:@selector(urlAttributes)];
	parseState.hasInvalidLinkAttributes = [attributes respondsToSelector:@selector(invalidLinkAttributes)];
	
	return parseMarkdownBlockRecursively(inputString, outResult, parseState, attributes, &increment);
};



#pragma mark - Parser's core


SYMLMarkdownParserState parseMarkdownBlockRecursively(NSString *inputString, id <SYMLAttributedObjectCollection> *outResult, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *incrementToReturn)
{
	if(parseState.currentRecursionDepth >= parseState.maximumRecursionDepth) {
		return parseState;
	}
	
	while(parseState.searchRange.location < parseState.textLength) {
		parseState.searchRange = NSMakeRange(parseState.searchRange.location, parseState.textLength - parseState.searchRange.location);
		
		NSInteger increment = 0;
		SYMLMarkdownParserLineType lineType = SYMLMarkdownParserLineTypeNormal;
		
		if(parseState.previousLineType == SYMLMarkdownParserLineTypeNormal) {
			// Parse root level markdown elements
			// Each of the following functions are expected to leave the cursor at the start of the following line
			// They shouldn't expect to start at the beginning of a line
			if( !(parseState.shouldParseHeadings && SYMLParseMarkdownHeading(inputString, outResult, parseState, attributes, &increment, &lineType)) &&
				!(parseState.shouldParseBlockquotes && SYMLParseMarkdownBlockquotes(inputString, outResult, parseState, attributes, &increment, &lineType)) &&
				!(parseState.shouldParseBlockcode && SYMLParseMarkdownBlockcode(inputString, outResult, parseState, attributes, &increment, &lineType)) &&
				!(parseState.shouldParseHorizontalRule && SYMLParseMarkdownHorizontalRule(inputString, outResult, parseState, attributes, &increment, &lineType)) &&
				!(parseState.shouldParseLists && SYMLParseMarkdownList(inputString, outResult, parseState, attributes, &increment, &lineType)) &&
				!SYMLParseParagraph(inputString, outResult, parseState, attributes, &increment, &lineType)		// Parses inline elements like emphasis, bold and links
					) {
				NSLog(@"SYMLMarkdownParser: Couldn't find a rule to parse the text starting at the %@ range: %@…", NSStringFromRange(parseState.searchRange), [inputString ajk_substringWithUntestedRange:NSMakeRange(parseState.searchRange.location, 20)]);
				increment++;	// Increment the current position anyway to avoid an infinite loop
			}
		} else {
			// Handle any styles in the previous line that might bleed over into this one
			// currently blockquotes and link titles
			
			if(parseState.previousLineType == SYMLMarkdownParserLineTypeBlockquote) {
				SYMLParseContinuingBlockquote(inputString, outResult, parseState, attributes, &increment, &lineType);
			} else if(parseState.previousLineType == SYMLMarkdownParserLineTypeList) {
				// parseContinuingList ???
			} else if(parseState.previousLineType == SYMLMarkdownParserLineTypeLink) {
				SYMLParseTrailingLinkTitle(inputString, outResult, parseState, attributes, &increment, &lineType);
			}
		}
		
		
		// Setup the state for the next pass
		parseState.searchRange.location += increment;
		parseState.previousLineType = lineType;
	}
	
	if(incrementToReturn != NULL) {
		*incrementToReturn += parseState.searchRange.location;
	}
	
	return parseState;
}



#pragma mark - Parsing block elements

BOOL SYMLParseMarkdownHeading(NSString *inputString, id <SYMLAttributedObjectCollection> *outResult, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType) {
	__block NSRange formattingRange = NSMakeRange(parseState.searchRange.location, 0);
	__block NSInteger relativeIncrement = 0;
	__block NSInteger headingDepth = 0;
	
	NSCharacterSet *newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
	
	if([inputString rangeOfString:@"#" options:0 range:parseState.searchRange].location == parseState.searchRange.location) {
		// Match # hash style headings
		__block BOOL isHeader = FALSE;
		
		[inputString enumerateSubstringsInRange:parseState.searchRange options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			if([substring isEqualToString:@"#"]) {
				headingDepth++;
				
				// Don't recognise as a heading if there are more than 6 hashes
				isHeader = headingDepth <= 6;
			}
			
			if(isHeader) {
				relativeIncrement += enclosingRange.length;
				
				if([newlineCharacterSet characterIsMember:[substring characterAtIndex:0]]) {
					*stop = TRUE;
				} else {
					formattingRange.length += substringRange.length;
				}
			} else {
				relativeIncrement = 0;
				formattingRange.length = 0;
				*stop = TRUE;
			}
		}];
	} else if(parseState.searchRange.location > 0) {
		// Match --- or === style headings
		//	Translation of the ..DashOrEqualsHeadings regex:
		//		Starting at the beginning of the line, search for 3 or more -'s or ='s
		//		possibly followed by some spaces or tabs before reaching the end of the line
		
		NSString *regexToMatchDashOrEqualsHeadings = @"^((-{3,})|(={3,}))[ \\t]*?([\\r\\n]|$)";
		NSString *regexToMatchWordCharacters = @"\\w";
		
		NSRange underlineRange = [inputString rangeOfRegex:regexToMatchDashOrEqualsHeadings options:0 inRange:parseState.searchRange capture:0 error:NULL];
		
		if(underlineRange.location == parseState.searchRange.location) {
			[inputString enumerateSubstringsInRange:NSMakeRange(0, parseState.searchRange.location) options:NSStringEnumerationByLines | NSStringEnumerationReverse usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
				// Chech whether the previous line contains word characters
				if([substring rangeOfRegex:regexToMatchWordCharacters].location != NSNotFound) {
					// Add the range of the previous line to the range of the underline
					formattingRange.location -= enclosingRange.length;
					formattingRange.length += underlineRange.length + enclosingRange.length;
					relativeIncrement = underlineRange.length;
				}
				
				*stop = TRUE;
			}];
		}
	}
	
	
	// Apply any formatting
	if(formattingRange.length > 0) {
		[*outResult markSectionAsElement:SYMLTextHeaderElement withContent:nil range:formattingRange];
		
		if(parseState.hasHeadingAttributes) {
			[*outResult addAttributes:[attributes headingAttributes] range:formattingRange];
		}
	}
	
	if(relativeIncrement > 0) {
		if(increment != NULL) {
			*increment += relativeIncrement;
		}
		
		return TRUE;
	}
	
	return FALSE;
}



BOOL SYMLParseMarkdownHorizontalRule(NSString *inputString, id <SYMLAttributedObjectCollection> *outResult, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType) {
	// Heading trumps horizontal rule, horizontal rule trumps a list
	__block NSInteger formatLength = 0;
	__block NSInteger enclosingLength = 0;
	
	NSString *regexToMatchHorizontalRules = @"(^[ \\t]*(\\*([\\t ]*)){3,}[ \\t]*\n)|(^[ \\t]*(-([\\t ]*)){3,}[ \\t]*\n)";
	
	/*
		 OK.. lets break this down:
		 
			(	^[ \t]*				// Scan any spaces of tabs at the beginning of the line
				(\*([\t ]*)){3,}	// Match at least 3 asterisks *, optionally interspersed with spaces or tabs
				[ \t]*\n			// Finally match spaces or tabs to the end of the line
			) | (					// Otherwise..
				^[ \t]*				// do exactly the same
				(-([\t ]*)){3,}		// but searching for a dash - character
				[ \t]*\n
			)
		
		finally (for added obfuscation) \'s need to be escaped
	 */

	NSRange rangeOfHorizontalRule = [inputString rangeOfRegex:regexToMatchHorizontalRules
													  options:RKLMultiline
													  inRange:parseState.searchRange
													  capture:0 error:NULL];
	
	if(rangeOfHorizontalRule.location == parseState.searchRange.location) {
		formatLength = rangeOfHorizontalRule.length - 1;	// Don't format the trailing newline
		enclosingLength = rangeOfHorizontalRule.length;
	}
	
	if(formatLength > 0) {
		// Apply any formatting
		NSRange formattingRange = NSMakeRange(parseState.searchRange.location, formatLength);
		[*outResult markSectionAsElement:SYMLTextHorizontalRuleElement withContent:nil range:formattingRange];
		
		if(parseState.hasHorizontalRuleAttributes) {
			[*outResult addAttributes:[attributes horizontalRuleAttributes] range:formattingRange];
		}
	}
	
	if(increment != NULL) {
		*increment += enclosingLength;
	}
	
	return enclosingLength > 0;
}


BOOL SYMLParseMarkdownBlockquotes(NSString *inputString, id <SYMLAttributedObjectCollection> *outResult, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType) {
	// Look for blockquotes - paragraphs beginning with > characters
	NSString *regexToMatchBlockquoteLines = @"(^[ \\t]*>[> \\t]*)(.*\n?)";
	NSRange rangeOfBlockquote = [inputString rangeOfRegex:regexToMatchBlockquoteLines options:0 inRange:parseState.searchRange capture:1 error:NULL];
	
	if(rangeOfBlockquote.location != NSNotFound) {
		[*outResult markSectionAsElement:SYMLTextBlockquoteElement withContent:nil range:rangeOfBlockquote];
		
		if(parseState.hasBlockquoteAttributes) {
			[*outResult addAttributes:[attributes blockquoteAttributes] range:rangeOfBlockquote];
		}
		
		
		NSRange trailingRange = [inputString rangeOfRegex:regexToMatchBlockquoteLines options:0 inRange:parseState.searchRange capture:2 error:NULL];
		
		if(trailingRange.location != NSNotFound) {
			[*outResult markSectionAsElement:SYMLTextBlockquoteElement withContent:nil range:trailingRange];
			
			if(parseState.hasBlockquoteAttributes) {
				[*outResult addAttributes:[attributes blockquoteAttributes] range:trailingRange];
			}
			
			SYMLMarkdownParserState currentParseState = parseState;
			currentParseState.currentRecursionDepth++;
			currentParseState.shouldParseBlockquotes = FALSE;
			currentParseState.shouldParseHorizontalRule = FALSE;
			currentParseState.previousLineType = SYMLMarkdownParserLineTypeNormal;
			currentParseState.searchRange = trailingRange;
			parseMarkdownBlockRecursively(inputString, outResult, currentParseState, attributes, increment);
		}
		
		if(lineType != NULL) {
			*lineType = SYMLMarkdownParserLineTypeBlockquote;
		}
		
		if(increment != NULL) {
			*increment = NSMaxRange(trailingRange) - parseState.searchRange.location;
		}
		
		return TRUE;
	}
	
	return FALSE;
}



BOOL SYMLParseMarkdownBlockcode(NSString *inputString, id <SYMLAttributedObjectCollection> *outResult, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType) {
	return 0;		// ??
}



BOOL SYMLParseMarkdownList(NSString *inputString, id <SYMLAttributedObjectCollection> *outResult, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType) {
	// Look for an unnordered list
	NSRange rangeOfLine = [inputString rangeOfRegex:@"^.*\\n?" inRange:parseState.searchRange];
	
	if(rangeOfLine.location != NSNotFound) {
		NSString *regexToMatchListItems = @"^([ \\t]*)([-+\\*]|[0-9]+\\.)[ \\t]+";
		NSRange rangeOfListItem = [inputString rangeOfRegex:regexToMatchListItems options:0 inRange:rangeOfLine capture:0 error:NULL];
		
		if(rangeOfListItem.location != NSNotFound) {			
			// Apply any formatting
			[*outResult markSectionAsElement:SYMLTextListElement withContent:nil range:rangeOfListItem];
			
			if(parseState.hasListAttributes) {
				[*outResult addAttributes:[attributes listAttributes] range:rangeOfListItem];
			}
			
			SYMLMarkdownParserState currentParseState = parseState;
			currentParseState.searchRange = NSMakeRange(NSMaxRange(rangeOfListItem), NSMaxRange(rangeOfLine) - NSMaxRange(rangeOfListItem));
			currentParseState.textLength = NSMaxRange(rangeOfLine);
			currentParseState.currentRecursionDepth++;
			currentParseState.shouldParseHeadings = FALSE;
			currentParseState.shouldParseHorizontalRule = FALSE;
			currentParseState.shouldParseLists = FALSE;
			parseMarkdownBlockRecursively(inputString, outResult, currentParseState, attributes, NULL);
			
			if(lineType != NULL) {
				*lineType = SYMLMarkdownParserLineTypeList;
			}
			
			if(increment != NULL) {
				*increment += rangeOfLine.length;
			}
			
			return TRUE;
		}
	}
	
	return FALSE;
}


#pragma mark - Parse inline elements


BOOL SYMLParseParagraph(NSString *inputString, id <SYMLAttributedObjectCollection> *outResult, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType) {

	// This method enumerates through each character up to the end of the current line
	
	NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
	NSCharacterSet *newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
	NSCharacterSet *punctuationCharacterSet = [NSCharacterSet punctuationCharacterSet];
	
	static NSString * const SYMLMarkdownParserRegexToMatchLinkURL = @"(\\s*)?([\\S]*)";
	static NSString * const SYMLMarkdownParserRegexToMatchLinkTitle = @"(\\s*)?((\".*\")|('.*')|(\\(.*\\)))";
	static NSString * const SYMLMarkdownParserRegexToEndOfLine = @"^.*";
	
	
	NSInteger enclosingLength = 0;
	SYMLMarkdownParserInlineState inlineState = SYMLInitialParserInlineState();
	
	
	for(NSInteger characterIndex = parseState.searchRange.location; characterIndex < NSMaxRange(parseState.searchRange); characterIndex++) {
		/*
		 Parse inline elements on the given line
		 =======================================
		 
		 There are four rather large if..else blocks
		 
		 - The first parses link elements.
		 - The second parses emphasis and strong elements
		 - The third parses html style <tags>
		 - The fourth inserts the captured formatting attributes
		 
		 All state that needs to be used beyond the current character
		 should be encapsulated in the inlineState struct.
		 */
		
		unichar currentCharacter = [inputString characterAtIndex:characterIndex];
		BOOL isNewline = [newlineCharacterSet characterIsMember:currentCharacter];
		BOOL precedingCharacterIsWhitespace = inlineState.precedingCharacter != 0 && [whitespaceCharacterSet characterIsMember:inlineState.precedingCharacter];
		BOOL commitAppearance = isNewline || characterIndex == NSMaxRange(parseState.searchRange) - 1;
		
		
		// Parse link elements
		if(parseState.shouldParseLinks) {
			if(currentCharacter == '[' && inlineState.linkLabel.location == NSNotFound) {
				
				// Start a potential link element
				inlineState.linkLabel.location = characterIndex;
			
			} else if(inlineState.precedingCharacter == ']' && inlineState.linkLabel.location != NSNotFound) {
				inlineState.linkLabel.length = characterIndex - inlineState.linkLabel.location;
				
				if(inlineState.linkDefinition.location == NSNotFound
						&& (currentCharacter == '[' || currentCharacter == ':' || currentCharacter == '(')) {
					
					// Start the link element
					inlineState.linkDefinition.location = characterIndex;
					inlineState.linkDefinitionCharacter = currentCharacter;
					
					if(currentCharacter == ':') {
						// [id]: style elements extend to the end of the current line
						inlineState.linkDefinition.length = 1;
						
						NSRange remainingLineRange = NSMakeRange(characterIndex + 1, NSMaxRange(parseState.searchRange) - characterIndex - 1);
						remainingLineRange = [inputString rangeOfRegex:SYMLMarkdownParserRegexToEndOfLine inRange:remainingLineRange];
						enclosingLength += remainingLineRange.length;
						
						inlineState.linkURL = [inputString rangeOfRegex:SYMLMarkdownParserRegexToMatchLinkURL options:0 inRange:remainingLineRange capture:2 error:nil];
						
						remainingLineRange.location += inlineState.linkURL.length;
						remainingLineRange.length -= inlineState.linkURL.length;
						inlineState.linkTitle = [inputString rangeOfRegex:SYMLMarkdownParserRegexToMatchLinkTitle options:0 inRange:remainingLineRange capture:2 error:nil];
						
						if(inlineState.linkTitle.location == NSNotFound && lineType != NULL) {
							*lineType = SYMLMarkdownParserLineTypeLink;
						}
						
						commitAppearance = TRUE;
						isNewline = TRUE;
					}
				}
			} else if((currentCharacter == '[' || currentCharacter == '(')
				   && precedingCharacterIsWhitespace
				   && inlineState.linkLabel.location != NSNotFound
				   && inlineState.linkDefinition.location == NSNotFound
				   && characterIndex - 1 == NSMaxRange(inlineState.linkLabel)) {
				
				inlineState.linkDefinition.location = characterIndex;
				inlineState.linkDefinitionCharacter = currentCharacter;
				
			} else if(inlineState.linkDefinition.location != NSNotFound) {
				if(inlineState.linkDefinitionCharacter == '[' && currentCharacter == ']') {
					// Complete [link][] and [link][id] style elements
					inlineState.linkDefinition.length = characterIndex + 1 - inlineState.linkDefinition.location;
					commitAppearance = TRUE;
				} else if(inlineState.linkDefinitionCharacter == '(' && currentCharacter == ')') {
					// Complete [link](http://inquisitivesoftware.com "Title") style elements
					inlineState.linkDefinition.length = characterIndex + 1 - inlineState.linkDefinition.location;
					
					NSRange linkDefinitionContent = inlineState.linkDefinition;
					if(linkDefinitionContent.length > 2) {
						linkDefinitionContent.location++;
						linkDefinitionContent.length -= 2;
						inlineState.linkURL = [inputString rangeOfRegex:SYMLMarkdownParserRegexToMatchLinkURL options:0 inRange:linkDefinitionContent capture:2 error:nil];
						
						NSRange remainingLineRange;
						remainingLineRange.location = NSMaxRange(inlineState.linkURL);
						remainingLineRange.length = NSMaxRange(linkDefinitionContent) - remainingLineRange.location;
						inlineState.linkTitle = [inputString rangeOfRegex:SYMLMarkdownParserRegexToMatchLinkTitle options:0 inRange:remainingLineRange capture:2 error:nil];
					}
					commitAppearance = TRUE;
				}
				
			}
		}
		
		
		// Parse emphasis and strong elements
		if(parseState.shouldParseEmphasisAndStrongTags) {
			if(currentCharacter == '*' || currentCharacter == '_') {
				
				if(inlineState.precedingCharacter == currentCharacter) {
					// If the previous character was also a second * or _
					// upgrade from an emphasis element to a strong element
					
					if(inlineState.strong.location == NSNotFound) {
						inlineState.strong.location = characterIndex - 1;
						inlineState.strongCharacter = currentCharacter;
						
						if(inlineState.emphasis.location == characterIndex - 1) {
							inlineState.emphasis.location = NSNotFound;
							inlineState.emphasisCharacter = 0;
						}
					} else if(currentCharacter == inlineState.strongCharacter && !inlineState.characterBeforePrecedingCharacterIsWhitespace) {
						// Detect the closing character of a strong element
						inlineState.strong.length = characterIndex + 1 - inlineState.strong.location;
					}
					
					// If there are two trailing ** or __ then don't match as an emphasis tag
					inlineState.emphasis.length = 0;
					
				} else if(inlineState.emphasis.location == NSNotFound) {
					
					// Detect the start of a potential emphasis element
					if(!inlineState.precedingCharacter || precedingCharacterIsWhitespace) {
						inlineState.emphasis.location = characterIndex;
						inlineState.emphasisCharacter = currentCharacter;
					}
					
				} else if(currentCharacter == inlineState.emphasisCharacter && !precedingCharacterIsWhitespace) {
					// Detect the closing character of an emphasis element
					inlineState.emphasis.length = characterIndex + 1 - inlineState.emphasis.location;
				}
				
			} else if(isNewline || [whitespaceCharacterSet characterIsMember:currentCharacter] || [punctuationCharacterSet characterIsMember:currentCharacter]) {
				// Reset the emphasis or strong element if the * or _ characters are followed by a whitespace
				if(characterIndex - 1 == inlineState.emphasis.location) {
					inlineState.emphasis.location = NSNotFound;
					inlineState.emphasisCharacter = 0;
				} else if(characterIndex - 2 == inlineState.strong.location) {
					inlineState.strong.location = NSNotFound;
					inlineState.strongCharacter = 0;
				} else {
					commitAppearance = TRUE;
				}
			} else {
				// Require a trailing space after an * or _ character to complete the element
				inlineState.emphasis.length = 0;
				inlineState.strong.length = 0;
			}
		}
		
		
		// Parse html style tags
		if(parseState.shouldParseHTMLTags) {
			if(inlineState.htmlElement.location == NSNotFound && currentCharacter == '<') {
				inlineState.htmlElement.location = characterIndex;
			} else if(inlineState.htmlElement.location != NSNotFound && currentCharacter == '>') {
				inlineState.htmlElement.length = characterIndex + 1 - inlineState.htmlElement.location;
				commitAppearance = TRUE;
			}
		}
		
		
		// Apply the current state
		if(commitAppearance) {
			if(inlineState.linkLabel.length && inlineState.linkDefinition.length) {
				
				// A link element overides an emphasis or strong element
				NSRange labelRange;
				labelRange.location = inlineState.linkLabel.location;
				labelRange.length = NSMaxRange(inlineState.linkDefinition) - inlineState.linkLabel.location;
				
				// Draw the link element including all surrounding brackets [link][]
				[*outResult markSectionAsElement:SYMLTextLinkElement withContent:nil range:labelRange];
				
				if(parseState.hasLinkAttributes) {
					[*outResult addAttributes:[attributes linkAttributes] range:labelRange];
				}
				
				// Draw the contents of the first set of brackets [contents][]
				labelRange = inlineState.linkLabel;
				labelRange.location += 1;
				labelRange.length -= 2;
				if(labelRange.length > 0) {
					NSString *linkName = [inputString ajk_substringWithUntestedRange:labelRange];
					
					// the linkDefinition.length == 1 when parsing [tag]: url "title" style links
					NSString *elementType = (inlineState.linkDefinition.length == 1) ? SYMLTextLinkTagElement : SYMLTextLinkNameElement;
					[*outResult markSectionAsElement:elementType withContent:linkName range:labelRange];
					
					if(parseState.hasLinkTagAttributes) {
						[*outResult addAttributes:[attributes linkTagAttributes] range:labelRange];
					}
				}
				
				
				// Draw any content of the trailing [] or () brackets
				if(inlineState.linkDefinition.length > 2) {
					labelRange = inlineState.linkDefinition;
					labelRange.location += 1;
					labelRange.length -= 2;
					
					if(inlineState.linkURL.location != NSNotFound) {
						// If this is a [title](url) style link draw an error color which should be
						// overwritten by linkURL and linkTitle if the link format is valid
						if(parseState.hasInvalidLinkAttributes) {
							[*outResult addAttributes:[attributes invalidLinkAttributes] range:labelRange];
						}
					} else {
						// Otherwise draw the links tag [link][tag]
						if(parseState.hasLinkTagAttributes) {
							[*outResult addAttributes:[attributes linkTagAttributes] range:labelRange];
						}
						
						// Attach an attribute to quickly find this tag
						NSString *label = [inputString ajk_substringWithUntestedRange:labelRange];
						label = [[label lowercaseString] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
						
						if([label length]) {
							[*outResult markSectionAsElement:SYMLTextLinkTagElement withContent:label range:labelRange];
						}
					}
				}
								
				
				if(inlineState.linkDefinition.location != NSNotFound
					&& inlineState.linkDefinition.length == 1) {
					labelRange.location = NSMaxRange(inlineState.linkDefinition);
					labelRange.length = (parseState.searchRange.location + enclosingLength) - labelRange.location + 1;
					
					// If this is a [tag]: style link draw an error color which should be
					// overwritten by linkURL and linkTitle if the link format is valid
					if(labelRange.location < (parseState.searchRange.location + enclosingLength)) {
						if(parseState.hasInvalidLinkAttributes) {
							[*outResult addAttributes:[attributes invalidLinkAttributes] range:labelRange];
						}
					}
				}
				
				
				// Draw the link's url
				if(inlineState.linkURL.location != NSNotFound) {
					if(parseState.hasEmphasisAttributes) {
						[*outResult addAttributes:[attributes emphasisAttributes] range:inlineState.linkURL];
					}
					
					if(inlineState.linkURL.length) {
						if(parseState.hasLinkAttributes) {
							[*outResult addAttributes:[attributes linkAttributes] range:inlineState.linkURL];
						}
						
						if(parseState.hasLinkURLAttributes) {
							[*outResult addAttributes:[attributes urlAttributes] range:inlineState.linkURL];
						}
						
						// Attach an attribute to quickly find this url
						NSString *urlString = [inputString ajk_substringWithUntestedRange:inlineState.linkURL];
						urlString = [urlString stringByTrimmingCharactersInSet:whitespaceCharacterSet];
						
						[*outResult markSectionAsElement:SYMLTextLinkURLElement withContent:urlString range:NSUnionRange(inlineState.linkDefinition, inlineState.linkURL)];
					}
				}
				
				// Draw the link title
				if(inlineState.linkTitle.location != NSNotFound) {
					if(parseState.hasLinkTitleAttributes) {
						[*outResult addAttributes:[attributes linkTitleAttributes] range:inlineState.linkTitle];
					}
					
					NSRange titleRange = inlineState.linkTitle;
					titleRange.length -= 2;
					titleRange.location += 1;
					
					NSString *linkTitle = [inputString ajk_substringWithUntestedRange:titleRange];
					[*outResult markSectionAsElement:SYMLTextLinkNameElement withContent:linkTitle range:NSUnionRange(inlineState.linkDefinition, inlineState.linkTitle)];
				}
				
				
				// Reset the link parsing state
				NSRange notFoundRange = NSMakeRange(NSNotFound, 0);
				inlineState.linkLabel = notFoundRange;
				inlineState.linkDefinition = notFoundRange;
				inlineState.linkDefinitionCharacter = 0;
				inlineState.linkURL = notFoundRange;
				inlineState.linkTitle = notFoundRange;
																			
			} else if(inlineState.strong.location != NSNotFound && inlineState.strong.length) {
				if(parseState.hasStrongAttributes) {
					[*outResult addAttributes:[attributes strongAttributes] range:inlineState.strong];
				}
				
				inlineState.strong = NSMakeRange(NSNotFound, 0);
				inlineState.strongCharacter = 0;
			} else if(inlineState.emphasis.location != NSNotFound && inlineState.emphasis.length) {
				if(parseState.hasEmphasisAttributes) {
					[*outResult addAttributes:[attributes emphasisAttributes] range:inlineState.emphasis];
				}
				
				inlineState.emphasis = NSMakeRange(NSNotFound, 0);
				inlineState.emphasisCharacter = 0;
			} else if(inlineState.htmlElement.length) {
				
				// Style html elements
				if(parseState.hasEmphasisAttributes) {
					[*outResult addAttributes:[attributes emphasisAttributes] range:inlineState.htmlElement];
				}
				
//				SYMLTextFormatter parses these elements using an NSDataDescriptor
//
//				NSRange htmlElement = inlineState.htmlElement;
//				if(htmlElement.length > 2) {
//					htmlElement.location += 1;
//					htmlElement.length -= 2;
//					
//					NSString *itemString = [[inputString substringWithUntestedRange:htmlElement] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
//					
//					if([itemString isMatchedByRegex:SYMLMarkdownParserRegexToMatchURLs]) {
//						// SYMLTextLinkAttribute
////						[*outResult markSectionAsElement:SYMLTextLinkURLElement withContent:itemString range:htmlElement];
//					} else if([itemString isMatchedByRegex:SYMLMarkdownParserRegexToMatchEmailAddresses]) {
//						// SYMLEmailAttribute
////						[*outResult markSectionAsElement:SYMLTextEmailElement withContent:itemString range:htmlElement];
//					} else {
//						itemString = nil;
//					}
//
//					if(itemString) {
//						if(parseState.hasLinkAttributes) {
//							[*outResult addAttributes:[attributes linkAttributes] range:htmlElement];
//						}
//					}
//				}
				
				inlineState.htmlElement = NSMakeRange(NSNotFound, 0);
			}
		}
		
		inlineState.precedingCharacter = currentCharacter;
		inlineState.characterBeforePrecedingCharacterIsWhitespace = precedingCharacterIsWhitespace;
		
		enclosingLength++;
		
		if(isNewline) {
			break;
		}
	}
	
		
	if(enclosingLength > 0) {
		if(increment != NULL) {
			*increment += enclosingLength;
		}
		
		return TRUE;
	}
	
	return FALSE;
}



#pragma mark - Handle styles which might bleed over from the previous line


void SYMLParseContinuingBlockquote(NSString *inputString, id <SYMLAttributedObjectCollection> *outResult, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType)
{
	// If the given line starts with a > character then
	// let the standard blockquote parsing method catch it
	NSRange blockquoteRange = [inputString rangeOfRegex:@"^[ \\t]*>.*" inRange:parseState.searchRange];
	
	if(blockquoteRange.location == NSNotFound) {
		// And the line contains non whitespace characters
		NSRange lineRange = [inputString rangeOfRegex:@"^.*\\S.*\n?" inRange:parseState.searchRange];
		
		if(lineRange.location != NSNotFound) {
			// Apply the desired formatting
			if(parseState.hasBlockquoteAttributes) {
				[*outResult addAttributes:[attributes blockquoteAttributes] range:lineRange];
			}
			
			// Parse the blockquotes contents
			SYMLMarkdownParserState currentParseState = parseState;
			currentParseState.currentRecursionDepth++;
			currentParseState.shouldParseBlockquotes = FALSE;
			currentParseState.previousLineType = SYMLMarkdownParserLineTypeNormal;
			currentParseState.searchRange = lineRange;
			parseMarkdownBlockRecursively(inputString, outResult, currentParseState, attributes, NULL);
			
			if(lineType != NULL) {
				*lineType = SYMLMarkdownParserLineTypeBlockquote;
			}
			
			if(increment != NULL) {
				*increment += lineRange.length;
			}
		}
	}
	
}


void SYMLParseTrailingLinkTitle(NSString *inputString, id <SYMLAttributedObjectCollection> *outResultInput, SYMLMarkdownParserState parseState, id <SYMLMarkdownParserAttributes> attributes, NSInteger *increment, SYMLMarkdownParserLineType *lineType)
{
	/*
		Parses link titles that appear on the following line:
		
			[XKCD]: http://xkcd.com/
					"A geeky webcomic with a romantic heart"
	*/

	if(!parseState.shouldParseLinks) {
		return;
	}
	
	__block NSInteger formatLength = 0;
	__block NSInteger enclosingLength = 0;
	__weak id <SYMLAttributedObjectCollection> textInput = *outResultInput;

	[inputString enumerateSubstringsInRange:parseState.searchRange options:NSStringEnumerationByLines usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		NSRange linkTitleRange = [inputString rangeOfRegex:@"^\\s*((\".*\")|('.*')|(\\(.*\\)))\\s*$" options:0 inRange:substringRange capture:1 error:nil];
		
		if(linkTitleRange.location != NSNotFound) {
			formatLength = substringRange.length;
			enclosingLength = enclosingRange.length;
			
			// Style the line
			if(formatLength > 0 && parseState.hasBlockquoteAttributes) {
				[textInput addAttributes:[attributes blockquoteAttributes] range:linkTitleRange];
			}
		}
								
		*stop = TRUE;
	}];
	
	
	if(enclosingLength > 0) {
		*increment += enclosingLength;
	}
}
