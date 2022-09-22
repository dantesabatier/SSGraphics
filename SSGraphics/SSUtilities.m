//
//  SSUtilities.m
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import <TargetConditionals.h>
#import "SSUtilities.h"
#import "SSImageSource.h"
#import "SSGeometry.h"
#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#endif

static NSBundle *__ImageIOFramework = nil;

static BOOL _SSCoreGraphicsIsLoaded = NO;

__attribute__((constructor))
static void SSCoreGraphicsInit(void) {
    if (_SSCoreGraphicsIsLoaded) {
        return;
    }
    _SSCoreGraphicsIsLoaded = YES;
}

__attribute__((destructor))
static void SSCoreGraphicsDestroy(void) {
    [__ImageIOFramework release];
}

NSString *SSGraphicsGetLocalizedString(NSString *string) {
    if (!__ImageIOFramework) {
        __ImageIOFramework = [[NSBundle bundleWithIdentifier:@"com.apple.ImageIO.framework"] ss_retain];
    }
    NSString *localizedString = [__ImageIOFramework localizedStringForKey:string value:string table:@"CGImageSource"];
    return localizedString ? localizedString : string;
}

