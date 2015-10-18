//
//  TextContainer.h
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "TextParser.h"
#import "EmojiCache.h"

@interface TextContainer : NSObject

@property (nonatomic, strong) NSMutableString *originString;
@property (nonatomic, strong) TextParser *parser;
@property (nonatomic, strong) EmojiCache *emojiChache;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *imagePathArray;

@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, assign) CTFramesetterRef textFramesetter;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CTFrameRef textFrame;
@property (nonatomic, assign) BOOL hasEmoji;
@property (nonatomic, assign) BOOL hasImage;

- (void)containInSize:(CGSize)size;
- (CGSize)fitSize;

@end
