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
@synthesize otherTextFrame;
@synthesize advanceCount;
@synthesize lineIndex;

- (void)dealloc {
    if (self.textFramesetter) {
		CFRelease(self.textFramesetter);
		self.textFramesetter = NULL;
	}
    
    if (self.textFrame) {
		CFRelease(self.textFrame);
		self.textFrame = NULL;
	}
    
    if (self.otherTextFrame) {
		CFRelease(self.otherTextFrame);
		self.otherTextFrame = NULL;
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
        self.lineIndex = 0;
        self.advanceCount = 1;
    }
    
    return self;
}

- (void)fillTextAttributes:(TextAttributes*)textAttributes inRange:(NSRange)range {
    CGFloat lineSpacing = textAttributes.lineSpacing;
    CTTextAlignment lineAlignment = textAttributes.lineAlignment;
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
    NSLog(@"=========: %f", [[NSDate new] timeIntervalSince1970]);
    [self.parser parseText:self.originString inHrefArray:self.hrefArray inEmojiArray:self.emojiArray inImageArray:self.imageArray];
    
    self.attributedString = [[NSMutableAttributedString alloc] initWithString:self.originString];
    
    TextAttributes *textAttributes = [[TextAttributes alloc] init];
    [textAttributes fillTextFont:[UIFont systemFontOfSize:MinFontSize].fontName fontSize:MinFontSize textColor:NormalColor lineSpacing:LineSpacing lineAlignment:NSTextAlignmentJustified lineBreakMode:NSLineBreakByWordWrapping];
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
        textModel.width = 18.0;
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
    
    frame.size.height += (self.imageArray.count + 5) * (ImageHeight + LineSpacing * 2.0);
    
    if (self.advanceCount > self.imageArray.count) {
        self.advanceCount = self.imageArray.count;
    }
    
    for (int i = 0; i < self.advanceCount; ++i) {
        TextModel *textModel = [self.imageArray objectAtIndex:i];
        [self calculateRectOfImage:textModel inTextFrame:self.textFrame];
        
        CFRelease(self.textFrame);
        
        textPath = CGPathCreateMutable();
        CGPathAddRect(textPath, NULL, self.frame);
        CFDictionaryRef clipPathsDict = [self clipPaths];
        self.textFrame = CTFramesetterCreateFrame(self.textFramesetter, CFRangeMake(0,0), textPath, clipPathsDict);
        CFRelease(clipPathsDict);
        CGPathRelease(textPath);
    }
    
    NSLog(@"=========: %f", [[NSDate new] timeIntervalSince1970]);
}

- (void)containInBackgroud {
    for (int i = self.advanceCount; i < self.imageArray.count; ++i) {
        TextModel *textModel = [self.imageArray objectAtIndex:i];
        
        if (i == self.advanceCount) {
            [self calculateRectOfImage:textModel inTextFrame:self.textFrame];
        } else {
            [self calculateRectOfImage:textModel inTextFrame:self.otherTextFrame];
        }
        
        if (self.otherTextFrame) {
            CFRelease(self.otherTextFrame);
        }
        
        CGMutablePathRef textPath = CGPathCreateMutable();
        CGPathAddRect(textPath, NULL, self.frame);
        CFDictionaryRef clipPathsDict = [self clipPaths];
        self.otherTextFrame = CTFramesetterCreateFrame(self.textFramesetter, CFRangeMake(0,0), textPath, clipPathsDict);
        CFRelease(clipPathsDict);
        CGPathRelease(textPath);
    }
    
    @synchronized (self) {
        if (self.otherTextFrame) {
            CFRelease(self.textFrame);
            self.textFrame = self.otherTextFrame;
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
                CGRect emojiRect = CGRectMake(0.0, 0.0, 20.0, 20.0);
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                emojiRect.origin.x = lineOrigins[i].x + xOffset;
                emojiRect.origin.y = lineOrigins[0].y - lineOrigins[i].y;
                textModel.rect = emojiRect;
            }
        }
    }
}

- (void)calculateRectOfImage:(TextModel*)model inTextFrame:(CTFrameRef)textFrameRef {
    NSArray *lines = (NSArray *)CTFrameGetLines(textFrameRef);
    int lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(textFrameRef, CFRangeMake(0, 0), lineOrigins);
    
    for (; lineIndex < lineCount; ++lineIndex) {
        CTLineRef line = (__bridge CTLineRef)lines[lineIndex];
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
                CGFloat y = lineOrigins[0].y - lineOrigins[lineIndex + 1].y;
                CGFloat w = self.frame.size.width;
                CGFloat h = ImageHeight - (MinFontSize + LineSpacing);
                if (textModel.range.location == 0) {
                    h -= MinFontSize + LineSpacing;
                }
                
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
