//
//  NTESChatroomManager.h
//  NIM
//
//  Created by chris on 16/1/15.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NTESMember;

@interface NTESChatroomDataCenter : NSObject

@property (nonatomic, copy) NSString *currentRoomId;

+ (instancetype)sharedInstance;

- (NIMChatroomMember *)anchorInfo:(NSString *)roomId;

- (NIMChatroomMember *)myInfo:(NSString *)roomId;

- (NIMChatroom *)roomInfo:(NSString *)roomId;

- (void)cacheAnchorInfo:(NIMChatroomMember *)info roomId:(NSString *)roomId;

- (void)cacheMyInfo:(NIMChatroomMember *)info roomId:(NSString *)roomId;

- (void)cacheChatroom:(NIMChatroom *)chatroom;

//成员列表信息
- (NSArray *)membersWithRoomId:(NSString *)roomId;

//增加成员库
- (void)memberLibAddMembers:(NSArray<NIMChatroomMember *> *)members
                     roomId:(NSString *)roomId;

//成员库中查询,返回已查到的成员
- (NSArray<NIMChatroomMember *> *)memberLibQueryMembers:(NSArray <NSString *>*)memberIds
                                                 roomId:(NSString *)roomId;
//增加观众
- (void)memberListAddMembers:(NSArray<NTESMember *> *)members roomId:(NSString *)roomId;

//减少观众
- (void)memberListDelMembers:(NSArray<NTESMember *> *)members roomId:(NSString *)roomId;

//清空观众
- (void)memberListClear:(NSString *)roomId;

//设置观众禁言
- (void)setMemberMute:(BOOL)isMute roomId:(NSString *)roomId userId:(NSString *)userId;

//观众是否已经被踢
- (BOOL)memberIsKicked:(NSString *)userId roomId:(NSString *)roomId;

//清除房间数据
- (void)clearChatroomData:(NSString *)roomId;

@end
