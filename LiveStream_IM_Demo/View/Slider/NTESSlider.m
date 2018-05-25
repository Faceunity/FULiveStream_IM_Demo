//
//  NTESSlider.m
//  NTESSlider
//
//  Created by Netease on 17/4/18.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESSlider.h"

#define NTES_SLIDER_INTERVAL 4.0

@interface NTESSlider ()
@property (nonatomic, strong) UIImageView *minValueImgView;
@property (nonatomic, strong) UIImageView *maxValueImgView;
@property (nonatomic, strong) NTESSliderControl *sliderCtl;
@property (nonatomic, assign) BOOL isVertical;

@end

@implementation NTESSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.sliderCtl];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.minValueImg && self.maxValueImg)
    {
        if (self.isVertical)
        {
            self.maxValueImgView.top = 0;
            self.maxValueImgView.centerX = self.width/2;
            self.minValueImgView.bottom = self.height;
            self.minValueImgView.centerX = self.width/2;
            self.sliderCtl.frame = CGRectMake(0,
                                              _maxValueImgView.bottom + NTES_SLIDER_INTERVAL,
                                              self.width,
                                              _minValueImgView.top - _maxValueImgView.bottom - NTES_SLIDER_INTERVAL*2);
            
        }
        else
        {
            self.minValueImgView.left = 0;
            self.minValueImgView.centerY = self.height/2;
            self.maxValueImgView.right = self.width;
            self.maxValueImgView.centerY = self.height/2;
            self.sliderCtl.frame = CGRectMake(_minValueImgView.right + NTES_SLIDER_INTERVAL,
                                              0,
                                              _maxValueImgView.left - _minValueImgView.right - NTES_SLIDER_INTERVAL*2,
                                              self.height);
        }
    }
    else if (!self.minValueImg && self.maxValueImg)
    {
        if (self.isVertical)
        {
            self.maxValueImgView.top = 0;
            self.maxValueImgView.centerX = self.width/2;
            self.sliderCtl.frame = CGRectMake(0,
                                              _maxValueImgView.bottom + NTES_SLIDER_INTERVAL,
                                              self.width,
                                              self.height - _maxValueImgView.bottom - NTES_SLIDER_INTERVAL);
        }
        else
        {
            self.maxValueImgView.right = self.width;
            self.maxValueImgView.centerY = self.height/2;
            self.sliderCtl.frame = CGRectMake(0,
                                              0,
                                              _maxValueImgView.left - NTES_SLIDER_INTERVAL,
                                              self.height);
        }
    }
    else if (self.minValueImg && !self.maxValueImg)
    {
        if (self.isVertical)
        {
            self.minValueImgView.bottom = self.height;
            self.minValueImgView.centerX = self.width/2;
            self.sliderCtl.frame = CGRectMake(0,
                                              0,
                                              self.width,
                                              _minValueImgView.top - NTES_SLIDER_INTERVAL);
        }
        else
        {
            self.minValueImgView.left = 0;
            self.minValueImgView.centerY = self.height/2;
            self.sliderCtl.frame = CGRectMake(_minValueImgView.right + NTES_SLIDER_INTERVAL,
                                              0,
                                              self.width - _minValueImgView.right - NTES_SLIDER_INTERVAL,
                                              self.height);
        }
    }
    else
    {
        _sliderCtl.frame = self.bounds;
    }
    

}

#pragma mark - Setter
- (CGFloat)value
{
    return self.sliderCtl.value;
}

- (void)setValue:(CGFloat)value
{
    self.sliderCtl.value = value;
}

- (void)setDefault_value:(CGFloat)default_value {
    self.sliderCtl.defalut_value = default_value;
}

- (CGFloat)default_value {
    return self.sliderCtl.defalut_value;
}

- (NTESValueStyle)valueStyle
{
    return self.sliderCtl.valueStyle;
}

- (void)setValueStyle:(NTESValueStyle)valueStyle
{
    self.sliderCtl.valueStyle = valueStyle;
}

- (CGFloat)maxValue
{
    return self.sliderCtl.maxValue;
}

