//
//  NTESUpdateDelegate.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/12.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateDelegate.h"

@implementation NTESUpdateDelegate

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESUpdateDelegate alloc] init];
    });
    return instance;
}

#pragma mark - <NOSUploadRequestDelegate>
-(NSString *)NOSUploadAppKey{
    
    NSString *appKey = [NTESDemoConfig sharedConfig].appKey;
    
    return (appKey ? appKey : @"");
}

-(NSString *)NOSVcloudAppAccid{
    
    NSString *userName = [NTESLoginManager sharedManager].currentNTESLoginData.accid;
    
    return (userName ? userName : @"");
}

-(NSString *)NOSVcloudAppToken{

    NSString *token = [NTESLoginManager sharedManager].currentNTESLoginData.vodToken;
    
    return (token ? token : @"");
}

@end
