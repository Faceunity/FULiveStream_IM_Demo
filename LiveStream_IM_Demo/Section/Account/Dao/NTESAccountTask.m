//
//  NTESAccountTask.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAccountTask.h"
#import "NTESDaoAccountModel.h"

@implementation NTESAccountTask
- (NSURLRequest *)taskRequest
{
    return NULL;
}

- (void)onGetResponse:(id)jsonObject
                error:(NSError *)error {}
@end

#pragma mark - 登陆
@implementation NTESLoginTask
- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[[NTESDemoConfig sharedConfig] apiURL] stringByAppendingString:@"/user/login"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *postData = [NSString stringWithFormat:@"accid=%@&password=%@",[_data accid],[_data password]];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error
{
    NSError *resultError = error;
    
    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NTESDaoAccountModel *response = [NTESDaoAccountModel yy_modelWithDictionary:jsonObject];
        
        if ([response.code integerValue] != 200)
        {
            resultError = [NSError errorWithDomain:@"ntes domain"
                                              code:[response.code integerValue]
                                          userInfo:@{NTES_ERROR_MSG_KEY: (response.msg ?: @"")}];
        }
        else
        {
            //存放用户信息
            NTESAccount *account = [NTESAccount new];
            account.accid = response.data.accid;
            account.nickname = response.data.nickname;
            account.imToken = response.data.imToken;
            account.vodToken = response.data.vodToken;
            [NTESLoginManager sharedManager].currentNTESLoginData = account;
            resultError = nil;
        }
    }
    
    if (_handler) {
        _handler(resultError);
    }
}
@end

#pragma mark - 手机登录
@implementation NTESLoginWithPhoneTask
- (NSURLRequest *)taskRequest {
    NSString *urlString = [[[NTESDemoConfig sharedConfig] apiURL] stringByAppendingString:@"/user/phoneLogin"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *postData = [NSString stringWithFormat:@"phone=%@&verifyCode=%@",[_data phone],[_data verifyCode]];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error {
    NSError *resultError = error;
    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NTESDaoAccountModel *response = [NTESDaoAccountModel yy_modelWithDictionary:jsonObject];
        
        if ([response.code integerValue] != 200)
        {
            resultError = [NSError errorWithDomain:@"ntes domain"
                                              code:[response.code integerValue]
                                          userInfo:@{NTES_ERROR_MSG_KEY: (response.msg ?: @"")}];
        }
        else
        {
            //存放用户信息
            NTESAccount *account = [NTESAccount new];
            account.accid = response.data.accid;
            account.nickname = response.data.nickname;
            account.imToken = response.data.imToken;
            account.vodToken = response.data.vodToken;
            [NTESLoginManager sharedManager].currentNTESLoginData = account;
            resultError = nil;
        }
    }
    
    if (_handler) {
        _handler(resultError);
    }
}

@end

#pragma mark - 注销
@implementation NTESLogoutTask
- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[[NTESDemoConfig sharedConfig] apiURL] stringByAppendingString:@"/user/logout"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *postData = [NSString stringWithFormat:@"sid=%@",_data.accid];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error
{
    NSError *resultError = error;
    
    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NTESDaoModel *response = [NTESDaoModel yy_modelWithDictionary:jsonObject];
        
        if ([response.code integerValue] != 200)
        {
            resultError = [NSError errorWithDomain:@"ntes domain"
                                              code:[response.code integerValue]
                                          userInfo:@{NTES_ERROR_MSG_KEY: (response.msg ?: @"")}];
        }
        else
        {
            //清除用户信息
            [NTESLoginManager sharedManager].currentNTESLoginData = nil;
            resultError = nil;
        }
    }
    
    if (_handler) {
        _handler(resultError);
    }
}
@end

#pragma mark - 注册
@implementation NTESRegisterTask
- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[[NTESDemoConfig sharedConfig] apiURL] stringByAppendingString:@"/user/reg"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *postData = [NSString stringWithFormat:@"accid=%@&password=%@&nickname=%@&phone=%@&verifyCode=%@",[_data accid],[_data password],[_data nickname],[_data phone],[_data verifyCode]];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error
{
    NSError *resultError = error;
    
    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NTESDaoModel *response = [NTESDaoModel yy_modelWithDictionary:jsonObject];
        
        if ([response.code integerValue] != 200)
        {
            resultError = [NSError errorWithDomain:@"ntes domain"
                                              code:[response.code integerValue]
                                          userInfo:@{NTES_ERROR_MSG_KEY: (response.msg ?: @"")}];
        }
        else
        {
            resultError = nil;
        }
    }
    
    if (_handler) {
        _handler(resultError);
    }
}

@end

#pragma mark - 注册获取验证码
@implementation NTESGetRegVerifyCodeTask
- (NSURLRequest *)taskRequest {
    NSString *urlString = [[[NTESDemoConfig sharedConfig] apiURL] stringByAppendingString:@"/user/reg/sendCode"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *postData = [NSString stringWithFormat:@"phone=%@", _phoneNum];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    return request;

}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error
{
    NSError *resultError = error;
    
    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NTESDaoModel *response = [NTESDaoModel yy_modelWithDictionary:jsonObject];
        
        if ([response.code integerValue] != 200)
        {
            resultError = [NSError errorWithDomain:@"ntes domain"
                                              code:[response.code integerValue]
                                          userInfo:@{NTES_ERROR_MSG_KEY: (response.msg ?: @"")}];
        }
        else
        {
            resultError = nil;
        }
    }
    
    if (_handler) {
        _handler(resultError);
    }
}

@end


@implementation NTESGetLogVerifyCodeTask

- (NSURLRequest *)taskRequest {
    NSString *urlString = [[[NTESDemoConfig sharedConfig] apiURL] stringByAppendingString:@"/user/phoneLogin/sendCode"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *postData = [NSString stringWithFormat:@"phone=%@", _phoneNum];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
    
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error
{
    NSError *resultError = error;
    
    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NTESDaoModel *response = [NTESDaoModel yy_modelWithDictionary:jsonObject];
        
        if ([response.code integerValue] != 200)
        {
            resultError = [NSError errorWithDomain:@"ntes domain"
                                              code:[response.code integerValue]
                                          userInfo:@{NTES_ERROR_MSG_KEY: (response.msg ?: @"")}];
        }
        else
        {
            resultError = nil;
        }
    }
    
    if (_handler) {
        _handler(resultError);
    }
}

@end
