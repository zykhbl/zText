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

- (id)init {
    self = [super init];
    
    if (self) {
        self.coretextView = [[BaseCoretextView alloc] init];
        self.coretextView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.coretextView];
    }
    
    return self;
}

@end
