//
//  NTESArrangeView.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/5/27.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"
#import "NTESSlider.h"

@class NTESArrangeView;
@protocol NTESArrangeViewDelegate <NSObject>

//亮度
- (void)ArrangeView:(NTESArrangeView *)arrangeView brightValueChanged:(CGFloat)brightness;
//对比度
- (void)ArrangeView:(NTESArrangeView *)arrangeView contrastValueChanged:(CGFloat)contrast;
//饱和度
- (void)ArrangeView:(NTESArrangeView *)arrangeView saturateValueChanged:(CGFloat)saturation;
//色温
- (void)ArrangeView:(NTESArrangeView *)arrangeView tempValueChanged:(CGFloat)temperature;
//锐度
- (void)ArrangeView:(NTESArrangeView *)arrangeView sharpValueChanged:(CGFloat)sharpness;

@end

@interface NTESArrangeView : NTESBaseView

@property(nonatomic, weak) id<NTESArrangeViewDelegate> delegate;

@property(nonatomic, strong) NTESSlider *bright_slider;
@property(nonatomic, strong) NTESSlider *contr_slider;
@property(nonatomic, strong) NTESSlider *saturation_slider;
@property(nonatomic, strong) NTESSlider *temp_slider;
@property(nonatomic, strong) NTESSlider *sharp_slider;

@end
