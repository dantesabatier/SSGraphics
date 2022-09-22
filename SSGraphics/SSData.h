//
//  SSData.h
//  SSGraphics
//
//  Created by Dante Palacios on 28/01/17.
//  Copyright © 2017 Dante Palacios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SSDefines.h"

CF_ASSUME_NONNULL_BEGIN

typedef CFDataRef SSData;

SS_EXPORT NSString * __nullable SSDataGetImageType(CFDataRef imageData);// CF_SWIFT_NAME(getter:SSData.imageType(self:));
SS_EXPORT CGSize SSDataGetPixelSize(CFDataRef imageData);// CF_SWIFT_NAME(getter:SSData.pixelSize(self:));

CF_ASSUME_NONNULL_END
