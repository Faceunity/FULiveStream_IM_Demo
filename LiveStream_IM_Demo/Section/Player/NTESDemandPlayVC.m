//
//  NTESDemandPlayVC.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDemandPlayVC.h"
#import "NTESDemandPalyerBar.h"
#import "AppDelegate.h"

@interface NTESDemandPlayVC ()<NTESDemandPalyerBarProtocol>

@property (assign, nonatomic) BOOL isForceLandscape; //强制横屏
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary; //图库
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NTESDemandPalyerBar *controlBar;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) UIAlertView *netAlert;
@property (nonatomic, assign) BOOL isBackground;
@end

@implementation NTESDemandPlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initSubviews];
    
    //进入后台通知
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(didEnterBackground:)
                                       name:UIApplicationDidEnterBackgroundNotification
                                     object:nil];
    
    //进入前台通知
    
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(didBecomeActive:)
                                       name:UIApplicationWillEnterForegroundNotification
                                     object:nil];
    
    //网络监听
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(didNetwokingChanged:)
                                       name:kRealReachabilityChangedNotification
                                     object:nil];
    
    [self startPlay:_playUrl inView:self.containerView isFull:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.controlBar showBar];
    
    self.navigationController.navigationBarHidden = YES;
}

- (BOOL)shouldAutorotate
{
    BOOL flag = _isForceLandscape;
    
    _isForceLandscape = NO;
    
    return (flag ? YES : NO);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.controlBar showBar];
}

- (instancetype)initWithName:(NSString *)name url:(NSString *)playUrl
{
    if (self = [super init]) {
        self.playUrl = playUrl;
        self.name = name;
    }
    return self;
}

- (void)initSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.controlBar];
    
    __weak typeof(self) weakSelf = self;
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    
    [self.controlBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
}

- (void)makeUITimer
{
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        [self syncUI];
    });
}

- (void)syncUI
{
    NSInteger duration = round([self.player duration]);
    self.controlBar.duration = duration;
    
    NSInteger currPos = round([self.player currentPlaybackTime]);
    self.controlBar.playTime = currPos;
    
    self.controlBar.maxValue = duration;
    self.controlBar.curValue = currPos;
    
    self.controlBar.isStart = ([self.player playbackState] == NELPMoviePlaybackStatePlaying);
}

- (void)stopSyncUI:(BOOL)isStop
{
    if (isStop)
    {
        if (_timer) {
            dispatch_source_cancel(_timer);
            _timer = nil;
        }
    }
    else
    {
        if (!_timer) {
            [self makeUITimer];
            dispatch_resume(_timer);
        }
    }
}

