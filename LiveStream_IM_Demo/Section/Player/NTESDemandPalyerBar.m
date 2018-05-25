//
//  NTESDemandPalyerBar.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDemandPalyerBar.h"
#import "NTESSlider.h"

@interface NTESDemandPalyerBar ()

//顶部工具栏系列
@property (nonatomic, strong) UIView *topBackground;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UILabel *titleLab;

//底部工具栏系列
@property (nonatomic, strong) UIView *bottomBackground;
@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UILabel *playTimeLab;
@property (nonatomic, strong) UILabel *durationLab;
@property (nonatomic, strong) NTESSlider *processSlider;
@property (nonatomic, strong) UIButton *audioBtn;
@property (nonatomic, strong) UIButton *snapBtn;
@property (nonatomic, strong) UIButton *fullScreenBtn;

@end

@implementation NTESDemandPalyerBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    self.alpha = 0.0;
    
    [self addSubview:self.topBackground];
    [_topBackground addSubview:self.backBtn];
    [_topBackground addSubview:self.titleLab];
    
    [self addSubview:self.bottomBackground];
    [_bottomBackground addSubview:self.startBtn];
    [_bottomBackground addSubview:self.playTimeLab];
    [_bottomBackground addSubview:self.processSlider];
    [_bottomBackground addSubview:self.durationLab];
    [_bottomBackground addSubview:self.audioBtn];
    [_bottomBackground addSubview:self.snapBtn];
    [_bottomBackground addSubview:self.fullScreenBtn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
    self.isStart = NO;
    self.isMuted = NO;
    self.isFull = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_topBackground.width != self.width)
    {
        _topBackground.frame = CGRectMake(0, 0, self.width, 50.0);
        _backBtn.frame = CGRectMake(0, 0, _topBackground.height, _topBackground.height);
        _titleLab.size = CGSizeMake(self.width - _backBtn.width*2, _topBackground.height);
        _titleLab.center = CGPointMake(_topBackground.width/2, _topBackground.height/2);
    }
    
    if (_bottomBackground.width != self.width)
    {
        _bottomBackground.frame = CGRectMake(0, self.height - 50.0, self.width, 50.0);
        
        [self layoutSubviewsWithDirection];
    }
}

- (void)layoutSubviewsWithDirection
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        [self layoutHorizontaDirection];
    }
    else
    {
        [self layoutVerticalDirection];
    }
}

- (void)layoutHorizontaDirection
{
    _playTimeLab.hidden = NO;
    _durationLab.hidden = NO;
    
    _startBtn.frame = CGRectMake(8,
                                 4.0,
                                 _bottomBackground.height - 8.0,
                                 _bottomBackground.height - 8.0);
    
    _playTimeLab.frame = CGRectMake(_startBtn.right,
                                    0,
                                    _playTimeLab.width + 8,
                                    _playTimeLab.height);
    _playTimeLab.centerY = _bottomBackground.height/2;
    
    
    _fullScreenBtn.frame = CGRectMake(_bottomBackground.width - _startBtn.width - 8.0,
                                      _startBtn.top,
                                      _startBtn.width,
                                      _startBtn.height);
    _snapBtn.frame = CGRectMake(_fullScreenBtn.left - _fullScreenBtn.width,
                                _fullScreenBtn.top,
                                _fullScreenBtn.width,
                                _fullScreenBtn.height);
    _audioBtn.frame = CGRectMake(_snapBtn.left - _snapBtn.width,
                                 _snapBtn.top,
                                 _snapBtn.width,
                                 _snapBtn.height);
    
    [_durationLab sizeToFit];
    _durationLab.frame = CGRectMake(_audioBtn.left - _durationLab.width - 8.0,
                                    _playTimeLab.top,
                                    _durationLab.width,
                                    _durationLab.height);
    _processSlider.frame = CGRectMake(_playTimeLab.right + 8.0,
                                      0,
                                      _durationLab.left - 8.0 - _playTimeLab.right - 8.0,
                                      _bottomBackground.height);
}

