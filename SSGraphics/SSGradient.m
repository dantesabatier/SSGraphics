//
//  SSGradient.m
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import <TargetConditionals.h>
#import "SSGradient.h"
#import "SSColor.h"
#import "SSColorSpace.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/NSColor.h>
#endif

CGGradientRef SSGradientCreateProgressIndicatorGradientForControlTint(NSUInteger controlTint) {
    NSArray *colors = nil;
    switch (controlTint) {
        case 6:
            colors = @[(__bridge id)SSAutorelease(SSColorCreateDeviceRGB(0.160, 0.160, 0.160, 1.0)), (__bridge id)SSAutorelease(SSColorCreateDeviceRGB(0.460, 0.460, 0.460, 1.0))];
            break;
        default:
            colors = @[(__bridge id)SSAutorelease(SSColorCreateDeviceRGB(0.000, 0.530, 0.870, 1.0)), (__bridge id)SSAutorelease(SSColorCreateDeviceRGB(0.000, 0.310, 0.780, 1.0))];
            break;
    }
    
    return CGGradientCreateWithColors(SSColorSpaceGetDeviceRGB(), (__bridge CFArrayRef)colors, (const CGFloat[]){0.0, 1.0});
}

CGGradientRef SSGradientGetProgressIndicatorGradientForControlTint(NSUInteger controlTint) {
    return SSAutorelease(SSGradientCreateProgressIndicatorGradientForControlTint(controlTint));
}

CGGradientRef SSGradientGetDefaultProgressIndicatorGradient() {
    NSUInteger currentControlTint = 1;
#if !TARGET_OS_IPHONE
    currentControlTint = [NSColor currentControlTint];
#endif
    return SSGradientGetProgressIndicatorGradientForControlTint(currentControlTint);
}

CGGradientRef SSGradientCreateWithColor(CGColorRef color) {
    if (color) {
        return CGGradientCreateWithColors(SSColorSpaceGetDeviceRGB(), (__bridge CFArrayRef)@[(__bridge id)SSAutorelease(SSColorCreateShadowedWithLevel(color, 0.1)), (__bridge id)SSAutorelease(SSColorCreateHighlightedWithLevel(color, 0.6))], (const CGFloat[]){0.0, 1.0});
    }
    return NULL;
}

CGGradientRef SSGradientCreateShadowWithColor(CGColorRef color) {
    if (color) {
        CGColorRef shadowColor = SSColorShadowColorWithColor(color);
        const CGFloat *components = CGColorGetComponents(shadowColor);
        return CGGradientCreateWithColorComponents(SSColorSpaceGetDeviceRGB(), (const CGFloat[]){components[0], components[1], components[2], 0.0, components[0], components[1], components[2], 0.33}, (const CGFloat[]){0, 1}, 2);
    }
    return NULL;
}
