//
//  NTESFaceUManager.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/7/25.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESFaceUManager.h"
#import "FURenderer.h"
#import "authpack.h"

@interface NTESFaceUManager () 
{
    int items[2];
    int frameID;
}

@property (nonatomic, assign) BOOL skinDetectEnable ;   // 精准美肤
@property (nonatomic, assign) NSInteger blurShape;      // 美肤类型 (0、1、) 清晰：0，朦胧：1
@property (nonatomic, assign) double blurLevel;         // 磨皮(0.0 - 6.0)
@property (nonatomic, assign) double whiteLevel;        // 美白
@property (nonatomic, assign) double redLevel;          // 红润
@property (nonatomic, assign) double eyelightingLevel;  // 亮眼
@property (nonatomic, assign) double beautyToothLevel;  // 美牙

@property (nonatomic, assign) NSInteger faceShape;        // 脸型 (0、1、2) 女神：0，网红：1，自然：2， 自定义：4
@property (nonatomic, assign) double enlargingLevel;      /**大眼 (0~1)*/
@property (nonatomic, assign) double thinningLevel;       /**瘦脸 (0~1)*/

@property (nonatomic, assign) double enlargingLevel_new;      /**新版大眼 (0~1)*/
@property (nonatomic, assign) double thinningLevel_new;       /**新版瘦脸 (0~1)*/

@property (nonatomic, assign) double jewLevel;            /**下巴 (0~1)*/
@property (nonatomic, assign) double foreheadLevel;       /**额头 (0~1)*/
@property (nonatomic, assign) double noseLevel;           /**鼻子 (0~1)*/
@property (nonatomic, assign) double mouthLevel;          /**嘴型 (0~1)*/

@end

@implementation NTESFaceUManager

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NTESFaceUManager shareInstance] start];
    });
}

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESFaceUManager alloc] init];
    });
    return instance;
}


- (instancetype)init {
    if (self = [super init]) {
        
        [self setupFaceUnity];
        [self reloadItem:nil];
        [self loadFilter];
        
    }
    return self;
}


#pragma mark - Private

- (void)start {
#warning mark ----- 具体修改见 FULiveDemo: https://github.com/Faceunity/FULiveDemo/tree/dev
    NSLog(@"NTESFaceUnity Manager start -- 具体修改见 FULiveDemo: https://github.com/Faceunity/FULiveDemo/tree/dev");
}

- (void)setupFaceUnity {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"v3.bundle" ofType:nil];
    
    /**这里新增了一个参数shouldCreateContext，设为YES的话，不用在外部设置context操作，我们会在内部创建并持有一个context。
     还有设置为YES,则需要调用FURenderer.h中的接口，不能再调用funama.h中的接口。*/
    [[FURenderer shareRenderer] setupWithDataPath:path authPackage:&g_auth_package authSize:sizeof(g_auth_package) shouldCreateContext:YES];
    
    // 开启表情跟踪优化功能
    NSData *animModelData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"anim_model.bundle" ofType:nil]];
    int res0 = fuLoadAnimModel((void *)animModelData.bytes, (int)animModelData.length);
    NSLog(@"fuLoadAnimModel %@",res0 == 0 ? @"failure":@"success" );
    
    NSData *arModelData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ardata_ex.bundle" ofType:nil]];
    
    
    int res1 = fuLoadExtendedARData((void *)arModelData.bytes, (int)arModelData.length);
    
    NSLog(@"fuLoadAnimModel %@",res1 == 0 ? @"failure":@"success" );
    
    [self setDefaultParameters];
    
    NSLog(@"faceunitySDK version:%@",[FURenderer getVersion]);
    
    [FURenderer setMaxFaces:4];
}

/*设置默认参数*/
- (void)setDefaultParameters {
    
    self.skinDetectEnable       = YES ;
    self.blurShape              = 0 ;
    self.blurLevel              = 0.7 ;
    self.whiteLevel             = 0.5 ;
    self.redLevel               = 0.5 ;
    
    self.eyelightingLevel       = 0.7 ;
    self.beautyToothLevel       = 0.7 ;
    
    self.faceShape              = 4 ;
    self.enlargingLevel         = 0.4 ;
    self.thinningLevel          = 0.4 ;
    self.enlargingLevel_new         = 0.4 ;
    self.thinningLevel_new          = 0.4 ;
    
    self.jewLevel               = 0.3 ;
    self.foreheadLevel          = 0.3 ;
    self.noseLevel              = 0.5 ;
    self.mouthLevel             = 0.4 ;
}

