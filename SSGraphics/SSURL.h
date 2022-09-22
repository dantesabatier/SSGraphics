//
//  SSURL.h
//  SSGraphics
//
//  Created by Dante Palacios on 28/01/17.
//  Copyright © 2017 Dante Palacios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#import "SSDefines.h"

CF_ASSUME_NONNULL_BEGIN

typedef CFURLRef SSURL;

SS_EXPORT CFStringRef SSURLGetUTI(CFURLRef URL) NS_REFINED_FOR_SWIFT; //CF_SWIFT_NAME(getter:SSURL.UTI(self:));
SS_EXPORT CGSize SSURLGetPixelSize(CFURLRef URL) NS_REFINED_FOR_SWIFT; //CF_SWIFT_NAME(getter:SSURL.pixelSize(self:));

CF_ASSUME_NONNULL_END

