//
//  NTESChatroom.m
//  NEUIDemo
//
//  Created by Netease on 17/1/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESChatroom.h"

@implementation NTESChatroom

- (instancetype)initWithNITChatroom:(NIMChatroom *)chatroom
{
    if (self = [super init])
    {
        self.roomId = chatroom.roomId;
        self.onlineUserCount = chatroom.onlineUserCount;
        self.creatorId = chatroom.creator;
    }
    return self;
}

@end
