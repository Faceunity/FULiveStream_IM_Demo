//
//  NTESUpdateService.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateService.h"

@implementation NTESUpdateService

- (instancetype)init
{
    if (self = [super init])
    {
        _demandQueue = [[NTESUpdateQueue alloc] initWithType:NTESUpdateTypeDemand];
        
        _shortVideoQueue = [[NTESUpdateQueue alloc] initWithType:NTESUpdateTypeShortVideo];
    }
    return self;
}

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESUpdateService alloc] init];
    });
    return instance;
}

@end
