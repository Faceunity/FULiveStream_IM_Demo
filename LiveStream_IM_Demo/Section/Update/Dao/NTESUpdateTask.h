//
//  NTESUpdateTask.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/8.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESDaoTaskProtocol.h"
#import "NTESVideoEntity.h"

typedef void(^NTESVideoAddHandler)(NSError *error, NSInteger transjobstatus, NSInteger videoCount, NTESVideoEntity *info);
typedef void(^NTESVideoQueryHandler)(NSError *error, NSArray <NTESVideoEntity *> *infos);
typedef void(^NTESVideoStateHandler)(NSError *error, NSDictionary *states); //{vid:state} 10表示初始，20表示失败，30表示处理中，40表示成功，-1表示视频不存在

@interface NTESUpdateTask : NSObject<NTESDaoTaskProtocol>
@end

//增加视频Id，上传成功后调用
@interface NTESVideoAddTask : NTESUpdateTask
@property (nonatomic, copy) NSString *vid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NTESVideoAddHandler handler;
@end

@interface NTESVideoDelTask : NTESUpdateTask
@property (nonatomic, copy) NSString *vid;
@property (nonatomic, copy) NSString *format; //nil:源视频   other:1表示标清mp4，
                                              //2表示高清mp4，3表示超清mp4，4表示标清flv，5表示高清flv，
                                              //6表示超清flv，7表示标清hls，8表示高清hls，9表示超清hls
@property (nonatomic, copy) NTESResponseHandler handler;
@end

//查询视频信息
@interface NTESVideoQueryTask : NTESUpdateTask
@property (nonatomic, copy) NSString *vid;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NTESVideoQueryHandler handler;
@end


//查询视频转码状态
@interface NTESVideoStateTask : NTESUpdateTask
@property (nonatomic, copy) NSArray *vids;
@property (nonatomic, copy) NTESVideoStateHandler handler;
@end
