//
//  NTESLiveDataCenter.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/9.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESLiveDataCenter.h"

@implementation NTESLiveDataCenter

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESLiveDataCenter alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self defaultLiveParaCtx];
    }
    return self;
}

- (void)defaultLiveParaCtx
{
    if (!_pParaCtx) {
        _pParaCtx = [LSLiveStreamingParaCtxConfiguration defaultLiveStreamingConfiguration];
    }
}

#pragma mark -- 伴音文件
- (NSMutableArray *)audios
{
    if (!_audios)
    {
        _audios = [NSMutableArray array];
        NSString* musicFilePath = nil;
        
        //添加两个示例音乐。
        musicFilePath = [[NSBundle mainBundle]pathForResource:@"test_1" ofType:@"mp3"];
        if (musicFilePath) {
            [_audios addObject:musicFilePath];
        }
        musicFilePath = [[NSBundle mainBundle]pathForResource:@"test_2" ofType:@"mp3"];
        if (musicFilePath) {
            [_audios addObject:musicFilePath];
        }
    }
    return _audios;
}

#pragma mark -- 参数转字符串
- (NSString *)infoSubStrWith:(NSInteger)index strs:(NSArray *)strs
{
    NSString *str = @"未知";
    if (index >= 0 && index < strs.count)
    {
        str = strs[index];
    }
    return str;
}