- (void)reloadItem:(NSString *)selectedItem {
    
    /**如果取消了道具的选择，直接销毁道具*/
    if ([selectedItem isEqual: @"noitem"] || selectedItem == nil)
    {
        if (items[1] != 0) {
            
            NSLog(@"faceunity: destroy item");
            [FURenderer destroyItem:items[1]];
            
            /**为避免道具句柄被销毁会后仍被使用导致程序出错，这里需要将存放道具句柄的items[1]设为0*/
            items[1] = 0;
        }
        
        return;
    }
    
    /**先创建道具句柄*/
    NSString *path = [[NSBundle mainBundle] pathForResource:[selectedItem stringByAppendingString:@".bundle"] ofType:nil];
    int itemHandle = [FURenderer itemWithContentsOfFile:path];
    
    /**销毁老的道具句柄*/
    if (items[1] != 0) {
        NSLog(@"faceunity: destroy item");
        [FURenderer destroyItem:items[1]];
    }
    
    /**将刚刚创建的句柄存放在items[1]中*/
    items[1] = itemHandle;
    
    NSLog(@"faceunity: load item");
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    /*Faceunity核心接口，将道具及美颜效果绘制到pixelBuffer中，执行完此函数后pixelBuffer即包含美颜及贴纸效果*/
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) ;
    [[FURenderer shareRenderer] renderPixelBuffer:pixelBuffer withFrameId:frameID items:items itemCount:sizeof(items)/sizeof(int) flipx:YES];//flipx 参数设为YES可以使道具做水平方向的镜像翻转
    frameID += 1;

}

- (void)loadFilter
{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification.bundle" ofType:nil];
    items[0] = [FURenderer itemWithContentsOfFile:path];
    
    // 设置一次就好。
    // 在美颜参数发生改变的时候需要更新
    [FURenderer itemSetParam:items[0] withName:@"skin_detect" value:@(self.skinDetectEnable)]; //是否开启皮肤检测
    [FURenderer itemSetParam:items[0] withName:@"heavy_blur" value:@(self.blurShape)]; // 美肤类型 (0、1、) 清晰：0，朦胧：1
    [FURenderer itemSetParam:items[0] withName:@"blur_level" value:@(self.blurLevel * 6.0 )]; //磨皮 (0.0 - 6.0)
    [FURenderer itemSetParam:items[0] withName:@"color_level" value:@(self.whiteLevel)]; //美白 (0~1)
    [FURenderer itemSetParam:items[0] withName:@"red_level" value:@(self.redLevel)]; //红润 (0~1)
    [FURenderer itemSetParam:items[0] withName:@"eye_bright" value:@(self.eyelightingLevel)]; // 亮眼
    [FURenderer itemSetParam:items[0] withName:@"tooth_whiten" value:@(self.beautyToothLevel)];// 美牙
    
    [FURenderer itemSetParam:items[0] withName:@"face_shape" value:@(self.faceShape)]; //美型类型 (0、1、2、3、4)女神：0，网红：1，自然：2，默认：3，自定义：4
    
    [FURenderer itemSetParam:items[0] withName:@"eye_enlarging" value:@(self.enlargingLevel_new)]; //大眼 (0~1)
    [FURenderer itemSetParam:items[0] withName:@"cheek_thinning" value:@(self.thinningLevel_new)]; //瘦脸 (0~1)
    [FURenderer itemSetParam:items[0] withName:@"intensity_chin" value:@(self.jewLevel)]; /**下巴 (0~1)*/
    [FURenderer itemSetParam:items[0] withName:@"intensity_nose" value:@(self.noseLevel)];/**鼻子 (0~1)*/
    [FURenderer itemSetParam:items[0] withName:@"intensity_forehead" value:@(self.foreheadLevel)];/**额头 (0~1)*/
    [FURenderer itemSetParam:items[0] withName:@"intensity_mouth" value:@(self.mouthLevel)];/**嘴型 (0~1)*/
}


// 不需要使用的时候销毁道具 以降低内存
- (void)clearAllItems {
    
    [FURenderer destroyAllItems];
    
    /**销毁道具后，为保证被销毁的句柄不再被使用，需要将int数组中的元素都设为0*/
    for (int i = 0; i < sizeof(items) / sizeof(int); i++) {
        items[i] = 0;
    }
    
    /**销毁道具后，清除context缓存*/
    [FURenderer OnDeviceLost];
    
    /**销毁道具后，重置人脸检测*/
    [FURenderer onCameraChange];
}

/**切换前后摄像头要调用此函数*/
- (void)onCameraChange
{
    [FURenderer onCameraChange];
}

@end
