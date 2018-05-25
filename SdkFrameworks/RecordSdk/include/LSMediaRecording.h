//
//  lsMediaCapture.h
//  lsMediaCapture
//
//  Created by NetEase on 15/8/12.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//  类LSMediacapture，用于录制

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LSMediaRecordingParaCtx.h"

@class GPUImageFilter;
/**
  @brief 录制中的NSNotificationCenter消息广播
 */
#define LS_Recording_Started                     @"LSMediaRecrodingStarted"       //!<  录制已经开始
#define LS_Recording_Finished                    @"LSMediaRecordingFinished"      //!<  录制已经结束
#define LS_Recording_MusicFile_Eof               @"LSMeidaRecordingMusicFileEof"  //!< 当前audio文件播放结束
#define LS_Recording_Init_Error_Key              @"LSRecordingInitErrorKey"       //初始化失败原因key

@interface LSMediaRecording : NSObject

#pragma mark - 回调相关
/**
 *  @brief 得到 过程中的统计信息
 *
 *  statistics 统计信息结构体
 */
@property (nonatomic,copy) void (^onStatisticInfoGot)(LSMediaRecordStatistics* statistics);

/**
 *  @brief 过程中发生错误的回调函数
 *
 *  error 具体错误信息
 */
@property (nonatomic,copy) void (^onLiveStreamError)(NSError *error);

#pragma mark - 初始化相关

/**
 清除缓存，如果和转码sdk一同使用，请在最后释放的类中调用。
 */
+ (void)cleanGPUCache;

/**
 *  初始化mediacapture
 *
 *  @return LSMediaCapture
 */
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initLiveStreamWithAppKey:(NSString *)appKey error:(NSError **)error;

/**
 *  初始化mediacapture
 *
 *  @param  videoParaCtx 录制视频参数
 *
 *  @return LSMediaCapture
 */
- (instancetype)initLiveStreamWithVideoParaCtx:(LSRecordVideoParaCtx*)videoParaCtx
                                        appKey:(NSString *)appKey
                                         error:(NSError **)error;

/**
 *  @brief 初始化mediacapture
 *
 *  @param  lsParaCtx 录制参数
 *
 *  @return LSMediaCapture
 */
- (instancetype)initLiveStreamWithLivestreamParaCtx:(LSMediaRecordingParaCtx*)lsParaCtx
                                             appKey:(NSString *)appKey
                                              error:(NSError **)error;

#pragma mark - 预览相关
/**
 *  @brief 打开视频预览
 *
 *  @param  preview 预览窗口
 *
 *  @warning 在ipad3上，前置摄像头的分辨率不支持960*540的高分辨率,不建议在ipad上使用前置摄像头进行高清分辨率采集
 */
-(void)startVideoPreview:(UIView*)preview;

/**
 *  @brief 暂停视频预览
 *
 *  @warning 如果正在录制 ，则同时关闭视频预览以及视频录制
 */
-(void)pauseVideoPreview;

/**
 *  @brief 恢复视频预览
 *
 *  @warning 如果正在录制 ，则开始视频录制
 */
-(void)resumeVideoPreview;

/**
 *  @brief 获取视频截图，
 *
 *  @param completionBlock 获取最新一幅视频图像的回调
 */
- (void)snapShotWithCompletionBlock:(void(^)(UIImage* image))completionBlock;


/**
 *  @brief 切换前后摄像头
 *
 *  @return 当前摄像头的位置，前或者后
 */
- (LSRecordCameraPosition)switchCamera;

#pragma mark - 水印相关
/**
 * @brief 添加静态视频水印
 *
 * @param image 静态图像
 * @param rect 具体位置和大小
 * @param location 位置
 */
- (void)addWaterMark:(UIImage*)image
                rect:(CGRect)rect
            location:(LSRecordWaterMarkLocation)location;

/**
 * @brief 关闭本地预览静态水印
 * 
 * @param isClosed 是否关闭
 */
- (void)closePreviewWaterMark:(BOOL)isClosed;

/**
 * @brief添加动态视频水印
 *
 * @param imageArray 动态图像数组
 * @param count 播放速度的快慢:count代表count帧一张图
 * @param looped 是否循环，不循环就显示一次
 * @param rect 具体位置和大小（x，y根据location位置，计算具体的位置信息）
 * @param location 位置
 */
- (void)addDynamicWaterMarks:(NSArray*)imageArray
                    fpsCount:(unsigned int)count
                        loop:(BOOL)looped
                        rect:(CGRect)rect
                    location:(LSRecordWaterMarkLocation)location;

/**
 * @brief 关闭本地预览动态水印
 *
 * @param isClosed 是否关闭
 */
- (void)closePreviewDynamicWaterMark:(BOOL)isClosed;

/**
 清除水印
 */
- (void)cleanWaterMark;

#pragma mark - 分辨率、帧率、裁剪
/**
 * @brief 录制的视频分辨率、码率、帧率设置， 开始录制之前可以设置
 *
 * @param videoResolution 分辨率
 * @param bitrate 录制码率
 * @param fps 录制帧率
 */
-(void)setVideoParameters:(LSRecordVideoStreamingQuality)videoResolution
                  bitrate:(int)bitrate
                      fps:(int)fps;

/**
 *  @brief 视频分辨率选择，开始录制之前可以设置
 */
@property(nonatomic,assign)LSRecordVideoStreamingQuality videoQuality;

