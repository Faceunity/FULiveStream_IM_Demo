//
//  NTESChatroomManger.m
//  LiveStream_IM_Demo
//
//  Created by zhanggenning on 17/1/14.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESChatroomManger.h"
#import "NTESChatroomDataCenter.h"
#import "NTESLiveDataCenter.h"
#import "NTESDaoService+Live.h"

const NSInteger gMaxQueryCountEverySecond = 8; //每分钟最多查询的数量

@interface NTESChatroomManger ()
{
    dispatch_source_t _timer;
    dispatch_queue_t _queue;
}

@property (nonatomic, assign) BOOL allowTimerRefresh; //允许定时刷新
@property (nonatomic, assign) NSInteger requestMemberCount;     //请求列表次数
@property (nonatomic, assign) NSInteger requestMemberInfoCount; //请求成员信息次数
@property (nonatomic, assign) NSInteger delayRequestNumber;     //延迟请求的人数
@property (nonatomic, strong) NSMutableArray *delayRequestMemberIds; //待请求的member id
@property (nonatomic, copy) NormalCompleteBlock membersHandle;
@property (nonatomic, copy) RequestMembersCompleteBlock infoHandle;
@property (nonatomic, strong) NSMutableDictionary *lastMemberDic; //观众列表游标
@property (nonatomic, strong) NSMutableDictionary *lastTempMemberDic; //游客列表游标
@end

@implementation NTESChatroomManger

- (instancetype)init
{
    if (self = [super init]) {
        _lastMemberDic = [NSMutableDictionary dictionary];
        _lastTempMemberDic = [NSMutableDictionary dictionary];
        _delayRequestMemberIds = [NSMutableArray array];
        _allowTimerRefresh = NO;
        [self startTimer];
    }
    return self;
}

+ (instancetype)shareInstance
{
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NTESChatroomManger new];
    });
    return instance;
}

//主播进入聊天室
- (void)anchorEnterChatroom:(EnterCompleteBlock)complete
{
    [[NTESDaoService sharedService] requestCreateRoomCompletion:^(NSString *roomId, NSError *error) {
        if (!error)
        {
            NIMChatroomEnterRequest *request = [[NIMChatroomEnterRequest alloc] init];
            request.roomId = roomId;
            [[NIMSDK sharedSDK].chatroomManager enterChatroom:request completion:^(NSError * _Nullable error, NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me) {
                
                if (!error)
                {
                    NSLog(@"[NTES_IM_Demo] >>> 进入聊天室成功!");
                    
                    //缓存数据
                    [NTESChatroomDataCenter sharedInstance].currentRoomId = request.roomId;
                    [[NTESChatroomDataCenter sharedInstance] cacheAnchorInfo:me roomId:request.roomId];
                    [[NTESChatroomDataCenter sharedInstance] cacheMyInfo:me roomId:request.roomId];
                    [[NTESChatroomDataCenter sharedInstance] cacheChatroom:chatroom];
                }
                else
                {
                    NSLog(@"[NTES_IM_Demo] >>> 进入聊天室失败，%zi", error.code);
                }
                
                if (complete) {
                    complete(error, roomId);
                }
            }];
        }
        else
        {
            NSLog(@"[NTES_IM_Demo] >>> 进入聊天室失败, %zi!", error.code);
            if (complete) {
                complete(error, roomId);
            }
        }
    }];
}

//主播离开聊天室(退出＋销毁)
- (void)anchorExitChatroom:(NSString *)roomId destory:(BOOL)destory complete:(NormalCompleteBlock)complete
{
    //退出聊天室
    [[NIMSDK sharedSDK].chatroomManager exitChatroom:roomId completion:^(NSError * _Nullable error) {
        
        if (!error)
        {
            NSLog(@"[NTES_IM_Demo] >>> 退出聊天室成功!");
            
            if (destory) //销毁聊天室(应用服务器)
            {
                [[NTESDaoService sharedService] requestDestoryRoom:[roomId integerValue] completion:^(NSError *error) {
                    if (!error)
                    {
                        NSLog(@"[NTES_IM_Demo] >>> 销毁聊天室成功!");
                        
                        //销毁房间数据
                        [[NTESChatroomDataCenter sharedInstance] clearChatroomData:roomId];
                    }
                    else
                    {
                        NSLog(@"[NTES_IM_Demo] >>> 销毁聊天室失败!");
                    }
                    
                    if (complete)
                    {
                        complete(error);
                    }
                }];
            }
            else //不销毁聊天室(应用服务器)
            {
                if (complete) {
                    complete(error);
                }
            }
        }
        else
        {
            NSLog(@"[NTES_IM_Demo] >>> 退出聊天室失败!");
            if (complete) {
                complete(error);
            }
        }
    }];
}

