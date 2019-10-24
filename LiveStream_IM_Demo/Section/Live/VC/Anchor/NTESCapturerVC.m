//
//  NTESCapturerVC.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESCapturerVC.h"
#import "NTESLiveDataCenter.h"

#import <FUAPIDemoBar/FUAPIDemoBar.h>
#import "FUManager.h"
@interface NTESCapturerVC ()
{
    BOOL _videoIsPause;
    BOOL _audioIsPause;
    NSMutableArray *_audioArray; //伴音文件路径
}

@property (nonatomic, assign) BOOL liveStreamIsStart; // 推流状态
@property (nonatomic, assign) BOOL allowStartLiveStream; //保证startLiveStream 接口不会重复调用
@property (nonatomic, assign) BOOL allowStopLiveStream; //保证stopLiveStream  接口不会重复调用

@property (nonatomic, assign) UIBackgroundTaskIdentifier backTaskId; //后台id
@property (nonatomic, assign) BOOL needReplayVideo;  //需要恢复视频.(前后台切换)
@property (nonatomic, assign) BOOL needReplayAudio;  //需要恢复音频.(前后台切换)
@property (nonatomic, assign) BOOL needRecoverLive;  //需要恢复推流.(网络切换)

@property (nonatomic, strong) LSMediaCapture *capturer;
@property (nonatomic, weak) UIView *container;
@property (nonatomic, copy) LiveCompleteBlock stopStreamBlock;
@property (nonatomic, copy) LiveCompleteBlock startStreamBlock;

/****   ---- FaceUnity ----     ****/
@property (nonatomic, strong) FUAPIDemoBar *demoBar ;
/****   ---- FaceUnity ----     ****/
@end

@implementation NTESCapturerVC

/****   ---- FaceUnity ----     ****/
- (void)processBuffer:(CMSampleBufferRef)sampleBuffer {
    
    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer) ;
    
    [[FUManager shareManager] renderItemsToPixelBuffer:buffer];
    
    [self.capturer externalInputSampleBuffer:sampleBuffer];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[FUManager shareManager] loadItems];
    [self.view addSubview:self.demoBar];
    
    
}


-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 164 - 160, self.view.frame.size.width, 164)];
        
        _demoBar.itemsDataSource = [FUManager shareManager].itemsDataSource;
        _demoBar.selectedItem = [FUManager shareManager].selectedItem ;
        
        _demoBar.filtersDataSource = [FUManager shareManager].filtersDataSource ;
        _demoBar.beautyFiltersDataSource = [FUManager shareManager].beautyFiltersDataSource ;
        _demoBar.filtersCHName = [FUManager shareManager].filtersCHName ;
        _demoBar.selectedFilter = [FUManager shareManager].selectedFilter ;
        [_demoBar setFilterLevel:[FUManager shareManager].selectedFilterLevel forFilter:[FUManager shareManager].selectedFilter] ;
        
        _demoBar.skinDetectEnable = [FUManager shareManager].skinDetectEnable;
        _demoBar.blurShape = [FUManager shareManager].blurShape ;
        _demoBar.blurLevel = [FUManager shareManager].blurLevel ;
        _demoBar.whiteLevel = [FUManager shareManager].whiteLevel ;
        _demoBar.redLevel = [FUManager shareManager].redLevel;
        _demoBar.eyelightingLevel = [FUManager shareManager].eyelightingLevel ;
        _demoBar.beautyToothLevel = [FUManager shareManager].beautyToothLevel ;
        _demoBar.faceShape = [FUManager shareManager].faceShape ;
        
        _demoBar.enlargingLevel = [FUManager shareManager].enlargingLevel ;
        _demoBar.thinningLevel = [FUManager shareManager].thinningLevel ;
        _demoBar.enlargingLevel_new = [FUManager shareManager].enlargingLevel_new ;
        _demoBar.thinningLevel_new = [FUManager shareManager].thinningLevel_new ;
        _demoBar.jewLevel = [FUManager shareManager].jewLevel ;
        _demoBar.foreheadLevel = [FUManager shareManager].foreheadLevel ;
        _demoBar.noseLevel = [FUManager shareManager].noseLevel ;
        _demoBar.mouthLevel = [FUManager shareManager].mouthLevel ;
        
        _demoBar.delegate = self;
    }
    return _demoBar ;
}


