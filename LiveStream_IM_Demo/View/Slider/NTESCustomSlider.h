//
//  NTESCustomSlider.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/23.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  一个可以提供单滑动、双滑动、根据步长滑动的UISlider
 */

@interface NTESCustomSlider : UIControl

@property(nonatomic, assign) CGFloat minimumValue;//default is 0.0

@property(nonatomic, assign) CGFloat maximumValue;//dafault is 1.0

@property(nonatomic, assign) CGFloat minimumRange;//default is 0.0,最大值最小值之间间距

@property(nonatomic, assign) CGFloat stepValue;

@property(nonatomic, assign) BOOL stepValueContinuously;

@property(nonatomic, assign) BOOL continuous;//默认是YES，表示没有步长滑动，是连续滑动

@property(nonatomic, assign) CGFloat lowerValue;

@property(nonatomic, assign) CGFloat upperValue;

@property(nonatomic, readonly) CGPoint lowerCenter;

@property(nonatomic, readonly) CGPoint upperCenter;

@property(nonatomic, assign) CGFloat lowerMaximumValue;

@property(nonatomic, assign) CGFloat upperMinimumValue;

@property(nonatomic, assign) UIEdgeInsets lowerTouchEdgeInsets;

@property(nonatomic, assign) UIEdgeInsets upperTouchEdgeInsets;

@property(nonatomic, assign) BOOL lowerHandleHidden;

@property(nonatomic, assign) BOOL upperHandleHidden;

@property (assign, nonatomic) float lowerHandleHiddenWidth;
@property (assign, nonatomic) float upperHandleHiddenWidth;

@property(strong, nonatomic) UIImage* lowerHandleImageNormal;
@property(strong, nonatomic) UIImage* lowerHandleImageHighlighted;

@property(strong, nonatomic) UIImage* upperHandleImageNormal;
@property(strong, nonatomic) UIImage* upperHandleImageHighlighted;

@property(strong, nonatomic) UIImage* trackImage;

// track image when lower value is higher than the upper value (eg. when minimum range is negative
@property(strong, nonatomic) UIImage* trackCrossedOverImage;

@property(strong, nonatomic) UIImage* trackBackgroundImage;

@property (strong, nonatomic) UIImageView* lowerHandle;
@property (strong, nonatomic) UIImageView* upperHandle;

- (void)addSubViews;

- (void)setLowerValue:(CGFloat)lowerValue animated:(BOOL)animated;

- (void)setUpperValue:(CGFloat)upperValue animated:(BOOL)animated;

- (void)setLowerValue:(CGFloat)lowerValue upperValue:(CGFloat)upperValue animated:(BOOL)animated;

@end
