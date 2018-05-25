//
//  NTESBaseView.m
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/3/29.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"

@implementation NTESBaseView

- (void)dealloc
{
    NSLog(@"[NTESBaseView][%@] 释放了", NSStringFromClass([self class]));
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self doInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self doInit];
    }
    return self;
}

#pragma mark - 虚方法
- (void)doInit {};

@end