/**      FUAPIDemoBarDelegate       **/
- (void)demoBarDidSelectedItem:(NSString *)itemName {
    
    [[FUManager shareManager] loadItem:itemName];
}

- (void)demoBarBeautyParamChanged {
    
    [FUManager shareManager].skinDetectEnable = _demoBar.skinDetectEnable;
    [FUManager shareManager].blurShape = _demoBar.blurShape;
    [FUManager shareManager].blurLevel = _demoBar.blurLevel ;
    [FUManager shareManager].whiteLevel = _demoBar.whiteLevel;
    [FUManager shareManager].redLevel = _demoBar.redLevel;
    [FUManager shareManager].eyelightingLevel = _demoBar.eyelightingLevel;
    [FUManager shareManager].beautyToothLevel = _demoBar.beautyToothLevel;
    [FUManager shareManager].faceShape = _demoBar.faceShape;
    [FUManager shareManager].enlargingLevel = _demoBar.enlargingLevel;
    [FUManager shareManager].thinningLevel = _demoBar.thinningLevel;
    [FUManager shareManager].enlargingLevel_new = _demoBar.enlargingLevel_new;
    [FUManager shareManager].thinningLevel_new = _demoBar.thinningLevel_new;
    [FUManager shareManager].jewLevel = _demoBar.jewLevel;
    [FUManager shareManager].foreheadLevel = _demoBar.foreheadLevel;
    [FUManager shareManager].noseLevel = _demoBar.noseLevel;
    [FUManager shareManager].mouthLevel = _demoBar.mouthLevel;
    
    [FUManager shareManager].selectedFilter = _demoBar.selectedFilter ;
    [FUManager shareManager].selectedFilterLevel = _demoBar.selectedFilterLevel;
}

- (void)dealloc
{
    [_capturer unInitLiveStream];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [[FUManager shareManager] destoryItems];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    //开始直播的通知
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(onStartLiveStream:)
                                       name:LS_LiveStreaming_Started
                                     object:nil];
    //停止直播的通知
    [NTESAutoRemoveNotification addObserver:self selector:@selector(onFinishedLiveStream:)
                                       name:LS_LiveStreaming_Finished
                                     object:nil];
    //网络不好的通知
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(onBadNetworking:)
                                       name:LS_LiveStreaming_Bad
                                     object:nil];
    
    //伴音播放结束的通知
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(onAudioFileComplete:)
                                       name:LS_AudioFile_eof
                                     object:nil];
    
    //进入后台通知
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(onEnterBackground:)
                                       name:UIApplicationDidEnterBackgroundNotification
                                     object:nil];
    
    //进入前台通知
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(onBecomeActive:)
                                       name:UIApplicationDidBecomeActiveNotification
                                     object:nil];
    
    //网络监听
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(onNetwokingChanged:)
                                       name:kRealReachabilityChangedNotification
                                     object:nil];
    
    _allowStartLiveStream = YES;
    _allowStopLiveStream = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public
- (void)startVideoPreview:(NSString *)url
                container:(UIView *)view
{
    _pushUrl = url;
    _container = view;
    
    //申请权限
    __weak typeof(self) weakSelf = self;
    [NTESAuthorizationHelper requestMediaCapturerAccessWithHandler:^(NSError *error) {
        if (!error) //开始预览
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (weakSelf.capturer)
                {
                    [weakSelf.capturer startVideoPreview:view];
                }
                else
                {
                    NSLog(@"[Demo] >>>> self.capturer 为空");
                }
                
            });
        }
        else //权限未开启
        {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注意"
                                                                message:@"直播失败，请检查网络和权限重新开启"
                                                               delegate:nil cancelButtonTitle:@"确定"
                                                      otherButtonTitles: nil];
                [alertView showAlertWithCompletionHandler:^(NSInteger index) {
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                }];
            });
        }
    }];
}

