//
//  NTESVideoEditVC.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/5/26.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESVideoEditVC.h"
#import "NTESVideoEditView.h"
#import "NTESRecordDataCenter.h"
#import "NTESTranscodingDataCenter.h"
#import "NTESArrangeView.h"
#import "NTESTrimView.h"
#import "NTESCircleView.h"
#import "NTESVideoEntity.h"
#import "NTESShortVideoHomeVC.h"
#import "UIColor+NTESHelper.h"
#import "NTESTextImageView.h"


typedef void(^TranscodingCompleteBlock)(NSError *error, NSString *outPath);

#define videoFadeInOutDuration 3

@interface NTESVideoEditVC () <NTESVideoEditViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, NTESTextImageViewDelegate>

@property(nonatomic, strong) NTESVideoEditView *editView;
//FIX ME:视频预览界面
@property(nonatomic, strong) UIView *previewView;

@property(nonatomic, strong) LSMediaTranscoding *mediaTrans;

@property (nonatomic, strong) dispatch_queue_t transcodingQueue;

@property (nonatomic, strong) TranscodingCompleteBlock transcodingComplete;

@property(nonatomic, assign) BOOL isPreviewStarted;

@property(nonatomic, strong) UIImageView *textureImg;

@property(nonatomic, assign) CGPoint startPoint;

@property(nonatomic, strong) AVAudioPlayer *audioPlayer;

@property(nonatomic, assign) CGFloat startTextureTime;

@property(nonatomic, assign) CGFloat endTextureTime;

@property(nonatomic, assign) NSInteger firstVideoWidth;

@property(nonatomic, assign) NSInteger firstVideoHeight;

@property (nonatomic, strong) UIAlertController *alertCtl;

@property (nonatomic, weak) UITextField *videoNameTextField;

@property(nonatomic, strong) NSMutableArray *tempVideos;

//输入和输出文件
@property (nonatomic, copy) NSString *outputPath;
@property (nonatomic, copy) NSString *outputName;

@property(nonatomic, strong) NTESCircleView *progressView;

@property(nonatomic, strong) UILabel *tipLabel;

@property(nonatomic, strong) UIImageView *videoImageView;
@property(nonatomic, strong) UIView *maskView;

//添加字幕
@property(nonatomic, strong) NTESTextImageView *textImgView;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) NSString *textContent;

@end

@implementation NTESVideoEditVC

- (BOOL)isNaviBarVisible {
    return YES;
}

- (BOOL)isStatusBarVisible {
    return YES;
}

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configNavigationBar];

    self.title = @"视频编辑Demo";
    self.leftBtnTitle = @"返回";
    self.rightBtnTitle = @"完成";
    [self.videoNameTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    //初始化转码sdk
    [self doinitTranscoding];
    
    [self setupSubViews];
    
    [self dostartPreview];
}

- (void)configNavigationBar {
    UIImage *backImg = [UIImage imageWithColor:UIColorFromRGB(0x000000) size:CGSizeMake(100, 100)];
    [self.navigationController.navigationBar setBackgroundImage:backImg forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:![self isNaviBarVisible] animated:YES];
    self.editView.filePaths = [[NTESRecordDataCenter shareInstance] recordFilePaths];
    self.tempVideos  = [[NSMutableArray alloc] initWithArray:[NTESRecordDataCenter shareInstance].recordFilePaths];
}

- (void)viewWillDisappear:(BOOL)animated {
    //释放资源
    self.isPreviewStarted = NO;
    self.tempVideos = nil;
    [self.mediaTrans stopVideoPreview];
    [self releaseAudioPlayer];
    self.mediaTrans = nil;
    [NTESTranscodingDataCenter clear];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)doinitTranscoding {
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
        _transcodingQueue = dispatch_queue_create("LSTranscoding", NULL);
        self.mediaTrans.inputMainFileNameArray = [NTESRecordDataCenter shareInstance].recordFilePaths;
        self.mediaTrans.scaleVideoMode = LS_TRANSCODING_SCALE_VIDEO_MODE_FULL_BLACK;
        self.isPreviewStarted = NO;
    }
}

