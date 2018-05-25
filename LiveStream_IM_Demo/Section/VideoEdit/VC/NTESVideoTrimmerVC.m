//
//  NTESVideoTrimmerVC.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/21.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESVideoTrimmerVC.h"
#import <AVFoundation/AVFoundation.h>
#import "NTESRecordVC.h"
#import "NTESRecordDataCenter.h"
#import "NTESFrameView.h"
#import "NTESVideoMaskBar.h"
#import "NTESFilterConfigView.h"
#import "NTESVideoEditVC.h"
#import "NTESCircleView.h"

#define trimmerWidth self.view.width * 0.648

typedef void(^TranscodingCompleteBlock)(NSError *error, NSString *outPath);

@interface NTESVideoTrimmerVC () <NTESFrameViewDelegate, NTESVideoMaskBarDelegate, NTESFrameViewDelegate, UIGestureRecognizerDelegate>

//遮罩View
@property(nonatomic, strong) UIView *maskView;

@property(nonatomic, assign) BOOL isPreviewStarted;
//视频层
@property(nonatomic, strong) UIView *containerView;
//滤镜按钮
@property(nonatomic, strong) UIButton *topFilterBtn;
//控制栏
@property(nonatomic, strong) NTESVideoMaskBar *videoMaskBar;
//滤镜配置信息
@property (nonatomic, strong) NTESFilterConfigView *filterConfig;
//视频路径
@property(nonatomic, copy) NSString *localVideoPath;

@property(nonatomic, strong) UIButton *okBtn;

@property(nonatomic, strong) UIButton *cancelBtn;

//trimView部分
@property(nonatomic, strong) NTESFrameView *trimmerView;

@property(nonatomic, assign) CGFloat startTime;

//转码需要的LSMediaTranscoding实例
@property(nonatomic, strong) LSMediaTranscoding *mediaTrans;
//转码放到一个子线程
@property(nonatomic, strong) dispatch_queue_t transcodingQueue;
//转码完成后的block
@property(nonatomic, strong) TranscodingCompleteBlock transcodingComplete;
//进度显示View
@property(nonatomic, strong) NTESCircleView *progressView;
//转码后的路径
@property(nonatomic, copy) NSString *outputPath;
//转码后的名称
@property(nonatomic, copy) NSString *outputName;

@end

@implementation NTESVideoTrimmerVC

- (BOOL)isNaviBarVisible {
    return NO;
}

- (instancetype)initWithVideoURL:(NSString *)videoPath trimDuration:(CGFloat)duration {
    if (self = [super init]) {
        self.localVideoPath = videoPath;
        self.trimDuration = duration;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //初始化SDK
    [self doinitTransSDK];
    //构建子视图
    [self setupSubViews];
    //开启视频预览
    [self doStartPreview];
    
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(didEnterBackGround:)
                                       name:UIApplicationDidEnterBackgroundNotification
                                     object:nil];
    
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(didBecomeActive:)
                                       name:UIApplicationDidBecomeActiveNotification
                                     object:nil];
    
}



- (void)viewWillDisappear:(BOOL)animated {
    self.trimmerView.hidden = YES;
    [self.mediaTrans stopVideoPreview];
}