- (void)stopVideoPreview
{
    if (self.capturer)
    {
        [self.capturer pauseVideoPreview];
        [self.capturer unInitLiveStream];
    }
    else
    {
        NSLog(@"[Demo] >>>> self.capturer 为空");
    }
}

- (void)startLiveStream:(LiveCompleteBlock)complete
{
    _startStreamBlock = complete;
    
    if (!_allowStartLiveStream)
    {
        NSLog(@"startStream接口调用中，等调用结束后再次调用");
        if (complete) {
            NSError *error = [[NSError alloc] initWithDomain:@"PushSdkDemo" code:10010 userInfo:nil];
            complete(error);
        }
        return;
    }
    else
    {
        _allowStartLiveStream = NO; //允许重新调用startStream接口
    }
    
    if (_liveStreamIsStart) //推流已开始，直接返回
    {
        _allowStartLiveStream = YES;
        if (_startStreamBlock)
        {
            _startStreamBlock(nil);
        }
        return;
    }
    
    if (!self.capturer)
    {
        _allowStartLiveStream = YES;
        if (complete) {
            NSError *error = [[NSError alloc] initWithDomain:@"PushSdkDemo" code:10011 userInfo:@{NTES_ERROR_MSG_KEY : @"未初始化"}];
            complete(error);
        }
        return;
    }

    [self.capturer startLiveStream:^(NSError *error) {
        if (error) {
            NSLog(@"开始推流失败，[%@]", [error localizedDescription]);
            _allowStartLiveStream = YES; //允许重新调用startStream接口
        }
        if (_startStreamBlock) {
            _startStreamBlock(error);
        }
    }];
}

- (void)stopLiveStream:(LiveCompleteBlock)complete
{
    _stopStreamBlock = complete;
    
    if (!_allowStopLiveStream)
    {
        NSLog(@"startStream接口调用中，等调用结束后再次调用");
        if (complete) {
            NSError *error = [[NSError alloc] initWithDomain:@"PushSdkDemo" code:10010 userInfo:nil];
            complete(error);
        }
        return;
    }
    else
    {
        _allowStopLiveStream = NO; //不允许调用startStream接口
    }
    
    if (!_liveStreamIsStart) //没推流，直接返回
    {
        _allowStopLiveStream = YES; //允许调用stopStream接口
        
        if (_stopStreamBlock)
        {
            _stopStreamBlock(nil);
        }
        return;
    }
    
    if (!self.capturer)
    {
        NSLog(@"[Demo] >>>> self.capturer 为空");
        if (complete) {
            NSError *error = [[NSError alloc] initWithDomain:@"PushSdkDemo" code:10011 userInfo:nil];
            complete(error);
        }
    }

    __weak typeof(self) weakSelf = self;
    [self.capturer stopLiveStream:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (error)
            {
                NSLog(@"停止推流出错[%@]", [error localizedDescription]);
                
                weakSelf.allowStopLiveStream = YES; //允许重新调用stopStream接口
                
                if (weakSelf.stopStreamBlock)
                {
                    weakSelf.stopStreamBlock(error);
                }
            }
        });
    }];
}

//暂停视频
- (void)pauseVideo:(BOOL)isPause
{
    if (!self.capturer)
    {
        NSLog(@"[Demo] >>>> self.capturer 为空");
    }
    else
    {
        _videoIsPause = isPause;
        
        if (_liveStreamIsStart)
        {
            if (isPause) //暂停
            {
                [self.capturer pauseVideoLiveStream];
            }
            else //恢复
            {
                [self.capturer resumeVideoLiveStream];
            }
        }
        else
        {
            NSLog(@"视频推流未开始");
        }
    }
}

//暂停音频
- (void)pauseAudio:(BOOL)isPause
{
    if (!self.capturer)
    {
        NSLog(@"[Demo] >>>> self.capturer 为空");
    }
    else
    {
        _audioIsPause = isPause;
        
        if (_liveStreamIsStart)
        {
            if (isPause) //暂停
            {
                [self.capturer pauseAudioLiveStream];
            }
            else //恢复
            {
                [self.capturer resumeAudioLiveStream];
            }
        }
        else
        {
            NSLog(@"音频推流未开始");
        }
    }
}