- (void)setupSubViews {
    self.view.backgroundColor = [UIColor blackColor];
    self.textColor = [UIColor blackColor];
    CGFloat editViewHeight = [self getEditViewHeight];
    
    self.previewView = ({
        UIView *view = [[UIView alloc] init];
        NTESRecordScreenScale scale = [NTESRecordDataCenter shareInstance].config.screenScale;
        view.frame = [self videoRectWithScreenScale:scale];
        view;
    });
    
    self.editView = ({
        NTESVideoEditView *view = [[NTESVideoEditView alloc] initWithFrame:CGRectMake(0, self.view.height - editViewHeight, self.view.width, editViewHeight) filePaths:[NTESRecordDataCenter shareInstance].recordFilePaths];
        view.delegate = self;
        view;
    });
    
    [self.view addSubview:self.previewView];
    [self.view addSubview:self.editView];
    
    self.videoImageView = ({
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 2*16, self.view.height - 3*32)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView;
    });
    self.videoImageView.centerX = self.view.width/2;
    [self.view addSubview:self.videoImageView];
    
    self.maskView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        view.frame = self.view.frame;
        view.hidden = YES;
        view;
    });
    [self.view addSubview:_maskView];
    
    self.progressView = ({
        NTESCircleView *view = [NTESCircleView new];
        view.frame = CGRectMake(0, 0, 64, 64);
        view.center = self.view.center;
        view;
    });
    
    self.tipLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.videoImageView.bottom - 64, self.view.width - 32, 64)];
        label.centerX = self.view.centerX;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"正在保存视频，为防止视频丢失请不要关闭本页面";
        label.numberOfLines = 2;
        label.font = [UIFont systemFontOfSize:13];
        label;
    });
    [self.view addSubview:self.tipLabel];
    self.tipLabel.hidden = YES;
    
}

- (void)dostartPreview {
    self.isPreviewStarted = YES;
    [self.mediaTrans startVideoPreview:self.previewView];
}

#pragma mark - action && gesture

- (void)doRightNavBarRightBtnAction {
    NSLog(@"VideoEditVC 点击了完成");
    [self presentViewController:self.alertCtl animated:YES completion:nil];
}

- (void)goUpdateVC {
    NSInteger index = self.navigationController.viewControllers.count - 1;
    index -= 2;
    if (index < 0) {
        index = 0;
    }
    UIViewController *vc = self.navigationController.viewControllers[index];
    [self.navigationController popToViewController:vc animated:YES];
}

#pragma mark - NTESVideoEditViewDelegate

- (void)editView:(NTESVideoEditView *)editView brightnessValue:(CGFloat)brightness {
    self.mediaTrans.brightness = brightness;
}

- (void)editView:(NTESVideoEditView *)editView contrastValue:(CGFloat)contrast {
    self.mediaTrans.contrast = contrast;
}

- (void)editView:(NTESVideoEditView *)editView saturationValue:(CGFloat)saturation {
    self.mediaTrans.saturation = saturation;
}

- (void)editView:(NTESVideoEditView *)editView temperatureValue:(CGFloat)temperature {
    self.mediaTrans.hue = temperature;
}

-(void)editView:(NTESVideoEditView *)editView sharpnessValue:(CGFloat)sharpness {
    self.mediaTrans.sharpness = sharpness;
}

- (void)editView:(NTESVideoEditView *)editView switchForward:(NSInteger)pos {
    NSString *filePath = self.tempVideos[pos];
    self.tempVideos[pos] = self.tempVideos[pos - 1];
    self.tempVideos[pos - 1] = filePath;
}

- (void)editView:(NTESVideoEditView *)editView switchBackward:(NSInteger)pos {
    NSString *filePath = self.tempVideos[pos];
    self.tempVideos[pos] = self.tempVideos[pos + 1];
    self.tempVideos[pos + 1] = filePath;
}

- (void)editView:(NTESVideoEditView *)editView audioValue:(CGFloat)audioValue {
    NSLog(@"audioValue:%lf", audioValue);
    self.mediaTrans.intensityOfMainAudioVolume = audioValue / 100;
    if (self.audioPlayer) {
        self.audioPlayer.volume = (1 - self.mediaTrans.intensityOfMainAudioVolume);
    }
}

- (void)editView:(NTESVideoEditView *)editView hasFade:(BOOL)hasFaded {
    if (hasFaded) {
        self.mediaTrans.videoFadeInOutDurationS = videoFadeInOutDuration;
    }
    else {
        self.mediaTrans.videoFadeInOutDurationS = 0;
    }
}

