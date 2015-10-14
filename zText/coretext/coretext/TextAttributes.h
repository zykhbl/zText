//
//  TextAttributes.h
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CTFont.h>

#define MinFontSize 14.0
#define NormalColor [UIColor blackColor]
#define HightLinkColor [UIColor colorWithHexString:@"#49af4c"]

@interface TextAttributes : NSObject

@property (nonatomic, assign) CTFontRef font;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) NSTextAlignment lineAlignment;
@property (nonatomic, assign) CTLineBreakMode lineBreakMode;

- (void)fillTextFont:(NSString*)fontname fontSize:(CGFloat)fontSize textColor:(UIColor*)textColor lineSpacing:(CGFloat)lineSpacing lineAlignment:(NSTextAlignment)lineAlignment lineBreakMode:(CTLineBreakMode)lineBreakMode;

@end
