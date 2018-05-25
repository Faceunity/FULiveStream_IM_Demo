//
//  NTESVideoEditView.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/5/27.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"

@class NTESVideoEditView;
@protocol NTESVideoEditViewDelegate <NSObject>

//亮度
- (void)editView:(NTESVideoEditView *)editView brightnessValue:(CGFloat)brightness;
//对比度
- (void)editView:(NTESVideoEditView *)editView contrastValue:(CGFloat)contrast;
//饱和度
- (void)editView:(NTESVideoEditView *)editView saturationValue:(CGFloat)saturation;
//色温
- (void)editView:(NTESVideoEditView *)editView temperatureValue:(CGFloat)temperature;
//锐度
- (void)editView:(NTESVideoEditView *)editView sharpnessValue:(CGFloat)sharpness;
//原声大小
- (void)editView:(NTESVideoEditView *)editView audioValue:(CGFloat)audioValue;
//过渡效果
- (void)editView:(NTESVideoEditView *)editView hasFade:(BOOL)hasFaded;
//前移
- (void)editView:(NTESVideoEditView *)editView switchForward:(NSInteger)pos;
//后移
- (void)editView:(NTESVideoEditView *)editView switchBackward:(NSInteger)pos;
//贴图
- (void)editView:(NTESVideoEditView *)editView selectedTexture:(NSInteger)index;
//显示贴图时间
- (void)editView:(NTESVideoEditView *)editView showTextureFromTime:(CGFloat)startTime toTime:(CGFloat)endTime;
//伴音
- (void)editView:(NTESVideoEditView *)editView selectedAudio:(NSInteger)index;
//原声比例
- (void)editView:(NTESVideoEditView *)editView mainVolume:(CGFloat)mainVolume;
//选择文字
- (void)editView:(NTESVideoEditView *)editView selectText:(NSInteger)textIndex;
//选择颜色
- (void)editView:(NTESVideoEditView *)editView selectTextColor:(NSInteger)colorType;

@end


@interface NTESVideoEditView : NTESBaseView

@property(nonatomic, weak) id<NTESVideoEditViewDelegate> delegate;

@property(nonatomic, strong) NSArray<NSString *> *filePaths;

- (instancetype)initWithFrame:(CGRect)frame filePaths:(NSArray<NSString *> *)filePaths;

@end