//观众进入聊天室
- (void)audienceEnterChatroomWithRoomid:(NSString *)roomId complete:(EnterCompleteBlock)complete
{
    //应用服务端查询聊天室
    [[NTESDaoService sharedService] requestQueryRoomWithRoomId:[roomId integerValue] completion:^(NTESChatroom *room, NSError *error) {
        if (!error)
        {
            NSLog(@"[NTES_IM_Demo] >>> 查询聊天室成功!");
            if (room.status == 1) //正在直播
            {
                //进入聊天室
                NIMChatroomEnterRequest *request = [[NIMChatroomEnterRequest alloc] init];
                request.roomId = roomId;
                [[NIMSDK sharedSDK].chatroomManager enterChatroom:request completion:^(NSError * _Nullable error, NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me) {
                    if (!error) //进入成功
                    {
                        NSLog(@"[NTES_IM_Demo] >>> 进入聊天室成功!");
                        //保存数据
                        [NTESChatroomDataCenter sharedInstance].currentRoomId = request.roomId;
                        [[NTESChatroomDataCenter sharedInstance] cacheMyInfo:me roomId:request.roomId];
                        [[NTESChatroomDataCenter sharedInstance] cacheChatroom:chatroom];
                    }
                    else
                    {
                        NSLog(@"[NTES_IM_Demo] >>> 进入聊天室失败, %zi!", error.code);
                    }
                    
                    if (complete) {
                        complete(error, roomId);
                    }
                }];
            }
            else //没有在直播
            {
                NSLog(@"[NTES_IM_Demo] >>> 直播室状态不是直播，state=%zi!", room.status);
                error = [NSError errorWithDomain:@"NTESChatroomManger" code:0 userInfo:@{NTES_ERROR_MSG_KEY : @"该房间没有在直播"}];
                if (complete) {
                    complete(error, nil);
                }
            }
        }
        else //查询房间信息失败
        {
            NSLog(@"[NTES_IM_Demo] >>> 查询聊天室失败, %zi!", error.code);
            if (complete) {
                complete(error, nil);
            }
        }
    }];
}

- (void)audienceEnterChatroomWithPullUrl:(NSString *)pullUrl complete:(EnterCompleteBlock)complete
{
    //保存拉流地址
    [NTESLiveDataCenter shareInstance].pullUrl = pullUrl;
    
    //应用服务端查询聊天室
    [[NTESDaoService sharedService] requestQueryRoomWithPullUrl:pullUrl completion:^(NTESChatroom *room, NSError *error) {
        if (!error)
        {
            NSLog(@"[NTES_IM_Demo] >>> 查询聊天室成功!");
            if (room.status == 1) //正在直播
            {
                //进入聊天室
                NIMChatroomEnterRequest *request = [[NIMChatroomEnterRequest alloc] init];
                request.roomId = room.roomId;
                [[NIMSDK sharedSDK].chatroomManager enterChatroom:request completion:^(NSError * _Nullable error, NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me) {
                    if (!error) //进入成功
                    {
                        NSLog(@"[NTES_IM_Demo] >>> 进入聊天室成功!");
                        
                        //保存数据
                        [NTESChatroomDataCenter sharedInstance].currentRoomId = request.roomId;
                        [[NTESChatroomDataCenter sharedInstance] cacheMyInfo:me roomId:request.roomId];
                        [[NTESChatroomDataCenter sharedInstance] cacheChatroom:chatroom];
                    }
                    else
                    {
                        NSLog(@"[NTES_IM_Demo] >>> 进入聊天室失败, %zi!", error.code);
                    }
                    
                    if (complete) {
                        complete(error, chatroom.roomId);
                    }
                }];
            }
            else //没有在直播
            {
                NSLog(@"[NTES_IM_Demo] >>> 直播室状态不是直播，state=%zi!", room.status);
                error = [NSError errorWithDomain:@"NTESChatroomManger" code:0 userInfo:@{NTES_ERROR_MSG_KEY : @"没有在直播"}];
                if (complete) {
                    complete(error, nil);
                }
            }
        }
        else //查询房间信息失败
        {
             NSLog(@"[NTES_IM_Demo] >>> 查询聊天室失败, %zi!", error.code);
            if (complete) {
                complete(error, nil);
            }
        }
    }];
}

