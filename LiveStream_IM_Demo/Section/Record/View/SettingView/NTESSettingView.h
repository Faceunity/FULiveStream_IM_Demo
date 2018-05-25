//
//  NTESSettingView.h
//  ShortVideo_Demo
//
//  Created by Netease on 17/2/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"
#import "NTESRecordConfigEntity.h"

@protocol NTESSettingViewProtocol;

@interface NTESSettingView : NTESBaseView

@property (nonatomic, weak) id <NTESSettingViewProtocol> delegate;

- (void)configWithEntity:(NTESRecordConfigEntity *)entity;

- (void)showInView:(UIView *)view complete:(void(^)())complete;

- (void)dismissComplete:(void(^)())complete;

- (CGFloat)settingHeight;

@end

@protocol NTESSettingViewProtocol <NSObject>

- (void)NTESSettingView:(NTESSettingView *)view selectSection:(NSInteger)section;

- (void)NTESSettingView:(NTESSettingView *)view selectDuration:(NSInteger)duration;

- (void)NTESSettingView:(NTESSettingView *)view selectResolution:(NTESRecordResolution)resolution;

- (void)NTESSettingView:(NTESSettingView *)view selectScreen:(NTESRecordScreenScale)screen;

@end
