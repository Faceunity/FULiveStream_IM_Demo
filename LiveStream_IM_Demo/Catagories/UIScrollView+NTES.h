//
//  UIScrollView+NTES.h
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/4/14.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (NTES)

@property (assign, nonatomic) CGFloat insetT;
@property (assign, nonatomic) CGFloat insetB;
@property (assign, nonatomic) CGFloat insetL;
@property (assign, nonatomic) CGFloat insetR;

@property (assign, nonatomic) CGFloat offsetX;
@property (assign, nonatomic) CGFloat offsetY;

@property (assign, nonatomic) CGFloat contentW;
@property (assign, nonatomic) CGFloat contentH;

@end
