//
//  SSURL.m
//  SSGraphics
//
//  Created by Dante Palacios on 28/01/17.
//  Copyright © 2017 Dante Palacios. All rights reserved.
//

#import <TargetConditionals.h>
#import "SSURL.h"
#import "SSImageSource.h"
#import "SSGeometry.h"
#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#endif

CFStringRef SSURLGetUTI(CFURLRef URL) {
    return SSAutorelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, SSAutorelease(CFURLCopyPathExtension(URL)), NULL));
}

CGSize SSURLGetPixelSize(CFURLRef URL) {
    CGSize pixelSize = CGSizeZero;
    if (URL) {
        CFStringRef inUTI = SSURLGetUTI(URL);
        if (UTTypeConformsTo(inUTI, kUTTypeImage)) {
            pixelSize = SSImageSourceGetPixelSize(SSAutorelease(CGImageSourceCreateWithURL(URL, NULL)));
        }
#if !TARGET_OS_IPHONE
        if (SSSizeIsEmpty(pixelSize) && ((__bridge NSURL *)URL).isFileURL) {
            MDItemRef metadataItem = SSAutorelease(MDItemCreate(NULL, SSAutorelease(CFURLCopyFileSystemPath(URL, kCFURLPOSIXPathStyle))));
            if (metadataItem) {
                pixelSize = CGSizeMake(((__bridge NSNumber *)SSAutorelease(MDItemCopyAttribute(metadataItem, kMDItemPixelWidth))).doubleValue, ((__bridge NSNumber *)SSAutorelease(MDItemCopyAttribute(metadataItem, kMDItemPixelHeight))).doubleValue);
            } 
        }
#endif
    }
    return pixelSize;
}
