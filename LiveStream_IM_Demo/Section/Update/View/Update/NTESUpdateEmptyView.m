//
//  NTESUpdateEmptyView.m
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/4/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateEmptyView.h"

@interface NTESUpdateEmptyView ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton *retryBtn;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIActivityIndicatorView *active;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@end

@implementation NTESUpdateEmptyView

- (void)doInit
{
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.imgView];
    [self addSubview:self.active];
    [self addSubview:self.titleLab];
    [self addSubview:self.retryBtn];
    [self addGestureRecognizer:self.tap];
    
    self.style = NTESUpdateEmptyNone;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imgView.frame = CGRectMake(0, 0, 220, 176);
    self.imgView.center =  CGPointMake(self.width/2, self.height/2 - 30.0);
    self.titleLab.frame = CGRectMake(0, _imgView.bottom + 16.0, self.width, 25.0);
    self.active.center = CGPointMake(self.width/2, self.height/2 - 40.0);
    self.retryBtn.frame = CGRectMake(0, _titleLab.bottom + 8.0, 82.0, 40.0);
    self.retryBtn.centerX = self.width/2;
}

#pragma mark - Public
- (void)show:(BOOL)isShown style:(NTESUpdateEmptyStyle)style
{
    self.hidden = !isShown;
    self.style = style;
}

#pragma mark - Action
- (void)btnAction
{
    if (_retry) {
        _retry();
    }
}

- (void)tapAction:(UIGestureRecognizer *)tap
{
    if (_retry) {
        _retry();
    }
}

#pragma mark - Setter
- (void)setStyle:(NTESUpdateEmptyStyle)style
{
    switch (style) {
        case NTESUpdateEmptyNone:
        {
            self.imgView.image = [UIImage imageNamed:@"empty_none_video"];
            self.imgView.hidden = NO;
            [self.active stopAnimating];
            self.titleLab.text = @"没有视频";
            self.retryBtn.hidden = YES;
            [self removeGestureRecognizer:self.tap];
            [self addGestureRecognizer:self.tap];
            break;
        }
        case NTESUpdateEmptyLoading:
        {
            self.imgView.hidden = YES;
            [self.active startAnimating];
            self.titleLab.text = @"加载中";
            self.retryBtn.hidden = YES;
            [self removeGestureRecognizer:self.tap];
            break;
        }
        case NTESUpdateEmptyTimeOut:
        {
            self.imgView.image = [UIImage imageNamed:@"empty_net_timout"];
            self.imgView.hidden = NO;
            [self.active stopAnimating];
            self.titleLab.text = @"加载超时";
            self.retryBtn.hidden = NO;
            [self removeGestureRecognizer:self.tap];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Getter
- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgView;
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:14.0];
        _titleLab.textColor = UIColorFromRGB(0x999999);
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UIActivityIndicatorView *)active
{
    if (!_active) {
        _active = [[UIActivityIndicatorView alloc] init];
        _active.size = CGSizeMake(40, 40);
        _active.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _active.hidesWhenStopped = YES;
    }
    return _active;
}

- (UIButton *)retryBtn
{
    if (!_retryBtn) {
        _retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_retryBtn setTitleColor:UIColorFromRGB(0x3d7ef5) forState:UIControlStateNormal];
        [_retryBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        [_retryBtn setBackgroundImage:[UIImage imageNamed:@"blue_btn"] forState:UIControlStateNormal];
        [_retryBtn setBackgroundImage:[UIImage imageNamed:@"blue_btn_high"] forState:UIControlStateHighlighted];
        [_retryBtn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryBtn;
}

- (UITapGestureRecognizer *)tap
{
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    }
    return _tap;
}

@end
