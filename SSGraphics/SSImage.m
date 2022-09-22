//
//  SSImage.m
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import <TargetConditionals.h>
#import "SSImage.h"
#import "SSColor.h"
#import "SSColorSpace.h"
#import "SSString.h"
#import "SSPath.h"
#import "SSGradient.h"
#import "SSContext.h"
#if !TARGET_OS_WATCH
#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVFoundation.h>
#endif
#if TARGET_OS_IPHONE
#import <UIKit/UIImage.h>
#else
#import <AppKit/NSImage.h>
#import <AppKit/NSGraphicsContext.h>
#endif
#import <objc/objc-sync.h>
#import "CIContext+SSAdditions.h"

bool SSImageWriteToURL(CGImageRef image, CFURLRef url, CFDictionaryRef properties) {
    bool result = false;
    if (image && url) {
        NSString *pathExtension = (__bridge NSString *)SSAutorelease(CFURLCopyPathExtension(url));
        if (pathExtension.length) {
            CFStringRef imageType = SSAutorelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)pathExtension, NULL));
            if (imageType) {
                static const size_t maximumNumberOfImages = 10;
                static const size_t minimumNumberOfImages = 1;
                size_t count = UTTypeEqual(imageType, kUTTypeAppleICNS) ? maximumNumberOfImages : minimumNumberOfImages;
                CGImageDestinationRef dest = SSAutorelease(CGImageDestinationCreateWithURL(url, imageType, count, NULL));
                if (dest) {
                    switch (count) {
                        case maximumNumberOfImages: {
                            NSArray <NSNumber *>*sizes = @[@16.0, @32.0, @32.0, @64.0, @128.0, @256.0, @256.0, @512.0, @512.0, @1024.0];
                            for (NSNumber *size in sizes) {
                                CGImageDestinationAddImage(dest, SSAutorelease(SSImageCreateCopyWithSize(image, SSSizeMakeSquare(size.floatValue), SSRectResizingMethodScale)), properties);
                            }
                        }
                            break;
                        default:
                            CGImageDestinationAddImage(dest, image, properties);
                            break;
                    }
                    result = CGImageDestinationFinalize(dest);
                } else {
                    SSDebugLog(@"SSImageWriteToURL(%@, %@, %@) Failed! (CGImageDestinationRef) ", image, url, properties);
                }
            } else {
                SSDebugLog(@"SSImageWriteToURL(%@, %@, %@) Failed! (imageType) ", image, url, properties);
            }
        } else {
            SSDebugLog(@"SSImageWriteToURL(%@, %@, %@) Failed! (pathExtension) ", image, url, properties);
        }
    } else {
        SSDebugLog(@"SSImageWriteToURL(%@, %@, %@) Failed!", image, url, properties);
    }
    
    return result;
}

bool SSImageWriteToPath(CGImageRef image, NSString *path, CFDictionaryRef properties) {
    return SSImageWriteToURL(image, (__bridge CFURLRef)[NSURL fileURLWithPath:path], properties);
}

#if NS_BLOCKS_AVAILABLE

CGImageRef SSImageCreate(CGSize size, void (^drawingHandler)(CGContextRef ctx)) {
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, (size_t)size.width, (size_t)size.height, 8, (size_t)size.width * 4, colorSpace, kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    if (drawingHandler) {
        drawingHandler(ctx);
    }
    CGImageRef image = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return image;
}

#endif

CGImageRef SSImageCreateWithImageResourceNamedInBundle(NSBundle *bundle, NSString *imageName) {
    if (bundle) {
        NSString *path = nil;
#if TARGET_OS_IPHONE
        if (imageName.length) {
            NSString *extension = imageName.pathExtension;
            if (extension.length) {
                path = [bundle pathForResource:imageName.stringByDeletingPathExtension ofType:extension];
            } else {
                NSArray *imageTypes = (__bridge NSArray *)SSAutorelease(CGImageDestinationCopyTypeIdentifiers());
                for (NSString *imageType in imageTypes) {
                    if ((path = [bundle pathForResource:imageName ofType:(__bridge NSString *)SSAutorelease(UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)imageType, kUTTagClassFilenameExtension))])) {
                        break;
                    }
                }
            }
        }
#else
        path = [bundle pathForImageResource:imageName];
#endif
        if (path) {
            id image = nil;
#if TARGET_OS_IPHONE
            image = [UIImage imageWithContentsOfFile:path];
            if (!image) {
                CFStringRef imageType = SSAutorelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)path.pathExtension, NULL));
                if (UTTypeConformsTo(imageType, kUTTypePDF)) {
                    CGPDFDocumentRef document = SSAutorelease(CGPDFDocumentCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path]));
                    if (document) {
                        CGImageRef cgImage = SSAutorelease(SSImageCreateWithCGPDFDocument(document, 1, 72.0));
                        if (cgImage) {
                            image = [UIImage imageWithCGImage:cgImage];
#if defined(__IPHONE_7_0)
                            if ([imageName hasSuffix:@"Template"]) {
                                image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                            }
#endif
                        }
                    }
                }
            }
#else
            image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
            if ([imageName hasSuffix:@"Template"]) {
                ((NSImage*)image).template = YES;
            }  
#endif
            if (image) {
                return CGImageCreateCopy(SSImageGetCGImage(image));
            }
        }
#if 1
        if (imageName.length) {
            SSDebugLog(@"SSImageCreateWithImageResourceNamedInBundle(%@, %@), Warning!, image not found…", bundle.bundleIdentifier, imageName);
        }
#endif
    }
	return NULL;
}

CGImageRef SSImageCreateWithURL(CFURLRef url) {
	CGImageRef image = NULL;
    if (url) {
        CGImageSourceRef source = CGImageSourceCreateWithURL(url, NULL);
        if (source) {
            image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
            CFRelease(source);
        } else {
            //SSDebugLog(@"SSImageCreateWithURL(%@) Failed! (source) ", url);
        }
    } else {
        //SSDebugLog(@"SSImageCreateWithURL(%@) Failed!", url);
    }
	return image;
}

CGImageRef SSImageCreateWithPath(NSString *path) {
	return SSImageCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path]);
}

CGImageRef SSImageCreateWithData(CFDataRef data) {
	CGImageRef image = NULL;
    if (data) {
        CGImageSourceRef source = CGImageSourceCreateWithData(data, NULL);
        if (source) {
            image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
            CFRelease(source);
        }
    }
    return image;
}

CGImageRef SSImageThumbnailCreateWithSource(CGImageSourceRef source, NSInteger maxPixelSize) {
    return source ? CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)@{(__bridge NSString *)kCGImageSourceCreateThumbnailWithTransform:@YES, (__bridge NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent:@YES, (__bridge NSString *)kCGImageSourceThumbnailMaxPixelSize:@(maxPixelSize)}) : NULL;
}

CGImageRef SSImageCreateThumbnail(CGImageRef image, NSInteger maxPixelSize) {
    return SSImageThumbnailCreateWithData(SSImageGetData(image), maxPixelSize);
}

CGImageRef SSImageThumbnailCreateWithURL(CFURLRef url, NSInteger maxPixelSize) {
    return SSImageThumbnailCreateWithSource(SSAutorelease(CGImageSourceCreateWithURL(url, NULL)), maxPixelSize);
}

CGImageRef SSImageThumbnailCreateWithPath(NSString *path, NSInteger maxPixelSize) {
    return SSImageThumbnailCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path], maxPixelSize);
}

CGImageRef SSImageThumbnailCreateWithData(CFDataRef data, NSInteger maxPixelSize) {
    return SSImageThumbnailCreateWithSource(SSAutorelease(CGImageSourceCreateWithData(data, NULL)), maxPixelSize);
}

#if !TARGET_OS_WATCH

CGImageRef SSImageCreateBadgeWithLabel(NSString *label, id font, CGFloat borderWidth) {
    CGFloat minimumHeight = 22.0;
    CGSize stringSize = SSStringGetSizeWithFont(label, font);
    CGFloat proposedImageHeight = MAX(FLOOR(stringSize.height + 2.0 + borderWidth*(CGFloat)2.0), minimumHeight);
    CGRect bounds = CGRectZero;
    bounds.size = CGSizeMake(MAX(proposedImageHeight, FLOOR(stringSize.width + (minimumHeight*(CGFloat)0.5)) + (borderWidth*(CGFloat)2.0)), proposedImageHeight);
    
    size_t pixelsWide = CGRectGetWidth(bounds);
    size_t pixelsHigh = CGRectGetHeight(bounds);
    size_t bytesPerRow = (pixelsWide * 4);
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return  NULL;
    }
    
    CGColorRef borderColor = CGColorCreate(colorSpace, (const CGFloat[]){1.0, 1.0, 1.0, 1.0});
    CGPathRef path = SSPathCreateWithRoundedRect(CGRectIntegral(CGRectInset(bounds, borderWidth, borderWidth)), pixelsHigh*(CGFloat)0.5, NULL);
    CGRect boundingBox = CGPathGetBoundingBox(path);
    CGContextSaveGState(ctx);
    {
        CGContextSetShouldAntialias(ctx, true);
        CGContextSetAllowsAntialiasing(ctx, true);
        
        if (borderWidth) {
            CGContextSaveGState(ctx);
            {
                CGContextAddPath(ctx, path);
                CGContextSetStrokeColorWithColor(ctx, borderColor);
                CGContextSetLineWidth(ctx, borderWidth);
                CGContextStrokePath(ctx);
            }
            CGContextRestoreGState(ctx);
        }
        
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);
        
        CGColorRef fillColor = CGColorCreate(colorSpace, (const CGFloat[]){0.97647058823529, 0.11764705882353, 0.16862745098039, 1.0});
        CGContextSetFillColorWithColor(ctx, fillColor);
        CGContextFillRect(ctx, boundingBox);
        CGColorRelease(fillColor);
        
    }
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
    
    CGRect stringBounds = SSRectCenteredSize(bounds, stringSize);
    CGContextSaveGState(ctx);
    {
        CGContextSetShadow(ctx, CGSizeMake(0, 1.0), 1.0);
        CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_11)) || (TARGET_OS_IPHONE && defined(__IPHONE_9_0)))
        SSContextDrawTextAlignedInRect(ctx, (__bridge CFStringRef)label, stringBounds, kCTTextAlignmentCenter, (__bridge CTFontRef)font, borderColor);
