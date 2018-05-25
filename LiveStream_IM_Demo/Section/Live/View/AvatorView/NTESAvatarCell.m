//
//  NTESAvatarCell.m
//  NEUIDemo
//
//  Created by Netease on 17/1/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAvatarCell.h"

@interface NTESAvatarCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIImageView *muteImageView;
@property (nonatomic, strong) UILabel *nickNameLab;

@end

@implementation NTESAvatarCell

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
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.muteImageView];
    [self.contentView addSubview:self.nickNameLab];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = MIN(self.contentView.width, self.contentView.height);
    self.avatarView.frame = CGRectMake(0, 0, width, width);
    self.muteImageView.frame = CGRectMake(self.avatarView.right-15.0, self.avatarView.bottom - 15.0, 15.0, 15.0);
    self.nickNameLab.frame = CGRectMake(0, self.contentView.bottom - self.nickNameLab.height,
                                        self.avatarView.width,
                                        self.nickNameLab.height);

}

- (void)configCell:(NSString *)avatarUrl nickName:(NSString *)nickName isMute:(BOOL)isMute
{
    self.avatarUrl = avatarUrl;
    
    self.nickName = nickName;
    
    self.mute = isMute;
}

#pragma mark -- Get/Set
- (UIImageView *)avatarView
{
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _avatarView;
}

- (UIImageView *)muteImageView
{
    if (!_muteImageView) {
        _muteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"forbidden_ic_"]];
        _muteImageView.contentMode = UIViewContentModeScaleAspectFit;
        _muteImageView.hidden = YES;
    }
    return _muteImageView;
}

- (void)setAvatarUrl:(NSString *)avatarUrl
{
    [_avatarView setCircleImageWithUrl:avatarUrl];
}

- (void)setMute:(BOOL)mute
{
    _muteImageView.hidden = !mute;
}

- (void)setNickName:(NSString *)nickName
{
    _nickName = (nickName ?: @"");
    
    self.nickNameLab.text = _nickName;
    
    [self.nickNameLab sizeToFit];
    
    [self setNeedsLayout];
}

- (UILabel *)nickNameLab
{
    if (!_nickNameLab)
    {
        _nickNameLab = [[UILabel alloc] init];
        _nickNameLab.font = [UIFont systemFontOfSize:12.0];
        _nickNameLab.textAlignment = NSTextAlignmentCenter;
        _nickNameLab.textColor = [UIColor whiteColor];
    }
    return _nickNameLab;
}

@end
