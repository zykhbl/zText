//
//  TinyWebView.m
//  zText
//
//  Created by zykhbl on 15-10-18.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import "TinyWebView.h"

@implementation TinyWebView

@synthesize coretextView;

- (void)renderString:(NSString*)text {
    self.clipsToBounds = YES;
    if (self.coretextView == nil) {
        self.coretextView = [[BaseCoretextView alloc] init];
        self.coretextView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.coretextView];
    }
    
    TextContainer *textContainer = [[TextContainer alloc] init];
    textContainer.originString = [NSMutableString stringWithString:text];
    [textContainer containInSize:self.bounds.size];
    self.coretextView.textContainer = textContainer;
    self.coretextView.frame = self.coretextView.textContainer.frame;
    self.contentSize = [self.coretextView.textContainer fitSize];
    
    [self loadImages];
}

- (void)loadImages {
    [self.coretextView addEmojiViews];
    [self.coretextView addImageViews];
}

@end