#else
        SSContextDrawTextAlignedInRect(ctx, (__bridge CFStringRef)label, stringBounds, kCTCenterTextAlignment, (__bridge CTFontRef)font, borderColor);
#endif
    }
    CGContextRestoreGState(ctx);
    CGColorRelease(borderColor);
    
    return CGBitmapContextCreateImage(ctx);
}

CGImageRef SSImageCreateWithLabelNumber(NSInteger fileLabel, CGSize size) {
    NSArray *labelColors = SSColorGetLabelColors();
    if (!NSLocationInRange(fileLabel, NSMakeRange(0, labelColors.count))) {
        return NULL;
    }
    
    CGColorRef color = SSColorGetCGColor(labelColors[fileLabel]);
    
    CGRect bounds = CGRectZero;
    bounds.size = size;
    
    size_t pixelsWide = CGRectGetWidth(bounds);
    size_t pixelsHigh = CGRectGetHeight(bounds);
    size_t bytesPerRow = (pixelsWide * 4);
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return  NULL;
    }
    
    CGPathRef path = SSPathCreateWithRoundedRect(CGRectIntegral(CGRectInset(bounds, 2.0, 2.0)), pixelsHigh*(CGFloat)0.5, NULL);
    CGRect boundingBox = CGPathGetBoundingBox(path);
    CGContextSaveGState(ctx);
    {
        CGColorRef shadowColor = SSColorCreateDeviceRGB(0.92, 0.92, 0.92, 0.92);
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1.0), 0.0, shadowColor);
        CGColorRelease(shadowColor);
        
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            CGColorRef boderColor = SSColorCreateShadowedWithLevel(color, 0.5);
            CGContextSetStrokeColorWithColor(ctx, boderColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextStrokePath(ctx);
            CGColorRelease(boderColor);
        }
        CGContextRestoreGState(ctx);
        
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);
        
        CGGradientRef gradient = SSGradientCreateWithColor(color);
        CGContextSetShadowWithColor(ctx, CGSizeZero, 0, NULL);
        SSContextDrawLinearGradient(ctx, gradient, boundingBox, 90.0);
        CGGradientRelease(gradient);
        
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            CGColorRef glowColor = SSColorCreateDeviceRGB(0.9, 0.9, 0.9, 0.16);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextSetStrokeColorWithColor(ctx, glowColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextStrokePath(ctx);
            CGColorRelease(glowColor);
        }
        CGContextRestoreGState(ctx);
        
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            CGColorRef innerShadowColor = SSColorCreateDeviceRGB(0.9, 0.9, 0.9, 0.6);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            SSContextDrawInnerShadowWithColor(ctx, path, innerShadowColor, CGSizeMake(0.0, -1.0), 0.0);
            CGColorRelease(innerShadowColor);
        }
        CGContextRestoreGState(ctx);
        
    }
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
    
    return CGBitmapContextCreateImage(ctx);
}

#endif

#if !TARGET_OS_WATCH

CGImageRef SSImageCreateWithCIImage(CIImage *image) {
    CGImageRef imageRef = NULL;
    if (image) {
        imageRef = [[CIContext sharedContext] createCGImage:image fromRect:image.extent];
    }
    return imageRef;
}

#endif

#if !TARGET_OS_IPHONE

CGImageRef SSImageCreateWithIconRef(IconRef iconRef, CGSize size) {
    CGImageRef image = NULL;
    if (iconRef) {
        if (SSSizeIsEmpty(size)) {
            size = SSSizeMakeSquare(512.0);
        }
        
        const size_t width = size.width;
        const size_t height = size.height;
        CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
        CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
        if (ctx) {
            CGRect imageBounds = CGRectZero;
            imageBounds.size = size;
            
            if (PlotIconRefInContext(ctx, &imageBounds, kAlignAbsoluteCenter, kTransformNone, NULL, kIconServicesNoBadgeFlag, iconRef) == noErr) {
                image = CGBitmapContextCreateImage(ctx);
            }
        }
    }
    
    return image;
}

CGImageRef SSImageCreateWithIconRefAtURL(CFURLRef url, CGSize size) {
    CGImageRef image = NULL;
    if (url) {
        IconRef iconRef;
        IconFamilyHandle iconFamily;
        FSRef fileRef;
        if (CFURLGetFSRef(url, &fileRef) && ReadIconFromFSRef(&fileRef, &iconFamily)) {
            HLock((Handle)iconFamily);
            GetIconRefFromIconFamilyPtr(*iconFamily,(**iconFamily).resourceSize, &iconRef);
            DisposeHandle((Handle)iconFamily);
            image = SSImageCreateWithIconRef(iconRef, size);
            ReleaseIconRef(iconRef);
        }
    }
    return image;
}

CGImageRef SSImageCreateWithPreviewOfItemAtURL(CFURLRef url, CGSize size) {
    return QLThumbnailImageCreate(kCFAllocatorDefault, url, SSSizeIsEmpty(size) ? SSSizeMakeSquare(512.0) : size, (__bridge CFDictionaryRef)@{(__bridge NSString *)kQLThumbnailOptionIconModeKey:@NO});
}

CGImageRef SSImageCreateWithGradient(NSGradient *gradient, CGSize size, CGFloat angle) {
    if (!gradient) {
        return NULL;
    }
    
	size_t pixelsWide = (size_t)size.width;
	size_t pixelsHigh = (size_t)size.height;
	size_t bytesPerRow = (size_t)(pixelsWide * 4);
	CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
	
    NSGraphicsContext *context = nil;
#if defined(__MAC_10_10)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        context = [NSGraphicsContext graphicsContextWithCGContext:ctx flipped:YES];
    }
#else
    context = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:YES];
#endif
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:context];
	
	[gradient drawInRect:SSRectMakeWithSize(size) angle:angle];
	
	[NSGraphicsContext restoreGraphicsState];
	
	CGImageRef image = CGBitmapContextCreateImage(ctx);
	
	CGContextRelease(ctx);
	
	return image;
}

#endif

CGImageRef SSImageCreateWithColor(CGColorRef color, CGSize size) {
    return SSImageCreate(size, ^(CGContextRef c) {
        CGContextSetFillColorWithColor(c, color ? color : SSColorGetWhiteColor());
        CGContextFillRect(c, CGContextGetClipBoundingBox(c));
    });
}

CGImageRef SSImageCreateWithCGGradient(CGGradientRef gradient, CGSize size, CGFloat angle) {
    return gradient ? SSImageCreate(size, ^(CGContextRef ctx) {
        SSContextDrawLinearGradient(ctx, gradient, CGContextGetClipBoundingBox(ctx), angle);
    }) : NULL;
}

CGImageRef SSImageCreateWithEPSDataProvider(CGDataProviderRef data) {
    return NULL;
}

CGImageRef SSImageCreateWithCGPDFPage(CGPDFPageRef page, CGFloat dpi) {
    if (!page) {
        return NULL;
    }
    
    CGFloat scale = dpi/72.0;
    CGRect boundingBox = SSRectScale(CGPDFPageGetBoxRect(page, kCGPDFCropBox), scale);
    CGColorSpaceRef space = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, CGRectGetWidth(boundingBox), CGRectGetHeight(boundingBox), 8, CGRectGetWidth(boundingBox) * 4, space, kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst));
    CGContextSetGrayFillColor(ctx, 1.0, 1.0);
    CGContextFillRect(ctx, boundingBox);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    CGContextSetRenderingIntent(ctx, kCGRenderingIntentDefault);
    CGContextScaleCTM(ctx, scale, scale);
    CGContextDrawPDFPage(ctx, page);
    return CGBitmapContextCreateImage(ctx);
}

CGImageRef SSImageCreateWithCGPDFDocument(CGPDFDocumentRef document, size_t pageNumber, CGFloat dpi) {
    return document ? (NSLocationInRange(pageNumber, (NSRange){1, CGPDFDocumentGetNumberOfPages(document)}) ? SSImageCreateWithCGPDFPage(CGPDFDocumentGetPage(document, pageNumber), dpi) : NULL) : NULL;
}

#if !TARGET_OS_WATCH