//贴图
- (void)editView:(NTESVideoEditView *)editView selectedTexture:(NSInteger)index {
    if (self.textureImg) {
        [self.textureImg removeFromSuperview];
    }
    NSArray *imgArray = @[@"", @"亲亲大", @"刺刀大", @"鬼脸大"];
    if (index > 0 && index < 4) {
        UIImage *img = [UIImage imageNamed:[imgArray objectAtIndex:index]];
        self.textureImg = ({
            UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            imgView.userInteractionEnabled = YES;
            imgView.tag = 100;
            imgView;
        });
        [self.previewView addSubview:self.textureImg];
    }else if (index == 0) {
        if (self.textureImg) {
            [self.textureImg removeFromSuperview];
            self.textureImg = nil;
        }
    }
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureOnImgDetected:)];
    panGR.delegate = self;
    panGR.maximumNumberOfTouches = 1;
    panGR.minimumNumberOfTouches = 1;
    [self.textureImg addGestureRecognizer:panGR];
}

- (void)editView:(NTESVideoEditView *)editView showTextureFromTime:(CGFloat)startTime toTime:(CGFloat)endTime {
    self.startTextureTime = startTime;
    self.endTextureTime = endTime;
}

//伴音
- (void)editView:(NTESVideoEditView *)editView selectedAudio:(NSInteger)index {
    NSString *audio1Path = [[NSBundle mainBundle] pathForResource:@"test_1" ofType:@"mp3"];
    NSString *audio2Path = [[NSBundle mainBundle] pathForResource:@"test_2" ofType:@"mp3"];
    NSString *audio3Path = [[NSBundle mainBundle] pathForResource:@"test_3" ofType:@"mp3"];
    
    switch (index) {
        case 0:
        {
            [self releaseAudioPlayer];
            self.mediaTrans.inputSecondaryFileName = nil;
            self.mediaTrans.intensityOfSecondAudioVolume = 0.f;
        }
            break;
        case 1:
        {
            [self releaseAudioPlayer];
            self.mediaTrans.inputSecondaryFileName = audio1Path;
            [self playAudiowithPath:audio1Path];
        }
            break;
        case 2:
        {
            [self releaseAudioPlayer];
            self.mediaTrans.inputSecondaryFileName = audio2Path;
            [self playAudiowithPath:audio2Path];
        }
            break;
        case 3:
        {
            [self releaseAudioPlayer];
            self.mediaTrans.inputSecondaryFileName = audio3Path;
            [self playAudiowithPath:audio3Path];
        }
            break;
        default:
            break;
    }
}

- (void)editView:(NTESVideoEditView *)editView mainVolume:(CGFloat)mainVolume {
    self.mediaTrans.intensityOfMainAudioVolume = mainVolume;
    if ([self.mediaTrans.inputSecondaryFileName length] > 0) {
        self.mediaTrans.intensityOfSecondAudioVolume = 1 - mainVolume;
    }
}

//文字
- (void)editView:(NTESVideoEditView *)editView selectText:(NSInteger)textIndex {
    if (self.textImgView) {
        self.textContent = [self.textImgView textString];
        [self.textImgView removeFromSuperview];
    }
    NSArray *imgArr = @[@"", @"yellow", @"red", @"bubble"];
    switch (textIndex) {
        case 0:
        {
            if (self.textImgView) {
                [self.textImgView removeFromSuperview];
                self.textImgView = nil;
            }
        }
            break;
        case 1: case 2: case 3:
        {
            UIImage *img = [UIImage imageNamed:[imgArr objectAtIndex:textIndex]];
            self.textImgView = ({
                CGRect rect;
                if (textIndex == 3) {
                    rect = CGRectMake(self.previewView.width / 4, self.previewView.height / 2, self.previewView.width / 2, 80);
                }
                else {
                    rect = CGRectMake(0, self.previewView.height / 2, self.previewView.width, 50);
                }
                if (!self.textContent) {
                    self.textContent = @"哈哈哈";
                }
                NTESTextImageView *imgView = [[NTESTextImageView alloc] initWithFrame:rect andSize:self.previewView.size andText:self.textContent andColor:self.textColor andBackImage:img];
                imgView.textImgViewDelegate = self;
                imgView;
            });
            [self.previewView addSubview:self.textImgView];
        }
            break;
        default:
            break;
    }
}

