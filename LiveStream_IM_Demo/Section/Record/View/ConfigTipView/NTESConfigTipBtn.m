//
//  NTESConfigTipBtn.m
//  ShortVideo_Demo
//
//  Created by Netease on 17/2/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESConfigTipBtn.h"

const CGFloat gInterVal = 6.0;
const CGFloat gInterViewWidth = 1.0;

@interface NTESConfigTipBtn ()
{
    CGFloat _lastWidth;
    UIColor *_normalBackColor;
}

@property (nonatomic, strong) UILabel *sectionLab;

@property (nonatomic, strong) UILabel *durationLab;

@property (nonatomic, strong) UILabel *resolutionLab;

@property (nonatomic, strong) UILabel *screenScaleLab;

@property (nonatomic, strong) NSMutableArray *intervalViews;

@end

@implementation NTESConfigTipBtn

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
    [self addSubview:self.sectionLab];
    [self addSubview:self.durationLab];
    [self addSubview:self.resolutionLab];
    [self addSubview:self.screenScaleLab];
    [self addIntervalWithCount:3];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //清晰度
    _resolutionLab.left = gInterVal*2;
    _resolutionLab.centerY = self.height/2;
    
    //段数
    _sectionLab.left = _resolutionLab.right + gInterVal * 2 + gInterViewWidth;
    _sectionLab.centerY = self.height/2;
    
    //总时长
    _durationLab.left = _sectionLab.right + gInterVal * 2 + gInterViewWidth;
    _durationLab.centerY = self.height/2;
    
    //画幅
    _screenScaleLab.left = _durationLab.right + gInterVal * 2 + gInterViewWidth;
    _screenScaleLab.centerY = self.height/2;
    
    //间隔
    __weak typeof(self) weakSelf = self;
    [_intervalViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = (UIView *)obj;
        view.centerY = self.height/2;
        
        if (idx == 0) {
            view.left = weakSelf.resolutionLab.right + gInterVal;
        }
        else if (idx == 1) {
            view.left = weakSelf.sectionLab.right + gInterVal;
        }
        else if (idx == 2) {
            view.left = weakSelf.durationLab.right + gInterVal;
        }
    }];
}

- (void)addIntervalWithCount:(NSInteger)count
{
    if (count == 0) {
        return;
    }
    
    if (!_intervalViews) {
        _intervalViews = [NSMutableArray array];
    }
    
    if (_intervalViews.count != 0)
    {
        [_intervalViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_intervalViews removeAllObjects];
    }

    for (NSInteger i = 0; i < count; i++) {
        UIView *view = [self makeIntervalView];
        [_intervalViews addObject:view];
        [self addSubview:view];
    }
}

- (UIView *)makeIntervalView
{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, gInterViewWidth, gInterViewWidth);
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

#pragma mark - Touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    _normalBackColor = self.backgroundColor;
    self.backgroundColor = [UIColor lightGrayColor];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (_normalBackColor) {
        self.backgroundColor = _normalBackColor;
    }
}

#pragma mark - Setter
- (void)setDuration:(NSInteger)duration
{
    _duration = duration;
    _durationLab.text = [NSString stringWithFormat:@"%zi 秒", duration];
    CGFloat lastWidth = _durationLab.width;
    [_durationLab sizeToFit];
    
    //宽度变了
    if (_durationLab.width != lastWidth)
    {
        CGFloat distance = _durationLab.width - lastWidth;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = CGRectMake(self.left - distance,
                                    self.top,
                                    self.tipRect.width,
                                    self.height);
        }];
    }
}

- (void)setSection:(NSInteger)section
{
    _section = section;
    _sectionLab.text = [NSString stringWithFormat:@"%zi 段", section];
    CGFloat lastWidth = _sectionLab.width;
    [_sectionLab sizeToFit];
    
    //宽度变了
    if (_sectionLab.width != lastWidth)
    {
        CGFloat distance = _sectionLab.width - lastWidth;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = CGRectMake(self.left - distance,
                                    self.top,
                                    self.tipRect.width,
                                    self.height);
        }];
    }
}

