//
//  UIButton+Captcha.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/29.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "UIButton+Captcha.h"
#import <objc/runtime.h>

static NSString *timerkey = @"timerKey";

@implementation UIButton (Captcha)

- (void)setTimer:(dispatch_source_t)timer {
    objc_setAssociatedObject(self, &timerkey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (dispatch_source_t)timer {
    return objc_getAssociatedObject(self, &timerkey);
}

- (void)startTimeAtCaptchaButton {
    __block int timeout = 60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(self.timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    WEAK_SELF(weakSelf);
    dispatch_source_set_event_handler(self.timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(weakSelf.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                STRONG_SELF(strongSelf);
                [strongSelf setTitle:@"获取验证码" forState:UIControlStateNormal];
                strongSelf.contentMode = UIViewContentModeLeft;
                strongSelf.userInteractionEnabled = YES;
            });
        }else{
            int seconds = timeout % 61;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                STRONG_SELF(strongSelf);
                [strongSelf setTitle:[NSString stringWithFormat:@"剩余%@秒",strTime] forState:UIControlStateNormal];
                strongSelf.contentMode = UIViewContentModeCenter;
                strongSelf.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(self.timer);
}

- (void)releaseTimeAtCaptchaButton {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
        WEAK_SELF(weakSelf);
        dispatch_async(dispatch_get_main_queue(), ^{
            STRONG_SELF(strongSelf);
            [strongSelf setTitle:@"获取验证码" forState:UIControlStateNormal];
            strongSelf.userInteractionEnabled = YES;
        });
    }
}


@end
