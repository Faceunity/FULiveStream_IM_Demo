//
//  NTESDaoLiveModel.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDaoModel.h"

@interface NTESDaoLiveModel : NSObject
@end

#pragma mark - 主播聊天室数据模型
@interface NTESAnchorChatroomInfo : NSObject
@property (nonatomic, strong) NSNumber *roomId;
@property (nonatomic, copy) NSString *pushUrl;
@property (nonatomic, copy) NSString *rtmpPullUrl;
@property (nonatomic, copy) NSString *hlsPullUrl;
@property (nonatomic, copy) NSString *httpPullUrl;
@property (nonatomic, copy) NSString *cid;
@end

@interface NTESAnchorChatroomModel : NTESDaoModel
@property (nonatomic, strong) NTESAnchorChatroomInfo *data;
@end

#pragma mark - 观众聊天室数据模型
@interface NTESQueryChatroomInfo : NSObject
@property (nonatomic, strong) NSNumber *roomId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pushUrl;
@property (nonatomic, copy) NSString *rtmpPullUrl;
@property (nonatomic, copy) NSString *hlsPullUrl;
@property (nonatomic, copy) NSString *httpPullUrl;
@property (nonatomic, strong) NSNumber *liveStatus;
@end

@interface NTESQueryChatroomModel : NTESDaoModel
@property (nonatomic, strong) NTESQueryChatroomInfo *data;
@end
