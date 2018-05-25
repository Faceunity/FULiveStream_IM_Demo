//
//  NTESRecordControlBar.m
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/3/30.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESRecordControlBar.h"
#import "NTESRecordTopBar.h"
#import "NTESConfigTipBtn.h"
#import "NTESSegmentView.h"
#import "NTESProcessBtn.h"

#import "NTESBeautyConfigView.h"
#import "NTESFilterConfigView.h"
#import "NTESSettingView.h"
#import "NTESVideoMaskBar.h"
#import "NTESRecordDataCenter.h"

static NSInteger gTopBarHeight = 44.0;
static NSInteger gBottomBarHeihgt = 120.0;

@interface NTESRecordControlBar ()<NTESRecordTopBarProtocol, NTESProcessBtnProtocol, NTESSettingViewProtocol, UIGestureRecognizerDelegate, NTESVideoMaskBarDelegate>

@property (nonatomic, assign) BOOL isCancelRecord; //取消录制动画

@property (nonatomic, strong) UIView *maskView; //浮层遮罩

@property (nonatomic, strong) NTESRecordTopBar *topBar;     //顶部工具栏
@property (nonatomic, strong) NTESVideoMaskBar *videoMaskBar; //视频浮层控制栏

@property (nonatomic, strong) NTESProcessBtn *recordBtn;    //开始录像按钮
@property (nonatomic, strong) NTESSegmentView *segmentLine; //分段数分割线（虚线）
@property (nonatomic, strong) NTESConfigTipBtn *configTipBtn;  //配置信息按钮

@property (nonatomic, strong) NTESBeautyConfigView *beautyConfig; //美颜配置信息
@property (nonatomic, strong) NTESFilterConfigView *filterConfig; //滤镜配置信息
@property(nonatomic, strong) NTESFilterConfigView *faceUConfig;  //faceUnity配置信息

@property (nonatomic, strong) NTESSettingView *settingView; //录制配置信息

@property (nonatomic, strong) UIButton *cancelRecordBtn;   //取消录制
@property (nonatomic, strong) UIButton *deleteRecordBtn; //删除录制
@property (nonatomic, strong) UIButton *completeRecordBtn; //完成录制

@property(nonatomic, strong) UIButton *addVideoBtn;//添加相册视频按钮

@end

@implementation NTESRecordControlBar

- (void)doInit
{
    [self addSubview:self.topBar];
    [self addSubview:self.videoMaskBar];
    [self addSubview:self.configTipBtn];
    [self addSubview:self.segmentLine];
    [self addSubview:self.recordBtn];
    [self addSubview:self.cancelRecordBtn];
    [self addSubview:self.deleteRecordBtn];
    [self addSubview:self.completeRecordBtn];
    [self addSubview:self.addVideoBtn];
    
    self.completeRecordSections = 0;
    [self switchToNormalUI];
    [self setupConfig];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _maskView.frame = self.bounds;
    
    //顶部工具栏
    _topBar.frame = CGRectMake(0, 0, self.width, gTopBarHeight);
    
    //控制条
    _videoMaskBar.centerX = self.width/2;
    
    //美颜选项
    self.beautyConfig.frame = CGRectMake(0,
                                         _topBar.bottom,
                                         self.width,
                                         66);
    
    //滤镜选项
    self.filterConfig.frame = self.beautyConfig.frame;
    
    self.faceUConfig.frame = self.beautyConfig.frame;
    
    //分隔线
    _segmentLine.frame = CGRectMake(0,
                                    self.bottom - gBottomBarHeihgt,
                                    self.width,
                                    10.0);
    //选择按钮
    _configTipBtn.origin = CGPointMake(self.width - _configTipBtn.width - 12.0,
                                       _segmentLine.top - 15 - _configTipBtn.height);
    
    //配置选项
    self.settingView.frame = CGRectMake(0,
                                        _configTipBtn.top - 13.0 - [_settingView settingHeight],
                                        self.width,
                                        [_settingView settingHeight]);
    
    //开始录制按钮
    _recordBtn.center = CGPointMake(self.width/2, (self.height - _segmentLine.bottom)/2 + _segmentLine.bottom);
    _recordBtn.layer.cornerRadius = _recordBtn.width/2;
    
    //取消录制按钮
    _cancelRecordBtn.center = CGPointMake(_recordBtn.left/2 - 10, _recordBtn.centerY);
    
    //删除录制按钮
    _deleteRecordBtn.frame = _cancelRecordBtn.frame;
    
    //完成录制按钮
    _completeRecordBtn.center = CGPointMake((self.width - _recordBtn.right)/2 + _recordBtn.right, _recordBtn.centerY);
    
    //添加视频按钮
    
    if (_deleteRecordBtn.hidden) {
        _addVideoBtn.center = CGPointMake(_recordBtn.left/2 - 10, _recordBtn.centerY);
    }
}

