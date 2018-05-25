//
//  NTESRecordConfigEntity.h
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/3/30.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NTESRecordResolution)
{
    NTESRecordResolutionSD = 0, //流畅
    NTESRecordResolutionHD,     //高清
};

typedef NS_ENUM(NSInteger, NTESRecordScreenScale)
{
    NTESRecordScreenScale16x9 = 0, //16:9
    NTESRecordScreenScale4x3,      //4:3
    NTESRecordScreenScale1x1       //1:1
};


@interface NTESRecordConfigEntity : NSObject

@property (nonatomic, assign) CGFloat exposureValue;

@property (nonatomic, assign) CGFloat beautyValue;

@property (nonatomic, strong) NSArray *filterDatas;

@property(nonatomic, strong) NSArray *faceUDatas;

@property(nonatomic, strong) NSArray *faceUTitleDatas;

@property (nonatomic, assign) NSInteger filterIndex;

@property(nonatomic, assign) NSInteger faceIndex;

@property (nonatomic, assign) NSInteger section;

@property (nonatomic, assign) NSInteger duration;

@property(nonatomic, assign) BOOL beauty;

@property (nonatomic, assign) NTESRecordScreenScale screenScale;

@property (nonatomic, assign) NTESRecordResolution resolution;

@end
