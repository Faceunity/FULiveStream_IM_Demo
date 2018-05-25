//
//  NTESAlbumService.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/4/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESAlbumGroupEntity.h"

typedef void(^NTESAlbumQueryCompleteBlock)(NSArray <NTESAlbumGroupEntity *>*groups);
typedef BOOL(^NTESAlbumCacheCancelBlock)();
typedef void(^NTESAlbumCacheCompleteBlock)(NSError *error, NSString *relPath);

@interface NTESAlbumService : NSObject

+ (instancetype)shareInstance;

//添加视频到相册
- (void)addPhotoWithComplete:(void (^)(NSError *error))complete;

//删除asset名称对应视频
- (void)deleLastVideoWithCompletion:(void(^)(BOOL success))completion
                            failure:(void(^)(NSError *error))failure;

//查询相册视频
- (void)videoGroupsWithAscending:(BOOL)ascending
                    withMinDuration:(CGFloat)duration
                        complete:(NTESAlbumQueryCompleteBlock)complete;

//缓存视频用于添加视频
- (void)cacheVideoWithAlbumVideoKey:(NSString *)assetKey
                           complete:(void (^)(NSError *error, NSString *filePath))complete;

//缓存视频
- (void)cacheVideoWithAlbumVideoKey:(NSString *)videoKey
                             cancel:(NTESAlbumCacheCancelBlock)cancel
                           complete:(NTESAlbumCacheCompleteBlock)complete;

@end
