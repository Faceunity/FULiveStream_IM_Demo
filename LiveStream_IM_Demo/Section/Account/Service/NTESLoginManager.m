//
//  NTESLoginManager.m
//  NIM
//
//  Created by amao on 5/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESLoginManager.h"
#import "NTESChatroomDataCenter.h"
#import "NTESDaoService+Account.h"

static NSString *kNtesLoginAccountPath = @"nim_sdk_login_data"; //登陆账号相对路径

@interface NTESLoginManager () <NIMLoginManagerDelegate>
@property (nonatomic,copy)  NSString    *filepath;
@end

@implementation NTESLoginManager

- (void)dealloc
{
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
}

+ (instancetype)sharedManager
{
    static NTESLoginManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *filepath = [[NTESSandboxHelper documentPath] stringByAppendingPathComponent:kNtesLoginAccountPath];
        instance = [[NTESLoginManager alloc] initWithPath:filepath];
    });
    return instance;
}

- (instancetype)initWithPath:(NSString *)filepath
{
    if (self = [super init])
    {
        _filepath = filepath;
        
        [self readData];
        
        [[NIMSDK sharedSDK].loginManager addDelegate:self];
    }
    return self;
}

- (void)setCurrentNTESLoginData:(NTESAccount *)currentNTESLoginData
{
    _currentNTESLoginData = currentNTESLoginData;
    [self saveData];
}

//从文件中读取和保存用户名密码,建议上层开发对这个地方做加密,DEMO只为了做示范,所以没加密
- (void)readData
{
    NSString *filepath = [self filepath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
        _currentNTESLoginData = [object isKindOfClass:[NTESAccount class]] ? object : nil;
    }
}

- (void)saveData
{
    NSData *data = [NSData data];
    if (_currentNTESLoginData)
    {
        data = [NSKeyedArchiver archivedDataWithRootObject:_currentNTESLoginData];
    }
    [data writeToFile:[self filepath] atomically:YES];
}

#pragma mark - Public
//登陆
- (void)loginUser:(NTESAccount *)user complete:(LoginCompleteBlock)complete
{
    //应用服务器登陆
    [[NTESDaoService sharedService] loginUser:user completion:^(NSError *error) {
        if (!error) //应用服务器登陆成功
        {
            NSLog(@"[NTES_IM_Demo] >>> 应用服务器登陆成功!");
            NSString *token = [NTESLoginManager sharedManager].currentNTESLoginData.imToken;
            NSString *accid = [NTESLoginManager sharedManager].currentNTESLoginData.accid;
            
            //NIM sdk登陆
            [[[NIMSDK sharedSDK] loginManager] login:accid token:token completion:^(NSError * _Nullable error) {
                [SVProgressHUD dismiss];
                
                if (!error) //登陆成功
                {
                    NSLog(@"[NTES_IM_Demo] >>> NIM sdk登陆成功!");
                    
                    //保存用户名和密码
                    [NTESLoginManager sharedManager].currentNTESLoginData.accid = user.accid;
                    [NTESLoginManager sharedManager].currentNTESLoginData.password = user.password;
                    
                }
                else
                {
                    NSLog(@"[NTES_IM_Demo] >>> NIM sdk登陆失败，%zi!", error.code);
                }
                
                //登陆完成
                if (complete) {
                    complete(error);
                }
            }];
        }
        else //应用服务器登陆失败
        {
            NSLog(@"[NTES_IM_Demo] >>> 应用服务器登陆失败，%zi!", error.code);
            if (complete) {
                complete(error);
            }
        }
    }];
}

//手机登录
- (void)loginUserWithPhone:(NTESAccount *)user complete:(LoginCompleteBlock)complete {
    //应用服务器登陆
    [[NTESDaoService sharedService] loginUserWithPhone:user completion:^(NSError *error) {
        if (!error) //应用服务器登陆成功
        {
            NSLog(@"[NTES_IM_Demo] >>> 应用服务器登陆成功!");
            NSString *token = [NTESLoginManager sharedManager].currentNTESLoginData.imToken;
            NSString *accid = [NTESLoginManager sharedManager].currentNTESLoginData.accid;
            
            //NIM sdk登陆
            [[[NIMSDK sharedSDK] loginManager] login:accid token:token completion:^(NSError * _Nullable error) {
                [SVProgressHUD dismiss];
                
                if (!error) //登陆成功
                {
                    NSLog(@"[NTES_IM_Demo] >>> NIM sdk登陆成功!");
                    
                }
                else
                {
                    NSLog(@"[NTES_IM_Demo] >>> NIM sdk登陆失败，%zi!", error.code);
                }
                
                //登陆完成
                if (complete) {
                    complete(error);
                }
            }];
        }
        else //应用服务器登陆失败
        {
            NSLog(@"[NTES_IM_Demo] >>> 应用服务器登陆失败，%zi!", error.code);
            if (complete) {
                complete(error);
            }
        }
    }];
}


