//
//  NTESAlbumHeader.m
//  ShortVideo_Demo
//
//  Created by Netease on 17/2/14.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAlbumHeader.h"

@interface NTESAlbumHeader ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIButton *clearBtn;

@end

@implementation NTESAlbumHeader
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLab];
        [self addSubview:self.clearBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLab.frame = CGRectMake(10, 20, self.titleLab.width, self.titleLab.height);
    self.clearBtn.frame = CGRectMake(self.width - 60, 0, 60, self.height);
}

- (void)clearBtnAction:(UIButton *)btn
{
    if (_clearBlock) {
        _clearBlock();
    }
}

#pragma mark - Public
- (void)configHeader:(NSString *)title hiddenClear:(BOOL)hiddenClear clearBlock:(ClearBlock)clearBlock
{
    self.titleStr = title;
    
    self.hiddenClear = hiddenClear;
    
    self.clearBlock = clearBlock;
}

#pragma mark - Getter/Setter
- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:15.0];
        _titleLab.textColor = UIColorFromRGB(0x333333);
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

- (UIButton *)clearBtn
{
    if (!_clearBtn) {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _clearBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [_clearBtn setTitle:@"清空" forState:UIControlStateNormal];
        [_clearBtn addTarget:self action:@selector(clearBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _clearBtn;
}

- (void)setTitleStr:(NSString *)titleStr
{
    _titleStr = titleStr;
    
    if (titleStr) {
        self.titleLab.text = titleStr;
        [self.titleLab sizeToFit];
    }
}

- (void)setHiddenClear:(BOOL)hiddenClear
{
    _hiddenClear = hiddenClear;
    
    self.clearBtn.hidden = hiddenClear;
}

@end
