//
//  TextModel.h
//  zText
//
//  Created by zykhbl on 15-10-17.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

typedef enum {
	HREF  = 1 << 0,
	EMOJI = 1 << 1,
    IMAGE = 1 << 2,
    AUDIO = 1 << 3,
    VIDEO = 1 << 4
} TextType;

#import <Foundation/Foundation.h>

@interface TextModel : NSObject

@property (nonatomic, assign) TextType type;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) NSRange range;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) UIImage *emoji;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGRect rect;

@end
