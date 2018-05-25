//
//  NTESUpdateOperation.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/8.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESUpdateDefine.h"

@class NTESVideoEntity;
@protocol NTESUpdateOperationProtocol;

@interface NTESUpdateOperation : NSOperation
//上传模型
@property (nonatomic, weak) NTESVideoEntity *item;

//视频数量
@property (nonatomic, assign, readonly) NSInteger videoCount;

//转码状态
@property (nonatomic, assign, readonly) NSInteger transjobstatus;

//上传类型
@property (nonatomic, assign) NTESUpdateType type;

//回调
@property (nonatomic, weak) id <NTESUpdateOperationProtocol> delegate;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithItem:(NTESVideoEntity *)item type:(NTESUpdateType)type;

@end

@protocol NTESUpdateOperationProtocol <NSObject>

//任务开启
- (void)updateOperationDidStart:(NTESUpdateOperation *)operation;

//任务取消
- (void)updateOperationDidCancel:(NTESUpdateOperation *)operation;

//任务完成
- (void)updateOperationDidComplete:(NTESUpdateOperation *)operation
                             error:(NSError *)error
                               vid:(NSString *)vid;

//任务阶段
- (void)updateOperationStateDidChanged:(NTESUpdateOperation *)operation
                               toPhase:(NTESOperationProcess)phase;

//上传进度
- (void)updateOperationProcess:(NTESUpdateOperation *)operation process:(CGFloat)process;

@end
