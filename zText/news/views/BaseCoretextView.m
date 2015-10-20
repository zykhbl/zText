//
//  BaseCoretextView.m
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import "BaseCoretextView.h"
#import "UIImageView+WebCache.h"

@implementation BaseCoretextView

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
    
    CTFrameDraw(self.textContainer.textFrame, ctx);
    
    for (TextModel *textModel in self.textContainer.emojiArray) {
        if (textModel.emoji != nil) {
            UIGraphicsBeginImageContext(textModel.rect.size);
            CGContextDrawImage(ctx, textModel.rect, [textModel.emoji  CGImage]);
            UIGraphicsEndImageContext();
        }
    }
    
    CGContextRestoreGState(ctx);
}

- (void)addImageViews {
    for (TextModel *textModel in self.textContainer.imageArray) {
        CGRect rect = textModel.rect;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:rect];
        [imgView sd_setImageWithURL:[[NSURL alloc] initWithString:textModel.text]];
        [self addSubview:imgView];
    }
}

@end
