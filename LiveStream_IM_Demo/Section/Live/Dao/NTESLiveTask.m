//
//  NTESCreateChatroomTask.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESLiveTask.h"
#import "NTESDaoLiveModel.h"
#import "NTESChatroom.h"
#import "NTESLiveDataCenter.h"
#import "NTESUDIDSolution.h"

@implementation NTESLiveTask
- (NSURLRequest *)taskRequest
{
    return NULL;
}

- (void)onGetResponse:(id)jsonObject
                error:(NSError *)error {}
@end

@implementation NTESCreateChatroomTask
- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[[NTESDemoConfig sharedConfig] apiURL] stringByAppendingString:@"/room/create"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *accid = [NTESLoginManager sharedManager].currentNTESLoginData.accid;
    //添加deviceid 用于解决主播崩溃后一段时间内无法进入聊天室的问题。
    NSString *deviceId = [NTESUDIDSolution xlUDID_MD5];
    NSString *postData = [NSString stringWithFormat:@"sid=%@&deviceId=%@",accid, deviceId];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error
{
    NSError *resultError = error;
    NSString *roomId = nil;
    
    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NTESAnchorChatroomModel *response = [NTESAnchorChatroomModel yy_modelWithDictionary:jsonObject];
        
        if ([response.code integerValue] != 200)
        {
            resultError = [NSError errorWithDomain:@"ntes domain"
                                              code:[response.code integerValue]
                                          userInfo:@{NTES_ERROR_MSG_KEY: (response.msg ?: @"")}];
        }
        else
        {
            //存储数据
            roomId = [NSString stringWithFormat:@"%@", response.data.roomId];
            [NTESLiveDataCenter shareInstance].pushUrl = response.data.pushUrl;
            [NTESLiveDataCenter shareInstance].rtmpPullUrl = response.data.rtmpPullUrl;
            [NTESLiveDataCenter shareInstance].hlsPullUrl = response.data.hlsPullUrl;
            [NTESLiveDataCenter shareInstance].httpPullUrl = response.data.httpPullUrl;
        }
    }
    
    if (_handler) {
        _handler(roomId, resultError);
    }
}
@end

@implementation NTESDistoryChatroomTask
- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[[NTESDemoConfig sharedConfig] apiURL] stringByAppendingString:@"/room/leave"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *sid = [NTESLoginManager sharedManager].currentNTESLoginData.accid;
    NSString *postData = [NSString stringWithFormat:@"sid=%@&roomId=%@",sid, _roomId];
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
            //删除数据
            [NTESLiveDataCenter shareInstance].pushUrl = nil;
            [NTESLiveDataCenter shareInstance].pullUrl = nil;
        }
    }
    
    if (_handler) {
        _handler(resultError);
    }
}
@end

@implementation NTESQueryChatroomTask
- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[[NTESDemoConfig sharedConfig] apiURL] stringByAppendingString:@"/room/enter"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:30];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *sid = [NTESLoginManager sharedManager].currentNTESLoginData.accid;
    
    NSMutableString *params = [NSMutableString string];
    if (_roomId) {
        [params appendString:[NSString stringWithFormat:@"&roomId=%@", _roomId]];
    }
    if (_pullUrl) {
        [params appendString:[NSString stringWithFormat:@"&pullUrl=%@", _pullUrl]];
    }
    NSString *postData = [NSString stringWithFormat:@"sid=%@%@",sid, params];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error
{
    NSError *resultError = error;
    NTESChatroom *chatroom = nil;

    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NTESQueryChatroomModel *response = [NTESQueryChatroomModel yy_modelWithDictionary:jsonObject];
        if ([response.code integerValue] != 200)
        {
            resultError = [NSError errorWithDomain:@"ntes domain"
                                              code:[response.code integerValue]
                                          userInfo:@{NTES_ERROR_MSG_KEY: (response.msg ?: @"")}];
        }
        else
        {
            chatroom = [NTESChatroom new];
            chatroom.roomId = [NSString stringWithFormat:@"%@", response.data.roomId];
            chatroom.creatorId = response.data.name;
            chatroom.status = [response.data.liveStatus integerValue];
            
            //存储数据
            [NTESLiveDataCenter shareInstance].rtmpPullUrl = response.data.rtmpPullUrl;
            [NTESLiveDataCenter shareInstance].hlsPullUrl = response.data.hlsPullUrl;
            [NTESLiveDataCenter shareInstance].httpPullUrl = response.data.httpPullUrl;
        }
    }
    
    if (_handler) {
        _handler(chatroom, resultError);
    }
}
@end
