//
//  CoreTextViewController.h
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import "CoreTextViewController.h"
#import "LabelViewController.h"
#import "ListViewController.h"
#import "TinyWebViewController.h"
#import "TinyFieldViewController.h"

@implementation CoreTextViewController

@synthesize labelVC;
@synthesize listVC;
@synthesize tinyWebVC;
@synthesize tinyFieldVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.labelVC == nil) {
        self.labelVC = [[LabelViewController alloc] init];
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
    
    [self addTabScrollView:@[@"普通", @"列表", @"网页", @"输入"] andMainScrollView:@[self.labelVC, self.listVC, self.tinyWebVC, self.tinyFieldVC]];
}

@end
