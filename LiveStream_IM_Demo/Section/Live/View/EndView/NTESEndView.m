//
//  NTESEndView.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/9.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESEndView.h"

@interface NTESEndView ()

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *messageLabel;

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *closeButton;

@end

@implementation NTESEndView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    [self addSubview:self.avatarImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.messageLabel];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.closeButton.frame = CGRectMake(self.width - 50, 18, 50, 50);
    
    self.avatarImageView.frame = CGRectMake(0, 174 * UISreenHeightScale, 80, 80);
    self.avatarImageView.centerX = self.width/2;
    
    self.nameLabel.frame = CGRectMake(0, self.avatarImageView.bottom + 10, self.width, self.nameLabel.height);
    
    self.messageLabel.frame = CGRectMake(0, self.nameLabel.bottom + 32, self.width, self.messageLabel.height);
    
    self.backButton.frame = CGRectMake(0, self.messageLabel.bottom + 40, self.avatarImageView.width + 16, 44);
    self.backButton.centerX = self.width/2;
    
}

- (void)configEndView:(NSString *)avatarImage
                 name:(NSString *)name
              message:(NSString *)message
           hiddenBack:(BOOL)hiddenBack
{
    [self.avatarImageView setCircleImageWithUrl:avatarImage];
    
    if (name)
    {
        self.nameLabel.text = name;
        [self.nameLabel sizeToFit];
    }

    if (message)
    {
        self.messageLabel.text = message;
        [self.messageLabel sizeToFit];
    }
    
    [self.backButton removeFromSuperview];
    [self.closeButton removeFromSuperview];
    if (hiddenBack)
    {
        [self addSubview:self.closeButton];
    }
    else
    {
        [self addSubview:self.backButton];
    }
}

- (void)closeAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(endViewCloseAction:)]) {
        [_delegate endViewCloseAction:self];
    }
}

#pragma mark - Getter/Setter
- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _backButton.backgroundColor = [UIColor whiteColor];
        _backButton.layer.cornerRadius = 5.0f;
        [_backButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)closeButton
{
    if (!_closeButton)
    {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"icon_close_n"] forState:UIControlStateNormal];
        [_closeButton setImage:[UIImage imageNamed:@"icon_close_p"] forState:UIControlStateHighlighted];
        [_closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.clipsToBounds = YES;
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel)
    {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:15.0];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:20.0];
        _messageLabel.text = @"直播已结束";
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _messageLabel;
}

@end
