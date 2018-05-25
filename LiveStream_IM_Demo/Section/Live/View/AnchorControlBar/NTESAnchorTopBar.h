//
//  NTESAnchorTopBar.h
//  NEUIDemo
//
//  Created by Netease on 17/1/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESChatroom.h"
#import "NTESMember.h"

@protocol NTESAnchorTopBarProtocol;

@interface NTESAnchorTopBar : UIView

@property (nonatomic, weak) id <NTESAnchorTopBarProtocol> delegate;

+ (instancetype)topBarInstance;

//隐藏和聊天室相关信息
- (void)hiddenChatroomView:(BOOL)isHidden;

- (void)hiddenVideo:(BOOL)isHidden;
- (void)hiddenAudio:(BOOL)isHidden;
- (void)hiddenCamera:(BOOL)isHidden;

- (void)refreshBarWithChatroom:(NTESChatroom *)chatroom;

- (void)refreshBarWithAudiences:(NSArray <NTESMember *> *)audiences;

- (void)sendTouchupInsideToAudio; //模拟按下伴音按键

@end

@protocol NTESAnchorTopBarProtocol <NSObject>
//关闭
- (void)topBarClose:(NTESAnchorTopBar *)bar;
//视频开启
- (void)topBar:(NTESAnchorTopBar *)bar videoOpen:(BOOL)isOpen;
//音频开启
- (void)topBar:(NTESAnchorTopBar *)bar audioOpen:(BOOL)isOpen;
//镜头前向
- (void)topBar:(NTESAnchorTopBar *)bar cameraIsFront:(BOOL)isFront;

//点击了用户头像
- (void)topBar:(NTESAnchorTopBar *)bar didSelectMember:(NTESMember *)member;

@end
