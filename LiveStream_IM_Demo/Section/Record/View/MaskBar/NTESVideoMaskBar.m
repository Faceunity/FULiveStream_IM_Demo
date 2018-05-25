//
//  NTESVideoMaskBar.m
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/4/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESVideoMaskBar.h"
#import "NTESSlider.h"

@interface NTESVideoMaskBar ()

{
    BOOL _isFocusing;    //正在变焦
    BOOL _focusIsShown; //聚焦视图出现
    BOOL _zoomIsChanged; //变焦改变
    CGFloat _oriVerValue;
}


@property (nonatomic, strong) UIView *minTraceView;

@property (nonatomic, strong) UIView *maxTraceView;

@property (nonatomic, strong) UIView *thumbView;

@property (nonatomic, assign) CGPoint point;

@property (nonatomic, strong) UIView *containerView;

@end

@implementation NTESVideoMaskBar

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    NSLog(@"NTESVideoMaskBar 释放了");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        [self addSubview:self.exposureSlider];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _containerView.frame = CGRectMake(0, 0, 84, 60);
    _containerView.center = _point;
    _exposureSlider.frame = CGRectMake(self.width - 40.0, 0, 40.0, 200.0);
    _exposureSlider.centerY = self.height/2;
}

- (void)showExposureSlider
{
    if (_exposureSlider.isHidden)
    {
        _exposureSlider.hidden = NO;
        [self performSelector:@selector(dissmissExposureSlider) withObject:nil afterDelay:2.0];
    }
}

- (void)dissmissExposureSlider
{
    if (!_exposureSlider.isHidden)
    {
        _exposureSlider.hidden = YES;
    }
}

- (void)showFocusInPoint:(CGPoint)point complete:(void (^)())complete
{
    _isFocusing = YES;
    
    [self performSelector:@selector(dismissFocus) withObject:nil afterDelay:1.5];
    
    //移除
    [self.containerView removeFromSuperview];
    _focusIsShown = NO;
    
    //调整位置
    _containerView.frame = CGRectMake(0, 0, 84, 60);
    if (point.x > self.width * 2/3) //右边界
    {
        _point = CGPointMake(point.x - (_containerView.width/2 - _containerView.height/2), point.y);
        self.zoomSlider.frame = CGRectMake(0, 0, 20.0, _containerView.height);
        self.focusImgView.frame = CGRectMake(_zoomSlider.right + 4.0, 0, _containerView.height, _containerView.height);
    }
    else
    {
        _point = CGPointMake(point.x + (_containerView.width/2 - _containerView.height/2), point.y);
        self.focusImgView.frame = CGRectMake(0, 0, _containerView.height, _containerView.height);
        self.zoomSlider.frame = CGRectMake(_focusImgView.right + 4.0, 0, 20.0, _containerView.height);
    }
    self.containerView.center = _point;
    self.containerView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
    //回调
    if (_delegate && [_delegate respondsToSelector:@selector(MaskBar:focusInPoint:)]) {
        [_delegate MaskBar:self focusInPoint:point];
    }
    
    //显示
    [self addSubview:self.containerView];
    [UIView animateWithDuration:0.5 animations:^{
        self.containerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _focusIsShown = YES;
        _isFocusing = NO;
    }];
}

- (void)dismissFocus
{
    [self.containerView removeFromSuperview];
    _focusIsShown = NO;
}

- (BOOL)rect:(CGRect)rect containPoint:(CGPoint)point
{
    return (point.x > rect.origin.x
            && point.x < rect.origin.x + rect.size.width
            && point.y > rect.origin.y
            && point.y < rect.origin.y + rect.size.height);
}