- (void)layoutVerticalDirection
{
    _playTimeLab.hidden = YES;
    _durationLab.hidden = YES;
    
    _startBtn.frame = CGRectMake(8,
                                 0,
                                 _bottomBackground.height,
                                 _bottomBackground.height);
    _fullScreenBtn.frame = CGRectMake(_bottomBackground.width - _bottomBackground.height - 4.0 - 8.0,
                                      4.0,
                                      _bottomBackground.height - 8.0,
                                      _bottomBackground.height - 8.0);
    
    _snapBtn.frame = CGRectMake(_fullScreenBtn.left - _fullScreenBtn.width,
                                _fullScreenBtn.top,
                                _fullScreenBtn.width,
                                _fullScreenBtn.height);
    _audioBtn.frame = CGRectMake(_snapBtn.left - _snapBtn.width,
                                 _snapBtn.top,
                                 _snapBtn.width,
                                 _snapBtn.height);
    _processSlider.frame = CGRectMake(_startBtn.right + 8.0,
                                      0,
                                      _audioBtn.left - 8.0 - _startBtn.right - 8.0,
                                      _bottomBackground.height);
}

- (void)showBar
{
    if (self.alpha != 1) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
            [self performSelector:@selector(dismissBar) withObject:nil afterDelay:3];
        }];
    }
}

- (void)dismissBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (self.alpha != 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        }];
    }
}

#pragma mark - Action
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    [self dismissBar];
}

- (void)backAction:(UIButton *)btn
{
    if (_delegate && [_delegate respondsToSelector:@selector(PlayerBarBackAction:)]) {
        [_delegate PlayerBarBackAction:self];
    }
}

- (void)btnAction:(UIButton *)btn
{
    switch (btn.tag) {
        case 10: //播放
        {
            if (_delegate && [_delegate respondsToSelector:@selector(PlayerBarStartAction:)]) {
                [_delegate PlayerBarStartAction:self];
            }
            break;
        }
        case 11: //静音
        {
            if (_delegate && [_delegate respondsToSelector:@selector(PlayerBarMuteAction:)]) {
                [_delegate PlayerBarMuteAction:self];
            }
            break;
        }
        case 12: //截屏
        {
            if (_delegate && [_delegate respondsToSelector:@selector(PlayerBarSnapAction:)]) {
                [_delegate PlayerBarSnapAction:self];
            }
            break;
        }
        case 13: //全屏
        {
            if (_delegate && [_delegate respondsToSelector:@selector(PlayerBarFullAction:)]) {
                [_delegate PlayerBarFullAction:self];
            }
            break;
        }
        default:
            break;
    }
}

- (void)sliderAction:(UISlider *)slider
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (_delegate && [_delegate respondsToSelector:@selector(PlayerBar:processChanged:)]) {
        [_delegate PlayerBar:self processChanged:slider.value];
    }
}

- (void)sliderEndAction:(UISlider *)slider
{
    [self performSelector:@selector(dismissBar) withObject:nil afterDelay:3];
}

#pragma mark - Setter
- (void)setTitleStr:(NSString *)titleStr
{
    _titleStr = titleStr ?: @"";
    _titleLab.text = _titleStr;
}

- (void)setPlayTime:(NSInteger)playTime
{
    _playTime = playTime;
    NSString *playTimeStr = [NSString timeStringWithSecond:playTime minDigits:3];
    _playTimeLab.text = playTimeStr;
}

- (void)setDuration:(NSInteger)duration
{
    _duration = duration;
    NSString *durationStr = [NSString timeStringWithSecond:duration minDigits:3];
    _durationLab.text = durationStr;
}

- (void)setMaxValue:(NSInteger)maxValue
{
    _maxValue = maxValue;
    
    _processSlider.maxValue = maxValue;
}

- (void)setCurValue:(NSInteger)curValue
{
    _curValue = curValue;
    
    _processSlider.value = curValue;
}

- (void)setIsStart:(BOOL)isStart
{
    if (_isStart != isStart)
    {
        _isStart = isStart;
        
        _startBtn.selected = isStart;
    }
}

