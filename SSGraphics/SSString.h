//
//  SSString.h
//  SSGraphics
//
//  Created by Dante Palacios on 25/12/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SSDefines.h"

CF_ASSUME_NONNULL_BEGIN

SS_EXPORT CGSize SSStringGetSizeWithFont(id string, id font);
SS_EXPORT CGSize SSStringGetSize(NSString *string, NSString *fontName, CGFloat fontSize);

CF_ASSUME_NONNULL_END
