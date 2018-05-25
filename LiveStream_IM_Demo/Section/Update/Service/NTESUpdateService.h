//
//  NTESUpdateService.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//  上传任务管理服务

#import <Foundation/Foundation.h>
#import "NTESUpdateQueue.h"

#define GLobalUpdateDemandQueue [NTESUpdateService shareInstance].demandQueue

#define GLobalUpdateShortVideoQueue [NTESUpdateService shareInstance].shortVideoQueue

@interface NTESUpdateService : NSObject

@property (nonatomic, strong) NTESUpdateQueue *demandQueue;

@property (nonatomic, strong) NTESUpdateQueue *shortVideoQueue;

+ (instancetype)shareInstance;

@end