- (void)setupSubViews {
    self.videoMaskBar = ({
        NTESVideoMaskBar *maskBar = [NTESVideoMaskBar new];
        maskBar.zoomSlider.hidden = YES;
        maskBar.focusImgView.hidden = YES;
        maskBar.frame = self.view.frame;
        maskBar.centerX = self.view.width / 2;
        maskBar.delegate = self;
        maskBar;
    });
    
    self.containerView = ({
        UIView *view = [UIView new];
        NTESRecordScreenScale scale = [NTESRecordDataCenter shareInstance].config.screenScale;
        view.frame = [self videoRectWithScreenScale:scale];
        view;
    });
    
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.videoMaskBar];
    
    self.topFilterBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(334 * UISreenWidthScale, 30 * UISreenHeightScale, 30, 30);
        [btn setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"filter_high"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(filterBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    [self.view addSubview:self.topFilterBtn];
    
    self.trimmerView = ({
        CGRect tmpRect = CGRectMake((UIScreenWidth - trimmerWidth) / 2, UIScreenHeight - 50, trimmerWidth, 40);
        NTESFrameView *view = [[NTESFrameView alloc] initWithFrame:tmpRect videoURL:[NSURL fileURLWithPath:self.localVideoPath] trimDuration:self.trimDuration];
        view.delegate = self;
        view;
    });
    
    self.okBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.view.width - 19 - 28, self.view.height - 42, 28, 28);
        btn.centerY = self.trimmerView.centerY;
        [btn setImage:[UIImage imageNamed:@"勾"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(okBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.cancelBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(19, self.view.height - 42, 28, 28);
        btn.centerY = self.trimmerView.centerY;
        [btn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    [self.view addSubview:self.trimmerView];
    [self.view addSubview:self.okBtn];
    [self.view addSubview:self.cancelBtn];
    
    self.maskView = ({
        UIView *view = [UIView new];
        view.frame = self.view.frame;
        view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.0f];
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        tapGR.delegate = self;
        [view addGestureRecognizer:tapGR];
        view;
    });
    
    self.filterConfig = ({
        NTESFilterConfigView *filterConfig = [[NTESFilterConfigView alloc] init];
        filterConfig.frame = CGRectMake(0, self.topFilterBtn.bottom + 11, UIScreenWidth, 66);
        filterConfig.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        filterConfig.datas = @[@"无", @"黑白", @"自然", @"粉嫩", @"怀旧"];
        filterConfig.alpha = 0;
        filterConfig;
    });
    WEAK_SELF(weakSelf);
    self.filterConfig.selectBlock = ^(NSInteger index) {
        NSLog(@"filter type:%li", index);
        LSRecordGPUImageFilterType filterType = [[NTESRecordDataCenter shareInstance] filterTypeWithFilterIndex:index];
        weakSelf.mediaTrans.filterType = filterType;
    };
    
    self.progressView = ({
        NTESCircleView *circleView = [[NTESCircleView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        circleView.center = self.view.center;
        circleView;
    });
    
    [self.view addSubview:self.progressView];
    
    self.outputPath = ({
        NSString *name = [self.localVideoPath lastPathComponent];
        NSString *tmp_name = [NSString stringWithFormat:@"%@.mp4", name];
        NSString *outPath = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:name];
        //如果存在加上时间区分
        if ([[NSFileManager defaultManager] fileExistsAtPath:outPath]) {
            tmp_name = [NSString stringWithFormat:@"%@_%@.mp4", name, [[NSDate date] stringWithFormat:@"yyyyMMddHHmmss"]];
            outPath = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:name];
        }
        outPath;
    });
}

- (void)doinitTransSDK {
    NSString *appkey = [NTESDemoConfig sharedConfig].shortVideoAppKey;
    NSError *error = nil;
    self.mediaTrans = [[LSMediaTranscoding alloc] initWithAppKey:appkey error:&error];
    
    if (error) {
        NSString *msg = error.userInfo[LS_Transcoding_Init_Error_Key];
        UIView *showView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        [showView makeToast:msg duration:2.f position:CSToastPositionCenter];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        self.transcodingQueue = dispatch_queue_create("LSTranscoding", NULL);
        self.mediaTrans.inputMainFileNameArray = @[self.localVideoPath];
        self.mediaTrans.scaleVideoMode = LS_TRANSCODING_SCALE_VIDEO_MODE_FULL;
        self.isPreviewStarted = NO;
    }
}

- (void)doStartPreview {
    self.isPreviewStarted = YES;
    [self.mediaTrans startVideoPreview:self.containerView];
}

- (void)didEnterBackGround:(NSNotification *)notification {
    if (_isPreviewStarted) {
        _isPreviewStarted = NO;
        [self.mediaTrans stopVideoPreview];
    }
}

- (void)didBecomeActive:(NSNotification *)notification {
    if (!_isPreviewStarted) {
        _isPreviewStarted = YES;
        [self.mediaTrans startVideoPreview:self.containerView];
    }
}

#pragma mark - delegate
- (void)MaskBar:(NTESVideoMaskBar *)bar exposureValueChanged:(CGFloat)exposure {
    self.mediaTrans.brightness = exposure;
}

- (void)trimmerView:(NTESFrameView *)trimmerView didEndChangeStartTime:(CGFloat)startTime {
    self.startTime = startTime;
}

#pragma mark - action && gesture

- (void)filterBtnAction:(UIButton *)sender {
    [self.view addSubview:self.maskView];
    [self showInView:self.maskView complete:nil];
    
}

- (void)okBtnAction:(UIButton *)sender {
    
    [@[self.videoMaskBar,
       self.trimmerView,
       self.topFilterBtn,
       self.okBtn] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
           view.userInteractionEnabled = NO;
       }];

    //删除本地沙盒原始文件
    [NTESSandboxHelper deleteFiles:@[self.localVideoPath]];
    self.mediaTrans.outputFileName = self.outputPath;
    self.mediaTrans.beginTimeS = (int)self.startTime;
    self.mediaTrans.durationTimeS = (int)self.trimDuration;
//    self.mediaTrans.cropInfo = [self getDemandSize];
    //点击ok btn 然后开始转码，这里需要较长时间
    [self.mediaTrans stopVideoPreview];
    
    WEAK_SELF(weakSelf);
    [self doTransVideo:^(NSError *error, NSString *outPath) {
        if (error) {
            NSLog(@"[NTESDemo] - NTESRecordResult - 转码失败 - [%@]", error);
            [weakSelf showTransFailAlert];
        }
        else {
            STRONG_SELF(strongSelf);
            NSLog(@"[NTESDemo] - NTESRecordResult - 转码成功, outpath is :%@", outPath);
            [[NTESRecordDataCenter shareInstance].recordFilePaths addObject:outPath];
            NSInteger count = strongSelf.navigationController.viewControllers.count;
            NTESRecordVC *recordVC = strongSelf.navigationController.viewControllers[count - 3];
            [strongSelf.navigationController popToViewController:recordVC animated:YES];
        }
    }];
    
}

- (void)cancelBtnAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 手势 - <UIGestureRecognizerDelegate>
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return (touch.view == self.maskView);
}

#pragma mark - Private
//显示、隐藏滤镜
- (void)FilterConfigisShow:(BOOL)isShow {
    WEAK_SELF(weakSelf);
    if (self.filterConfig.alpha == 0.f && isShow) {
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.filterConfig.alpha = 1.f;
        }];
    }else {
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.filterConfig.alpha = 0.f;
        }];
    }
}

