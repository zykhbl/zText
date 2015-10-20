//
//  TextParser.m
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import "TextParser.h"
#import "RegexKitLite.h"

#define AtRegex @"(@[^：:\\s]+)"
#define HrefRegex @"(((https)|(http))?)://(?:(\\S+?)(?::(\\S+?))?@)?([a-zA-Z0-9\\-.]+)(?::(\\d+))?((?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?"
#define EmojiRegex @"\\[p[0-9]+\\]"
#define ImageHrefRegex [NSString stringWithFormat:@"%@%@", HrefRegex, @"((.png)|(.jpg)|(.gif))"]
#define AudioHrefRegex [NSString stringWithFormat:@"%@%@", HrefRegex, @"((.mp3))"]
#define CharactersToBeEscaped @"!*'();:@&=+$,%#[]"

@implementation TextParser

- (void)parseAudioHrefOfText:(NSMutableString*)originString regex:(NSString*)regex linkHead:(NSString*)linkHead inHrefArray:(NSMutableArray*)hrefArray {
    NSString *textStr = [NSString stringWithString:originString];
    NSInteger begin = 0;
    int offset = 0;
    
    NSArray *matchStrs = [originString componentsMatchedByRegex:regex];
    for (NSString *matchStr in matchStrs) {
        NSRange range = [textStr rangeOfString:matchStr];
        textStr = [textStr substringFromIndex:range.location + range.length];
        
        range.location += begin;
        begin = range.location + range.length;
        
        TextModel *textModel = [[TextModel alloc] init];
        textModel.type = AUDIO;
        textModel.text = @"MP3";
        textModel.range = NSMakeRange(range.location - offset, [textModel.text length]);
        textModel.color = HightLinkColor;
        NSString *keyWord = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)(matchStr), NULL, (__bridge CFStringRef)(CharactersToBeEscaped), kCFStringEncodingUTF8));
        textModel.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", linkHead, keyWord]];
        [hrefArray addObject:textModel];
        
        [originString replaceCharactersInRange:NSMakeRange(range.location - offset, range.length) withString:textModel.text];
        offset += range.length - [textModel.text length];
    }
}

- (void)parseEmojiOfText:(NSMutableString*)originString regex:(NSString*)regex inHrefArray:(NSMutableArray*)hrefArray inEmojiArray:(NSMutableArray*)emojiArray {
    unichar replacementChar = 0xFFFF;
    NSString *replaceString = [NSString stringWithCharacters:&replacementChar length:1];
    
    NSString *textStr = [NSString stringWithString:originString];
    NSInteger begin = 0;
    int offset = 0;
    
    NSMutableArray *textModelArray = [[NSMutableArray alloc] init];
    NSArray *matchStrs = [originString componentsMatchedByRegex:regex];
    for (NSString *matchStr in matchStrs) {
        NSRange range = [textStr rangeOfString:matchStr];
        textStr = [textStr substringFromIndex:range.location + range.length];
        
        range.location += begin;
        begin = range.location + range.length;
        
        TextModel *textModel = [[TextModel alloc] init];
        textModel.type = EMOJI;
        textModel.text = matchStr;
        textModel.range = NSMakeRange(range.location - offset, [replaceString length]);
        textModel.color = ClearColor;
        [textModelArray addObject:textModel];
        
        [originString replaceCharactersInRange:NSMakeRange(range.location - offset, range.length) withString:replaceString];
        offset += range.length - [replaceString length];
        
        for (TextModel *model in hrefArray) {
            if (model.type == AUDIO) {
                if (model.range.location > textModel.range.location) {
                    int diffValue = [matchStr length] - [replaceString length];
                    model.range = NSMakeRange(model.range.location - diffValue, model.range.length);
                }
            }
        }
    }
    [emojiArray addObjectsFromArray:textModelArray];
}

- (void)parseImageOfText:(NSMutableString*)originString regex:(NSString*)regex inHrefArray:(NSMutableArray*)hrefArray inEmojiArray:(NSMutableArray*)emojiArray inImageArray:(NSMutableArray*)imageArray {
    NSString *replaceString = @"\n ";
    
    NSString *textStr = [NSString stringWithString:originString];
    NSInteger begin = 0;
    int offset = 0;
    
    NSMutableArray *textModelArray = [[NSMutableArray alloc] init];
    NSArray *matchStrs = [originString componentsMatchedByRegex:regex];
    for (NSString *matchStr in matchStrs) {
        NSRange range = [textStr rangeOfString:matchStr];
        textStr = [textStr substringFromIndex:range.location + range.length];
        
        range.location += begin;
        begin = range.location + range.length;
        
        TextModel *textModel = [[TextModel alloc] init];
        textModel.type = IMAGE;
        textModel.text = matchStr;
        textModel.range = NSMakeRange(range.location - offset, [replaceString length]);
        textModel.color = ClearColor;
        [textModelArray addObject:textModel];
        
        [originString replaceCharactersInRange:NSMakeRange(range.location - offset, range.length) withString:replaceString];
        offset += range.length - [replaceString length];
        
        for (TextModel *model in hrefArray) {
            if (model.type == AUDIO) {
                if (model.range.location > textModel.range.location) {
                    int diffValue = [matchStr length] - [replaceString length];
                    model.range = NSMakeRange(model.range.location - diffValue, model.range.length);
                }
            }
        }
        for (TextModel *model in emojiArray) {
            if (model.range.location > textModel.range.location) {
                int diffValue = [matchStr length] - [replaceString length];
                model.range = NSMakeRange(model.range.location - diffValue, model.range.length);
            }
        }
    }
    [imageArray addObjectsFromArray:textModelArray];
}

- (void)parseHrefOfText:(NSMutableString*)originString regex:(NSString*)regex linkHead:(NSString*)linkHead inHrefArray:(NSMutableArray*)hrefArray {
    NSString *textStr = [NSString stringWithString:originString];
    NSInteger begin = 0;
    
    NSArray *matchStrs = [originString componentsMatchedByRegex:regex];
    for (NSString *matchStr in matchStrs) {
        NSRange range = [textStr rangeOfString:matchStr];
        textStr = [textStr substringFromIndex:range.location + range.length];
        
        range.location += begin;
        begin = range.location + range.length;
        
        TextModel *textModel = [[TextModel alloc] init];
        textModel.type = HREF;
        textModel.text = matchStr;
        textModel.range = range;
        textModel.color = HightLinkColor;
        NSString *keyWord = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)(matchStr), NULL, (__bridge CFStringRef)(CharactersToBeEscaped), kCFStringEncodingUTF8));
        textModel.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", linkHead, keyWord]];
        
        [hrefArray addObject:textModel];
    }
}

- (void)parseText:(NSMutableString*)originString inHrefArray:(NSMutableArray*)hrefArray inEmojiArray:(NSMutableArray*)emojiArray inImageArray:(NSMutableArray*)imageArray {
    [self parseAudioHrefOfText:originString regex:AudioHrefRegex linkHead:@"audio:" inHrefArray:hrefArray];
    [self parseEmojiOfText:originString regex:EmojiRegex inHrefArray:hrefArray inEmojiArray:emojiArray];
    [self parseImageOfText:originString regex:ImageHrefRegex inHrefArray:hrefArray inEmojiArray:emojiArray inImageArray:imageArray];
    
    [self parseHrefOfText:originString regex:AtRegex linkHead:@"at:" inHrefArray:hrefArray];
    [self parseHrefOfText:originString regex:HrefRegex linkHead:@"" inHrefArray:hrefArray];
}

@end
