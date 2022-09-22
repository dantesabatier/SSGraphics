//
//  SSGradient.h
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SSDefines.h"

CF_ASSUME_NONNULL_BEGIN

typedef CGGradientRef SSGradient;

CF_IMPLICIT_BRIDGING_ENABLED

SS_EXPORT CGGradientRef __nullable SSGradientCreateProgressIndicatorGradientForControlTint(NSUInteger controlTint) CF_RETURNS_RETAINED; //CF_SWIFT_NAME(SSGradient.init(progress:));
SS_EXPORT CGGradientRef __nullable SSGradientGetProgressIndicatorGradientForControlTint(NSUInteger controlTint) CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(SSGradient.progress(for:));
SS_EXPORT CGGradientRef __nullable SSGradientGetDefaultProgressIndicatorGradient(void) CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSGradient.progress());

CF_IMPLICIT_BRIDGING_DISABLED

SS_EXPORT CGGradientRef __nullable SSGradientCreateWithColor(CGColorRef color) CF_RETURNS_RETAINED; //CF_SWIFT_NAME(SSGradient.init(color:));
SS_EXPORT CGGradientRef __nullable SSGradientCreateShadowWithColor(CGColorRef color) CF_RETURNS_RETAINED; //CF_SWIFT_NAME(SSGradient.shadow(color:));

CF_ASSUME_NONNULL_END