//切换镜头
- (void)switchCamera
{
    if (!self.capturer)
    {
        NSLog(@"[Demo] >>>> self.capturer 为空");
    }
    else
    {
        [self.capturer switchCamera:nil];
    }
}

//截屏
- (void)snapImage:(LiveSnapBlock)complete
{
    if (!self.capturer)
    {
        NSLog(@"[Demo] >>>> self.capturer 为空");
    }
    else
    {
        if (_liveStreamIsStart)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.capturer snapShotWithCompletionBlock:^(UIImage *latestFrameImage) {
                    if (complete) {
                        complete(latestFrameImage);
                    }
                }];
            });
        }
        else
        {
            NSLog(@"视频推流未开始");
            if (complete) {
                complete(nil);
            }
        }
    }
    
    /****   ---- FaceUnity ----     ****/
    [[FUManager shareManager] onCameraChange];
    /****   ---- FaceUnity ----     ****/
}

//滤镜
//- (void)setFilterType:(NSInteger)index
//{
//    if (index < 0 || index > 4)
//    {
//        NSLog(@"滤镜选择范围出错[0-4], 当前选择[%zi]", index);
//    }
//    else
//    {
//        if (!self.capturer)
//        {
//            NSLog(@"[Demo] >>>> self.capturer 为空");
//        }
//        else
//        {
//            [self.capturer setFilterType:(LSGpuImageFilterType)index];
//
//            self.pParaCtx.sLSVideoParaCtx.filterType = (LSGpuImageFilterType)index;
//        }
//    }
//}

//伴音
- (void)setAudioType:(NSInteger)index;
{
    static NSInteger currentIndex = 0;
    
    if (currentIndex == index) {
        return;
    }
    
    if (!self.capturer)
    {
        NSLog(@"[Demo] >>>> self.capturer 为空");
        return;
    }
    
    if (index == 0)
    {
        [self.capturer stopPlayMusic];
    }
    else
    {
        if (index - 1 < 0 || index > [NTESLiveDataCenter shareInstance].audios.count)
        {
            NSLog(@"伴音选择范围出错[1 - %zi], 当前选择[%zi]",
                  [NTESLiveDataCenter shareInstance].audios.count,
                  index);
        }
        else
        {
            [self.capturer stopPlayMusic];
            NSString *url = [NTESLiveDataCenter shareInstance].audios[index - 1];
            [self.capturer startPlayMusic:url withEnableSignleFileLooped:YES];
        }
    }
    
    currentIndex = index;
}

#pragma mark - Notication
//网络不好的情况下，连续一段时间收到这种错误，可以提醒应用层降低分辨率
-(void)onBadNetworking:(NSNotification *)notification
{
    //NSLog(@"live streaming on bad networking");
}

//收到此消息，说明直播真的开始了
-(void)onStartLiveStream:(NSNotification *)notification
{
    NSLog(@"on start live stream");//只有收到直播开始的 信号，才可以关闭直播
    
    dispatch_async(dispatch_get_main_queue(), ^(void){

        _liveStreamIsStart = YES; //推流已经开启
        
        _allowStartLiveStream = YES; //允许重新调用startStream接口

        if (_startStreamBlock) {
            _startStreamBlock(nil);
        }
        
        [self doDidStartLiveStream];
    });
}

//直播结束的通知消息
-(void)onFinishedLiveStream:(NSNotification *)notification
{
    NSLog(@"on finished live stream");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _liveStreamIsStart = NO;
        
        _allowStopLiveStream = YES; //允许重新调用stopStream接口
        
        [SVProgressHUD dismiss];
        
        if (_stopStreamBlock) {
            _stopStreamBlock(nil);
        }
        
        [self doDidStopLiveStream];
    });
}

