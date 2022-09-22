//
//  CGColor.h
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SSDefines.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIColor.h>
#else
#import <AppKit/NSColor.h>
#endif

typedef CGColorRef SSColor;

CF_IMPLICIT_BRIDGING_ENABLED

CF_ASSUME_NONNULL_BEGIN

SS_EXPORT CGColorRef __nullable SSColorCreateWithPatternImage(CGImageRef CF_CONSUMED image, CGFloat scale) CF_RETURNS_RETAINED; //CF_SWIFT_NAME(SSColor.init(pattern:scale:));
SS_EXPORT CGColorRef __nullable SSColorCreateDeviceRGB(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) CF_RETURNS_RETAINED; //CF_SWIFT_NAME(SSColor.init(deviceRGB:_:_:_:));
SS_EXPORT CGColorRef __nullable SSColorCreateDeviceGray(CGFloat gray, CGFloat alpha) CF_RETURNS_RETAINED; //CF_SWIFT_NAME(SSColor.init(deviceGray:_:));
SS_EXPORT CGColorRef __nullable SSColorCreateWithString(NSString *string) CF_RETURNS_RETAINED; //CF_SWIFT_NAME(SSColor.init(string:));
SS_EXPORT CGColorRef __nullable SSColorCreateBlendedWithFractionOfColor(CGColorRef color, CGColorRef baseColor, CGFloat fraction) CF_RETURNS_RETAINED; //CF_SWIFT_NAME(SSColor.blended(self:base:fraction:));
SS_EXPORT CGColorRef __nullable SSColorCreateHighlightedWithLevel(CGColorRef color, CGFloat level) CF_RETURNS_RETAINED; //CF_SWIFT_NAME(SSColor.highlighted(self:level:));
SS_EXPORT CGColorRef __nullable SSColorCreateShadowedWithLevel(CGColorRef color, CGFloat level) CF_RETURNS_RETAINED; //CF_SWIFT_NAME(SSColor.shadowed(self:level:));
SS_EXPORT CGColorRef __nullable SSColorGetContrastingLabelColor(CGColorRef color) CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.contrasting(self:));
SS_EXPORT CGColorRef __nullable SSColorGetSystemColor(void) NS_AVAILABLE(10_5, NA) CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.system());
SS_EXPORT CGColorRef __nullable SSColorGetCurrentControlTintColor(void) NS_AVAILABLE(10_5, NA) CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.tint());
SS_EXPORT CGColorRef __nullable SSColorGetBlackColor(void) CF_SWIFT_UNAVAILABLE("") CF_RETURNS_NOT_RETAINED;
SS_EXPORT CGColorRef __nullable SSColorGetWhiteColor(void) CF_SWIFT_UNAVAILABLE("") CF_RETURNS_NOT_RETAINED;
SS_EXPORT CGColorRef __nullable SSColorGetClearColor(void) CF_SWIFT_UNAVAILABLE("") CF_RETURNS_NOT_RETAINED;
SS_EXPORT CGColorRef __nullable SSColorGetGrayColor(void) CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.gray());
SS_EXPORT CGColorRef __nullable SSColorGetLightGrayColor(void) CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.lightGray());
SS_EXPORT CGColorRef __nullable SSColorGetHighlightColor(void) CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.highligh());
SS_EXPORT CGColorRef __nullable SSColorGetShadowColor(void) CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.shadow());
SS_EXPORT CGColorRef __nullable SSColorGetRedColor(void) CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.red());
SS_EXPORT CGColorRef __nullable SSColorGetGreenColor(void) CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.green());
SS_EXPORT CGColorRef __nullable SSColorGetBlueColor(void) CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.blue());
SS_EXPORT const CGFloat * __nullable SSColorGetRGBComponents(CGColorRef color); //CF_SWIFT_NAME(getter:SSColor.rgbComponents(self:));
SS_EXPORT CGColorRef __nullable SSColorGetCGColor(id color) CF_SWIFT_UNAVAILABLE("") CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.color(self:));
SS_EXPORT NSString * __nullable SSColorGetStringRepresentation(CGColorRef color)CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.stringRepresentation(self:));
SS_EXPORT NSString * __nullable SSColorGetHexadecimalStringRepresentation(CGColorRef color)CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.hexadecimalStringRepresentation(self:));
SS_EXPORT CGColorRef __nullable SSColorShadowColorWithColor(CGColorRef color)CF_RETURNS_NOT_RETAINED; //CF_SWIFT_NAME(getter:SSColor.shadow(self:));
#if TARGET_OS_IPHONE
SS_EXPORT NSArray <UIColor *>*SSColorGetLabelColors(void);
#else
SS_EXPORT NSArray <NSColor *>*SSColorGetLabelColors(void);
#endif

CF_ASSUME_NONNULL_END

CF_IMPLICIT_BRIDGING_DISABLED
