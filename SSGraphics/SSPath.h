//
//  SSPath.h
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#if !TARGET_OS_WATCH
#import <CoreText/CoreText.h>
#endif
#import "SSGeometry.h"

typedef CGPathRef SSPath;

CF_ASSUME_NONNULL_BEGIN

CF_IMPLICIT_BRIDGING_ENABLED

SS_EXPORT CGPathRef __nullable SSPathCreateWithRect(CGRect rect, SSRectCorner rectCorners, CGFloat cornerRadius, const CGAffineTransform * __nullable transform) NS_REFINED_FOR_SWIFT; //CF_SWIFT_NAME(SSPath.init(_:_:_:_:)) CF_RETURNS_RETAINED;
SS_EXPORT CGPathRef __nullable SSPathCreateWithRoundedRect(CGRect rect, CGFloat cornerRadius, const CGAffineTransform * __nullable transform) NS_REFINED_FOR_SWIFT; //CF_SWIFT_NAME(SSPath.init(roundedRect:_:_:)) CF_RETURNS_RETAINED;
SS_EXPORT CGPathRef __nullable SSPathCreateWithArrow(CGRect rect, SSRectCorner rectCorners, CGFloat cornerRadius, CGSize arrowSize, SSRectPosition arrowPosition) NS_REFINED_FOR_SWIFT; //CF_SWIFT_NAME(SSPath.init(arrow:_:_:_:_:)) CF_RETURNS_RETAINED;

CF_IMPLICIT_BRIDGING_DISABLED

#if !TARGET_OS_WATCH
SS_EXPORT CGPathRef __nullable SSPathCreateWithString(CFStringRef string, CTFontRef font, const CGAffineTransform * __nullable transform) NS_REFINED_FOR_SWIFT; //CF_SWIFT_NAME(SSPath.init(string:_:_:)) CF_RETURNS_RETAINED;
#endif
SS_EXPORT CGPathRef __nullable SSPathCreateWithImage(CGImageRef image, const CGAffineTransform * __nullable transform) NS_REFINED_FOR_SWIFT; //CF_SWIFT_NAME(SSPath.init(image:_:)) CF_RETURNS_RETAINED NS_AVAILABLE(10_6, 5_0);

CF_ASSUME_NONNULL_END