//音频文件播放完成
- (void)onAudioFileComplete:(NSNotification *)notification
{
    NSLog(@"on finished audio file");
    
    [self doAudioFilePlayComplete];
}

//进入后台
- (void)onEnterBackground:(NSNotification *)notification
{
    UIApplication *app = [UIApplication sharedApplication];
    //申请后台时间
    _backTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"===在额外申请的10分钟内依然没有完成任务===");
        // 结束后台任务
        [app endBackgroundTask:_backTaskId];
    }];
    if(_backTaskId == UIBackgroundTaskInvalid){
        NSLog(@"===iOS版本不支持后台运行,后台任务启动失败===");
        return;
    }

//    //进入后台先暂停吧
//    if (self.pParaCtx->eOutStreamType == LS_HAVE_VIDEO)
//    {
//        if (!_videoIsPause) {
//            [self pauseVideo:YES];
//            _needReplayVideo = YES;
//        }
//    }
//    else if (self.pParaCtx->eOutStreamType == LS_HAVE_AUDIO)
//    {
////        if (!_audioIsPause) {
////            [self pauseAudio:YES];
////            _needReplayAudio = YES;
////        }
//    }
//    else
//    {
//        if (!_videoIsPause) {
//            [self pauseVideo:YES];
//            _needReplayVideo = YES;
//        }
////        if (!_audioIsPause) {
////            [self pauseAudio:YES];
////            _needReplayAudio = YES;
////        }
//    }
//
//    _needReplayVideo = YES;
//    [self pauseVideo:YES];
    
//    _needReplayAudio = YES;
//    [self pauseAudio:YES];
    
    //后台一分钟后结束推流
    //[self performSelector:@selector(stopLiveWhenBackground) withObject:nil afterDelay:30];
}

//进入前台
- (void)onBecomeActive:(NSNotification *)notification
{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//    
//    if (_needReplayAudio)
//    {
//        [self pauseAudio:NO];
//    }
//    
//    if (_needReplayVideo)
//    {
//        [self pauseVideo:NO];
//    }
}

//网络变化
- (void)onNetwokingChanged:(NSNotification *)notification
{
    RealReachability *reachability = (RealReachability *)notification.object;
    ReachabilityStatus status = [reachability currentReachabilityStatus];
    
    [SVProgressHUD dismiss];
    
    if (status == RealStatusNotReachable) //没有网络
    {
        if (_liveStreamIsStart) //正在直播，则停止
        {
            __weak typeof(self) weakSelf = self;
            [self stopLiveStream:^(NSError *error) {
                if (error)
                {
                    NSLog(@"网络断开，停止推流失败");
                }
                
                //10s后重新连接
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.needRecoverLive = YES;
                    [SVProgressHUD showWithStatus:@"重连中..."];
                    [weakSelf performSelector:@selector(restartLiveWhenNetRecover) withObject:nil afterDelay:10];
                });
            }];
        }
    }
    else if (status == RealStatusViaWiFi) //wifi网络
    {
        if ([reachability previousReachabilityStatus] == RealStatusNotReachable) //无 -> wifi
        {
            if (_needRecoverLive)
            {
                _needRecoverLive = NO;
                
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(restartLiveWhenNetRecover) object:nil];
                
                [self startLiveStream:^(NSError *error) {
                    if (error) {
                        NSLog(@"网络恢复重新开启视频流失败");
                    }
                }];
            }
        }
    }
    else if (status == RealStatusViaWWAN) //3/4G网络
    {
        if ([reachability previousReachabilityStatus] == RealStatusNotReachable) //无 -> 3/4G网络
        {
            if (_needRecoverLive)
            {
                _needRecoverLive = NO;
                
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(restartLiveWhenNetRecover) object:nil];
                
                //提示用户
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"正在使用手机流量，是否继续？"
                                                               delegate:nil
                                                      cancelButtonTitle:@"是"
                                                      otherButtonTitles:@"否", nil];
                
                __weak typeof(self) weakSelf = self;
                [alert showAlertWithCompletionHandler:^(NSInteger index) {
                    if (index == 0)
                    {
                        [SVProgressHUD show];
                        [weakSelf startLiveStream:^(NSError *error) {
                            [SVProgressHUD dismiss];
                            if (error)
                            {
                                NSLog(@"网络恢复重新开启视频流失败");
                            }
                        }];
                    }
                }];
            }
        }
        else if ([reachability previousReachabilityStatus] == RealStatusViaWiFi) //wifi -> 3/4G网络
        {
            if (_liveStreamIsStart) //正在直播
            {
                //停止推流
                [self stopLiveStream:^(NSError *error) {
                    if (error) {
                        NSLog(@"停止推流出错");
                    }
                }];
                
                //提示用户
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"正在使用手机流量，是否继续？"
                                                               delegate:nil
                                                      cancelButtonTitle:@"是"
                                                      otherButtonTitles:@"否", nil];
                __weak typeof(self) weakSelf = self;
                [alert showAlertWithCompletionHandler:^(NSInteger index) {
                    if (index == 0)
                    {
                        [SVProgressHUD show];
                        [weakSelf startLiveStream:^(NSError *error) {
                            [SVProgressHUD dismiss];
                            if (error)
                            {
                                NSLog(@"继续推流失败");
                            }
                        }];
                    }
                }];
            }
        }
    }
}

