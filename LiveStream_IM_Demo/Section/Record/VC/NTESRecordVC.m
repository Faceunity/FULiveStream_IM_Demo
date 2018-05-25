//
//  NTESRecordVC.m
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/3/30.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESRecordVC.h"
#import "NTESRecordControlBar.h"
#import "NTESRecordDataCenter.h"
#import "NTESAlubmVC.h"
#import "NTESVideoEntity.h"
#import "NTESAlbumService.h"
#import "NTESVideoEditVC.h"

#import "GPUImageGrayscaleFilter.h"
#import "GPUImageHueFilter.h"

#import "NTESFaceUManager.h"

typedef void(^RecordCompleteBlock)(NSError *error, NSString *path);
typedef void(^RecordStartBlock)(NSError *error);

@interface NTESRecordVC () <NTESRecordControlBarProtocol, UITextFieldDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NTESRecordControlBar *controlBar;
@property (nonatomic, strong) LSMediaRecording *mediaCapture;
@property (nonatomic, assign) LSMediaRecordingParaCtx *pStreamParaCtx;

@property (nonatomic, strong) RecordStartBlock recordStart;
@property (nonatomic, strong) RecordCompleteBlock recordComplete;

@property (nonatomic, strong) UIAlertController *completeAlertCtl;
@property (nonatomic, weak) UITextField *videoNameTextField;

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isSkip;

@property(nonatomic, assign) BOOL isNeedResumeFaceU;

@property(nonatomic, copy) void (^externalVideoFrameCallBack)(CMSampleBufferRef pixelBuf);

@end

@implementation NTESRecordVC

- (void)dealloc
{
    [NTESRecordDataCenter clear];
}

//注意：进来之前记得申请一下权限
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化子视图
    [self doInitSubViews];
    //初始化sdk
    [self doInitRecordSdk];
    //开启预览
    [self doStartPreview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!CGRectEqualToRect(self.view.bounds, _controlBar.frame)) {
        _controlBar.frame = self.view.bounds;
        _containerView.center = CGPointMake(self.view.width/2, self.view.height/2);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController setNeedsStatusBarAppearanceUpdate];
    
    self.navigationController.navigationBarHidden = YES;
    
    _controlBar.completeRecordSections = [NTESRecordDataCenter shareInstance].recordFilePaths.count;
    
    //[[NTESRecordDataCenter shareInstance].recordFilePaths removeAllObjects];
    //[NTESSandboxHelper deleteFiles:[NTESRecordDataCenter shareInstance].recordFilePaths];

    self.controlBar.hidden = NO;
    self.containerView.hidden = NO;
    
    [_mediaCapture resumeVideoPreview];
    
    if (_isNeedResumeFaceU) {
        //恢复预览的时候继续处理
        _mediaCapture.externalVideoFrameCallback = _externalVideoFrameCallBack;
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    self.containerView.hidden = YES;
    self.controlBar.hidden = YES;

    [_mediaCapture pauseVideoPreview];
    
    //这里目前需要一直有 faceU
    _isNeedResumeFaceU = YES;
}

- (void)doInitSubViews
{
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.controlBar];
    
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(appDidEnterBackground:)
                                       name:UIApplicationDidEnterBackgroundNotification
                                     object:nil];
}

