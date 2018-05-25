//
//  NTESLiveDataHelper.h
//  NTES_Live_Demo
//
//  Created by zhanggenning on 17/1/21.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSMediaCapture.h"
#import "NELivePlayer.h"

@interface NTESLiveDataHelper : NSObject

//滤镜 < - > 选择 映射
+ (LSGpuImageFilterType)filterTypeWithSelectedIndex:(NSInteger)index;

+ (NSInteger)selectIndexWithfilterType:(LSGpuImageFilterType)filterType;

//拉流地址 <-> 映射
+ (NSString *)pullUrlWithSelectIndex:(NSInteger)index;


@end
