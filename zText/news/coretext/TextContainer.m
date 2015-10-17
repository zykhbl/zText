//
//  TextContainer.m
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import "TextContainer.h"

@implementation TextContainer

@synthesize originString;
@synthesize parser;
@synthesize emojiChache;
@synthesize array;

@synthesize attributedString;
@synthesize textFramesetter;
@synthesize frame;
@synthesize textFrame;
@synthesize hasEmoji;

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

static CGFloat getAscent(void *ref){
    return [(__bridge TextModel*)ref emojiHeight];
}

static CGFloat getDescent(void *ref){
    return 0.0;
}

static CGFloat getWidth(void* ref){
    return [(__bridge TextModel*)ref emojiWidth];
}

- (void)containInSize:(CGSize)size {
    [self.parser parseText:self.originString inArray:self.array];
    
    self.attributedString = [[NSMutableAttributedString alloc] initWithString:self.originString];
    
    TextAttributes *textAttributes = [[TextAttributes alloc] init];
    [textAttributes fillTextFont:[UIFont systemFontOfSize:MinFontSize].fontName fontSize:MinFontSize textColor:NormalColor lineSpacing:5.0 lineAlignment:NSTextAlignmentLeft lineBreakMode:kCTLineBreakByWordWrapping];
    [self fillTextAttributes:textAttributes inRange:NSMakeRange(0, [self.originString length])];
    
    self.hasEmoji = NO;
    for (TextModel *textModel in self.array) {
        switch (textModel.type) {
            case HREF: {
                [self.attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)textModel.color.CGColor range:textModel.range];
                break;
            }
            case EMOJI: {
                self.hasEmoji = YES;
                
                textModel.emoji = [self emojiForKey:textModel.text];
                textModel.emojiWidth = 20.0;
                textModel.emojiHeight = 15.0;
                
                CTRunDelegateCallbacks callbacks;
                memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
                callbacks.version = kCTRunDelegateCurrentVersion;
                callbacks.getAscent = getAscent;
                callbacks.getDescent = getDescent;
                callbacks.getWidth = getWidth;
                CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(textModel));
                
                [self.attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)textModel.color.CGColor range:textModel.range];
                [self.attributedString addAttribute:(NSString*)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:textModel.range];
                
                CFRelease(runDelegate);
                break;
            }
            case IMAGE: {
                
                break;
            }
                
            default:
                break;
        }
    }
    
    self.textFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(self.attributedString));
    
    self.frame = CGRectZero;
    frame.size = CTFramesetterSuggestFrameSizeWithConstraints(self.textFramesetter, CFRangeMake(0, 0), NULL, CGSizeMake(size.width, CGFLOAT_MAX), NULL);
    frame.size.width
    = size.width;
    
    CGMutablePathRef textPath = CGPathCreateMutable();
    CGPathAddRect(textPath, NULL, self.frame);
    self.textFrame = CTFramesetterCreateFrame(self.textFramesetter, CFRangeMake(0,0), textPath, NULL);
    CGPathRelease(textPath);
    
    if (self.hasEmoji) {
        [self calculateRectOfEmoji];
    }    
}

- (void)calculateRectOfEmoji {
    NSArray *lines = (NSArray *)CTFrameGetLines(self.textFrame);
    int lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, 0), lineOrigins);
    
    for (int i = 0; i < lineCount; ++i) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        for (id runObj in runObjArray) {
            CTRunRef run = (__bridge CTRunRef)runObj;
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef runDelegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (runDelegate == nil) {
                continue;
            }
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent + 4.0;
            
            CGPathRef pathRef = CTFrameGetPath(self.textFrame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            CGRect emojiRect = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            emojiRect.size.height += 5.0;
            
            TextModel *textModel = CTRunDelegateGetRefCon(runDelegate);
            textModel.emojiRect = emojiRect;
        }
    }
}

@end
