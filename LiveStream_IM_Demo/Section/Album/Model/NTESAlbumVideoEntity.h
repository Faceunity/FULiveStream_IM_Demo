//
//  NTESAlbumVideoEntity.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/4/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAsset;

@interface NTESAlbumVideoEntity : NSObject

//名称
@property (nonatomic, copy) NSString *title;

//文件大小
@property (nonatomic, assign) CGFloat size;

//微缩图
@property (nonatomic, strong) UIImage *thumbImg;

//时长
@property (nonatomic, assign) CGFloat duration;

//PHAsset对应的key
@property (nonatomic, copy) NSString *assetKey;

@end
