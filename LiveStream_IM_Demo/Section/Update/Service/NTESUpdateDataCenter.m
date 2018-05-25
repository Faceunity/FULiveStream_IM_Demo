//
//  NTESUpdateDataCenter.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateDataCenter.h"

#define MAX_DEMAND_COUNT 5
#define MAX_SHORT_VIDEO_COUNT 10

@implementation NTESUpdateDataCenter

- (instancetype)init
{
    if (self = [super init]) {
        
        NSString *recordPath = [[NTESSandboxHelper userRootPath] stringByAppendingPathComponent:@"demand_update_record"];
        _demandData = [[NTESUpdateData alloc] initWithRecordPath:recordPath maxVideoCount:MAX_DEMAND_COUNT];
        
        
        recordPath = [[NTESSandboxHelper userRootPath] stringByAppendingPathComponent:@"shortVideo_update_record"];
        _stortVideoData = [[NTESUpdateData alloc] initWithRecordPath:recordPath maxVideoCount:MAX_SHORT_VIDEO_COUNT];
    }
    return self;
}

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESUpdateDataCenter alloc] init];
    });
    return instance;
}

@end
