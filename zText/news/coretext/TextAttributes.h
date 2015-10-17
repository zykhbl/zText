//
//  TextAttributes.h
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CTFont.h>

#define MinFontSize 13.0
#define NormalColor [UIColor blackColor]
#define HightLinkColor [UIColor colorWithRed:73.0/255.0 green:175.0/255.0 blue:76.0/255.0 alpha:1.0]
#define ClearColor [UIColor clearColor]

@interface TextAttributes : NSObject

@property (nonatomic, assign) CTFontRef font;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) NSTextAlignment lineAlignment;
@property (nonatomic, assign) CTLineBreakMode lineBreakMode;

- (void)fillTextFont:(NSString*)fontname fontSize:(CGFloat)size textColor:(UIColor*)color lineSpacing:(CGFloat)spacing lineAlignment:(NSTextAlignment)alignment lineBreakMode:(CTLineBreakMode)breakMode;

@end
