//
//  NTESPresentEmptyView.h
//  NEUIDemo
//
//  Created by Netease on 17/1/6.
//  Copyright © 2017年 Netease. All rights reserved.
//  礼物盒子的空视图

#import <UIKit/UIKit.h>

@interface NTESPresentEmptyView : UIView

@property (nonatomic, copy) NSString *info;
@property (nonatomic, copy) NSString *bkImageName;

+ (instancetype)emptyViewWithInfo:(NSString *)info;

+ (instancetype)emptyViewWithInfo:(NSString *)info bkImageName:(NSString *)imageName;

@end
