//
//  NTESPlayStreamVC.h
//  NEUIDemo
//
//  Created by Netease on 17/1/3.
//  Copyright © 2017年 Netease. All rights reserved.
//  直播观众端ui相关

#import "NTESLivePlayer.h"
#import "NTESChatroom.h"

@interface NTESPlayStreamVC : NTESLivePlayer

@property (nonatomic, copy) NSString *roomId; //房间号

@property (nonatomic, copy) NSString *pullUrl; //拉流地址

- (instancetype)initWithChatroomid:(NSString *)chatroomId pullUrl:(NSString *)pullUrl;


@end