#pragma mark - Public
- (void)startRecordAnimation
{
    _isCancelRecord = NO;
    
    [self.recordBtn startProgressAnimation];
}

- (void)stopRecordAnimation
{
    _isCancelRecord = YES;
    
    [self.recordBtn stopProgressAnimation];
}

- (void)sendCancelRecordAction
{
    [self.cancelRecordBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)sendDeleteRecordAction
{
    [self.deleteRecordBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (CGRect)videoMaskRectWithScreenScale:(NTESRecordScreenScale)scale
{
    CGRect fullScale = [UIScreen mainScreen].bounds;
    CGFloat width = MIN(fullScale.size.width, fullScale.size.height);
    CGFloat height = MAX(fullScale.size.width, fullScale.size.height);
    CGRect videoRect = [self videoRectWithScreenScale:scale];
    CGRect maxRect = CGRectMake(0, gTopBarHeight, width, height - gTopBarHeight - gBottomBarHeihgt);
    if (videoRect.origin.y < maxRect.origin.y) {
        videoRect.origin.y = maxRect.origin.y;
    }
    
    if (videoRect.size.height > maxRect.size.height) {
        videoRect.size.height = maxRect.size.height;
    }

    return videoRect;
}

- (CGRect)videoRectWithScreenScale: (NTESRecordScreenScale)scale
{
    CGRect fullScale = [UIScreen mainScreen].bounds;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = MIN(fullScale.size.width, fullScale.size.height);
    CGFloat height = MAX(fullScale.size.width, fullScale.size.height);
    
    switch (scale) {
        case NTESRecordScreenScale16x9:
        {
            CGFloat dstHeight = width * 16 / 9;
            if (dstHeight > height) //底边超了, 以高为主
            {
                width = height * 9/16;
            }
            else
            {
                height = dstHeight;
            }
            break;
        }
        case NTESRecordScreenScale4x3:
        {
            CGFloat dstHeight = width * 4/3;
            if (dstHeight > height)
            {
                width = height * 3/4;
                y = gTopBarHeight;
            }
            else if (dstHeight == height)
            {
                height = dstHeight;
            }
            else
            {
                y = gTopBarHeight;
                height = dstHeight;
            }
            break;
        }
        case NTESRecordScreenScale1x1:
        {
            CGFloat maxHeight = height - gBottomBarHeihgt - gTopBarHeight;
            y = (maxHeight - width)/2 + gTopBarHeight;
            height = width;
            break;
        }
        default:
            break;
    }

    return CGRectMake(x, y, width, height);
}

#pragma mark - UI Switch
//录制的UI
- (void)switchToRecordUI
{
    /*----- 只显示录制进度和取消 -----*/
    _recordBtn.hidden = NO;
    [_recordBtn showBtn:NO];
    _cancelRecordBtn.hidden = NO;
    
    _topBar.hidden = YES;
    _videoMaskBar.hidden = YES;
    _configTipBtn.hidden = YES;
    _segmentLine.hidden = YES;
    _deleteRecordBtn.hidden = YES;
    _completeRecordBtn.hidden = YES;
    _addVideoBtn.hidden = YES;
}

//正常的UI
- (void)switchToNormalUI
{
    /*----- 不显示取消 -----*/
    _cancelRecordBtn.hidden = YES;
    
    _addVideoBtn.hidden = NO;
    _recordBtn.hidden = NO;
    [_recordBtn showBtn:YES];
    _topBar.hidden = NO;
    _videoMaskBar.hidden = NO;
    _configTipBtn.hidden = NO;
    _segmentLine.hidden = NO;
    _deleteRecordBtn.hidden = (_completeRecordSections == 0);
    _completeRecordBtn.hidden = (_completeRecordSections == 0);
}

#pragma mark - Action
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    WEAK_SELF(weakSelf);
    UIView *showView = [_maskView.subviews lastObject];
    
    if (showView == _beautyConfig) {
        [_beautyConfig dismissComplete:^{
            [weakSelf.maskView removeFromSuperview];
        }];
    }
    else if (showView == _filterConfig) {
        [_filterConfig dismissComplete:^{
            [weakSelf.maskView removeFromSuperview];
        }];
    }
    else if (showView == _settingView) {
        [_settingView dismissComplete:^{
            [weakSelf.maskView removeFromSuperview];
        }];
    }
    else if (showView == _faceUConfig) {
        [_faceUConfig dismissComplete:^{
            [weakSelf.maskView removeFromSuperview];
        }];
    }
}

- (void)addVideoBtnTap {
    if (_delegate && [_delegate respondsToSelector:@selector(ContorlBarAddVideo:withDuration:)]) {
        [_delegate ContorlBarAddVideo:self withDuration:_recordBtn.duration];
    }
}

- (void)btnAction:(UIButton *)btn
{
    if (btn.tag == 10) //点击取消录制
    {
        [self performSelector:@selector(tapCancelAction:) withObject:nil afterDelay:0.3]; 
    }
    else if (btn.tag == 11) //点击删除录制
    {
        if (_delegate && [_delegate respondsToSelector:@selector(ControlBarRecordDidDeleted:)]) {
            [_delegate ControlBarRecordDidDeleted:self];
        }
    }
    else if (btn.tag == 12) //点击完成录制
    {
        [self performSelector:@selector(tapCompleteBtnAction:) withObject:nil afterDelay:0.f];
    }
    else if (btn.tag == 13) //点击配置信息
    {
        [self addSubview:self.maskView];
        [self.settingView showInView:self.maskView complete:nil];
    }
}

- (void)tapCancelAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(ControlBarRecordDidCancelled:)]) {
        [_delegate ControlBarRecordDidCancelled:self];
    }
}

