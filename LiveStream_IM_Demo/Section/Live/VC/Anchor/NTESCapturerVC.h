//
//  NTESCapturerVC.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseVC.h"

typedef void(^LiveCompleteBlock)(NSError *error);
typedef void(^LiveSnapBlock)(UIImage *image);

@interface NTESCapturerVC : NTESBaseVC

@property (nonatomic, assign) BOOL isOnlyPushVideo;

@property (nonatomic, copy) NSString *pushUrl;

@property (nonatomic, assign, readonly) LSLiveStreamingParaCtxConfiguration *pParaCtx;

//开始预览
- (void)startVideoPreview:(NSString *)url
                container:(UIView *)view;

//停止预览
- (void)stopVideoPreview;

//开始直播
- (void)startLiveStream:(LiveCompleteBlock)complete;

//停止直播
- (void)stopLiveStream:(LiveCompleteBlock)complete;

//暂停视频
- (void)pauseVideo:(BOOL)isPause;

//暂停音频
- (void)pauseAudio:(BOOL)isPause;

//切换镜头
- (void)switchCamera;

//截屏
- (void)snapImage:(LiveSnapBlock)complete;

//滤镜
- (void)setFilterType:(NSInteger)index;

//伴音
- (void)setAudioType:(NSInteger)index;

#pragma mark - 子类重载 (被动事件监听)
//已经停止直播
- (void)doDidStopLiveStream;

//已经开始直播
- (void)doDidStartLiveStream;

//直播中出错
- (void)doLiveStreamError:(NSError *)error;

//变焦事件
- (void)doZoomScaleValueChanged:(CGFloat)value;

//音频文件播放完成
- (void)doAudioFilePlayComplete;

@end
