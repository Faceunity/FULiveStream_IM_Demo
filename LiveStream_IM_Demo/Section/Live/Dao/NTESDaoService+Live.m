//
//  NTESDaoService+Live.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDaoService+Live.h"

@implementation NTESDaoService (Live)

- (void)requestCreateRoomCompletion:(NTESCreateChatroomHandler)completion
{
    NTESCreateChatroomTask *task = [[NTESCreateChatroomTask alloc] init];
    task.handler = completion;
    [self runTask:task];
}

- (void)requestDestoryRoom:(NSInteger)roomId
                completion:(NTESResponseHandler)completion
{
    NTESDistoryChatroomTask *task = [[NTESDistoryChatroomTask alloc] init];
    task.roomId = @(roomId);
    task.handler = completion;
    [self runTask:task];
}

- (void)requestQueryRoomWithRoomId:(NSInteger)roomId
                        completion:(NTESQueryChatroomHandler)completion
{
    NTESQueryChatroomTask *task = [NTESQueryChatroomTask new];
    task.roomId = @(roomId);
    task.handler = completion;
    [self runTask:task];
}

- (void)requestQueryRoomWithPullUrl:(NSString *)pullUrl
                         completion:(NTESQueryChatroomHandler)completion
{
    NTESQueryChatroomTask *task = [NTESQueryChatroomTask new];
    task.pullUrl = pullUrl;
    task.handler = completion;
    [self runTask:task];
}

@end