CGImageRef SSImageCreateCopy(CGImageRef image, CGSize size) {
    if (!image) {
        return NULL;
    }
    
    CGImageRef imageRef = NULL;
    const size_t width = CGImageGetWidth(image);
	const size_t height = CGImageGetHeight(image);
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
	CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    CGContextDrawImage(ctx, SSRectMakeWithSize(size), image);
    
    void *data = CGBitmapContextGetData(ctx);
    if (!data) {
        return NULL;
    }
    
    void *outt = malloc((size.width * 4) * size.height);
    vImage_Buffer src = {data, height, width, width * 4};
    vImage_Buffer dest = {outt, size.height, size.width, size.width * 4};
    vImageScale_ARGB8888(&src, &dest, NULL, kvImageDoNotTile|kvImageHighQualityResampling);
    
    CFDataRef outputData = CFDataCreate(NULL, dest.data, dest.height*dest.rowBytes);
    if (outputData) {
        CGDataProviderRef provider = CGDataProviderCreateWithCFData(outputData);
        if (provider) {
            imageRef = CGImageCreate(size.width, size.height, 8, 32, size.width * 4, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst, provider, NULL, true, kCGRenderingIntentDefault);
            
            CGDataProviderRelease(provider);
        }
        CFRelease(outputData);
    }
    free(outt);
    
    return imageRef;
}

CGImageRef SSImageCreateRotated(CGImageRef image, float angle) {
    if (!(&vImageRotate_ARGB8888)) {
        return NULL;
    }
    
    const size_t width = CGImageGetWidth(image);
    const size_t height = CGImageGetHeight(image);
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0, .origin.y = 0.0, .size.width = width, .size.height = height}, image);
    
    UInt8 *data = (UInt8 *)CGBitmapContextGetData(ctx);
    if (!data) {
        return NULL;
    }
    
    vImage_Buffer src = {data, height, width, bytesPerRow};
    vImage_Buffer dest = {data, height, width, bytesPerRow};
    Pixel_8888 bgColor = {0, 0, 0, 0};
    vImageRotate_ARGB8888(&src, &dest, NULL, RADIANS(angle), bgColor, kvImageDoNotTile|kvImageBackgroundColorFill|kvImageHighQualityResampling);
    
    return CGBitmapContextCreateImage(ctx);
}

CGImageRef SSImageCreateWithBrightness(CGImageRef image, float brightness) {
    if (!image) {
        return NULL;
    }
    
    /// Create an ARGB bitmap context
    const size_t width = CGImageGetWidth(image);
    const size_t height = CGImageGetHeight(image);
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    /// Draw the image in the bitmap context
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0, .origin.y = 0.0, .size.width = width, .size.height = height}, image);
    
    /// Grab the image raw data
    UInt8* data = (UInt8*)CGBitmapContextGetData(ctx);
    if (!data) {
        return NULL;
    }
    
    const size_t pixelsCount = width * height;
    float* dataAsFloat = (float*)malloc(sizeof(float) * pixelsCount);
    float min = (float)0, max = (float)255;
    
    /// Calculate red components
    vDSP_vfltu8(data + 1, 4, dataAsFloat, 1, pixelsCount);
    vDSP_vsadd(dataAsFloat, 1, &brightness, dataAsFloat, 1, pixelsCount);
    vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount);
    vDSP_vfixu8(dataAsFloat, 1, data + 1, 4, pixelsCount);
    
    /// Calculate green components
    vDSP_vfltu8(data + 2, 4, dataAsFloat, 1, pixelsCount);
    vDSP_vsadd(dataAsFloat, 1, &brightness, dataAsFloat, 1, pixelsCount);
    vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount);
    vDSP_vfixu8(dataAsFloat, 1, data + 2, 4, pixelsCount);
    
    /// Calculate blue components
    vDSP_vfltu8(data + 3, 4, dataAsFloat, 1, pixelsCount);
    vDSP_vsadd(dataAsFloat, 1, &brightness, dataAsFloat, 1, pixelsCount);
    vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount);
    vDSP_vfixu8(dataAsFloat, 1, data + 3, 4, pixelsCount);
    
    CGImageRef brightenedImageRef = CGBitmapContextCreateImage(ctx);
    
    free(dataAsFloat);
    
    return brightenedImageRef;
}

CGImageRef SSImageCreateWithContrast(CGImageRef image, float contrast) {
    if (!image) {
        return NULL;
    }
    
    const size_t width = CGImageGetWidth(image);
    const size_t height = CGImageGetHeight(image);
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    /// Draw the image in the bitmap context
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image);
    
    /// Grab the image raw data
    UInt8* data = (UInt8*)CGBitmapContextGetData(ctx);
    if (!data) {
        return NULL;
    }
    
    const size_t pixelsCount = width * height;
    float* dataAsFloat = (float*)malloc(sizeof(float) * pixelsCount);
    float min = (float)0, max = (float)255;
    
    /// Contrast correction factor
    const float factor = (259.0f * (contrast + 255.0f)) / (255.0f * (259.0f - contrast));
    
    float v1 = -128.0f, v2 = 128.0f;
    
    /// Calculate red components
    vDSP_vfltu8(data + 1, 4, dataAsFloat, 1, pixelsCount);
    vDSP_vsadd(dataAsFloat, 1, &v1, dataAsFloat, 1, pixelsCount);
    vDSP_vsmul(dataAsFloat, 1, &factor, dataAsFloat, 1, pixelsCount);
    vDSP_vsadd(dataAsFloat, 1, &v2, dataAsFloat, 1, pixelsCount);
    vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount);
    vDSP_vfixu8(dataAsFloat, 1, data + 1, 4, pixelsCount);
    
    /// Calculate green components
    vDSP_vfltu8(data + 2, 4, dataAsFloat, 1, pixelsCount);
    vDSP_vsadd(dataAsFloat, 1, &v1, dataAsFloat, 1, pixelsCount);
    vDSP_vsmul(dataAsFloat, 1, &factor, dataAsFloat, 1, pixelsCount);
    vDSP_vsadd(dataAsFloat, 1, &v2, dataAsFloat, 1, pixelsCount);
    vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount);
    vDSP_vfixu8(dataAsFloat, 1, data + 2, 4, pixelsCount);
    
    /// Calculate blue components
    vDSP_vfltu8(data + 3, 4, dataAsFloat, 1, pixelsCount);
    vDSP_vsadd(dataAsFloat, 1, &v1, dataAsFloat, 1, pixelsCount);
    vDSP_vsmul(dataAsFloat, 1, &factor, dataAsFloat, 1, pixelsCount);
    vDSP_vsadd(dataAsFloat, 1, &v2, dataAsFloat, 1, pixelsCount);
    vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount);
    vDSP_vfixu8(dataAsFloat, 1, data + 3, 4, pixelsCount);
    
    /// Create an image object from the context
    CGImageRef contrastedImageRef = CGBitmapContextCreateImage(ctx);
    
    /// Cleanup
    free(dataAsFloat);
    
    return contrastedImageRef;
}

CGImageRef SSImageCreateWithGammaCorrection(CGImageRef image, float gamma) {
    if (!image) {
        return NULL;
    }
    
    const size_t width = CGImageGetWidth(image);
    const size_t height = CGImageGetHeight(image);
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    /// Draw the image in the bitmap context
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image);
    
    /// Grab the image raw data
    UInt8* data = (UInt8*)CGBitmapContextGetData(ctx);
    if (!data) {
        return NULL;
    }
#if (!TARGET_OS_IPHONE && defined(__MAC_10_4)) || TARGET_OS_IPHONE && defined(__IPHONE_5_0)
    if ((&vvpowf) != NULL) {
        const size_t pixelsCount = width * height;
        const size_t n = sizeof(float) * pixelsCount;
        float* dataAsFloat = (float*)malloc(n);
        float* temp = (float*)malloc(n);
        float min = (float)0, max = (float)255;
        const int iPixels = (int)pixelsCount;
        
        /// Need a vector with same size :(
        vDSP_vfill(&gamma, temp, 1, pixelsCount);
        
        /// Calculate red components
        vDSP_vfltu8(data + 1, 4, dataAsFloat, 1, pixelsCount);
        vDSP_vsdiv(dataAsFloat, 1, &max, dataAsFloat, 1, pixelsCount);
        vvpowf(dataAsFloat, temp, dataAsFloat, &iPixels);
        vDSP_vsmul(dataAsFloat, 1, &max, dataAsFloat, 1, pixelsCount);
        vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount);
        vDSP_vfixu8(dataAsFloat, 1, data + 1, 4, pixelsCount);
        
        /// Calculate green components
        vDSP_vfltu8(data + 2, 4, dataAsFloat, 1, pixelsCount);
        vDSP_vsdiv(dataAsFloat, 1, &max, dataAsFloat, 1, pixelsCount);
        vvpowf(dataAsFloat, temp, dataAsFloat, &iPixels);
        vDSP_vsmul(dataAsFloat, 1, &max, dataAsFloat, 1, pixelsCount);
        vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount);
        vDSP_vfixu8(dataAsFloat, 1, data + 2, 4, pixelsCount);
        
        /// Calculate blue components
        vDSP_vfltu8(data + 3, 4, dataAsFloat, 1, pixelsCount);
        vDSP_vsdiv(dataAsFloat, 1, &max, dataAsFloat, 1, pixelsCount);
        vvpowf(dataAsFloat, temp, dataAsFloat, &iPixels);
        vDSP_vsmul(dataAsFloat, 1, &max, dataAsFloat, 1, pixelsCount);
        vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount);
        vDSP_vfixu8(dataAsFloat, 1, data + 3, 4, pixelsCount);
        
        /// Cleanup
        free(temp);
        free(dataAsFloat);
    }
