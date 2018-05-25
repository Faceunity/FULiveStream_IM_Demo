//
//  NTESDaoUpdateModel.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDaoModel.h"

@interface NTESDaoUpdateModel : NSObject
@end

@interface NTESVideoInfo : NSObject
@property (nonatomic, strong) NSNumber *completeTime;
@property (nonatomic, strong) NSNumber *createTime;
@property (nonatomic, copy)   NSString *downloadHdFlvUrl;
@property (nonatomic, copy)   NSString *downloadOrigUrl;
@property (nonatomic, copy)   NSString *downloadSdHlsUrl;
@property (nonatomic, copy)   NSString *downloadSdMp4Url;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSNumber *durationMsec;

@property (nonatomic, strong) NSNumber *hdFlvSize;
@property (nonatomic, copy)   NSString *hdFlvUrl;
@property (nonatomic, strong) NSNumber *initialSize;
@property (nonatomic, copy)   NSString *origUrl;
@property (nonatomic, strong) NSNumber *sdHlsSize;
@property (nonatomic, copy)   NSString *sdHlsUrl;
@property (nonatomic, strong) NSNumber *shdMp4Size;
@property (nonatomic, copy)   NSString *shdMp4Url;

@property (nonatomic, copy) NSString *snapshotUrl;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSNumber *typeId;
@property (nonatomic, copy)   NSString *typeName;
@property (nonatomic, strong) NSNumber *updateTime;
@property (nonatomic, copy)   NSString *videoName;
@property (nonatomic, strong) NSNumber *vid;

@end

#pragma mark - 上传 － 增加视频数据模型
@interface NTESAddVideoInfo : NSObject
@property (nonatomic, strong) NSNumber *transjobstatus; //0:转码提交成功 1:转码提交失败
@property (nonatomic, strong) NSNumber *videoCount; //上传视频的数量
@property (nonatomic, strong) NTESVideoInfo *videoinfo; //上传视频的信息
@end

@interface NTESAddVideoModel : NTESDaoModel
@property (nonatomic, strong) NTESAddVideoInfo *data;
@end

#pragma mark - 上传 － 查询视频信息
@interface NTESVideoQueryInfo : NSObject
@property (nonatomic, strong) NSNumber *totalCount;
@property (nonatomic, strong) NSArray <NTESVideoInfo *>*list;
@end

@interface NTESVideoQueryModel : NTESDaoModel
@property (nonatomic, strong) NTESVideoQueryInfo *data;
@end

#pragma mark - 上传 － 查询视频转码状态
@interface NTESVideoState : NSObject
@property (nonatomic, copy) NSString *vid;
@property (nonatomic, copy) NSNumber *transcodestatus; //10表示初始，20表示失败，30表示处理中，40表示成功，-1表示视频不存在
@end

@interface NTESVideoStateInfo : NSObject
@property (nonatomic, strong) NSArray <NTESVideoState *>*list;
@end

@interface NTESVideoStateModel : NTESDaoModel
@property (nonatomic, strong) NTESVideoStateInfo *data;
@end
