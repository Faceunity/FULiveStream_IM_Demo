//
//  NTESPresentBoxView.h
//  NIMLiveDemo
//
//  Created by chris on 16/3/30.
//  Copyright © 2016年 Netease. All rights reserved.
//  主播的礼物盒子

#import <UIKit/UIKit.h>

@class NTESPresent;

@interface NTESPresentBoxView : UIControl

@property (nonatomic, strong) NSArray <NTESPresent *> *presents;

- (void)show;

@end
