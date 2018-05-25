//
//  NTESRecordDataCenter.h
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/3/30.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NTESRecordConfigEntity.h"

@interface NTESRecordDataCenter : NSObject

+ (instancetype)shareInstance;

+ (void)clear;

//配置参数（段数、时长等）
@property (nonatomic, strong) NTESRecordConfigEntity *config;

//录制参数
@property (nonatomic, strong) LSMediaRecordingParaCtx *pRecordPara;

//录制文件路径
@property (nonatomic, strong) NSMutableArray <NSString *>*recordFilePaths;

//输出视频的名称
@property (nonatomic, copy) NSString *outputVideoName;

//输出视频的相对路径
@property (nonatomic, copy) NSString *outputVideoRelPath;

//滤镜种类数据
- (NSInteger)filterIndexWithFilterType:(LSRecordGPUImageFilterType)filterType;
- (LSRecordGPUImageFilterType)filterTypeWithFilterIndex:(NSInteger)index;

//缩放模式
- (NTESRecordScreenScale)screenScaleWithRecordScaleMode:(LSRecordVideoRenderScaleMode)mode;
- (LSRecordVideoRenderScaleMode)recordScaleModeWithScreenScale:(NTESRecordScreenScale)scale;

//分辨率
- (NTESRecordResolution)resolutionWithRecordQuality:(LSRecordVideoStreamingQuality)quality;
- (LSRecordVideoStreamingQuality)recordQualityWithResolution:(NTESRecordResolution)resolution;

@end
