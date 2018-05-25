//
//  NTESDemoConfig.m
//  NIM
//
//  Created by amao on 4/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESDemoConfig.h"

@interface NTESDemoConfig ()

@end

@implementation NTESDemoConfig
+ (instancetype)sharedConfig
{
    static NTESDemoConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESDemoConfig alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        /* --------------------------  开发环境 ----------------------------*/
//        _appKey = @"9f818f8b0d072adb91a0cad597590b51";
//        _apiURL = @"http://223.252.220.238:8080/appdemo";
//        _shortVideoAppKey = @"9f818f8b0d072adb91a0cad597590b51";
        /* --------------------------  End -------------------------------*/
        
        /* --------------------------  线上环境 ----------------------------*/
        _appKey = @"d49345914660a3af65e7fa287ec90e6b";
        _apiURL = @"https://app.netease.im/appdemo";
        _shortVideoAppKey = @"d49345914660a3af65e7fa287ec90e6b";
        /* --------------------------  End -------------------------------*/
        
    }
    return self;
}

- (NSString *)appKey
{
    return _appKey;
}

- (NSString *)apiURL
{
    return _apiURL;
}

- (NSString *)cerName
{
    return nil;
}


@end
