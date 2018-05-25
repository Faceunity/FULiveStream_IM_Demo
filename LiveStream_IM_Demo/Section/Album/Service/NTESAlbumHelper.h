//
//  NTESAlbumHelper.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/4/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface NTESAlbumHelper : NSObject

//所有的视频类ASSets（智能相册）
+ (NSArray <PHAsset *> *)requestAllAssetsWithAscending:(BOOL)ascending;

//获取视频信息
+ (void)requestVideoInfoForAsset:(PHAsset *)asset
                        complete:(void (^)(NSString *name, CGFloat size))complete;

//获取视频原始信息
+ (NSString *)requestVideoNameForAsset:(PHAsset *)asset;

//获取视频微缩图
+ (void)requestVideoThumbForAsset:(PHAsset *)asset
                         complete:(void (^)(UIImage *thumb))complete;

@end
