//
//  NTESFaceUManager.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/7/25.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTESFaceUManager : NSObject

+ (instancetype)shareInstance;

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)reloadItem:(NSString *)selectedItem;

// 不需要使用的时候销毁道具 以降低内存
- (void)clearAllItems ;

/**切换前后摄像头要调用此函数*/
- (void)onCameraChange;
@end
