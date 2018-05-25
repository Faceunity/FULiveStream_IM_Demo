//
//  NTESPlayerVC.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/2.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESPlayerVC.h"

@interface NTESPlayerVC()

@property (nonatomic, assign) BOOL needRecoverPlay;

@property (nonatomic, copy) NSString *playUrl;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic,strong) NELivePlayerController *player;

@end

@implementation NTESPlayerVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    
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
    NSLog(@"seek完成了");
}

#pragma mark - Private
- (NELivePlayerController *)makePlayer:(NSString *)streamUrl
{
    NELivePlayerController *playerController;
    [NELivePlayerController setLogLevel:NELP_LOG_DEFAULT];
    playerController = [[NELivePlayerController alloc] initWithContentURL:[NSURL URLWithString:streamUrl]];
    NSLog(@"live player start version %@", [NELivePlayerController getSDKVersion]);
    [playerController setBufferStrategy:NELPLowDelay];
    [playerController setHardwareDecoder:NO];
    [playerController setPauseInBackground:YES];
    [playerController setScalingMode:NELPMovieScalingModeAspectFit];
    [playerController setShouldAutoplay:YES];
    [playerController setPlaybackTimeout:10000];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    return playerController;
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
