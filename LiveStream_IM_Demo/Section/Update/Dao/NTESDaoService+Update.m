//
//  NTESDaoService+Update.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDaoService+Update.h"

@implementation NTESDaoService (Update)

- (void)requestAddVideoWithName:(NSString *)name
                            vid:(NSString *)vid
                           type:(NSInteger)type
                     completion:(NTESVideoAddHandler)completion
{
    NTESVideoAddTask *task = [NTESVideoAddTask new];
    task.name = name;
    task.vid = vid;
    task.type = type;
    task.handler = completion;
    [self runTask:task];
}

- (void)requestDelVideoWithVid:(NSString *)vid
                        format:(NSString *)format
                    completion:(NTESResponseHandler)completion
{
    NTESVideoDelTask *task = [NTESVideoDelTask new];
    task.vid = vid;
    task.format = format;
    task.handler = completion;
    [self runTask:task];
}

- (void)requestQueryVideoInfoWithType:(NSInteger)type
                           completion:(NTESVideoQueryHandler)completion
{
    NTESVideoQueryTask *task = [NTESVideoQueryTask new];
    task.type = type;
    task.handler = completion;
    [self runTask:task];
}

- (void)requestQueryVideoInfoWithVid:(NSString *)vid
                          completion:(NTESVideoQueryHandler)completion
{
    NTESVideoQueryTask *task = [NTESVideoQueryTask new];
    task.vid = vid;
    task.handler = completion;
    [self runTask:task];
}

- (void)requestVideoStateWithVids:(NSArray *)vids
                       completion:(NTESVideoStateHandler)completion
{
    NTESVideoStateTask *task = [NTESVideoStateTask new];
    task.vids = vids;
    task.handler = completion;
    [self runTask:task];
}

@end
