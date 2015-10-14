//
//  TextContainer.h
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface TextContainer : NSObject

@property (nonatomic, strong) NSString *originString;

@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, assign) CTFramesetterRef textFramesetter;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CTFrameRef textFrame;

@end