//转码视频
- (void)doTransVideo:(TranscodingCompleteBlock)completion {
    WEAK_SELF(weakSelf);
    self.mediaTrans.LSMediaTransProgress = ^(float progress) {
//        NSLog(@"transcodeDurationMS = %zi, process = %f", weakSelf.mediaTrans.transcodeDurationMS, progress);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = progress;
        });
    };
    
    weakSelf.transcodingComplete = completion;
    
    dispatch_async(_transcodingQueue, ^{
        [weakSelf.mediaTrans doTranscoding:^(NSError *error, NSString *output) {
            if (error) {
                NSLog(@"转码失败， %@", error);
                if (weakSelf.transcodingComplete) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.progressView.progress = 0.;
                        weakSelf.transcodingComplete(error, nil);
                    });
                }
            }
            else {
                NSLog(@"转码成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.progressView.progress = 1.;
                    weakSelf.transcodingComplete(nil, output);
                });
            }
        }];
    });
}

- (void)showTransFailAlert {
    WEAK_SELF(weakSelf);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"转码失败"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles: nil];
    
    [alertView showAlertWithCompletionHandler:^(NSInteger index) {
        [weakSelf goRecordVC];
    }];
}

- (void)goRecordVC {
    NSInteger count = self.navigationController.viewControllers.count;
    NTESRecordVC *recordVC = self.navigationController.viewControllers[count - 3];
    [self.navigationController popToViewController:recordVC animated:YES];
}

#pragma mark - 视频预览窗口
- (CGRect)videoRectWithScreenScale: (NTESRecordScreenScale)scale
{
    CGRect fullScale = [UIScreen mainScreen].bounds;
    CGFloat preview_width = fullScale.size.width;
    CGFloat preview_height = fullScale.size.height;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = MIN(preview_width, preview_height);
    CGFloat height = MAX(preview_width, preview_height);
    
    switch (scale) {
        case NTESRecordScreenScale16x9:
        {
            CGFloat dstHeight = width * 16 / 9;
            if (dstHeight > height) //底边超了, 以高为主
            {
                width = height * 9/16;
                x = (preview_width - width) / 2;
            }
            else
            {
                height = dstHeight;
                y = (preview_height - height) / 2;
            }
            break;
        }
        case NTESRecordScreenScale4x3:
        {
            CGFloat dstHeight = width * 4 / 3;
            if (dstHeight > height)
            {
                width = height * 3 / 4;
                x = (preview_width - width) / 2;
            }
            else
            {
                height = dstHeight;
                y = (preview_height - height) / 2;
            }
            break;
        }
        case NTESRecordScreenScale1x1:
        {
            if (width < height) {
                height = width;
                x = (preview_width - width) / 2;
                y = (preview_height - height) / 2;
            }
            else {
                width = height;
                x = (preview_width - width) / 2;
                y = (preview_height - height) / 2;
            }
            break;
        }
        default:
            break;
    }
    return CGRectMake(x, y, width, height);
}

- (void)tapAction:(UITapGestureRecognizer *)tapGR {
    WEAK_SELF(weakSelf);
    UIView *showView = [_maskView.subviews lastObject];
    if (showView == _filterConfig) {
        [self FilterConfigisShow:NO];
        [weakSelf.maskView removeFromSuperview];
    }
}

- (void)showInView:(UIView *)view complete:(void (^)())complete
{
    [self.filterConfig removeFromSuperview];
    
    if (self.filterConfig.alpha == 0.0)
    {
        [view addSubview:self.filterConfig];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.filterConfig.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (complete) {
                complete();
            }
        }];
    }
    else
    {
        if (complete) {
            complete();
        }
    }
}

@end