- (void)editView:(NTESVideoEditView *)editView selectTextColor:(NSInteger)colorType {
    NSArray *colorArr = @[@"000000", @"FFFFFF", @"FBDC40", @"F21111", @"0021FF", @"009E1A"];
    if (self.textImgView) {
        self.textColor = [UIColor colorWithHexString:colorArr[colorType]];
        [self.textImgView changeTextColor:self.textColor];
    }
}

#pragma mark - Private
- (void)releaseAudioPlayer {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
}

- (void)playAudiowithPath:(NSString *)filePath {
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.volume = 1 - self.mediaTrans.intensityOfMainAudioVolume;
    if (!error) {
        self.audioPlayer.numberOfLoops = -1;
    }
    [self.audioPlayer play];
}

- (void)doSnapImage {
    NSString *str = self.tempVideos[0];
    UIImage *img = [UIImage imageWithVideoPath:str];
    if (img) {
        self.maskView.hidden = NO;
        self.videoImageView.image = img;
    }else {
        NSLog(@"截图失败");
    }
}

- (void)doMerge {
    WEAK_SELF(weakSelf);
    [self doMergeVideo:^(NSError *error, NSString *outPath) {
        //融合前删掉NTESRecordDataCenter recordFilePath
        [NTESSandboxHelper deleteFiles:[NTESRecordDataCenter shareInstance].recordFilePaths];
        if (error)
        {
            NSLog(@"[NTESDemo] - NTESRecordResult - 转码失败 - [%@]", error);
            [weakSelf showSaveFailAlert:@"转码失败"];
        }
        else
        {
            NSLog(@"[NTESDemo] - NTESRecordResult - 转码成功");
            //转码成功，先进行保存操作
            [self doSaveVideoToAlbum:outPath complete:^(NSError *error) {
                STRONG_SELF(strongSelf);
                NSString *name = weakSelf.outputName;
                NSString *relPath = [outPath lastPathComponent];
                NSLog(@"转码relPath:%@, outPath%@", relPath, outPath);
                [strongSelf doUpdateVideoName:name relPath:relPath];
//                if (error)
//                {   //保存相册失败
//                    strongSelf.tipLabel.hidden = YES;
//                    [strongSelf showSaveFailAlert:@"保存到相册失败"];
//                }
//                else
//                {   //回上传页面
                    NSLog(@"回上传页面");
                    strongSelf.tipLabel.hidden = YES;
                    strongSelf.progressView.hidden = YES;
                    [SVProgressHUD showSuccessWithStatus:@"保存到相册成功"];
                    [strongSelf performSelector:@selector(goUpdateVC) withObject:nil afterDelay:1];
                    
            }];
        }
        
    }];
}

- (void)doMergeVideo:(TranscodingCompleteBlock)complete {
    WEAK_SELF(weakSelf);
    //进度回调
    _mediaTrans.LSMediaTransProgress = ^(float progress) {
        //更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = progress;
        });
    };
    //保存变量
    _transcodingComplete = complete;
    //配置转码参数
    [self configMediaTrans];
    //配置水印位置
    [self configWaterMark];
    if (!self.mediaTrans.inputSecondaryFileName) {
        self.mediaTrans.intensityOfSecondAudioVolume = 0.f;
    }
    dispatch_async(_transcodingQueue, ^{
        [weakSelf.mediaTrans doTranscoding:^(NSError *error, NSString *output) {
            if (error) {
                NSLog(@"转码结束了 - 失败, %@", error);
                if (weakSelf.transcodingComplete)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.progressView.progress = 0.0;
                        weakSelf.transcodingComplete(error, nil);
                    });
                }
            }
            else
            {
                NSLog(@"转码结束了 - 成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.transcodingComplete) {
                        weakSelf.progressView.progress = 1.0;
                        weakSelf.transcodingComplete(nil, output);
                    }
                });
            }
        }];
    });
}

//保存到相册
- (void)doSaveVideoToAlbum:(NSString *)filePath complete:(void(^)(NSError *))complete
{
    self.tipLabel.hidden = NO;

    ALAssetsLibrary *assetLib = [[ALAssetsLibrary alloc] init];
    
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSError *error = [NSError errorWithDomain:@"ntes.demo.record.result"
                                             code:0x1000
                                         userInfo:@{NTES_ERROR_MSG_KEY : @"文件不存在"}];
        if (complete) {
            complete(error);
        }
    }
    else
    {
        [assetLib saveVideo:fileUrl toAlbum:@"短视频" completion:^(NSURL *assetURL, NSError *error) {
            if (complete) {
                NSLog(@"保存相册成功");
                complete(nil);
            }
        } failure:^(NSError *error) {
            if (complete) {
                NSLog(@"保存相册失败");
                complete(error);
            }
        }];
    }
}

