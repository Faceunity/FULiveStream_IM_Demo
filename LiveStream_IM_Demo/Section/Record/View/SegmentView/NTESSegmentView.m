//
//  NTESSegmentView.m
//  ShortVideo_Demo
//
//  Created by Netease on 17/2/16.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESSegmentView.h"

const CGFloat gIntervalWidth = 2;

@interface NTESSegmentView ()

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) NSMutableArray *intervalViews;

@property (nonatomic, strong) NSMutableArray *segmentViews;

@property (nonatomic, assign) BOOL needLayout;

@end

@implementation NTESSegmentView

- (void)doInit
{
    [self addSubview:self.lineView];
    self.clipsToBounds = NO;
    self.backgroundColor = [UIColor clearColor];
    _intervalViews = [NSMutableArray array];
    _segmentViews = [NSMutableArray array];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.lineView.width != self.width)
    {
        self.lineView.frame = CGRectMake(0, 0, self.width, 1);
        self.lineView.centerY = self.height/2;
        [self drawDashLine:self.lineView lineColor:[UIColor whiteColor]];
    }
    
    CGFloat segmentLength = self.width/_numbers;
    
    //布局interval
    for (UIView *view in _intervalViews)
    {
        NSInteger index = [_intervalViews indexOfObject:view];
        CGFloat x = segmentLength * (index + 1) + gIntervalWidth * index;
        view.frame = CGRectMake(x, -2, gIntervalWidth, self.height+4);
    }
    
    //布局segment
    for (UIView *view in _segmentViews)
    {
        NSInteger index = [_segmentViews indexOfObject:view];
        CGFloat x = (segmentLength + gIntervalWidth) * index;
        view.frame = CGRectMake(x, 2, segmentLength, self.height - 4);
    }


    if (_needLayout)
    {
        //显示interval
        [self showIntervalView];
        
        _needLayout = NO;
    }
}

- (void)setupIntervalViewsWithNumber:(NSInteger)number
{
    if (number < 1)
    {
        return;
    }
    
    NSInteger intervalCount = number - 1;
    
    //清空数组
    for (UIView *view in _intervalViews) {
        [view removeFromSuperview];
    }
    [_intervalViews removeAllObjects];
    
    for (NSInteger index = 0; index < intervalCount; index++)
    {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = gIntervalWidth/2;
        view.hidden = YES;
        [_intervalViews addObject:view];
        [self addSubview:view];
    }
}

- (void)setupSegmentViewsWithNumber:(NSInteger)number
{
    if (number < 0)
    {
        return;
    }
    
    //清空数组
    for (UIView *view in _segmentViews) {
        [view removeFromSuperview];
    }
    [_segmentViews removeAllObjects];
    
    for (NSInteger index = 0; index < number; index++)
    {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = UIColorFromRGB(0x2084ff);
        view.hidden = !(index < _selectCount);
        [_segmentViews addObject:view];
        [self addSubview:view];
    }
}

- (void)showIntervalView
{
    for (UIView *view in _intervalViews) {
        view.hidden = NO;
        
        [UIView animateWithDuration:0.15 animations:^{
            view.transform = CGAffineTransformMakeScale(2, 2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                view.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

- (void)drawDashLine:(UIView *)lineView lineColor:(UIColor *)lineColor
{
    if (_shapeLayer) {
        [_shapeLayer removeFromSuperlayer];
    }
    
    _shapeLayer = [CAShapeLayer layer];
    [_shapeLayer setBounds:lineView.bounds];
    [_shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    [_shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [_shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [_shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [_shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [_shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:2.0], [NSNumber numberWithInt:4.0], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL,CGRectGetWidth(lineView.frame), 0);
    [_shapeLayer setPath:path];
    CGPathRelease(path);
    //把绘制好的虚线添加上来
    [lineView.layer addSublayer:_shapeLayer];
}

#pragma mark - Setter/Getter
- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor clearColor];
    }
    return _lineView;
}

- (void)setNumbers:(NSInteger)numbers
{
    _numbers = numbers;
    
    if (numbers != 0)
    {
        [self setupIntervalViewsWithNumber:numbers];
        
        [self setupSegmentViewsWithNumber:numbers];
        
        self.needLayout = YES;
        
        [self setNeedsLayout];
    }
}

- (void)setSelectCount:(NSInteger)selectCount
{
    _selectCount = selectCount;
    
    [_segmentViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = (UIView *)obj;
        view.hidden = !(idx < selectCount);
    }];
}

@end
