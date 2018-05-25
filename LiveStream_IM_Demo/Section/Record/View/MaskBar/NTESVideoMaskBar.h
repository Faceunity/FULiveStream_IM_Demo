//
//  NTESVideoMaskBar.h
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/4/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESSlider.h"

@protocol NTESVideoMaskBarDelegate;

@interface NTESVideoMaskBar : UIControl

@property (nonatomic, assign) CGFloat exposureValue;

@property (nonatomic, strong) NTESSlider *exposureSlider; //曝光滑杆

@property (nonatomic, strong) NTESSlider *zoomSlider; //变焦滑杆

@property (nonatomic, strong) UIImageView *focusImgView;

@property (nonatomic, weak) id <NTESVideoMaskBarDelegate> delegate;

@end


@protocol NTESVideoMaskBarDelegate <NSObject>

@optional

- (void)MaskBar:(NTESVideoMaskBar *)bar exposureValueChanged:(CGFloat)exposure;

- (void)MaskBar:(NTESVideoMaskBar *)bar focusInPoint:(CGPoint)point;

- (void)MaskBar:(NTESVideoMaskBar *)bar zoomChanged:(CGFloat)zoom;

@end