/**
 *  @brief 视频比例选择，开始录制之前可以设置
 */
@property(nonatomic,assign)LSRecordVideoRenderScaleMode videoScaleMode;

#pragma mark - 摄像头相关
/**
 * @brief  手动聚焦点，开始录制之前可以设置
 */
@property(nonatomic,assign)CGPoint focusPoint;

/**
 * @brief 闪光灯。YES:开 NO:关
 */
@property (nonatomic, assign)BOOL flash;

/**
 * @brief 摄像头最大变焦倍数，只读。
 */
@property (nonatomic, assign, readonly) CGFloat maxZoomScale;

/**
 * @brief  摄像头变焦倍数。[1, maxZoomScale]，default:1
 */
@property (nonatomic, assign) CGFloat zoomScale;

/**
 * @brief  摄像头曝光补偿属性：在摄像头曝光补偿最大最小范围内改变曝光度
 *         value : [-1 ~ 1], defaule: 0
 */
@property(nonatomic,assign) float exposureValue;

#pragma mark - 滤镜相关
/**
 *  @brief 滤镜类型设置。
 *
 *  value : 取值参见LSRecordGPUImageFilterType。default:LS_RECORD_GPUIMAGE_NORMAL
 */
@property (nonatomic, assign) LSRecordGPUImageFilterType filterType;


/**
 *  @brief 设置磨皮滤镜的强度。仅支持NMCGPUImageZiran，NMCGPUImageMeiyan1，NMCGPUImageMeiyan2
 *  value :  [0 ~ 1], default: 0
 */
@property (nonatomic, assign) float smoothFilterIntensity;

/**
 *  @brief 设置美白滤镜强度,只支持NMCGPUImageZiran NMCGPUImageMeiyan1 NMCGPUImageMeiyan2
 *  value : [0 ~ 1], default 0
 */
@property (nonatomic, assign) float whiteningFilterIntensity;

#pragma mark - 录制相关
/**
 * @brief 分镜保存的根路径(默认路径 Documents/videos)
 */
@property (nonatomic, copy) NSString *recordFileSavedRootPath;

/**
 * @brief 分镜保存的mp4地址，只读
 */
@property (nonatomic, copy, readonly) NSString *recordFilePath;

/**
 *  @brief 开始录制
 *
 *  @param completionBlock 具体错误信息
 */
- (BOOL)startLiveStreamWithError:(void(^)(NSError *))completionBlock;

/**
 *  @brief 结束录制
 *
 *  @warning 只有 真正开始后，也就是收到LSLiveStreamingStarted消息后，才可以关闭 ,error为nil的时候，说明 结束，否则 过程中发生错误，
 */
-(void)stopLiveStream:(void(^)(NSError *))completionBlock;

#pragma mark - 混音相关
/**
 *   @brief 开始播放混音文件
 *
 *   @param musicURL 音频文件地址/文件名
 *   @param enableLoop 当前音频文件是否单曲循环
 *   @return YES:成功  NO:失败
 */
- (BOOL)startPlayMusic:(NSString*)musicURL withEnableSignleFileLooped:(BOOL)enableLoop;


/**
 *   @brief 结束播放混音文件，释放播放文件
 */
- (BOOL)stopPlayMusic;

/**
 *   @brief 继续播放混音文件
 */
- (BOOL)resumePlayMusic;

/**
 *   @brief 暂停播放混音文件
 */
- (BOOL)pausePlayMusic;

/**
 *  @brief 设置混音强度
 *
 *  @param value 混音强度范围［1 - 10］
 */
- (void)setMixIntensity:(int )value;

#pragma mark - 日志和版本号
/**
 *  @brief 设置日志级别
 *
 *  @param logLevel 信息的级别
 */
-(void)setTraceLevel:(LSMediaRecordLogLevel)logLevel;

/**
 *  @brief 日志是否输出到文件，默认存放在／library/cache
 *
 *  @param isToFile YES（default）:输出到文件 NO:不输出到文件
 */
- (void)isLogToFile:(BOOL)isToFile;

/**
 *  @brief 获取当前sdk的版本号
 *
 *  @return 版本号
 */
-(NSString*)getSDKVersionID;

#pragma mark - 扩展接口
/**
 *   @brief 添加自定义滤镜。default:nil
 */
@property (nonatomic, strong) GPUImageFilter *customFilter;


/**
 * @brief 美颜开关。指在定义滤镜上是否再叠加sdk提供的自然滤镜。default:NO
 *
 * value:
 *
 * YES:自定义滤镜（如果有）＋ 自然滤镜(LS_RECORD_GPUIMAGE_ZIRAN)。
 * NO: 自定义滤镜（如果有）＋ 普通滤镜(LS_RECORD_GPUIMAGE_NORMAL)。
 */
@property(nonatomic,assign)BOOL isBeautyFilterOn;

/**
 * @brief 用户可以通过这个接口，将处理完的数据送回来，由视频云sdk录制出去
 *
 * @param sampleBuffer 采集到的数据结构体
 */
- (void)externalInputVideoFrame:(CMSampleBufferRef)sampleBuffer;

/**
 * @brief 获取最新一帧视频截图后的回调
 *
 * pixelBuf 采集到的数据结构体
 */
@property (nonatomic,copy) void (^externalVideoFrameCallback)(CMSampleBufferRef pixelBuf);

@end

