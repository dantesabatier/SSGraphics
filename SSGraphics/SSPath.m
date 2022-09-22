//
//  SSPath.m
//  SSGraphics
//
//  Created by Dante Palacios on 15/11/13.
//  Copyright (c) 2013 Dante Palacios. All rights reserved.
//

#import "SSPath.h"

CGPathRef SSPathCreateWithRect(CGRect rect, SSRectCorner rectCorners, CGFloat cornerRadius, const CGAffineTransform *transform) {
    if (!cornerRadius || !rectCorners) {
        return CGPathCreateWithRect(rect, transform);
    }
    
    cornerRadius = MIN(cornerRadius, 0.5 * MIN(CGRectGetWidth(rect), CGRectGetHeight(rect)));
    
	CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, transform, CGRectGetMinX(rect), CGRectGetMinY(rect) + cornerRadius);
    
    if (rectCorners & SSRectCornerBottomLeft) {
        CGPathAddArcToPoint(path, transform, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMinX(rect) + cornerRadius, CGRectGetMinY(rect), cornerRadius);
    } else {
        CGPathAddLineToPoint(path, transform, CGRectGetMinX(rect), CGRectGetMinY(rect));
    }
    
    if (rectCorners & SSRectCornerBottomRight) {
        CGPathAddArcToPoint(path, transform, CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect), CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect) + cornerRadius, cornerRadius);
    } else {
        CGPathAddLineToPoint(path, transform, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    }
    
    if (rectCorners & SSRectCornerTopRight) {
        CGPathAddArcToPoint(path, transform, CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect), CGRectGetMinX(rect) + CGRectGetWidth(rect) - cornerRadius, CGRectGetMinY(rect) + CGRectGetHeight(rect), cornerRadius);
    } else {
        CGPathAddLineToPoint(path, transform, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    }
    
    if (rectCorners & SSRectCornerTopLeft) {
        CGPathAddArcToPoint(path, transform, CGRectGetMinX(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), cornerRadius);
    } else {
        CGPathAddLineToPoint(path, transform, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    }
    
    CGPathCloseSubpath(path);
    
    return path;
}

CGPathRef SSPathCreateWithRoundedRect(CGRect rect, CGFloat cornerRadius, const CGAffineTransform *transform) {
    return SSPathCreateWithRect(rect, SSRectAllCorners, cornerRadius, transform);
}

CGPathRef SSPathCreateWithArrow(CGRect rect, SSRectCorner rectCorners, CGFloat cornerRadius, CGSize arrowSize, SSRectPosition arrowPosition) {
    bool wantsArrow = !SSSizeIsEmpty(arrowSize);
    if ((!cornerRadius || !rectCorners) && !wantsArrow) {
        return CGPathCreateWithRect(rect, NULL);
    }
    
    cornerRadius = MIN(cornerRadius, 0.5 * MIN(CGRectGetWidth(rect), CGRectGetHeight(rect)));
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    if (!wantsArrow) {
        arrowPosition = 0;
        CGPathMoveToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect) + cornerRadius);
    } else {
        switch (arrowPosition) {
            case SSRectPositionLeft: {
                CGPathMoveToPoint(path, NULL, CGRectGetMinX(rect), FLOOR(CGRectGetMidY(rect) + (arrowSize.width*(CGFloat)0.5)));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMinX(rect) - arrowSize.height), CGRectGetMidY(rect));
                CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), FLOOR(CGRectGetMidY(rect) - (arrowSize.width*(CGFloat)0.5)));
            }
                break;
            case SSRectPositionBottom: {
                CGPathMoveToPoint(path, NULL, FLOOR(CGRectGetMidX(rect) - (arrowSize.width*(CGFloat)0.5)), CGRectGetMinY(rect));
                CGPathAddLineToPoint(path, NULL, CGRectGetMidX(rect), FLOOR(CGRectGetMinY(rect) - arrowSize.height));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMidX(rect) + (arrowSize.width*(CGFloat)0.5)), CGRectGetMinY(rect));
            }
                break;
            case SSRectPositionRight: {
                CGPathMoveToPoint(path, NULL, CGRectGetMaxX(rect), FLOOR(CGRectGetMidY(rect) - (arrowSize.width*(CGFloat)0.5)));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMaxX(rect) + arrowSize.height), CGRectGetMidY(rect));
                CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), FLOOR(CGRectGetMidY(rect) + (arrowSize.width*(CGFloat)0.5)));
            }
                break;
            case SSRectPositionTop: {
                CGPathMoveToPoint(path, NULL, FLOOR(CGRectGetMidX(rect) + (arrowSize.width*(CGFloat)0.5)), CGRectGetMaxY(rect));
                CGPathAddLineToPoint(path, NULL, CGRectGetMidX(rect), FLOOR(CGRectGetMaxY(rect) + arrowSize.height));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMidX(rect) - (arrowSize.width*(CGFloat)0.5)), CGRectGetMaxY(rect));
            }
                break;
            case SSRectPositionLeftTop: {
                CGPathMoveToPoint(path, NULL, CGRectGetMinX(rect), FLOOR(CGRectGetMaxY(rect) - arrowSize.width));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMinX(rect) - arrowSize.height), FLOOR(CGRectGetMaxY(rect) - (arrowSize.width*(CGFloat)1.5)));
                CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), FLOOR(CGRectGetMaxY(rect) - (arrowSize.width*(CGFloat)2.0)));
            }
                break;
            case SSRectPositionBottomRight: {
                CGPathMoveToPoint(path, NULL, FLOOR(CGRectGetMaxX(rect) - (arrowSize.width*(CGFloat)2.0)), CGRectGetMinY(rect));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMaxX(rect) - (arrowSize.width*(CGFloat)1.5)), FLOOR(CGRectGetMinY(rect) - arrowSize.height));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMaxX(rect) - arrowSize.width), CGRectGetMinY(rect));
            }
                break;
            case SSRectPositionRightTop: {
                CGPathMoveToPoint(path, NULL, CGRectGetMaxX(rect), FLOOR(CGRectGetMaxY(rect) - (arrowSize.width*(CGFloat)2.0)));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMaxX(rect) + arrowSize.height), FLOOR(CGRectGetMaxY(rect) - (arrowSize.width*(CGFloat)1.5)));
                CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), FLOOR(CGRectGetMaxY(rect) - arrowSize.width));
            }
                break;
            case SSRectPositionTopRight: {
                CGPathMoveToPoint(path, NULL, FLOOR(CGRectGetMaxX(rect) - arrowSize.width), CGRectGetMaxY(rect));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMaxX(rect) - (arrowSize.width*(CGFloat)1.5)), FLOOR(CGRectGetMaxY(rect) + arrowSize.height));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMaxX(rect) - (arrowSize.width*(CGFloat)2.0)), CGRectGetMaxY(rect));
            }
                break;
            case SSRectPositionLeftBottom: {
                CGPathMoveToPoint(path, NULL, CGRectGetMinX(rect), FLOOR(CGRectGetMinY(rect) + (arrowSize.width*(CGFloat)2.0)));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMinX(rect) - arrowSize.height), FLOOR(CGRectGetMinY(rect) + (arrowSize.width*(CGFloat)1.5)));
                CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), FLOOR(CGRectGetMinY(rect) + arrowSize.width));
            }
                break;
            case SSRectPositionBottomLeft: {
                CGPathMoveToPoint(path, NULL, FLOOR(CGRectGetMinX(rect) + arrowSize.width), CGRectGetMinY(rect));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMinX(rect) + (arrowSize.width*(CGFloat)1.5)), FLOOR(CGRectGetMinY(rect) - arrowSize.height));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMinX(rect) + (arrowSize.width*(CGFloat)2.0)), CGRectGetMinY(rect));
            }
                break;
            case SSRectPositionRightBottom: {
                CGPathMoveToPoint(path, NULL, CGRectGetMaxX(rect), FLOOR(CGRectGetMinY(rect) + arrowSize.width));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMaxX(rect) + arrowSize.height), FLOOR(CGRectGetMinY(rect) + (arrowSize.width*(CGFloat)1.5)));
                CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), FLOOR(CGRectGetMinY(rect) + (arrowSize.width*(CGFloat)2.0)));
            }
                break;
            case SSRectPositionTopLeft: {
                CGPathMoveToPoint(path, NULL, FLOOR(CGRectGetMinX(rect) + (arrowSize.width*(CGFloat)2.0)), CGRectGetMaxY(rect));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMinX(rect) + (arrowSize.width*(CGFloat)1.5)), FLOOR(CGRectGetMaxY(rect) + arrowSize.height));
                CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMinX(rect) + arrowSize.width), CGRectGetMaxY(rect));
            }
                break;
            case SSRectPositionCenter:
                break;
        }
    }
    
    switch (arrowPosition) {
        case SSRectPositionLeft:
        case SSRectPositionLeftTop:
        case SSRectPositionLeftBottom: {
            if (rectCorners & SSRectCornerBottomLeft) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMinX(rect) + cornerRadius, CGRectGetMinY(rect), cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect));
            }
            
            if (rectCorners & SSRectCornerBottomRight) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect), CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect) + cornerRadius, cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect));
            }
            
            if (rectCorners & SSRectCornerTopRight) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect), CGRectGetMinX(rect) + CGRectGetWidth(rect) - cornerRadius, CGRectGetMinY(rect) + CGRectGetHeight(rect), cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
            }
            
            
            if (rectCorners & SSRectCornerTopLeft) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect));
            }
            
        }
            break;
        case SSRectPositionBottom:
        case SSRectPositionBottomRight:
        case SSRectPositionBottomLeft: {
            if (rectCorners & SSRectCornerBottomRight) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect), CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect) + cornerRadius, cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect));
            }
            
            if (rectCorners & SSRectCornerTopRight) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect), CGRectGetMinX(rect) + CGRectGetWidth(rect) - cornerRadius, CGRectGetMinY(rect) + CGRectGetHeight(rect), cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
            }
            
            if (rectCorners & SSRectCornerTopLeft) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect));
            }
            
            if (rectCorners & SSRectCornerBottomLeft) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMinX(rect) + cornerRadius, CGRectGetMinY(rect), cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect));
            }
            
        }
            break;
        case SSRectPositionRight:
        case SSRectPositionRightTop:
        case SSRectPositionRightBottom: {
            if (rectCorners & SSRectCornerTopRight) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect), CGRectGetMinX(rect) + CGRectGetWidth(rect) - cornerRadius, CGRectGetMinY(rect) + CGRectGetHeight(rect), cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
            }
            
            if (rectCorners & SSRectCornerTopLeft) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect));
            }
            
            if (rectCorners & SSRectCornerBottomLeft) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMinX(rect) + cornerRadius, CGRectGetMinY(rect), cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect));
            }
            
            if (rectCorners & SSRectCornerBottomRight) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect), CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect) + cornerRadius, cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect));
            }
        }
            break;
        case SSRectPositionTop:
        case SSRectPositionTopRight:
        case SSRectPositionTopLeft: {
            if (rectCorners & SSRectCornerTopLeft) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect));
            }
            
            if (rectCorners & SSRectCornerBottomLeft) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMinX(rect) + cornerRadius, CGRectGetMinY(rect), cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect));
            }
            
            if (rectCorners & SSRectCornerBottomRight) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect), CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect) + cornerRadius, cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect));
            }
            
            if (rectCorners & SSRectCornerTopRight) {
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect), CGRectGetMinX(rect) + CGRectGetWidth(rect) - cornerRadius, CGRectGetMinY(rect) + CGRectGetHeight(rect), cornerRadius);
            } else {
                CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
            }
        }
            break;
        case SSRectPositionCenter:
            break;
    }
    
    CGPathCloseSubpath(path);
    
    return path;
}

