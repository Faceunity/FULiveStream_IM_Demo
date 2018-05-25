//
//  LSMediaRecordingParaCtx.h
//  LSMediaRecoderAndProcessor
//
//  Created by Netease on 17/7/10.
//  Copyright © 2017年 朱玲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSMediaRecordingDefs.h"

@class LSRecordVideoParaCtx;
@class LSRecordAudioParaCtx;

#pragma mark - 全部参数
@interface LSMediaRecordingParaCtx : NSObject

@property (nonatomic, assign) LSRecordStreamType eOutStreamType; //类型：音视频，视频，音频.
@property (nonatomic, strong) LSRecordVideoParaCtx *sLSRecordVideoParaCtx; //视频相关参数
@property (nonatomic, strong) LSRecordAudioParaCtx *sLSRecordAudioParaCtx; //音频相关参数

+ (instancetype)defaultPara;

@end

#pragma mark - 视频参数
@interface LSRecordVideoParaCtx : NSObject

@property (nonatomic, assign) NSInteger fps; //帧率
@property (nonatomic, assign) NSInteger bitrate; //码率
@property (nonatomic, assign) LSRecordVideoCodecType codec; //视频编码器
@property (nonatomic, assign) LSRecordVideoStreamingQuality videoStreamingQuality; //视频分辨率
@property (nonatomic, assign) LSRecordCameraPosition cameraPosition; //视频采集前后摄像头
@property (nonatomic, assign) LSRecordCameraOrientation interfaceOrientation; //视频采集方向
@property (nonatomic, assign) LSRecordVideoOutputMode videoOutputMode; //视频输出格式
@property (nonatomic, assign) LSRecordVideoRenderScaleMode videoRenderMode; //视频显示端比例16:9
@property (nonatomic, assign) LSRecordGPUImageFilterType filterType; //滤镜类型
@property (nonatomic, assign) BOOL isFrontCameraMirrored; //是否镜像前置摄像头

+ (instancetype)defaultPara;

@end

#pragma mark - 音频参数
@interface LSRecordAudioParaCtx : NSObject

@property (nonatomic, assign) NSInteger samplerate; //!< 音频的样本采集率.
@property (nonatomic, assign) NSInteger numOfChannels; //!< 音频采集的通道数：单声道，双声道.
@property (nonatomic, assign) NSInteger frameSize; //!< 音频采集的帧大小.
@property (nonatomic, assign) NSInteger bitrate; //!< 音频编码码率.
@property (nonatomic, assign) LSRecordAudioCodecType codec; //!< 音频编码器.//!< 音频编码器.

+ (instancetype)defaultPara;

@end

#pragma mark - 统计参数
@interface LSMediaRecordStatistics : NSObject

@property (nonatomic, assign) NSUInteger videoCaptureFrameRate; //采集帧率
@property (nonatomic, assign) NSUInteger videoFilteredFrameRate;//滤镜帧率
@property (nonatomic, assign) NSUInteger videoSendFrameRate; //发送帧率
@property (nonatomic, assign) NSUInteger videoSendBitRate;   //发送码率
@property (nonatomic, assign) NSUInteger videoSendWidth;  //发送视频宽度
@property (nonatomic, assign) NSUInteger videoSendHeight; //发送视频高度
@property (nonatomic, assign) NSUInteger videoSetFrameRate; //设置的帧率
@property (nonatomic, assign) NSUInteger videoSetBitRate;   //设置的码率
@property (nonatomic, assign) NSUInteger videoSetWidth;  //设置的视频宽度
@property (nonatomic, assign) NSUInteger videoSetHeight; //设置的视频高度
@property (nonatomic, assign) NSUInteger audioSendBitRate; //音频发送的帧率

@end
