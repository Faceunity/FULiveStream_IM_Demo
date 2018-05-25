//
//  NTESUpdateQueue.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/4/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESUpdateModel.h"

#define NTES_UPDATEQUEUE_QUERY_NOTE @"ntes_updatequeue_query_note"

@interface NTESUpdateQueue : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 自定义上传队列
 
 @param queue 控制的队列（一定要传递并行队列）
 */
//- (instancetype)initWithThreadQueue:(dispatch_queue_t)queue;

- (instancetype)initWithType:(NTESUpdateType)type;


/**
 队列清理
 */
- (void)clear;


/**
 添加上传任务
 
 @param models 上传任务模型
 @param complete 添加完成回调
 */
- (void)addUpdateTaskWithModels:(NSArray <NTESUpdateModel *>*)models complete:(void(^)())complete;


/**
 添加查询任务

 @param dic 查询的vid和状态字典，结构 {vid:@(state)}
 */
- (void)addQueryTaskWithDic:(NSDictionary *)dic;


/**
 取消单个上传任务

 @param item 上传任务实体
 */
- (void)cancelUpdateTaskWithItem:(NTESVideoEntity *)item;


/**
 队列全部任务暂停
 */
- (void)pause;


/**
 队列全部任务恢复
 */
- (void)resume;


/**
 队列全部任务取消
 */
- (void)cancel;

@end