- (void)setIsMuted:(BOOL)isMuted
{
    _isMuted = isMuted;
    
    _audioBtn.selected = isMuted;
}

- (void)setIsFull:(BOOL)isFull
{
    _isFull = isFull;
    
    _fullScreenBtn.selected = isFull;
}

#pragma mark - Getter
- (UIView *)topBackground
{
    if (!_topBackground) {
        _topBackground = [[UIView alloc] init];
        _topBackground.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    }
    return _topBackground;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"ntes_player_quit"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:17.0];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UIView *)bottomBackground
{
    if (!_bottomBackground) {
        _bottomBackground = [[UIView alloc] init];
        _bottomBackground.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _bottomBackground;
}

- (UIButton *)startBtn
{
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setImage:[UIImage imageNamed:@"ntes_player_play"] forState:UIControlStateNormal];
        [_startBtn setImage:[UIImage imageNamed:@"ntes_player_pause"] forState:UIControlStateSelected];
        _startBtn.tag = 10;
        [_startBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (UILabel *)playTimeLab
{
    if (!_playTimeLab) {
        _playTimeLab = [[UILabel alloc] init];
        _playTimeLab.textColor = [UIColor whiteColor];
        _playTimeLab.textAlignment = NSTextAlignmentCenter;
        _playTimeLab.font = [UIFont systemFontOfSize:13.0];
        _playTimeLab.text = @"00:00:00";
        [_playTimeLab sizeToFit];
        [self layoutSubviewsWithDirection];
    }
    return _playTimeLab;
}

- (NTESSlider *)processSlider
{
    if (!_processSlider) {
        _processSlider = [[NTESSlider alloc] init];
        _processSlider.minValue = 0.0;
        _processSlider.maxValue = 1.0;
        _processSlider.value = 0.0;
        _processSlider.thumbImage = [UIImage imageNamed:@"ntes_player_thumb"];
        _processSlider.thumbSize = CGSizeMake(15.0, 15.0);
        _processSlider.trackWidth = 4.0;
        _processSlider.minThrackImage = [UIImage imageNamed:@"ntes_playe_play_trace"];

        __weak typeof(self) weakSelf = self;
        _processSlider.valueChangedBlock = ^(CGFloat value) {
            
            [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(PlayerBar:processChanged:)]) {
                [weakSelf.delegate PlayerBar:weakSelf processChanged:value];
            }
        };
        
        _processSlider.valueEndChangeBlock = ^(CGFloat value) {
            [weakSelf performSelector:@selector(dismissBar) withObject:nil afterDelay:3];
        };
    }
    return _processSlider;
}

- (UILabel *)durationLab
{
    if (!_durationLab) {
        _durationLab = [[UILabel alloc] init];
        _durationLab.textColor = [UIColor whiteColor];
        _durationLab.textAlignment = NSTextAlignmentCenter;
        _durationLab.font = [UIFont systemFontOfSize:13.0];
        _durationLab.text = @"--:--:--";
        [_durationLab sizeToFit];
        [self layoutSubviewsWithDirection];
    }
    return _durationLab;
}

- (UIButton *)audioBtn
{
    if (!_audioBtn) {
        _audioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_audioBtn setImage:[UIImage imageNamed:@"ntes_player_audio"] forState:UIControlStateNormal];
        [_audioBtn setImage:[UIImage imageNamed:@"ntes_player_mute"] forState:UIControlStateSelected];
        _audioBtn.tag = 11;
        [_audioBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _audioBtn;
}

- (UIButton *)snapBtn
{
    if (!_snapBtn) {
        _snapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_snapBtn setImage:[UIImage imageNamed:@"ntes_player_snap"] forState:UIControlStateNormal];
        _snapBtn.tag = 12;
        [_snapBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _snapBtn;
}

- (UIButton *)fullScreenBtn
{
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"ntes_player_h"] forState:UIControlStateSelected];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"ntes_player_v"] forState:UIControlStateNormal];
        _fullScreenBtn.tag = 13;
        [_fullScreenBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}

@end
