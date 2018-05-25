//
//  NTESRecordTopBar.m
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/3/30.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESRecordTopBar.h"

#define icon_width 44

@interface NTESRecordTopBar ()

@property (nonatomic, strong) UIButton *quitBtn;
@property(nonatomic, strong) UIButton *faceUBtn;
@property (nonatomic, strong) UIButton *beautyBtn;
@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, strong) UIButton *cameraBtn;


@end

@implementation NTESRecordTopBar

- (void)doInit
{
    [@[self.quitBtn,
       self.faceUBtn,
       self.beautyBtn,
       self.filterBtn,
       self.cameraBtn] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
           [self addSubview:view];
       }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    WEAK_SELF(weakSelf);
    [_quitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@icon_width);
        make.left.equalTo(weakSelf.mas_left);
        make.centerY.equalTo(weakSelf.mas_centerY);
    }];
    
    [_cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@icon_width);
        make.right.equalTo(weakSelf.mas_right);
        make.centerY.equalTo(weakSelf.mas_centerY);
    }];
    
    [_filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@icon_width);
        make.right.equalTo(weakSelf.cameraBtn.mas_left).offset(-8);
        make.centerY.equalTo(weakSelf.mas_centerY);
    }];
    
    [_beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@icon_width);
        make.right.equalTo(weakSelf.filterBtn.mas_left).offset(-8);
        make.centerY.equalTo(weakSelf.mas_centerY);
    }];
    
    [_faceUBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@icon_width);
        make.right.equalTo(weakSelf.beautyBtn.mas_left).offset(-8);
        make.centerY.equalTo(weakSelf.mas_centerY);
    }];
}

#pragma mark - Action
- (void)btnAction:(UIButton *)btn
{
    switch (btn.tag) {
        case 10: //退出
        {
            if (_delegate && [_delegate respondsToSelector:@selector(TopBarQuitAction:)]) {
                [_delegate TopBarQuitAction:self];
            }
            break;
        }
        case 11: //美颜
        {
            if (_delegate && [_delegate respondsToSelector:@selector(TopBarBeautyAction:)]) {
                [_delegate TopBarBeautyAction:self];
            }
            break;
        }
        case 12: //滤镜
        {
            if (_delegate && [_delegate respondsToSelector:@selector(TopBarFilterAction:)]) {
                [_delegate TopBarFilterAction:self];
            }
            break;
        }
        case 13: //相机
        {
            if (_delegate && [_delegate respondsToSelector:@selector(TopBarCameraAction:)]) {
                [_delegate TopBarCameraAction:self];
            }
            break;
        }
        case 14:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(TopBarFaceUSdkAction:)]) {
                [_delegate TopBarFaceUSdkAction:self];
            }
            break;
        }
        default:
            break;
    }
}


#pragma mark - Getter
- (UIButton *)quitBtn {
    if (!_quitBtn) {
        _quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_quitBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_quitBtn setImage:[UIImage imageNamed:@"close_high"] forState:UIControlStateHighlighted];
        _quitBtn.tag = 10;
        [_quitBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _quitBtn;
}

- (UIButton *)faceUBtn {
    if (!_faceUBtn) {
        _faceUBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_faceUBtn setImage:[UIImage imageNamed:@"faceU"] forState:UIControlStateNormal];
//        [_faceUBtn setImage:[UIImage imageNamed:@""] forState:<#(UIControlState)#>]
        _faceUBtn.tag = 14;
        [_faceUBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceUBtn;
}

- (UIButton *)beautyBtn {
    if (!_beautyBtn) {
        _beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_beautyBtn setImage:[UIImage imageNamed:@"beauty"] forState:UIControlStateNormal];
        [_beautyBtn setImage:[UIImage imageNamed:@"beauty_high"] forState:UIControlStateHighlighted];
        _beautyBtn.tag = 11;
        [_beautyBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyBtn;
}

- (UIButton *)filterBtn {
    if (!_filterBtn) {
        _filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_filterBtn setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
        [_filterBtn setImage:[UIImage imageNamed:@"filter_high"] forState:UIControlStateHighlighted];
        _filterBtn.tag = 12;
        [_filterBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterBtn;
}

- (UIButton *)cameraBtn {
    if (!_cameraBtn) {
        _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraBtn setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [_cameraBtn setImage:[UIImage imageNamed:@"camera_high"] forState:UIControlStateHighlighted];
        _cameraBtn.tag = 13;
        [_cameraBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraBtn;
}


@end
