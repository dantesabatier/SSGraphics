//
//  CIContext+SSAdditions.m
//  SSGraphics
//
//  Created by Dante Palacios on 28/01/17.
//  Copyright © 2017 Dante Palacios. All rights reserved.
//

#import "CIContext+SSAdditions.h"
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/NSApplication.h>
#endif

@implementation CIContext (SSAdditions)

+ (CIContext *)sharedContext {
    static CIContext *sharedContext = nil;
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_6)) || (TARGET_OS_IPHONE && defined(__IPHONE_4_0)))
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id obj = nil;
        NSString *notificationName = nil;
#if TARGET_OS_IPHONE
        obj = [UIApplication sharedApplication];
        notificationName = UIApplicationWillTerminateNotification;
#else
        obj = NSApp;
        notificationName = NSApplicationWillTerminateNotification;
#endif
        __block __unsafe_unretained id observer = [[NSNotificationCenter defaultCenter] addObserverForName:notificationName object:obj queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [sharedContext release];
            sharedContext = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
        
#if TARGET_OS_IPHONE
        sharedContext = [[CIContext alloc] initWithOptions:@{kCIContextUseSoftwareRenderer:@NO}];
#else
        sharedContext = [[CIContext alloc] initWithOptions:@{kCIContextUseSoftwareRenderer:@NO}];//[[CIContext contextWithCGContext:SSContextGetCurrent() options:@{kCIContextUseSoftwareRenderer:@NO}] ss_retain];
#endif
        
    });
#endif
    return sharedContext;
}

@end
