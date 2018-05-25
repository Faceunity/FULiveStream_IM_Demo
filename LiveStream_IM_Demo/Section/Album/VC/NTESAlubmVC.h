//
//  NTESAlubmVC.h
//  NTESUpadateUI
//
//  Created by Netease on 17/2/23.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseVC.h"

@class NTESAlbumVideoEntity;

typedef void(^NTESAlubmSelectBlock)(NSArray<NTESAlbumVideoEntity *> *selectVideos);

@interface NTESAlubmVC : NTESBaseVC

@property (nonatomic, copy) NTESAlubmSelectBlock selected;

@property (nonatomic, assign) NSInteger maxNumber;

@property(nonatomic, assign) CGFloat minDuration;

/**
 *  多选上传视频
 *
 *  @param maxNumber 最大可选数
 *  @param duration  最短视频时长过滤
 *  @param selected  选择的回调
 *
 *  @return 返回一个 NTESAlbumVC 实例
 */

+ (instancetype)albumWithMaxNumber:(NSInteger)maxNumber withMinDuration:(CGFloat)duration selected:(NTESAlubmSelectBlock)selected;

@end
