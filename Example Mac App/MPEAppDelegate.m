//
//  MPEAppDelegate.m
//  Markdown Parser Example
//
//  Created by Harry Jordan on 09/05/2014.
//  Copyright (c) 2014 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//

#import "MPEAppDelegate.h"
#import "SYMLMarkdownTextFormatter-Mac.h"



@implementation MPEAppDelegate


- (void)awakeFromNib
{
	self.textView.delegate = self;
	self.textView.textContainerInset = NSMakeSize(60.0, 35.0);
	self.textView.backgroundColor = [NSColor colorWithCalibratedRed:0.921 green:0.917 blue:0.897 alpha:1.0];
	
	NSURL *exampleDocumentURL = [[NSBundle mainBundle] URLForResource:@"README" withExtension:@"md"];
	NSString *exampleText = [NSString stringWithContentsOfURL:exampleDocumentURL  usedEncoding:NULL error:NULL];
	
	self.textView.string = exampleText;
	[self applySyntaxHighlighting];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
	return YES;
}


- (void)textDidChange:(NSNotification *)notification
{
	[self applySyntaxHighlighting];
}


- (void)applySyntaxHighlighting
{
	SYMLMarkdownTextFormatter *textFormatter = [[SYMLMarkdownTextFormatter alloc] init];
	
	NSString *text = self.textView.string;
	NSAttributedString *attributedString = [textFormatter formatString:text];
	
	[self.textView.textStorage setAttributedString:attributedString];
}


@end
