//
//  TextParser.m
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import "TextParser.h"
#import "RegexKitLite.h"
#import "TextModel.h"
#import "TextAttributes.h"

#define AtRegex @"(@[^：:\\s]+)"
#define HrefRegex @"(https?)://(?:(\\S+?)(?::(\\S+?))?@)?([a-zA-Z0-9\\-.]+)(?::(\\d+))?((?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?"
#define EmojiRegex @"\\[p[0-9]+\\]"
#define ImageHrefRegex @"(https?)://(?:(\\S+?)(?::(\\S+?))?@)?([a-zA-Z0-9\\-.]+)(?::(\\d+))?((?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?((.png)|(.jpg)|(.gif))"
#define CharactersToBeEscaped @"!*'();:@&=+$,%#[]"

@implementation TextParser

- (void)parseImageHrefOfText:(NSMutableString*)originString regex:(NSString*)regex linkHead:(NSString*)linkHead inArray:(NSMutableArray*)array {
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
        textModel.type = HREF;
        textModel.text = @"图片";
        textModel.range = NSMakeRange(range.location - offset, [textModel.text length]);
        textModel.color = HightLinkColor;
        NSString *keyWord = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)(matchStr), NULL, (__bridge CFStringRef)(CharactersToBeEscaped), kCFStringEncodingUTF8));
        textModel.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", linkHead, keyWord]];
        
        [array addObject:textModel];
        
        [originString replaceCharactersInRange:NSMakeRange(range.location - offset, range.length) withString:textModel.text];
        offset += range.length - [textModel.text length];
    }
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

- (void)parseEmojiOfText:(NSMutableString*)originString regex:(NSString*)regex linkHead:(NSString*)linkHead inArray:(NSMutableArray*)array {
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
        textModel.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",linkHead, keyWord]];
        
        [array addObject:textModel];
    }
}

- (void)parseText:(NSMutableString*)originString inArray:(NSMutableArray*)array  {
    [self parseImageHrefOfText:originString regex:ImageHrefRegex linkHead:@"" inArray:array];
    [self parseEmojiOfText:originString regex:EmojiRegex linkHead:@"" inArray:array];
    
    [self parseHrefOfText:originString regex:AtRegex linkHead:@"" inArray:array];
    [self parseHrefOfText:originString regex:HrefRegex linkHead:@"" inArray:array];
}

@end
