//
//  NTESAnchorBottomBar.m
//  NEUIDemo
//
//  Created by Netease on 17/1/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAnchorBottomBar.h"
#import "NTESMenuView.h"

typedef NS_ENUM(NSInteger,NTESAnchorBottomActionType)
{
    NTESAnchorBottomActionTypeComment = 1000, //点评论按钮
    NTESAnchorBottomActionTypeFilter, //滤镜
    NTESAnchorBottomActionTypeAudio,  //伴音
    NTESAnchorBottomActionTypeShare,  //分享
    NTESAnchorBottomActionTypeSnap,   //截屏
};

@interface NTESAnchorBottomBar ()<NTESMenuViewProtocol>

@property (nonatomic, strong) UIView *line; //分割线
@property (nonatomic, strong) UIButton *commentBtn; //评论按钮
@property (nonatomic, strong) UIButton *filterButton; //礼物按钮
@property (nonatomic, strong) UIButton *audioButton;  //伴音按钮
@property (nonatomic, strong) UIButton *snapButton;   //截屏按钮
@property (nonatomic, strong) UIButton *sharedButton; //分享按钮
@property (nonatomic, strong) NTESMenuView *filterMenuView; //滤镜选择框
@property (nonatomic, strong) NTESMenuView *audioMenuView; //伴音选择框
@property (nonatomic, strong) NTESMenuView *shareMenuView; //分享选择框
@end

@implementation NTESAnchorBottomBar

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
    [self addSubview:self.filterButton];
    [self addSubview:self.audioButton];
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

    self.sharedButton.frame = CGRectMake(self.right - 35.0 - 10.0,
                                         self.commentBtn.top,
                                         35.0,
                                         35.0);
    
    self.snapButton.frame = CGRectMake(self.sharedButton.left - 35.0 - 10.0,
                                       self.commentBtn.top,
                                       35.0,
                                       35.0);
    
    self.audioButton.frame = CGRectMake(self.snapButton.left - 35.0 - 10.0,
                                        self.commentBtn.top,
                                        35.0,
                                        35.0);
    self.filterButton.frame = CGRectMake(self.audioButton.left - 35.0 - 10,
                                         self.commentBtn.top,
                                         35.0,
                                         35.0);
}

#pragma mark - Action
- (void)onAction:(UIButton *)btn
{
    switch (btn.tag)
    {
        case NTESAnchorBottomActionTypeComment:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(bottomBarClickComment:)]) {
                [_delegate bottomBarClickComment:self];
            }
            break;
        }
        case NTESAnchorBottomActionTypeFilter:
        {
            NSLog(@"点击滤镜");
            [self.filterMenuView show];
            break;
        }
        case NTESAnchorBottomActionTypeAudio:
        {
            NSLog(@"点击伴音");
            [self.audioMenuView show];
            break;
        }
        case NTESAnchorBottomActionTypeShare:
        {
            NSLog(@"点击分享");
            [self.shareMenuView show];
            break;
        }
        case NTESAnchorBottomActionTypeSnap:
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

#pragma mark - Getter/Setter
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
        _commentBtn.tag = NTESAnchorBottomActionTypeComment;
        [_commentBtn setImage:[UIImage imageNamed:@"message_btn_n"] forState:UIControlStateNormal];
        [_commentBtn setImage:[UIImage imageNamed:@"message_btn_p"] forState:UIControlStateHighlighted];
        [_commentBtn addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentBtn;
}

- (UIButton *)filterButton
{
    if (!_filterButton)
    {
        _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _filterButton.tag = NTESAnchorBottomActionTypeFilter;
        [_filterButton setImage:[UIImage imageNamed:@"美颜滤镜_n"] forState:UIControlStateNormal];
        [_filterButton setImage:[UIImage imageNamed:@"美颜滤镜_p"] forState:UIControlStateHighlighted];
        [_filterButton addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterButton;
}

- (UIButton *)audioButton
{
    if (!_audioButton)
    {
        _audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _audioButton.tag = NTESAnchorBottomActionTypeAudio;
        [_audioButton setImage:[UIImage imageNamed:@"music_btn_n"] forState:UIControlStateNormal];
        [_audioButton setImage:[UIImage imageNamed:@"music_btn_p"] forState:UIControlStateHighlighted];
        [_audioButton addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _audioButton;
}

- (UIButton *)snapButton
{
    if (!_snapButton) {
        _snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _snapButton.tag = NTESAnchorBottomActionTypeSnap;
        [_snapButton setImage:[UIImage imageNamed:@"screenshots_btn_n"] forState:UIControlStateNormal];
        [_snapButton setImage:[UIImage imageNamed:@"screenshots_btn_p"] forState:UIControlStateHighlighted];
        [_snapButton addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _snapButton;
}

- (UIButton *)sharedButton
{
    if (!_sharedButton) {
        _sharedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sharedButton.tag = NTESAnchorBottomActionTypeShare;
        [_sharedButton setImage:[UIImage imageNamed:@"share_btn_n"] forState:UIControlStateNormal];
        [_sharedButton setImage:[UIImage imageNamed:@"share_btn_p"] forState:UIControlStateHighlighted];
        [_sharedButton addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sharedButton;
}

- (NTESMenuView *)filterMenuView
{
    if (!_filterMenuView) {
        _filterMenuView = [[NTESMenuView alloc] initWithType:NTESMenuTypeFilter];
        _filterMenuView.selectedIndex = 0;
        _filterMenuView.delegate = self;
    }
    return _filterMenuView;
}

- (NTESMenuView *)audioMenuView
{
    if (!_audioMenuView) {
        _audioMenuView = [[NTESMenuView alloc] initWithType:NTESMenuTypeAudio];
        _audioMenuView.selectedIndex = 0;
        _audioMenuView.delegate = self;
    }
    return _audioMenuView;
}

- (NTESMenuView *)shareMenuView
{
    if (!_shareMenuView) {
        _shareMenuView = [[NTESMenuView alloc] initWithType:NTESMenuTypeShare];
        _shareMenuView.delegate = self;
    }
    return _shareMenuView;
}

- (void)setHiddenFilter:(BOOL)hiddenFilter
{
    _hiddenFilter = hiddenFilter;
    
    self.filterButton.hidden = hiddenFilter;
}

- (void)setHiddenSnap:(BOOL)hiddenSnap
{
    _hiddenSnap = hiddenSnap;
    
    self.snapButton.hidden = hiddenSnap;
}

#pragma mark - Public
- (void)setSelectedFilter:(NSInteger)selectedFilter
{
    self.filterMenuView.selectedIndex = selectedFilter;
    
    _selectedFilter = selectedFilter;
}

- (void)dismissChooseMenu
{
    [self.filterMenuView dismiss];
    [self.audioMenuView dismiss];
}

#pragma mark -- <NTESMenuViewProtocol>
- (void)menuView:(NTESMenuView *)menu didSelect:(NSInteger)index
{
    if (menu == self.filterMenuView)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(bottomBar:selectFilter:)]) {
            [_delegate bottomBar:self selectFilter:index];
        }
    }
    else if (menu == self.audioMenuView)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(bottomBar:selectAudio:)]) {
            [_delegate bottomBar:self selectAudio:index];
        }
    }
    else if (menu == self.shareMenuView)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(bottomBar:selectShareUrl:)]) {
            [_delegate bottomBar:self selectShareUrl:index];
        }
    }
}

@end
