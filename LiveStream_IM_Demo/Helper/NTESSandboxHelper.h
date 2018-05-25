//
//  NTESSandboxHelper.h
//  ShortVideo_Demo
//
//  Created by Netease on 17/2/14.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTESSandboxHelper : NSObject

/**
 沙盒路径
 */
+ (NSString *)documentPath;

/**
 用户根路径
 */
+ (NSString *)userRootPath;

/**
 视频上传缓存路径
 */
+ (NSString *)videoCachePath;

/**
 视频录制路径
 */
+ (NSString *)videoRecordPath;

/**
 清除录制路径的所有文件
 */
+ (void)clearRecordVideoPath;

/**
 删除文件
 */
+ (void)deleteFiles:(NSArray *)filePaths;

/**
 创建目录
 */
+ (NSError *)createDirectoryWithPath:(NSString *)path;

@end
