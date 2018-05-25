//
//  NTESBeautyConfigView.m
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/3/30.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBeautyConfigView.h"
#import "NTESSlider.h"

@interface NTESBeautyConfigView ()

@property (nonatomic, strong) NTESSlider *slider;

@end

@implementation NTESBeautyConfigView

- (void)doInit
{
    self.alpha = 0.0;
    [self addSubview:self.titleLab];
    [self addSubview:self.minValueLab];
    [self addSubview:self.slider];
    [self addSubview:self.maxValueLab];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleLab.frame = CGRectMake(16, 0, _titleLab.width, _titleLab.height);
    _titleLab.centerY = self.height/2;
    
    _minValueLab.left = _titleLab.right + 8.0;
    _minValueLab.centerY = self.height/2;
    
    _maxValueLab.right = self.width - 16.0;
    _maxValueLab.centerY = self.height/2;
    
    _slider.frame = CGRectMake(_minValueLab.right + 16.0,
                               8.0,
                               _maxValueLab.left - _minValueLab.right - 16.0*2,
                               self.height - 8.0*2);
}

#pragma mark - Public
- (void)showInView:(UIView *)view complete:(void (^)())complete
{
    [self removeFromSuperview];
    
    if (self.alpha == 0.0)
    {
        [view addSubview:self];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1.0;
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

- (void)dismissComplete:(void (^)())complete
{
    if (self.alpha != 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
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

#pragma mark - Setter

- (void)setMaxValue:(CGFloat)maxValue
{
    _maxValue = maxValue;
    
    _maxValueLab.text = [NSString stringWithFormat:@"%zi", (NSInteger)maxValue];
    [_maxValueLab sizeToFit];
    
    _slider.maxValue = maxValue;
}

- (void)setMinValue:(CGFloat)minValue
{
    _minValue = minValue;
    
    _minValueLab.text = [NSString stringWithFormat:@"%zi", (NSInteger)minValue];
    [_minValueLab sizeToFit];
    
    _slider.minValue = minValue;
}

- (void)setCurValue:(CGFloat)curValue
{
    if (curValue < _minValue) {
        curValue = _minValue;
    }
    if (curValue > _maxValue) {
        curValue = _maxValue;
    }
    
    _curValue = curValue;
    
    _slider.value = curValue;
}

- (void)setDefalutValue:(CGFloat)defalutValue {
    _slider.default_value = defalutValue;
}

#pragma mark - Getter
- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        _titleLab.font = [UIFont systemFontOfSize:14.0];
        _titleLab.text = @"美颜强度";
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

- (UILabel *)minValueLab
{
    if (!_minValueLab) {
        _minValueLab = [[UILabel alloc] init];
        _minValueLab.textAlignment = NSTextAlignmentCenter;
        _minValueLab.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        _minValueLab.font = [UIFont systemFontOfSize:14.0];
        _minValueLab.text = @"0";
        [_minValueLab sizeToFit];
    }
    return _minValueLab;
}

- (UILabel *)maxValueLab
{
    if (!_maxValueLab) {
        _maxValueLab = [[UILabel alloc] init];
        _maxValueLab = [[UILabel alloc] init];
        _maxValueLab.textAlignment = NSTextAlignmentCenter;
        _maxValueLab.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        _maxValueLab.font = [UIFont systemFontOfSize:14.0];
        _maxValueLab.text = @"10";
        [_maxValueLab sizeToFit];
    }
    return _maxValueLab;
}

- (NTESSlider *)slider
{
    if (!_slider) {
        _slider = [[NTESSlider alloc] init];
        UIImage *thumbImg = [UIImage new];
        _slider.maxValue = self.maxValue;
        _slider.minValue = self.minValue;
        _slider.default_value = self.defalutValue;
        _slider.trackColor = [UIColor colorWithWhite:1 alpha:0.4];
        if (_slider.value != _slider.default_value) {
            thumbImg = [UIImage imageNamed:@"beauty_slider_highlighted"];
        }
        else {
            thumbImg = [UIImage imageNamed:@"beauty_slider_thumb"];
        }
        _slider.thumbImage = thumbImg;
        
        __weak typeof(self) weakSelf = self;
        _slider.valueChangedBlock = ^(CGFloat value) {
            if (weakSelf.valueChangedBlock) {
                weakSelf.valueChangedBlock(value);
            }
        };
    }
    return _slider;
}

@end
