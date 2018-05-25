//
//  NTESFilterConfigCell.m
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/4/1.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESFilterConfigCell.h"

@interface NTESFilterConfigCell ()

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation NTESFilterConfigCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self doInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self doInit];
    }
    return self;
}

- (void)doInit
{
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.0];
    [self addSubview:self.titleLab];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleLab.frame = self.bounds;
}

#pragma mark - Setter
- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        _titleLab.textColor = [UIColor whiteColor];
    }
    else
    {
        _titleLab.textColor = [UIColor colorWithWhite:1 alpha:0.4];
    }
}

- (void)setTitleStr:(NSString *)titleStr
{
    _titleStr = titleStr;
    
    _titleLab.text = (titleStr ?: @"");
}

#pragma mark - Getter
- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = [UIColor colorWithWhite:1 alpha:0.4];
        _titleLab.font = [UIFont systemFontOfSize:14.0];
    }
    return _titleLab;
}

@end
