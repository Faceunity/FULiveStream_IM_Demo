//
//  LSMediaTranscoding.h
//  LSMediaTranscoding
//
//  Created by NetEase on 16/12/16.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSMediaRecordingDefs.h"
#import "LSMediaTranscodingParaCtx.h"

@class UIImage;
@class GPUImageFilter;

#define LS_Transcoding_Init_Error_Key              @"LSTranscodingInitErrorKey"  //初始化失败原因key

@interface LSMediaTranscoding : NSObject

/**
 清除缓存，如果和录制sdk一同使用，请在最后释放的类中调用。
 */
+ (void)cleanGPUCache;

#pragma mark - 初始化
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief 初始化
 *
 * @param appKey appKey
 * @param error 初始化失败原因
 * @return 实例
 */
- (instancetype)initWithAppKey:(NSString *)appKey
                         error:(NSError **)error;

/**
 * @brief 实例化转码
 *
 * @param inFileName  转码输入文件路径全称，此文件需包含视频信息，
 * @param outFileName 转码输出文件路径全称
 * @param appKey appKey
 * @param error  初始化失败原因
 *
 * @warning:此处我们不做输入文件是mp4的check，只判断文件名是否为空
 */
-(instancetype)initWithInOutFileName:(NSString *)inFileName
                         outFileName:(NSString *)outFileName
                              appKey:(NSString *)appKey
                               error:(NSError **)error;


/**
 * @brief 实例化转码
 *
 * @param inMainFileName      转码输入文件路径全称，此文件为转码的主输入文件，需包含视频信息
 * @param inSecondaryFileName 转码输入文件路径全称，此文件为转码的次要输入文件，可以为空，不为空时，需包含音频信息，也仅仅使用其音频信息
 * @param outFileName         转码输出文件路径全称
 * @param appKey              appKey
 * @param error               初始化失败原因
 *
 * @warning:此处我们不做输入文件是mp4的check，只判断文件名是否为空
 */
-(instancetype)initWithMultiInOutFileName:(NSString *)inMainFileName
                      inSecondaryFileName:(NSString *)inSecondaryFileName
                              outFileName:(NSString *)outFileName
                                   appKey:(NSString *)appKey
                                    error:(NSError **)error;



/**
 * @brief 实例化转码
 *
 * @param inMainFileNameArray      转码输入文件路径全称数组，转码SDK支持多个输入文件的拼接
 * @param inSecondaryFileName      转码输入文件路径全称，此文件为转码的次要输入文件，可以为空，不为空时，需包含音频信息，也仅仅使用其音频信息
 * @param outFileName         转码输出文件路径全称
 * @param appKey              appKey
 * @param error               初始化失败原因
 *
 * @warning:此处我们不做输入文件是mp4的check，只判断文件名是否为空
 */

-(instancetype)initWithMultiInOutFileNameArray:(NSArray *)inMainFileNameArray
                           inSecondaryFileName:(NSString *)inSecondaryFileName
                                   outFileName:(NSString *)outFileName
                                        appKey:(NSString *)appKey
                                         error:(NSError **)error;



#pragma mark - 转码文件设置
/**
 * @brief 输入单个音频文件,
 *
 * @warning 这个文件一定要包含合法音频，
 */
@property(nonatomic,strong)NSString* inputSecondaryFileName;

/**
 * @brief 输入单个音视频文件,转码的主要输入文件，时长等以此为基准,当同时输入单个主文件，array[0]
 *
 * @warning 这个文件一定要包含视频，当仅仅包含音频时，请允许
 */
@property(nonatomic,strong)NSArray* inputMainFileNameArray;


/**
 * @brief 输出文件的名字
 */
@property(nonatomic,strong)NSString* outputFileName;

#pragma mark - 基本参数设置
/**
 * @brief 转码视频输出信息，编码宽度
 *
 * @warning 如果不设置输出宽高，默认使用第一个主文件的分辨率输出
 */
@property(nonatomic,assign) int videoEncodedWidth;

/**
 * @brief 转码视频输出信息，编码高度
 *
 * @warning 如果不设置输出宽高，默认使用第一个主文件的分辨率输出
 */