#pragma mark - Touch Action

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self showExposureSlider];
    
    CGPoint point = [touch locationInView:self];
    if (![self rect:self.bounds containPoint:point]) {
        return NO;
    }
    
    if (_isFocusing) {
        return NO;
    }
    else
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissFocus) object:nil];
        _oriVerValue = [touch locationInView:self].y;
        return YES;
    }
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_focusIsShown) //改变焦点
    {
        CGPoint touchPoint = [touch locationInView:self];
        
        CGFloat changeValue = touchPoint.y - _oriVerValue;
        
        CGFloat changeDstValue = -changeValue/self.height * (_zoomSlider.maxValue - _zoomSlider.minValue);
        
        if (changeDstValue != 0) {
            self.zoomSlider.value += changeDstValue;
            
            if (_delegate && [_delegate respondsToSelector:@selector(MaskBar:zoomChanged:)]) {
                [_delegate MaskBar:self zoomChanged:_zoomSlider.value];
            }
        }
        
        _zoomIsChanged = YES;
        
        _oriVerValue = touchPoint.y;
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_zoomIsChanged) //变焦改变了
    {
        [self performSelector:@selector(dismissFocus) withObject:nil afterDelay:1.0];
        _zoomIsChanged = NO;
    }
    else //新的位置
    {
        CGPoint touchPoint = [touch locationInView:self];
        
        [self showFocusInPoint:touchPoint complete:nil];
    }
}

#pragma mark - Setter
- (void)setExposureValue:(CGFloat)exposureValue
{
    if (exposureValue < -1) {
        exposureValue = -1;
    }
    
    if (exposureValue > 1) {
        exposureValue = 1;
    }
    
    _exposureValue = exposureValue;
    
    self.exposureSlider.value = exposureValue;
}

#pragma mark - Getter
- (UIImageView *)focusImgView
{
    if (!_focusImgView) {
        _focusImgView = [[UIImageView alloc] init];
        _focusImgView.contentMode = UIViewContentModeScaleAspectFit;
        _focusImgView.image = [UIImage imageNamed:@"focus_border"];
    }
    return _focusImgView;
}

- (NTESSlider *)exposureSlider
{
    if (!_exposureSlider) {
        _exposureSlider = [[NTESSlider alloc] init];
        _exposureSlider.minValue = -0.5;
        _exposureSlider.maxValue = 0.5;
        _exposureSlider.hidden = YES;
        _exposureSlider.default_value = 0.f;
        _exposureSlider.maxValueImg = [UIImage imageNamed:@"exposure_slider_max"];
        _exposureSlider.thumbImage = [UIImage imageNamed:@"beauty_slider_thumb"];
        
        __weak typeof(self) weakSelf = self;
        _exposureSlider.valueChangedBlock = ^(CGFloat value) {
            [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(dissmissExposureSlider) object:nil];
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(MaskBar:exposureValueChanged:)]) {
                [weakSelf.delegate MaskBar:weakSelf exposureValueChanged:value];
            }
        };
        
        _exposureSlider.valueEndChangeBlock = ^(CGFloat value) {
            [weakSelf performSelector:@selector(dissmissExposureSlider) withObject:nil afterDelay:2.0];
        };
    }
    return _exposureSlider;
}

- (NTESSlider *)zoomSlider
{
    if (!_zoomSlider) {
        _zoomSlider = [[NTESSlider alloc] init];
        _zoomSlider.minValue = 1.0;
        _zoomSlider.maxValue = 3.0;
        _zoomSlider.valueStyle = NTESValueStyleFocus;
        _zoomSlider.trackWidth = 1.0;
        _zoomSlider.thumbSize = CGSizeMake(25, 15);
        _zoomSlider.thumbImage = [UIImage imageNamed:@"focus_slider_thumb"];
        _zoomSlider.minThrackImage = [UIImage imageNamed:@"focus_slider_line"];
        _zoomSlider.maxThrackImage = [UIImage imageNamed:@"focus_slider_line"];
        _zoomSlider.userInteractionEnabled = NO;
    }
    return _zoomSlider;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        [_containerView addSubview:self.focusImgView];
        [_containerView addSubview:self.zoomSlider];
        _containerView.size = CGSizeMake(57.0, 57.0);
    }
    return _containerView;
}

@end