- (void)tapCompleteBtnAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(ControlBarRecordDidCompleted:isSkip:)]) {
        
        BOOL isSkip = (_completeRecordSections != [NTESRecordDataCenter shareInstance].config.section);
        [_delegate ControlBarRecordDidCompleted:self isSkip:isSkip];
    }
}

- (void)sliderAction:(UISlider *)slider
{
    if (_delegate && [_delegate respondsToSelector:@selector(ControlBar:exposure:)]) {
        [_delegate ControlBar:self exposure:slider.value];
    }
}

#pragma mark - 顶部工具栏 - <NTESRecordTopBarProtocol>
- (void)TopBarQuitAction:(NTESRecordTopBar *)bar
{
    if (_delegate && [_delegate respondsToSelector:@selector(ControlBarQuit:)]) {
        [_delegate ControlBarQuit:self];
    }
}

- (void)TopBarFaceUSdkAction:(NTESRecordTopBar *)bar {
    [self addSubview:self.maskView];
    [self.faceUConfig showInView:self.maskView complete:nil];
}

- (void)TopBarBeautyAction:(NTESRecordTopBar *)bar {
    [self addSubview:self.maskView];
    [self.beautyConfig showInView:self.maskView complete:nil];
}

- (void)TopBarFilterAction:(NTESRecordTopBar *)bar {
    [self addSubview:self.maskView];
    [self.filterConfig showInView:self.maskView complete:nil];
}

- (void)TopBarCameraAction:(NTESRecordTopBar *)bar {
    if (_delegate && [_delegate respondsToSelector:@selector(ControlBarCameraSwitch:)]) {
        [_delegate ControlBarCameraSwitch:self];
    }
}

#pragma mark - 视频浮层工具栏 - <NTESVideoMaskBarDelegate>
- (void)MaskBar:(NTESVideoMaskBar *)slider exposureValueChanged:(CGFloat)exposure
{
    if (_delegate && [_delegate respondsToSelector:@selector(ControlBar:exposure:)]) {
        [_delegate ControlBar:self exposure:exposure];
    }
}

- (void)MaskBar:(NTESVideoMaskBar *)slider focusInPoint:(CGPoint)point
{
    CGPoint dstPoint = [slider convertPoint:point toView:self];
    
    if (_delegate && [_delegate respondsToSelector:@selector(ControlBar:focusPoint:)]) {
        [_delegate ControlBar:self focusPoint:dstPoint];
    }
}