#pragma mark - Function
//录制sdk初始化
- (void)doInitRecordSdk
{
    NSError *error = nil;
    NSString *appKey = [NTESDemoConfig sharedConfig].shortVideoAppKey;
    _mediaCapture = [[LSMediaRecording alloc] initLiveStreamWithLivestreamParaCtx:self.pStreamParaCtx appKey:appKey error:&error];
    if (error)
    {
        NSString *msg = error.userInfo[LS_Recording_Init_Error_Key];
        UIView *showView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        [showView makeToast:msg duration:2 position:CSToastPositionCenter];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [_mediaCapture setSmoothFilterIntensity:[NTESRecordDataCenter shareInstance].config.beautyValue / 40.f];
        NSInteger filterIndex = [NTESRecordDataCenter shareInstance].config.filterIndex;
        [_mediaCapture setFilterType:[[NTESRecordDataCenter shareInstance] filterTypeWithFilterIndex:filterIndex]];
        [_mediaCapture getSDKVersionID];
        [_mediaCapture setExposureValue:[NTESRecordDataCenter shareInstance].config.exposureValue];
        
        WEAK_SELF(weakSelf);
        _externalVideoFrameCallBack = ^(CMSampleBufferRef pixelBuf) {
            [[NTESFaceUManager shareInstance] processSampleBuffer:pixelBuf];
            [weakSelf.mediaCapture externalInputVideoFrame:pixelBuf];
        };
        
        [NTESAutoRemoveNotification addObserver:self
                                       selector:@selector(onStartLiveStream:)
                                           name:LS_Recording_Started
                                         object:nil];
        [NTESAutoRemoveNotification addObserver:self
                                       selector:@selector(onFinishedLiveStream:)
                                           name:LS_Recording_Finished
                                         object:nil];
    }
}

//开启预览
- (void)doStartPreview
{
    if (self.pStreamParaCtx.eOutStreamType != LS_HAVE_AUDIO) {
        //打开摄像头预览
        [_mediaCapture startVideoPreview:self.containerView];
    }
}

//开始录制
- (void)doStartRecord:(RecordStartBlock)comlete
{
    _recordStart = comlete;
    
    _mediaCapture.recordFileSavedRootPath = [NTESSandboxHelper videoRecordPath];

    [_mediaCapture startLiveStreamWithError:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                if (comlete) {
                    comlete(error);
                }
            }
        });
    }];
}

//结束录制
- (void)doStopRecord:(RecordCompleteBlock)complete
{
    _recordComplete = complete;
    
    [_mediaCapture stopLiveStream:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (complete) {
                    complete(error, nil);
                }
            }
        });
    }];
}

#pragma mark - Notication
//收到此消息，说明 录制真的开始了
- (void)onStartLiveStream:(NSNotification *)note
{
    _isRecording = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_recordStart) {
            _recordStart(nil);
        }
    });
}

// 录制结束的通知消息
- (void)onFinishedLiveStream:(NSNotification *)note
{
    NSLog(@"录制结束，路径是 -- [%@], 根目录是 -- [%@]", _mediaCapture.recordFilePath, _mediaCapture.recordFileSavedRootPath);
    
    _isRecording = NO;
    
    NSError *error = [NSError errorWithDomain:@"ntes.record.complete" code:1001 userInfo:@{NTES_ERROR_MSG_KEY: @"文件路径为空"}];

    if (_mediaCapture.recordFilePath) {
        error = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_recordComplete) {
            _recordComplete(error, _mediaCapture.recordFilePath);
        }
    });
}

//进入后台通知
- (void)appDidEnterBackground:(NSNotification *)note
{
    if (_isRecording) //停止
    {
        [_controlBar sendCancelRecordAction];
    }
}

