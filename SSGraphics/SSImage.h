//
//  SSImage.h
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#if !TARGET_OS_WATCH
#import <CoreImage/CIContext.h>
#import <CoreImage/CIFilter.h>
#import <CoreImage/CIImage.h>
#import <CoreImage/CIColor.h>
#endif
#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import <AppKit/NSGradient.h>
#import <QuickLook/QuickLook.h>
#endif
#import "SSGeometry.h"

CF_ASSUME_NONNULL_BEGIN

SS_EXPORT bool SSImageWriteToURL(CGImageRef image, CFURLRef url, __nullable CFDictionaryRef properties);
SS_EXPORT bool SSImageWriteToPath(CGImageRef image, NSString *path, __nullable CFDictionaryRef properties);

#if NS_BLOCKS_AVAILABLE

CF_IMPLICIT_BRIDGING_ENABLED

SS_EXPORT CGImageRef __nullable SSImageCreate(CGSize size, void (^__nullable drawingHandler)(CGContextRef __nullable ctx)) NS_AVAILABLE(10_6, 4_0);

CF_IMPLICIT_BRIDGING_DISABLED

#endif

SS_EXPORT CGImageRef __nullable SSImageCreateWithImageResourceNamedInBundle(NSBundle *bundle, NSString *imageName) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateWithURL(CFURLRef url) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateWithPath(NSString *path) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateWithData(CFDataRef data) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateThumbnail(CGImageRef image, NSInteger maxPixelSize) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageThumbnailCreateWithSource(CGImageSourceRef source, NSInteger maxPixelSize) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageThumbnailCreateWithURL(CFURLRef url, NSInteger maxPixelSize) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageThumbnailCreateWithPath(NSString *path, NSInteger maxPixelSize) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageThumbnailCreateWithData(CFDataRef data, NSInteger maxPixelSize) CF_RETURNS_RETAINED;
#if !TARGET_OS_WATCH
SS_EXPORT CGImageRef __nullable SSImageCreateWithCIImage(CIImage *image) CF_RETURNS_RETAINED;
#endif

#if !TARGET_OS_IPHONE

CF_IMPLICIT_BRIDGING_ENABLED

SS_EXPORT CGImageRef __nullable SSImageCreateWithIconRef(IconRef iconRef, CGSize size);

CF_IMPLICIT_BRIDGING_DISABLED

SS_EXPORT CGImageRef __nullable SSImageCreateWithIconRefAtURL(CFURLRef url, CGSize size) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, NA) SS_DEPRECATED;
SS_EXPORT CGImageRef __nullable SSImageCreateWithPreviewOfItemAtURL(CFURLRef url, CGSize size) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateWithGradient(NSGradient *gradient, CGSize size, CGFloat angle) CF_RETURNS_RETAINED;

#endif

