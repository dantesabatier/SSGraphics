//
//  SSContext.m
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import "SSContext.h"
#import "SSColorSpace.h"
#import "SSPath.h"
#if !TARGET_OS_IPHONE
#import <AppKit/NSApplication.h>
#import <AppKit/NSGraphicsContext.h>
#endif

CGContextRef SSContextGetCurrent() {
    CGContextRef context = NULL;
#if TARGET_OS_IPHONE
    context = UIGraphicsGetCurrentContext();
#else
#if defined(__MAC_10_10)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        context = [NSGraphicsContext currentContext].CGContext;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
#pragma clang diagnostic pop
    }
#else
    context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
#endif
#endif
    return context;
}

void SSContextAddRoundedRect(CGContextRef c, CGRect rect, CGFloat cornerRadius) {
    if (!cornerRadius) {
        CGContextAddRect(c, rect);
    } else {
        CGPathRef path = SSPathCreateWithRoundedRect(rect, cornerRadius, NULL);
        CGContextAddPath(c, path);
        CGPathRelease(path);
    }
}

void SSContextDrawGlowWithColor(CGContextRef c, CGPathRef path, CGColorRef color) {
    CGContextSaveGState(c);
    {
        CGContextAddPath(c, path);
        CGContextSetBlendMode(c, kCGBlendModeOverlay);
        CGContextSetStrokeColorWithColor(c, color);
        CGContextSetLineWidth(c, 2.0);
        CGContextStrokePath(c);
    }
    CGContextRestoreGState(c);
}

void SSContextDrawInnerShadowWithColor(CGContextRef c, CGPathRef path, CGColorRef color, CGSize offset, CGFloat blur) {
    CGRect boundingRect = CGContextGetPathBoundingBox(c);
    CGRect outterRect = CGRectInset(boundingRect, -abs((int)offset.width) - blur, -abs((int)offset.height) - blur);
    
    CGColorSpaceRef space = SSColorSpaceGetDeviceRGB();
    const CGFloat shadowColorComponents[] = {0.0, 0.0, 0.0, 0.5};
    CGColorRef shadowColor = CGColorCreate(space, shadowColorComponents);
    
    CGContextSaveGState(c);
    {
        CGContextClip(c);
        CGContextBeginTransparencyLayer(c, NULL);
        {
            CGContextSaveGState(c);
            {
                CGContextAddPath(c, path);
                CGContextAddRect(c, outterRect);
                
                CGContextSetFillColorWithColor(c, shadowColor);
                CGContextSetShadowWithColor(c, offset, blur, color);
                CGContextEOFillPath(c);
                
            }
            CGContextRestoreGState(c);
        }
        CGContextEndTransparencyLayer(c);
    }
    CGContextRestoreGState(c);
    
    CGColorRelease(shadowColor);
}

#if !TARGET_OS_WATCH


void SSContextDrawText(CGContextRef c, CFStringRef text,  CGRect rect, CFDictionaryRef attributes) {
    CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, text, attributes);
    if (attrString) {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
        if (framesetter) {
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathAddRect(path, NULL, rect);
            
            CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, CFAttributedStringGetLength(attrString)), path, NULL);
            if (frame) {
                CTFrameDraw(frame, c);
                CFRelease(frame);
            }
            
            CGPathRelease(path);
            CFRelease(framesetter);
        }
        
        CFRelease(attrString);
    }
}

void SSContextDrawTextAlignedInRect(CGContextRef c, CFStringRef text, CGRect rect, CTTextAlignment alignment, CTFontRef font, CGColorRef color)  {
	size_t settingCount = 1;
	CTParagraphStyleSetting settings[1] = {{kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment}};
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, settingCount);
	
	CFIndex numValues = 3;
	CFStringRef keys[3] = {kCTFontAttributeName, kCTForegroundColorAttributeName, kCTParagraphStyleAttributeName};
	CFTypeRef values[3] = {font, color, paragraphStyle};
	CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, numValues, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	
	CFRelease(paragraphStyle);

	SSContextDrawText(c, text, rect, attributes);
	
	CFRelease(attributes);
}

