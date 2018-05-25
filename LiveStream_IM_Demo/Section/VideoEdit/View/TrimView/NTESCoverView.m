//
//  NTESCoverView.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESCoverView.h"
#import "NTESTrimBorder.h"

#define thumborderWidth 158
#define thumborderHeight 42

@interface NTESCoverView ()

@property(nonatomic, strong) NTESTrimBorder *thumbBorder;

@property(nonatomic, strong) UILabel *durationLabel;
@property(nonatomic, assign) CGFloat thumWidth;
@property(nonatomic, assign) CGFloat duration;

@end


@implementation NTESCoverView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame duration:3.3];
}

- (instancetype)initWithFrame:(CGRect)frame duration:(CGFloat)duration {
    if (self = [super initWithFrame:frame]) {
        self.duration = duration;
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.thumWidth = 4;
    
    //FIX ME:trimmer view这里有问题
//    _thumbBorder = ({
//        NTESTrimBorder *border = [[NTESTrimBorder alloc] initWithFrame:CGRectMake(0, 0, thumborderWidth, thumborderHeight)];
//        border.contentMode = UIViewContentModeCenter;
//        border;
//    });
//    [self addSubview:self.thumbBorder];
    
    self.durationLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-2, -1, self.width + 4, self.height + 2)];
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.layer.borderWidth = 4;
        label.layer.cornerRadius = 4;
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:@"%.1fs", self.duration];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:14.f];
        label;
    });
    [self addSubview:self.durationLabel];
    
}

#pragma mark - hit test
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    //用于传递scrollview 滑动事件
    return nil;
}

@end
