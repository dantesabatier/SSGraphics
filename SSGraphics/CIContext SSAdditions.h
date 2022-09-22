//
//  CIContext+SSAdditions.h
//  SSGraphics
//
//  Created by Dante Palacios on 28/01/17.
//  Copyright © 2017 Dante Palacios. All rights reserved.
//

#import <CoreImage/CIContext.h>
#import "SSDefines.h"

@interface CIContext (SSAdditions)

@property (class, readonly, strong) CIContext *sharedContext SS_CONST NS_AVAILABLE(10_6, 4_0);

@end