#else
    const size_t bitmapByteCount = bytesPerRow * height;
    for (size_t i = 0; i < bitmapByteCount; i += 4) {
        const float red = (float)data[i + 1];
        const float green = (float)data[i + 2];
        const float blue = (float)data[i + 3];
        
        data[i + 1] = MIN(255, MAX(0, 255 * powf((red / 255.0f), gamma)));
        data[i + 2] = MIN(255, MAX(0, 255 * powf((green / 255.0f), gamma)));
        data[i + 3] = MIN(255, MAX(0, 255 * powf((blue / 255.0f), gamma)));
    }
#endif
    return CGBitmapContextCreateImage(ctx);
}

/* vImage kernel */
static int16_t __s_sharpen_kernel_3x3[9] = {
    -1, -1, -1,
    -1, 9, -1,
    -1, -1, -1
};

#if (!TARGET_OS_IPHONE && !defined(__MAC_10_4)) || TARGET_OS_IPHONE && !defined(__IPHONE_5_0)
/* vDSP kernel */
static float __f_sharpen_kernel_3x3[9] = {
    -1.0f, -1.0f, -1.0f,
    -1.0f, 9.0f, -1.0f,
    -1.0f, -1.0f, -1.0f
};
#endif

CGImageRef SSImageCreateWithSharpness(CGImageRef image, int32_t bias) {
    if (!image) {
        return NULL;
    }
    
    /// Create an ARGB bitmap context
    const size_t width = CGImageGetWidth(image);
    const size_t height = CGImageGetHeight(image);
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    /// Draw the image in the bitmap context
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image);
    
    /// Grab the image raw data
    UInt8* data = (UInt8*)CGBitmapContextGetData(ctx);
    if (!data) {
        return NULL;
    }
    
#if (!TARGET_OS_IPHONE && defined(__MAC_10_4)) || TARGET_OS_IPHONE && defined(__IPHONE_5_0)
    if ((&vImageConvolveWithBias_ARGB8888) != NULL) {
        const size_t n = sizeof(UInt8) * width * height * 4;
        void* outt = malloc(n);
        vImage_Buffer src = {data, height, width, bytesPerRow};
        vImage_Buffer dest = {outt, height, width, bytesPerRow};
        vImageConvolveWithBias_ARGB8888(&src, &dest, NULL, 0, 0, __s_sharpen_kernel_3x3, 3, 3, 1/*divisor*/, bias, NULL, kvImageDoNotTile|kvImageCopyInPlace);
        
        memcpy(data, outt, n);
        
        free(outt);
    }
