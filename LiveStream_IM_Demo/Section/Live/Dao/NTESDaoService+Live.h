//
//  NTESDaoService+Live.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDaoService.h"
#import "NTESLiveTask.h"

@interface NTESDaoService (Live)

- (void)requestCreateRoomCompletion:(NTESCreateChatroomHandler)completion;

- (void)requestDestoryRoom:(NSInteger)roomId
                completion:(NTESResponseHandler)completion;

- (void)requestQueryRoomWithRoomId:(NSInteger)roomId
                        completion:(NTESQueryChatroomHandler)completion;

- (void)requestQueryRoomWithPullUrl:(NSString *)pullUrl
                         completion:(NTESQueryChatroomHandler)completion;

@end
