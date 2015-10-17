//
//  TextAttributes.m
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import "TextAttributes.h"

@implementation TextAttributes

@synthesize font;
@synthesize fontSize;
@synthesize textColor;
@synthesize lineSpacing;
@synthesize lineAlignment;
@synthesize lineBreakMode;

- (void)clearFont {
    if (self.font) {
        CFRelease(self.font);
		self.font = NULL;
    }
}

- (void)dealloc {
    [self clearFont];
}

- (CTFontRef)createFont:(NSString*)fontname {
    CFStringRef cf_fontname = CFStringCreateWithCString(kCFAllocatorDefault, [fontname UTF8String], 0);
    CTFontRef cfont = CTFontCreateWithName(cf_fontname, MinFontSize, NULL);
    CFRelease(cf_fontname);
    
    return cfont;
}

- (void)fillTextFont:(NSString*)fontname fontSize:(CGFloat)fontSize textColor:(UIColor*)textColor lineSpacing:(CGFloat)lineSpacing lineAlignment:(NSTextAlignment)lineAlignment lineBreakMode:(CTLineBreakMode)lineBreakMode {
    [self clearFont];
    self.font = [self createFont:fontname];
    
    self.fontSize = MinFontSize;
    self.textColor = NormalColor;
    self.lineSpacing = 5;
    self.lineAlignment = NSTextAlignmentLeft;
    self.lineBreakMode = kCTLineBreakByTruncatingTail;
}

@end
