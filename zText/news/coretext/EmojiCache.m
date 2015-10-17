//
//  EmojiCache.h
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import "EmojiCache.h"

@implementation EmojiCache

@synthesize emojiCache;

+ (id)defaultEmojiCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.emojiCache = [[NSCache alloc] init];
        self.emojiCache.countLimit = 100;
    }
    
    return self;
}

- (void)setEmoji:(UIImage*)emoji forKey:(NSString*)key {
    [self.emojiCache setObject:emoji forKey:key];
}

- (UIImage*)emojiForKey:(NSString*)key {
    return [self.emojiCache objectForKey:key];;
}

@end