//观众离开聊天室
- (void)audienceExitChatroom:(NSString *)roomId isKicked:(BOOL)isKicked complete:(NormalCompleteBlock)complete
{
    //关闭定时刷新
    self.allowTimerRefresh = NO;
    
    if (isKicked) //如果是被踢的，则不需要退出聊天室
    {
        if (complete) {
            complete(nil);
        }
    }
    else
    {
        [[NIMSDK sharedSDK].chatroomManager exitChatroom:roomId completion:^(NSError * _Nullable error) {
            
            if (error)
            {
                NSLog(@"[NTES_IM_Demo] >>> 退出聊天室失败, %zi!", error.code);
            }
            else
            {
                NSLog(@"[NTES_IM_Demo] >>> 退出聊天室成功!");
            }
            
            if (complete) {
                complete(error);
            }
        }];
    }
    

}

//主播信息
- (void)requestAnchorInfoWithRoomId:(NSString *)roomId complete:(RequestMemberCompleteBlock)complete
{
    if (!complete) {
        return;
    }
    //缓存中查找
    NIMChatroomMember *member = [[NTESChatroomDataCenter sharedInstance] anchorInfo:roomId];
    if (member) {
        NTESMember *ntex = [[NTESMember alloc] initWithNIMMember:member];
        complete(nil,ntex);
        return;
    }
    
    //网络申请
    NIMChatroom *chatroom = [[NTESChatroomDataCenter sharedInstance] roomInfo:roomId];
    NIMChatroomMembersByIdsRequest *requst = [[NIMChatroomMembersByIdsRequest alloc] init];
    requst.roomId = roomId;
    requst.userIds = @[chatroom.creator];
    
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembersByIds:requst completion:^(NSError *error, NSArray *members) {
        
        NIMChatroomMember *anchor = members.firstObject;
        
        //缓存
        NTESMember *ntesMember = nil;
        if (anchor)
        {
            [[NTESChatroomDataCenter sharedInstance] cacheAnchorInfo:anchor roomId:roomId];
            ntesMember = [[NTESMember alloc] initWithNIMMember:anchor];
        }
        
        //回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(error, ntesMember);
            }
        });
    }];
}


//请求刷新成员列表
- (void)requestRefreshMemberWithRoomId:(NSString *)roomId complete:(NormalCompleteBlock)complete
{
    _membersHandle = complete;
    
    //停止定时刷新
    _allowTimerRefresh = NO;

    //保存当前member的个数
    NSArray* members = [[NTESChatroomDataCenter sharedInstance] membersWithRoomId:roomId];
    NSInteger number = (members.count < 20 ? 20 : members.count);

    //请求新数据
    [self requestMemebers:number roomID:roomId isRefresh:YES];
}

//请求下页成员列表
- (void)requestNextPageMemberWithRoomId:(NSString *)roomId complete:(NormalCompleteBlock)complete
{
    _membersHandle = complete;
    
    [self requestMemebers:20 roomID:roomId isRefresh:NO];
}

//请求聊天室信息
- (void)requestRoomInfoWithRoomId:(NSString *)roomId complete:(RequestChatroomInfoComplete)complete
{
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomInfo:roomId completion:^(NSError * _Nullable error, NIMChatroom * _Nullable chatroom) {
        if (!error)
        {
            //修改缓存信息
            [[NTESChatroomDataCenter sharedInstance] cacheChatroom:chatroom];
        }
        else
        {
            NSLog(@"[NTES_IM_Demo] >>> 获取房间信息失败，%zi", error.code);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ChatMangerRefreshRoomInfoNotiction object:nil];
    }];
}

