//
//  NTESMember.m
//  NEUIDemo
//
//  Created by Netease on 17/1/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESMember.h"
#import "NTESChatroomDataCenter.h"

@implementation NTESMember

- (instancetype)initWithNIMMember:(NIMChatroomMember *)member
{
    if (self = [super init])
    {
        self.userId = member.userId;
        self.showName = member.roomNickname;
        self.avatarUrlString = member.roomAvatar;
        self.isMuted = member.isMuted;
    }
    return self;
}

- (instancetype)initWithUserId:(NSString *)userId message:(NIMMessage *)message
{
    NTESMember *info = [[NTESMember alloc] init];
    info.showName = userId; //默认值
    if ([userId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount]) {
        NIMChatroomMember *member = [[NTESChatroomDataCenter sharedInstance] myInfo:message.session.sessionId];
        info.showName        = member.roomNickname;
        info.avatarUrlString = member.roomAvatar;
    }else{
        NIMMessageChatroomExtension *ext = [message.messageExt isKindOfClass:[NIMMessageChatroomExtension class]] ?
        (NIMMessageChatroomExtension *)message.messageExt : nil;
        info.showName = ext.roomNickname;
        info.avatarUrlString = ext.roomAvatar;
    }
    return info;
}

@end