#else
    const size_t pixelsCount = width * height;
    const size_t n = sizeof(float) * pixelsCount;
    float* dataAsFloat = malloc(n);
    float* resultAsFloat = malloc(n);
    float min = (float)0, max = (float)255;
    
    /// Red components
    vDSP_vfltu8(data + 1, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f3x3(dataAsFloat, height, width, __f_sharpen_kernel_3x3, resultAsFloat);
    vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
    vDSP_vfixu8(resultAsFloat, 1, data + 1, 4, pixelsCount);
    
    /// Green components
    vDSP_vfltu8(data + 2, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f3x3(dataAsFloat, height, width, __f_sharpen_kernel_3x3, resultAsFloat);
    vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
    vDSP_vfixu8(resultAsFloat, 1, data + 2, 4, pixelsCount);
    
    /// Blue components
    vDSP_vfltu8(data + 3, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f3x3(dataAsFloat, height, width, __f_sharpen_kernel_3x3, resultAsFloat);
    vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
    vDSP_vfixu8(resultAsFloat, 1, data + 3, 4, pixelsCount);
    
    free(dataAsFloat);
    free(resultAsFloat);
#endif
    return CGBitmapContextCreateImage(ctx);
}

/* vImage kernel */
static int16_t __s_unsharpen_kernel_3x3[9] = {
    -1, -1, -1,
    -1, 17, -1,
    -1, -1, -1
};
#if (!TARGET_OS_IPHONE && !defined(__MAC_10_4)) || TARGET_OS_IPHONE && !defined(__IPHONE_5_0)
/* vDSP kernel */
static float __f_unsharpen_kernel_3x3[9] = {
    -1.0f/9.0f, -1.0f/9.0f, -1.0f/9.0f,
    -1.0f/9.0f, 17.0f/9.0f, -1.0f/9.0f,
    -1.0f/9.0f, -1.0f/9.0f, -1.0f/9.0f
};
#endif

CGImageRef SSImageCreateUnsharpness(CGImageRef image, int32_t bias) {
    if (!image) {
        return NULL;
    }
    
    const size_t width = CGImageGetWidth(image);
    const size_t height = CGImageGetHeight(image);
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    /// Draw the image in the bitmap context
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image);
    
    /// Grab the image raw data
    UInt8* data = (UInt8*)CGBitmapContextGetData(ctx);
    if (!data) {
        return NULL;
    }
    
#if (!TARGET_OS_IPHONE && defined(__MAC_10_4)) || TARGET_OS_IPHONE && defined(__IPHONE_5_0)
    if ((&vImageConvolveWithBias_ARGB8888) != NULL) {
        const size_t n = sizeof(UInt8) * width * height * 4;
        void* outt = malloc(n);
        vImage_Buffer src = {data, height, width, bytesPerRow};
        vImage_Buffer dest = {outt, height, width, bytesPerRow};
        vImageConvolveWithBias_ARGB8888(&src, &dest, NULL, 0, 0, __s_unsharpen_kernel_3x3, 3, 3, 9/*divisor*/, bias, NULL, kvImageDoNotTile|kvImageCopyInPlace);
        
        memcpy(data, outt, n);
        
        free(outt);
    }
#else
    const size_t pixelsCount = width * height;
    const size_t n = sizeof(float) * pixelsCount;
    float* dataAsFloat = malloc(n);
    float* resultAsFloat = malloc(n);
    float min = (float)0, max = (float)255;
    
    /// Red components
    vDSP_vfltu8(data + 1, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f3x3(dataAsFloat, height, width, __f_unsharpen_kernel_3x3, resultAsFloat);
    vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
    vDSP_vfixu8(resultAsFloat, 1, data + 1, 4, pixelsCount);
    
    /// Green components
    vDSP_vfltu8(data + 2, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f3x3(dataAsFloat, height, width, __f_unsharpen_kernel_3x3, resultAsFloat);
    vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
    vDSP_vfixu8(resultAsFloat, 1, data + 2, 4, pixelsCount);
    
    /// Blue components
    vDSP_vfltu8(data + 3, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f3x3(dataAsFloat, height, width, __f_unsharpen_kernel_3x3, resultAsFloat);
    vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
    vDSP_vfixu8(resultAsFloat, 1, data + 3, 4, pixelsCount);
    
    free(dataAsFloat);
    free(resultAsFloat);
#endif
    return CGBitmapContextCreateImage(ctx);
}

#if (!TARGET_OS_IPHONE && !defined(__MAC_10_4)) || TARGET_OS_IPHONE && !defined(__IPHONE_5_0)
static float __f_gaussianblur_kernel_5x5[25] = {
    1.0f/256.0f,  4.0f/256.0f,  6.0f/256.0f,  4.0f/256.0f, 1.0f/256.0f,
    4.0f/256.0f, 16.0f/256.0f, 24.0f/256.0f, 16.0f/256.0f, 4.0f/256.0f,
    6.0f/256.0f, 24.0f/256.0f, 36.0f/256.0f, 24.0f/256.0f, 6.0f/256.0f,
    4.0f/256.0f, 16.0f/256.0f, 24.0f/256.0f, 16.0f/256.0f, 4.0f/256.0f,
    1.0f/256.0f,  4.0f/256.0f,  6.0f/256.0f,  4.0f/256.0f, 1.0f/256.0f
};
#endif

static int16_t __s_gaussianblur_kernel_5x5[25] = {
    1, 4, 6, 4, 1,
    4, 16, 24, 16, 4,
    6, 24, 36, 24, 6,
    4, 16, 24, 16, 4,
    1, 4, 6, 4, 1
};

CGImageRef SSImageCreateWithGaussianBlur(CGImageRef image, int32_t bias) {
    if (!image) {
        return NULL;
    }
    
    const size_t width = CGImageGetWidth(image);
    const size_t height = CGImageGetHeight(image);
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    /// Draw the image in the bitmap context
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0, .origin.y = 0.0, .size.width = width, .size.height = height}, image);
    
    /// Grab the image raw data
    UInt8* data = (UInt8*)CGBitmapContextGetData(ctx);
    if (!data) {
        return NULL;
    }
#if (!TARGET_OS_IPHONE && defined(__MAC_10_4)) || TARGET_OS_IPHONE && defined(__IPHONE_5_0)
    if ((&vImageConvolveWithBias_ARGB8888) != NULL) {
        const size_t n = sizeof(UInt8) * width * height * 4;
        void* outt = malloc(n);
        vImage_Buffer src = {data, height, width, bytesPerRow};
        vImage_Buffer dest = {outt, height, width, bytesPerRow};
        vImageConvolveWithBias_ARGB8888(&src, &dest, NULL, 0, 0, __s_gaussianblur_kernel_5x5, 5, 5, 256/*divisor*/, bias, NULL, kvImageDoNotTile|kvImageCopyInPlace);
        memcpy(data, outt, n);
        free(outt);
    }
#else
    const size_t pixelsCount = width * height;
    const size_t n = sizeof(float) * pixelsCount;
    float* dataAsFloat = malloc(n);
    float* resultAsFloat = malloc(n);
    
    /// Red components
    vDSP_vfltu8(data + 1, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f5x5(dataAsFloat, height, width, __f_gaussianblur_kernel_5x5, resultAsFloat);
    vDSP_vfixu8(resultAsFloat, 1, data + 1, 4, pixelsCount);
    
    /// Green components
    vDSP_vfltu8(data + 2, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f5x5(dataAsFloat, height, width, __f_gaussianblur_kernel_5x5, resultAsFloat);
    vDSP_vfixu8(resultAsFloat, 1, data + 2, 4, pixelsCount);
    
    /// Blue components
    vDSP_vfltu8(data + 3, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f5x5(dataAsFloat, height, width, __f_gaussianblur_kernel_5x5, resultAsFloat);
    vDSP_vfixu8(resultAsFloat, 1, data + 3, 4, pixelsCount);
    
    free(resultAsFloat);
    free(dataAsFloat);
#endif
    return CGBitmapContextCreateImage(ctx);
}

CGImageRef SSImageCreateWithBoxBlur(CGImageRef image, CGFloat blur) {
    if (!image) {
        return NULL;
    }
    
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    
    int32_t boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    const size_t width = CGImageGetWidth(image);
    const size_t height = CGImageGetHeight(image);
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSAutorelease(CGColorSpaceCreateDeviceRGB());
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0, .origin.y = 0.0, .size.width = width, .size.height = height}, image);
    
    UInt8 *data = (UInt8*)CGBitmapContextGetData(ctx);
    if (!data) {
        return NULL;
    }
    
    if ((&vImageBoxConvolve_ARGB8888) != NULL) {
        const size_t n = sizeof(UInt8) * width * height * 4;
        void* outt = malloc(n);
        vImage_Buffer src = {data, height, width, bytesPerRow};
        vImage_Buffer dest = {outt, height, width, bytesPerRow};
        vImageBoxConvolve_ARGB8888(&src, &dest, NULL, 0, 0, boxSize, boxSize, NULL, kvImageDoNotTile|kvImageEdgeExtend);
        memcpy(data, outt, n);
        free(outt);
    }
    
    return CGBitmapContextCreateImage(ctx);
}

/* vImage kernel */
static int16_t __s_edgedetect_kernel_3x3[9] = {
    -1, -1, -1,
    -1, 8, -1,
    -1, -1, -1
};
#if (!TARGET_OS_IPHONE && !defined(__MAC_10_4)) || TARGET_OS_IPHONE && !defined(__IPHONE_5_0)
/* vDSP kernel */
static float __f_edgedetect_kernel_3x3[9] = {
    -1.0f, -1.0f, -1.0f,
    -1.0f, 8.0f, -1.0f,
    -1.0f, -1.0f, -1.0f
};
#endif

CGImageRef SSImageCreateWithEdgeDetection(CGImageRef image, int32_t bias) {
    if (!image) {
        return NULL;
    }
    
    const size_t width = CGImageGetWidth(image);
    const size_t height = CGImageGetHeight(image);
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    /// Draw the image in the bitmap context
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image);
    
    /// Grab the image raw data
    UInt8* data = (UInt8*)CGBitmapContextGetData(ctx);
    if (!data) {
        return NULL;
    }
    
#if (!TARGET_OS_IPHONE && defined(__MAC_10_4)) || TARGET_OS_IPHONE && defined(__IPHONE_5_0)
    if ((&vImageConvolveWithBias_ARGB8888) != NULL) {
        const size_t n = sizeof(UInt8) * width * height * 4;
        void* outt = malloc(n);
        vImage_Buffer src = {data, height, width, bytesPerRow};
        vImage_Buffer dest = {outt, height, width, bytesPerRow};
        
        vImageConvolveWithBias_ARGB8888(&src, &dest, NULL, 0, 0, __s_edgedetect_kernel_3x3, 3, 3, 1, bias, NULL, kvImageDoNotTile|kvImageCopyInPlace);
        
        CGDataProviderRef dp = CGDataProviderCreateWithData(NULL, data, n, NULL);
        CGColorSpaceRef cs = SSColorSpaceGetDeviceRGB();
        CGImageRef edgedImageRef = CGImageCreate(width, height, 8, 32, bytesPerRow, cs, kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipFirst, dp, NULL, true, kCGRenderingIntentDefault);
        
        /// Cleanup
        CGDataProviderRelease(dp);
        free(outt);
        
        return edgedImageRef;
    }
#else
    const size_t pixelsCount = width * height;
    const size_t n = sizeof(float) * pixelsCount;
    float* dataAsFloat = malloc(n);
    float* resultAsFloat = malloc(n);
    float min = (float)0, max = (float)255;
    
    /// Red components
    vDSP_vfltu8(data + 1, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f3x3(dataAsFloat, height, width, __f_edgedetect_kernel_3x3, resultAsFloat);
    vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
    vDSP_vfixu8(resultAsFloat, 1, data + 1, 4, pixelsCount);
    
    /// Green components
    vDSP_vfltu8(data + 2, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f3x3(dataAsFloat, height, width, __f_edgedetect_kernel_3x3, resultAsFloat);
    vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
    vDSP_vfixu8(resultAsFloat, 1, data + 2, 4, pixelsCount);
    
    /// Blue components
    vDSP_vfltu8(data + 3, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f3x3(dataAsFloat, height, width, __f_edgedetect_kernel_3x3, resultAsFloat);
    vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
    vDSP_vfixu8(resultAsFloat, 1, data + 3, 4, pixelsCount);
    
    CGImageRef edgedImageRef = CGBitmapContextCreateImage(ctx);
    
    /// Cleanup
    free(resultAsFloat);
    free(dataAsFloat);
    
    return edgedImageRef;
#endif
}

/* vImage kernel */
static int16_t __s_emboss_kernel_3x3[9] = {
    -2, 0, 0,
    0, 1, 0,
    0, 0, 2
};
#if (!TARGET_OS_IPHONE && !defined(__MAC_10_4)) || TARGET_OS_IPHONE && !defined(__IPHONE_5_0)
/* vDSP kernel */
static float __f_emboss_kernel_3x3[9] = {
    -2.0f, 0.0f, 0.0f,
    0.0f, 1.0f, 0.0f,
    0.0f, 0.0f, 2.0f
};
#endif

CGImageRef SSImageCreateWithEmboss(CGImageRef image, int32_t bias) {
    if (!image) {
        return NULL;
    }
    
    const size_t width = CGImageGetWidth(image);
    const size_t height = CGImageGetHeight(image);
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    /// Draw the image in the bitmap context
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image);
    
    /// Grab the image raw data
    UInt8* data = (UInt8*)CGBitmapContextGetData(ctx);
    if (!data) {
        return NULL;
    }
    
#if (!TARGET_OS_IPHONE && defined(__MAC_10_4)) || TARGET_OS_IPHONE && defined(__IPHONE_5_0)
    if ((&vImageConvolveWithBias_ARGB8888) != NULL) {
        const size_t n = sizeof(UInt8) * width * height * 4;
        void* outt = malloc(n);
        vImage_Buffer src = {data, height, width, bytesPerRow};
        vImage_Buffer dest = {outt, height, width, bytesPerRow};
        vImageConvolveWithBias_ARGB8888(&src, &dest, NULL, 0, 0, __s_emboss_kernel_3x3, 3, 3, 1/*divisor*/, bias, NULL, kvImageDoNotTile|kvImageCopyInPlace);
        
        memcpy(data, outt, n);
        
        free(outt);
    }
#else
    const size_t pixelsCount = width * height;
    const size_t n = sizeof(float) * pixelsCount;
    float* dataAsFloat = malloc(n);
    float* resultAsFloat = malloc(n);
    float min = (float)0, max = (float)255;
    
    /// Red components
    vDSP_vfltu8(data + 1, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f3x3(dataAsFloat, height, width, __f_emboss_kernel_3x3, resultAsFloat);
    vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
    vDSP_vfixu8(resultAsFloat, 1, data + 1, 4, pixelsCount);
    
    /// Green components
    vDSP_vfltu8(data + 2, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f3x3(dataAsFloat, height, width, __f_emboss_kernel_3x3, resultAsFloat);
    vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
    vDSP_vfixu8(resultAsFloat, 1, data + 2, 4, pixelsCount);
    
    /// Blue components
    vDSP_vfltu8(data + 3, 4, dataAsFloat, 1, pixelsCount);
    vDSP_f3x3(dataAsFloat, height, width, __f_emboss_kernel_3x3, resultAsFloat);
    vDSP_vclip(resultAsFloat, 1, &min, &max, resultAsFloat, 1, pixelsCount);
    vDSP_vfixu8(resultAsFloat, 1, data + 3, 4, pixelsCount);
    
    free(dataAsFloat);
    free(resultAsFloat);
#endif
    return CGBitmapContextCreateImage(ctx);
}

/* Sepia values for manual filtering (< iOS 5) */
static float const __sepiaFactorRedRed = 0.393f;
static float const __sepiaFactorRedGreen = 0.349f;
static float const __sepiaFactorRedBlue = 0.272f;
static float const __sepiaFactorGreenRed = 0.769f;
static float const __sepiaFactorGreenGreen = 0.686f;
static float const __sepiaFactorGreenBlue = 0.534f;
static float const __sepiaFactorBlueRed = 0.189f;
static float const __sepiaFactorBlueGreen = 0.168f;
static float const __sepiaFactorBlueBlue = 0.131f;

CGImageRef SSImageCreateSepia(CGImageRef image) {
    if (!image) {
        return NULL;
    }
    /* 1.6x faster than before */
    
    /// Draw the image in the bitmap context
    const size_t width = CGImageGetWidth(image);
    const size_t height = CGImageGetHeight(image);
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image);
    
    /// Grab the image raw data
    UInt8* data = (UInt8*)CGBitmapContextGetData(ctx);
    if (!data) {
        return NULL;
    }
    
    const size_t pixelsCount = width * height;
    const size_t n = sizeof(float) * pixelsCount;
    float* reds = (float*)malloc(n);
    float* greens = (float*)malloc(n);
    float* blues = (float*)malloc(n);
    float* tmpRed = (float*)malloc(n);
    float* tmpGreen = (float*)malloc(n);
    float* tmpBlue = (float*)malloc(n);
    float* finalRed = (float*)malloc(n);
    float* finalGreen = (float*)malloc(n);
    float* finalBlue = (float*)malloc(n);
    float min = (float)0, max = (float)255;
    
    /// Convert byte components to float
    vDSP_vfltu8(data + 1, 4, reds, 1, pixelsCount);
    vDSP_vfltu8(data + 2, 4, greens, 1, pixelsCount);
    vDSP_vfltu8(data + 3, 4, blues, 1, pixelsCount);
    
    /// Calculate red components
    vDSP_vsmul(reds, 1, &__sepiaFactorRedRed, tmpRed, 1, pixelsCount);
    vDSP_vsmul(greens, 1, &__sepiaFactorGreenRed, tmpGreen, 1, pixelsCount);
    vDSP_vsmul(blues, 1, &__sepiaFactorBlueRed, tmpBlue, 1, pixelsCount);
    vDSP_vadd(tmpRed, 1, tmpGreen, 1, finalRed, 1, pixelsCount);
    vDSP_vadd(finalRed, 1, tmpBlue, 1, finalRed, 1, pixelsCount);
    vDSP_vclip(finalRed, 1, &min, &max, finalRed, 1, pixelsCount);
    vDSP_vfixu8(finalRed, 1, data + 1, 4, pixelsCount);
    
    /// Calculate green components
    vDSP_vsmul(reds, 1, &__sepiaFactorRedGreen, tmpRed, 1, pixelsCount);
    vDSP_vsmul(greens, 1, &__sepiaFactorGreenGreen, tmpGreen, 1, pixelsCount);
    vDSP_vsmul(blues, 1, &__sepiaFactorBlueGreen, tmpBlue, 1, pixelsCount);
    vDSP_vadd(tmpRed, 1, tmpGreen, 1, finalGreen, 1, pixelsCount);
    vDSP_vadd(finalGreen, 1, tmpBlue, 1, finalGreen, 1, pixelsCount);
    vDSP_vclip(finalGreen, 1, &min, &max, finalGreen, 1, pixelsCount);
    vDSP_vfixu8(finalGreen, 1, data + 2, 4, pixelsCount);
    
    /// Calculate blue components
    vDSP_vsmul(reds, 1, &__sepiaFactorRedBlue, tmpRed, 1, pixelsCount);
    vDSP_vsmul(greens, 1, &__sepiaFactorGreenBlue, tmpGreen, 1, pixelsCount);
    vDSP_vsmul(blues, 1, &__sepiaFactorBlueBlue, tmpBlue, 1, pixelsCount);
    vDSP_vadd(tmpRed, 1, tmpGreen, 1, finalBlue, 1, pixelsCount);
    vDSP_vadd(finalBlue, 1, tmpBlue, 1, finalBlue, 1, pixelsCount);
    vDSP_vclip(finalBlue, 1, &min, &max, finalBlue, 1, pixelsCount);
    vDSP_vfixu8(finalBlue, 1, data + 3, 4, pixelsCount);
    
    /// Create an image object from the context
    CGImageRef sepiaImage = CGBitmapContextCreateImage(ctx);
    
    /// Cleanup
    
    free(reds);
    free(greens);
    free(blues);
    free(tmpRed);
    free(tmpGreen);
    free(tmpBlue);
    free(finalRed);
    free(finalGreen);
    free(finalBlue);
    
    return sepiaImage;
}

/* Negative multiplier to invert a number */
static float __negativeMultiplier = -1.0f;

CGImageRef SSImageCreateInverted(CGImageRef image) {
    if (!image) {
        return NULL;
    }
    
    const size_t width = CGImageGetWidth(image);
    const size_t height = CGImageGetHeight(image);
    const size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    /// Draw the image in the bitmap context
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image);
    
    /// Grab the image raw data
    UInt8* data = (UInt8*)CGBitmapContextGetData(ctx);
    if (!data) {
        return NULL;
    }
    
    const size_t pixelsCount = width * height;
    float* dataAsFloat = (float*)malloc(sizeof(float) * pixelsCount);
    float min = (float)0, max = (float)255;
    UInt8* dataRed = data + 1;
    UInt8* dataGreen = data + 2;
    UInt8* dataBlue = data + 3;
    
    /// vDSP_vsmsa() = multiply then add
    /// slightly faster than the couple vDSP_vneg() & vDSP_vsadd()
    /// Probably because there are 3 function calls less
    
    /// Calculate red components
    vDSP_vfltu8(dataRed, 4, dataAsFloat, 1, pixelsCount);
    vDSP_vsmsa(dataAsFloat, 1, &__negativeMultiplier, &max, dataAsFloat, 1, pixelsCount);
    vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount);
    vDSP_vfixu8(dataAsFloat, 1, dataRed, 4, pixelsCount);
    
    /// Calculate green components
    vDSP_vfltu8(dataGreen, 4, dataAsFloat, 1, pixelsCount);
    vDSP_vsmsa(dataAsFloat, 1, &__negativeMultiplier, &max, dataAsFloat, 1, pixelsCount);
    vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount);
    vDSP_vfixu8(dataAsFloat, 1, dataGreen, 4, pixelsCount);
    
    /// Calculate blue components
    vDSP_vfltu8(dataBlue, 4, dataAsFloat, 1, pixelsCount);
    vDSP_vsmsa(dataAsFloat, 1, &__negativeMultiplier, &max, dataAsFloat, 1, pixelsCount);
    vDSP_vclip(dataAsFloat, 1, &min, &max, dataAsFloat, 1, pixelsCount);
    vDSP_vfixu8(dataAsFloat, 1, dataBlue, 4, pixelsCount);
    
    CGImageRef invertedImageRef = CGBitmapContextCreateImage(ctx);
    
    /// Cleanup
    free(dataAsFloat);
    
    return invertedImageRef;
}

#endif

CGImageRef SSImageCreateCopyWithSize(CGImageRef image, CGSize size, SSRectResizingMethod resizingMethod) {
    if (!image) {
        return NULL;
    }
    
    if (SSSizeIsEmpty(size)) {
        return NULL;
    }
    
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width * 4, SSColorSpaceGetDeviceRGB(), kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    SSContextDrawImage(ctx, image, SSRectMakeWithSize(size), resizingMethod);
    
    return CGBitmapContextCreateImage(ctx);
}

CGImageRef SSImageCreateCopyWithScaleFactor(CGImageRef image, CGFloat scaleFactor) {
    return SSImageCreateCopyWithSize(image, CGSizeMake(CGImageGetWidth(image) * scaleFactor, CGImageGetHeight(image) * scaleFactor), SSRectResizingMethodScale);
}

CGImageRef SSImageCreateCopyWithAlpha(CGImageRef image, CGFloat alpha) {
    if (!image) {
        return NULL;
    }
    
    CGSize size = SSImageGetSize(image);
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width * 4, colorSpace, kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst));
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, SSRectMakeWithSize(size), image);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    
    return imageRef;
}

