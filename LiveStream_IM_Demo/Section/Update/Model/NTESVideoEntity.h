//
//  NTESVideoEntity.h
//  NTESUpadateUI
//
//  Created by Netease on 17/2/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESUpdateDefine.h"
#import "NTESAlbumVideoEntity.h"

@interface NTESVideoEntity : NSObject <NSCoding>

#pragma mark - 本地信息
@property (nonatomic, assign) NTESVideoItemState state; //当前的状态
@property (nonatomic, strong) NSString *title;          //文件名字
@property (nonatomic, strong) NSString *extension;      //扩展名
@property (nonatomic, assign) CGFloat duration;         //时长

#pragma mark - 选视频
@property (nonatomic, copy) NSString *assetKey;  //相册PHAsset对应的key
@property (nonatomic, assign) CGFloat fileSize;  //文件大小(M)
@property (nonatomic, strong) UIImage *thumbImg; //微缩图
@property (nonatomic, copy) NSString *fileRelPath;  //文件缓存相对路径(缓存之后才会有，使用时需要加上userRootPath）
@property (nonatomic, assign) CGFloat updateProcess; //上传进度

#pragma mark - 上传后
@property (nonatomic, copy) NSString *vid;
@property (nonatomic, copy) NSString *thumbImgUrl; //微缩图地址
@property (nonatomic, copy) NSString *origUrl;     //原文件播放地址
@property (nonatomic, copy) NSString *shdMp4Url;   //高清mp4的播放地址
@property (nonatomic, assign) CGFloat shdMp4Size;   //高清mp4的大小
@property (nonatomic, copy) NSString *hdFlvUrl;    //标清flv的播放地址
@property (nonatomic, assign) CGFloat hdFlvSize;   //标清flv的大小
@property (nonatomic, copy) NSString *sdHlsUrl;    //流畅hls的播放地址
@property (nonatomic, assign) CGFloat sdHlsSize;   //流畅hls的大小

#pragma mark - 断点续传
@property (nonatomic, assign) NTESOperationProcess updatePhase; //上传阶段
@property (nonatomic, copy) NSString *nosBucket; //nos 上传桶名
@property (nonatomic, copy) NSString *nosObject; //nos 上传对象名
@property (nonatomic, copy) NSString *nosToken;  //nos 上传token

- (instancetype)initWithAlbumVideo:(NTESAlbumVideoEntity *)albumItem;

- (void)copyFromItem:(NTESVideoEntity *)item;

+ (NTESVideoEntity *)entityWithFileName:(NSString *)name extension:(NSString *)extension relPath:(NSString *)fileRelPath;

@end
