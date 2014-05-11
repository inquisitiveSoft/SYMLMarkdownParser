//
//  Markdown_Parser_ExampleTests.m
//  Markdown Parser ExampleTests
//
//  Created by Harry Jordan on 09/05/2014.
//  Copyright (c) 2014 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//

#import <XCTest/XCTest.h>
#import "SYMLMarkdownParser.h"


@interface Markdown_Parser_ExampleTests : XCTestCase

@end



@implementation Markdown_Parser_ExampleTests

- (void)setUp
{
    [super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testNullInputs
{
	// Parsing without any input
	SYMLMarkdownParserState parseState = {0};
	SYMLParseMarkdown(NULL, NULL, parseState, NULL);
	
	// Test without an attributed collection to parse into
	NSURL *exampleDocumentURL = [[NSBundle mainBundle] URLForResource:@"README" withExtension:@"md"];
	NSString *exampleText = [NSString stringWithContentsOfURL:exampleDocumentURL  usedEncoding:NULL error:NULL];
	
	parseState = SYMLDefaultMarkdownParserState();
	SYMLParseMarkdown(exampleText, NULL, parseState, NULL);
}


- (void)testSpeed
{
	NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
	
	NSTimeInterval finish = [NSDate timeIntervalSinceReferenceDate];
	NSLog(@"duration: %f", finish - start);
}



@end
