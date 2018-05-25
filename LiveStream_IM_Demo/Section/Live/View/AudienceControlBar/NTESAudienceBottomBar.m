//
//  NTESAudienceBottomBar.m
//  NEUIDemo
//
//  Created by Netease on 17/1/4.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAudienceBottomBar.h"
#import "NTESPresentShopView.h"
#import "NTESPresentMessage.h"
#import "NTESMenuView.h"

typedef NS_ENUM(NSInteger,NTESBottomActionType)
{
    NTESBottomActionTypeComment = 1000, //点评论按钮
    NTESBottomActionTypePresent, //礼物
    NTESBottomActionTypeShare,   //分享
    NTESBottomActionTypeSnap,    //截屏
};

@interface NTESAudienceBottomBar ()<NTESPresentShopViewDelegate, NTESMenuViewProtocol>

@property (nonatomic, strong) UIView *line; //分割线
@property (nonatomic, strong) UIButton *commentBtn; //评论按钮
@property (nonatomic, strong) UIButton *sharedButton; //分享按钮
@property (nonatomic, strong) UIButton *presentButton; //礼物按钮
@property (nonatomic, strong) UIButton *snapButton; //截屏按钮
@property (nonatomic, strong) NTESPresentShopView *presentShop; //礼物商店
@property (nonatomic, strong) NTESMenuView *shareMenuView; //分享选择框

@end

@implementation NTESAudienceBottomBar

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
    [self addSubview:self.line];
    [self addSubview:self.commentBtn];
    [self addSubview:self.presentButton];
    [self addSubview:self.snapButton];
    [self addSubview:self.sharedButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.line.frame = CGRectMake(6.0, 0, self.width - 6.0 * 2, 1.0);
    
    self.commentBtn.frame = CGRectMake(self.line.left,
                                       self.line.bottom + 10.0,
                                       35.0,
                                       35.0);
    
    self.sharedButton.frame = CGRectMake(self.line.right - 35.0 - 10.0,
                                         self.commentBtn.top,
                                         35.0,
                                         35.0);
    
    self.snapButton.frame = CGRectMake(self.sharedButton.left - 35.0 - 10.0,
                                       self.commentBtn.top,
                                       35.0,
                                       35.0);
    
    self.presentButton.frame = CGRectMake(self.snapButton.left - 35.0 - 10.0,
                                          self.commentBtn.top,
                                          35.0,
                                          35.0);
}

#pragma mark - action
- (void)onAction:(UIButton *)btn
{
    switch (btn.tag)
    {
        case NTESBottomActionTypeComment:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(bottomBarClickComment:)]) {
                [_delegate bottomBarClickComment:self];
            }
            break;
        }
        case NTESBottomActionTypePresent:
        {
            [self.presentShop showPresentShop:_presents];
            
            break;
        }
        case NTESBottomActionTypeShare:
        {
            [self.shareMenuView show];
            
            break;
        }
        case NTESBottomActionTypeSnap:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(bottomBarClickSnap:)]) {
                [_delegate bottomBarClickSnap:self];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - getter/setter
- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor blackColor];
    }
    return _line;
}

- (UIButton *)commentBtn
{
    if (!_commentBtn)
    {
        _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _commentBtn.tag = NTESBottomActionTypeComment;
        [_commentBtn setImage:[UIImage imageNamed:@"message_btn_n"] forState:UIControlStateNormal];
        [_commentBtn setImage:[UIImage imageNamed:@"message_btn_p"] forState:UIControlStateHighlighted];
        [_commentBtn addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentBtn;
}

- (UIButton *)sharedButton
{
    if (!_sharedButton) {
        _sharedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sharedButton.tag = NTESBottomActionTypeShare;
        [_sharedButton setImage:[UIImage imageNamed:@"share_btn_n"] forState:UIControlStateNormal];
        [_sharedButton setImage:[UIImage imageNamed:@"share_btn_p"] forState:UIControlStateHighlighted];
        [_sharedButton addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sharedButton;
}

- (UIButton *)presentButton
{
    if (!_presentButton) {
        _presentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _presentButton.tag = NTESBottomActionTypePresent;
        [_presentButton setImage:[UIImage imageNamed:@"gift_btn_n"] forState:UIControlStateNormal];
        [_presentButton setImage:[UIImage imageNamed:@"gift_btn_p"] forState:UIControlStateHighlighted];
        [_presentButton addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _presentButton;
}

- (UIButton *)snapButton
{
    if (!_snapButton) {
        _snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _snapButton.tag = NTESBottomActionTypeSnap;
        [_snapButton setImage:[UIImage imageNamed:@"screenshots_btn_n"] forState:UIControlStateNormal];
        [_snapButton setImage:[UIImage imageNamed:@"screenshots_btn_p"] forState:UIControlStateHighlighted];
        [_snapButton addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _snapButton;
}

- (NTESPresentShopView *)presentShop
{
    if (!_presentShop) {
        _presentShop = [[NTESPresentShopView alloc] init];
        _presentShop.delegate = self;
    }
    return _presentShop;
}

- (NTESMenuView *)shareMenuView
{
    if (!_shareMenuView) {
        _shareMenuView = [[NTESMenuView alloc] initWithType:NTESMenuTypeShare];
        _shareMenuView.delegate = self;
    }
    return _shareMenuView;
}

- (void)setHiddenSnap:(BOOL)hiddenSnap
{
    _hiddenSnap = hiddenSnap;
    
    self.snapButton.hidden = hiddenSnap;
}

- (void)setPresents:(NSArray *)presents
{
    _presents = presents;
    
    self.presentShop.presents = presents;
}

#pragma mark - Public
- (void)dismissPresentShop
{
    [self.presentShop dismiss];
}

#pragma mark -- <NTESPresentShopViewDelegate>
//发送礼物
- (void)didSelectPresent:(NTESPresent *)present
{
    if (_delegate && [_delegate respondsToSelector:@selector(bottomBar:sendPresent:)]) {
        [_delegate bottomBar:self sendPresent:present];
    }
}

#pragma mark -- <NTESMenuViewProtocol>
- (void)menuView:(NTESMenuView *)menu didSelect:(NSInteger)index
{
    if (menu == self.shareMenuView)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(bottomBar:selectShareUrl:)]) {
            [_delegate bottomBar:self selectShareUrl:index];
        }
    }
}

@end
