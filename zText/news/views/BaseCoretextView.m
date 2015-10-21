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
@synthesize emojiViewArray;
@synthesize imageViewArray;

+ (Class)layerClass {
    return [CATiledLayer class];
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.emojiViewArray = [[NSMutableArray alloc] init];
        self.imageViewArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.0f, -1.0f));
    
    CTFrameDraw(self.textContainer.textFrame, ctx);
}

- (void)addEmojiViews {
    for (TextModel *textModel in self.textContainer.emojiArray) {
        CGRect rect = textModel.rect;
        UIImageView *emojiView = [[UIImageView alloc] initWithFrame:rect];
        [self.emojiViewArray addObject:emojiView];
        emojiView.image = textModel.emoji;
        [self addSubview:emojiView];
    }
}

- (void)addImageViews {
    for (TextModel *textModel in self.textContainer.imageArray) {
        CGRect rect = textModel.rect;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        [self.imageViewArray addObject:imageView];
        [imageView sd_setImageWithURL:[[NSURL alloc] initWithString:textModel.text]];
        [self addSubview:imageView];
    }
}

@end
