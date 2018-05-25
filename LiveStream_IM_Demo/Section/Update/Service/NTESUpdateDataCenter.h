//
//  NTESUpdateDataCenter.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//  上传的数据管理中心

#import <Foundation/Foundation.h>

#import "NTESUpdateData.h"

#define GLobalUpdateDemandData [NTESUpdateDataCenter shareInstance].demandData

#define GLobalUpdateShortVideoData [NTESUpdateDataCenter shareInstance].stortVideoData

@interface NTESUpdateDataCenter : NSObject

@property (nonatomic, strong) NTESUpdateData *demandData;

@property (nonatomic, strong) NTESUpdateData *stortVideoData;

+ (instancetype)shareInstance;

@end