- (void)setResolution:(NTESRecordResolution)resolution
{
    _resolution = resolution;
    NSString *str = @"流畅";
    switch (resolution) {
        case NTESRecordResolutionSD:
            str = @"流畅";
            break;
        case NTESRecordResolutionHD:
            str = @"高清";
            break;
        default:
            break;
    }
    
    _resolutionLab.text = str;
    CGFloat lastWidth = _sectionLab.width;
    [_sectionLab sizeToFit];
    
    //宽度变了
    if (_resolutionLab.width != lastWidth)
    {
        CGFloat distance = _resolutionLab.width - lastWidth;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = CGRectMake(self.left - distance,
                                    self.top,
                                    self.tipRect.width,
                                    self.height);
        }];
    }
}

- (void)setScreenScale:(NTESRecordScreenScale)screenScale
{
    _screenScale = screenScale;
    
    NSString *str = @"16:9";
    switch (screenScale) {
        case NTESRecordScreenScale16x9:
            str = @"16:9";
            break;
        case NTESRecordScreenScale4x3:
            str = @"4:3";
            break;
        case NTESRecordScreenScale1x1:
            str = @"1:1";
            break;
        default:
            break;
    }
    
    _screenScaleLab.text = str;
    CGFloat lastWidth = _sectionLab.width;
    [_sectionLab sizeToFit];
    
    //宽度变了
    if (_screenScaleLab.width != lastWidth)
    {
        CGFloat distance = _screenScaleLab.width - lastWidth;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = CGRectMake(self.left - distance,
                                    self.top,
                                    self.tipRect.width,
                                    self.height);
        }];
    }
}

#pragma mark - Getter
- (UILabel *)sectionLab
{
    if (!_sectionLab) {
        _sectionLab = [[UILabel alloc] init];
        _sectionLab.textColor = [UIColor whiteColor];
        _sectionLab.textAlignment = NSTextAlignmentCenter;
        _sectionLab.font = [UIFont systemFontOfSize:14.0];
        _sectionLab.text = @"0 段";
        [_sectionLab sizeToFit];
    }
    return _sectionLab;
}

- (UILabel *)durationLab
{
    if (!_durationLab) {
        _durationLab = [[UILabel alloc] init];
        _durationLab.textColor = [UIColor whiteColor];
        _durationLab.textAlignment = NSTextAlignmentCenter;
        _durationLab.font = [UIFont systemFontOfSize:14.0];
        _durationLab.text = @"0 秒";
        [_durationLab sizeToFit];
    }
    return _durationLab;
}

- (UILabel *)resolutionLab
{
    if (!_resolutionLab) {
        _resolutionLab = [[UILabel alloc] init];
        _resolutionLab.textColor = [UIColor whiteColor];
        _resolutionLab.textAlignment = NSTextAlignmentCenter;
        _resolutionLab.font = [UIFont systemFontOfSize:14.0];
        _resolutionLab.text = @"标清";
        [_resolutionLab sizeToFit];
    }
    return _resolutionLab;
}

- (UILabel *)screenScaleLab
{
    if (!_screenScaleLab) {
        _screenScaleLab = [[UILabel alloc] init];
        _screenScaleLab.textColor = [UIColor whiteColor];
        _screenScaleLab.textAlignment = NSTextAlignmentCenter;
        _screenScaleLab.font = [UIFont systemFontOfSize:14.0];
        _screenScaleLab.text = @"16:9";
        [_screenScaleLab sizeToFit];
    }
    return _screenScaleLab;
}

- (CGSize)tipRect
{
    CGFloat intervalWidth = gInterVal * 8;
    CGFloat interViewWidth = gInterViewWidth * _intervalViews.count;
    CGFloat labWidth = _resolutionLab.width + _sectionLab.width + _durationLab.width + _screenScaleLab.width;
    CGFloat width = intervalWidth + interViewWidth + labWidth + 2* gInterVal;
    CGFloat height = self.sectionLab.height + gInterVal + 2.0;
    return CGSizeMake(width, height);
}

@end
