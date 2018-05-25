//
//  NTESLoginManager.h
//  NIM
//
//  Created by amao on 5/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESAccount.h"

//用户被踢通知
#define kNTESAccountBeKicedNotication @"kNTESAccountBeKicedNotication"

typedef void(^LoginCompleteBlock)(NSError *error);
typedef void(^RegistCompleteBlock)(NTESAccount *account, NSError *error);
typedef void(^GetVerifyCodeCompleteBlock)(NSError *error);

@interface NTESLoginManager : NSObject

+ (instancetype)sharedManager;

//当前用户的信息
@property (nonatomic,strong) NTESAccount  *currentNTESLoginData;

- (void)loginUser:(NTESAccount *)user complete:(LoginCompleteBlock)complete;

- (void)logoutUser:(NTESAccount *)user complete:(LoginCompleteBlock)complete;

- (void)registUser:(NTESAccount *)user complete:(RegistCompleteBlock)complete;

- (void)getRegisterVerifyCode:(NSString *)phoneNum complete:(GetVerifyCodeCompleteBlock)complete;

- (void)loginUserWithPhone:(NTESAccount *)user complete:(LoginCompleteBlock)complete;

- (void)getLoginVerifyCode:(NSString *)phoneNum complete:(GetVerifyCodeCompleteBlock)complete;
@end
