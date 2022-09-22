//
//  SSColorSpace.h
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SSDefines.h"

typedef CGColorSpaceRef SSColorSpace;

CF_ASSUME_NONNULL_BEGIN

CF_IMPLICIT_BRIDGING_ENABLED

SS_EXPORT CGColorSpaceRef __nullable SSColorSpaceGetDeviceRGB(void) NS_REFINED_FOR_SWIFT; //CF_SWIFT_NAME(getter:SSColorSpace.deviceRGB());
SS_EXPORT CGColorSpaceRef __nullable SSColorSpaceGetDeviceGray(void) NS_REFINED_FOR_SWIFT; //CF_SWIFT_NAME(getter:SSColorSpace.deviceGray());

CF_IMPLICIT_BRIDGING_DISABLED

SS_EXPORT NSString *const kSSColorSpaceDeviceRGB;

CF_ASSUME_NONNULL_END