CGImageRef SSImageCreateGrayscale(CGImageRef image) {
    if (!image) {
        return NULL;
    }
        
    /* const UInt8 luminance = (red * 0.2126) + (green * 0.7152) + (blue * 0.0722); // Good luminance value */
	/// Create a gray bitmap context
	const size_t width = CGImageGetWidth(image);
	const size_t height = CGImageGetHeight(image);
	CGColorSpaceRef space = SSColorSpaceGetDeviceGray();
	CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8/*Bits per component*/, width * 3, space, kCGBitmapByteOrderDefault|kCGImageAlphaNone));
    if (!ctx) {
        return NULL;
    }
    
	/// Image quality
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    /// Draw the image in the bitmap context
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0, .origin.y = 0.0, .size.width = width, .size.height = height}, image);
    
	return CGBitmapContextCreateImage(ctx);
}

CGImageRef SSImageCreateFlipped(CGImageRef image, bool vertically) {
    if (!image) {
        return NULL;
    }
    
    const size_t width = CGImageGetWidth(image);
	const size_t height = CGImageGetHeight(image);
	const size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
	CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    // Image quality
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    
    if (vertically) {
        CGContextTranslateCTM(ctx, 0.0, height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
    } else {
        CGContextTranslateCTM(ctx, width, 0.0);
        CGContextScaleCTM(ctx, -1.0, 1.0);
    }
    
    /// Draw the image in the bitmap context
    CGContextDrawImage(ctx, (CGRect){.origin.x = 0.0, .origin.y = 0.0, .size.width = width, .size.height = height}, image);
    
    return CGBitmapContextCreateImage(ctx);
}

CGImageRef SSImageCreateRotatedClockwiseByAngle(CGImageRef image, CGFloat angle) {
    if (!image) {
        return NULL;
    }
	CGFloat radians = RADIANS(-angle);
	CGFloat width = CGImageGetWidth(image);
	CGFloat height = CGImageGetHeight(image);
	CGRect imgRect = CGRectMake(0, 0, width, height);
	CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, CGAffineTransformMakeRotation(radians));
	CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(NULL, rotatedRect.size.width, rotatedRect.size.height, CGImageGetBitsPerComponent(image), 0, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst);
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationNone);
    CGContextTranslateCTM(ctx, +(rotatedRect.size.width/2), +(rotatedRect.size.height/2));
    CGContextRotateCTM(ctx, radians);
    CGContextTranslateCTM(ctx, -(rotatedRect.size.width/2), -(rotatedRect.size.height/2));
    CGContextDrawImage(ctx, CGRectMake((rotatedRect.size.width-width)/2.0f, (rotatedRect.size.height-height)/2.0f, width, height), image);
	CGImageRef rotatedImage = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	return rotatedImage;
}