#pragma mark - Exception Handling
//后台超时结束
- (void)stopLiveWhenBackground
{
    NSLog(@"超时了，结束推流了...");
    
    UIApplication *app = [UIApplication sharedApplication];
    __weak typeof(self) weakSelf = self;
    [self stopLiveStream:^(NSError *error) {
        
        weakSelf.needReplayAudio = NO;
        weakSelf.needReplayVideo = NO;
        
        if (error != nil)
        {
            NSLog(@"退到后台的结束直播发生错误");
        }
        
        [app endBackgroundTask:weakSelf.backTaskId];
    }];
}

//断网重连接
- (void)restartLiveWhenNetRecover
{
    [SVProgressHUD dismiss];
    
    _needRecoverLive = NO;
    
    NSString *toast = [NSString stringWithFormat:@"重连失败"];
    [self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
}

#pragma mark - Getter/Setter
- (LSLiveStreamingParaCtxConfiguration *)pParaCtx
{
    return [NTESLiveDataCenter shareInstance].pParaCtx;
}

- (BOOL)isOnlyPushVideo
{
    return [NTESLiveDataCenter shareInstance].isPushOnlyVideo;
}

- (LSMediaCapture *)capturer
{
    if (!_capturer) {
        _capturer = [[LSMediaCapture alloc] initLiveStream:self.pushUrl withLivestreamParaCtxConfiguration:self.pParaCtx];
        [_capturer setTraceLevel:LS_LOG_RESV];
        [_capturer setFilterType:LS_GPUIMAGE_NORMAL];
        [_capturer setSmoothFilterIntensity:0.0];
        [_capturer setWhiteningFilterIntensity:0.0];
        
        if (_capturer == nil) {
            NSLog(@"[Demo] >>>> 推流sdk初始化失败");
        }
        
        //直播过程中发生错误的回调函数
        __weak typeof(self) weakSelf = self;
        _capturer.onLiveStreamError = ^(NSError *error){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf doLiveStreamError:error];
            });
        };
        //变焦回调
        _capturer.onZoomScaleValueChanged = ^(CGFloat value){
            [weakSelf doZoomScaleValueChanged:value];
        };
        
        
        // 获取视频数据
        /****   ---- FaceUnity ----     ****/
        _capturer.externalCaptureSampleBufferCallback = ^(CMSampleBufferRef sampleBuffer) {
            
            [weakSelf processBuffer:sampleBuffer ];
        } ;
        /****   ---- FaceUnity ----     ****/
        
    }
    return _capturer;
}

#pragma mark - 子类重载

- (void)doDidStopLiveStream {}
- (void)doDidStartLiveStream {}
- (void)doLiveStreamError:(NSError *)error {}
- (void)doZoomScaleValueChanged:(CGFloat)value {}
- (void)doAudioFilePlayComplete {}
@end