//注销
- (void)logoutUser:(NTESAccount *)user complete:(LoginCompleteBlock)complete
{
    //注销sdk
    [[NIMSDK sharedSDK].loginManager logout:^(NSError * _Nullable error) {
        
        if (!error)
        {
            NSLog(@"[NTES_IM_Demo] >>> 应用服务器注销成功!");
            __weak typeof(self) weakSelf = self;
            [[NTESDaoService sharedService] logoutUser:user completion:^(NSError *error) {
                
                if (!error) //清空数据
                {
                    NSLog(@"[NTES_IM_Demo] >>> NIM sdk 注销成功");
                    weakSelf.currentNTESLoginData = nil;
                }
                else
                {
                    NSLog(@"[NTES_IM_Demo] >>> NIM sdk 注销失败，%zi!", error.code);
                }
                
                if (complete) {
                    complete(error);
                }
            }];
        }
        else
        {
            NSLog(@"[NTES_IM_Demo] >>> 应用服务器注销失败，%zi!", error.code);
            if (complete)
            {
                complete(error);
            }
        }
    }];
}

//注册
- (void)registUser:(NTESAccount *)user complete:(RegistCompleteBlock)complete
{
    //应用服务器注册
    __block NTESAccount *registUser = user;
    [[NTESDaoService sharedService] registerUser:user  completion:^(NSError *error) {
        
        if (!error)
        {
            NSLog(@"[NTES_IM_Demo] >>> 应用服务器注册成功!");
        }
        else
        {
            NSLog(@"[NTES_IM_Demo] >>> 应用服务器注册失败，%zi!", error.code);
            registUser = nil;
        }
        
        if (complete) {
            complete(registUser, error);
        }
    }];
}

//获取注册验证码
- (void)getRegisterVerifyCode:(NSString *)phoneNum complete:(GetVerifyCodeCompleteBlock)complete {
    [[NTESDaoService sharedService] getRegVerifyCode:phoneNum completion:^(NSError *error) {
        if (!error) {
            NSLog(@"获取验证码成功");
        }
        else {
            NSLog(@"获取验证码失败%zi", error.code);
        }
        if (complete) {
            complete(error);
        }
    }];
}

//获取登录验证码
- (void)getLoginVerifyCode:(NSString *)phoneNum complete:(GetVerifyCodeCompleteBlock)complete {
    [[NTESDaoService sharedService] getLogVerifyCode:phoneNum completion:^(NSError *error) {
        if (!error) {
            NSLog(@"获取登录验证码成功");
        }
        else {
            NSLog(@"获取验证码失败%zi", error.code);
        }
        if (complete) {
            complete(error);
        }
    }];
}

- (void)goLoginVC
{
    UINavigationController *rootVC = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC.presentedViewController) {
        [rootVC.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [rootVC popToRootViewControllerAnimated:YES];
        }];
    }
    else
    {
        [rootVC popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - NIMLoginManagerDelegate
- (void)onAutoLoginFailed:(NSError *)error
{
    //添加密码出错等引起的自动登录错误处理
    if ([error code] == NIMRemoteErrorCodeInvalidPass ||
        [error code] == NIMRemoteErrorCodeExist)
    {
        
        __weak typeof(self) weakSelf = self;
        [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
            [[NTESLoginManager sharedManager] setCurrentNTESLoginData:nil];
            
            //回登陆页面
            [weakSelf goLoginVC];
        }];
    }
}

- (void)onKick:(NIMKickReason)code clientType:(NIMLoginClientType)clientType
{
    NSLog(@"current thread is :%@", [NSThread currentThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNTESAccountBeKicedNotication object:nil];
    
    //现在改成支持多端登陆的了，10个相同的登陆会踢掉第一个登陆的设备
    NTESAccount *currentAccout = [NTESLoginManager sharedManager].currentNTESLoginData;
    [[NTESLoginManager sharedManager] logoutUser:currentAccout complete:^(NSError *error) {
        if (error) {
            NSLog(@"应用服务器注销失败，%@", error);
        }
    }];
}


@end
