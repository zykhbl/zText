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

- (void)parseAudioHrefOfText:(NSMutableString*)originString regex:(NSString*)regex linkHead:(NSString*)linkHead inArray:(NSMutableArray*)array {
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
        [array addObject:textModel];
        
        [originString replaceCharactersInRange:NSMakeRange(range.location - offset, range.length) withString:textModel.text];
        offset += range.length - [textModel.text length];
    }
}

- (void)parseEmojiOfText:(NSMutableString*)originString regex:(NSString*)regex inArray:(NSMutableArray*)array {
    NSString *textStr = [NSString stringWithString:originString];
    NSInteger begin = 0;
    int offset = 0;
    
    NSMutableArray *emojiArray = [[NSMutableArray alloc] init];
    NSArray *matchStrs = [originString componentsMatchedByRegex:regex];
    for (NSString *matchStr in matchStrs) {
        NSRange range = [textStr rangeOfString:matchStr];
        textStr = [textStr substringFromIndex:range.location + range.length];
        
        range.location += begin;
        begin = range.location + range.length;
        
        unichar replacementChar = 0xFFFF;
        NSString *replacementStr = [NSString stringWithCharacters:&replacementChar length:1];
        
        TextModel *textModel = [[TextModel alloc] init];
        textModel.type = EMOJI;
        textModel.text = matchStr;
        textModel.range = NSMakeRange(range.location - offset, [replacementStr length]);
        textModel.color = ClearColor;
        [emojiArray addObject:textModel];
        
        [originString replaceCharactersInRange:NSMakeRange(range.location - offset, range.length) withString:replacementStr];
        offset += range.length - [replacementStr length];
        
        for (TextModel *model in array) {
            if (model.type == AUDIO) {
                if (model.range.location > textModel.range.location) {
                    int diffValue = [matchStr length] - [replacementStr length];
                    model.range = NSMakeRange(model.range.location - diffValue, model.range.length);
                }
            }
        }
    }
    [array addObjectsFromArray:emojiArray];
}

- (void)parseImageOfText:(NSMutableString*)originString regex:(NSString*)regex inArray:(NSMutableArray*)array {
    NSString *textStr = [NSString stringWithString:originString];
    NSInteger begin = 0;
    int offset = 0;
    
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    NSArray *matchStrs = [originString componentsMatchedByRegex:regex];
    for (NSString *matchStr in matchStrs) {
        NSRange range = [textStr rangeOfString:matchStr];
        textStr = [textStr substringFromIndex:range.location + range.length];
        
        range.location += begin;
        begin = range.location + range.length;
        
        NSString *replacementStr = @" ";
        
        TextModel *textModel = [[TextModel alloc] init];
        textModel.type = IMAGE;
        textModel.text = matchStr;
        textModel.range = NSMakeRange(range.location - offset, [replacementStr length]);
        textModel.color = ClearColor;
        [imageArray addObject:textModel];
        
        [originString replaceCharactersInRange:NSMakeRange(range.location - offset, range.length) withString:replacementStr];
        offset += range.length - [replacementStr length];
        
        for (TextModel *model in array) {
            if (model.type == AUDIO || model.type == EMOJI) {
                if (model.range.location > textModel.range.location) {
                    int diffValue = [matchStr length] - [replacementStr length];
                    model.range = NSMakeRange(model.range.location - diffValue, model.range.length);
                }
            }
        }
    }
    [array addObjectsFromArray:imageArray];
}

- (void)parseHrefOfText:(NSMutableString*)originString regex:(NSString*)regex linkHead:(NSString*)linkHead inArray:(NSMutableArray*)array {
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
        
        [array addObject:textModel];
    }
}

- (void)parseText:(NSMutableString*)originString inArray:(NSMutableArray*)array  {
    [self parseAudioHrefOfText:originString regex:AudioHrefRegex linkHead:@"audio:" inArray:array];
    [self parseEmojiOfText:originString regex:EmojiRegex inArray:array];
    [self parseImageOfText:originString regex:ImageHrefRegex inArray:array];
    
    [self parseHrefOfText:originString regex:AtRegex linkHead:@"at:" inArray:array];
    [self parseHrefOfText:originString regex:HrefRegex linkHead:@"" inArray:array];
}

@end
