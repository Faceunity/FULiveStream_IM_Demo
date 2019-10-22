//
//  NTESRecordDataCenter.m
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/3/30.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESRecordDataCenter.h"

@implementation NTESRecordDataCenter
@synthesize recordFilePaths = _recordFilePaths;
- (instancetype)init
{
    if (self = [super init]) {
        [self defaultRecordParaCtx];
        [self defaultRecordConfig];
    }
    return self;
}

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESRecordDataCenter alloc] init];
    });
    return instance;
}

+ (void)clear
{
    [NTESSandboxHelper deleteFiles:[NTESRecordDataCenter shareInstance].recordFilePaths];
    [NTESRecordDataCenter shareInstance].recordFilePaths = nil;
    [[NTESRecordDataCenter shareInstance] defaultRecordConfig];
}

- (void)defaultRecordConfig
{
    _config = [[NTESRecordConfigEntity alloc] init];
    _config.exposureValue = 0.0;
    _config.beautyValue = 0.0;
    _config.filterDatas = @[@"无", @"黑白", @"自然", @"粉嫩", @"怀旧", @"Cus1", @"Cus2"];
    _config.filterIndex = [self filterIndexWithFilterType:_pRecordPara.sLSRecordVideoParaCtx.filterType];
//    _config.faceUDatas = @[@"特效1", @"特效2", @"特效3", @"特效4"];
    _config.faceUTitleDatas = @[@"无", @"特效1",@"特效2",@"特效3",@"特效4",@"特效5",@"特效6",@"特效7",@"特效8",@"特效9",@"特效10",@"特效11",@"特效12",@"特效13"];
    _config.faceUDatas = @[@"noitem", @"tiara", @"item0208", @"YellowEar", @"PrincessCrown", @"Mood" , @"Deer" , @"BeagleDog", @"item0501", @"item0210",  @"HappyRabbi", @"item0204", @"hartshorn", @"ColorCrown"];
    _config.faceIndex = 0;
    _config.section = 3;
    _config.duration = 10;
    _config.resolution = NTESRecordResolutionHD;
    _config.screenScale = NTESRecordScreenScale16x9;
    _config.beauty = YES;
}

- (void)defaultRecordParaCtx
{
    _pRecordPara = [[LSMediaRecordingParaCtx alloc] init];
    //这里可以设置音视频流／音频流／视频流
    _pRecordPara.eOutStreamType = LS_RECORD_AV;
    //视频
    _pRecordPara.sLSRecordVideoParaCtx.fps = 30; //fps ,就是帧率，建议在10~24之间
    _pRecordPara.sLSRecordVideoParaCtx.bitrate = 10000000;
    _pRecordPara.sLSRecordVideoParaCtx.codec = LS_RECORD_VIDEO_CODEC_H264;
    _pRecordPara.sLSRecordVideoParaCtx.videoStreamingQuality = LS_RECORD_VIDEO_QUALITY_SUPER;
    _pRecordPara.sLSRecordVideoParaCtx.cameraPosition = LS_RECORD_CAMERA_POSITION_FRONT;
    _pRecordPara.sLSRecordVideoParaCtx.interfaceOrientation = LS_RECORD_CAMERA_ORIENTATION_PORTRAIT;
    _pRecordPara.sLSRecordVideoParaCtx.videoRenderMode = LS_RECORD_VIDEO_RENDER_MODE_SCALE_16_9;
    _pRecordPara.sLSRecordVideoParaCtx.filterType = LS_RECORD_GPUIMAGE_NORMAL;
    _pRecordPara.sLSRecordVideoParaCtx.isFrontCameraMirrored = YES;
    
    //音频
    _pRecordPara.sLSRecordAudioParaCtx.bitrate = 64000;
    _pRecordPara.sLSRecordAudioParaCtx.codec = LS_RECORD_AUDIO_CODEC_AAC;
    _pRecordPara.sLSRecordAudioParaCtx.frameSize = 2048;
    _pRecordPara.sLSRecordAudioParaCtx.numOfChannels = 1;
    _pRecordPara.sLSRecordAudioParaCtx.samplerate = 44100;
}

