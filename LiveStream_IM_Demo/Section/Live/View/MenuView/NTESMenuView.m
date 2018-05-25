//
//  NTESMenuView.m
//  NEUIDemo
//
//  Created by Netease on 17/1/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESMenuView.h"
#import "NTESAudioMenuBar.h"
#import "NTESFilterMenuBar.h"
#import "NTESShareMenuBar.h"

@interface NTESMenuView ()
@property (nonatomic, assign) NTESMenuType type;
@property (nonatomic, strong) NTESAudioMenuBar *audioBar;
@property (nonatomic, strong) NTESFilterMenuBar *filterBar;
@property (nonatomic, strong) NTESShareMenuBar *shareBar;
@property (nonatomic, strong) NTESMenuBaseBar *bar;
@end

@implementation NTESMenuView

- (instancetype)initWithType:(NTESMenuType)type
{
    if (self = [super init])
    {
        _type = type;
        
        self.frame = [UIScreen mainScreen].bounds;
        
        [self addTarget:self action:@selector(onTapBackground:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:self.bar];
    }
    return self;
}


- (void)onTapBackground:(id)sender
{
    [self dismiss];
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    self.bar.top = self.height;
    [UIView animateWithDuration:0.25 animations:^{
        self.bar.bottom = self.height;
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bar.top = self.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Getter/Setter
- (UIView *)bar
{
    switch (_type)
    {
        case NTESMenuTypeFilter:
        {
            return self.filterBar;
            break;
        }
        case NTESMenuTypeAudio:
        {
            return self.audioBar;
        }
        case NTESMenuTypeShare:
        {
            return self.shareBar;
        }
        default:
        {
            return [[UIView alloc] initWithFrame:CGRectZero];
        }
    }
}

- (NTESAudioMenuBar *)audioBar
{
    if (!_audioBar)
    {
        _audioBar = [[NTESAudioMenuBar alloc] init];
        _audioBar.frame = CGRectMake(0, self.height, self.width, _audioBar.barHeight);
        
        __weak typeof(self) weakSelf = self;
        _audioBar.selectBlock = ^(NSInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //选择回调
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(menuView:didSelect:)]) {
                [strongSelf.delegate menuView:strongSelf didSelect:index];
            }
        };
    }
    return _audioBar;
}

- (NTESFilterMenuBar *)filterBar
{
    if (!_filterBar)
    {
        _filterBar = [[NTESFilterMenuBar alloc] init];
        _filterBar.frame = CGRectMake(0, self.height, self.width, _filterBar.barHeight);
        
        __weak typeof(self) weakSelf = self;
        _filterBar.selectBlock = ^(NSInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //选择回调
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(menuView:didSelect:)]) {
                [strongSelf.delegate menuView:strongSelf didSelect:index];
            }
        };
    }
    return _filterBar;
}

- (NTESShareMenuBar *)shareBar
{
    if (!_shareBar)
    {
        _shareBar = [[NTESShareMenuBar alloc] init];
        _shareBar.frame = CGRectMake(0, self.height, self.width, _shareBar.barHeight);
        
        __weak typeof(self) weakSelf = self;
        _shareBar.selectBlock = ^(NSInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            //选择回调
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(menuView:didSelect:)]) {
                [strongSelf.delegate menuView:strongSelf didSelect:index];
                
                [strongSelf dismiss];
            }
        };
        
        _shareBar.cancelBlock = ^(){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf dismiss];
        };
    }
    return _shareBar;
}


- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    self.bar.selectedIndex = selectedIndex;
    _selectedIndex = selectedIndex;
}

@end