- (void)setMaxValue:(CGFloat)maxValue
{
    self.sliderCtl.maxValue = maxValue;
}

- (CGFloat)minValue
{
    return self.sliderCtl.minValue;
}

- (void)setMinValue:(CGFloat)minValue
{
    self.sliderCtl.minValue = minValue;
}

- (UIImage *)thumbImage
{
    return self.sliderCtl.thumbImage;
}

- (void)setThumbImage:(UIImage *)thumbImage
{
    self.sliderCtl.thumbImage = thumbImage;
}

- (UIImage *)minThrackImage
{
    return self.sliderCtl.minThrackImage;
}

- (void)setMinThrackImage:(UIImage *)minThrackImage
{
    self.sliderCtl.minThrackImage = minThrackImage;
}

- (UIImage *)maxThrackImage
{
    return self.sliderCtl.maxThrackImage;
}

- (void)setMaxThrackImage:(UIImage *)maxThrackImage
{
    self.sliderCtl.maxThrackImage = maxThrackImage;
}

- (CGFloat)trackWidth
{
    return self.sliderCtl.trackWidth;
}

- (void)setTrackWidth:(CGFloat)trackWidth
{
    self.sliderCtl.trackWidth = trackWidth;
}

- (void)setTrackColor:(UIColor *)trackColor {
    self.sliderCtl.trackColor = trackColor;
}

- (CGSize)thumbSize
{
    return self.sliderCtl.thumbSize;
}

- (void)setThumbSize:(CGSize)thumbSize
{
    self.sliderCtl.thumbSize = thumbSize;
}

- (void)setMinValueImg:(UIImage *)minValueImg
{
    if (minValueImg)
    {
        self.minValueImgView.image = minValueImg;
        [self.minValueImgView removeFromSuperview];
        [self addSubview:self.minValueImgView];
    }
    _minValueImg = minValueImg;
}

- (void)setMaxValueImg:(UIImage *)maxValueImg
{
    if (maxValueImg)
    {
        self.maxValueImgView.image = maxValueImg;
        [self.maxValueImgView removeFromSuperview];
        [self addSubview:self.maxValueImgView];
    }
    _maxValueImg = maxValueImg;
}

#pragma mark - Getter
- (UIImageView *)minValueImgView
{
    if (!_minValueImgView) {
        _minValueImgView = [[UIImageView alloc] init];
        _minValueImgView.contentMode = UIViewContentModeScaleAspectFit;
        _minValueImgView.size = CGSizeMake(20.0, 20.0);
    }
    return _minValueImgView;
}

- (UIImageView *)maxValueImgView
{
    if (!_maxValueImgView) {
        _maxValueImgView = [[UIImageView alloc] init];
        _maxValueImgView.contentMode = UIViewContentModeScaleAspectFit;
        _maxValueImgView.size = CGSizeMake(20.0, 20.0);
    }
    return _maxValueImgView;
}

- (NTESSliderControl *)sliderCtl
{
    if (!_sliderCtl) {
        _sliderCtl = [[NTESSliderControl alloc] init];
        
        if (_sliderCtl.valueStyle != NTESValueStyleFocus) {
            WEAK_SELF(weakSelf);
            _sliderCtl.valueBlock = ^(CGFloat value){
                if (weakSelf.valueChangedBlock) {
                    weakSelf.valueChangedBlock(value);
                    weakSelf.sliderCtl.thumbLab.hidden = NO;
                    weakSelf.sliderCtl.thumbLab.textColor = UIColorFromRGB(0x2084ff);
                }
            };
            
            _sliderCtl.valueEndChangeBlock = ^(CGFloat value) {
                if (weakSelf.valueEndChangeBlock) {
                    weakSelf.valueEndChangeBlock(value);
                    weakSelf.sliderCtl.thumbLab.hidden = YES;
                }
            };
        }
    }
    return _sliderCtl;
}

- (BOOL)isVertical
{
    return (self.bounds.size.height > self.bounds.size.width);
}

@end