- (void)doBack
{
    //隐藏
    [self.controlBar dismissBar];
    
    //停止定时器
    [self stopSyncUI:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//强制横屏
- (void)doForceLandscape
{
    _isForceLandscape = YES;
    
    if ([UIDevice currentDevice].orientation != UIDeviceOrientationPortrait)
    {
        [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    }
    
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
}

//强制竖屏
- (void)doForcePortrait
{
    if ([UIDevice currentDevice].orientation != UIDeviceOrientationPortrait)
    {
        _isForceLandscape = YES;
        [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
        [UIViewController attemptRotationToDeviceOrientation];
    }
}

#pragma mark - Control
- (void)showNetRemindAlert
{
    //提示用户
    __weak typeof(self) weakSelf = self;
    [self.netAlert showAlertWithCompletionHandler:^(NSInteger index) {
        if (index == 0)
        {
            [weakSelf.player play];
        }
        else
        {
            [weakSelf doForcePortrait];
            [weakSelf performSelector:@selector(doBack) withObject:nil afterDelay:0.25];
        }
    }];
}

#pragma mark - Notication
//进入后台
- (void)didEnterBackground:(NSNotification *)notification
{
    _isBackground = YES;
    
    [self.player pause];
}

//进入前台
- (void)didBecomeActive:(NSNotification *)notification
{
    _isBackground = NO;
    
    [self checkNetStatus];
}

//网络切换
- (void)didNetwokingChanged:(NSNotification *)notification
{
    [SVProgressHUD dismiss];
    
    if (!_isBackground) {
        [self checkNetStatus];
    }
}

- (void)checkNetStatus
{
    if (GLobalRealReachability.currentReachabilityStatus == RealStatusViaWWAN) //3/4G网络
    {
        [self.player pause];
        
        if (!self.netAlert.isVisible) {
            [self showNetRemindAlert];
        }
    }
    else
    {
        if (self.netAlert.isVisible) {
            [self.netAlert dismissWithClickedButtonIndex:1 animated:NO];
        }
    }
}

#pragma mark - NTESDemandPalyerBarProtocol
//返回
- (void)PlayerBarBackAction:(NTESDemandPalyerBar *)bar
{
    [self doForcePortrait];
    
    [self performSelector:@selector(doBack) withObject:nil afterDelay:0.25];
}

//开始（暂停）
- (void)PlayerBarStartAction:(NTESDemandPalyerBar *)bar
{
    if (bar.isStart)
    {
        [self.player pause];
        
        [self stopSyncUI:YES];
        
        bar.isStart = NO;
    }
    else
    {
        [self.player play];
        
        [self stopSyncUI:NO];
        
        bar.isStart = YES;
    }
}

//静音
- (void)PlayerBarMuteAction:(NTESDemandPalyerBar *)bar
{
    [self.player setMute:!bar.isMuted];
    
    bar.isMuted = !bar.isMuted;
}

//截屏
- (void)PlayerBarSnapAction:(NTESDemandPalyerBar *)bar
{
    UIImage *image = [self.player getSnapshot];
    
    //保存相册
    [self.assetLibrary saveImage:image toAlbum:@"视频直播" completion:^(NSURL *assetURL, NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"截图成功"];
    } failure:^(NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"截图保存失败"];
    }];
}

//全屏
- (void)PlayerBarFullAction:(NTESDemandPalyerBar *)bar
{
    if (bar.isFull)
    {
        [self doForcePortrait];
    }
    else
    {
        [self doForceLandscape];
    }
    bar.isFull = !bar.isFull;
}

//进度调整
- (void)PlayerBar:(NTESDemandPalyerBar *)bar processChanged:(CGFloat)process
{
    [self.player setCurrentPlaybackTime:process];
}

#pragma mark - Overload
- (void)doStartPlay
{
    _controlBar.isStart = YES;
    
    [self stopSyncUI:NO];
    
    [self checkNetStatus];
}

- (void)doPlayComplete:(NSError *)error
{
    _controlBar.isStart = NO;
    
    [self doForcePortrait];
    
    NSString *string = (error ? @"播放出错" : @"播放完成");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:string delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    __weak typeof(self) weakSelf = self;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        [weakSelf performSelector:@selector(doBack) withObject:nil afterDelay:0.25];
    }];
}
#pragma mark - Setter
- (void)setPlayUrl:(NSString *)playUrl
{
    if (playUrl) {
        _playUrl = playUrl;
    }
}

- (void)setName:(NSString *)name
{
    _name = name;
    
    self.controlBar.titleStr = (name ?: @"未知标题");
}

#pragma mark - Getter
- (UIView *)containerView
{
    if (!_containerView)
    {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor blackColor];
        _containerView.frame = [UIScreen mainScreen].bounds;
    }
    return _containerView;
}

- (NTESDemandPalyerBar *)controlBar
{
    if (!_controlBar) {
        _controlBar = [[NTESDemandPalyerBar alloc] init];
        _controlBar.backgroundColor = [UIColor clearColor];
        _controlBar.isStart = YES;
        _controlBar.delegate = self;
    }
    return _controlBar;
}

- (ALAssetsLibrary *)assetLibrary
{
    if (!_assetLibrary) {
        _assetLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetLibrary;
}

- (UIAlertView *)netAlert
{
    if (!_netAlert)
    {
        //提示用户
        _netAlert = [[UIAlertView alloc] initWithTitle:@""
                                               message:@"正在使用手机流量，是否继续播放？"
                                              delegate:nil
                                     cancelButtonTitle:@"是"
                                     otherButtonTitles:@"否", nil];
    }
    return _netAlert;
}

@end
