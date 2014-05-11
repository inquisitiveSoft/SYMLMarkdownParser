//
//  MPEAppDelegate.h
//  Markdown Parser Example
//
//  Created by Harry Jordan on 09/05/2014.
//  Copyright (c) 2014 Harry Jordan. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//

#import <Cocoa/Cocoa.h>

@interface MPEAppDelegate : NSObject <NSApplicationDelegate, NSTextViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@end