//请求成员信息
- (void)requestMemberInfoWithRoomId:(NSString *)roomId memberId:(NSArray *)memberIds complete:(RequestMembersCompleteBlock)complete
{
    _infoHandle = complete;
    
    NSMutableArray *tempMessageIds = [NSMutableArray arrayWithArray:memberIds];
    
    //查询人才库
    NSArray *locMembers = [[NTESChatroomDataCenter sharedInstance] memberLibQueryMembers:memberIds roomId:roomId];
    if (locMembers.count != 0) //找到的部分先丢过去刷一下
    {
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        NSMutableArray *result = [NSMutableArray array];
        
        for (NIMChatroomMember *member in locMembers)
        {
            NTESMember *ntes = [[NTESMember alloc] initWithNIMMember:member];
            [result addObject:ntes];
            [indexSet addIndex:[locMembers indexOfObject:member]];
        }
        
        //抛出
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(nil, result);
            }
        });
        
        //移除
        [tempMessageIds removeObjectsAtIndexes:indexSet];
    }
    
    //网络
    if (tempMessageIds.count != 0)
    {
        [self requestMemberInfoWithRoomId:roomId memberIds:tempMessageIds];
    }
}

#pragma mark - Private
- (void)startTimer
{
    //请求次数清零（一分钟最多请求8次）
    dispatch_queue_t queue = dispatch_queue_create("NIMRequestQueue", NULL);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 60.0 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        [self timerAction];
        
    });
    dispatch_resume(_timer);
}

- (void)timerAction
{
    NSString *roomId = [NTESChatroomDataCenter sharedInstance].currentRoomId;
    if (roomId == nil) {
        return;
    }
    
    //清零
    _requestMemberCount = 0;
    
    if (_allowTimerRefresh) //允许定时刷新
    {
        //请求所有成员列表
        NSArray* members = [[NTESChatroomDataCenter sharedInstance] membersWithRoomId:roomId];
        NSInteger number = (members.count < 20 ? 20 : members.count);
        
        //请求新数据
        [self requestMemebers:number roomID:roomId isRefresh:YES];

        //请求房间信息
        [self requestRoomInfoWithRoomId:roomId complete:nil];
    }
    
    //请求成员信息
    if (_requestMemberInfoCount > gMaxQueryCountEverySecond && _delayRequestMemberIds.count != 0) //一分钟之内已经超过8次请求，说明有的请求没有发送，主动请求一次
    {
        _requestMemberInfoCount = 0;
        
        [self requestMemberInfoWithRoomId:roomId memberIds:_delayRequestMemberIds];
    }
    else //一分钟之内没超过8次，说明之前请求全部返回了，清零就行了。
    {
        _requestMemberInfoCount = 0;
    }
}

