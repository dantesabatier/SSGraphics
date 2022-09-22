//
//  SSColorSpace.m
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import "SSColorSpace.h"

NSString *const kSSColorSpaceDeviceRGB = @"kCGColorSpaceDeviceRGB";

static CGColorSpaceRef __SSColorSpaceDeviceRGB = NULL;
static CGColorSpaceRef __SSColorSpaceDeviceGray = NULL;

static BOOL _SSColorSpaceIsLoaded = NO;

__attribute__((constructor))
static void SSColorSpaceInit(void) {
    if (_SSColorSpaceIsLoaded) {
        return;
    }
    _SSColorSpaceIsLoaded = YES;
}

__attribute__((destructor))
static void SSColorSpaceDestroy(void) {
    CGColorSpaceRelease(__SSColorSpaceDeviceRGB);
    CGColorSpaceRelease(__SSColorSpaceDeviceGray);
}

CGColorSpaceRef SSColorSpaceGetDeviceRGB() {
    if (!__SSColorSpaceDeviceRGB) {
        __SSColorSpaceDeviceRGB = CGColorSpaceCreateDeviceRGB();
    }
    return __SSColorSpaceDeviceRGB;
}

CGColorSpaceRef SSColorSpaceGetDeviceGray() {
    if (!__SSColorSpaceDeviceGray) {
        __SSColorSpaceDeviceGray = CGColorSpaceCreateDeviceGray();
    }
    return __SSColorSpaceDeviceGray;
}
