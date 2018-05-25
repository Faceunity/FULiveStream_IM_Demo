//
//  NTESChatroomManager.m
//  NIM
//
//  Created by chris on 16/1/15.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESChatroomDataCenter.h"
#import "NSDictionary+NTESJson.h"
#import "NTESPresent.h"
#import "NTESPresentAttachment.h"
#import <pthread.h>

#import "NTESMember.h"

@interface NTESChatroomDataCenter()
{
    pthread_mutex_t _lock;
}

@property (nonatomic, strong) NSMutableDictionary *memberLibData;  //人员库(只增不减)
@property (nonatomic, strong) NSMutableDictionary *memberListData; //观众列表

@property (nonatomic, strong) NSMutableDictionary *chatrooms;  //聊天室
@property (nonatomic, strong) NSMutableDictionary *myInfo;     //我的信息
@property (nonatomic, strong) NSMutableDictionary *anchorInfo; //主持人信息

@end

@implementation NTESChatroomDataCenter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _chatrooms = [[NSMutableDictionary alloc] init];
        _myInfo = [[NSMutableDictionary alloc] init];
        _anchorInfo = [[NSMutableDictionary alloc] init];
        
        _memberLibData = [[NSMutableDictionary alloc] init];
        _memberListData = [[NSMutableDictionary alloc] init];
    }
    return self;
}

//添加人员库
- (void)memberLibAddMembers:(NSArray<NIMChatroomMember *> *)members roomId:(NSString *)roomId
{
    pthread_mutex_lock(&_lock);
    
    NSMutableDictionary *memberDic = [_memberLibData objectForKey:roomId];
    if (memberDic == nil) {
        memberDic = [NSMutableDictionary dictionary];
    }
    
    for (NIMChatroomMember *member in members) {
        [memberDic setObject:member forKey:member.userId];
    }
    [_memberLibData setObject:memberDic forKey:roomId];
    pthread_mutex_unlock(&_lock);
}

//查询人员库
- (NSArray<NIMChatroomMember *> *)memberLibQueryMembers:(NSArray <NSString *>*)memberIds roomId:(NSString *)roomId
{
    NSMutableDictionary *memberDic = [_memberLibData objectForKey:roomId];
    NSMutableArray *tempMembers = [NSMutableArray array];
    if (memberDic)//从人员库中查询
    {
        for (NSString *memberId in memberIds)
        {
            NIMChatroomMember *member = [memberDic objectForKey:memberId];
            
            if (member) {
                [tempMembers addObject:member];
            }
        }
    }
    return tempMembers;
}


#pragma mark - Public
+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESChatroomDataCenter alloc] init];
    });
    return instance;
}

//获取主播信息
- (NIMChatroomMember *)anchorInfo:(NSString *)roomId
{
    return _anchorInfo[roomId];
}

//缓存主播信息
- (void)cacheAnchorInfo:(NIMChatroomMember *)info roomId:(NSString *)roomId
{
    [_anchorInfo setObject:info forKey:roomId];
}

//获取我的信息
- (NIMChatroomMember *)myInfo:(NSString *)roomId
{
    return _myInfo[roomId];
}

//缓存我的信息
- (void)cacheMyInfo:(NIMChatroomMember *)info roomId:(NSString *)roomId
{
    [_myInfo setObject:info forKey:roomId];
}

//获取聊天室信息
- (NIMChatroom *)roomInfo:(NSString *)roomId
{
    return _chatrooms[roomId];
}

//缓存聊天室信息
- (void)cacheChatroom:(NIMChatroom *)chatroom
{
    [_chatrooms setObject:chatroom forKey:chatroom.roomId];
}

//设置观众禁言
- (void)setMemberMute:(BOOL)isMute roomId:(NSString *)roomId userId:(NSString *)userId
{
    //更新人员库信息
    NSMutableDictionary *memberDic = _memberLibData[roomId];
    
    if (memberDic) {
        NIMChatroomMember *member = [memberDic objectForKey:userId];
        pthread_mutex_lock(&_lock);
        member.isMuted = isMute;
        pthread_mutex_unlock(&_lock);
    }

    //更新列表信息
    NTESMember *targetMember = nil;
    NSInteger index = -1;
    NSMutableArray *array = _memberListData[roomId];
    if (array) {
        for (NTESMember *member in array) {
            if (member.userId == userId) {
                targetMember = member;
                index = [array indexOfObject:member];
            }
        }
    }
    
    if (targetMember != nil)
    {
        pthread_mutex_lock(&_lock);
        targetMember.isMuted = isMute;
        if (isMute) //禁言用户要置顶
        {
            [array removeObjectAtIndex:index];
            [array insertObject:targetMember atIndex:0];
        }
        pthread_mutex_unlock(&_lock);
    }
}

