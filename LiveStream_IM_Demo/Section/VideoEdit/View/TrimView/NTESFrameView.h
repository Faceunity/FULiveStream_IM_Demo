//
//  NTESFrameView.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"


@class NTESFrameView;
@protocol NTESFrameViewDelegate <NSObject>

- (void)trimmerView:(NTESFrameView *)trimmerView didEndChangeStartTime:(CGFloat)startTime;

@end

@interface NTESFrameView : NTESBaseView

//截取长度
@property(nonatomic, assign) CGFloat trimDuration;

@property(nonatomic, weak) id<NTESFrameViewDelegate> delegate;


/**
 *  初始化剪辑页面
 *
 *  @param frame    view frame
 *  @param videoURL video URL
 *  @param duration 剪辑时长
 *
 *  @return NTESFrameView
 */
- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL trimDuration:(CGFloat)duration;

@end