- (void)MaskBar:(NTESVideoMaskBar *)slider zoomChanged:(CGFloat)zoom
{
    if (_delegate && [_delegate respondsToSelector:@selector(ContorlBar:zoom:)]) {
        [_delegate ContorlBar:self zoom:zoom];
    }
}

#pragma mark - 视频设置页面 - <NTESSettingViewProtocol>
- (void)NTESSettingView:(NTESSettingView *)view selectSection:(NSInteger)section
{
    [NTESRecordDataCenter shareInstance].config.section = section;
    _segmentLine.numbers = section;
    _configTipBtn.section = section;
    _recordBtn.duration = (CGFloat)[NTESRecordDataCenter shareInstance].config.duration/section;
}

- (void)NTESSettingView:(NTESSettingView *)view selectDuration:(NSInteger)duration
{
    [NTESRecordDataCenter shareInstance].config.duration = duration;
    _configTipBtn.duration = duration;
    _recordBtn.duration = (CGFloat)duration/[NTESRecordDataCenter shareInstance].config.section;
}

- (void)NTESSettingView:(NTESSettingView *)view selectResolution:(NTESRecordResolution)resolution
{
    [NTESRecordDataCenter shareInstance].config.resolution = resolution;
    _configTipBtn.resolution = resolution;
    
    if (_delegate && [_delegate respondsToSelector:@selector(ControlBar:resolution:)]) {
        [_delegate ControlBar:self resolution:resolution];
    }
}

- (void)NTESSettingView:(NTESSettingView *)view selectScreen:(NTESRecordScreenScale)screen
{
    [NTESRecordDataCenter shareInstance].config.screenScale = screen;
    _configTipBtn.screenScale = screen;
    
    self.videoMaskBar.frame = [self videoMaskRectWithScreenScale:screen];
    self.videoMaskBar.centerX = self.width/2;
    CGRect videoRect = [self videoRectWithScreenScale:screen];
    
    if (_delegate && [_delegate respondsToSelector:@selector(ControlBar:frame:scale:)]) {
        [_delegate ControlBar:self frame:videoRect scale:screen];
    }
}

#pragma mark - 录制按钮 - <NTESProcessBtnProtocol>
//录制动画已经开始了
- (void)NTESProcessBtnDidStart:(NTESProcessBtn *)processBtn
{
    [self switchToRecordUI];
    
    if (_delegate && [_delegate respondsToSelector:@selector(ControlBarRecordDidStart:)]) {
        [_delegate ControlBarRecordDidStart:self];
    }
}

//录制动画已经结束了
- (void)NTESProcessBtnDidStop:(NTESProcessBtn *)processBtn
{
    if (_delegate && [_delegate respondsToSelector:@selector(ControlBarRecordAnimationDidStop:isCancel:)]) {
        [_delegate ControlBarRecordAnimationDidStop:self isCancel:_isCancelRecord];
    }
    
    [self switchToNormalUI];
}

#pragma mark - 手势 - <UIGestureRecognizerDelegate>
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return (touch.view == self.maskView);
}

#pragma mark - Setter
- (void)setupConfig
{
    self.videoMaskBar.exposureValue = [NTESRecordDataCenter shareInstance].config.exposureValue;
    //美颜
    self.beautyConfig.curValue = [NTESRecordDataCenter shareInstance].config.beautyValue;
    //滤镜
    self.filterConfig.datas = [NTESRecordDataCenter shareInstance].config.filterDatas;
    self.filterConfig.selectIndex = [NTESRecordDataCenter shareInstance].config.filterIndex;
    //faceUnity
    self.faceUConfig.datas = [NTESRecordDataCenter shareInstance].config.faceUTitleDatas;
    self.faceUConfig.selectIndex = [NTESRecordDataCenter shareInstance].config.faceIndex;
    
    self.recordBtn.duration = (CGFloat)[NTESRecordDataCenter shareInstance].config.duration / [NTESRecordDataCenter shareInstance].config.section;
    self.segmentLine.numbers = [NTESRecordDataCenter shareInstance].config.section;
    
    self.configTipBtn.section = [NTESRecordDataCenter shareInstance].config.section;
    self.configTipBtn.duration = [NTESRecordDataCenter shareInstance].config.duration;
    self.configTipBtn.screenScale = [NTESRecordDataCenter shareInstance].config.screenScale;
    self.configTipBtn.resolution = [NTESRecordDataCenter shareInstance].config.resolution;
    
    CGRect frame = [self videoMaskRectWithScreenScale:[NTESRecordDataCenter shareInstance].config.screenScale];
    self.videoMaskBar.frame = frame;
    
    [self.settingView configWithEntity:[NTESRecordDataCenter shareInstance].config];
}

