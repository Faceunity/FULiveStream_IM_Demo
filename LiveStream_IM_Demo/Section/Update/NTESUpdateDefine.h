//
//  NTESUpdateDefine.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#ifndef NTESUpdateDefine_h
#define NTESUpdateDefine_h

/**
 上传类型
 */
typedef NS_ENUM(NSInteger,NTESUpdateType)
{
    NTESUpdateTypeDemand = 0,
    NTESUpdateTypeShortVideo,
};

/**
 视频状态
 */
typedef NS_ENUM(NSInteger, NTESVideoItemState) //状态
{
    NTESVideoItemNormal = 0,    //正常
    NTESVideoItemUnexist,       //不存在
    NTESVideoItemCaching,       //准备中
    NTESVideoItemWaiting,       //等待中
    NTESVideoItemUpdating,      //上传中
    NTESVideoItemUpdateFail,    //上传失败
    NTESVideoItemTransCoding,   //转码中
    NTESVideoItemTransCodeFail, //转码失败
    NTESVideoItemComplete       //完成
};


/**
 视频格式
 */
typedef NS_ENUM(NSInteger, NTESVideoFormat)
{
    NTESVideoFormatSHDMP4 = 3,  //高清mp4
    NTESVideoFormatHDFLV = 5,   //标清flv
    NTESVideoFormatSDHLS = 7,   //流畅hls
};


/**
 上传阶段

 - NTESOperationReadyProcess
 */
typedef NS_ENUM(NSInteger, NTESOperationProcess) {
    NTESOperationReadyProcess            = 0, //准备中
    NTESOperationCachingProcess,              //缓存中
    NTESOperationFileInitingProcess,          //文件初始化中
    NTESOperationFileUpdatingProcess,         //文件上传中
    NTESOperationFileQueryingProcess,         //文件查询中
    NTESOperationFileReporingProcess,         //文件上报服务端中
    NTESOperationFileCompleteProcess,         //文件上传完成
};

#endif /* NTESUpdateDefine_h */