static void SSImageCalculateAutolevelValues(CGImageRef image, CGFloat *whitePoint, CGFloat *blackPoint) {
    UInt8* imageData = malloc(100 * 100 * 4);
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(imageData, 100, 100, 8, 4 * 100, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(ctx, CGRectMake(0, 0, 100, 100), image);
    
    int histogramm[256];
    bzero(histogramm, 256 * sizeof(int));
    
    for (int i = 0; i < 100 * 100 * 4; i += 4) {
        UInt8 value = (imageData[i] + imageData[i+1] + imageData[i+2]) / 3;
        histogramm[value]++;
    }
    
    CGContextRelease(ctx);
    free(imageData);
    
    int black = 0;
    int counter = 0;
    
    // count up to 200 (2%) values from the black side of the histogramm to find the black point
    while ((counter < 200) && (black < 256)) {
        counter += histogramm[black];
        black ++;
    }
    
    int white = 255;
    counter = 0;
    
    // count up to 200 (2%) values from the white side of the histogramm to find the white point
    while ((counter < 200) && (white > 0)) {
        counter += histogramm[white];
        white --;
    }
    
    *blackPoint = 0.0 - (black / 256.0);
    *whitePoint = 1.0 + ((255-white) / 256.0);
}

CGImageRef SSImageCreateCopyAutoLeveled(CGImageRef image) {
    if (!image) {
        return NULL;
    }
    
    CGFloat whitePoint, blackPoint;
    SSImageCalculateAutolevelValues(image, &whitePoint, &blackPoint);
    const CGFloat decode[6] = {blackPoint, whitePoint, blackPoint, whitePoint, blackPoint, whitePoint};
    return CGImageCreate(CGImageGetWidth(image), CGImageGetHeight(image), CGImageGetBitsPerComponent(image), CGImageGetBitsPerPixel(image), CGImageGetBytesPerRow(image), CGImageGetColorSpace(image), CGImageGetBitmapInfo(image), CGImageGetDataProvider(image), decode, YES, CGImageGetRenderingIntent(image));
}

CGImageRef SSImageCreateCopyWithShadow(CGImageRef image, CGColorRef shadowColor, CGSize shadowOffset, CGFloat shadowRadius) {
    if (!image) {
        return NULL;
    }
    
    CGFloat shadowLenght = (FABS(MAX(shadowOffset.width, shadowOffset.height))*(CGFloat)2.0) + (shadowRadius*(CGFloat)2.0);
    const size_t width = (size_t)CGImageGetWidth(image)+shadowLenght;
    const size_t height = (size_t)CGImageGetHeight(image)+shadowLenght;
    const size_t bytesPerRow = (size_t)(width * 4);
    
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    CGContextSetShadowWithColor(ctx, shadowOffset, shadowRadius, shadowColor);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    CGContextDrawImage(ctx, CGRectIntegral(CGRectMake((width*0.5) - (CGImageGetWidth(image)*(CGFloat)0.5), (height*0.5) - (CGImageGetHeight(image)*(CGFloat)0.5), CGImageGetWidth(image), CGImageGetHeight(image))), image);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
	return imageRef;
}

CGImageRef SSImageCreateWithMaskingAverageColor(CGImageRef image) {
    CGColorRef backgroundColor = SSImageGetAverageColor(image);
    const CGFloat *backgroundColorComponents = CGColorGetComponents(backgroundColor);
    const CGFloat components[] = {backgroundColorComponents[0]*255.0, 255.0, backgroundColorComponents[1]*255.0, 255.0, backgroundColorComponents[2]*255.0, 255.0};
    return CGImageCreateWithMaskingColors(image, components);
}

CGImageRef SSImageCreateCopyByFillingVisibleAlphaWithColor(CGImageRef image, CGColorRef color) {
    if (!image) {
        return NULL;
    }
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    size_t bytesPerRow = width * 4;
    CGRect imageBounds = (CGRect){.origin.x = 0.0, .origin.y = 0.0, .size.width = width, .size.height = height};
	CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    CGContextSetBlendMode(ctx, kCGBlendModeColor);
    CGContextClipToMask(ctx, imageBounds, image);
    CGContextSetFillColorWithColor(ctx, color ? color : SSColorGetBlackColor());
    CGContextFillRect(ctx, imageBounds);
    CGImageRef coloredImage = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return coloredImage;
}

CGImageRef SSImageCreateCopyByFillingVisibleAlphaWithGradient(CGImageRef image, CGGradientRef gradient) {
    if (!image)
        return NULL;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    size_t bytesPerRow = width * 4;
    CGRect imageBounds = (CGRect){.origin.x = 0.0, .origin.y = 0.0, .size.width = width, .size.height = height};
	CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(ctx, imageBounds, image);
    CGContextClipToMask(ctx, imageBounds, image);
    CGContextSetBlendMode(ctx, kCGBlendModeSourceAtop);
    SSContextDrawLinearGradient(ctx, gradient, imageBounds, 90.0);
    CGImageRef coloredImage = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return coloredImage;
}

#if !TARGET_OS_WATCH

#if ((!TARGET_OS_IPHONE && defined(__MAC_10_8)) || (TARGET_OS_IPHONE && defined(__IPHONE_5_0)))

CGImageRef SSImageCreateCopyAutoEnhanced(CGImageRef image) {
    return image ? SSImageCreateCopyWithFilters(image, [[CIImage imageWithCGImage:image] autoAdjustmentFiltersWithOptions:@{kCIImageAutoAdjustEnhance:@YES}], nil) : NULL;
}

#endif

CGImageRef SSImageCreateBlackAndWhite(CGImageRef image) {
    if (!image) {
        return NULL;
    }
    
    CIColor *color = nil;
#if TARGET_OS_IPHONE
    color = [[[CIColor alloc] initWithColor:[UIColor whiteColor]] autorelease];
#else
    color = [[[CIColor alloc] initWithColor:[NSColor whiteColor]] autorelease];
#endif
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:@"inputColor", color, @"inputIntensity", @1.0, nil];
    if (!filter) {
        return NULL;
    }
    
    return SSImageCreateCopyWithFilters(image, @[filter], nil);
}

CGImageRef SSImageCreateCopyWithFalseColor(CGImageRef image, CGColorRef color) {
    if (!image || !color) {
        return NULL;
    }
    
    CIColor *falseColor = [CIColor colorWithCGColor:color];
    return SSImageCreateCopyWithFilters(image, @[[CIFilter filterWithName:@"CIFalseColor" keysAndValues:@"inputColor0", falseColor, @"inputColor1", falseColor, nil]], nil);
}

CGImageRef SSImageCreateCopyWithFilters(CGImageRef image, NSArray *filters, CIContext *context) {
    if (!image) {
        return NULL;
    }
    
    if (!context) {
#if 0
#if TARGET_OS_IPHONE
        context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@NO}];
#else
        CGContextRef ctx = CGBitmapContextCreate(NULL, CGImageGetWidth(image), CGImageGetHeight(image), 8, CGImageGetWidth(image) * 4, SSAutorelease(CGColorSpaceCreateDeviceRGB()), kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
        context = [CIContext contextWithCGContext:ctx options:@{kCIContextUseSoftwareRenderer:@NO}];
        CGContextRelease(ctx);
#endif
#else
        context = [CIContext sharedContext];
#endif
    }
    
    CIImage *outputImage = [CIImage imageWithCGImage:image];
    for (CIFilter *filter in filters) {
        [filter setValue:outputImage forKey:kCIInputImageKey];
        outputImage = [filter valueForKey:kCIOutputImageKey];
    }
    
    CGImageRef filteredImage = NULL;
    @synchronized(context) {
        filteredImage = [context createCGImage:outputImage fromRect:outputImage.extent];
    }
    return filteredImage;
}

