//
//  BaseCoretextView.h
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextContainer.h"

@interface BaseCoretextView : UIView

@property (nonatomic, strong) TextContainer *textContainer;
@property (nonatomic, strong) NSTextCheckingResult *activeLink;
@property (nonatomic, strong) NSMutableArray *emojiViewArray;
@property (nonatomic, strong) NSMutableArray *imageViewArray;

- (void)addEmojiViews;
- (void)addImageViews;

@end
