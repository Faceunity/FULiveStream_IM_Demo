//
//  NTESTranscodingDataCenter.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/15.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESTranscodingDataCenter.h"

@interface NTESTranscodingDataCenter ()

@end

@implementation NTESTranscodingDataCenter

- (instancetype)init {
    if (self = [super init]) {
        [self defaultTransConfig];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESTranscodingDataCenter alloc] init];
    });
    return instance;
}

+ (void)clear {
    [[NTESTranscodingDataCenter sharedInstance] defaultTransConfig];
}

- (void)defaultTransConfig {
    
    //设置默认值
    self.transConfig = [NTESTransConfigEntity new];
    self.transConfig.brightness = 0.0;
    self.transConfig.contrast = 1.0;
    self.transConfig.saturation = 1.0;
    self.transConfig.sharpness = 0.0;
    self.transConfig.temperature = 0;
}

@end
