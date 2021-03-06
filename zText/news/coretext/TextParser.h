//
//  TextParser.h
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextModel.h"
#import "TextAttributes.h"

@interface TextParser : NSObject

- (void)parseText:(NSMutableString*)originString inHrefArray:(NSMutableArray*)hrefArray inEmojiArray:(NSMutableArray*)emojiArray inImageArray:(NSMutableArray*)imageArray;

@end
