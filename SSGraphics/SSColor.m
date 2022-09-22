//
//  SSColor.m
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import "SSColor.h"
#import "SSColorSpace.h"
#import "SSImage.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/NSColorSpace.h>
#endif
#import <objc/objc-sync.h>

static CGColorRef __SSBlackColor = NULL;
static CGColorRef __SSWhiteColor = NULL;
static CGColorRef __SSGrayColor = NULL;
static CGColorRef __SSLightGrayColor = NULL;
static CGColorRef __SSHighlightColor = NULL;
static CGColorRef __SSShadowColor = NULL;
static CGColorRef __SSClearColor = NULL;
static CGColorRef __SSRedColor = NULL;
static CGColorRef __SSBlueColor = NULL;
static CGColorRef __SSGreenColor = NULL;

static BOOL _SSColorIsLoaded = NO;

__attribute__((constructor))
static void SSColorInit(void) {
    if (_SSColorIsLoaded)
        return;
    
    _SSColorIsLoaded = YES;
}

__attribute__((destructor))
static void SSColorDestroy(void) {
    CGColorRelease(__SSBlackColor);
    CGColorRelease(__SSWhiteColor);
    CGColorRelease(__SSGrayColor);
    CGColorRelease(__SSLightGrayColor);
    CGColorRelease(__SSHighlightColor);
    CGColorRelease(__SSShadowColor);
    CGColorRelease(__SSClearColor);
    CGColorRelease(__SSRedColor);
    CGColorRelease(__SSBlueColor);
    CGColorRelease(__SSGreenColor);
}

static void drawPatternImageCallback(void *info, CGContextRef ctx) {
    CGContextDrawImage(ctx, CGRectMake(0, 0, CGImageGetWidth((CGImageRef)info), CGImageGetHeight((CGImageRef)info)), (CGImageRef)info);
}

static void releasePatternImageCallback(void *info) {
    CGImageRelease((CGImageRef)info);
}

CGColorRef SSColorCreateWithPatternImage(CGImageRef CF_CONSUMED image, CGFloat scale) {
    //NSCParameterAssert(image);
    //NSCParameterAssert(scale >= 1.0);
    if (image) {
        size_t width = CGImageGetWidth(image);
        size_t height = CGImageGetHeight(image);
        CGPatternCallbacks callbacks = {0, &drawPatternImageCallback, &releasePatternImageCallback};
        CGPatternRef pattern = CGPatternCreate(image, CGRectMake(0, 0, width, height), CGAffineTransformMake(1/scale, 0, 0, 1/scale, 0, 0), width, height, kCGPatternTilingConstantSpacing, true, &callbacks);
        CGColorSpaceRef space = CGColorSpaceCreatePattern(NULL);
        CGFloat components[1] = {1.0};
        CGColorRef color = CGColorCreateWithPattern(space, pattern, components);
        CGColorSpaceRelease(space);
        CGPatternRelease(pattern);
        return color;
    }
    return NULL;
}

CGColorRef SSColorCreateDeviceRGB(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    return CGColorCreate(SSColorSpaceGetDeviceRGB(), (const CGFloat[]){red, green, blue, alpha});
}

CGColorRef SSColorCreateDeviceGray(CGFloat gray, CGFloat alpha) {
    return CGColorCreate(SSColorSpaceGetDeviceGray(), (const CGFloat[]){gray, alpha});
}

CGColorRef SSColorCreateWithString(NSString *string) {
    CGColorRef color = NULL;
    if (string) {
        NSArray *components = [string componentsSeparatedByString:@" "];
        size_t numberOfComponents = components.count;
        CGFloat (^__ss_float_value)(id obj) = ^CGFloat(id obj) {
#if CGFLOAT_IS_DOUBLE
            return [obj doubleValue];
#else
            return [obj floatValue];
#endif
        };
        
        switch (numberOfComponents) {
            case 2:
                color = SSColorCreateDeviceRGB(__ss_float_value(components[0]), __ss_float_value(components[0]), __ss_float_value(components[0]), __ss_float_value(components[1]));
                break;
            case 4:
                color = SSColorCreateDeviceRGB(__ss_float_value(components[0]), __ss_float_value(components[1]), __ss_float_value(components[2]), __ss_float_value(components[3]));
                break;
            default:
                SSDebugLog(@"SSColorCreateWithString(%@), Warning! invalid number of components %ld", string, numberOfComponents);
                break;
        }
    }
    return color;
}

