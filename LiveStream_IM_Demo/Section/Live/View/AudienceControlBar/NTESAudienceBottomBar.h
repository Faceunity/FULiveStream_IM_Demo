//
//  NTESAudienceBottomBar.h
//  NEUIDemo
//
//  Created by Netease on 17/1/4.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NTESPresent.h"

@protocol NTESAudienceBottomBarProtocol;

@interface NTESAudienceBottomBar : UIView

@property (nonatomic, assign) BOOL hiddenSnap;

@property (nonatomic, weak) id <NTESAudienceBottomBarProtocol> delegate;

@property (nonatomic, strong) NSArray *presents;

- (void)dismissPresentShop;

@end

@protocol NTESAudienceBottomBarProtocol <NSObject>
@optional

//点击截屏
- (void)bottomBarClickSnap:(NTESAudienceBottomBar *)bar;
//点击分享
- (void)bottomBarClickShare:(NTESAudienceBottomBar *)bar;
//点击评论
- (void)bottomBarClickComment:(NTESAudienceBottomBar *)bar;
//选择分享
- (void)bottomBar:(NTESAudienceBottomBar *)bar selectShareUrl:(NSInteger)index;
//发送礼物
- (void)bottomBar:(NTESAudienceBottomBar *)bar sendPresent:(NTESPresent *)present;

@end