//请求全部列表(网络)
- (void)requestMemebers:(NSInteger)number roomID:(NSString *)roomId isRefresh:(BOOL)isRefresh
{
    //请求次数限制
    if (++_requestMemberCount > gMaxQueryCountEverySecond) {
        //这里直接返回了，等待冷却时间过后，统一请求一次
        _delayRequestNumber += number; 
        _allowTimerRefresh = YES;      //开启定时刷新
        return;
    }
    
    //请求
    __block NIMChatroomMemberRequest *requst = [[NIMChatroomMemberRequest alloc] init];
    requst.roomId = roomId;
    requst.type = NIMChatroomFetchMemberTypeRegularOnline;
    requst.limit = number; //每次请求的人数
    if (isRefresh)
    {
        requst.lastMember = nil;
    }
    else
    {
         requst.lastMember = _lastMemberDic[roomId];
    }
    
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembers:requst completion:^(NSError * _Nullable error, NSArray<NIMChatroomMember *> * _Nullable members) {
        if (members){
            
            NSArray *regularMembers = members;
            NSInteger tempNumbers = number - regularMembers.count;
            tempNumbers = (tempNumbers > 0 ? tempNumbers : 0);
            requst.limit = tempNumbers;
            requst.type = NIMChatroomFetchMemberTypeTemp;
            
            if (tempNumbers == 0) //请求数量够了，完成返回
            {
                //清除延迟请求人数
                weakSelf.delayRequestNumber = 0;
                
                //保存游标
                weakSelf.lastMemberDic[roomId] = members.lastObject;
                
                //refresh, 清一下数据源
                if (isRefresh)
                {
                    [[NTESChatroomDataCenter sharedInstance] memberListClear:roomId];
                }
                
                //更新人员库
                NSMutableArray *totalMembers = [NSMutableArray arrayWithArray:regularMembers];
                [[NTESChatroomDataCenter sharedInstance] memberLibAddMembers:totalMembers roomId:roomId];
                
                //转换一下
                NSMutableArray *array = [NSMutableArray array];
                for (NIMChatroomMember *member in totalMembers) {
                    NTESMember *ntes = [[NTESMember alloc] initWithNIMMember:member];
                    [array addObject:ntes];
                }
                
                //更新人员列表
                [[NTESChatroomDataCenter sharedInstance] memberListAddMembers:array roomId:roomId];
                
                //通知
                [[NSNotificationCenter defaultCenter] postNotificationName:ChatMangerRefreshMemberNotiction object:nil];
                
                //回调
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.membersHandle) {
                        weakSelf.membersHandle(error);
                    }
                });
                
                //开启定时刷新
                weakSelf.allowTimerRefresh = YES;
            }
            else  //数量不够，继续请求游客信息
            {
                //请求次数增1
                if (++weakSelf.requestMemberCount > gMaxQueryCountEverySecond)
                {
                    //这里直接返回了，等待冷却时间过后，统一请求一次
                    weakSelf.delayRequestNumber += number;
                    _allowTimerRefresh = YES;      //开启定时刷新
                    return;
                }
                
                //请求游客信息
                [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembers:requst completion:^(NSError * _Nullable error, NSArray<NIMChatroomMember *> * _Nullable members) {
                    
                    //清除延迟请求人数
                    weakSelf.delayRequestNumber = 0;
                    
                    //保存游标
                    weakSelf.lastMemberDic[roomId] = members.lastObject;
                    weakSelf.lastTempMemberDic[roomId] = regularMembers.lastObject;
                    
                    //refresh, 清一下数据源
                    if (isRefresh)
                    {
                        [[NTESChatroomDataCenter sharedInstance] memberListClear:roomId];
                    }
                    
                    //更新人员库
                    NSMutableArray *totalMembers = [NSMutableArray arrayWithArray:regularMembers];
                    [totalMembers addObjectsFromArray:members];
                    [[NTESChatroomDataCenter sharedInstance] memberLibAddMembers:totalMembers roomId:roomId];
                    
                    
                    //转换一下
                    NSMutableArray *array = [NSMutableArray array];
                    for (NIMChatroomMember *member in totalMembers) {
                        NTESMember *ntes = [[NTESMember alloc] initWithNIMMember:member];
                        [array addObject:ntes];
                    }
                    
                    //更新人员列表
                    [[NTESChatroomDataCenter sharedInstance] memberListAddMembers:array roomId:roomId];
                    
                    //通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:ChatMangerRefreshMemberNotiction object:nil];
                    
                    //回调
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.membersHandle) {
                            weakSelf.membersHandle(error);
                        }
                    });
                    
                    //允许定时刷新
                    weakSelf.allowTimerRefresh = YES;
                    
                    NSLog(@"请求的所有人回来了");
                }];
            }
        }
    }];
}

//请求人员信息（网络）
- (void)requestMemberInfoWithRoomId:(NSString *)roomId memberIds:(NSMutableArray *)memberIds
{
    //请求次数增1
    _requestMemberInfoCount++;
    
    
    if (_requestMemberInfoCount > gMaxQueryCountEverySecond) {
        
        [_delayRequestMemberIds addObjectsFromArray:memberIds];
        //这里直接返回了，等待冷却时间过后，统一请求一次
        return;
    }
    
    NIMChatroomMembersByIdsRequest *requst = [[NIMChatroomMembersByIdsRequest alloc] init];
    requst.roomId = roomId;
    requst.userIds = memberIds;
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembersByIds:requst completion:^(NSError * _Nullable error, NSArray<NIMChatroomMember *> * _Nullable members) {
        
        //移除缓存请求
        if (weakSelf.delayRequestMemberIds.count != 0) {
            NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
            for (NSString *memberId in weakSelf.delayRequestMemberIds) {
                for (NIMChatroomMember *member in members) {
                    if (memberId == member.userId) {
                        [indexSet addIndex:[weakSelf.delayRequestMemberIds indexOfObject:memberId]];
                        break;
                    }
                }
            }
            [weakSelf.delayRequestMemberIds removeObjectsAtIndexes:indexSet];
        }
        
        //更新人员库
        [[NTESChatroomDataCenter sharedInstance] memberLibAddMembers:members roomId:roomId];
        
        //转换一下
        NSMutableArray *array = [NSMutableArray array];
        for (NIMChatroomMember *member in members) {
            NTESMember *ntes = [[NTESMember alloc] initWithNIMMember:member];
            [array addObject:ntes];
        }
        
        //回调通知
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.infoHandle) {
                weakSelf.infoHandle(error, array);
            }
        });
        NSLog(@"请求的信息回来了");
    }];
}

@end
