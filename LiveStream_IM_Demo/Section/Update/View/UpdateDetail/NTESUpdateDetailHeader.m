//
//  NTESUpdateDetailHeader.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateDetailHeader.h"

@interface NTESUpdateDetailHeader ()

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation NTESUpdateDetailHeader

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

- (instancetype)initWithTitle:(NSString *)titleStr
{
    if (self = [super init]) {
        [self customInit];
        
        self.titleStr = titleStr;
    }
    return self;
}

- (void)customInit
{
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleLab];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLab.centerY = self.height/2;
    self.titleLab.left = 15.0;
}

#pragma mark - Setter
- (void)setTitleStr:(NSString *)titleStr
{
    if (titleStr) {
        _titleStr = titleStr;
        _titleLab.text = titleStr;
        [_titleLab sizeToFit];
    }
}

#pragma mark - Getter
- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:14.0];
        _titleLab.textColor = UIColorFromRGB(0x999999);
    }
    return _titleLab;
}
@end