- (NSString *)liveStreamConfigInfo
{
    NSMutableString *infoStr = [NSMutableString string];
    NSString *str = @"未知";
    NSArray *strArray;
    
    //硬件编码类型
    strArray = @[@"关闭", @"音频", @"视频", @"音视频"];
    str = [self infoSubStrWith:(NSInteger)_pParaCtx.eHaraWareEncType strs:strArray];
    [infoStr appendString:[NSString stringWithFormat:@"是否开启硬件编码: [%@]\n", str]];
    
    //推流类型
    strArray = @[@"音频", @"视频", @"音视频"];
    str = [self infoSubStrWith:(NSInteger)_pParaCtx.eOutStreamType strs:strArray];
    [infoStr appendString:[NSString stringWithFormat:@"推流类型: [%@]\n", str]];
    
    //推流协议
    strArray = @[@"FLV", @"RTMP"];
    str = [self infoSubStrWith:(NSInteger)_pParaCtx.eOutFormatType strs:strArray];
    [infoStr appendString:[NSString  stringWithFormat:@"推流协议: [%@]\n", str]];
    
    //是否上传sdk日志
    str = ((_pParaCtx.uploadLog == YES) ? @"是" : @"否");
    [infoStr appendString:[NSString stringWithFormat:@"上传日至: [%@]\n", str]];
    
    //视频参数
    [infoStr appendString:[NSString stringWithFormat:@"--------------------------------------\n"]];
    [infoStr appendString:[NSString stringWithFormat:@"帧率: [%zi]\n", _pParaCtx.sLSVideoParaCtx.fps]];
    [infoStr appendString:[NSString stringWithFormat:@"码率: [%zi]\n", _pParaCtx.sLSVideoParaCtx.bitrate]];
    
//    //---视频编码器
//    strArray = @[@"H264", @"VP9", @"HEVC"];
//    str = [self infoSubStrWith:(NSInteger)_pParaCtx.sLSVideoParaCtx.codec strs:strArray];
//    [infoStr appendString:[NSString stringWithFormat:@"视频编码器: [%@]\n", str]];
    
    //---视频分辨率
    strArray = @[@"低清 352*288", @"标清 480*360", @"高清 640*480", @"超清 960*540", @"超高清 1280*720"];
    str = [self infoSubStrWith:(NSInteger)_pParaCtx.sLSVideoParaCtx.videoStreamingQuality strs:strArray];
    [infoStr appendString:[NSString stringWithFormat:@"视频分辨率: [%@]\n", str]];
    
    //--采集前后摄像头
    strArray = @[@"后置摄像头", @"前置摄像头"];
    str = [self infoSubStrWith:(NSInteger)_pParaCtx.sLSVideoParaCtx.cameraPosition strs:strArray];
    [infoStr appendString:[NSString stringWithFormat:@"视频采集前后摄像头: [%@]\n", str]];
    
    //--视频采集方向
    strArray = @[@"PORTRAIT", @"UPDOWN", @"RIGHT", @"LEFT"];
    str = [self infoSubStrWith:(NSInteger)_pParaCtx.sLSVideoParaCtx.interfaceOrientation strs:strArray];
    [infoStr appendString:[NSString stringWithFormat:@"视频采集方向: [%@]\n", str]];
    
    //--视频显示端比例16:9
    strArray = @[@"非宽屏", @"宽屏"];
    str = [self infoSubStrWith:(NSInteger)_pParaCtx.sLSVideoParaCtx.videoRenderMode strs:strArray];
    [infoStr appendString:[NSString stringWithFormat:@"是否为宽屏（16:9）: [%@]\n", str]];
    
    //--滤镜类型
    strArray = @[@"无滤镜", @"黑白", @"自然", @"粉嫩", @"怀旧"];
    str = [self infoSubStrWith:(NSInteger)_pParaCtx.sLSVideoParaCtx.filterType strs:strArray];
    [infoStr appendString:[NSString stringWithFormat:@"滤镜类型: [%@]\n", str]];
    
    //--是否开启摄像头flash功能
    str = ((_pParaCtx.sLSVideoParaCtx.isCameraFlashEnabled == YES) ? @"是" : @"否");
    [infoStr appendString:[NSString stringWithFormat:@"开启闪光灯: [%@]\n", str]];
    
    //--是否开启手势变焦
    str = ((_pParaCtx.sLSVideoParaCtx.isCameraZoomPinchGestureOn == YES) ? @"是" : @"否");
    [infoStr appendString:[NSString stringWithFormat:@"开启手势变焦: [%@]\n", str]];
    
    //--是否开启水印支持
    str = ((_pParaCtx.sLSVideoParaCtx.isVideoWaterMarkEnabled == YES) ? @"是" : @"否");
    [infoStr appendString:[NSString stringWithFormat:@"开启水印支持: [%@]\n", str]];
    
    //--是否开启滤镜支持
    str = ((_pParaCtx.sLSVideoParaCtx.isVideoFilterOn == YES) ? @"是" : @"否");
    [infoStr appendString:[NSString stringWithFormat:@"开启滤镜支持: [%@]\n", str]];
    
    //--是否开启Qos功能
    str = ((_pParaCtx.sLSVideoParaCtx.isQosOn == YES) ? @"是" : @"否");
    [infoStr appendString:[NSString stringWithFormat:@"开启Qos功能: [%@]\n", str]];
    
    //--是否镜像前置摄像头
    str = ((_pParaCtx.sLSVideoParaCtx.isFrontCameraMirroredPreView == YES) ? @"是" : @"否");
    [infoStr appendString:[NSString stringWithFormat:@"镜像前置摄像头: [%@]\n", str]];
    
    //音频参数
    [infoStr appendString:[NSString stringWithFormat:@"--------------------------------------\n"]];
    [infoStr appendString:[NSString stringWithFormat:@"音频的样本采集率: [%zi]\n", _pParaCtx.sLSAudioParaCtx.samplerate]];
    [infoStr appendString:[NSString stringWithFormat:@"音频采集的通道数: [%zi]\n", _pParaCtx.sLSAudioParaCtx.numOfChannels]];
    [infoStr appendString:[NSString stringWithFormat:@"音频采集的帧大小: [%zi]\n", _pParaCtx.sLSAudioParaCtx.frameSize]];
    [infoStr appendString:[NSString stringWithFormat:@"音频编码码率: [%zi]\n", _pParaCtx.sLSAudioParaCtx.bitrate]];
    
//    //--滤镜类型
//    strArray = @[@"AAC", @"GIPS"];
//    str = [self infoSubStrWith:(NSInteger)_pParaCtx.sLSAudioParaCtx.codec strs:strArray];
//    [infoStr appendString:[NSString stringWithFormat:@"音频编码器: [%@]\n", str]];
    
    return infoStr;
};

@end
