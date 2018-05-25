//
//  NTESCircleView.m
//  HWProgress
//
//  Created by sxmaps_w on 2017/3/3.
//  Copyright © 2017年 hero_wqb. All rights reserved.
//

#import "NTESCircleView.h"

#define KHWCircleLineWidth 2.0f

@interface NTESCircleView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UILabel *cLabel;

@end

@implementation NTESCircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        
        //百分比标签
        [self addSubview:self.cLabel];
    }
    
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    if (progress < 0 ) {
        progress = 0.0;
    }
    if (progress > 1.0) {
        progress = 1.0;
    }
    
    _progress = progress;
    
    _cLabel.text = [NSString stringWithFormat:@"%d%%", (int)floor(progress * 100)];
    
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _cLabel.frame = self.bounds;
}

- (void)drawRect:(CGRect)rect
{
    //路径
    UIBezierPath *path = [[UIBezierPath alloc] init];
    //线宽
    path.lineWidth = KHWCircleLineWidth;
    //颜色
    [[UIColor whiteColor] set];
    //拐角
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    //半径
    CGFloat radius = (MIN(rect.size.width, rect.size.height) - KHWCircleLineWidth) * 0.5;
    //画弧（参数：中心、半径、起始角度(3点钟方向为0)、结束角度、是否顺时针）
    [path addArcWithCenter:(CGPoint){rect.size.width * 0.5, rect.size.height * 0.5} radius:radius startAngle:M_PI * 1.5 endAngle:M_PI * 1.5 + M_PI * 2 * _progress clockwise:YES];
    //连线
    [path stroke];
}

#pragma mark - Getter
- (UILabel *)cLabel
{
    if (!_cLabel) {
        _cLabel = [[UILabel alloc] init];
        _cLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _cLabel.textColor = [UIColor whiteColor];
        _cLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _cLabel;
}

@end

