//
//  NTESUpdateData.h
//  NTESUpadateUI
//
//  Created by Netease on 17/2/28.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NTESVideoEntity;
@class NTESVideoFormatEntity;

@interface NTESUpdateData : NSObject

@property (nonatomic, assign) NSInteger videoMaxCount;

@property (nonatomic, strong) NSMutableArray <NTESVideoEntity *> *netVideos; //应用服务器上记录的视频

@property (nonatomic, strong) NSMutableArray <NTESVideoEntity *> *locVideos; //本地记录的视频（本地化）

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

/**
 全局上传数据中心
 */
+ (instancetype)shareInstance;

/**
 自定义上传数据中心

 @param recordPath 上传记录存储相对路径
 @param maxcount 最大的视频数量
 */
- (instancetype)initWithRecordPath:(NSString *)recordPath maxVideoCount:(NSInteger)maxcount NS_DESIGNATED_INITIALIZER;

/**
 清除数据
 */
- (void)clear;

/**
 读取本地记录
 */
- (void)loadLocVideos;

/**
 保存上传记录，开始上传时调用
 */
- (void)saveUpdateRecordToDisk;


/**
 根据视频的vid查询视频模型

 @param vid 视频的vid
 @return 视频已上传返回视频模型，否则返回nil
 */
- (NTESVideoEntity *)videoInVideosWithVid:(NSString *)vid;

@end
