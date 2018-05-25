//
//  NTESTrimView.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/5/27.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"

@class NTESTrimView;
@protocol NTESTrimViewDelegate <NSObject>

//调节原声大小
- (void)trimView:(NTESTrimView *)trimView audio:(NSUInteger)audioValue;
//FIX ME:sdk 目前只有全局加上淡入淡出
- (void)trimView:(NTESTrimView *)trimView fadeInOutPosition:(BOOL)hasFaded;
//调整位置,前移
- (void)trimView:(NTESTrimView *)trimView switchForward:(NSInteger)switchPosition;
//后移
- (void)trimView:(NTESTrimView *)trimView switchBackward:(NSInteger)switchPosition;

@end

@interface NTESTrimView : NTESBaseView

@property(nonatomic, weak) id<NTESTrimViewDelegate> delegate;

@property(nonatomic, strong) NSArray<NSString *> *videoPaths;

- (instancetype)initWithFrame:(CGRect)frame videoPaths:(NSArray<NSString *> *)videoPaths;

@end
