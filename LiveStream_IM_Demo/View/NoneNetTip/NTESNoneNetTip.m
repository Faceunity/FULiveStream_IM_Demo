//
//  NTESNoneNetTip.m
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/4/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESNoneNetTip.h"

@interface NTESNoneNetTip ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation NTESNoneNetTip

- (void)doInit
{
    self.clipsToBounds = YES;
    self.backgroundColor = UIColorFromRGB(0xFFE5BC);
    [self addSubview:self.imgView];
    [self addSubview:self.titleLab];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imgView.left = 19.0;
    self.imgView.centerY = self.height/2;
    self.titleLab.left = self.imgView.right + 8.0;
    self.titleLab.centerY = self.imgView.centerY;
}

#pragma mark - Getter
- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.frame = CGRectMake(0, 0, 16.0, 16.0);
        _imgView.image = [UIImage imageNamed:@"circle_Info"];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgView;
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"当前网络不可用，请检查您的网络设置";
        _titleLab.font = [UIFont systemFontOfSize:14.0];
        _titleLab.textColor = UIColorFromRGB(0x4A4A4A);
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

@end
