//
//  NTESTrimBorder.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESTrimBorder.h"

@implementation NTESTrimBorder

- (void)drawRect:(CGRect)rect {
//    //白色圆角矩形
//    CGFloat width = rect.size.width;
//    CGFloat height = rect.size.height;
//    
//    //这里取平均值1/10
//    CGFloat radius = 6.;
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    //移动初始点位置
//    CGContextMoveToPoint(context, radius, 0);
//    
//    //画第一条线和第一个1/4圆弧
//    CGContextAddLineToPoint(context, width - radius, 0);
//    CGContextAddArc(context, width - radius, radius, radius, - M_PI / 2, 0., 0);
//    
//    //画第二条线和第二个圆弧
//    CGContextAddLineToPoint(context, width, height - radius);
//    CGContextAddArc(context, width - radius, height - radius, radius, 0., M_PI / 2, 0);
//
//    //画第三条线和第三个圆弧
//    CGContextAddLineToPoint(context, radius, height);
//    CGContextAddArc(context, radius, height - radius, radius, M_PI / 2, M_PI, 0);
//    
//    //画第4条线和第四个圆弧
//    CGContextAddLineToPoint(context, 0, radius);
//    CGContextAddArc(context, radius, radius, radius, M_PI, 1.5 * M_PI, 0);
//
//    CGContextClosePath(context);
//    
//    CGContextSetLineWidth(context, 4.0);//线的宽度
//    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
//    CGContextSetRGBFillColor(context, 1, 1, 1, 0.);
//
//    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    // 线的宽度
    
    CGFloat lineWidth = 4.f;
    
    // 根据线的宽度 设置画线的位置
    
    CGRect rect1 =  CGRectMake(lineWidth * 0.5, lineWidth * 0.5, rect.size.width - lineWidth , rect.size.height - lineWidth);
    
    // 获取图像上下文
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 设置线的宽度
    
    CGContextSetLineWidth(context, lineWidth);
    
    // 设置线的颜色
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
//    // 设置虚线和实线的长度
//    
//    CGFloat lengths[] = { 2.5, 1.5 };
//    
//    CGContextSetLineDash(context, 0, lengths,1);
    
    // CGContextSetLineDash(context, 0, lengths, 1);
    
    // 画矩形path 圆角5度
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect1 cornerRadius:4];
    
    // 添加到图形上下文
    
    CGContextAddPath(context, bezierPath.CGPath);
    
    // 渲染
    
    CGContextStrokePath(context);
}

@end
