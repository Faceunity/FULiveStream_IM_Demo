//
//  NTESMuteView.m
//  NEUIDemo
//
//  Created by Netease on 17/1/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESMuteView.h"
#import "NTESMuteBar.h"

@interface NTESMuteView ()

@property (nonatomic, strong) NTESMuteBar *bar;

@end

@implementation NTESMuteView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addTarget:self action:@selector(onTapBackground:) forControlEvents:UIControlEventTouchUpInside];
        
        self.frame = [UIScreen mainScreen].bounds;
        _bar = [NTESMuteBar instancView];
        _bar.frame = CGRectMake(0, self.height, self.width, 200.0);
        
        __weak typeof(self) weakSelf = self;
        _bar.kickBlock = ^(NTESMember *user) {
        
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf dismiss];
            
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(muteView:kick:)]) {
                [strongSelf.delegate muteView:strongSelf kick:user];
            }
        };
        
        _bar.muteBlock = ^(NTESMember *user) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf dismiss];
            
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(muteView:mute:)]) {
                [strongSelf.delegate muteView:strongSelf mute:user];
            }
        };
        [self addSubview:_bar];
    }
    return self;
}

- (void)onTapBackground:(id)sender
{
    [self dismiss];
}


#pragma mark - Public
- (void)showWithUserInfo:(NTESMember *) userInfo
{
    self.bar.userInfo = userInfo;
    
    [self show];
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


@end