CGColorRef SSColorCreateBlendedWithFractionOfColor(CGColorRef color, CGColorRef baseColor, CGFloat fraction) {
    if (!color || !baseColor) {
        return NULL;
    }
    
    CGFloat x = 1.0 - MIN(fraction, 1.0);
	const CGFloat *components1 = SSColorGetRGBComponents(color);
	const CGFloat *components2 = SSColorGetRGBComponents(baseColor);
    return SSColorCreateDeviceRGB(x * components1[0] + fraction * components2[0], x * components1[1] + fraction * components2[1], x * components1[2] + fraction * components2[2], 1.0);
}

CGColorRef SSColorCreateHighlightedWithLevel(CGColorRef color, CGFloat level) {
    return color ? SSColorCreateBlendedWithFractionOfColor(color, SSColorGetHighlightColor(), level) : NULL;
}

CGColorRef SSColorCreateShadowedWithLevel(CGColorRef color, CGFloat level) {
    return color ? SSColorCreateBlendedWithFractionOfColor(color, SSColorGetShadowColor(), level) : NULL;
}

CGColorRef SSColorGetContrastingLabelColor(CGColorRef color) {
    if (!color) {
        return NULL;
    }
    const CGFloat *components = SSColorGetRGBComponents(color);
    return (((components[0] + components[1] + components[2]) / (CGFloat)3.0) >= (CGFloat)0.5) ? SSColorGetBlackColor() : SSColorGetWhiteColor();
}

#if !TARGET_OS_IPHONE

CGColorRef SSColorGetSystemColor(void) {
    return SSColorGetCGColor([[NSColor alternateSelectedControlColor] colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]]);
}

CGColorRef SSColorGetCurrentControlTintColor() {
	return SSColorGetCGColor([[NSColor colorForControlTint:[NSColor currentControlTint]] colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]]);
}

#endif

CGColorRef SSColorGetBlackColor(void) {
    if (!__SSBlackColor) {
        __SSBlackColor = SSColorCreateDeviceGray(0.0, 1.0);
    }
    return __SSBlackColor;
}

CGColorRef SSColorGetWhiteColor(void) {
    if (!__SSWhiteColor) {
        __SSWhiteColor = SSColorCreateDeviceGray(1.0, 1.0);
    }
    return __SSWhiteColor;
}

CGColorRef SSColorGetGrayColor(void) {
    if (!__SSGrayColor) {
        __SSGrayColor = SSColorCreateDeviceGray(0.5, 1);
    }
    return __SSGrayColor;
}

CGColorRef SSColorGetLightGrayColor(void) {
    if (!__SSLightGrayColor) {
        __SSLightGrayColor = SSColorCreateDeviceGray(0.666667, 1);
    }
    return __SSLightGrayColor;
}

CGColorRef SSColorGetHighlightColor(void) {
    if (!__SSHighlightColor) {
        __SSHighlightColor = SSColorCreateDeviceGray(1.0, 1.0);
    }
    return __SSHighlightColor;
}

CGColorRef SSColorGetShadowColor(void) {
    if (!__SSShadowColor) {
        __SSShadowColor = SSColorCreateDeviceGray(0.33, 0.33);
    }
    return __SSShadowColor;
}

CGColorRef SSColorGetClearColor(void) {
    if (!__SSClearColor) {
        __SSClearColor = SSColorCreateDeviceGray(0.0, 0.0);
    }
    return __SSClearColor;
}