SS_EXPORT CGImageRef __nullable SSImageCreateWithColor(CGColorRef color, CGSize size) CF_RETURNS_RETAINED NS_AVAILABLE(10_6, 4_0);
SS_EXPORT CGImageRef __nullable SSImageCreateWithCGGradient(CGGradientRef gradient, CGSize size, CGFloat angle) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 4_0);
SS_EXPORT CGImageRef __nullable SSImageCreateWithEPSDataProvider(CGDataProviderRef data) CF_RETURNS_RETAINED NS_AVAILABLE(10_6, NA);
SS_EXPORT CGImageRef __nullable SSImageCreateWithCGPDFPage(CGPDFPageRef page, CGFloat dpi) CF_RETURNS_RETAINED NS_AVAILABLE(10_6, 4_0);
SS_EXPORT CGImageRef __nullable SSImageCreateWithCGPDFDocument(CGPDFDocumentRef document, size_t pageNumber, CGFloat dpi) CF_RETURNS_RETAINED NS_AVAILABLE(10_6, 4_0);
SS_EXPORT CGImageRef __nullable SSImageCreateCopyWithSize(CGImageRef image, CGSize size, SSRectResizingMethod resizingMethod) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateCopyWithScaleFactor(CGImageRef image, CGFloat scaleFactor) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateCopyAutoLeveled(CGImageRef image) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateCopy(CGImageRef image, CGSize size) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 4_0) SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateCopyAutoEnhanced(CGImageRef image) CF_RETURNS_RETAINED NS_AVAILABLE(10_8, 5_0) SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateBlackAndWhite(CGImageRef image) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 4_0) SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateGrayscale(CGImageRef image) CF_RETURNS_RETAINED SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateFlipped(CGImageRef image, bool vertically) CF_RETURNS_RETAINED SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateRotatedClockwiseByAngle(CGImageRef image, CGFloat angle) CF_RETURNS_RETAINED SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateRotated(CGImageRef image, float angle) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 5_0) SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateWithBrightness(CGImageRef image, float brightness) CF_RETURNS_RETAINED SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateWithContrast(CGImageRef image, float contrast) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 5_0) SS_UNAVAILABLE_WATCHOS ;
SS_EXPORT CGImageRef __nullable SSImageCreateWithGammaCorrection(CGImageRef image, float gamma) CF_RETURNS_RETAINED SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateWithSharpness(CGImageRef image, int32_t bias) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 5_0) SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateUnsharpness(CGImageRef image, int32_t bias) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 5_0) SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateWithGaussianBlur(CGImageRef image, int32_t bias) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 5_0) SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateWithBoxBlur(CGImageRef image, CGFloat blur) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 5_0) SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateWithEdgeDetection(CGImageRef image, int32_t bias) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 5_0) SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateWithEmboss(CGImageRef image, int32_t bias) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 5_0) SS_UNAVAILABLE_WATCHOS;
SS_EXPORT CGImageRef __nullable SSImageCreateWithMaskingAverageColor(CGImageRef image) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateCopyByFillingVisibleAlphaWithColor(CGImageRef image, __nullable CGColorRef color) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateCopyByFillingVisibleAlphaWithGradient(CGImageRef image, CGGradientRef gradient) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateCopyWithFalseColor(CGImageRef image, CGColorRef color) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 6_0) SS_UNAVAILABLE_WATCHOS;
#if !TARGET_OS_WATCH
SS_EXPORT CGImageRef __nullable SSImageCreateCopyWithFilters(CGImageRef image, NSArray <CIFilter *>* __nullable filters, CIContext * __nullable context) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 6_0);
#endif
SS_EXPORT CGImageRef __nullable SSImageCreateSepia(CGImageRef image) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateInverted(CGImageRef image) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateCopyWithShadow(CGImageRef image, __nullable CGColorRef shadowColor, CGSize shadowOffset, CGFloat shadowRadius) CF_RETURNS_RETAINED;
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_5)) || (TARGET_OS_IPHONE && defined(__IPHONE_7_0)))
SS_EXPORT CGImageRef __nullable SSImageCreateShadowWithColor(CGImageRef image, __nullable CGColorRef shadowColor, CGFloat blur) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 7_0);
SS_EXPORT CGImageRef __nullable SSImageCreateShadow(CGImageRef image, CGFloat blur) CF_RETURNS_RETAINED NS_AVAILABLE(10_5, 7_0);
#endif
SS_EXPORT CGImageRef __nullable SSImageCreateHighlightImage(CGImageRef image, __nullable CGColorRef color, CGFloat blur, Boolean fill) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateFocusRing(CGImageRef image, __nullable CGColorRef color, CGFloat blur) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageCreateMask(CGImageRef image) CF_RETURNS_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageByConvertingToColorSpaceNameIfNeeded(CGImageRef image, CFStringRef spaceName) CF_RETURNS_NOT_RETAINED NS_AVAILABLE(10_5, NA);

CF_IMPLICIT_BRIDGING_ENABLED

SS_EXPORT CGImageRef __nullable SSImageCreateWithLabelNumber(NSInteger labelNumber, CGSize size) CF_RETURNS_RETAINED NS_AVAILABLE(10_6, 5_0);

CF_IMPLICIT_BRIDGING_DISABLED

SS_EXPORT CGImageRef __nullable SSImageCreateBadgeWithLabel(NSString *label, id font, CGFloat borderWidth) CF_RETURNS_RETAINED;
SS_EXPORT CFDataRef __nullable SSImageGetData(CGImageRef image) CF_RETURNS_NOT_RETAINED;
SS_EXPORT CGSize SSImageGetSize(CGImageRef image);
SS_EXPORT CGFloat SSImageGetAlpha(CGImageRef image);
SS_EXPORT CGColorRef __nullable SSImageGetAverageColor(CGImageRef image) CF_RETURNS_NOT_RETAINED;
SS_EXPORT CGImageRef __nullable SSImageGetCGImage(id image) CF_RETURNS_NOT_RETAINED NS_AVAILABLE(10_6, 4_0);

CF_ASSUME_NONNULL_END
