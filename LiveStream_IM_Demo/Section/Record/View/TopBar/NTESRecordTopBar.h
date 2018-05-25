//
//  NTESRecordTopBar.h
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/3/30.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"

@protocol NTESRecordTopBarProtocol;

@interface NTESRecordTopBar : NTESBaseView

@property (nonatomic, weak) id <NTESRecordTopBarProtocol> delegate;

@property(nonatomic, assign) BOOL hiddenBeauty;

@property(nonatomic, assign) BOOL hiddenFilterConfig;

@property(nonatomic, assign) BOOL isBeauty;

@end

@protocol NTESRecordTopBarProtocol <NSObject>

@optional

- (void)TopBarQuitAction:(NTESRecordTopBar *)bar;
//faceUnity 特效
- (void)TopBarFaceUSdkAction:(NTESRecordTopBar *)bar;
//美颜
- (void)TopBarBeautyAction:(NTESRecordTopBar *)bar;
//滤镜
- (void)TopBarFilterAction:(NTESRecordTopBar *)bar;
//摄像头切换
- (void)TopBarCameraAction:(NTESRecordTopBar *)bar;

@end