CGColorRef SSColorGetRedColor(void) {
    if (!__SSRedColor) {
        __SSRedColor = SSColorCreateDeviceRGB(1.0, 0, 0, 1);
    }
    return __SSRedColor;
}

CGColorRef SSColorGetGreenColor(void) {
    if (!__SSGreenColor) {
        __SSGreenColor = SSColorCreateDeviceRGB(0, 1, 0, 1);
    }
    return __SSGreenColor;
}

CGColorRef SSColorGetBlueColor(void) {
    if (!__SSBlueColor) {
        __SSBlueColor = SSColorCreateDeviceRGB(0, 0, 1, 1);
    }
    return __SSBlueColor;
}

NSString *SSColorGetStringRepresentation(CGColorRef color) {
    if (color) {
        const CGFloat *components = SSColorGetRGBComponents(color);
        return [NSString stringWithFormat:@"%f %f %f %f", components[0], components[1], components[2], components[3]];
    }
    return NULL;
}

const CGFloat *SSColorGetRGBComponents(CGColorRef color) {
    NSCParameterAssert(color);
    
    CGColorRef rgbColor = NULL;
    const CGFloat *components = CGColorGetComponents(color);
    size_t numberOfComponents = CGColorGetNumberOfComponents(color);
    switch (numberOfComponents) {
        case 2:
            rgbColor = SSAutorelease(SSColorCreateDeviceRGB(components[0], components[0], components[0], components[1]));
            break;
        case 4:
            rgbColor = SSAutorelease(SSColorCreateDeviceRGB(components[0], components[1], components[2], components[3]));
            break;
        default:
            SSDebugLog(@"SSColorGetRGBComponents(), Warning! invalid number of components %ld", numberOfComponents);
            rgbColor = SSAutorelease(SSColorCreateDeviceRGB(0, 0, 0, 0));
            break;
    }
    return CGColorGetComponents(rgbColor);
}

CGColorRef SSColorGetCGColor(id color) {
    CGColorRef colorRef = NULL;
    if ([color isKindOfClass:NSClassFromString(@"__NSCFType")] && (CFGetTypeID((__bridge CFTypeRef)color) == CGColorGetTypeID()))
        colorRef = (__bridge CGColorRef)color;
#if TARGET_OS_IPHONE
    else if ([color isKindOfClass:[UIColor class]])
        colorRef = [color CGColor];
#else
    else if ([color isKindOfClass:[NSColor class]]) {
        NSColor *(^validColorBlock)(void) = ^NSColor *(void) {
            NSColor *resultingColor = color;
            NSArray *spaceNames = @[NSCalibratedRGBColorSpace, NSPatternColorSpace];
            if (![spaceNames containsObject:[color colorSpaceName]]) {
                for (NSString *spaceName in spaceNames) {
                    if ((resultingColor = [color colorUsingColorSpaceName:spaceName])) {
                        break;
                    } 
                }
            }
            return resultingColor;
        };
        
        NSColor *validColor = validColorBlock();
        if (validColor) {
            switch (validColor.colorSpace.colorSpaceModel) {
                case NSPatternColorSpaceModel: {
                    CGFloat scale = 1.0;
#if 1
                    static CGRect rect = {{0, 0}, {1024, 1024}};
                    static CGContextRef ctx = NULL;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        ctx = CGBitmapContextCreate(NULL, CGRectGetWidth(rect), CGRectGetHeight(rect), 8, CGRectGetWidth(rect)*4, SSAutorelease(CGColorSpaceCreateDeviceRGB()), kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
                    });
                    scale = CGRectGetHeight(rect)/CGRectGetHeight(CGContextConvertRectToDeviceSpace(ctx, rect));
#else
#if defined(__MAC_10_7)
                    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
                        static NSView *view = nil;
                        static dispatch_once_t onceToken;
                        dispatch_once(&onceToken, ^{
                            view = [[NSView alloc] initWithFrame:SSRectMakeSquare(90)];
                        });
                        objc_sync_enter(view);
                        scale = CGRectGetWidth([view convertRectToBacking:view.bounds])/CGRectGetWidth(view.bounds);
                        objc_sync_exit(view);
                    }
#endif
#endif
                    NSImage *patternImage = validColor.patternImage;
                    if (patternImage) {
                         colorRef = SSAutorelease(SSColorCreateWithPatternImage(CGImageCreateCopy(SSImageGetCGImage(patternImage)), MAX(scale, 1.0)));
                    } else {
                        colorRef = SSColorGetClearColor();
                    }
                }
                    break;
                    
                default: {
                    CGColorSpaceRef colorSpace = validColor.colorSpace.CGColorSpace;
                    if (colorSpace) {
                        CGFloat *components = (CGFloat *)calloc(validColor.numberOfComponents, sizeof(CGFloat));
                        [validColor getComponents:components];
                        colorRef = SSAutorelease(CGColorCreate(colorSpace, components));
                        free(components);
                    }
                }
                    break;
            }
        }
    }