@property(nonatomic,assign) int videoEncodedHeight;

/**
 * @brief 转码视频输出的质量档次，有三挡
 *
 * @warning 设置这个将不会对分辨率进行采样，而是改变输出的码率，文件大小
 */
@property(nonatomic,assign)LSMediaTrascoidngVideoQuality videoQuality;

/**
 * @brief 视频伸缩模式.拉伸或等比例缩放（黑边填充）
 *
 * @warning 当多个视频文件拼接时，因为分辨率不一致导致的问题，需要通过scale来输出相同分辨率的视频
 */
@property(nonatomic,assign)LSMediaTrascoidngScaleVideoMode scaleVideoMode;

#pragma mark - 截取参数设置
/**
 * @brief 原始视频截取开始时间
 *
 * @warning 必须和durationTimeS配对使用，如果小于0或者超出截取范围，默认不截取
 */
@property(nonatomic,assign) int beginTimeS;

/**
 * @brief 原始视频截取持续时间
 *
 * @warning 必须和beginTimeS配对使用，如果小于0或者超出截取范围，默认不截取
 */
@property(nonatomic,assign) int durationTimeS;

#pragma mark - 音频参数设置
/**
 * @brief 设置静音
 *
 * @warning 设置为YES时，主文件和伴音文件均无声
 */
@property(nonatomic,assign)BOOL isMuted;

/**
 * @brief 是否混入主文件的音频，默认是 YES
 *
 * @warning 如果isMuted选项为YES，则这里失效
 */
@property(nonatomic,assign)BOOL isMixMainFileMusic;

/**
 * @brief 主文件的音量大小。取值:[0~1]，默认 0.5
 *
 * @warning 如果isMixMainFileMusic选项为NO，则这里失效
 */
@property(nonatomic,assign)float intensityOfMainAudioVolume;

/**
 * @brief 伴音文件的音量大小。取值:[0~1]，默认 0.5
 */
@property(nonatomic,assign)float intensityOfSecondAudioVolume;

#pragma mark - 转场参数设置
/**
 * @brief 伴音(转场)切换淡入淡出时长
 * 
 * @warning 伴音文件会根据视频输出总时长循环播放，当播放次数<=1次时，此设置无效
 */
@property(nonatomic,assign) int audioFadeInOutDurationS;

/**
 * @brief 视频转场淡入淡出时长
 *
 * @warning 当用户输入视频文件<=1时，此设置无效
 */
@property(nonatomic,assign) int videoFadeInOutDurationS;

#pragma mark - 裁剪参数设置
/**
 * @brief 视频的裁剪信息
 *
 * @warning 坐标系（0，0，视频分辨率宽，视频分辨率高）
 */
@property(nonatomic, strong)LSVideoCropInfo *cropInfo;

#pragma mark - 水印参数设置
/**
 * @brief 视频的水印叠加信息
 *
 * @warning 坐标系（0，0，视频分辨率宽，视频分辨率高）
 */
@property(nonatomic, strong) NSArray <LSWaMarkRectInfo *> *waterMarkInfos;

#pragma mark - 滤镜参数设置
/**
 *  @brief 设置磨皮滤镜的强度。
 *
 *  @value [0 ~ 40], default: 20
 *
 *  @warning 仅支持NMCGPUImageZiran，NMCGPUImageMeiyan1，NMCGPUImageMeiyan2
 */
@property (nonatomic, assign) float smoothFilterIntensity;

/**
 * @brief 设置美白滤镜强度
 *
 * @value [0 ~ 1], default 0.5
 *
 * @warning 只支持NMCGPUImageZiran NMCGPUImageMeiyan1 NMCGPUImageMeiyan2
 */
@property (nonatomic, assign) float whiteningFilterIntensity;

/**
 * @brief 添加自定义滤镜。default:nil
 */
@property (nonatomic, strong) GPUImageFilter *customFilter;


