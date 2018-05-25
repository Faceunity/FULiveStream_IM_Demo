//
//  NTESSlider.h
//  NTESSlider
//
//  Created by Netease on 17/4/18.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESSliderControl.h"

typedef void(^NTESSliderValueChanged)(CGFloat value);

@interface NTESSlider : UIView

@property (nonatomic, assign) CGFloat value;

@property(nonatomic, assign) CGFloat default_value;

@property (nonatomic, assign) NTESValueStyle valueStyle;

@property (nonatomic, assign) CGFloat maxValue;

@property (nonatomic, assign) CGFloat minValue;

@property (nonatomic, strong) UIImage *thumbImage;

@property (nonatomic, strong) UIImage *minThrackImage;

@property (nonatomic, strong) UIImage *maxThrackImage;

@property (nonatomic, strong) UIImage *minValueImg;

@property (nonatomic, strong) UIImage *maxValueImg;

@property (nonatomic, assign) CGFloat trackWidth;

@property (nonatomic, assign) CGSize thumbSize;

@property(nonatomic, strong) UIColor *trackColor;


@property (nonatomic, copy) NTESSliderValueChanged valueChangedBlock;

@property (nonatomic, copy) NTESSliderValueChanged valueEndChangeBlock;

@end