#endif
    return colorRef;
}

NSString *SSColorGetHexadecimalStringRepresentation(CGColorRef color) {
    if (color) {
        const CGFloat *components = SSColorGetRGBComponents(color);
        NSInteger redIntValue = components[0]*255.99999;
        NSInteger greenIntValue = components[1]*255.99999;
        NSInteger blueIntValue = components[2]*255.99999;
        return [NSString stringWithFormat:@"#%@%@%@", [NSString stringWithFormat:@"%02lx", (long)redIntValue], [NSString stringWithFormat:@"%02lx", (long)greenIntValue], [NSString stringWithFormat:@"%02lx", (long)blueIntValue]];
    }
    return nil;
}

CGColorRef SSColorShadowColorWithColor(CGColorRef color) {
    return SSAutorelease(SSColorCreateBlendedWithFractionOfColor(color, SSColorGetShadowColor(), 0.75));
}

NSArray *SSColorGetLabelColors(void) {
    NSArray *colors = nil;
#if TARGET_OS_IPHONE
    colors = @[[UIColor colorWithRed:1.000000 green:1.000000 blue:1.000000 alpha:1.000000], [UIColor colorWithRed:0.656260 green:0.656260 blue:0.656260 alpha:1.000000], [UIColor colorWithRed:0.699229 green:0.835950 blue:0.265629 alpha:1.000000], [UIColor colorWithRed:0.746105 green:0.546883 blue:0.843763 alpha:1.000000], [UIColor colorWithRed:0.339849 green:0.628916 blue:0.996109 alpha:1.000000], [UIColor colorWithRed:0.933608 green:0.851575 blue:0.265629 alpha:1.000000], [UIColor colorWithRed:0.980484 green:0.382818 blue:0.347662 alpha:1.000000], [UIColor colorWithRed:0.960952 green:0.660166 blue:0.253910 alpha:1.000000]];
#else
#if defined(__MAC_10_6)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_5) {
        colors = [NSWorkspace sharedWorkspace].fileLabelColors;
    }
#endif
    if (!colors) {
        colors = @[[NSColor colorWithRed:1.000000 green:1.000000 blue:1.000000 alpha:1.000000], [NSColor colorWithRed:0.656260 green:0.656260 blue:0.656260 alpha:1.000000], [NSColor colorWithRed:0.699229 green:0.835950 blue:0.265629 alpha:1.000000], [NSColor colorWithRed:0.746105 green:0.546883 blue:0.843763 alpha:1.000000], [NSColor colorWithRed:0.339849 green:0.628916 blue:0.996109 alpha:1.000000], [NSColor colorWithRed:0.933608 green:0.851575 blue:0.265629 alpha:1.000000], [NSColor colorWithRed:0.980484 green:0.382818 blue:0.347662 alpha:1.000000], [NSColor colorWithRed:0.960952 green:0.660166 blue:0.253910 alpha:1.000000]];
    }
#endif
    return colors;
}

