//
//  LabelViewController.m
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import "LabelViewController.h"

#define TextString @"日本http://ww4.sinaimg.cn/large/54a443cfgw1enxvdur36xj205k04ywf7.gif顶级力量金属GALNERYUS是今年本人POWER团里强烈推荐的一张！@zykhbl 几个大师级的乐手组成的高速力量团，从2010年新主唱小野正利加入后，就好听到不行！这5年来一直保持着每年至少一张新作的高产，即使没有全长专辑，也有圈钱的EP、单曲、现场或是炒冷饭之作。或许他们最巅峰、评价最高的专辑是2011年的《Phoenix Rising》。但今年这张也真是保持了水准啊。@zykhbl 大师级的演奏，各种天[p7][p8][p7]衣无缝的配合复杂得跟数学公式一样，通篇各种乐器不要脸炫技SOLO，SYU尼玛你的手怎么长的？？同时，高速力量[p8][p8]金属里加入了不少其他风格的音乐，http://ww4.sinaimg.cn/large/54a443cfgw1enxvdur36xj205k04ywf7.gif比如第5首《Enemy ToInjustice》带点美国西部的民谣，http://weibo.com/p/1001603795427546820617这位牛仔骑的马可是跑200码的……副歌的旋律好好听啊！！！！；第9首《Secret Love》有些FUSION的意思，能让[p8]你回想起不少小时候听到的动漫主题曲（或许这首本就是一首动漫主题曲？不知道了），日本人玩这种曲风真是世界一流的。http://ww4.sinaimg.cn/large/54a443cfgw1enxvdur36xj205k04ywf7.gif这样一只乐队，你对他们不能有太高的要求，也不能要求他们去突破个什么，只求他们可以继续出新作，保持水准就好了。另外，这张专辑母语增加了不少。"

@implementation LabelViewController

@synthesize coreTextView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.coreTextView == nil) {
        self.coreTextView = [[BaseCoretextView alloc] init];
        self.coreTextView.backgroundColor = [UIColor whiteColor];
        
        TextContainer *textContainer = [[TextContainer alloc] init];
        textContainer.originString = [NSMutableString stringWithString:TextString];
        [textContainer containInSize:self.view.bounds.size];
        
        self.coreTextView.textContainer = textContainer;
        self.coreTextView.frame = self.coreTextView.textContainer.frame;
        
        [self.view addSubview:self.coreTextView];
    }
}

@end
