//
//  CoreTextViewController.h
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import "CoreTextViewController.h"
#import "TextViewController.h"
#import "ListViewController.h"
#import "TinyWebViewController.h"
#import "TinyFieldViewController.h"

@implementation CoreTextViewController

@synthesize textVC;
@synthesize listVC;
@synthesize tinyWebVC;
@synthesize tinyFieldVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.textVC == nil) {
        self.textVC = [[TextViewController alloc] init];
    }
    
    if (self.listVC == nil) {
        self.listVC = [[ListViewController alloc] init];
    }
    
    if (self.tinyWebVC == nil) {
        self.tinyWebVC = [[TinyWebViewController alloc] init];
    }
    
    if (self.tinyFieldVC == nil) {
        self.tinyFieldVC = [[TinyFieldViewController alloc] init];
    }
    
    [self addTabScrollView:@[@"普通", @"列表", @"网页", @"输入"] andMainScrollView:@[self.textVC, self.listVC, self.tinyWebVC, self.tinyFieldVC]];
}

@end
