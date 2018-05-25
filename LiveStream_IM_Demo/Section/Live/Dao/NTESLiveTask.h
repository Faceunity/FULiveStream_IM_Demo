//
//  NTESCreateChatroomTask.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESDaoTaskProtocol.h"

@class NTESChatroom;

typedef void(^NTESCreateChatroomHandler)(NSString *roomId, NSError *error);
typedef void(^NTESQueryChatroomHandler)(NTESChatroom *room, NSError *error);

@interface NTESLiveTask : NSObject<NTESDaoTaskProtocol>
@end

@interface NTESCreateChatroomTask : NTESLiveTask
@property (nonatomic, copy) NTESCreateChatroomHandler handler;
@end

@interface NTESDistoryChatroomTask : NTESLiveTask
@property (nonatomic, strong) NSNumber *roomId;
@property (nonatomic, copy) NTESResponseHandler handler;
@end

@interface NTESQueryChatroomTask : NTESLiveTask

@property (nonatomic, strong) NSNumber *roomId;
@property (nonatomic, copy) NSString *pullUrl;
@property (nonatomic, copy) NTESQueryChatroomHandler handler;
@end