- (BOOL)memberIsKicked:(NSString *)userId roomId:(NSString *)roomId
{
    BOOL isKicked = NO;
    NSArray *members = _memberListData[roomId];
    if (members && members.count != 0)
    {
        for (NTESMember *member in members) {
            if (member.userId == userId)
            {
                isKicked = NO;
                break;
            }
            else
            {
                isKicked = YES;
            }
        }
    }
    else
    {
        isKicked = YES;
    }
    return isKicked;
}

//成员列表信息
- (NSArray *)membersWithRoomId:(NSString *)roomId
{
    return _memberListData[roomId];
}

//列表增加成员
- (void)memberListAddMembers:(NSArray<NTESMember *> *)members roomId:(NSString *)roomId
{
    pthread_mutex_lock(&_lock);
    NSMutableArray *memberCache = [_memberListData objectForKey:roomId];
    if (memberCache == nil)
    {
        memberCache = [NSMutableArray array];
    }
    
    NSMutableArray *addMembers = [NSMutableArray arrayWithArray:members];
    NSMutableArray *muteMembers = [NSMutableArray array];
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init]; //memory cache 中需要删除对象的索引
    NSMutableIndexSet *delIndexSet = [[NSMutableIndexSet alloc] init]; //addMembers中需要删除对象的索引
    NSMutableIndexSet *muteAddIndexSet = [[NSMutableIndexSet alloc] init]; //禁言人员添加位置索引
    
    //检查一下数据
    for (NTESMember *member in addMembers)
    {
        //把主播信息过滤掉，这里不应该存放主播信息
        NIMChatroomMember *anchor = _anchorInfo[roomId];
        if (anchor && [member.userId isEqualToString:anchor.userId]) {
            NSInteger index = [addMembers indexOfObject:member];
            [delIndexSet addIndex:index]; //删除主播信息
            break;
        }
        
        //去重
        for (NTESMember *exitMember in memberCache)
        {
            if ([member.userId isEqualToString:exitMember.userId])
            {
                NSInteger index = [memberCache indexOfObject:exitMember];
                [indexSet addIndex:index]; //删除旧的对象
                break;
            }
        }
        
        //禁言用户
        if (member.isMuted)
        {
            [muteMembers addObject:member];
            NSInteger index = [addMembers indexOfObject:member];
            [delIndexSet addIndex:index]; //删除禁言的对象
            [muteAddIndexSet addIndex:(muteMembers.count - 1)];
        }
    }
    
    //执行删除
    if (indexSet.count != 0)
    {
        [memberCache removeObjectsAtIndexes:indexSet];
    }
    if (delIndexSet.count != 0)
    {
        [addMembers removeObjectsAtIndexes:delIndexSet];
    }
    
    //头部添加禁言用户
    [memberCache insertObjects:muteMembers atIndexes:muteAddIndexSet];
    
    //尾部添加正常用户
    [memberCache addObjectsFromArray:addMembers];
    [_memberListData setObject:memberCache forKey:roomId];

    pthread_mutex_unlock(&_lock);
}

//列表删除成员
- (void)memberListDelMembers:(NSArray<NTESMember *> *)members roomId:(NSString *)roomId
{
    pthread_mutex_lock(&_lock);
    NSMutableArray *memberCache = [_memberListData objectForKey:roomId];

    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    
    //去重
    for (NTESMember *member in members)
    {
        for (NTESMember *exitMember in memberCache)
        {
            if ([member.userId isEqualToString:exitMember.userId])
            {
                NSInteger index = [memberCache indexOfObject:exitMember];
                [indexSet addIndex:index]; //增加删除对象
                break;
            }
        }
    }
    
    if (memberCache && indexSet.count != 0)
    {
        [memberCache removeObjectsAtIndexes:indexSet];
    }
    pthread_mutex_unlock(&_lock);
}

- (void)memberListClear:(NSString *)roomId
{
    pthread_mutex_lock(&_lock);
    NSMutableArray *array = _memberListData[roomId];
    [array removeAllObjects];
    [_memberListData removeObjectForKey:roomId];
    pthread_mutex_unlock(&_lock);

}

//清除房间数据
- (void)clearChatroomData:(NSString *)roomId
{
    if (roomId)
    {
        _currentRoomId = nil;
        _anchorInfo[roomId] = nil;
        _myInfo[roomId] = nil;
        _chatrooms[roomId] = nil;
        _memberLibData[roomId] = nil;
        _memberListData[roomId] = nil;
    }
}

@end
