//
//  EmojiCache.h
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmojiCache : NSObject

@property (nonatomic, strong) NSCache *emojiCache;

+ (id)defaultEmojiCache;

- (void)setEmoji:(UIImage*)emoji forKey:(NSString*)key;
- (UIImage*)emojiForKey:(NSString*)key;

@end
