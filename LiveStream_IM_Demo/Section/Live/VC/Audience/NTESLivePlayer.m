//
//  NTESLivePlayer.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/2.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESLivePlayer.h"

@interface NTESLivePlayer()

@property (nonatomic, assign) BOOL needRecoverPlay;

@property (nonatomic, copy) NSString *playUrl;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic,strong) NELivePlayerController *player;

@end

@implementation NTESLivePlayer

- (void)viewDidLoad
{
    [super viewDidLoad];

    _isFullScreen = YES;
    
    _isMute = NO;
    
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(livePlayerDidPreparedToPlay:)
                                       name:NELivePlayerDidPreparedToPlayNotification
                                     object:nil];
    
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(livePlayerPlayBackFinished:)
                                       name:NELivePlayerPlaybackFinishedNotification
                                     object:nil];
    
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(livePlayerloadStateChanged:)
                                       name:NELivePlayerLoadStateChangedNotification
                                     object:nil];
    
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(livePlayerSeekComplete:)
                                       name:NELivePlayerMoviePlayerSeekCompletedNotification
                                     object:nil];
    //网络监听
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(onNetwokingChanged:)
                                       name:kRealReachabilityChangedNotification
                                     object:nil];
}

- (void)dealloc
{
    [self releasePlayer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [SVProgressHUD dismiss];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - 通知
//开始播放
- (void)livePlayerDidPreparedToPlay:(NSNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    //取消菊花
    [SVProgressHUD dismiss];
    
    //判断类型
    [self doPlayUrlType: [self playType]];
    
    [self.player play];
    
    [self doStartPlay];
}

//结束播放
- (void)livePlayerPlayBackFinished:(NSNotification*)notification
{
    //取消菊花
    [SVProgressHUD dismiss];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    switch ([[[notification userInfo] valueForKey:NELivePlayerPlaybackDidFinishReasonUserInfoKey] intValue])
    {
        case NELPMovieFinishReasonPlaybackEnded:
        {
            NSLog(@"播放结束");
            [self doPlayComplete:nil];
            break;
        }
        case NELPMovieFinishReasonPlaybackError:
        {
            NSLog(@"playback error, will retry in 5 sec.");
            
            NSError *error = [NSError errorWithDomain:@"PlayerDomain" code:-1000 userInfo:@{NTES_ERROR_MSG_KEY: @"播放出错"}];
            
            [self doPlayComplete:error];
            
            break;
        }
        case NELPMovieFinishReasonUserExited:
            break;
            
        default:
            break;
    }
}

//缓冲状态改变
- (void)livePlayerloadStateChanged:(NSNotification *)notification
{
    NSLog(@"缓冲状态改变");
    
    NELPMovieLoadState nelpLoadState = self.player.loadState;
    
    if (nelpLoadState == NELPMovieLoadStatePlaythroughOK)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        NSLog(@"finish buffering");
        [SVProgressHUD dismiss];
    }
    else if (nelpLoadState == NELPMovieLoadStateStalled)
    {
        NSLog(@"begin buffering");
        [SVProgressHUD showWithStatus:@"缓冲中..."];
        
        //这里保险一下，主播后台视频停止后并异常退出后，播放端不会收到结束通知，这里根据状态强行结束一下。
        NSError *error = [[NSError alloc] initWithDomain:@"ntesplayer" code:-1005 userInfo:nil];
        [self performSelector:@selector(doPlayComplete:) withObject:error afterDelay:30];
    }
}

//seek完成
- (void)livePlayerSeekComplete:(NSNotification *)note
{
    if (_isPaused == NO)
    {
        [self.player play];
        [self doStartPlay];
    }
    else
    {
        [self.player pause];
    }
}

- (void)onNetwokingChanged:(NSNotification *)notification
{
    RealReachability *reachability = [RealReachability sharedInstance];
    ReachabilityStatus status = [reachability currentReachabilityStatus];
    
    [SVProgressHUD dismiss];
    
    if (status == RealStatusNotReachable) //没有网络
    {
        //销毁
        [self.player shutdown];
        
        //重连标记
        _needRecoverPlay = YES;
        
        //10秒后重新连接
        [SVProgressHUD showWithStatus:@"重连中..."];
        [self performSelector:@selector(retryWhenNetchanged) withObject:nil afterDelay:10];
    }
    else if (status == RealStatusViaWiFi) //wifi网络
    {
        if ([reachability previousReachabilityStatus] == RealStatusNotReachable) //无 -> wifi
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(retryWhenNetchanged) object:nil];
            
            if (_needRecoverPlay)
            {
                [self retry];
            }
        }
    }
    else if (status == RealStatusViaWWAN) //3/4G网络
    {
        if ([reachability previousReachabilityStatus] == RealStatusNotReachable) //无 -> 3/4G网络
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(retryWhenNetchanged) object:nil];
            
            if (_needRecoverPlay)
            {
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
                        [weakSelf retry];
                    }
                    else
                    {
                        [weakSelf doPlayComplete:nil];
                    }
                }];
            }
        }
        else if ([reachability previousReachabilityStatus] == RealStatusViaWiFi) //wifi -> 3/4G网络
        {
            //停止播放
            [self.player shutdown];
            
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
                    [weakSelf retry];
                }
                else
                {
                    [weakSelf doPlayComplete:nil];
                }
            }];
        }
    }
}

