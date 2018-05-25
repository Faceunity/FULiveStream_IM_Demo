//
//  NTESSliderControl.h
//  NTESSliderControl
//
//  Created by Netease on 17/4/18.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NTESValueStyle) //状态
{
    NTESValueStyleNone = 0,  //无
    NTESValueStyleInteger,   //整型
    NTESValueStyleSignal,    //单精度
    NTESValueStyleFocus,    //对焦数字
};

typedef void(^NTESSliderControlValueChanged)(CGFloat value);

@interface NTESSliderControl : UIControl

@property(nonatomic, assign) CGFloat defalut_value;

@property (nonatomic, assign) CGFloat value;

@property (nonatomic, assign) NTESValueStyle valueStyle;

@property (nonatomic, assign) CGFloat maxValue;

@property (nonatomic, assign) CGFloat minValue;

@property (nonatomic, strong) UIImage *thumbImage;

@property (nonatomic, strong) UIImage *minThrackImage;

@property (nonatomic, strong) UIImage *maxThrackImage;

@property (nonatomic, assign) CGFloat trackWidth;

@property (nonatomic, assign) CGSize thumbSize;

@property(nonatomic, strong) UIColor *trackColor;

@property (nonatomic, strong) UILabel *thumbLab;

@property (nonatomic, copy) NTESSliderControlValueChanged valueBlock;

@property (nonatomic, copy) NTESSliderControlValueChanged valueEndChangeBlock;

@end
