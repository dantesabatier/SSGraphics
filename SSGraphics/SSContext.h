//
//  SSContext.h
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
#import <CoreImage/CIContext.h>
#endif
#if TARGET_OS_IPHONE
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>
#endif
#import "SSGeometry.h"

typedef CGContextRef SSContext;

CF_ASSUME_NONNULL_BEGIN

SS_EXPORT CGContextRef SSContextGetCurrent(void);// CF_SWIFT_NAME(getter:SSContext.current());
SS_EXPORT void SSContextAddRoundedRect(CGContextRef c, CGRect rect, CGFloat cornerRadius);// CF_SWIFT_NAME(SSContext.addRoundedRect(self:_:_:));
SS_EXPORT void SSContextDrawGlowWithColor(CGContextRef c, CGPathRef path, CGColorRef color);// CF_SWIFT_NAME(SSContext.drawGlow(self:in:with:));
SS_EXPORT void SSContextDrawInnerShadowWithColor(CGContextRef c, CGPathRef path, CGColorRef color, CGSize offset, CGFloat blur);// CF_SWIFT_NAME(SSContext.drawInnerShadow(self:in:with:offset:blur:));
#if !TARGET_OS_WATCH
SS_EXPORT void SSContextDrawText(CGContextRef c, CFStringRef text,  CGRect rect, CFDictionaryRef attributes);// CF_SWIFT_NAME(SSContext.draw(self:text:in:with:));
SS_EXPORT void SSContextDrawTextAlignedInRect(CGContextRef c, CFStringRef text, CGRect rect, CTTextAlignment alignment, CTFontRef font, CGColorRef color);// CF_SWIFT_NAME(SSContext.draw(self:text:in:aligned:font:color:));
#endif
SS_EXPORT void SSContextDrawImage(CGContextRef c, CGImageRef image, CGRect rect, SSRectResizingMethod resizingMethod);// CF_SWIFT_NAME(SSContext.draw(self:image:in:using:));
SS_EXPORT void SSContextDrawLinearGradient(CGContextRef c, CGGradientRef gradient, CGRect rect, CGFloat angle);// CF_SWIFT_NAME(SSContext.drawLinearGradient(self:gradient:in:angle:));
SS_EXPORT void SSContextDrawGlossGradient(CGContextRef c, CGRect rect, bool vertically);// CF_SWIFT_NAME(SSContext.drawGlossGradient(self:in:vertically:));
SS_EXPORT void SSContextDrawGlossGradientWithColor(CGContextRef c, CGRect rect, CGColorRef color, bool vertically);// CF_SWIFT_NAME(SSContext.drawGlossGradient(self:in:with:vertically:));

CF_ASSUME_NONNULL_END
