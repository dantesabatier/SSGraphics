//
//  SSUtilities.h
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#if TARGET_OS_IPHONE
#import <ImageIO/ImageIO.h>
#endif
#import "SSDefines.h"

CF_ASSUME_NONNULL_BEGIN

SS_EXPORT NSString * __nullable SSGraphicsGetLocalizedString(NSString *string);

CF_ASSUME_NONNULL_END
