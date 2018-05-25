//
//  NTESUpdateModel.h
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/4/7.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NTESVideoEntity.h"

typedef void(^NTESUpdateBlock)(NSError *error, NTESVideoEntity *item);

@interface NTESUpdateModel : NSObject

@property (nonatomic, weak) NTESVideoEntity *item;

@property (nonatomic, assign) BOOL isPaused;

/**
 开始回调
 */
@property (nonatomic, copy) NTESUpdateBlock startBlock;

/**
 取消回调
 */
@property (nonatomic, copy) NTESUpdateBlock cancelBlock;

/**
 暂停回调
 */
@property (nonatomic, copy) NTESUpdateBlock pauseBlock;

/**
 完成回调
 */
@property (nonatomic, copy) NTESUpdateBlock completeBlock;

/**
 阶段回调
 */
@property (nonatomic, copy) NTESUpdateBlock phaseBlock;

/**
 进度回调
 */
@property (nonatomic, copy) NTESUpdateBlock processBlock;

@end
