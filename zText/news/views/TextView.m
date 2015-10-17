//
//  TextView.m
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import "TextView.h"

CGRect CTRunGetTypographicBoundsAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin) {
	CGFloat ascent, descent, leading;
    ascent = descent = leading = 0;
	CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
	CGFloat height = ascent + descent /* + leading */;
	
	CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
	
	return CGRectMake(lineOrigin.x + xOffset, lineOrigin.y - descent, width, height);
}

NSRange NSRangeFromCFRange(CFRange range) {
	return NSMakeRange(range.location, range.length);
}

BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range) {
	NSRange lineRange = NSRangeFromCFRange(CTLineGetStringRange(line));
	NSRange intersectedRange = NSIntersectionRange(lineRange, range);
	return (intersectedRange.length > 0);
}

BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range) {
	NSRange runRange = NSRangeFromCFRange(CTRunGetStringRange(run));
	NSRange intersectedRange = NSIntersectionRange(runRange, range);
	return (intersectedRange.length > 0);
}

@implementation TextView

@synthesize textContainer;
@synthesize activeLink;

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGContextSetInterpolationQuality(ctx, kCGInterpolationLow);
    CGContextSetRenderingIntent(ctx, kCGRenderingIntentDefault);
    CGContextSetAllowsFontSmoothing(ctx, FALSE);
    CGContextSetShouldSmoothFonts(ctx, FALSE);
    CGContextSetAllowsFontSubpixelPositioning(ctx, FALSE);
    CGContextSetShouldSubpixelPositionFonts(ctx, FALSE);
    CGContextSetAllowsFontSubpixelQuantization(ctx, FALSE);
    CGContextSetShouldSubpixelQuantizeFonts(ctx, FALSE);
    CGContextSetFlatness(ctx, 0.0);
    
    CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.0f, -1.0f));
    
    if (self.activeLink) {
        [self drawActiveLinkHighlightForRect:self.textContainer.frame];
    }
    
    CTFrameDraw(self.textContainer.textFrame, ctx);
    
    CGContextRestoreGState(ctx);
}

-(void)drawActiveLinkHighlightForRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
    
    CGContextSetInterpolationQuality(ctx, kCGInterpolationLow);
    CGContextSetRenderingIntent(ctx, kCGRenderingIntentDefault);
    CGContextSetAllowsFontSmoothing(ctx, FALSE);
    
	CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y));
    
	[[UIColor colorWithWhite:0.4 alpha:0.3] setFill];
	
	NSRange activeLinkRange = self.activeLink.range;
	
	CFArrayRef lines = CTFrameGetLines(self.textContainer.textFrame);
    if (lines == NULL) {
        return;
    }
	CFIndex lineCount = CFArrayGetCount(lines);
	CGPoint lineOrigins[lineCount];
	CTFrameGetLineOrigins(self.textContainer.textFrame, CFRangeMake(0,0), lineOrigins);
    
    NSURL *url = [(NSTextCheckingResult*)self.activeLink URL];
    if ([[url scheme] isEqualToString:@"touchComment"]) {
        CGRect unionRect = CGRectZero;
        CGRect maxRect = CGRectZero;
        
        for (CFIndex lineIndex = 0; lineIndex < lineCount; lineIndex++) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
            
            if (!CTLineContainsCharactersFromStringRange(line, activeLinkRange)) {
                continue;
            }
            
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            CFIndex runCount = CFArrayGetCount(runs);
            for (CFIndex runIndex = 0; runIndex < runCount; runIndex++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, runIndex);
                
                if (!CTRunContainsCharactersFromStringRange(run, activeLinkRange)) {
                    continue;
                }
                
                CGRect linkRunRect = CTRunGetTypographicBoundsAsRect(run, line, lineOrigins[lineIndex]);
                linkRunRect = CGRectIntegral(linkRunRect);
                linkRunRect.size.height += 3.0;
                linkRunRect.size.width = self.textContainer.frame.size.width;
                
                if (CGRectIsEmpty(unionRect)) {
                    unionRect = linkRunRect;
                    maxRect = linkRunRect;
                } else {
                    if (unionRect.origin.y > linkRunRect.origin.y) {
                        unionRect.origin.y = linkRunRect.origin.y;
                    }
                    if (maxRect.origin.y < linkRunRect.origin.y) {
                        maxRect = linkRunRect;
                    }
                    unionRect.size.height = (maxRect.origin.y + maxRect.size.height) - unionRect.origin.y;
                }
            }
        }
        
        if (!CGRectIsEmpty(unionRect)) {
            CGContextFillRect(ctx, unionRect);
        }
    } else {
        for (CFIndex lineIndex = 0; lineIndex < lineCount; lineIndex++) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
            
            if (!CTLineContainsCharactersFromStringRange(line, activeLinkRange)) {
                continue;
            }
            
            CGRect unionRect = CGRectZero;
            
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            CFIndex runCount = CFArrayGetCount(runs);
            for (CFIndex runIndex = 0; runIndex < runCount; runIndex++) {
                CTRunRef run = CFArrayGetValueAtIndex(runs, runIndex);
                
                if (!CTRunContainsCharactersFromStringRange(run, activeLinkRange)) {
                    if (!CGRectIsEmpty(unionRect)) {
                        CGContextFillRect(ctx, unionRect);
                        unionRect = CGRectZero;
                    }
                    continue;
                }
                
                CGRect linkRunRect = CTRunGetTypographicBoundsAsRect(run, line, lineOrigins[lineIndex]);
                linkRunRect = CGRectIntegral(linkRunRect);
                linkRunRect.size.height += 3.0;
                
                if (CGRectIsEmpty(unionRect)) {
                    unionRect = linkRunRect;
                } else {
                    unionRect = CGRectUnion(unionRect, linkRunRect);
                }
            }
            if (!CGRectIsEmpty(unionRect)) {
                CGContextFillRect(ctx, unionRect);
            }
        }
    }
    
	CGContextRestoreGState(ctx);
}

@end
