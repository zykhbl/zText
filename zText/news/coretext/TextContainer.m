//
//  TextContainer.m
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import "TextContainer.h"
#import "TextAttributes.h"
#import "TextModel.h"

@implementation TextContainer

@synthesize originString;
@synthesize parser;
@synthesize emojiChache;
@synthesize array;

@synthesize attributedString;
@synthesize textFramesetter;
@synthesize frame;
@synthesize textFrame;

- (void)dealloc {
    if (self.textFramesetter) {
		CFRelease(self.textFramesetter);
		self.textFramesetter = NULL;
	}
    
    if (self.textFrame) {
		CFRelease(self.textFrame);
		self.textFrame = NULL;
	}
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.parser = [[TextParser alloc] init];
        self.emojiChache = [[EmojiCache alloc] init];
        self.array = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)fillTextAttributes:(TextAttributes*)textAttributes inRange:(NSRange)range {
    CGFloat lineSpacing = textAttributes.lineSpacing;
    NSTextAlignment lineAlignment = textAttributes.lineAlignment;
    CTLineBreakMode lineBreakMode = textAttributes.lineBreakMode;
    
    CTParagraphStyleSetting paragraphStyle_settings[] = {
		{kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpacing), &lineSpacing},
        {kCTParagraphStyleSpecifierAlignment, sizeof(lineAlignment), &lineAlignment},
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(lineBreakMode), &lineBreakMode}
    };
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphStyle_settings, sizeof(paragraphStyle_settings) / sizeof(paragraphStyle_settings[0]));
    
	CFStringRef keys[] = {kCTFontAttributeName, kCTParagraphStyleAttributeName, kCTForegroundColorAttributeName};
	CFTypeRef values[] = {textAttributes.font, paragraphStyle, textAttributes.textColor.CGColor};
    CFDictionaryRef attributes = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys)/sizeof(keys[0]), NULL, NULL);
    
    [self.attributedString setAttributes:(__bridge NSDictionary*)attributes range:range];
    
    CFRelease(paragraphStyle);
    CFRelease(attributes);
}

- (UIImage*)emojiForKey:(NSString*)key {
    UIImage *emoji = [self.emojiChache emojiForKey:key];
    if (emoji == nil) {
        emoji = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", key]];
//        emoji = [UIImage decodedImageWithImage:emoji];
        if (emoji != nil) {
            [self.emojiChache setEmoji:emoji forKey:key];
        }
    }
    
    return emoji;
}

- (void)containInSize:(CGSize)size {
    [self.parser parseText:self.originString inArray:self.array];
    
    self.attributedString = [[NSMutableAttributedString alloc] initWithString:self.originString];
    
    TextAttributes *textAttributes = [[TextAttributes alloc] init];
    [textAttributes fillTextFont:[UIFont systemFontOfSize:MinFontSize].fontName fontSize:MinFontSize textColor:NormalColor lineSpacing:5 lineAlignment:NSTextAlignmentLeft lineBreakMode:kCTLineBreakByTruncatingTail];
    [self fillTextAttributes:textAttributes inRange:NSMakeRange(0, [self.originString length])];
    
    for (TextModel *textModel in self.array) {
        switch (textModel.type) {
            case AT: {
                [self.attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)textModel.color.CGColor range:textModel.range];
                break;
            }
            case HREF: {
                [self.attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)textModel.color.CGColor range:textModel.range];
                break;
            }
            case EMOJI: {
//                [self.attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)textModel.color.CGColor range:textModel.range];
                break;
            }
            case IMAGE: {
                [self.attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)textModel.color.CGColor range:textModel.range];
                break;
            }
                
            default:
                break;
        }
    }
    
    self.textFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(self.attributedString));
    
    self.frame = CGRectZero;
    frame.size = CTFramesetterSuggestFrameSizeWithConstraints(self.textFramesetter, CFRangeMake(0, 0), NULL, CGSizeMake(size.width, CGFLOAT_MAX), NULL);
    
    CGMutablePathRef textPath = CGPathCreateMutable();
    CGPathAddRect(textPath, NULL, self.frame);
    self.textFrame = CTFramesetterCreateFrame(self.textFramesetter, CFRangeMake(0,0), textPath, NULL);
    CGPathRelease(textPath);
}

@end
