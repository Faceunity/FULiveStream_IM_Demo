//
//  NTESAnchorBottomBar.h
//  NEUIDemo
//
//  Created by Netease on 17/1/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NTESAnchorBottomBarProtocol;
@interface NTESAnchorBottomBar : UIView

@property (nonatomic, weak) id <NTESAnchorBottomBarProtocol> delegate;

@property (nonatomic, assign) BOOL hiddenFilter;

@property (nonatomic, assign) BOOL hiddenSnap;

@property (nonatomic, assign) NSInteger selectedFilter;

- (void)dismissChooseMenu;

@end

@protocol NTESAnchorBottomBarProtocol <NSObject>
@optional
//点击评论
- (void)bottomBarClickComment:(NTESAnchorBottomBar *)bar;
//点击截屏
- (void)bottomBarClickSnap:(NTESAnchorBottomBar *)bar;
//选择伴音
- (void)bottomBar:(NTESAnchorBottomBar *)bar selectAudio:(NSInteger)index;
//选择滤镜
- (void)bottomBar:(NTESAnchorBottomBar *)bar selectFilter:(NSInteger)index;
//选择分享
- (void)bottomBar:(NTESAnchorBottomBar *)bar selectShareUrl:(NSInteger)index;

@end
