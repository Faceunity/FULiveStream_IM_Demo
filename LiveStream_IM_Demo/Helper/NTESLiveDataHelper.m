//
//  NTESLiveDataHelper.m
//  NTES_Live_Demo
//
//  Created by zhanggenning on 17/1/21.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "NTESLiveDataHelper.h"
#import "NTESLiveDataCenter.h"

@implementation NTESLiveDataHelper

+ (LSGpuImageFilterType)filterTypeWithSelectedIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            return LS_GPUIMAGE_NORMAL;
        case 1:
            return LS_GPUIMAGE_ZIRAN;
        case 2:
            return LS_GPUIMAGE_MEIYAN1;
        case 3:
            return LS_GPUIMAGE_MEIYAN2;
        case 4:
            return LS_GPUIMAGE_SEPIA;
        default:
            NSLog(@"[Demo] >>> 参数出错，默认LS_GPUIMAGE_NORMAL");
            return LS_GPUIMAGE_NORMAL;
    }
}

+ (NSInteger)selectIndexWithfilterType:(LSGpuImageFilterType)filterType
{
    switch (filterType)
    {
        case LS_GPUIMAGE_NORMAL:
            return 0;
        case LS_GPUIMAGE_ZIRAN:
            return 1;
        case LS_GPUIMAGE_MEIYAN1:
            return 2;
        case LS_GPUIMAGE_MEIYAN2:
            return 3;
        case LS_GPUIMAGE_SEPIA:
            return 4;
        default:
            return 0;
    }
}

+ (NSString *)pullUrlWithSelectIndex:(NSInteger)index
{
    switch (index)
    {
        case 0:
            return ([NTESLiveDataCenter shareInstance].httpPullUrl ?: @"");
        case 1:
            return ([NTESLiveDataCenter shareInstance].hlsPullUrl ?: @"");
        case 2:
            return ([NTESLiveDataCenter shareInstance].rtmpPullUrl ?: @"");
        default:
            return ([NTESLiveDataCenter shareInstance].pullUrl ?: @"");
    }
}

@end