- (void)doUpdateVideoName:(NSString *)name relPath:(NSString *)relPath
{
    if (!name || !relPath) {
        NSLog(@"[NTESVideoEditVC] 上传失败，参数错误");
        return;
    }
    NTESVideoEntity *entity = [NTESVideoEntity entityWithFileName:name extension:@"mp4" relPath:relPath];
    NSLog(@"current thread: %@", [NSThread currentThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNtesAddShortVideoEntity object:entity];
    
}

- (void)configMediaTrans {
    self.mediaTrans.videoQuality = LS_TRANSCODING_VideoQuality_HIGH;
    self.mediaTrans.isMixMainFileMusic = YES;
    [NTESRecordDataCenter shareInstance].recordFilePaths = [self.tempVideos mutableCopy];
    self.mediaTrans.inputMainFileNameArray = [NTESRecordDataCenter shareInstance].recordFilePaths;
    self.mediaTrans.outputFileName = self.outputPath;
}

- (void)configWaterMark {
    NSMutableArray *tmp = @[].mutableCopy;
    int total_duration = 0;
    for (NSString *filePath in [NTESRecordDataCenter shareInstance].recordFilePaths) {
        NSURL *videoURL = [NSURL fileURLWithPath:filePath];
        AVAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        total_duration += CMTimeGetSeconds([asset duration]);
    }
    if (self.textureImg) {
        int duration = (int)(self.endTextureTime - self.startTextureTime);
        CGRect waterInfoRect1 = [self rectInVideoWithContainerFrame:self.previewView.frame imageFrame:self.textureImg.frame];
        LSWaMarkRectInfo *waterRectInfo = [LSWaMarkRectInfo new];
        waterRectInfo.location = LS_TRANSCODING_WMARK_Rect;
        waterRectInfo.uiX = waterInfoRect1.origin.x;
        waterRectInfo.uiY = waterInfoRect1.origin.y;
        waterRectInfo.uiWidth = waterInfoRect1.size.width;
        waterRectInfo.uiHeight = waterInfoRect1.size.height;
        waterRectInfo.uiBeginTimeInSec = (int)self.startTextureTime;
        waterRectInfo.uiDurationInSec = duration;
        waterRectInfo.waterMarkImage = self.textureImg.image;
        
        [tmp addObject:waterRectInfo];
    }
    
    if (self.textImgView) {
        CGRect waterInfoRect2 = [self rectInVideoWithContainerFrame:self.previewView.frame imageFrame:self.textImgView.frame];
        LSWaMarkRectInfo *waterRectInfo2 = [LSWaMarkRectInfo new];
        waterRectInfo2.location = LS_TRANSCODING_WMARK_Rect;
        waterRectInfo2.uiX = waterInfoRect2.origin.x;
        waterRectInfo2.uiY = waterInfoRect2.origin.y;
        waterRectInfo2.uiWidth = waterInfoRect2.size.width;
        waterRectInfo2.uiHeight = waterInfoRect2.size.height;
        waterRectInfo2.uiBeginTimeInSec = 0;
        waterRectInfo2.uiDurationInSec = total_duration;
        waterRectInfo2.waterMarkImage = self.textImgView.image;
        
        CGRect waterInfoRect3 = [self rectInVideoWithContainerFrame:self.previewView.frame imageFrame:self.textImgView.frame];
        LSWaMarkRectInfo *waterRectInfo3 = [LSWaMarkRectInfo new];
        waterRectInfo3.location = LS_TRANSCODING_WMARK_Rect;
        waterRectInfo3.uiX = waterInfoRect3.origin.x;
        waterRectInfo3.uiY = waterInfoRect3.origin.y;
        waterRectInfo3.uiWidth = waterInfoRect3.size.width;
        waterRectInfo3.uiHeight = waterInfoRect3.size.height;
        waterRectInfo3.uiBeginTimeInSec = 0;
        waterRectInfo3.uiDurationInSec = total_duration;
        UIImage *textImg = [self.textImgView imageWithText];
        waterRectInfo3.waterMarkImage = textImg;
        
        [tmp addObject:waterRectInfo2];
        [tmp addObject:waterRectInfo3];
    }
    
    self.mediaTrans.waterMarkInfos = tmp.copy;
}

- (void)showSaveFailAlert:(NSString *)reason {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:reason
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles: nil];
    
    WEAK_SELF(weakSelf);
    [alertView showAlertWithCompletionHandler:^(NSInteger index) {
        [weakSelf goUpdateVC];
    }];
}

