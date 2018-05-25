//
//  NTESAlubmBottomBar.m
//  NTESUpadateUI
//
//  Created by Netease on 17/2/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAlubmBottomBar.h"

@interface NTESAlubmBottomBar ()

@property (nonatomic, strong) UILabel *countLab;

@property (nonatomic, strong) UILabel *placeholderLab;

@property (nonatomic, strong) UIButton *sureBtn;


@end

@implementation NTESAlubmBottomBar

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
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];
    [self addSubview:self.countLab];
    [self addSubview:self.placeholderLab];
    [self addSubview:self.sureBtn];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _countLab.left = 10.0;
    _countLab.centerY = self.height/2;
    
    _placeholderLab.left = _countLab.right + 10;
    _placeholderLab.centerY = self.height/2;
    _placeholderLab.width += 8;
    
    _sureBtn.frame = CGRectMake(self.width - 60, 0, 60, self.height);
}

- (void)btnAction:(UIButton *)btn
{
    if (_delegate && [_delegate respondsToSelector:@selector(BottomBarSureAction:)]) {
        [_delegate BottomBarSureAction:self];
    }
}

#pragma mark - Setter
- (void)setCount:(NSInteger)count
{
    if (count <= _maxCount)
    {
        _count = count;
        
        _sureBtn.enabled = (count > 0);
        _countLab.text = [NSString stringWithFormat:@"%zi/%zi", count, _maxCount];
        [_countLab sizeToFit];
    }
}

- (void)setMaxCount:(NSInteger)maxCount
{
    _maxCount = maxCount;
    
    _placeholderLab.text = [NSString stringWithFormat:@"最多可选择%zi个视频", maxCount];
    [_placeholderLab sizeToFit];
;
}

#pragma mark - Getter
- (UILabel *)countLab
{
    if (!_countLab) {
        _countLab = [[UILabel alloc] init];
        _countLab.font = [UIFont systemFontOfSize:15.0];
        _countLab.textColor = UIColorFromRGB(0x333333);
        _countLab.textAlignment = NSTextAlignmentCenter;
        _countLab.text = @"0/0";
        [_countLab sizeToFit];
    }
    return _countLab;
}

- (UILabel *)placeholderLab
{
    if (!_placeholderLab) {
        _placeholderLab = [[UILabel alloc] init];
        _placeholderLab.font = [UIFont systemFontOfSize:15.0];
        _placeholderLab.textColor = [UIColor lightGrayColor];
        _placeholderLab.textAlignment = NSTextAlignmentCenter;
        _placeholderLab.text = @"最多可选择0个视频";
        [_placeholderLab sizeToFit];
    }
    return _placeholderLab;
}

- (UIButton *)sureBtn
{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:UIColorFromRGBA(0X238EFA, 0.3) forState:UIControlStateHighlighted];
        [_sureBtn setTitleColor:UIColorFromRGB(0X238EFA) forState:UIControlStateNormal];
        [_sureBtn setTitleColor:UIColorFromRGBA(0X238EFA, 0.3) forState:UIControlStateDisabled];
        _sureBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_sureBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        _sureBtn.enabled = NO;
    }
    return _sureBtn;
}

@end
