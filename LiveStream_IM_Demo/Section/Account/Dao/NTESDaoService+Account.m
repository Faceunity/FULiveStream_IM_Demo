//
//  NTESDaoService+Account.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDaoService+Account.h"
#import "NTESAccountTask.h"

@implementation NTESDaoService (Account)

- (void)registerUser:(NTESAccount *)data
          completion:(NTESResponseHandler)completion
{
    NTESRegisterTask *task = [[NTESRegisterTask alloc] init];
    task.data = data;
    task.handler = completion;
    [self runTask:task];
}

- (void)getRegVerifyCode:(NSString *)phone
           completion:(NTESResponseHandler)completion {
    NTESGetRegVerifyCodeTask *task = [[NTESGetRegVerifyCodeTask alloc] init];
    task.phoneNum = phone;
    task.handler = completion;
    [self runTask:task];
}

- (void)loginUser:(NTESAccount *)data
       completion:(NTESResponseHandler)completion
{
    NTESLoginTask *task = [[NTESLoginTask alloc] init];
    task.data = data;
    task.handler = completion;
    [self runTask:task];
}

- (void)getLogVerifyCode:(NSString *)phone
              completion:(NTESResponseHandler)completion {
    NTESGetLogVerifyCodeTask *task = [[NTESGetLogVerifyCodeTask alloc] init];
    task.phoneNum = phone;
    task.handler = completion;
    [self runTask:task];
}

- (void)loginUserWithPhone:(NTESAccount *)data
                completion:(NTESResponseHandler)completion {
    NTESLoginWithPhoneTask *task = [[NTESLoginWithPhoneTask alloc] init];
    task.data = data;
    task.handler = completion;
    [self runTask:task];
}

- (void)logoutUser:(NTESAccount *)data
        completion:(NTESResponseHandler)completion
{
    NTESLogoutTask *task = [[NTESLogoutTask alloc] init];
    task.data = data;
    task.handler = completion;
    [self runTask:task];
}

@end