#pragma mark - <NTESRecordControlBarProtocol>
//退出事件
- (void)ControlBarQuit:(NTESRecordControlBar *)bar
{
    if (_mediaCapture.externalVideoFrameCallback != nil) {
        _mediaCapture.externalVideoFrameCallback = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//摄像头切换事件
- (void)ControlBarCameraSwitch:(NTESRecordControlBar *)bar {
    [_mediaCapture switchCamera];
}

//faceU处理
- (void)ControlBar:(NTESRecordControlBar *)bar face:(NSInteger)index {
    
    NSArray *items = [NTESRecordDataCenter shareInstance].config.faceUDatas;
    if (index != 0) {
        [[NTESFaceUManager shareInstance] reloadItem:items[index]];
        _mediaCapture.externalVideoFrameCallback = _externalVideoFrameCallBack;
    }
    else {
        _mediaCapture.externalVideoFrameCallback = nil;
    }
}

//美颜（磨皮）强度
- (void)ControlBar:(NTESRecordControlBar *)bar smooth:(CGFloat)smooth
{
    NSLog(@"美颜值 : %f", smooth);
    [_mediaCapture setSmoothFilterIntensity:smooth];
}

//滤镜事件
- (void)ControlBar:(NTESRecordControlBar *)bar filter:(NSInteger)index
{
    NSLog(@"filter Type:%zi", index);
    if (index == 5) {
        GPUImageGrayscaleFilter *customFilter1 = [GPUImageGrayscaleFilter new];
        [_mediaCapture setCustomFilter:customFilter1];
    }
    else if (index == 6) {
        GPUImageHueFilter *customFilter2 = [GPUImageHueFilter new];
        [_mediaCapture setCustomFilter:customFilter2];
    }
    LSRecordGPUImageFilterType filterType = [[NTESRecordDataCenter shareInstance] filterTypeWithFilterIndex:index];
    [_mediaCapture setFilterType:filterType];
}

//曝光率事件
- (void)ControlBar:(NTESRecordControlBar *)bar exposure:(CGFloat)exposure
{
    //NSLog(@"曝光值 : %f", exposure);
    [_mediaCapture setExposureValue:exposure];
}

//分辨率事件
- (void)ControlBar:(NTESRecordControlBar *)bar resolution:(NTESRecordResolution)resolution
{
    NSLog(@"分辨率 : %zi", resolution);
    LSRecordVideoStreamingQuality quality = [[NTESRecordDataCenter shareInstance] recordQualityWithResolution:resolution];
    [_mediaCapture setVideoQuality:quality];
}

//画幅事件
- (void)ControlBar:(NTESRecordControlBar *)bar frame:(CGRect)frame scale:(NTESRecordScreenScale)scale
{
    NSLog(@"画幅 : %zi", scale);
    
    //调整container
    self.containerView.clipsToBounds = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.containerView.frame = frame;
        self.containerView.centerX = self.view.width/2;
        [self.containerView.layer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.frame = self.containerView.bounds;
        }];
    }];
    
    //设置下去
    LSRecordVideoRenderScaleMode mode = [[NTESRecordDataCenter shareInstance] recordScaleModeWithScreenScale:scale];
    [_mediaCapture setVideoScaleMode:mode];
}

//手动聚焦事件
- (void)ControlBar:(NTESRecordControlBar *)bar focusPoint:(CGPoint)point
{
    CGPoint dstPoint = [_controlBar convertPoint:point toView:_containerView];
    
    //这里需要传入0~1范围内的值，需要做一下比例转换
    CGPoint focusPoint = CGPointMake(dstPoint.x/_containerView.width, dstPoint.y/_containerView.height);
    
    //NSLog(@"聚焦点: %@", NSStringFromCGPoint(focusPoint));
    
    [_mediaCapture setFocusPoint:focusPoint];
}

//变焦事件
- (void)ContorlBar:(NTESRecordControlBar *)bar zoom:(CGFloat)zoom
{
    //NSLog(@"变焦倍数: %f", zoom);
    
    [_mediaCapture setZoomScale:zoom];
}

//开始录制事件
- (void)ControlBarRecordDidStart:(NTESRecordControlBar *)bar
{
    WEAK_SELF(weakSelf);
    [self doStartRecord:^(NSError *error) {
        STRONG_SELF(strongSelf);
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"开始录制失败:[%@]", error];
            [strongSelf.view makeToast:msg duration:2 position:CSToastPositionCenter];
        }
        else
        {
            [strongSelf.controlBar startRecordAnimation];
        }
    }];
}

//取消录制事件
- (void)ControlBarRecordDidCancelled:(NTESRecordControlBar *)bar
{
    __weak typeof(self) weakSelf = self;
    [self doStopRecord:^(NSError *error, NSString *path) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"结束录制失败:[%@]", error];
            [weakSelf.view makeToast:msg duration:2 position:CSToastPositionCenter];
        }
        else
        {
            [NTESSandboxHelper deleteFiles:@[path]]; //删除录制的文件
            [weakSelf.controlBar stopRecordAnimation]; //停止动画
        }
    }];
}

