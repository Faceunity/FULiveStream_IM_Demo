//
//  NTESUpdateProcessView.m
//  NTESUpadateUI
//
//  Created by Netease on 17/2/27.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateProcessView.h"

@interface NTESUpdateProcessView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation NTESUpdateProcessView


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
    self.clipsToBounds = YES;
    self.backgroundColor = UIColorFromRGB(0xd7dce0);
    [self.layer addSublayer:self.gradientLayer];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    if (self.layer.frame.size.height != _gradientLayer.frame.size.height) {
        self.layer.cornerRadius = self.layer.frame.size.height/2;
        _gradientLayer.cornerRadius = self.layer.frame.size.height/2;
        
        _gradientLayer.frame = CGRectMake(0,
                                          0,
                                          self.layer.frame.size.width * _progress,
                                          self.layer.frame.size.height);
    }
}

- (void)adjustFrame
{
    CGRect tempRect = [_gradientLayer frame];
    tempRect.size.width = CGRectGetWidth(self.layer.bounds) * self.progress;
    _gradientLayer.frame = tempRect;
}

#pragma mark - Setter
- (void)setProgress:(CGFloat)progress
{
    if (_progress != progress)
    {
        _progress = MIN(1.0, fabs(progress));
        [self adjustFrame];
    }
}

#pragma mark - Getter
- (CAGradientLayer *)gradientLayer
{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        [_gradientLayer setStartPoint:CGPointMake(0.0, 0.5)];
        [_gradientLayer setEndPoint:CGPointMake(1.0, 0.5)];
        
        NSArray *colors = @[(id)UIColorFromRGB(0x73ebf3).CGColor,
                            (id)UIColorFromRGB(0x63adf8).CGColor,
                            (id)UIColorFromRGB(0x238efa).CGColor];
        [_gradientLayer setColors:colors];
    }
    return _gradientLayer;
}

@end
