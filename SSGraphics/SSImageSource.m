//
//  SSImageSource.m
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import "SSImageSource.h"

CGSize SSImageSourceGetPixelSize(CGImageSourceRef source) {
    CGSize size = CGSizeZero;
    if (source) {
        NSDictionary *properties = (__bridge NSDictionary *)SSAutorelease(CGImageSourceCopyPropertiesAtIndex(source, 0, (__bridge CFDictionaryRef)@{(__bridge NSString *)kCGImageSourceShouldCache : @YES, (__bridge NSString *)kCGImageSourceShouldAllowFloat : @YES}));
        if (properties) {
             size = CGSizeMake((CGFloat)[properties[(__bridge NSString *)kCGImagePropertyPixelWidth] doubleValue], (CGFloat)[properties[(__bridge NSString *)kCGImagePropertyPixelHeight] doubleValue]);
        }   
    }
    return size;
}

