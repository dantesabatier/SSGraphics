//
//  SSImageSource.h
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <Foundation/Foundation.h>
#import "SSDefines.h"

typedef CGImageSourceRef SSImageSource;

CF_ASSUME_NONNULL_BEGIN

SS_EXPORT CGSize SSImageSourceGetPixelSize(CGImageSourceRef source) NS_REFINED_FOR_SWIFT; //CF_SWIFT_NAME(getter:SSImageSource.pixelSize());

CF_ASSUME_NONNULL_END