- (void)setCompleteRecordSections:(NSInteger)completeRecordSections
{
    if (completeRecordSections < 0)
    {
        completeRecordSections = 0;
    }
    else if (completeRecordSections > [NTESRecordDataCenter shareInstance].config.section)
    {
        completeRecordSections = [NTESRecordDataCenter shareInstance].config.section;
    }
    
    _completeRecordSections = completeRecordSections;
    
    self.segmentLine.selectCount = completeRecordSections;
    
    if (completeRecordSections == 0)
    {
        self.completeRecordBtn.hidden = YES;
        self.deleteRecordBtn.hidden = YES;
        self.recordBtn.titleStr = @"开始\n录制";
        self.recordBtn.userInteractionEnabled = YES;
        self.configTipBtn.hidden = NO;
        
       [UIView animateWithDuration:0.2f animations:^{
           _addVideoBtn.center = CGPointMake(_recordBtn.left/2 - 10, _recordBtn.centerY);
       }];
    }
    else if (completeRecordSections == [NTESRecordDataCenter shareInstance].config.section)
    {
        self.completeRecordBtn.hidden = NO;
        self.deleteRecordBtn.hidden = NO;
        self.recordBtn.titleStr = @"完成\n录制";
        self.recordBtn.userInteractionEnabled = NO;
        self.configTipBtn.hidden = YES;
        
        //完成
        [_completeRecordBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        self.completeRecordBtn.hidden = NO;
        self.deleteRecordBtn.hidden = NO;
        self.recordBtn.titleStr = @"继续\n录制";
        self.recordBtn.userInteractionEnabled = YES;
        self.configTipBtn.hidden = YES;
    }
    if (!_deleteRecordBtn.hidden) {
        
        [UIView animateWithDuration:0.2f animations:^{
            _addVideoBtn.center = CGPointMake(_recordBtn.centerX - 67 * UISreenWidthScale, _recordBtn.centerY);
        }];
    }

}

#pragma mark - Getter
- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.0];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        tap.delegate = self;
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (NTESRecordTopBar *)topBar
{
    if (!_topBar) {
        _topBar = [[NTESRecordTopBar alloc] init];
        _topBar.delegate = self;
        _topBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    }
    return _topBar;
}

- (NTESVideoMaskBar *)videoMaskBar
{
    if (!_videoMaskBar) {
        _videoMaskBar  = [[NTESVideoMaskBar alloc] init];
        _videoMaskBar.delegate = self;
    }
    return _videoMaskBar;
}

- (NTESProcessBtn *)recordBtn
{
    if (!_recordBtn) {
        _recordBtn = [[NTESProcessBtn alloc] init];
        _recordBtn.size = CGSizeMake(70, 70);
        _recordBtn.delegate = self;
    }
    return _recordBtn;
}

