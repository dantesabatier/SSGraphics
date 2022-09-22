//
//  SSData.m
//  SSGraphics
//
//  Created by Dante Palacios on 28/01/17.
//  Copyright © 2017 Dante Palacios. All rights reserved.
//

#import "SSData.h"
#import "SSImageSource.h"

NSString * __nullable SSDataGetImageType(CFDataRef imageData) {
    return imageData ? (__bridge NSString *)CGImageSourceGetType(SSAutorelease(CGImageSourceCreateWithData(imageData, NULL))) : nil;
}

CGSize SSDataGetPixelSize(CFDataRef imageData) {
    return imageData ? SSImageSourceGetPixelSize(SSAutorelease(CGImageSourceCreateWithData(imageData, NULL))) : CGSizeZero;
}
