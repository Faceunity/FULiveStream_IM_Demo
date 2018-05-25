//
//  NTESUpdateEmptyView.h
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/4/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"

typedef NS_ENUM(NSInteger, NTESUpdateEmptyStyle) //状态
{
    NTESUpdateEmptyNone = 0,  //无视频
    NTESUpdateEmptyLoading,   //读取中
    NTESUpdateEmptyTimeOut,   //超时
};

typedef void(^NTESEmptyRetryBlock)();

@interface NTESUpdateEmptyView : NTESBaseView

@property (nonatomic, assign) NTESUpdateEmptyStyle style;

@property (nonatomic, copy) NTESEmptyRetryBlock retry;

- (void)show:(BOOL)isShown
       style:(NTESUpdateEmptyStyle)style;

@end
