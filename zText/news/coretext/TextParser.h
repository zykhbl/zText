//
//  TextParser.h
//  zText
//
//  Created by zykhbl on 15-10-14.
//  Copyright (c) 2015年 zykhbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextParser : NSObject

- (void)parseText:(NSMutableString*)originString inArray:(NSMutableArray*)array;

@end
