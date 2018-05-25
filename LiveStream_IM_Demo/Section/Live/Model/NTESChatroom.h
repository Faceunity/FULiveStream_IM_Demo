//
//  NTESChatroom.h
//  NEUIDemo
//
//  Created by Netease on 17/1/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESMember.h"

@interface NTESChatroom : NSObject

@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, assign) NSInteger onlineUserCount;

@property (nonatomic, copy) NSString *creatorId;

@property (nonatomic, assign) NSInteger status; //频道状态（0：空闲； 1：直播； 2：禁用； 3：直播录制）

- (instancetype)initWithNITChatroom:(NIMChatroom *)chatroom;

@end
