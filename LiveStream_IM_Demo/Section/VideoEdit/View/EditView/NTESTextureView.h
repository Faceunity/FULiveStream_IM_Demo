//
//  NTESTextureView.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/5/27.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"

@class NTESTextureView;

@protocol NTESTextureViewDelegate <NSObject>

- (void)textureView:(NTESTextureView *)textureView selectTexture:(NSInteger)index;

- (void)textureView:(NTESTextureView *)textureView showTimeFrom:(CGFloat)startTime toTime:(CGFloat)endTime;

@end

@interface NTESTextureView : NTESBaseView

@property(nonatomic, weak) id<NTESTextureViewDelegate> delegate;

@property(nonatomic, strong) NSArray<NSString *> *filePaths;

- (instancetype)initWithFrame:(CGRect)frame filePaths:(NSArray<NSString *> *)filePaths;

@end