#if !TARGET_OS_WATCH

CGPathRef SSPathCreateWithString(CFStringRef string, CTFontRef font, const CGAffineTransform *transform) {
    CGMutablePathRef path = CGPathCreateMutable();
    CFIndex numValues = 1;
	CFStringRef keys[1] = {kCTFontAttributeName};
	CFTypeRef values[1] = {font};
	CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, numValues, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFAttributedStringRef attributedString = CFAttributedStringCreate(kCFAllocatorDefault, string, attributes);
    CTLineRef line = CTLineCreateWithAttributedString(attributedString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++) {
            CFRange range = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, range, &glyph);
            CTRunGetPositions(run, range, &position);
            CGPathRef p = CTFontCreatePathForGlyph(runFont, glyph, NULL);
            CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
            CGPathAddPath(path, &t, p);
            CGPathRelease(p);
        }
    }
    CFRelease(line);
    CFRelease(attributes);
    CFRelease(attributedString);
    
    if (transform == NULL) {
        return path;
    }
    
    return CGPathCreateCopyByTransformingPath(SSAutorelease(path), transform);
}

CGPathRef SSPathCreateWithImage(CGImageRef image, const CGAffineTransform *transform) {
#if (!TARGET_OS_IPHONE & defined(__MAC_10_6)) || (TARGET_OS_IPHONE && defined(__IPHONE_5_0))
    if (!image) {
         return NULL;
    }
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    size_t bytes = (width + 0x0000000F) & ~0x0000000F;
    unsigned char *data = calloc(height, bytes);
    CGRect imageBounds = CGRectMake(0, 0, width, height);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceGray();
    CGContextRef ctx = CGBitmapContextCreate(data, width, height, 8, width, space, kCGBitmapByteOrderDefault|kCGImageAlphaNone);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    CGContextSetShouldAntialias(ctx, 0);
    CGContextClipToMask(ctx, imageBounds, image);
    CGContextSetGrayFillColor(ctx, 1.0, 1.0);
    CGContextFillRect(ctx, imageBounds);
    CGContextRelease(ctx);
    CGColorSpaceRelease(space);
    
    NSMutableDictionary *segments = [[NSMutableDictionary alloc] init];
    void (^insert)(CGPoint start, CGPoint end) = ^(CGPoint start, CGPoint end) {
        CGPoint startPoint = CGPointMake(start.x, height - start.y - 1);
        CGPoint endPoint = CGPointMake(end.x, height - end.y - 1);
        NSString *startKey = SSStringFromPoint(startPoint);
        NSString *endKey = SSStringFromPoint(endPoint);
        NSArray *segment = @[startKey, endKey];
        NSMutableArray *segmentsAtStart = segments[startKey];
        if (!segmentsAtStart) {
            segmentsAtStart = [[[NSMutableArray alloc] init] autorelease];
            segments[startKey] = segmentsAtStart;
        }
        
        [segmentsAtStart addObject:segment];
        
        NSMutableArray *segmentsAtEnd = segments[endKey];
        if (!segmentsAtEnd) {
            segmentsAtEnd = [[[NSMutableArray alloc] init] autorelease];
            segments[endKey] = segmentsAtEnd;
        }
        [segmentsAtEnd addObject:segment];
    };
    
    void (^remove)(NSArray *segment) = ^(NSArray *segment) {
        NSString *startKey = segment[0];
        NSString *endKey = segment[1];
        
        NSMutableArray *segmentsAtStart = segments[startKey];
        NSMutableArray *segmentsAtEnd = segments[endKey];
        
        if (segmentsAtStart.count == 1) {
            [segments removeObjectForKey:startKey];
        } else {
            [segmentsAtStart removeObject:segment];
        }
        
        if (segmentsAtEnd.count == 1) {
            [segments removeObjectForKey:endKey];
        } else {
            [segmentsAtEnd removeObject:segment];
        }
            
    };
	
	int row = 0;
	for (row = 0; row < height; ++row) {
		int col = 0;
		unsigned char *pixels = data + (row * bytes);
		for (col = 0; col < width; ++col) {
			if (pixels[col] != 0x00) {
                if ((col == 0) || (pixels[col - 1]) == 0x00) {
                    insert(CGPointMake(col, row), CGPointMake(col, row + 1));
                }
				
                if (col == (width - 1) || pixels[col + 1] == 0x00) {
                    insert(CGPointMake(col + 1, row), CGPointMake(col + 1, row + 1));
                }
                
                if (row == 0 || *(pixels + col - bytes) == 0x00) {
                    insert(CGPointMake(col, row), CGPointMake(col + 1, row));
                }
                
                if (row == (height - 1) || *(pixels + col + bytes) == 0x00) {
                    insert(CGPointMake(col, row + 1), CGPointMake(col + 1, row + 1));
                }
			}
		}
	}
    
    free(data);
    
    NSString *key = segments.keyEnumerator.nextObject;
    CGPoint initialPoint = SSPointFromString(key);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, transform, initialPoint.x, initialPoint.y);
    
    void(^add)(CGPoint point, CGPoint *point1, CGPoint *point2) = ^(CGPoint point, CGPoint *point1, CGPoint *point2) {
        if (CGPointEqualToPoint(*point1, *point2)) {
            *point2 = point;
            return;
        }
        
        if ((point1->x == point2->x && point2->x == point.x) || (point1->y == point2->y && point2->y == point.y))
            *point2 = point;
        else {
            CGPathAddLineToPoint(path, transform, point.x, point.y);
            *point1 = *point2;
            *point2 = point;
        }
    };
    
    void(^flush)(CGPoint *point1, CGPoint *point2) = ^(CGPoint *point1, CGPoint *point2) {
        CGPoint point = *point2;
        CGPathAddLineToPoint(path, transform, point.x, point.y);
    };
    
    CGPoint point1 = initialPoint;
    CGPoint point2 = initialPoint;
    NSMutableArray *segment = nil;
    while ((segment = segments[key])) {
        CGPoint point = SSPointFromString(key);
        NSArray *firstSegment = (segment)[0];
		CGPoint start = SSPointFromString((firstSegment)[0]);
		CGPoint end = SSPointFromString((firstSegment)[1]);
        if (CGPointEqualToPoint(point, start)) {
            add(end, &point1, &point2);
            key = SSStringFromPoint(end);
        } else {
            add(start, &point1, &point2);
            key = SSStringFromPoint(start);
        }
        
        remove(firstSegment);
    }
    
    flush(&point1, &point2);
    
    CGPathCloseSubpath(path);
    
    [segments release];
    
    return path;
    
#else
    return NULL;
#endif
}
#endif
