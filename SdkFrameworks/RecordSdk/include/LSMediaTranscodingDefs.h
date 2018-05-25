//
//  LSMediaTranscodingDef.h
//  LSMediaTranscoding
//
//  Created by NetEase on 2017/4/6.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#ifndef LSMediaTranscodingDef_h
#define LSMediaTranscodingDef_h

typedef NS_ENUM(NSInteger,LSMediaTrascoidngVideoQuality)
{
    LS_TRANSCODING_VideoQuality_HIGH = 0,
    LS_TRANSCODING_VideoQuality_MEDIUM,
    LS_TRANSCODING_VideoQuality_LOW,
};
// 水印位置信息
typedef NS_ENUM(NSInteger,LSMediaTrascoidngWaterMarkLocation)
{
    LS_TRANSCODING_WMARK_Rect = 0,
    LS_TRANSCODING_WMARK_LeftUP,
    LS_TRANSCODING_WMARK_LeftDown,
    LS_TRANSCODING_WMARK_RightUP,
    LS_TRANSCODING_WMARK_RightDown,
};
// 视频伸缩设置信息
typedef NS_ENUM(NSInteger,LSMediaTrascoidngScaleVideoMode)
{
    LS_TRANSCODING_SCALE_VIDEO_MODE_FULL = 0,  //随意伸缩，拉伸填充
    LS_TRANSCODING_SCALE_VIDEO_MODE_FULL_BLACK //等比例伸缩，不足部分填黑边
    
};

// 转码支持的音视频编解码器类型
typedef NS_ENUM(NSInteger, LSMediaCodecId)
{
    LS_MEDIA_CODEC_ID_UNKNOW  =0, //目前尚不支持的音视频格式
    LS_MEDIA_CODEC_ID_AAC =1,
    LS_MEDIA_CODEC_ID_H264 =2,
    LS_MEDIA_CODEC_ID_MPEG4= 3,
    LS_MEDIA_CODEC_ID_MP3=4,
    
};

// 转码错误信息
typedef NS_ENUM(NSInteger, LSMediaTrascodingErrCode)
{
    LSMediaTrascodingErrCode_NO = 0,
    LSMediaTrascodingErrCode_MissingInOrOutFile,  //缺失错误
    LSMediaTrascodingErrCode_InputFileParseError, //解析错误
    LSMediaTrascodingErrCode_InputFileParamError, //参数错误
    LSMediaTrascodingErrCode_InputFileMediaFileError, //文件错误
    LSMediaTrascodingErrCode_TranscodingError //转码错误
};

#endif /* LSMediaTranscodingDef_h */