#if ((!TARGET_OS_IPHONE && defined(__MAC_10_5)) || (TARGET_OS_IPHONE && defined(__IPHONE_7_0)))

CGImageRef SSImageCreateShadowWithColor(CGImageRef image, CGColorRef shadowColor, CGFloat blur) {
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputRadius", @(blur), nil];
    if (!filter) {
        NSLog(@"SSImageCreateShadowWithColor(), Warning!, CIGaussianBlur is not available…");
        return NULL;
    }
    
    size_t shadowLenght = (size_t)CEIL(blur*(CGFloat)6.0);
    size_t width = CGImageGetWidth(image)+shadowLenght;
    size_t height = CGImageGetHeight(image)+shadowLenght;
    size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    CGImageRef colorImage = SSAutorelease(SSImageCreateCopyByFillingVisibleAlphaWithColor(image, shadowColor));
    if (!colorImage) {
        return NULL;
    }
    
    CGImageRef filteredImage = SSAutorelease(SSImageCreateCopyWithFilters(colorImage, @[filter], nil));
    if (!filteredImage) {
        return NULL;
    }
    
    CGRect imageBounds = SSRectCenteredSize((CGRect){.origin.x = 0.0, .origin.y = 0.0, .size.width = width, .size.height = height}, SSImageGetSize(filteredImage));
    CGContextDrawImage(ctx, imageBounds, filteredImage);
    
    return CGBitmapContextCreateImage(ctx);
}

CGImageRef SSImageCreateShadow(CGImageRef image, CGFloat blur) {
    return SSImageCreateShadowWithColor(image, SSColorGetBlackColor(), blur);
}

#endif
#endif

CGImageRef SSImageCreateHighlightImage(CGImageRef image, CGColorRef color, CGFloat blur, Boolean fill) {
    if (!image) {
        return NULL;
    }
    
    CGImageRef colorImage = SSAutorelease(SSImageCreateCopyByFillingVisibleAlphaWithColor(image, color));
    if (!colorImage) {
        return NULL;
    }
    
    size_t shadowLenght = (size_t)CEIL(blur*(CGFloat)6.0);
    size_t width = CGImageGetWidth(image)+shadowLenght;
    size_t height = CGImageGetHeight(image)+shadowLenght;
    size_t bytesPerRow = width * 4;
    CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst));
    if (!ctx) {
        return NULL;
    }
    
    CGRect imageBounds = (CGRect){.origin.x = 0.0, .origin.y = 0.0, .size.width = width, .size.height = height};
    CGRect colorBounds = SSRectCenteredSize(imageBounds, SSImageGetSize(colorImage));
    CGRect shadowBounds = CGRectInset(colorBounds, FLOOR(blur*(CGFloat)0.8), FLOOR(blur*(CGFloat)0.8));
    
    CGContextSetShadowWithColor(ctx, CGSizeZero, blur, color);
    for (NSInteger idx = 0; idx < 3; idx++) {
        CGContextDrawImage(ctx, shadowBounds, colorImage);
    }
    
    CGContextClipToMask(ctx, shadowBounds, colorImage);
    CGContextSetFillColorWithColor(ctx, color);
    CGContextFillRect(ctx, shadowBounds);
    
    if (!fill) {
        CGRect maskBounds = CGRectInset(shadowBounds, 3.0, 3.0);
        CGContextClipToMask(ctx, maskBounds, colorImage);
        CGContextClearRect(ctx, maskBounds);
    }
    
    return CGBitmapContextCreateImage(ctx);
}

CGImageRef SSImageCreateFocusRing(CGImageRef image, CGColorRef color, CGFloat blur) {
    return SSImageCreateHighlightImage(image, color, blur, true);
}

CGImageRef SSImageCreateMask(CGImageRef image) {
    return CGImageMaskCreate(CGImageGetWidth(image), CGImageGetHeight(image), CGImageGetBitsPerComponent(image), CGImageGetBitsPerPixel(image), CGImageGetBytesPerRow(image), CGImageGetDataProvider(image), NULL, false);
}

CGImageRef SSImageByConvertingToColorSpaceNameIfNeeded(CGImageRef image, CFStringRef spaceName) {
    if (image) {
        NSString *colorSpaceName = (__bridge NSString *) SSAutorelease(CGColorSpaceCopyName(CGImageGetColorSpace(image)));
        if (colorSpaceName && ![colorSpaceName isEqualToString:(__bridge NSString *)spaceName]) {
            CGColorSpaceRef space = NULL;
            if ([(__bridge NSString *)spaceName isEqualToString:kSSColorSpaceDeviceRGB]) {
                //FIXME: This does not work on 10.11
                space = SSColorSpaceGetDeviceRGB();
            } else {
                space = SSAutorelease(CGColorSpaceCreateWithName(spaceName));
            }
            
            if (space) {
                CGImageRef convertedImage = SSAutorelease(CGImageCreateCopyWithColorSpace(image, space));
                if (convertedImage) {
                    image = convertedImage;
                } else {
                    SSDebugLog(@"SSImageByConvertingToColorSpaceNameIfNeeded() Warning! Failed to convert image to color space %@...", (__bridge NSString *)spaceName);
                }
            }
        }
    }
    return image;
}

CFDataRef SSImageGetData(CGImageRef image) {
    CFDataRef imageData = NULL;
    if (image) {
#if 0
        CFDataRef pixelData = SSAutorelease(CGDataProviderCopyData(CGImageGetDataProvider(image)));
        if (pixelData)
            imageData = SSAutorelease(CFDataCreate(NULL, CFDataGetBytePtr(pixelData), CFDataGetLength(pixelData)));
#endif
        if (!imageData) {
            CGFloat alpha = SSImageGetAlpha(image);
#if TARGET_OS_IPHONE
            if (alpha == 1.0) {
                imageData = (__bridge CFDataRef)UIImageJPEGRepresentation([UIImage imageWithCGImage:image], 1.0);
            } else {
                imageData = (__bridge CFDataRef)UIImagePNGRepresentation([UIImage imageWithCGImage:image]);
            }
#else
            NSBitmapImageFileType fileType = NSPNGFileType;
            NSDictionary *properties = nil;
            if (alpha == 1.0) {
                fileType = NSJPEGFileType;
                properties = @{NSImageCompressionFactor: @1.0};
            }
            
            imageData = (__bridge CFDataRef)[[[[NSBitmapImageRep alloc] initWithCGImage:image] autorelease] representationUsingType:fileType properties:properties];
#endif
        }
    }
    
    return imageData;
}

CGSize SSImageGetSize(CGImageRef image) {
    return image ? CGSizeMake((CGFloat)CGImageGetWidth(image), (CGFloat)CGImageGetHeight(image)) : CGSizeZero;
}

CGFloat SSImageGetAlpha(CGImageRef image) {
    if (image) {
        unsigned char pixel[1] = {0};
        CGContextRef ctx = CGBitmapContextCreate(pixel, 1, 1, 8, 1, NULL, kCGBitmapByteOrderDefault|kCGImageAlphaOnly);
        CGContextDrawImage(ctx, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
        CGContextRelease(ctx);
        return pixel[0]/255.0;
    }
    return 0.0;
}

CGColorRef SSImageGetAverageColor(CGImageRef image) {
    if (image) {
        CGColorSpaceRef colorSpace = SSColorSpaceGetDeviceRGB();
        unsigned char rgba[4];
        CGContextRef ctx = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGBitmapByteOrder32Big|kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(ctx, CGRectMake(0, 0, 1, 1), image);
        CGContextRelease(ctx);
        
        if (rgba[3] > 0) {
            CGFloat alpha = ((CGFloat)rgba[3])/255.0;
            CGFloat multiplier = alpha/255.0;
            return SSAutorelease(CGColorCreate(colorSpace, (const CGFloat[]){((CGFloat)rgba[0])*multiplier, ((CGFloat)rgba[1])*multiplier, ((CGFloat)rgba[2])*multiplier, alpha}));
        } else {
            return SSAutorelease(CGColorCreate(colorSpace, (const CGFloat[]){((CGFloat)rgba[0])/255.0, ((CGFloat)rgba[1])/255.0, ((CGFloat)rgba[1])/255.0, ((CGFloat)rgba[3])/255.0}));
        }
    }
    return NULL;
}

CGImageRef SSImageGetCGImage(id image) {
    CGImageRef imageRef = NULL;
    if ([image isKindOfClass:NSClassFromString(@"__NSCFType")] && (CFGetTypeID((__bridge CFTypeRef)image) == CGImageGetTypeID())) {
        imageRef = (__bridge CGImageRef)image;
    }
#if TARGET_OS_IPHONE
    else if ([image isKindOfClass:[UIImage class]]) {
        imageRef = [image CGImage];
    }
#else
    else if ([image isKindOfClass:[NSImage class]]) {
        imageRef = [image CGImageForProposedRect:NULL context:nil hints:nil];
    }
#endif
    return imageRef;
}
