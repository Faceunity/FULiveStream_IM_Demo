//
//  LSMediaTranscodingParaCtx.h
//  LSMediaRecoderAndProcessor
//
//  Created by Netease on 17/7/11.
//  Copyright © 2017年 朱玲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LSMediaTranscodingDefs.h"

@interface LSMediaTranscodingParaCtx : NSObject
@end


#pragma mark - 水印信息
@interface LSWaMarkRectInfo : NSObject

@property (nonatomic, strong) UIImage *waterMarkImage;
@property (nonatomic, assign) LSMediaTrascoidngWaterMarkLocation location;
@property (nonatomic, assign) unsigned int uiX; //当location为非rect模式时，uix，uiY为边距，距离边的距离，当rect模式，为水印的顶点
@property (nonatomic, assign) unsigned int uiY;
@property (nonatomic, assign) unsigned int uiWidth;
@property (nonatomic, assign) unsigned int uiHeight;
@property (nonatomic, assign) unsigned int uiBeginTimeInSec;
@property (nonatomic, assign) unsigned int uiDurationInSec;

@end

#pragma mark - 裁剪信息
@interface LSVideoCropInfo : NSObject

@property (nonatomic, assign) unsigned int uiX;
@property (nonatomic, assign) unsigned int uiY;
@property (nonatomic, assign) unsigned int uiWidth;
@property (nonatomic, assign) unsigned int uiHeight;

@end

#pragma mark - 文件信息
@interface LSMediaFileInfo : NSObject

@property (nonatomic, assign) BOOL iHaveVideo;
@property (nonatomic, assign) int64_t iDurationMS;
@property (nonatomic, assign) int64_t iBitrateKb;
@property (nonatomic, assign) int64_t iVideoWidth;
@property (nonatomic, assign) int64_t iVideoHeight;
@property (nonatomic, assign) int64_t iVideoFrameRate;
@property (nonatomic, assign) int64_t iVideoBitrateKb;
@property (nonatomic, assign) int64_t iVideoDegress;
@property (nonatomic, assign) LSMediaCodecId videoCodecID;

@property (nonatomic, assign) BOOL iHaveAudio;
@property (nonatomic, assign) int64_t iAudioBitrateKb;
@property (nonatomic, assign) int64_t iAudioNumOfChannels;
@property (nonatomic, assign) int64_t iAudioSamplerate;
@property (nonatomic, assign) LSMediaCodecId audioCodecID;

@property (nonatomic, assign) BOOL isComposable;
@property (nonatomic, copy) NSString *formatName;


@end