#endif

void SSContextDrawImage(CGContextRef c, CGImageRef image, CGRect rect, SSRectResizingMethod resizingMethod) {
    if (image) {
        CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image));
        CGRect bounds = SSRectMakeWithAspectRatioInsideRect(imageRect, rect, resizingMethod);
        switch (resizingMethod) {
            case SSRectResizingMethodScale:
                CGContextDrawImage(c, bounds, image);
                break;
            default: {
                CGImageRef img = CGImageCreateWithImageInRect(image, bounds);
                CGContextDrawImage(c, rect, img);
                CGImageRelease(img);
            }
                break;
        }
    }
}

void SSContextDrawLinearGradient(CGContextRef c, CGGradientRef gradient, CGRect rect, CGFloat angle) {
    NSCParameterAssert(gradient);
    CGPoint startPoint;
    CGPoint endPoint;
    SSRectGetDrawingPointsForAngle(rect, angle, &startPoint, &endPoint);
    CGContextDrawLinearGradient(c, gradient, startPoint, endPoint, 0);
}

void SSContextDrawGlossGradient(CGContextRef c, CGRect rect, bool vertically) {
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGRect fillRect = vertically ? CGRectIntegral(CGRectMake(CGRectGetMinX(rect) + (CGRectGetWidth(rect)*(CGFloat)0.5), CGRectGetMinY(rect), CGRectGetWidth(rect)*(CGFloat)0.5, CGRectGetHeight(rect))) : CGRectIntegral(CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + (CGRectGetHeight(rect)*(CGFloat)0.5), CGRectGetWidth(rect), CGRectGetHeight(rect)*(CGFloat)0.5));
    CGContextSaveGState(c);
    {
        CGContextSaveGState(c);
        {
            CGContextSetBlendMode(c, kCGBlendModeOverlay);
            CGContextBeginTransparencyLayerWithRect(c, fillRect, NULL);
            {
                const CGFloat components[] = {1.0, 1.0, 1.0, 0.47, 0.0, 0.0, 0.0, 0.0};
                const CGFloat locations[] = {1, 0};
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
                CGContextDrawLinearGradient(c, gradient, CGPointZero, vertically ? CGPointMake(CGRectGetMaxX(rect), 0) : CGPointMake(0, CGRectGetMaxY(rect)), 0);
                CGGradientRelease(gradient);
            }
            CGContextEndTransparencyLayer(c);
            
            CGContextSetBlendMode(c, kCGBlendModeSoftLight);
            CGContextBeginTransparencyLayer(c, NULL);
            {
                const CGFloat shadowComponents[] = {0.0, 0.0, 0.0, 0.56, 0.0, 0.0, 0.0, 0.0};
                CGColorRef shadowColor = CGColorCreate(colorSpace, shadowComponents);
                CGContextSaveGState(c);
                {
                    CGContextSetShadowWithColor(c, CGSizeMake(0.0, -1.0), 4.0, shadowColor);
                    CGContextFillRect(c, fillRect);
                    CGColorRelease(shadowColor);
                }
                CGContextRestoreGState(c);
                CGContextSetBlendMode(c, kCGBlendModeClear);
                CGContextFillRect(c, fillRect);
            }
            CGContextEndTransparencyLayer(c);
        }
        CGContextRestoreGState(c);
    }
    CGContextRestoreGState(c);
}

void SSContextDrawGlossGradientWithColor(CGContextRef c, CGRect rect, CGColorRef color, bool vertically) {
    NSCParameterAssert(color);
    CGContextSetFillColorWithColor(c, color);
    CGContextFillRect(c, rect);
    SSContextDrawGlossGradient(c, rect, vertically);
}