- (UIButton *)addVideoBtn {
    if (!_addVideoBtn) {
        _addVideoBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.size = CGSizeMake(30, 30);
            [btn setBackgroundImage:[UIImage imageNamed:@"添加"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(addVideoBtnTap) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
    }
    return _addVideoBtn;
}

- (UIButton *)cancelRecordBtn
{
    if (!_cancelRecordBtn) {
        _cancelRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelRecordBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelRecordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelRecordBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_cancelRecordBtn setBackgroundImage:[UIImage imageNamed:@"white_btn"] forState:UIControlStateNormal];
        [_cancelRecordBtn setBackgroundImage:[UIImage imageNamed:@"white_btn_high"] forState:UIControlStateHighlighted];
        _cancelRecordBtn.tag = 10;
        [_cancelRecordBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        _cancelRecordBtn.size = CGSizeMake(62.0, 30.0);
    }
    return _cancelRecordBtn;
}

- (UIButton *)deleteRecordBtn
{
    if (!_deleteRecordBtn) {
        _deleteRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteRecordBtn.layer.cornerRadius = 15;
        _deleteRecordBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _deleteRecordBtn.layer.borderWidth = 1;
        [_deleteRecordBtn setTitle:@"上一步" forState:UIControlStateNormal];
        [_deleteRecordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _deleteRecordBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_deleteRecordBtn setBackgroundImage:[UIImage imageNamed:@"white_btn"] forState:UIControlStateNormal];
        [_deleteRecordBtn setBackgroundImage:[UIImage imageNamed:@"white_btn_high"] forState:UIControlStateHighlighted];
        _deleteRecordBtn.tag = 11;
        [_deleteRecordBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        _deleteRecordBtn.size = CGSizeMake(62.0, 30.0);
    }
    return _deleteRecordBtn;
}

- (UIButton *)completeRecordBtn
{
    if (!_completeRecordBtn) {
        _completeRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _completeRecordBtn.layer.cornerRadius = 15;
        _completeRecordBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _completeRecordBtn.layer.borderWidth = 1;
        [_completeRecordBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_completeRecordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _completeRecordBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _completeRecordBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_completeRecordBtn setBackgroundImage:[UIImage imageNamed:@"white_btn"] forState:UIControlStateNormal];
        [_completeRecordBtn setBackgroundImage:[UIImage imageNamed:@"white_btn_high"] forState:UIControlStateHighlighted];
        _completeRecordBtn.tag = 12;
        [_completeRecordBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        _completeRecordBtn.size = CGSizeMake(62.0, 30.0);
    }
    return _completeRecordBtn;
}

- (NTESSegmentView *)segmentLine
{
    if (!_segmentLine) {
        _segmentLine = [NTESSegmentView new];
        _segmentLine.backgroundColor = [UIColor clearColor];
    }
    
    return _segmentLine;
}

- (NTESConfigTipBtn *)configTipBtn
{
    if (!_configTipBtn) {
        _configTipBtn = [[NTESConfigTipBtn alloc] init];
        _configTipBtn.size = [_configTipBtn tipRect];
        _configTipBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _configTipBtn.layer.borderColor = UIColorFromRGB(0x5F5F5F).CGColor;
        _configTipBtn.layer.borderWidth = 0.5;
        _configTipBtn.tag = 13;
        _configTipBtn.resolution = [NTESRecordDataCenter shareInstance].config.resolution;
        _configTipBtn.section = [NTESRecordDataCenter shareInstance].config.section;
        _configTipBtn.duration = [NTESRecordDataCenter shareInstance].config.duration;
        _configTipBtn.screenScale = [NTESRecordDataCenter shareInstance].config.screenScale;

        [_configTipBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _configTipBtn;
}

- (NTESBeautyConfigView *)beautyConfig
{
    if (!_beautyConfig) {
        _beautyConfig = [[NTESBeautyConfigView alloc] init];
        _beautyConfig.maxValue = 40;
        _beautyConfig.minValue = 0;
        _beautyConfig.defalutValue = 0;
        _beautyConfig.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        WEAK_SELF(weakSelf);
        _beautyConfig.valueChangedBlock = ^(CGFloat value) {
            STRONG_SELF(strongSelf);
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(ControlBar:smooth:)]) {
                [strongSelf.delegate ControlBar:strongSelf smooth:value];
            }
        };
    }
    return _beautyConfig;
}

- (NTESFilterConfigView *)filterConfig
{
    if (!_filterConfig) {
        _filterConfig = [[NTESFilterConfigView alloc] init];
        _filterConfig.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        
        __weak typeof(self) weakSelf = self;
        _filterConfig.selectBlock = ^(NSInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(ControlBar:filter:)]) {
                [strongSelf.delegate ControlBar:strongSelf filter:index];
            }
        };
    }
    return _filterConfig;
}
//faceUnity
- (NTESFilterConfigView *)faceUConfig {
    if (!_faceUConfig) {
        _faceUConfig = [NTESFilterConfigView new];
        _faceUConfig.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        WEAK_SELF(weakSelf);
        _faceUConfig.selectBlock = ^(NSInteger index) {
            STRONG_SELF(strongSelf);
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(ControlBar:face:)]) {
                [strongSelf.delegate ControlBar:strongSelf face:index];
            }
        };
    }
    return _faceUConfig;
}

- (NTESSettingView *)settingView
{
    if (!_settingView) {
        _settingView = [[NTESSettingView alloc] init];
        _settingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        _settingView.delegate = self;
    }
    return _settingView;
}

@end
