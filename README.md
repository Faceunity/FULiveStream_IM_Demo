# FULiveStream_IM_Demo 快速接入文档

FULiveStream_IM_Demo 是集成了 [Faceunity](https://github.com/Faceunity/FULiveDemo/tree/dev) 面部跟踪和虚拟道具功能和网易云信直播功能的 Demo。

本文是 FaceUnity SDK 快速对接网易云信直播功能Demo的导读说明，关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)

## 快速集成方法

### 一、导入 SDK

将  FaceUnity  文件夹全部拖入工程中，NamaSDK所需依赖库为 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`

- 备注: 上述NamaSDK 依赖库使用 Pods 管理 会自动添加依赖,运行在iOS11以下系统时,需要手动添加`CoreML.framework`,并在**TARGETS -> Build Phases-> Link Binary With Libraries**将`CoreML.framework`手动修改为可选**Optional**


### FaceUnity 模块简介
```C
-FUManager              //nama 业务类
-FUCamera               //视频采集类(示例程序未使用)  
-authpack.h             //权限文件
+FUAPIDemoBar     //美颜工具条,可自定义
+items     //道具贴纸 xx.bundel文件

```


### 二、加入展示 FaceUnity SDK 美颜贴纸效果的  UI

1、在 `MediaCaptureViewController.m` 中打开faceU开关,导入所需头文件,并创建页面属性

```C
//faceU 开关
//#ifndef KLSMediaCaptureDemoCondense
#define KFaceUOn
//#endif

//faceU
#ifdef KFaceUOn
#import <GLKit/GLKit.h>
#import "FUAPIDemoBar.h"
#import <libCNamaSDK/FURenderer.h>
#import "FUManager.h"
#include <sys/mman.h>
#include <sys/stat.h>
#import "authpack.h"
#import <SVProgressHUD.h>
#endif

#ifdef KFaceUOn

@property(nonatomic, strong) FUAPIDemoBar *demoBar;//工具条
//@property(nonatomic, strong) UISegmentedControl *filterSegment;//faceU开关

#endif
```

2、初始化 UI，并遵循代理  FUAPIDemoBarDelegate ，实现代理方法 `bottomDidChange:` 切换贴纸 和 `filterValueChange:` 更新美颜参数。

```C

#ifdef KFaceUOn
#pragma mark - FaceUnity

-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 164 - 231, self.view.frame.size.width, 231)];
        
        _demoBar.mDelegate = self;
    }
    return _demoBar ;
}

/// 销毁道具
- (void)destoryFaceunityItems
{

    [[FUManager shareManager] destoryItems];
    
}

#pragma -FUAPIDemoBarDelegate
-(void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
}

-(void)switchRenderState:(BOOL)state{
    [FUManager shareManager].isRender = state;
}

-(void)bottomDidChange:(int)index{
    if (index < 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeBeautify];
    }
    if (index == 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeStrick];
    }
    
    if (index == 4) {
        [[FUManager shareManager] setRenderType:FUDataTypeMakeup];
    }
    if (index == 5) {
        
        [[FUManager shareManager] setRenderType:FUDataTypebody];
    }
}

#endif

```

### 三、在 `viewDidLoad:` 中初始化 SDK  并将  demoBar 添加到页面上

```C
#ifdef KFaceUOn
    //[self initFaceunity];
        
    [[FUManager shareManager] loadFilter];
    [FUManager shareManager].isRender = YES;
    [FUManager shareManager].flipx = NO;
    [FUManager shareManager].trackFlipx = NO;
     
#endif
```

### 四、图像处理

在 `viewDidLoad:` 中获取视频数据，并对图像进行处理：

```c

  //当用户想拿到摄像头的数据自己做一些处理，再经过网易视频云推送出去,请实现下列接口,在打开preview之前使用，preview看到的将是没有做过任何处理的图像

_mediaCapture.externalCaptureSampleBufferCallback = ^(CMSampleBufferRef sampleBuffer)
    {
//        NSLog(@"做一些视频前处理操作");
#ifdef KFaceUOn
    
        //Faceunity核心接口，将道具及美颜效果作用到图像中，执行完此函数pixelBuffer即包含美颜及贴纸效果
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
        
#warning 执行完上一步骤，即可将pixelBuffer绘制到屏幕上或推流到服务器进行直播
#endif
    };
    
```


### 五、销毁道具和切换摄像头

1 视图控制器生命周期结束时 `[[FUManager shareManager] destoryItems];`销毁道具。

2 切换摄像头需要调用 `[[FUManager shareManager] onCameraChange];`切换摄像头

### 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)