- (NSMutableArray<NSString *> *)recordFilePaths
{
    if (!_recordFilePaths) {
        _recordFilePaths = [NSMutableArray array];
    }
    return _recordFilePaths;
}

- (void)setRecordFilePaths:(NSMutableArray<NSString *> *)recordFilePaths
{
    _recordFilePaths = recordFilePaths;
    
    if (recordFilePaths == nil) {
        [NTESSandboxHelper clearRecordVideoPath];
    }
}

- (NSInteger)filterIndexWithFilterType:(LSRecordGPUImageFilterType)filterType
{
    NSInteger index = 0;
    switch (filterType) {
        case LS_RECORD_GPUIMAGE_NORMAL:
            index = 0;
            break;
        case LS_RECORD_GPUIMAGE_SEPIA:
            index = 1;
            break;
        case LS_RECORD_GPUIMAGE_ZIRAN:
            index = 2;
            break;
        case LS_RECORD_GPUIMAGE_MEIYAN1:
            index = 3;
            break;
        case LS_RECORD_GPUIMAGE_MEIYAN2:
            index = 4;
            break;
        default:
            index = LS_RECORD_GPUIMAGE_CUSTOM;
            break;
    }
    return index;
}

- (LSRecordGPUImageFilterType)filterTypeWithFilterIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            return LS_RECORD_GPUIMAGE_NORMAL;
        case 1:
            return LS_RECORD_GPUIMAGE_SEPIA;
        case 2:
            return LS_RECORD_GPUIMAGE_ZIRAN;
        case 3:
            return LS_RECORD_GPUIMAGE_MEIYAN1;
        case 4:
            return LS_RECORD_GPUIMAGE_MEIYAN2;
        default:
            return LS_RECORD_GPUIMAGE_NORMAL;
    }
}

#pragma mark - 缩放
- (NTESRecordScreenScale)screenScaleWithRecordScaleMode:(LSRecordVideoRenderScaleMode)mode
{
    switch (mode) {
        case LS_RECORD_VIDEO_RENDER_MODE_SCALE_16_9:
            return NTESRecordScreenScale16x9;
        case LS_RECORD_VIDEO_RENDER_MODE_SCALE_4_3:
            return NTESRecordScreenScale4x3;
        case LS_RECORD_VIDEO_RENDER_MODE_SCALE_1_1:
            return NTESRecordScreenScale1x1;
        default:
            return NTESRecordScreenScale16x9;
    }
}

- (LSRecordVideoRenderScaleMode)recordScaleModeWithScreenScale:(NTESRecordScreenScale)scale
{
    switch (scale) {
        case NTESRecordScreenScale16x9:
            return LS_RECORD_VIDEO_RENDER_MODE_SCALE_16_9;
        case NTESRecordScreenScale4x3:
            return LS_RECORD_VIDEO_RENDER_MODE_SCALE_4_3;
        case NTESRecordScreenScale1x1:
            return LS_RECORD_VIDEO_RENDER_MODE_SCALE_1_1;
        default:
            return LS_RECORD_VIDEO_RENDER_MODE_SCALE_NONE;
    }
}

#pragma mark - 分辨率
- (NTESRecordResolution)resolutionWithRecordQuality:(LSRecordVideoStreamingQuality)quality
{
    switch (quality) {
        case LS_RECORD_VIDEO_QUALITY_NORMAL:
        case LS_RECORD_VIDEO_QUALITY_HIGH:
            return NTESRecordResolutionSD;
        case LS_RECORD_VIDEO_QUALITY_SUPER:
        case LS_RECORD_VIDEO_QUALITY_SUPER_HIGH:
            return NTESRecordResolutionHD;
        default:
            return NTESRecordResolutionSD;
    }
}

- (LSRecordVideoStreamingQuality)recordQualityWithResolution:(NTESRecordResolution)resolution
{
    switch (resolution) {
        case NTESRecordResolutionSD:
            return LS_RECORD_VIDEO_QUALITY_NORMAL;
        case NTESRecordResolutionHD:
            return LS_RECORD_VIDEO_QUALITY_SUPER;
        default:
            return LS_RECORD_VIDEO_QUALITY_NORMAL;
    }
}



@end