/**
 * @brief 美颜开关。指在定义滤镜上是否再叠加sdk提供的自然滤镜。default:NO
 * 
 * @value
 *
 * YES:自定义滤镜（如果有）＋ 自然滤镜(LS_RECORD_GPUIMAGE_ZIRAN)。
 * NO: 自定义滤镜（如果有）＋ 普通滤镜(LS_RECORD_GPUIMAGE_NORMAL)。
 */
@property(nonatomic,assign)BOOL isBeautyFilterOn;

/**
 *  @brief 滤镜类型设置。
 *  @value 取值参见LSRecordGPUImageFilterType。default:LS_RECORD_GPUIMAGE_NORMAL
 */
@property (nonatomic, assign) LSRecordGPUImageFilterType filterType;

/**
 * @brief 亮度
 *
 * @value [-1.0, 1.0], default 0.0
 */
@property(nonatomic, assign) CGFloat brightness;

/**
 * @brief 对比度
 *
 * @value [0.0, 4.0], default 1.0
 */
@property(nonatomic, assign) CGFloat contrast;

/**
 * @brief 饱和度
 *
 * @value [0.0, 2.0], default 1.0
 */
@property(nonatomic, assign) CGFloat saturation;

/**
 * @brief 锐度
 *
 * @value [-4.0, 4.0], default 0.0
 */
@property(nonatomic, assign) CGFloat sharpness;

/**
 * @brief 色温
 *
 * @value [0, 360], default 0
 */
@property(nonatomic, assign) CGFloat hue;

#pragma mark - 转码操作
/**
 * @brief 转码进度回调
 *
 * progress 进度
 */
@property(nonatomic,strong)void(^LSMediaTransProgress)(float progress);//0.0~1.0

/**
 * @brief 转码
 *
 * @warning 转码耗时操作，sdk内部实现没有另外开辟单独的线程来进行操作，将线程管理交给用户，建议参考demo实现，不要放在主线程.
 * @warning 转码过程中，请关闭预览
 *
 * @param callback 转码回调，参数为NSError，callback回调 sdk内部实现没有dispatch_async,用户需要使用callback更新UI，请建议attach回main queue
 */
-(void)doTranscoding:(void(^)(NSError* error, NSString *output))callback;

/**
 * @brief 中断转码
 *
 * @warning 转码是个耗时操作，允许在程序执行的任何时候，中断操作。中断后，之前耗费的转码时间将没有任何输出物
 */
-(void)interruptTranscoding;

#pragma mark - 预览操作
/**
 *  @brief 打开视频预览
 *
 *  @param  preview 预览窗口
 *
 *  @warning 在ipad3上，前置摄像头的分辨率不支持960*540的高分辨率,不建议在ipad上使用前置摄像头进行高清分辨率采集
 */
-(void)startVideoPreview:(UIView*)preview;

/**
 *  @brief 停止视频预览
 *
 *  @warning 在ipad3上，前置摄像头的分辨率不支持960*540的高分辨率,不建议在ipad上使用前置摄像头进行高清分辨率采集
 */
- (void)stopVideoPreview;

#pragma mark - 扩展接口(外部预处理)
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
 *
 */
@property (nonatomic,copy) void (^externalVideoFrameCallback)(CMSampleBufferRef pixelBuf);

#pragma mark - 辅助操作
/**
 * @brief 文件信息查询
 *
 * @param infoBlock 参数信息回调，当error非空时，表示文件信息获取正确，或者说文件合法，读取info，info具体含义请参考LSMediaFileInfo结构体
 */
-(void)getinputFileInfo:(NSString*)inputFileName infoBlock:(void(^)(NSError* error, LSMediaFileInfo* info)) infoBlock;

/**
 *  @brief 设置trace 的level
 *
 *  @param logLevel trace 信息的级别
 */
-(void)setTraceLevel:(LSMediaRecordLogLevel)logLevel;

/**
 *  @brief 设置是否输出到文件，
 *
 *  @warning 默认存放在／library/cache
 *
 *  @param  isToFile   是否输出到文件，默认是输出到文件，当为false时，则不输出到文件
 */
- (void)isLogToFile:(BOOL)isToFile;

/**
 * @brief 获取当前sdk的版本号
 *
 * @return sdk版本号
 */
-(NSString*)getSDKVersionID;

@end