#pragma mark - gesture handle

- (void)panGestureOnImgDetected:(UIPanGestureRecognizer *)recognizer {
    
    UIGestureRecognizerState state = [recognizer state];
    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateChanged) {
        CGPoint transLation = [recognizer translationInView:self.previewView];
        UIView *dragImg = [self.view viewWithTag:100];
        
        if (dragImg) {
            CGPoint newCenter = CGPointMake(dragImg.center.x + transLation.x, dragImg.center.y + transLation.y);
            //限制不能拖出界面
            //FIX ME：这里默认按照第一个视频的X坐标
            CGFloat halfx = CGRectGetMinX(self.previewView.bounds) + dragImg.width/2;
            newCenter.x = MAX(halfx, newCenter.x);
            newCenter.x = MIN(self.previewView.bounds.size.width - halfx, newCenter.x);
            //FIX ME：同上Y坐标
            CGFloat halfy = CGRectGetMinY(self.previewView.bounds) + dragImg.height/2;
            newCenter.y = MAX(halfy, newCenter.y);
            newCenter.y = MIN(self.previewView.bounds.size.height - halfy, newCenter.y);
            
            [dragImg setCenter:newCenter];
            
            [recognizer setTranslation:CGPointZero inView:self.previewView];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch {
    if (touch.view == self.textureImg || touch.view == self.textImgView) {
        return YES;
    }
    return NO;
}

#pragma mark - Getter
- (UIAlertController *)alertCtl
{
    if (!_alertCtl) {
        _alertCtl = [UIAlertController alertControllerWithTitle:@"视频名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        WEAK_SELF(weakSelf);
        [_alertCtl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = [NSString stringWithFormat:@"新视频%@", [[NSDate date] stringWithFormat:@"MMddHHmmss"]];
            textField.delegate = weakSelf;
            [textField addTarget:weakSelf action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
            weakSelf.videoNameTextField = textField;
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            weakSelf.videoNameTextField.text = nil;
        }];
        [_alertCtl addAction:cancelAction];
        
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.videoNameTextField resignFirstResponder];
            
            if (weakSelf.videoNameTextField.text.length == 0)
            {
                [NTESRecordDataCenter shareInstance].outputVideoName = weakSelf.videoNameTextField.placeholder;
            }
            else
            {
                [NTESRecordDataCenter shareInstance].outputVideoName = weakSelf.videoNameTextField.text;
            }
            
            [self releaseAudioPlayer];
            [self.mediaTrans stopVideoPreview];
            //去掉子视图
            [self.editView removeFromSuperview];
            [self.previewView removeFromSuperview];
            [self.view addSubview:self.progressView];
            //命名完成，进行截图、融合
            self.navigationController.navigationBar.userInteractionEnabled = NO;
            [weakSelf doSnapImage];
            [weakSelf doMerge];
            
        }];
        [_alertCtl addAction:sureAction];
    }
    return _alertCtl;
}

- (NSString *)outputPath
{
    if (!_outputPath)
    {
        NSString *name = [NTESRecordDataCenter shareInstance].outputVideoName;
        NSString *tmp_name = [NSString stringWithFormat:@"%@.mp4", name];
        NSString *outPath = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:tmp_name];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:outPath])
        {
            tmp_name = [NSString stringWithFormat:@"%@_%@.mp4", name, [[NSDate date] stringWithFormat:@"yyyyMMddHHmmss"]];
            outPath = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:tmp_name];
        }
        
        _outputPath = outPath;
    }
    return _outputPath;
}

- (NSString *)outputName
{
    return [NTESRecordDataCenter shareInstance].outputVideoName;
}

- (NTESCircleView *)progressView
{
    if (!_progressView) {
        _progressView = [[NTESCircleView alloc] init];
    }
    return _progressView;
}

#pragma mark - 视频名称输入 - <UITextFieldDelegate>
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self isInputRuleNotBlank:string] || [string isEqualToString:@""]) {//当输入符合规则和退格键时允许改变输入框
        return YES;
    } else {
        NSString *msg = @"名称只可输入字母、汉字、数字和下划线";
        [self.view makeToast:msg duration:2 position:CSToastPositionCenter];
        return NO;
    }
}