#pragma mark - 网络切换逻辑
- (void)retryWhenNetchanged
{
    [SVProgressHUD dismiss];
    
    //关闭恢复标志
    _needRecoverPlay = NO;
    
    NSString *toast = [NSString stringWithFormat:@"重连失败"];
    [self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
    
    NSError *error = [NSError errorWithDomain:@"ntesdemo.play.netclose.error"
                                         code:0x1000
                                     userInfo:@{NTES_ERROR_MSG_KEY : @"网络重连失败"}];
    [self doPlayComplete:error];
}

- (void)retry
{
    if ([RealReachability sharedInstance].currentReachabilityStatus == RealStatusViaWWAN ||
        [RealReachability sharedInstance].currentReachabilityStatus == RealStatusViaWiFi)
    {
        //销毁
        [self releasePlayer];
        
        //开始
        [self startPlay:_playUrl inView:_containerView isFull:_isFullScreen];
        
        //关闭恢复标志
        _needRecoverPlay = NO;
    }
    else
    {
        NSString *toast = [NSString stringWithFormat:@"重连失败"];
        [self.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
    }
}

#pragma mark - Private
- (NELivePlayerController *)makePlayer:(NSString *)streamUrl
{
    NELivePlayerController *player;
    [NELivePlayerController setLogLevel:NELP_LOG_DEFAULT];
    player = [[NELivePlayerController alloc] initWithContentURL:[NSURL URLWithString:streamUrl]];
    NSLog(@"live player start version %@",[NELivePlayerController getSDKVersion]);
    [player setBufferStrategy:NELPLowDelay];
    [player setHardwareDecoder:NO];
    [player setPauseInBackground:NO];
    [player setScalingMode:NELPMovieScalingModeAspectFill];
    [player setShouldAutoplay:YES];
    [player setMute:_isMute];
    [player setPlaybackTimeout:10000];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    return player;
}


- (void)releasePlayer
{
    [_player.view removeFromSuperview];
    [_player shutdown];
    _player = nil;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (NTESPlayType)playType
{
    BOOL isAudio = NO;
    BOOL isVideo = NO;
    NELPAudioInfo audioInfo;
    [_player getAudioInfo:&audioInfo];
    NELPVideoInfo videoInfo;
    [_player getVideoInfo:&videoInfo];
    
    isAudio = (audioInfo.sample_rate != 0);
    isVideo = !(videoInfo.width == 0 && videoInfo.height == 0);
    
    if (isAudio && isVideo)
    {
        _playType = NTESPlayTypeVideoAndAudio;
    }
    else if (isAudio && !isVideo)
    {
        _playType = NTESPlayTypeAudio;
    }
    else if (!isAudio && isVideo)
    {
        _playType = NTESPlayTypeVideo;
    }
    else
    {
        _playType = NTESPlayTypeNone;
    }
    return _playType;
}

#pragma mark - Public
- (void)startPlay:(NSString *)streamUrl inView:(UIView *)view isFull:(BOOL)isFull
{
    _playUrl = streamUrl;
    _containerView = view;

    //添加player view
    [self.player.view removeFromSuperview];
    self.player = [self makePlayer:streamUrl];
    
    if (isFull) {
        [self.player setScalingMode:NELPMovieScalingModeAspectFill];
    }
    else
    {
        [self.player setScalingMode:NELPMovieScalingModeAspectFit];
    }
    
    if (self.player == nil)
    {
        [SVProgressHUD showWithStatus:@"缓冲中..."];
        NSError *error = [NSError errorWithDomain:@"PlayerDomain" code:-1000 userInfo:@{NTES_ERROR_MSG_KEY: @"播放出错"}];
        [self performSelector:@selector(doPlayComplete:) withObject:error afterDelay:1];
    }
    else
    {
        [view addSubview:self.player.view];
        [self.player.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(view);
        }];
        
        //播放
        if (![self.player isPreparedToPlay]) {
            
            [SVProgressHUD showWithStatus:@"缓冲中..."];
            
            NSError *error = [NSError errorWithDomain:@"PlayerDomain" code:-1000 userInfo:@{NTES_ERROR_MSG_KEY: @"播放出错"}];
            [self performSelector:@selector(doPlayComplete:) withObject:error afterDelay:30];
            
            //准备播放
            [self.player prepareToPlay];
        }
    }
}

#pragma mark - 子类重载
- (void)doPlayComplete:(NSError *)error {

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
};
- (void)doPlayUrlType: (NTESPlayType)playType {};

- (void)doStartPlay {};

@end
