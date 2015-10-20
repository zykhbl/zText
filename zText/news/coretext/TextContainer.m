//
//  TextContainer.m
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import "TextContainer.h"
#import "SDWebImageDecoder.h"

#define LineSpacing 5.0
#define ImageHeight 160.0

@implementation TextContainer

@synthesize originString;
@synthesize parser;
@synthesize emojiChache;
@synthesize hrefArray;
@synthesize emojiArray;
@synthesize imageArray;
@synthesize imagePathArray;

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
        self.emojiChache = [EmojiCache defaultEmojiCache];
        self.hrefArray = [[NSMutableArray alloc] init];
        self.emojiArray = [[NSMutableArray alloc] init];
        self.imageArray = [[NSMutableArray alloc] init];
        self.imagePathArray = [[NSMutableArray alloc] init];
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
        emoji = [UIImage decodedImageWithImage:emoji];
        if (emoji != nil) {
            [self.emojiChache setEmoji:emoji forKey:key];
        }
    }
    
    return emoji;
}

static CGFloat getAscent(void *ref){
    return [(__bridge TextModel*)ref height];
}

static CGFloat getDescent(void *ref){
    return 0.0;
}

static CGFloat getWidth(void* ref){
    return [(__bridge TextModel*)ref width];
}

- (void)addRunDelegate:(TextModel*)textModel {
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
}

- (void)containInSize:(CGSize)size {
    [self.parser parseText:self.originString inHrefArray:self.hrefArray inEmojiArray:self.emojiArray inImageArray:self.imageArray];
    
    self.attributedString = [[NSMutableAttributedString alloc] initWithString:self.originString];
    
    TextAttributes *textAttributes = [[TextAttributes alloc] init];
    [textAttributes fillTextFont:[UIFont systemFontOfSize:MinFontSize].fontName fontSize:MinFontSize textColor:NormalColor lineSpacing:LineSpacing lineAlignment:NSTextAlignmentLeft lineBreakMode:kCTLineBreakByWordWrapping];
    [self fillTextAttributes:textAttributes inRange:NSMakeRange(0, [self.originString length])];
    
    for (TextModel *textModel in self.hrefArray) {
        switch (textModel.type) {
            case HREF :
            case AUDIO: {
                [self.attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)textModel.color.CGColor range:textModel.range];
                break;
            }
            case VIDEO: {
                break;
            }
                
            default:
                break;
        }
    }
    
    for (TextModel *textModel in self.emojiArray) {
        textModel.emoji = [self emojiForKey:textModel.text];
        textModel.width = 20.0;
        textModel.height = 15.0;
        [self addRunDelegate:textModel];
    }
    
    for (TextModel *textModel in self.imageArray) {
        textModel.width = 1.0;
        textModel.height = 15.0;
        [self addRunDelegate:textModel];
    }
    
    self.textFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)(self.attributedString));
    
    self.frame = CGRectZero;
    frame.size = CTFramesetterSuggestFrameSizeWithConstraints(self.textFramesetter, CFRangeMake(0, 0), NULL, CGSizeMake(size.width, CGFLOAT_MAX), NULL);
    frame.size.width = size.width;
    
    CGMutablePathRef textPath = CGPathCreateMutable();
    CGPathAddRect(textPath, NULL, self.frame);
    self.textFrame = CTFramesetterCreateFrame(self.textFramesetter, CFRangeMake(0,0), textPath, NULL);
    CGPathRelease(textPath);
    
    frame.size.height += (self.imageArray.count + 1) * (ImageHeight + LineSpacing * 2.0);
    
    for (TextModel *textModel in self.imageArray) {
        if (textModel.type == IMAGE) {
            [self calculateRectOfImage:textModel];
            
            CFRelease(self.textFrame);
            
            textPath = CGPathCreateMutable();
            CGPathAddRect(textPath, NULL, self.frame);
            CFDictionaryRef clipPathsDict = [self clipPaths];
            self.textFrame = CTFramesetterCreateFrame(self.textFramesetter, CFRangeMake(0,0), textPath, clipPathsDict);
            CFRelease(clipPathsDict);
            CGPathRelease(textPath);
        }
    }
    
    if (self.emojiArray.count > 0) {
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
            
            TextModel *textModel = CTRunDelegateGetRefCon(runDelegate);
            if (textModel.type == EMOJI) {
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
                
                textModel.rect = emojiRect;
            }
        }
    }
}

- (void)calculateRectOfImage:(TextModel*)model {
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
            
            TextModel *textModel = CTRunDelegateGetRefCon(runDelegate);
            if (textModel == model) {
                CGFloat x = 0.0;
                CGFloat y = lineOrigins[0].y - lineOrigins[i + 1].y;
                CGFloat w = self.frame.size.width;
                CGFloat h = ImageHeight - (MinFontSize + LineSpacing);
                
                CGRect imageRect = CGRectMake(x, y,  w, h);
                CGAffineTransform transform = CGAffineTransformIdentity;
                transform = CGAffineTransformScale(transform, 1, -1);
                transform = CGAffineTransformTranslate(transform, 0, -self.frame.size.height);
                CGPathRef clipPath = CGPathCreateWithRect(imageRect, &transform);
                
                NSDictionary *clipPathDict = [NSDictionary dictionaryWithObject:(__bridge id)(clipPath) forKey:(__bridge NSString *)kCTFramePathClippingPathAttributeName];
                [self.imagePathArray addObject:clipPathDict];
                CFRelease(clipPath);
                
                imageRect.size.height += MinFontSize + LineSpacing * 4.0;
                if (textModel.range.location == 0) {
                    CGFloat diffHeight = MinFontSize + LineSpacing;
                    imageRect.origin.y -= diffHeight;
                    imageRect.size.height += diffHeight;
                }
                textModel.rect = imageRect;
                
                return;
            }
        }
    }
}

- (CFDictionaryRef)clipPaths {
    int eFrameWidth = 0;
    CFNumberRef frameWidth = CFNumberCreate(NULL, kCFNumberNSIntegerType, &eFrameWidth);
    
    int eFillRule = kCTFramePathFillEvenOdd;
    CFNumberRef fillRule = CFNumberCreate(NULL, kCFNumberNSIntegerType, &eFillRule);
    
    int eProgression = kCTFrameProgressionTopToBottom;
    CFNumberRef progression = CFNumberCreate(NULL, kCFNumberNSIntegerType, &eProgression);
    
    CFStringRef keys[] = { kCTFrameClippingPathsAttributeName, kCTFramePathFillRuleAttributeName, kCTFrameProgressionAttributeName, kCTFramePathWidthAttributeName};
    CFTypeRef values[] = { (__bridge CFTypeRef)(self.imagePathArray), fillRule, progression, frameWidth};
    
    CFDictionaryRef clipPathsDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    return clipPathsDict;
}

- (CGSize)fitSize {
    NSArray *lines = (NSArray *)CTFrameGetLines(self.textFrame);
    int lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, 0), lineOrigins);
    return CGSizeMake(self.frame.size.width, lineOrigins[0].y - lineOrigins[lineCount - 1].y + LineSpacing + MinFontSize);
}

@end