- (void)textFieldChanged:(UITextField *)textField {
    NSString *toBeString = textField.text;
    if (![self isInputRuleAndBlank:toBeString]) {
        textField.text = [self disable_emoji:toBeString];
        return;
    }
    
    NSString *lang = [[textField textInputMode] primaryLanguage]; // 获取当前键盘输入模式
    //简体中文输入,第三方输入法所有模式下都会显示“zh-Hans”
    if([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if(!position) {
            NSString *getStr = [self getSubString:toBeString];
            if(getStr && getStr.length > 0) {
                textField.text = getStr;
            }
        }
    } else{
        NSString *getStr = [self getSubString:toBeString];
        if(getStr && getStr.length > 0) {
            textField.text= getStr;
        }
    }
}

-(NSString *)getSubString:(NSString*)string
{
    if (string.length > 20) {
        NSString *msg = @"名称只可输入20个以内的字符";
        [self.view makeToast:msg duration:2 position:CSToastPositionCenter];
        return [string substringToIndex:20];
    }
    return nil;
}

/**
 * 字母、数字、中文正则判断（不包括空格）
 */
- (BOOL)isInputRuleNotBlank:(NSString *)str {
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    
    if (!isMatch) {
        NSString *other = @"➋➌➍➎➏➐➑➒";
        unsigned long len=str.length;
        for(int i=0;i<len;i++)
        {
            unichar a=[str characterAtIndex:i];
            if(!((isalpha(a))
                 ||(isalnum(a))
                 ||((a >= 0x4e00 && a <= 0x9fa6))
                 ||((a=='_'))
                 ||([other rangeOfString:str].location != NSNotFound)
                 ))
                return NO;
        }
        return YES;
        
    }
    return isMatch;
}

- (BOOL)isInputRuleAndBlank:(NSString *)str {
    
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d\\s_]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}

- (NSString *)disable_emoji:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

#pragma mark - 视频坐标转换
- (CGRect)rectInVideoWithContainerFrame:(CGRect)constainerFrame imageFrame:(CGRect)imageFrame
{
    CGRect imageInVideoRect = CGRectZero; //图片在视频中的位置
    CGRect validRect = CGRectZero; //有效范围
    unsigned int videoWidth = _mediaTrans.videoEncodedWidth;
    unsigned int videoHeight = _mediaTrans.videoEncodedHeight;
    
    //Step1: 计算有效水印叠加的有效范围。
    if (videoWidth < videoHeight) //竖的视频
    {
        validRect.size.height = constainerFrame.size.height;
        validRect.size.width = validRect.size.height * videoWidth / videoHeight;
        validRect.origin.x = (constainerFrame.size.width - validRect.size.width)/2;
        validRect.origin.y = 0;
    }
    else //横的视频
    {
        validRect.size.width = constainerFrame.size.width;
        validRect.size.height = validRect.size.width * videoHeight / videoWidth;
        validRect.origin.x = 0;
        validRect.origin.y = (constainerFrame.size.height - validRect.size.height)/2;
    }
    
    //Step2: 将有效范围(validRect)中的水印位置映射到视频坐标系中(0,0,videoWidth,videoHeight);
    imageInVideoRect.origin.x = (imageFrame.origin.x - validRect.origin.x) * videoWidth / validRect.size.width;
    imageInVideoRect.origin.y = (imageFrame.origin.y - validRect.origin.y) * videoHeight / validRect.size.height;
    imageInVideoRect.size.width = imageFrame.size.width * videoWidth / validRect.size.width;
    imageInVideoRect.size.height = imageFrame.size.height * videoHeight / validRect.size.height;
    
    return imageInVideoRect;
}

- (CGFloat)getEditViewHeight {
    if (UIScreenHeight == 568) {
        return 290;
    } else if (UIScreenHeight == 667) {
        return 300;
    } else {
        return 310;
    }
}

- (CGRect)videoRectWithScreenScale: (NTESRecordScreenScale)scale
{
    CGRect fullScale = [UIScreen mainScreen].bounds;
    CGFloat preview_width = fullScale.size.width;
    CGFloat preview_height = fullScale.size.height - [self getEditViewHeight] - 64;
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

@end