//删除录制事件(上一个)
- (void)ControlBarRecordDidDeleted:(NTESRecordControlBar *)bar
{
    NSString *path = [[NTESRecordDataCenter shareInstance].recordFilePaths lastObject];
    if (path) {
        [NTESSandboxHelper deleteFiles:@[path]]; //删除文件
    }
    [[NTESRecordDataCenter shareInstance].recordFilePaths removeLastObject]; //删除路径
    self.controlBar.completeRecordSections--; //更新UI
}

//完成录制事件
- (void)ControlBarRecordDidCompleted:(NTESRecordControlBar *)bar isSkip:(BOOL)isSkip
{
    NSLog(@"点击了完成");
    
    _isSkip = isSkip;
    
    [self presentViewController:self.completeAlertCtl animated:YES completion:nil];

}

//录制动画结束
- (void)ControlBarRecordAnimationDidStop:(NTESRecordControlBar *)bar  isCancel:(BOOL)isCancel
{
    //主动取消，不用处理
    if (isCancel)
    {
        return;
    }
    
    //录制时间到，需要停止录制
    __weak typeof(self) weakSelf = self;
    [self doStopRecord:^(NSError *error, NSString *path) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"结束录制失败:[%@]", error];
            [weakSelf.view makeToast:msg duration:2 position:CSToastPositionCenter];
        }
        else //录制完成
        {
            //录制小段完成了
            ++weakSelf.controlBar.completeRecordSections; //显示录制的时间段
            [[NTESRecordDataCenter shareInstance].recordFilePaths addObject:path]; //存储路径
        }
    }];
}

//选择相册添加视频事件
- (void)ContorlBarAddVideo:(NTESRecordControlBar *)bar withDuration:(CGFloat)duration {
    NTESAlubmVC *album = [NTESAlubmVC albumWithMaxNumber:1 withMinDuration:duration selected:nil];
    [self.navigationController pushViewController:album animated:YES];
}

#pragma mark - 视频名称输入 - <UITextFieldDelegate>
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""])
    {
        return YES;
    }
    else
    {
        BOOL format = [NSString checkVideoName:string];
        NSString *msg = nil;
        if (!format)
        {
            msg = @"只可输入汉字、英文、数字和下划线";
        }
        BOOL length = (textField.text.length < 20);
        if (!length)
        {
            msg = @"名称最多只可输入20位";
        }
        
        if (msg) {
            [self.view makeToast:msg duration:2 position:CSToastPositionCenter];
        }
        
        return (msg == nil);
    }
}

#pragma mark - Getter
- (UIView *)containerView
{
    if (!_containerView)
    {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor lightGrayColor];
        
        NTESRecordScreenScale scale = [NTESRecordDataCenter shareInstance].config.screenScale;
        _containerView.frame = [self.controlBar videoRectWithScreenScale:scale];
    }
    return _containerView;
}

- (NTESRecordControlBar *)controlBar
{
    if (!_controlBar) {
        _controlBar = [[NTESRecordControlBar alloc] init];
        _controlBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.0];
        _controlBar.completeRecordSections = [NTESRecordDataCenter shareInstance].recordFilePaths.count;
        _controlBar.delegate = self;
    }
    return _controlBar;
}

- (LSMediaRecordingParaCtx *)pStreamParaCtx
{
    return [NTESRecordDataCenter shareInstance].pRecordPara;
}

- (UIAlertController *)completeAlertCtl
{
    if (!_completeAlertCtl) {
        _completeAlertCtl = [UIAlertController alertControllerWithTitle:@"拍摄已完成!" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        WEAK_SELF(weakSelf);
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"删除上分段" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.controlBar sendDeleteRecordAction];
        }];
        [_completeAlertCtl addAction:cancelAction];
        
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"下一步" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NTESVideoEditVC *editVC = [[NTESVideoEditVC alloc] init];
            [weakSelf.navigationController pushViewController:editVC animated:YES];
            
        }];
        [_completeAlertCtl addAction:sureAction];
    }
    return _completeAlertCtl;
}

@end
