//
//  SSString.m
//  SSGraphics
//
//  Created by Dante Palacios on 25/12/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import "SSString.h"
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

CGSize SSStringGetSizeWithFont(id string, id font) {
    CGSize stringSize = CGSizeZero;
    if ([string isKindOfClass:[NSAttributedString class]]) {
        string = [string string];
    }
    
#if TARGET_OS_IPHONE
#if defined(__IPHONE_7_0)
    stringSize = [string sizeWithAttributes:@{NSFontAttributeName:font}];
#else
    stringSize = [string sizeWithFont:font];
#endif
#else
    stringSize = [string sizeWithAttributes:@{NSFontAttributeName:font}];
#endif
    return stringSize;
}

CGSize SSStringGetSize(NSString *string, NSString *fontName, CGFloat fontSize) {
#if TARGET_OS_IPHONE
    return SSStringGetSizeWithFont(string, [UIFont fontWithName:fontName size:fontSize]);
#else
    return SSStringGetSizeWithFont(string, [NSFont fontWithName:fontName size:fontSize]);
#endif
}
