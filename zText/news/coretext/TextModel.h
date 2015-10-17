//
//  TextModel.h
//  zText
//
//  Created by zykhbl on 15-10-17.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

typedef enum {
	HREF,
	EMOJI,
    IMAGE
} TextType;

#import <Foundation/Foundation.h>

@interface TextModel : NSObject

@property (nonatomic, assign) TextType type;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) NSRange range;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) UIImage *emoji;
@property (nonatomic, assign) CGFloat emojiWidth;
@property (nonatomic, assign) CGFloat emojiHeight;
@property (nonatomic, assign) CGRect emojiRect;

@end
