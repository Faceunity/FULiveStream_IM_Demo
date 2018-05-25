//
//  NTESChatroomManger.h
//  LiveStream_IM_Demo
//
//  Created by zhanggenning on 17/1/14.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESChatroom.h"
#import "NTESMember.h"

#define ChatMangerRefreshMemberNotiction  @"ChatMangerRefreshMemberNotiction" //刷新全部人员完成通知
#define ChatMangerRefreshRoomInfoNotiction  @"ChatMangerRefreshRoomInfoNotiction" //刷新完房间信息通知

typedef void(^RequestChatroomInfoComplete)(NSError *error);
typedef void(^RequestMemberCompleteBlock)(NSError *error, NTESMember *member);
typedef void(^RequestMembersCompleteBlock)(NSError *error, NSArray<NTESMember *> *members);
typedef void(^EnterCompleteBlock)(NSError *error, NSString *roomId);
typedef void(^NormalCompleteBlock)(NSError *error);

@interface NTESChatroomManger : NSObject

+ (instancetype)shareInstance;

//主播进入聊天室(创建＋进入)
- (void)anchorEnterChatroom:(EnterCompleteBlock)complete;

//主播离开聊天室(退出＋销毁)
- (void)anchorExitChatroom:(NSString *)roomId destory:(BOOL)destory complete:(NormalCompleteBlock)complete;

//观众进入聊天室(房间号)
- (void)audienceEnterChatroomWithRoomid:(NSString *)roomId complete:(EnterCompleteBlock)complete;

//观众进入聊天室(直播地址)
- (void)audienceEnterChatroomWithPullUrl:(NSString *)pullUrl complete:(EnterCompleteBlock)complete;

//观众离开聊天室
- (void)audienceExitChatroom:(NSString *)roomId isKicked:(BOOL)isKicked complete:(NormalCompleteBlock)complete;

//请求聊天室信息
- (void)requestRoomInfoWithRoomId:(NSString *)roomId complete:(RequestChatroomInfoComplete)complete;

//请求主播信息
- (void)requestAnchorInfoWithRoomId:(NSString *)roomId complete:(RequestMemberCompleteBlock)complete;

//请求刷新观众列表
- (void)requestRefreshMemberWithRoomId:(NSString *)roomId complete:(NormalCompleteBlock)complete;

//请求更多观众列表
- (void)requestNextPageMemberWithRoomId:(NSString *)roomId complete:(NormalCompleteBlock)complete;

//请求观众信息
- (void)requestMemberInfoWithRoomId:(NSString *)roomId memberId:(NSArray *)memberIds complete:(RequestMembersCompleteBlock)complete;

@end
